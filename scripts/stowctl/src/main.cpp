#include <algorithm>
#include <array>
#include <cerrno>
#include <cctype>
#include <clocale>
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <set>
#include <sstream>
#include <string>
#include <string_view>
#include <sys/wait.h>
#include <utility>
#include <vector>

#include <ncurses.h>

namespace fs = std::filesystem;

enum class Mode {
  Stow,
  Restow,
  Unstow,
};

enum class PackageState {
  Stowed,
  Pending,
  Error,
};

struct Package {
  std::string name;
  fs::path source;
  PackageState state = PackageState::Pending;
  std::string detail;
  bool selected = false;
};

struct CommandResult {
  int exit_code = -1;
  std::string output;
};

struct Config {
  fs::path repo_root;
  fs::path target_root;
  std::set<std::string> ignored_packages = {"greetd", "scripts"};
};

static std::string trim(std::string s) {
  auto not_space = [](unsigned char c) { return !std::isspace(c); };
  s.erase(s.begin(), std::find_if(s.begin(), s.end(), not_space));
  s.erase(std::find_if(s.rbegin(), s.rend(), not_space).base(), s.end());
  return s;
}

static std::vector<std::string> split_lines(const std::string& text) {
  std::vector<std::string> lines;
  std::istringstream in(text);
  std::string line;
  while (std::getline(in, line)) {
    lines.push_back(line);
  }
  return lines;
}

static std::string shell_quote(const std::string& value) {
  std::string out = "'";
  for (char ch : value) {
    if (ch == '\'') {
      out += "'\"'\"'";
    } else {
      out += ch;
    }
  }
  out += "'";
  return out;
}

static std::string join(const std::vector<std::string>& items, std::string_view sep = " ") {
  std::string out;
  for (std::size_t i = 0; i < items.size(); ++i) {
    if (i > 0) {
      out += sep;
    }
    out += items[i];
  }
  return out;
}

static bool starts_with_hidden(const fs::path& path) {
  auto name = path.filename().string();
  return !name.empty() && name[0] == '.';
}

static Config load_config(int argc, char** argv) {
  Config cfg;

  const char* repo_env = std::getenv("DOTFILES_ROOT");
  if (repo_env != nullptr && *repo_env != '\0') {
    cfg.repo_root = fs::path(repo_env);
  } else {
    const char* home = std::getenv("HOME");
    cfg.repo_root = fs::path(home != nullptr ? home : ".") / "dotfiles";
  }

  const char* target_env = std::getenv("STOW_TARGET");
  if (target_env != nullptr && *target_env != '\0') {
    cfg.target_root = fs::path(target_env);
  } else {
    const char* home = std::getenv("HOME");
    cfg.target_root = fs::path(home != nullptr ? home : ".");
  }

  for (int i = 1; i < argc; ++i) {
    std::string arg = argv[i];
    auto take_value = [&](fs::path& out) {
      if (i + 1 >= argc) {
        throw std::runtime_error("missing value for " + arg);
      }
      out = fs::path(argv[++i]);
    };

    if (arg == "--repo") {
      take_value(cfg.repo_root);
    } else if (arg == "--target") {
      take_value(cfg.target_root);
    } else if (arg == "--ignore") {
      if (i + 1 >= argc) {
        throw std::runtime_error("missing value for --ignore");
      }
      std::istringstream in(argv[++i]);
      std::string name;
      while (std::getline(in, name, ',')) {
        name = trim(std::move(name));
        if (!name.empty()) {
          cfg.ignored_packages.insert(name);
        }
      }
    } else if (arg == "--help" || arg == "-h") {
      std::cout
          << "Usage: " << argv[0] << " [--repo PATH] [--target PATH] [--ignore a,b,c]\n";
      std::exit(0);
    } else {
      throw std::runtime_error("unknown argument: " + arg);
    }
  }

  cfg.repo_root = fs::weakly_canonical(cfg.repo_root);
  cfg.target_root = fs::weakly_canonical(cfg.target_root);
  return cfg;
}

