# Agent Guide

- For reviewing new or changed code, use the [reviewer skill](.claude/skills/reviewer/SKILL.md). It covers correctness, maintainability, design, performance, and reporting findings.
- For documenting the platform or changing code, APIs, architecture, configuration, or operations in ways that affect documentation, use the [documentation skill](.claude/skills/documentation/SKILL.md).
- For creating or updating detailed phase implementation plans from `plans/project_plan.md`, use the [project-planning skill](.claude/skills/project-planning/SKILL.md). It checks repository evidence and cross-phase dependencies before planning.
- For tracking phase task progress or synchronizing task statuses with implementation evidence, use the [phase-task-tracker skill](.claude/skills/phase-task-tracker/SKILL.md).
- For Git status, diffs, branches, commits, merges, or other repository operations, use the [Git skill](.claude/skills/git/SKILL.md). It defines the `main` trunk workflow and commit message format.

## Workflow: checks

When asked to run checks, complete the pre-check before the post-check.

### Pre-check

1. Discover and run all applicable project tests, builds, lint, and type checks. Prefer the full test suite when available; report commands and results, including checks that could not run.
2. Run the reviewer skill against the current changes, including any additional focused checks it needs.

### Post-check

1. Run the documentation skill to update docs affected by the changes. If none are affected, report that instead of making unrelated edits.
2. If a phase plan is created or changed, run the project-planning skill so its `tasks.md` is created or reconciled with the plan while preserving progress for unchanged tasks.
3. Run the phase-task-tracker skill to update affected task statuses using implementation and pre-check evidence. If no task plan applies, report that rather than inventing tasks.
4. Report review findings, checks run, documentation and plan/task updates, and any validation gaps.

- When adding a project skill, link it here with a short description of when to use it.
