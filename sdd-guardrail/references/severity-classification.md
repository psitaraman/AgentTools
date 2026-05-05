# Severity Classification

Shared reference for how review findings are classified across the pipeline. Used in Phase 7 (Branch Review), Phase 8 (Trunk Audit), and Phase 9 (Final Audit).

## Severity Levels

Every review finding is tagged with a severity level:

**P0 — Blocks merge.**
- Violates BDD behavioral contract
- Violates product spec requirement
- Violates technical spec architectural requirement
- Causes previously passing tests to fail

**P1 — Blocks merge.**
- Security vulnerability
- PII or data privacy violation
- Performance regression
- Missing error handling for failure paths defined in BDD scenarios
- Undocumented security or correctness risk (see Spec Feedback below)

**P2 — Logged, does not block merge.**
- Style, naming, convention preferences
- Minor readability suggestions
- Refactoring ideas that don't affect behavior

## Scope Tags

Every review finding is also tagged with scope. **Scope tagging only applies to Phase 7 (Branch Review).** Phases 8 and 9 use severity only.

**In-scope.** Finding relates to the current feature's spec and BDD contract.

**Out-of-scope.** Finding relates to other features, future work, or general codebase improvements. Out-of-scope findings are logged for future work regardless of severity — they are never addressed in the current branch.

## Configurable Merge Threshold

A configurable threshold determines which severity levels block merge:

- **Default:** P0 and P1 block. P2 logs only.
- **Strict:** P0, P1, and P2 all block.
- **Relaxed:** Only P0 blocks.

The threshold is set per project and adjustable after observing real review behavior. If too many P2 findings are blocking velocity without catching real issues, relax. If P2 findings are catching real problems, tighten.

## Implementer Response Options

When the implementation agent (Model A) receives review findings from the branch reviewer (Model B), it has explicit permission to:

- **Accept and implement** in-scope P0 and P1 findings immediately.
- **Defer** in-scope P2 findings — tag as deferred, log, continue without addressing.
- **Push back on out-of-scope** findings regardless of severity — tag as out-of-scope, log for future work, continue.

Without this permission, the implementer attempts to address every finding with equal weight, leading to scope expansion and thrashing on cosmetic issues.

## Spec Feedback

When the reviewer finds a security or correctness issue that is NOT in documented requirements:
1. Tag it P1.
2. Note which spec or BDD scenario should be updated to cover this case.
3. This creates a feedback loop to Phases 1-3 — the human and Model A iterate on the spec update.
4. Updated specs trigger dual-model audit per `references/audit-checklist.md`.

## Review Exchange Recording

The full review-response exchange between reviewer and implementer is recorded per feature:
- Every finding with severity and scope tags
- Every implementer response (accepted, deferred, pushed back) with reason
- The final merge verdict

This recording serves two consumers:
1. **Post-merge human review summary** (Phase 7 output) — the human reviews decisions asynchronously after merge.
2. **Quality metrics** (see `references/observability-metrics.md`) — severity distribution, defer/pushback rate, rework rate.

The human has authority to revert a merge if they disagree with any defer or pushback decision. If reverted, the feature returns to Phase 6 with the human's correction applied — the previously deferred or pushed-back finding becomes a mandatory fix.
