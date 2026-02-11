---
name: code-review
description: Perform a comprehensive code review focusing on correctness, performance, readability, security, and maintainability. Analyzes code changes and returns structured feedback with prioritized issues and actionable suggestions.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: pull-request
---

## What I Do

- Analyze code changes systematically against a structured quality checklist
- Identify bugs, security vulnerabilities, performance bottlenecks, and maintainability concerns
- Return a prioritized, line-referenced review with actionable suggestions
- Flag dependency risks and known vulnerability patterns

## When to Use Me

Use this when reviewing code changes, pull requests, diffs, or when auditing existing code for quality issues. Also appropriate when refactoring and you want a second pass for regressions.

Ask clarifying questions if:
- Only a partial diff or snippet is provided without sufficient surrounding context
- The language, framework, or project conventions are unclear
- The intent of the change is ambiguous

## Review Checklist

### 1. Correctness

- Does the code implement the intended functionality?
- Are edge cases handled (null/undefined, empty inputs, boundary values, type mismatches)?
- Are there potential bugs, off-by-one errors, race conditions, or infinite loops?
- Do error handling paths behave correctly and avoid swallowing exceptions silently?
- Are return types and function contracts consistent?

### 2. Performance

- Are there inefficient algorithms (e.g., unnecessary nested loops, redundant computations, N+1 queries)?
- Is memory usage reasonable (large allocations, unbounded caches, memory leaks)?
- Are there blocking operations that should be async?
- Could any hot paths benefit from caching, batching, or lazy evaluation?

### 3. Readability and Maintainability

- Are variable, function, and class names descriptive and consistent with project conventions?
- Is the code well-commented where intent is non-obvious (avoid restating what the code does)?
- Is there consistent formatting and style?
- Is complexity manageable (functions under ~40 lines, limited nesting depth)?
- Are magic numbers and hardcoded strings extracted into named constants?

### 4. Security

- Are there injection risks (SQL, XSS, command injection, path traversal)?
- Are secrets, credentials, or API keys exposed in code or logs?
- Are all external inputs validated and sanitized before use?
- Are authentication and authorization checks present where required?
- Are dependencies up to date and free of known CVEs?
- Is sensitive data handled appropriately (encrypted at rest/in transit, not logged)?

### 5. Testing and Reliability

- Are there tests covering new or changed logic?
- Do tests cover both happy paths and failure/edge cases?
- Are mocks and stubs used appropriately without over-mocking?
- Are flaky test patterns avoided (timing dependencies, shared state)?

### 6. Best Practices

- Follows the project's established coding standards and conventions
- Uses appropriate design patterns without over-engineering
- Avoids code duplication (DRY) while maintaining clarity
- API changes are backward-compatible or migration paths are documented
- Commit messages and PR descriptions are clear

## Output Format

When performing a review, structure the response as follows:

### Summary

A brief overview of the changes and overall assessment (2-4 sentences).

### Issues Found

For each issue provide:
- Priority: High, Medium, or Low
- File and line number(s)
- Category: Correctness, Performance, Security, Readability, Testing, or Best Practices
- Description of the problem
- Specific suggestion or fix with a code example if helpful

### What Looks Good

Briefly note what the code does well. Reinforcing good patterns is valuable.

### Recommendations

Any broader suggestions such as architectural concerns, refactoring opportunities, missing documentation, or follow-up tasks.

## Priority Definitions

- **High**: Bugs, security vulnerabilities, data loss risks, or breaking changes that must be fixed before merge.
- **Medium**: Performance issues, maintainability concerns, or missing tests that should be addressed soon.
- **Low**: Style nitpicks, minor improvements, or optional enhancements that can be addressed later.

## Guidance for Ambiguous Situations

- If reviewing a partial snippet without full context, state assumptions clearly and note where the review may be incomplete
- If the programming language or framework is not specified, infer from syntax and conventions but confirm with the user
- If a pattern looks intentional but suboptimal, frame feedback as a question rather than a directive (e.g., "Was this approach chosen for a specific reason? An alternative might be...")
- When trade-offs exist (e.g., readability vs performance), present both sides and let the author decide
- Default to the principle of least surprise — flag anything a future maintainer might find confusing