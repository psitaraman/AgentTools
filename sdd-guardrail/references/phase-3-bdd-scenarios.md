# Phase 3: BDD Scenarios

**Participants:** Model A subagent (fresh context) + Human sign-off
**Context:** Subagent with fresh context. Inputs provided as files.
**Input:** Feature's product spec + feature's tech spec
**Output:** `bdd/*.md` per feature (one or more scenario files in the feature's `bdd/` directory; `scenarios.md` is the typical default for features with a single file)

## What This Phase Produces

Exhaustive behavioral contracts for each feature. Plain text, not Gherkin (ADR-003). Each scenario describes starting state, action, expected result, and edge cases. The AI is the parser.

BDD is separate from the product spec because product specs describe intent and value (narrative), while BDD enumerates every scenario including edge cases, error states, and boundary conditions. Each document does one job.

This is the last human checkpoint before AI-driven phases take over.

## Why Fresh Context

A fresh-context agent reading the specs for the first time catches gaps the co-creation sessions missed — scenarios not considered, edge cases overlooked, conflicting requirements between features. This is a verification and expansion step.

## Inputs

The BDD agent receives:
- **Feature's product spec** — primary input. Describes what the feature does and why.
- **Feature's tech spec** — secondary input. Needed for platform-specific behaviors and to understand what's technically possible.
- **Any dependencies** referenced in the feature's specs.

BDD mostly derives from the product spec (user behavior). The tech spec informs platform-specific scenarios where behavior genuinely differs.

## Scenario Format

Plain text per feature. Not Gherkin — no Given/When/Then syntax.

```
Scenario: [descriptive name]
  Starting state: [what exists before the action]
  Action: [what the user or system does]
  Expected result: [what should happen]
  Edge cases:
    - [variation and its expected result]
    - [variation and its expected result]
```

## Platform Scope

Core scenarios are mostly platform-independent — they describe user behavior regardless of platform. Platform-specific scenarios are added where behavior genuinely differs.

Mark platform-specific scenarios:

```
Scenario: [name] [platform: iOS]
  Starting state: ...
```

## Scenario Coverage

For each feature, ensure scenarios cover:
- Happy path (main success case)
- Input validation (empty, invalid, boundary values)
- Error states (network failure, server error, timeout)
- Edge cases (concurrent access, expired sessions, partial data)
- State transitions (logged in → logged out, empty → populated)
- Permissions and authorization (unauthorized access, expired tokens)
- Destructive actions (delete, overwrite — confirmation and undo)

## Pairing with RFC 2119 Keywords (ADR-022)

When a feature's tech spec is in-scope for RFC 2119 keyword discipline (wire formats, state machines, cross-module API contracts, tool/interface schemas, or protocol error handling), every MUST and SHOULD in the tech spec requires at least one corresponding behavioral scenario in this feature's BDD.

The scenario format above (Starting state → Action → Expected result) carries Given/When/Then semantics in plain text. A MUST in the tech spec pairs with a scenario whose Expected result asserts the required behavior; a SHOULD pairs with a scenario that demonstrates the recommended behavior and, where appropriate, an edge case showing the fallback when the recommendation is not met.

RFC 2119 defines conformance; BDD defines verification. Both are required — neither substitutes for the other.

## BDD File Structure

```yaml
---
version: 1.0
built-from:
  - features/login/product-spec: v1.0
  - features/login/tech-spec: v1.0
status: current
---
```

One or more `*.md` scenario files per feature, in the feature's `bdd/` directory. `scenarios.md` is the typical default; features with many scenarios may split into multiple files (e.g. `happy-path.md`, `error-states.md`).

## Done Signal

- Every feature has at least one BDD scenario file (one or more `*.md` files in the feature's `bdd/` directory)
- Each file covers happy path, error states, and edge cases
- Platform-specific scenarios marked where applicable
- Human has reviewed and signed off
- All files have version frontmatter

## If Blocked

- Ambiguous acceptance criteria in product spec → flag to human, ask to clarify
- Conflicting behavior between features → flag to human with AI recommendations
- Cannot determine edge cases without domain knowledge → flag to human, list what's known
