# AI Agent Skill Rubric v3

Evaluation criteria for AI agent skills designed as composable workflow graphs. Skills are DAGs: horizontal steps form workflows, vertical depth drills into sub-skills and tools, context boundaries are declared at each node.

Works for any agent platform (Claude Code, Copilot, Codex, Cursor, local LLMs).

Score each item 0 (fail), 1 (partial), or 2 (pass).

---

## 1. Orchestrator Design (max 14 points)

The root skill is a lean dispatcher. It defines the workflow and routes to external resources. It does not contain detail.

| # | Criteria | 0 | 1 | 2 |
|---|----------|---|---|---|
| 1.1 | Orchestrator is flat — under 100 lines, one sentence per step, links to where detail lives | >200 lines with inline detail | 100-200 lines, some inline | <100 lines, all detail in linked files |
| 1.2 | Each step has: what to do, where the detail is (script/sub-skill/reference/MCP tool), and a done signal | Steps are vague or missing elements | Most steps complete | Every step has action, link, and done signal |
| 1.3 | Workflow is traceable root to leaf — a reader can follow the full execution path from the orchestrator without guessing | Unclear what gets called or when | Mostly traceable | Fully traceable with explicit links at every level |
| 1.4 | Steps are ordered as a DAG — dependencies between steps are explicit, no circular references | Circular or unclear dependencies | Some dependencies implicit | All dependencies explicit, DAG is valid |
| 1.5 | Orchestrator handles failure at each step — what happens if a step fails, blocks, or times out | No failure handling | Some steps have failure paths | Every step has an explicit failure/blocked path |
| 1.6 | Orchestrator does not hardcode domain-specific content (project names, tech stack, company names) | Hardcoded references | Some generic | Fully domain-agnostic |
| 1.7 | All outputs and side effects are documented — no surprises (files created, branches, background processes, API calls) | Undocumented side effects | Some documented | All outputs and side effects listed |

## 2. Context Boundaries (max 12 points)

Every node in the DAG declares whether it runs in the current context or spawns a new one. This is the most important architectural decision.

| # | Criteria | 0 | 1 | 2 |
|---|----------|---|---|---|
| 2.1 | Every step explicitly declares: current context or new subagent | No context declarations | Some declared | Every step has explicit context boundary |
| 2.2 | Heavy operations (file reading, research, multi-step generation) use subagent isolation | Heavy ops in main context | Some isolated | All heavy ops in subagents |
| 2.3 | Steps that need conversation history run in current context — not isolated unnecessarily | Everything isolated, losing needed context | Mixed | Isolation decisions match actual context needs |
| 2.4 | Subagent steps define what input they receive and what output they return to the parent | No input/output contracts | Some defined | Every subagent step has explicit input/output contract |
| 2.5 | Parallel steps (multiple subagents) have a defined merge strategy — how results combine | No merge strategy | Implicit merge | Explicit merge strategy (merge branch, combine JSON, reconcile) |
| 2.6 | Total context cost of orchestrator + one active branch is estimated and under 5k tokens on-trigger | No cost awareness | Estimated but over 5k | Estimated and under 5k |

## 3. Vertical Depth (max 10 points)

Any step can drill into a sub-skill, which is itself a small orchestrator. Depth must be justified and independently testable.

| # | Criteria | 0 | 1 | 2 |
|---|----------|---|---|---|
| 3.1 | Each sub-skill is independently invocable and testable — works without the parent orchestrator | Sub-skills only work in parent context | Most independent | All sub-skills independently testable |
| 3.2 | Sub-skills follow the same structure as the root (flat orchestrator, links to detail, context boundaries) | Sub-skills are monolithic | Partially structured | Sub-skills follow same pattern recursively |
| 3.3 | Depth is justified — a step drills down only when the sub-workflow has 2+ steps of its own | Single-action steps wrapped in unnecessary sub-skills | Some unnecessary depth | Every sub-skill has 2+ steps justifying its existence |
| 3.4 | Depth is shallow enough to trace without getting lost — a new reader can follow the full path from root to leaf | Cannot trace execution path | Traceable with effort | Immediately traceable |
| 3.5 | Shared utilities (common scripts, shared reference files) are at the root level, not duplicated across sub-skills | Duplicated across sub-skills | Some sharing | All shared resources at root, referenced by sub-skills |

## 4. Horizontal Flow (max 10 points)

The workflow steps execute in sequence or parallel. Handoffs between steps are explicit.