static std::vector<fs::path> discover_packages(const Config& cfg) {
  std::vector<fs::path> packages;
  for (const auto& entry : fs::directory_iterator(cfg.repo_root)) {
    if (!entry.is_directory()) {
      continue;
    }

    const auto name = entry.path().filename().string();
    if (starts_with_hidden(entry.path())) {
      continue;
    }
    if (cfg.ignored_packages.contains(name)) {
      continue;
    }

    packages.push_back(entry.path());
  }

  std::sort(packages.begin(), packages.end(), [](const fs::path& a, const fs::path& b) {
    return a.filename().string() < b.filename().string();
  });
  return packages;
}

static CommandResult run_command(const std::vector<std::string>& argv) {
  CommandResult result;
  std::string command;
  for (const auto& arg : argv) {
    if (!command.empty()) {
      command += ' ';
    }
    command += shell_quote(arg);
  }
  command += " 2>&1";

  std::array<char, 4096> buffer{};
  FILE* pipe = popen(command.c_str(), "r");
  if (pipe == nullptr) {
    result.exit_code = -1;
    result.output = "popen failed";
    return result;
  }

  while (fgets(buffer.data(), static_cast<int>(buffer.size()), pipe) != nullptr) {
    result.output += buffer.data();
  }

  int status = pclose(pipe);
  if (WIFEXITED(status)) {
    result.exit_code = WEXITSTATUS(status);
  } else {
    result.exit_code = -1;
  }

  return result;
}

static std::string clean_stow_output(const std::string& output) {
  std::ostringstream out;
  for (const auto& line : split_lines(output)) {
    if (line == "WARNING: in simulation mode so not modifying filesystem.") {
      continue;
    }
    if (!trim(line).empty()) {
      out << line << '\n';
    }
  }
  return out.str();
}

static std::vector<std::string> build_stow_command(
    const Config& cfg, Mode mode, bool dry_run, const std::vector<std::string>& packages) {
  std::vector<std::string> argv = {
      "stow",
      "-v",
      "-d",
      cfg.repo_root.string(),
      "-t",
      cfg.target_root.string(),
  };

  if (dry_run) {
    argv.push_back("-n");
  }

  switch (mode) {
    case Mode::Stow:
      break;
    case Mode::Restow:
      argv.push_back("-R");
      break;
    case Mode::Unstow:
      argv.push_back("-D");
      break;
  }

  argv.insert(argv.end(), packages.begin(), packages.end());
  return argv;
}

static std::string mode_name(Mode mode) {
  switch (mode) {
    case Mode::Stow:
      return "stow";
    case Mode::Restow:
      return "restow";
    case Mode::Unstow:
      return "unstow";
  }
  return "stow";
}

static std::string state_name(PackageState state) {
  switch (state) {
    case PackageState::Stowed:
      return "STOWED";
    case PackageState::Pending:
      return "PENDING";
    case PackageState::Error:
      return "ERROR";
  }
  return "UNKNOWN";
}

static int state_color(PackageState state) {
  switch (state) {
    case PackageState::Stowed:
      return 2;
    case PackageState::Pending:
      return 3;
    case PackageState::Error:
      return 4;
  }
  return 1;
}

class App {
 public:
  explicit App(Config cfg) : cfg_(std::move(cfg)) {
    auto package_paths = discover_packages(cfg_);
    packages_.reserve(package_paths.size());
    for (const auto& path : package_paths) {
      Package pkg;
      pkg.name = path.filename().string();
      pkg.source = path;
      packages_.push_back(std::move(pkg));
    }
  }

  int run() {
    if (packages_.empty()) {
      std::cerr << "No stow packages found in " << cfg_.repo_root << '\n';
      return 1;
    }

    if (!prepare_curses()) {
      return 1;
    }

    append_log("[INFO] repo: " + cfg_.repo_root.string());
    append_log("[INFO] target: " + cfg_.target_root.string());
    refresh_statuses();
    draw();

    bool running = true;
    while (running) {
      int ch = getch();
      running = handle_key(ch);
      draw();
    }

    shutdown_curses();
    return exit_code_;
  }

