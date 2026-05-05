---
title: "sdd-guardrail — SDD+BDD+TDD Pipeline Orchestrator"
tags: [skill, sdd, bdd, tdd, pipeline, orchestration, multi-agent]
---

# sdd-guardrail — SDD+BDD+TDD Pipeline Orchestrator

## What It Is

A Claude Code skill that orchestrates a 9-phase software development pipeline enforcing SDD → BDD → TDD in strict sequence. No code before specs. No tests before behaviors. No merges without independent cross-model review. Model A generates, Model B evaluates. The human co-creates and audits at every phase.

Runs with `context: fork` — the orchestration executes in an isolated subagent context.

## When to Use

- Starting a new product, feature, or development cycle that needs verifiable requirements traceability.
- Multi-feature work where independent review and integration auditing matter.
- Projects where ad-hoc spec drift has caused defects in the past.

## When Not to Use

- Single-file changes, ad-hoc debugging, or one-off scripts.
- Retrofitting specs onto an existing codebase (the pipeline assumes specs come first).
- Exploratory prototyping where the cost of upfront specification outweighs the benefit.

## Pipeline

| Phase | What | Who | Output |
|-------|------|-----|--------|
| 1 | Product Spec | Human + Model A | product-spec.md + feature specs |
| 2 | Technical Spec | Human + Model A | tech-spec.md per feature |
| 3 | BDD Scenarios | Model A (fresh) + Human sign-off | bdd/ per feature |
| 4 | Checklist Generation | Model A (fresh) | evaluation checklists |
| 5 | TDD Test Generation | Model B (fresh) | tests/ (read-only) |
| 6 | Implementation | Model A builds, Model B evaluates | feature branch code |
| 7 | Branch Review | Model B (fresh) | merge decision + summary |
| 8 | Trunk Audit | Model B (fresh), Model A fixes | clean trunk |
| 9 | Final Audit | Both models independently | ship or fix |

## Key Design Decisions

- **Everything is a feature.** The product is the top-level feature. Features nest. Every feature has a product spec and a tech spec.
- **Dependencies are dynamic.** `built-from` is a flexible list — no rigid template.
- **Model A generates, Model B evaluates.** Model B writes tests (defines acceptance criteria). Model A implements. Model B reviews. Model A fixes. Roles never blur.
- **Recursive implementation.** 3 levels deep max, unlimited breadth. Model B evaluates at each level as work bubbles up.
- **Severity classification.** P0/P1 block merge, P2 logs only. Implementer can defer P2 and push back on out-of-scope findings.
- **Any conflict goes to human** with AI recommendations for collaborative resolution.
- **Spec/test changes trigger dual-model audit.**

## Components

| File | Purpose |
|------|---------|
| `SKILL.md` | Flat orchestrator, 9 phase steps |
| `references/phase-1-product-spec.md` | Co-creation guide, feature structure |
| `references/phase-2-technical-spec.md` | Research, architecture, design principles |
| `references/phase-3-bdd-scenarios.md` | Plain text BDD, scenario coverage |
| `references/phase-4-checklist-generation.md` | Evaluation checklist extraction |
| `references/phase-5-tdd-generation.md` | Test gen, red verification, isolation |
| `references/phase-6-implementation.md` | Recursive build-evaluate, failure traceability |
| `references/phase-7-branch-review.md` | Scope assertion, severity tagging, pushback |
| `references/phase-8-trunk-audit.md` | Integration audit, regression check |
| `references/phase-9-final-audit.md` | Dual-model audit, disagreement resolution |
| `references/audit-checklist.md` | Reviewer checklist + audit scripts |
| `references/severity-classification.md` | P0/P1/P2, scope, threshold, exchange recording |
| `references/observability-metrics.md` | Process, quality, failure, cost metrics |
| `references/document-hierarchy.md` | Version pinning, staleness, audit-on-change |
| `references/blocked-protocol.md` | BLOCKED format, conflict resolution |
| `scripts/check-phase.sh` | Pre-phase artifact validation |

## Context Cost

- ~500 tokens idle (description only in skill listing)
- ~2,000 tokens on trigger (SKILL.md loaded)
- Phase references loaded on demand (~500-800 tokens each)
- Full pipeline context stays isolated via `context: fork`

## Side Effects

The pipeline mutates the working repository. Consumers should expect:

- Git branches created per feature in Phase 6; merged to trunk in Phase 7.
- Test files written in Phase 5 and `chmod a-w` (read-only) before Phase 6.
- A `.baseline` artifact written at the end of Phase 5 by the harness to record red-test state; read by `scripts/check-phase.sh` in later phases to verify test integrity.
- Spec, BDD, checklist, and test files written under a feature directory layout (see `references/document-hierarchy.md`).
- UI test infrastructure (Playwright or equivalent) invoked in Phases 8 and 9 against a running instance of the application.
