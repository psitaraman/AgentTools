---
name: sdd-guardrail
description: "Orchestrate the SDD+BDD+TDD pipeline. Enforces strict phase sequence from product spec through final audit. Model A generates, Model B evaluates. Use when starting a new product, feature, or development cycle. Triggers on: 'start the pipeline', 'new product spec', 'run sdd', 'sdd guardrail'."
context: fork
---

# SDD Guardrail — Pipeline Orchestrator

9-phase pipeline: specs before behaviors, behaviors before tests, tests before implementation, independent review before merge.

### Phase 1: Product Spec
[current context — human + Model A co-create]
Create product spec + child feature product specs. See `${CLAUDE_SKILL_DIR}/references/phase-1-product-spec.md`.
**Done when:** All features specced, dependencies mapped, human approved.
**If blocked:** Flag to human with recommendations.

### Phase 2: Technical Spec
[current context — human + Model A co-create]
Create tech spec per feature. Research via MCP first. See `${CLAUDE_SKILL_DIR}/references/phase-2-technical-spec.md`.
**Done when:** Every feature has tech spec with architecture and design principles, human approved.
**If blocked:** Flag to human with recommendations.

### Phase 3: BDD Scenarios
[subagent — Model A, fresh context, human sign-off]
Generate exhaustive behavioral contracts per feature. See `${CLAUDE_SKILL_DIR}/references/phase-3-bdd-scenarios.md`.
**Done when:** All features have BDD scenarios, human signed off.
**If blocked:** See `${CLAUDE_SKILL_DIR}/references/blocked-protocol.md`.

### Phase 4: Checklist Generation
[subagent — Model A, fresh context]
Extract pass/fail evaluation checklists from all specs and BDD. See `${CLAUDE_SKILL_DIR}/references/phase-4-checklist-generation.md`.
**Done when:** Product spec, tech spec, and BDD checklists generated with version pinning.
**If blocked:** See `${CLAUDE_SKILL_DIR}/references/blocked-protocol.md`.

### Phase 5: TDD Test Generation
[subagent — Model B, fresh context]
Generate tests across architecture layers. Verify red. Set read-only. See `${CLAUDE_SKILL_DIR}/references/phase-5-tdd-generation.md`.
**Done when:** All tests red, files chmod read-only, baseline recorded.
**If blocked:** See `${CLAUDE_SKILL_DIR}/references/blocked-protocol.md`.

### Phase 6: Implementation
[subagent — Model A builds, Model B evaluates at each level]
Recursive build-evaluate loop. Max 3 deep, unlimited breadth. See `${CLAUDE_SKILL_DIR}/references/phase-6-implementation.md`.
Failure traceability: `${CLAUDE_SKILL_DIR}/references/phase-6-implementation.md#structured-failure-traceability`.
Severity/pushback: `${CLAUDE_SKILL_DIR}/references/severity-classification.md`.
**Done when:** All tests green, both audits pass at every level. → Phase 7.
**If blocked:** See `${CLAUDE_SKILL_DIR}/references/blocked-protocol.md`.

### Phase 7: Branch Review
[subagent — Model B, fresh context]
Comprehensive feature review before merge. Walk checklists. Tag findings. See `${CLAUDE_SKILL_DIR}/references/phase-7-branch-review.md`.
Severity/scope: `${CLAUDE_SKILL_DIR}/references/severity-classification.md`.
**Done when:** All blocking findings resolved, merged to trunk, post-merge summary produced.
**If blocked:** See `${CLAUDE_SKILL_DIR}/references/blocked-protocol.md`.

### Phase 8: Trunk Audit
[subagent — Model B, fresh context. Model A fixes.]
Integration check after merge. Full test suite + UI tests. See `${CLAUDE_SKILL_DIR}/references/phase-8-trunk-audit.md`.
**Done when:** Full test suite passes (unit + integration + UI), evaluation checklists walked, no regressions, all findings severity-tagged, trunk clean.
**If blocked:** See `${CLAUDE_SKILL_DIR}/references/blocked-protocol.md`.

### Phase 9: Final Audit
[subagent — both Model A + Model B independently, fresh context]
Both models audit full trunk + running app. See `${CLAUDE_SKILL_DIR}/references/phase-9-final-audit.md`.
**Done when:** Both pass. Disagree → human resolves.
**If blocked:** See `${CLAUDE_SKILL_DIR}/references/blocked-protocol.md`.

---
Audit checklist: `${CLAUDE_SKILL_DIR}/references/audit-checklist.md`
Document hierarchy: `${CLAUDE_SKILL_DIR}/references/document-hierarchy.md`
Metrics: `${CLAUDE_SKILL_DIR}/references/observability-metrics.md`
Pre-check: execute `${CLAUDE_SKILL_DIR}/scripts/check-phase.sh <phase> <feature-path>` before each phase. The script validates prerequisites for **entering** the named phase, not the products of the prior phase's completion.