 private:
  bool prepare_curses() {
    if (!initscr()) {
      std::cerr << "Failed to initialize ncurses\n";
      return false;
    }

    cbreak();
    noecho();
    keypad(stdscr, TRUE);
    curs_set(0);
    timeout(-1);

    if (has_colors()) {
      start_color();
      use_default_colors();
      init_pair(1, COLOR_CYAN, -1);
      init_pair(2, COLOR_GREEN, -1);
      init_pair(3, COLOR_YELLOW, -1);
      init_pair(4, COLOR_RED, -1);
      init_pair(5, COLOR_BLACK, COLOR_WHITE);
    }

    return true;
  }

  void shutdown_curses() {
    endwin();
  }

  bool handle_key(int ch) {
    switch (ch) {
      case 'q':
      case 'Q':
        return false;
      case KEY_UP:
      case 'k':
        move_cursor(-1);
        break;
      case KEY_DOWN:
      case 'j':
        move_cursor(1);
        break;
      case ' ':
        toggle_current();
        break;
      case 'a':
        select_all();
        break;
      case 'c':
        clear_selection();
        break;
      case 's':
        mode_ = Mode::Stow;
        clear_preview();
        log_mode_change();
        break;
      case 'r':
        mode_ = Mode::Restow;
        clear_preview();
        log_mode_change();
        break;
      case 'u':
        mode_ = Mode::Unstow;
        clear_preview();
        log_mode_change();
        break;
      case '\n':
      case KEY_ENTER:
      case 'p':
        preview_selected();
        break;
      case 'x':
        apply_preview();
        break;
      case 'R':
        refresh_statuses();
        break;
      case KEY_RESIZE:
        break;
      default:
        break;
    }

    return true;
  }

  std::vector<std::size_t> selected_indices() const {
    std::vector<std::size_t> indices;
    for (std::size_t i = 0; i < packages_.size(); ++i) {
      if (packages_[i].selected) {
        indices.push_back(i);
      }
    }
    if (indices.empty() && !packages_.empty()) {
      indices.push_back(cursor_);
    }
    return indices;
  }

  std::vector<std::string> selected_names() const {
    std::vector<std::string> names;
    for (auto idx : selected_indices()) {
      names.push_back(packages_[idx].name);
    }
    return names;
  }

  void clear_preview() {
    preview_valid_ = false;
    preview_mode_ = mode_;
    preview_names_.clear();
  }

  void move_cursor(int delta) {
    if (packages_.empty()) {
      return;
    }

    int next = static_cast<int>(cursor_) + delta;
    if (next < 0) {
      next = 0;
    }
    if (next >= static_cast<int>(packages_.size())) {
      next = static_cast<int>(packages_.size()) - 1;
    }
    cursor_ = static_cast<std::size_t>(next);
  }

  void toggle_current() {
    if (packages_.empty()) {
      return;
    }
    packages_[cursor_].selected = !packages_[cursor_].selected;
    clear_preview();
  }

  void select_all() {
    for (auto& pkg : packages_) {
      pkg.selected = true;
    }
    clear_preview();
  }

  void clear_selection() {
    for (auto& pkg : packages_) {
      pkg.selected = false;
    }
    clear_preview();
  }

  void log_mode_change() {
    append_log("[MODE] " + mode_name(mode_));
  }

  void append_log(const std::string& line) {
    log_lines_.push_back(line);
    if (log_lines_.size() > max_log_lines_) {
      log_lines_.erase(log_lines_.begin(), log_lines_.begin() + (log_lines_.size() - max_log_lines_));
    }
  }

  void append_output(const std::string& prefix, const std::string& output) {
    auto cleaned = clean_stow_output(output);
    if (cleaned.empty()) {
      append_log(prefix + " (no output)");
      return;
    }

    std::istringstream in(cleaned);
    std::string line;
    while (std::getline(in, line)) {
      append_log(prefix + " " + line);
    }
  }

  void refresh_statuses() {
    append_log("[INFO] refreshing package status");
    for (auto& pkg : packages_) {
      auto result = run_command(build_stow_command(cfg_, Mode::Stow, true, {pkg.name}));
      auto cleaned = clean_stow_output(result.output);
      if (result.exit_code != 0) {
        pkg.state = PackageState::Error;
        pkg.detail = first_line(cleaned.empty() ? result.output : cleaned);
      } else if (trim(cleaned).empty()) {
        pkg.state = PackageState::Stowed;
        pkg.detail.clear();
      } else {
        pkg.state = PackageState::Pending;
        pkg.detail = first_line(cleaned);
      }
    }
    append_log("[INFO] status refresh complete");
  }

