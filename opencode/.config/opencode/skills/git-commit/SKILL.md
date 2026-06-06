---
name: git-commit
description: >
  Triggered when the user says "commit", "make a commit", "propose a commit"
  or similar. Auto-suggests a commit message based on staged/unstaged changes
  and the repo's existing commit style. Requires confirmation before executing.
---

When the user asks you to make a commit or suggests a commit:

1. **Inspect changes**: run `git status --short` and `git diff` (or `git diff --cached` if there are staged changes).

2. **Check commit style**: run `git log --oneline -10` to understand the existing commit convention.

3. **Propose a message**: format it to match the repo style (imperative present tense, English, capitalize first word, no trailing period, e.g. "Add foo feature" or "Fix bar bug").

4. **Ask for confirmation**: present the `git add` and `git commit` command you intend to run and ask the user if they agree.

5. **Execute**: if confirmed, run `git add <files>` and `git commit -m "<message>"`. If the user is unsure, offer alternatives.
