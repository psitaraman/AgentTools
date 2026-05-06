---
name: grade-skill
description: "Grade any AI agent skill against the skill rubric. Use when evaluating a skill before use, after creating a skill, or when auditing existing skills. Triggers on: 'grade this skill', 'evaluate skill', 'audit skill', 'score skill', 'is this skill ready'. Outputs a scored report with pass/conditional/fail rating."
context: fork
---

# Grade Skill

Evaluate an AI agent skill against the rubric. Combines automated structural checks with judgment-based scoring. Runs in an isolated context — only the final report returns to the main conversation.

## Process

### Step 1: Locate the skill
[current context]

Ask the user for the skill path or identify it from context. Read the SKILL.md and list the directory contents.

**Done when:** Skill directory path confirmed and contents listed.
**If blocked:** Ask the user to provide the path.

### Step 2: Run automated checks
[current context — script executed, only output enters context]

Execute `${CLAUDE_SKILL_DIR}/scripts/check.sh <skill-path>`. Captures: line count, directory structure, file existence, description length, shebang presence, routing analysis, hardcoded content detection.

**Done when:** check.sh output captured.
**If blocked:** Report which check failed and why.

### Step 3: Load the rubric
[current context — reference loaded for scoring]

Read `${CLAUDE_SKILL_DIR}/references/rubric.md`. Contains 32 criteria across 7 categories.

**Done when:** Rubric loaded and ready for scoring.

### Step 4: Score each category
[current context]

For each of the 7 categories, score every criterion 0/1/2 based on:
- Automated check results from Step 2 (for structural criteria)
- Your judgment reading the skill's files (for quality criteria)

Be strict. If in doubt between two scores, pick the lower one.

**Scoring thresholds:**
- **Pass:** ≥53 (80%+) — ready for use
- **Conditional:** 40-52 (60-79%) — fix critical gaps before real work
- **Fail:** <40 (<60%) — redesign required

**Done when:** All 32 criteria scored.

### Step 5: Generate the report
[current context — this is the output that returns to the main conversation]

Output a report with this structure:

```
# Skill Grade: <skill-name>

## Summary
Score: XX/66 (XX%) — PASS / CONDITIONAL / FAIL

## Category Scores
| Category | Score | Max | Notes |
|----------|-------|-----|-------|
| Orchestrator Design | | 14 | |
| Context Boundaries | | 12 | |
| Vertical Depth | | 10 | |
| Horizontal Flow | | 10 | |
| Tool Integration | | 8 | |
| Testability | | 8 | |
| Triggering | | 4 | |
| **Total** | | **66** | |

## Automated Check Results
(paste from Step 2)

## Detailed Scoring
(list each criterion with score and one-line justification)

## Top Issues
(ranked list of the most impactful things to fix)

## Recommendation
(what to do: ship it, fix specific gaps, or redesign)
```

### Step 6: Suggest fixes
[current context]

For every criterion scored 0 or 1, suggest a concrete fix. Not "improve this" — specific changes to specific files.

**Done when:** Every low-scoring criterion has a specific fix suggestion.
