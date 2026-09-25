---
name: git
description: "Handle Git repository tasks including status, diffs, branches, staging, commits, merges, conflicts, history, and remotes. Follow trunk-based development with main as trunk and the required operation-first commit message format."
---

# Git Workflow

## When to Use

- Perform or explain any Git operation, including inspecting changes, managing branches, staging or committing, syncing with remotes, resolving conflicts, or reviewing history.

## Repository Workflow

1. Confirm the current repository and branch. If the working directory has no Git metadata, explain that Git is not initialized and do not initialize it unless explicitly asked.
2. Before changing Git state, inspect `git status --short --branch` and relevant staged and unstaged diffs. Preserve existing user changes and avoid staging unrelated files.
3. Treat `main` as the single long-lived trunk. Keep work small, use short-lived topic branches from `main` when branches are needed, and integrate frequently through the repository's configured review process. Do not introduce long-lived development or release branches.
4. Stage only the files in scope, inspect the staged diff, and run relevant checks before committing when practical.
5. Perform commits, pushes, merges, branch deletion, or other state-changing operations only when requested. Never discard user changes or rewrite published history without explicit instruction. Do not run destructive commands such as `git reset --hard`, `git checkout --`, or `git clean -fd` unless explicitly requested.
6. For conflicts, inspect both sides and preserve intent. Do not choose a side or resolve by dropping changes without enough context.

## Commit Messages

- Make every commit atomic: it should implement one cohesive change and leave the repository in a coherent state.
- If requested work contains independent concerns, split it into separate, reviewable commits in dependency order. Keep tightly coupled changes together only when they form one logical change.
- Stage and inspect each commit's files and diff separately, and run the relevant checks for that change when practical.
- Use exactly one line: `<Operation> <intent>`.
- Start with a capitalized operation verb that describes the change, such as `Add`, `Delete`, `Update`, `Modify`, or `Refactor`.
- Keep the message in simple present, concise, and specific. Do not use past tense, conventional-commit prefixes, or a trailing period.
- Examples: `Add product search endpoint`; `Update order validation`; `Refactor inventory reservation flow`.
