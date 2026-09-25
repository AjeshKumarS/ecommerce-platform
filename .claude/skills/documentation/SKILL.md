---
name: documentation
description: "Create or update documentation only for content and behavior currently present in the repository. Use for platform documentation and when existing code, contracts, configuration, or operations change."
---

# Platform Documentation

## When to Use

- Create or improve documentation covering the platform or one of its components.
- Update documentation when implementation changes affect behavior, architecture, APIs, events, data ownership, configuration, security, deployment, or operations.
- Document current architecture, workflows, or operational procedures.

## Procedure

1. Establish the scope. For platform-wide work, inventory the repository and identify implemented components, boundaries, communication paths, data stores, and operational tooling. For a code change, inspect the diff and the affected code, tests, configuration, and existing docs.
2. Document only files, implemented behavior, verified configuration, and decisions that currently exist in the repository. Do not create documentation for planned or future components, and do not infer implemented behavior from the project plan. Cover roadmap material only when the user explicitly requests it.
3. Identify the documentation affected by the scope. Prefer updating the existing document over creating duplicates. Use `README.md` for project orientation, `docs/architecture/` for system structure and workflows, `docs/api/` for REST/gRPC/event contracts, `docs/adr/` for decisions, and `docs/diagrams/` for diagrams.
4. Write for a developer who needs to understand, run, change, or operate the system. Explain ownership and interactions, important constraints, failure behavior, and trade-offs where relevant. Include commands only after verifying them against project configuration or successful execution.
5. Keep documentation consistent with code and with other docs. Link related material, use the repository's existing terms, and avoid copying large sections between documents.
6. Validate the result: check links and paths, verify names and examples against source, and run documented commands when practical. State unknowns or unavailable validation explicitly instead of guessing.

## Completion Report

Summarize which docs were created or updated, what system areas they cover, and any gaps that remain because implementation or verification was unavailable.
