---
name: project-planning
description: "Create detailed, readable implementation plans for one or all project phases. Read plans/project_plan.md, inspect completed work and existing plans, account for dependencies and future phases, and include useful Mermaid diagrams without conflicting with the implementation."
---

# Project Phase Planning

## When to Use

- Turn a phase in `plans/project_plan.md` into an actionable implementation plan.
- Create detailed plans for all phases while accounting for completed, active, and future work.
- Review or update existing phase plans after implementation or roadmap changes.

## Procedure

1. Read `plans/project_plan.md` and identify the requested phase or phases, goals, constraints, dependencies, and stated phase order.
2. Inspect the current repository, relevant source, tests, configuration, documentation, and existing phase plans. Use implementation evidence to determine what is done; do not treat a plan item as completed just because it appears in the overall plan. Classify each relevant phase as `Complete`, `In Progress`, `Not Started`, or `Needs Verification`, with concise evidence.
3. For each requested phase, review its predecessor and successor phases and any existing detailed plans. Carry forward prerequisites, respect established interfaces and decisions, avoid duplicating completed work, and state what the phase must provide to later phases. Do not introduce scope or decisions that conflict with verified code or another phase.
4. Create or update one folder per phase using this convention:

   ```text
   plans/
   ├── project_plan.md
   ├── phase-00-short-name/
   │   ├── plan.md
   │   ├── tasks.md
   │   └── diagrams/       # Optional, for diagrams kept separate from plan.md
   └── phase-01-short-name/
       ├── plan.md
       └── tasks.md
   ```

   Use the zero-padded phase number and a short, stable kebab-case name derived from the project plan. Keep each phase's detailed plan, task list, and any supporting diagrams in that phase's folder. Do not create empty folders for phases that have no plan yet.

5. Write each `plan.md` for a human implementer. Include:
   - Phase objective, status, and evidence of current state
   - Scope, explicit non-goals, prerequisites, and dependencies
   - Ordered work slices with deliverables and acceptance criteria
   - Relevant component boundaries, interfaces, data ownership, and decisions
   - Tests and validation for each meaningful slice
   - Risks, failure cases, security and performance considerations where relevant
   - Compatibility requirements for predecessor work and consumers in later phases
   - Completion criteria and open questions
6. Keep a `tasks.md` alongside every phase `plan.md`. For a new phase plan, create an ordered task table with stable IDs, dependencies where needed, and initial status `Not Started`. When updating a plan, reconcile its task file with the changed scope and acceptance criteria: preserve IDs, evidence, and statuses for unchanged work; add new tasks as `Not Started`; and explain tasks that become obsolete. Never reset completed task status merely because the plan changed.
7. Use Mermaid diagrams where they clarify architecture, sequence, state transitions, data flow, or dependencies. Prefer readable `flowchart` or `sequenceDiagram` blocks in `plan.md`; put a diagram in the phase's `diagrams/` folder only when it benefits from a separate source file. Explain what the diagram represents and keep it consistent with the written steps.
8. Keep plans specific to this project and phase. Distinguish verified current state from proposed implementation. Avoid vague tasks, repeated boilerplate, speculative detail, and large architecture changes without a clear dependency or rationale.
9. Validate links, phase numbers and names, Mermaid syntax at a visual level, acceptance criteria, task coverage, and cross-phase dependencies. Do not modify application code while planning unless the user separately asks for implementation.

## Completion Report

Report which phase plans were created or updated, the evidence-based status of relevant phases, key dependencies or conflicts handled, and any unresolved questions or validation limits.
