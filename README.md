# E-Commerce Platform

A learning project for building a production-style, DDD-based e-commerce platform as a monorepo of independently deployable services.

## Project Plan

The complete goals, architecture, technology choices, and development phases are in [plans/project_plan.md](plans/project_plan.md).

Detailed implementation plans and task tracking belong in numbered phase folders under `plans/`, using `plans/phase-XX-short-name/plan.md` and `plans/phase-XX-short-name/tasks.md`.

This repository is currently at the documentation and architecture-scaffolding stage. Application modules and build configuration will be added as their phases begin.

## Repository Layout

- `docs/architecture/` - domain and system architecture notes
- `docs/adr/` - architecture decision records
- `docs/api/` - API and event contract documentation
- `docs/diagrams/` - architecture diagrams

## Getting Started

Run `make help` to see the available repository helpers. The Java/Maven project build will be configured when the first service modules are introduced.
