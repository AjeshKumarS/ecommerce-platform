---
name: reviewer
description: "Review new or changed code before merge. Find verified correctness, maintainability, design, security, and performance issues, then produce a severity-ranked review report with file and line references."
---

# Code Reviewer

## When to Use

- Review a pull request, diff, or newly written code.
- Check whether an implementation follows sound engineering practices before merge.
- Investigate likely design, SOLID, pattern, or performance problems in changed code.

## Review Procedure

1. Identify the requested scope and inspect the diff first. Read nearby callers, tests, and ownership boundaries only as needed to understand behavior.
2. Trace changed control and data flows. Check correctness, edge cases, failure handling, security boundaries, concurrency, resource usage, and compatibility with existing contracts.
3. Assess maintainability and design in context. Consider separation of responsibilities and SOLID principles where they clarify a concrete risk. Recommend a design pattern only when it solves an observed problem; do not require patterns for their own sake.
4. Look for evidence-based performance risks, including unbounded work or memory, avoidable repeated computation or I/O, N+1 access, inefficient algorithms, contention, and blocking calls on critical paths. Describe the triggering workload and likely impact; do not speculate about optimization without evidence.
5. Check whether tests cover important changed behavior and run the narrowest relevant checks when practical. Distinguish verified defects from missing coverage and note checks that could not be run.
6. Validate each candidate finding against the code and its context. Exclude style preferences, hypothetical risks without a concrete path, and issues unrelated to the requested scope.

## Report Format

Lead with findings, ordered by severity. For each finding include:

- Severity: Critical, High, Medium, or Low
- File and line reference
- The concrete scenario that causes the issue and its impact
- A concise, actionable direction for addressing it

If there are no findings, state that clearly. Then list relevant checks run and any remaining test gaps or residual risks. Keep the report concise and do not modify code unless the user separately asks for fixes.
