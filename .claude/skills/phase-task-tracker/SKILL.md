---
name: phase-task-tracker
description: "Track implementation progress in per-phase tasks.md files. Use during the checks workflow or when asked to update phase task statuses; determine status from code, tests, documentation, and other repository evidence."
---

# Phase Task Tracker

## When to Use

- Update task status after implementation work or verification.
- Synchronize affected phase task files as part of the `checks` workflow.
- Create the task list for a phase that has a detailed plan but no `tasks.md` yet.

## Procedure

1. Read `plans/project_plan.md`, relevant phase `plan.md` files, and existing `tasks.md` files. Inspect current repository changes, implementation, tests, and documentation relevant to those tasks.
2. Determine which phase tasks the changes affect. For a whole-project status request, review every existing phase task file. Do not assume a task is complete merely because a related file exists or the task is described as complete in a plan.
3. Update only task status and concise evidence/notes needed to reflect verified progress. Preserve task IDs, scope, dependencies, and user-authored notes. If the work suggests a task's scope should change, report that rather than silently rewriting the plan.
4. Use these statuses consistently:
   - `Not Started`: no implementation work is evidenced.
   - `In Progress`: work exists but the task's acceptance criteria are not all met.
   - `Blocked`: a concrete missing dependency or issue prevents progress; state it.
   - `Needs Review`: implementation appears complete but required review or verification remains.
   - `Done`: acceptance criteria are met and relevant checks or other appropriate evidence confirm completion; record the evidence.
5. If a phase has a `plan.md` but lacks `tasks.md`, derive a concise, ordered task table from its explicit work slices and acceptance criteria. Use this format:

   ```markdown
   # Phase NN Tasks

   | ID    | Task                | Status      | Evidence / Notes |
   | ----- | ------------------- | ----------- | ---------------- |
   | NN-01 | Example deliverable | Not Started |                  |
   ```

   Do not invent a phase plan or task list when no phase plan exists. Report the missing plan and refer to the project-planning skill when planning is needed.

6. Validate that each status matches its evidence, dependencies are respected, and task IDs are unique within the phase. Do not modify application code as part of task tracking.

## Completion Report

List the phase task files updated or created, status changes with brief evidence, tasks blocked or awaiting review, and any phase that could not be mapped to an existing plan.
