# Phase 7: Branch Review

**Participants:** Model B (evaluator, fresh context)
**Context:** Subagent with fresh context
**Input:** Feature's product spec + tech spec + BDD scenarios + test results + implementation code + evaluation checklists (from Phase 4)
**Trigger:** Feature implementation complete, all TDD tests passing, all level-by-level evaluations passed in Phase 6

## What This Phase Produces

A comprehensive, holistic review of the complete feature before merge. Model B gets fresh context — it has not seen the incremental implementation work from Phase 6. It evaluates the whole feature against its specs and BDD contract.

This is distinct from Phase 6's level-by-level evaluation. Phase 6 checks "does each piece work?" Phase 7 checks "does the whole feature satisfy its contract?"

## Scope Assertion

The reviewer's scope is ONLY: "Does this feature's implementation satisfy its BDD contract and spec?"

- All findings must be traceable to a specific spec requirement, BDD assertion, or technical spec constraint.
- All findings tagged with severity (P0/P1/P2) and scope (in-scope/out-of-scope) per `references/severity-classification.md`.
- The reviewer does not expand scope beyond the feature being reviewed.
- If a concern is not grounded in a documented requirement and is not a security or correctness risk, the reviewer does not raise it.

**Exception:** Security vulnerabilities and correctness bugs that pose risk are flagged regardless of whether they appear in documented requirements. These are tagged P1 with a note identifying which spec or BDD scenario should be updated to cover this case (see Spec Feedback below).

## Review Process

1. **Walk the evaluation checklists** — product spec checklist, technical spec checklist, and BDD checklist item by item. Mark each pass/fail.
2. **Audit against the full checklist** — evaluate against `references/audit-checklist.md` with focus on the current feature.
3. **Tag every finding** with severity (P0/P1/P2) and scope (in-scope/out-of-scope).
4. **Submit review** to the implementer (Model A) for response.

## Documentation Alignment Checks

Model B explicitly verifies three alignments during branch review. These checks sit alongside the checklist walk and the audit-checklist evaluation — they are their own finding category because misalignment is a distinct failure mode from missing or incorrect behavior.

1. **BDD ↔ TDD coverage** (ADR-008) — every behavioral scenario in the feature's BDD has at least one test covering it. A scenario without a corresponding test is a P1 finding by default.
2. **File header ↔ code** (ADR-023) — for each source file produced by Phase 6:
   - The Public API list in the header matches the file's actual exports (mechanical comparison).
   - The Purpose line captures WHY the file exists and does not restate what the code does (per ADR-023). Reviewers check that the stated WHY still applies to the file as written — not that Purpose describes observable behavior (BDD and TDD own behavior).
   - The Pointers still resolve (the tech spec section exists, the BDD scenarios exist).
   Drift is a P1 finding by default — specifically Public API mismatch, because the mechanical check leaves no judgment room.
3. **Header WHY ↔ spec WHY** (ADR-023) — the file header's Purpose and Invariants do not contradict the governing tech spec section. Contradiction is a P1 finding; overlap without contradiction is fine.

For in-scope protocol specs (ADR-022), Model B additionally verifies that every MUST and SHOULD in the tech spec has at least one paired BDD scenario. Missing pairing is a P1 finding.

All documentation-alignment findings follow the same severity and scope protocol as other findings (`references/severity-classification.md`).

## Review-Response Loop

After Model B submits findings:

1. Model A reviews each finding and responds:
   - **Accept and implement** in-scope P0 and P1 findings immediately.
   - **Defer** in-scope P2 findings — tag as deferred, log, continue.
   - **Push back on out-of-scope** findings — tag as out-of-scope, log for future work, continue.
2. Model A implements accepted fixes.
3. Model B re-reviews the fixes.
4. Repeat until all blocking findings (P0/P1 above threshold) are resolved.
5. If stuck — flag to human with AI recommendations.

The full exchange is recorded per `references/severity-classification.md` (Review Exchange Recording).

## Spec Feedback

When the reviewer finds a security or correctness issue not in documented requirements:
1. Tag it P1.
2. Note which spec or BDD scenario should be updated to cover this case.
3. After the branch merges, this feeds back to Phases 1-3 — the human and Model A iterate on the spec update.
4. Updated specs trigger dual-model audit per `references/audit-checklist.md`.

## Merge Decision

- All P0 findings resolved.
- All P1 findings resolved (or below configurable threshold — see `references/severity-classification.md`).
- P2 findings logged as deferred.
- Out-of-scope findings logged for future work.
- → Merge to trunk → Phase 8 (Trunk Audit).

## Post-Merge Human Review Summary

After the branch merges, the orchestrator produces a review decision summary and presents it to the human asynchronously. The pipeline does not block for human approval.

The summary contains:
- All reviewer findings with severity and scope tags
- The implementer's response to each finding (accepted, deferred, pushed back)
- The reason for each defer or pushback
- Deferred P2 items as future work
- Out-of-scope findings logged for future work
- The final merge verdict and which findings were resolved vs deferred

The human has authority to revert the merge if they disagree with any defer or pushback decision. If reverted, the feature returns to Phase 6 with the human's correction applied — the previously deferred or pushed-back finding becomes a mandatory fix.

## Done Signal

- All evaluation checklists walked item by item
- Documentation alignment checks pass (BDD ↔ TDD, file header ↔ code, header WHY ↔ spec WHY; ADR-022 MUST/SHOULD ↔ BDD pairing where applicable)
- All findings tagged with severity and scope
- All blocking findings resolved
- Review exchange recorded
- Post-merge summary produced
- Feature merged to trunk

## If Blocked

- Reviewer cannot determine if finding is in-scope or out-of-scope → flag to human
- Implementer and reviewer disagree on severity classification → flag to human with both assessments
- Undocumented security risk requires immediate spec update before merge can proceed → flag to human, collaborative resolution
