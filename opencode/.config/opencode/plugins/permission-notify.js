import { execFile } from "node:child_process";

export default async () => {
  return {
    "permission.ask": async (input, output) => {
      const { title, type, pattern } = input;
      const body = pattern
        ? `${type}: ${title}\nPattern: ${Array.isArray(pattern) ? pattern.join(", ") : pattern}`
        : `${type}: ${title}`;

      execFile("notify-send", [
        "-u", "critical",
        "-a", "opencode",
        "🔐 Permission Required",
        body,
      ], () => {});
    },
  };
};
