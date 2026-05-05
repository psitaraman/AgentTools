# Phase 6: Implementation (Recursive Build-Evaluate Loop)

**Participants:** Model A (generator) builds and self-audits, Model B (evaluator) independently audits at every level
**Context:** Subagent per feature with fresh context. Worktrees for isolation when needed.
**Input:** Feature's product spec + BDD scenarios + tests (read-only) + feature's tech spec
**Output:** Feature branch code with all TDD tests passing → flows to Phase 7 (Branch Review)

## What This Phase Produces

Working implementation code on a feature branch. Model A writes code to make Model B's tests pass, self-audits its work, then Model B independently audits. This happens at every level of decomposition.

When complete, the feature flows to Phase 7 (Branch Review) for comprehensive holistic review before merge — not directly to trunk.

## Evaluation Flow

At each level:
1. **Model A implements** — writes code to make TDD tests pass.
2. **Model A self-audits** — reviews its own work against the full audit checklist (see `references/audit-checklist.md`).
3. **Model A runs audit scripts** — linter, SAST, dependency audit, etc. Includes output in self-audit report.
4. **Model B independently audits** — reviews script output, independently evaluates judgment-based checklist items.
5. **If Model B passes** — result bubbles up to the parent level.
6. **If Model B fails** — Model A iterates with Model B's feedback. Max 10 iterations per level.
7. **If max iterations reached** — flag to human with AI recommendations.

## Structured Failure Traceability

When a test fails during the TDD loop, the failure report is enriched with upstream context so Model A can reason about intent, not just syntax errors:

1. **BDD scenario origin** — which BDD scenario the failing test was generated from, resolved via the test file's `built-from` metadata.
2. **Product spec feature** — which product spec feature that BDD scenario traces to, following the `built-from` chain up.
3. **Behavioral assertion** — the plain text behavioral assertion from the BDD scenario.

This gives the implementer: "This test exists because the user expects [behavior] in [feature]" rather than just "assertion failed on line 42."

This enrichment is read-only context. It does not change the implementer's access to test files. ADR-005 (test file isolation) remains fully enforced.

## Implementer Response to Review Feedback

When Model B provides feedback during the level-by-level evaluation, Model A responds per the severity/scope rules in `references/severity-classification.md`:

- **Accept and implement** P0 and P1 findings immediately.
- **Defer** P2 findings — tag as deferred, log, continue.
- **Push back on out-of-scope** findings — tag as out-of-scope, log for future work, continue.

This prevents scope expansion and thrashing on cosmetic issues during the implementation loop.

## File Header Generation (ADR-023)

When Model A creates or modifies a source file, it writes the structured short header alongside the code in the same commit. The header carries:

- **Purpose** (1–2 lines) — WHY this file exists. Reference the tech spec section this file implements.
- **Public API** — enumerated list of exports (functions, classes, exported types). Must match actual exports.
- **Invariants / gotchas** — only when non-obvious. Skip when the header would restate self-documenting code.
- **Pointers** — tech spec section and BDD scenarios that govern this file.

Headers sit at the top of the file using language-appropriate comment syntax. Length target: 15–30 lines. No version history (git owns that). No restatement of code behavior (BDD and TDD own that). Header and code are updated together — a code change without a corresponding header review is a pipeline error.

Model B verifies header/code alignment during Phase 7 (Branch Review).

## Recursive Decomposition

Large tasks decompose into subtasks up to 3 levels deep (ADR-011). Breadth is unlimited — many subtasks at each level. Depth is capped at 3.

```
Feature Branch (Level 1)
  ├── Subtask A (Level 2)
  │     ├── Leaf A1 (Level 3) — Model A implements + self-audits → Model B audits
  │     ├── Leaf A2 (Level 3) — Model A implements + self-audits → Model B audits
  │     └── Level 2 integrates → Model A self-audits → Model B audits
  ├── Subtask B (Level 2)
  │     ├── Leaf B1 (Level 3) — Model A implements + self-audits → Model B audits
  │     └── Level 2 integrates → Model A self-audits → Model B audits
  └── Level 1 integrates → Model A self-audits → Model B audits
        └── all tests pass + both audits pass → Phase 7 (Branch Review)
```

## Depth Limit Rule

If a Level 3 task discovers it needs further decomposition, it does NOT spawn Level 4. Instead, the work is added as:
- A new sibling at Level 3, or
- A new subtask at Level 2

Work flattens back into existing levels. Never go deeper than 3.

## TDD Loop (Within Each Level)

Model A's implementation follows the TDD cycle:
1. Run tests — see which are red. Failure report includes traceability context (see above).
2. Write minimal code to make one test green.
3. Run tests again — verify green, check no regressions.
4. Repeat until all tests for this level's scope are green.
5. Refactor if needed — tests must stay green.

Test files are read-only (ADR-005). Model A cannot modify tests. Enforced by file permissions and post-hoc diff checks.

## Test Isolation Verification

After each implementation step, `check-phase.sh` verifies:
1. Test files have not been modified (diff against baseline from Phase 5).
2. If test files changed — reject changes, revert, flag to human.

## Spec Problems During Implementation

When implementation reveals that a spec is wrong, incomplete, or needs restructuring:
1. Model A flags the issue with its analysis and recommendations.
2. AI and human iterate together to redesign or refactor the spec or tech requirements.
3. Updated specs trigger dual-model audit against the full audit checklist.
4. Downstream documents (including checklists from Phase 4) flagged stale and regenerated as needed.
5. Resume implementation with corrected specs.

## Worktrees

Use git worktrees when isolation is needed — not mandated at every level. Use judgment:
- Parallel subtasks at the same level — worktrees for isolation
- Sequential subtasks — same branch may be fine
- Parent blocked on child result — worktree for the child

## Dependencies

Parent levels may block on child results before continuing:
- Level 2 decomposes work into Level 3 subtasks
- Level 3 subtasks complete and are evaluated
- Results flow back to Level 2
- Level 2 integrates and continues its work

## Concurrency

Independent features can run concurrently (separate branches, separate subagents). Independent subtasks within a feature can also run concurrently when using worktrees.

## Done Signal

- All TDD tests pass for this feature
- Model A has self-audited at every level
- Model B has independently audited and passed at every level
- Test files verified unmodified from Phase 5 baseline
- Each source file carries the ADR-023 structured short header, current with the code
- Code is on a feature branch ready for Phase 7 (Branch Review)

## If Blocked

- Tests fail after 10 iterations — flag to human, report what's failing and why
- Dependency on another feature not yet implemented — flag to human, identify the dependency
- Architecture in tech spec doesn't match what's needed — flag to human with recommendations, iterate on spec
- Test file appears to have a bug — flag to human, do not modify tests (ADR-005)
