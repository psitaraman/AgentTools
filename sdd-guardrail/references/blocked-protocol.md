# BLOCKED Protocol

When any agent cannot proceed — ambiguity, max iterations reached, missing information, dependency not met, stale input — it must stop and escalate. Agents do not self-unblock.

## When to BLOCKED

- Ambiguity in specs that requires human judgment
- Max iterations reached (default 10 per level) without tests passing
- Missing input artifact or stale dependency
- Dependency on another subtask's result that hasn't completed
- Conflicting requirements between any specs or dependencies
- External service or tool unavailable

## BLOCKED Report Format

```
BLOCKED

Phase: [current phase number and name]
Level: [depth level if in Phase 6, e.g., "Level 2, Subtask B"]

## Accomplished
[What was completed before blocking. Be specific — files created, tests written, code committed.]

## Blocking Issue
[What is preventing progress. One clear sentence.]

## Assessment
[Your analysis of what's needed to unblock. Include options if multiple paths exist.]

## Artifacts
[List any partial artifacts produced. Include file paths and state.]
```

## Rules

1. Output `BLOCKED` as the first line — this is the signal the harness detects.
2. Do not attempt workarounds, guesses, or partial solutions after blocking.
3. Do not modify test files to make them pass (ADR-005).
4. Do not self-unblock by lowering quality standards.
5. Preserve all work completed before the block — do not revert.

## Conflict Resolution

Conflicts are not just flagged and left for the human to fix alone. Resolution is collaborative:

1. Flag the conflict to the human with the BLOCKED report.
2. Human and AI resolve together iteratively — discussing options, pulling in external resources (docs, standards, research).
3. Once resolved, update the affected specs.
4. Updated specs trigger dual-model audit (both Model A and Model B review against the full audit checklist — see `references/audit-checklist.md`).
5. If audit passes → resume pipeline. If audit finds new issues → iterate.
