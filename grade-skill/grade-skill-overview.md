---
title: "grade-skill — AI Agent Skill Evaluation Tool"
created: 2026-04-07T18:00:00-07:00
updated: 2026-04-07T18:30:00-07:00
tags: [skill, eval, context-engineering]
status: current
---

# grade-skill — AI Agent Skill Evaluation Tool

## What It Is

A Claude Code skill that evaluates other skills against a structured rubric. Combines automated structural checks (line count, directory layout, description length, script executability) with LLM judgment scoring (instruction quality, context boundary decisions, testability, composability). Outputs a scored report with pass/conditional/fail rating and specific fix suggestions.

Runs with `context: fork` — the entire grading process executes in an isolated subagent context. Only the final report (~500 tokens) returns to the main conversation. The rubric, check output, and target skill contents are discarded after grading, keeping the main context clean. Estimated cost: ~4,000-5,300 tokens during grading, ~500 tokens returned.

## Current State

v3 of the rubric. 32 criteria across 7 categories, max 66 points. Pass at 80%+. Platform-agnostic — no Claude-specific references in the rubric itself.

## Key Details

**Invocation:** Copy the `grade-skill/` directory to `.claude/skills/grade-skill/` in any project. Trigger with "grade this skill", `/grade-skill`, or `/grade-skill <skill-name>`.

**Components:**
- `SKILL.md` — 6-step process with context boundaries declared at each step. Uses `context: fork` for isolation.
- `references/rubric.md` — full rubric with all 32 criteria and scoring tables. Loaded at Step 3, discarded after grading.
- `scripts/check.sh` — automated structural checks. Executed, not read — only output enters context.

**Rubric categories:** Orchestrator Design (14), Context Boundaries (12), Vertical Depth (10), Horizontal Flow (10), Tool Integration (8), Testability (8), Triggering (4).

**Context cost:** ~500 tokens idle (description only). ~4,000-5,300 tokens during grading (isolated). ~500 tokens returned to main conversation (report only).

## Cross-References

- **First target:** SDD guardrail skill — evaluated against the rubric during development of this grading tool.
