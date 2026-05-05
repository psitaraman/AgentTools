# Phase 4: Checklist Generation

**Participants:** Model A subagent (fresh context)
**Context:** Subagent with fresh context. All specs and BDD scenarios provided as files.
**Input:** All product specs + all tech specs + all BDD scenarios (including cross-feature items)
**Output:** Three evaluation checklists per feature, used in Phases 7, 8, 9

## What This Phase Produces

Flat evaluation checklists extracted from upstream artifacts. These are derived artifacts — not new sources of truth. One assertion per line, evaluable as pass/fail. Reviewers walk these item by item before rendering their verdict.

Generated after Phase 3 (BDD signed off by human) and before Phase 5 (TDD test generation). No code exists yet.

## Why Fresh Context

Model A needs the full context from product specs, tech specs, and all BDD scenarios across features to extract comprehensive checklists, including cross-feature items. Fresh context ensures clean extraction without accumulated bias from co-creation sessions.

## Three Checklist Types

### Product Spec Checklist
- Extracted from product specs.
- Each feature, user experience, and dependency stated in the spec becomes one line.
- Validates completeness — was every feature addressed?
- Used in Phase 7 (does the feature match what was promised?), Phase 8 (do all features together deliver the product?), and Phase 9 (does the integrated whole match the original spec?).

### Technical Spec Checklist
- Extracted from tech specs.
- Each architectural requirement, convention, framework constraint, and component relationship becomes one line.
- Validates that implementation follows the technical decisions.
- Used in Phases 7, 8, and 9.

### BDD Checklist
- Extracted from BDD scenario files.
- Each behavioral assertion and edge case becomes one line.
- Validated for completeness against product spec (does every product feature have at least one BDD assertion?) and tech spec (do scenarios respect platform constraints and architecture boundaries?).
- Forces the reviewer to verify every assertion was implemented, not just the happy path.
- Used in Phase 7 (branch review — feature-level) and Phase 9 (final audit — against the integrated system). Not walked in Phase 8: BDD is per-feature and already verified at Phase 7; Phase 8 focuses on integration-level product and tech-spec alignment.

### What Doesn't Need a Checklist

TDD does not need a checklist. TDD validation is: do the tests pass. Code either makes them green or it doesn't.

## Checklist Format

```
# Product Spec Checklist: [feature name]

- [ ] Feature overview: [one-line assertion from spec]
- [ ] User story: [user story, evaluable as implemented/not]
- [ ] Dependency: [dependency satisfied yes/no]
- [ ] Constraint: [constraint met yes/no]
...
```

Each line is a standalone pass/fail assertion. No narrative, no context — just the checkable fact.

## Cross-Feature Items

Some assertions span features:
- Shared infrastructure used by multiple features
- Dependencies between features
- Integration boundaries

These appear in the checklists of all features they affect, tagged with which features they span.

## Version Pinning

Checklists have their own `built-from` tracking:

```yaml
---
version: 1.0
built-from:
  - features/login/product-spec: v1.0
  - features/login/tech-spec: v1.0
  - features/login/bdd/scenarios: v1.0
status: current
checklist-type: product-spec | tech-spec | bdd
---
```

If any upstream spec version changes between phases, affected checklists are flagged stale and regenerated before the next phase that uses them. Same staleness rules as all other pipeline documents.

## How Checklists Are Used

Each checklist looks at its own artifact plus upstream dependencies following the `built-from` chain:
- Product spec checklist ← product spec
- Technical spec checklist ← technical spec
- BDD checklist ← BDD scenarios + product spec + technical spec

The review agent walks all applicable checklists item by item before rendering its verdict. Checklist results feed into observability metrics (see `references/observability-metrics.md`).

## Done Signal

- Product spec checklist generated for each feature
- Technical spec checklist generated for each feature
- BDD checklist generated for each feature with completeness validation
- Cross-feature items identified and tagged
- All checklists have version frontmatter with `built-from`

## If Blocked

- Spec is ambiguous — cannot extract a pass/fail assertion → flag to human, reference specific spec section
- BDD scenario has no corresponding product spec feature → flag gap to human
- Cross-feature dependency unclear → flag to human, list affected features
