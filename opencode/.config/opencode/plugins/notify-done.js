import { execFile } from "node:child_process";

let debounceTimer = null;

export default async () => {
  const scheduleNotify = () => {
    if (debounceTimer) clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      execFile("notify-send", [
        "-a", "opencode",
        "✅ opencode - Terminé",
        "Réponse prête",
      ], () => {});
      debounceTimer = null;
    }, 1000);
  };

  return {
    "experimental.text.complete": async () => {
      scheduleNotify();
    },
  };
};