| # | Criteria | 0 | 1 | 2 |
|---|----------|---|---|---|
| 4.1 | Each step produces a defined artifact that the next step consumes (file, JSON, branch, report) | No defined artifacts | Some artifacts defined | Every step has explicit input and output artifacts |
| 4.2 | Parallel steps are identified — steps with no dependencies between them can run simultaneously | No parallelism consideration | Some parallel steps identified | All parallelizable steps marked, dependencies prevent incorrect parallelism |
| 4.3 | The workflow has a single entry point and a single terminal state (or explicit terminal states for success/failure) | Multiple unclear entry/exit points | Entry clear, exit unclear | Single entry, explicit terminal states |
| 4.4 | Steps can be skipped or re-run independently — the workflow is resumable, not all-or-nothing | Must restart from beginning | Some steps re-runnable | Any step can be re-run with its inputs |
| 4.5 | Validation/gate steps exist between major phases — work is checked before proceeding | No gates | Some gates | Explicit validation between phases |

## 5. Tool Integration (max 8 points)

Steps reference tools: shell scripts, MCP servers, APIs, sub-skills. The skill defines what to call, not how it works internally.

| # | Criteria | 0 | 1 | 2 |
|---|----------|---|---|---|
| 5.1 | Shell scripts are executed — only their output enters context, not source code | Scripts read into context | Mixed | All scripts executed, only output consumed |
| 5.2 | External services use platform tool protocols (MCP, function calling, tool use) rather than reimplementing API calls | Skill reimplements APIs | Mixed | Platform tool protocols used for external services |
| 5.3 | Tool invocations are agent-agnostic — the skill describes what to call, the agent config maps it to the right command | Hardcoded to one agent platform | Some abstraction | Fully agent-agnostic tool references |
| 5.4 | Each tool has a fallback or error message if it's unavailable on the current platform | No fallback | Some tools have fallbacks | All tools have fallback behavior or clear error |

## 6. Testability (max 8 points)

| # | Criteria | 0 | 1 | 2 |
|---|----------|---|---|---|
| 6.1 | Can be tested with 3+ prompts at different complexity levels | Not testable | 1-2 test cases | 3+ test cases covering range |
| 6.2 | Has been through at least 2 iteration rounds (test → grade → fix → repeat) | Never tested | One pass | 2+ rounds |
| 6.3 | Outputs are objectively verifiable (files created, tests pass, checklist satisfied) | Purely subjective | Partially verifiable | Fully verifiable |
| 6.4 | Works on a fresh environment with no prior context | Requires prior context | Mostly self-contained | Fully self-contained |

## 7. Triggering (max 4 points)

| # | Criteria | 0 | 1 | 2 |
|---|----------|---|---|---|
| 7.1 | Description includes trigger phrases in real user language, with most important keywords early (platforms may truncate) | Generic/vague, keywords buried | Some trigger phrases | Specific phrases, keywords front-loaded |
| 7.2 | Description specifies when NOT to use the skill | No exclusions | Vague exclusions | Clear exclusion criteria |

---

## Scoring

| Category | Max | What it evaluates |
|----------|-----|-------------------|
| Orchestrator Design | 14 | Is the root skill flat, traceable, and failure-aware? |
| Context Boundaries | 12 | Are isolation decisions explicit and correct? |
| Vertical Depth | 10 | Are sub-skills justified, independent, and recursive? |
| Horizontal Flow | 10 | Are step handoffs, artifacts, and gates defined? |
| Tool Integration | 8 | Are tools executed not read, agent-agnostic, with fallbacks? |
| Testability | 8 | Has the skill been tested and does it work standalone? |
| Triggering | 4 | Will the agent actually invoke this skill when needed? |
| **Total** | **66** | |

| Rating | Score | Action |
|--------|-------|--------|
| Pass | ≥53 (80%+) | Ready for use |
| Conditional | 40-52 (60-79%) | Fix critical gaps before real work |
| Fail | <40 (<60%) | Redesign required |

---

## Quick Audit (5-minute version)

1. ☐ Is the orchestrator under 100 lines with links to all detail?
2. ☐ Does every step declare current context vs subagent?
3. ☐ Can you trace the full execution path root to leaf?
4. ☐ Can each sub-skill run independently?
5. ☐ Does every step define what it produces and what consumes it?
6. ☐ Are scripts executed, not read into context?
7. ☐ Does every step have a failure path?
8. ☐ Has it been tested with 3+ prompts?

If any answer is no, the skill needs work.
