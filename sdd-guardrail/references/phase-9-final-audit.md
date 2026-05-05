# Phase 9: Final Audit

**Participants:** Model A + Model B independently (both with fresh context)
**Context:** Two separate subagents, each with fresh context
**Input:** Full trunk + running application + all evaluation checklists (from Phase 4)
**Trigger:** All branches merged, no open branches remain

## What This Phase Produces

Independent verification by both models that the complete product meets its specifications. This is the terminal gate — nothing ships without both models passing independently.

## Why Both Models

Phase 8 had only Model B auditing after each merge. Phase 9 adds Model A back for a final independent check. Two independent perspectives on the complete product:

- **Model A** has been the generator throughout — it knows implementation intent but may have blind spots from being too close to the code.
- **Model B** has been the evaluator throughout — it knows the acceptance criteria but may have blind spots from not implementing.

Cross-model review eliminates self-preference bias (GPT-4 ~10%, Claude ~25% — ADR-006). Independent audits catch what single-model review misses. Multi-review aggregation increased recall by 118% over single-model runs.

## Audit Process

Each model independently:
1. Reads all product specs, tech specs, and BDD scenarios.
2. Runs the full test suite (unit + integration).
3. Runs all audit scripts from `references/audit-checklist.md` against the full codebase.
4. Runs UI tests against the running application (ADR-013).
5. Walks all evaluation checklists — product spec, technical spec, and BDD.
6. Verifies every BDD scenario is satisfied by the implementation.
7. Evaluates against the full audit checklist — every item, not just integration concerns.
8. Tags all findings with severity (P0/P1/P2) per `references/severity-classification.md` for metrics consistency. Scope tagging does not apply to Phase 9 — that is Phase 7 only.

Models do not see each other's results until both are complete.

## Verdicts

- **Both pass** — pipeline complete. Product ships.
- **Either fails** — enters the fix loop (see below).
- **Models disagree** — human resolves (see below).

## Fix Loop

If either model's audit finds issues:
1. Model A fixes the issues (fresh context).
2. Both models re-audit independently from scratch — not incremental, full re-audit.
3. Repeat until both pass or BLOCKED.

This is different from Phase 8's fix loop. Phase 9 requires BOTH models to re-audit after any fix, not just Model B.

## Disagreement Resolution

When models disagree (one passes, one fails):
1. Both verdicts presented to human with full audit reports.
2. Human resolves:
   - **Human agrees there's an issue** — Model A fixes → both models re-audit from scratch.
   - **Human says no issue** — disagreeing model's concern is dismissed, pipeline proceeds.
   - **Human says specs need updating** — collaborative resolution on specs → dual-model audit on changed specs → both models re-audit the product from scratch.

In all cases where code or specs change, both models re-audit from scratch. Human is the tiebreaker but resolution flows back through the same pipeline.

## Audit Report Format

Each model produces:

```
## Final Audit Report

Auditor: [Model A / Model B]
Date: [date]
Product: [product name]
Specs reviewed: [list of specs with versions]

### Test Results
- Unit tests: [pass/fail count]
- Integration tests: [pass/fail count]
- UI tests: [pass/fail count]

### Audit Script Results
[output from linter, SAST, dependency audit, etc.]

### Evaluation Checklist Results
[pass/fail per checklist item — product spec, tech spec, BDD]

### BDD Scenario Coverage
- [feature]: [all scenarios verified / issues found]

### Audit Checklist Evaluation
[judgment on each checklist category — correctness, security, architecture, quality attributes, UX]

### Findings
[specific issues with severity tags, file paths, and line numbers]

### Verdict: PASS / FAIL
[one sentence justification]
```

## Done Signal

- Both models have submitted independent audit reports
- Both verdicts are PASS (or human has resolved disagreements)
- All findings tagged with severity for metrics
- Pipeline complete

## If Blocked

- Cannot start the running application — flag to human, report the error
- UI test infrastructure unavailable — flag to human, report which tests couldn't run
- Missing specs or BDD scenarios — flag to human, identify what's missing
- Models produce contradictory findings that human cannot resolve — flag, escalate
