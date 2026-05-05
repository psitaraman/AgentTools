# Phase 8: Trunk Audit

**Participants:** Model B (evaluator, fresh context) identifies issues. Model A (generator) fixes them.
**Context:** Subagent with fresh context
**Input:** Full trunk from merge point + all specs + all tests + Phase 4 product-spec and tech-spec checklists (BDD checklist is per-feature — walked at Phase 7 and Phase 9, not at Phase 8)
**Trigger:** Feature branch merged to trunk after Phase 7 (Branch Review)

## What This Phase Produces

Verification that the merged feature branch hasn't broken anything in the trunk and that merged features work together. Phase 7 verified "does this feature satisfy its contract?" Phase 8 verifies "do merged features work together?"

This is an integration-scoped audit — not a repeat of Phase 7's feature review.

## Integration Scope

Model B receives the full integration surface:
- All merged feature specs (not just the latest merge)
- All BDD contracts across features (reference material for understanding feature behavior; the BDD checklist itself is not walked here — see ADR-020)
- All test results across features
- Product spec and tech spec evaluation checklists from Phase 4 (BDD checklist is per-feature and was walked at Phase 7)

Its scope is explicitly: "Do merged features work together?" This includes:
- Feature interactions and shared state
- Cross-feature data flows
- Shared infrastructure (auth, networking, persistence)
- Interface boundaries between features

## Audit Process

1. **Run the full test suite** — all tests across all features, not just the merged feature's tests.
2. **Run all audit scripts** from `references/audit-checklist.md` against the full codebase.
3. **Run UI tests against the running application** — start the application, exercise key flows with Playwright or equivalent (ADR-013).
4. **Walk evaluation checklists** — product spec checklist (do all features together deliver the product?) and technical spec checklist (does integration follow architecture?).
5. **Check for regressions:**
   - Do previously passing tests still pass?
   - Do features that were working before the merge still work?
   - Are shared components still functioning?
   - Any new warnings or deprecation notices?
6. **Tag findings with severity** (P0/P1/P2) per `references/severity-classification.md` for metrics consistency. Scope tagging does not apply to Phase 8 — that is Phase 7 only.

## Fix Loop

Model B identifies issues. Model A fixes them. Roles stay clean.

1. Model B audits trunk, reports issues with analysis, recommendations, and severity tags.
2. Model A fixes the issues (fresh context).
3. Model B re-audits.
4. Repeat until trunk is clean or max iterations reached.
5. If stuck — flag to human with AI recommendations.

## Done Signal

- Full test suite passes (unit + integration + UI)
- No regressions detected
- Evaluation checklists walked — all integration items pass
- All audit scripts pass against full codebase
- Any breakage fixed by Model A and verified by Model B
- All findings tagged with severity for metrics
- Trunk is clean and ready for the next merge

## If Blocked

- Test failure with unclear cause — flag to human, report failing tests and analysis
- Architectural conflict between merged features — flag to human with recommendations, iterate on resolution
- UI test infrastructure unavailable — flag to human, report which tests couldn't run
- Regression in a feature not related to the merge — flag to human, investigate root cause