  static std::string first_line(const std::string& text) {
    auto lines = split_lines(text);
    if (lines.empty()) {
      return {};
    }
    return trim(lines.front());
  }

  void preview_selected() {
    auto names = selected_names();
    if (names.empty()) {
      append_log("[WARN] no package selected");
      return;
    }

    preview_mode_ = mode_;
    preview_names_ = names;
    auto result = run_command(build_stow_command(cfg_, mode_, true, names));
    preview_valid_ = result.exit_code == 0;

    append_log("[DRY-RUN] " + mode_name(mode_) + " " + join(names, " "));
    append_output("[DRY]", result.output);
    append_log(std::string("[DRY] result: ") + (preview_valid_ ? "ok" : "failed"));

    if (!preview_valid_) {
      exit_code_ = 1;
    }
  }

  void apply_preview() {
    auto names = selected_names();
    if (names.empty()) {
      append_log("[WARN] no package selected");
      return;
    }

    if (!preview_valid_ || preview_mode_ != mode_ || preview_names_ != names) {
      append_log("[WARN] run a fresh preview first");
      return;
    }

    auto result = run_command(build_stow_command(cfg_, mode_, false, names));
    append_log("[APPLY] " + mode_name(mode_) + " " + join(names, " "));
    append_output("[RUN]", result.output);

    if (result.exit_code == 0) {
      append_log("[RUN] done");
      refresh_statuses();
      preview_valid_ = false;
      exit_code_ = 0;
    } else {
      append_log("[RUN] failed");
      exit_code_ = 1;
    }
  }

  std::string truncate_to_width(const std::string& text, int width) const {
    if (width <= 0) {
      return {};
    }
    if (static_cast<int>(text.size()) <= width) {
      return text;
    }
    if (width <= 3) {
      return text.substr(0, width);
    }
    return text.substr(0, width - 3) + "...";
  }

  void draw_header(int width) {
    attron(A_BOLD);
    mvprintw(0, 0, "%s", truncate_to_width(cfg_.repo_root.string(), width).c_str());
    attroff(A_BOLD);

    auto mode_text = "mode: " + mode_name(mode_);
    auto target_text = "target: " + cfg_.target_root.string();
    mvprintw(1, 0, "%s", truncate_to_width(target_text, width).c_str());
    mvprintw(1, std::max(0, width - static_cast<int>(mode_text.size()) - 1), "%s", mode_text.c_str());

    int selected_count = 0;
    for (const auto& pkg : packages_) {
      if (pkg.selected) {
        ++selected_count;
      }
    }

    std::string summary = "packages: " + std::to_string(packages_.size()) +
                          "  selected: " + std::to_string(selected_count) +
                          "  preview: " + (preview_valid_ ? "ready" : "none");
    mvprintw(2, 0, "%s", truncate_to_width(summary, width).c_str());
  }

  void draw_help(int y, int width) {
    const std::string help =
        "j/k: move  space: select  a: all  c: clear  s/r/u: mode  Enter/p: preview  x: apply  R: refresh  q: quit";
    attron(A_DIM);
    mvprintw(y, 0, "%s", truncate_to_width(help, width).c_str());
    attroff(A_DIM);
  }

  void draw_status_tag(int y, int x, const Package& pkg, bool current) {
    int color = state_color(pkg.state);
    if (has_colors()) {
      attron(COLOR_PAIR(color));
    }
    std::string tag = state_name(pkg.state);
    if (current) {
      tag = ">" + tag;
    }
    mvprintw(y, x, "[%s]", tag.c_str());
    if (has_colors()) {
      attroff(COLOR_PAIR(color));
    }
  }

