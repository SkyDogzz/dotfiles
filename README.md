# TODO: Swap to i3

# My Dotfiles

Welcome to my personal dotfiles repository! This collection contains my configurations for various tools and environments on an Arch Linux setup. While this is tailored for my own use, feel free to explore, clone, and adapt these dotfiles to suit your own setup.

## 🛠️ Tools and Configurations Included

This repository includes configurations for the following:
- **Arch Linux**: General setup and environment configurations.
- **Discord (BetterDiscord)**: Custom themes and plugins for Discord.
- **Clipboard Manager (Clipman)**: Settings for managing clipboard history.
- **File Manager (Dolphin)**: Configuration for the Dolphin file manager.
- **Fish Shell**: Custom configurations and plugins for the Fish shell.
- **Starship**: Prompt configuration for use with various shells.
- **Hyprland**: Configurations for the Hyprland window manager.
- **Kitty**: Custom configurations for the Kitty terminal emulator.
- **Neovim**: Configurations using lazy.nvim for plugin management.
- **Waybar**: Configuration for the Waybar status bar.

# 🚀 Installation

To get started with these dotfiles on your own machine, follow the steps below:

1. Clone the repository
```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
```
2. Create Symlinks
You can create symbolic links from this repository to your home directory. Here’s a general example for symlinking:
```bash
ln -s ~/dotfiles/fish ~/.config/fish
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/kitty ~/.config/kitty
ln -s ~/dotfiles/starship.toml ~/.config/starship.toml
ln -s ~/dotfiles/waybar ~/.config/waybar
```
Repeat this for all the configurations you wish to use.

3. Install Dependencies:
Ensure that you have installed the necessary software for each configuration (e.g., Fish, Neovim, Kitty, Hyprland). Installation instructions for each tool can be found in their respective documentation.

## ⚙️ Configuration Details
- **BetterDiscord**: Custom themes and plugin management for a better Discord experience.
- **Clipman**: Efficient clipboard management with keybindings and history.
- **Dolphin**: Customizations for a streamlined file management experience.
- **Fish Shell**: Enhanced terminal experience with custom prompts and completions.
- **Starship**: A blazing-fast and customizable prompt for any shell.
- **Hyprland**: Window management tailored for efficiency and aesthetics.
- **Kitty**: Terminal emulator settings with a focus on performance and appearance.
- **Neovim**: Powerful text editing with lazy.nvim for optimal plugin management.
- **Waybar**: Status bar configuration that integrates seamlessly with Hyprland.

## 🛠️ Customization
This setup is tailored for an Arch Linux environment, but it can be adapted for other distributions with some adjustments. In the future, I’ll provide more details on how to customize each configuration file to better suit your needs.

## 🤝 Contributions
While this is primarily for personal use, I’m open to suggestions and improvements. Feel free to fork this repository, make your changes, and submit a pull request if you think something could be improved or added.

## 📜 License
This repository is licensed under the MIT License, so you can use it freely. See the [LICENSE](./LICENSE) file for more details.
