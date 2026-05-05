# Observability and Metrics

Metrics collected from every pipeline run to feed harness improvement (ADR-018: no model weight updates — all improvement through better harness, specs, documentation, and context engineering).

## Process Metrics

- **Iterations to green per feature:** TDD loop cycles before tests pass. Tracks implementation difficulty and model capability over time.
- **Phase duration:** Wall clock time per phase per feature. Identifies pipeline bottlenecks.
- **BLOCKED rate:** How often agents hit BLOCKED per phase, per feature. High rate in a phase means specs or context are insufficient there.
- **BDD-to-test ratio:** Number of test files generated per BDD scenario. Validates ADR-008 one-to-many mapping is working.
- **Checklist pass rate:** Percentage of checklist items passing on first review per checklist type (product spec, technical spec, BDD). Low pass rate on a specific type indicates weak specs in that area.

## Quality Metrics

- **Severity distribution:** Count of P0, P1, P2 findings per review per feature. Track over time — P0/P1 counts should decrease as the harness improves.
- **Out-of-scope rate:** Percentage of review findings tagged out-of-scope (Phase 7 only). High rate means the reviewer is drifting beyond its mandate — tighten scope assertion.
- **Defer/pushback rate:** How often the implementer defers P2 or pushes back on out-of-scope findings. Tracks whether pushback permission is being used appropriately.
- **Judge disagreement rate:** How often Phase 7 (branch review) and Phase 8 (trunk audit) disagree on the same code. How often Model A and Model B disagree in Phase 9 (final audit).
- **Rework rate:** Features requiring re-implementation after review feedback. Track separately for P0, P1, and P2 causes.
- **Integration failure rate:** Features passing Phase 7 branch review but failing Phase 8 trunk audit. Indicates interface boundary issues between features.

## Failure Metrics

- **Common failure patterns:** Categorize recurring BLOCKED reasons and recurring P0 findings. Highest-value targets for harness improvement — each pattern is a missing spec, missing context, or missing tool.
- **Traceability gaps:** Cases where structured failure traceability (Phase 6) cannot resolve the `built-from` chain from a failing test back to a spec feature. Indicates version pinning or metadata gaps.
- **Checklist gap rate:** BDD checklist items with no corresponding test coverage. Indicates Phase 5 test generation is incomplete.

## Cost Metrics

- **Token cost:** Per feature, per phase, per full pipeline run. Tracks efficiency and identifies expensive phases.
- **Subagent count per run.** Tracks coordination complexity.
- **Total wall clock time per pipeline run.** The number that matters for iteration speed.

## Review Exchange Recording

The full review-response exchange between reviewer and implementer is recorded per feature:
- Every finding with severity and scope tags (see `references/severity-classification.md`)
- Every implementer response (accepted, deferred, pushed back) with reason
- The final merge verdict and which findings were resolved vs deferred

This is the raw data that feeds:
1. The post-merge human review summary (Phase 7 output)
2. The quality metrics above (severity distribution, defer/pushback rate, rework rate)
3. The audit trail — if the human reverts a merge, the exchange record shows exactly what decisions were made and why

## Collection

Metrics are collected by the harness at each phase boundary and at pipeline completion. Stored in structured format (JSON or equivalent) per run, accumulated across runs. The skill itself does not ship metrics collection code; a deployed harness is required.

The harness does not analyze metrics automatically — the human reviews metrics periodically to identify harness improvement opportunities.

Each metric is derived from data the pipeline already produces: phase timestamps, test results, review findings with severity/scope tags, BLOCKED reports, checklist results. No expensive additional instrumentation.