  void draw_package_line(int y, int width, const Package& pkg, bool current) {
    std::string left = pkg.selected ? "[x]" : "[ ]";
    std::string text = left + " " + pkg.name;
    if (!pkg.detail.empty()) {
      text += " - " + pkg.detail;
    }

    if (current) {
      if (has_colors()) {
        attron(COLOR_PAIR(5));
      } else {
        attron(A_REVERSE);
      }
    }

    mvprintw(y, 1, "%s", truncate_to_width(text, width - 14).c_str());
    draw_status_tag(y, std::max(1, width - 13), pkg, current);

    if (current) {
      if (has_colors()) {
        attroff(COLOR_PAIR(5));
      } else {
        attroff(A_REVERSE);
      }
    }
  }

  void draw_packages(int start_y, int x, int width, int height) {
    mvhline(start_y, x, ACS_HLINE, width);
    mvprintw(start_y, x + 2, " Packages ");
    int visible = std::max(0, height - 2);

    if (cursor_ < static_cast<std::size_t>(scroll_offset_)) {
      scroll_offset_ = static_cast<int>(cursor_);
    }
    if (cursor_ >= static_cast<std::size_t>(scroll_offset_ + visible)) {
      scroll_offset_ = static_cast<int>(cursor_) - visible + 1;
    }

    for (int row = 0; row < visible; ++row) {
      int idx = scroll_offset_ + row;
      int y = start_y + 1 + row;
      mvhline(y, x, ' ', width);
      if (idx >= static_cast<int>(packages_.size())) {
        continue;
      }
      draw_package_line(y, width, packages_[static_cast<std::size_t>(idx)], idx == static_cast<int>(cursor_));
    }
  }

  void draw_logs(int start_y, int x, int width, int height) {
    mvhline(start_y, x, ACS_HLINE, width);
    mvprintw(start_y, x + 2, " Log ");
    int visible = std::max(0, height - 2);
    int begin = static_cast<int>(log_lines_.size()) - visible;
    if (begin < 0) {
      begin = 0;
    }
    for (int row = 0; row < visible; ++row) {
      int y = start_y + 1 + row;
      mvhline(y, x, ' ', width);
      int idx = begin + row;
      if (idx >= static_cast<int>(log_lines_.size())) {
        continue;
      }
      mvprintw(y, x + 1, "%s", truncate_to_width(log_lines_[static_cast<std::size_t>(idx)], width - 2).c_str());
    }
  }

  void draw() {
    erase();
    int rows = 0;
    int cols = 0;
    getmaxyx(stdscr, rows, cols);

    if (rows < 10 || cols < 60) {
      mvprintw(0, 0, "Terminal too small");
      mvprintw(1, 0, "Need at least 60x10");
      refresh();
      return;
    }

    draw_header(cols);

    bool stacked = cols < 110;
    if (stacked) {
      int package_y = 4;
      int package_h = std::max(4, rows - 10);
      draw_packages(package_y, 0, cols, package_h);
      int log_y = package_y + package_h + 1;
      int log_h = std::max(3, rows - log_y - 2);
      draw_logs(log_y, 0, cols, log_h);
      draw_help(rows - 1, cols);
    } else {
      int left_w = cols * 2 / 3;
      int right_w = cols - left_w;
      int body_y = 4;
      int body_h = rows - body_y - 2;
      draw_packages(body_y, 0, left_w - 1, body_h);
      draw_logs(body_y, left_w, right_w, body_h);
      draw_help(rows - 1, cols);
    }

    refresh();
  }

  Config cfg_;
  std::vector<Package> packages_;
  std::vector<std::string> log_lines_;
  std::size_t cursor_ = 0;
  int scroll_offset_ = 0;
  Mode mode_ = Mode::Stow;
  bool preview_valid_ = false;
  Mode preview_mode_ = Mode::Stow;
  std::vector<std::string> preview_names_;
  int exit_code_ = 0;
  static constexpr std::size_t max_log_lines_ = 240;
};

int main(int argc, char** argv) {
  try {
    setlocale(LC_ALL, "");
    auto cfg = load_config(argc, argv);
    App app(std::move(cfg));
    return app.run();
  } catch (const std::exception& e) {
    std::cerr << "stowctl: " << e.what() << '\n';
    return 1;
  }
}
