# Agent Guide

- For reviewing new or changed code, use the [reviewer skill](.claude/skills/reviewer/SKILL.md). It covers correctness, maintainability, design, performance, and reporting findings.
- For documenting the platform or changing code, APIs, architecture, configuration, or operations in ways that affect documentation, use the [documentation skill](.claude/skills/documentation/SKILL.md).
- For Git status, diffs, branches, commits, merges, or other repository operations, use the [Git skill](.claude/skills/git/SKILL.md). It defines the `main` trunk workflow and commit message format.

## Workflow: checks

When asked to run checks:

1. Run the reviewer skill against the current changes, including its narrow relevant tests or checks when available.
2. Run the documentation skill to update docs affected by the changes. If no docs are affected, report that rather than making unrelated edits.
3. Report review findings, checks run, documentation updates, and any validation gaps.

- When adding a project skill, link it here with a short description of when to use it.
