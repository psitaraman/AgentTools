# Phase 5: TDD Test Generation

**Participants:** Model B subagent (fresh context) — the evaluator defines acceptance criteria
**Context:** Subagent with fresh context. Inputs provided as files.
**Input:** BDD scenarios + feature's tech spec + external docs (MCP)
**Output:** `tests/` in the feature's directory, verified red, read-only to implementers

## What This Phase Produces

Test files that encode BDD behavioral contracts as executable tests across architecture layers. One BDD scenario maps to many TDD tests (ADR-008). Tests are verified to fail (red state) before implementation begins.

Model B writes the tests because the evaluator defines what "passing" looks like. Model A (generator) then implements against these criteria in Phase 6. This separation means different models with different biases set the bar vs try to meet it.

## The BDD-to-TDD Bridge

The feature's tech spec is the bridge between behavioral scenarios and testable classes. No intermediate mapping step is needed.

BDD scenario: "user enables push notifications and receives a confirmation."
Tech spec architecture:
- `NotificationSettingsView` (view layer)
- `NotificationViewModel` (state layer)
- `PushService` conforming to `NotificationProtocol` (network layer)
- `PreferencesStore` (persistence layer)

TDD output: tests for each class at each layer, verifying their piece of the behavior. The tech spec's design principles (e.g., "protocol-oriented with dependency injection") tell the generator how to structure the tests — inject mocks via protocols, test each layer in isolation.

## Layer Mapping (ADR-008)

For each BDD scenario, generate tests across the architecture layers defined in the feature's tech spec:

- **View layer:** UI renders correct state, user interactions trigger correct actions
- **State layer:** State machines transition correctly, computed properties derive correctly
- **Network layer:** API requests formed correctly, responses parsed correctly, errors handled
- **Persistence layer:** Data saved/loaded correctly, migrations work, cache invalidation

Not every scenario touches every layer. Map based on the tech spec's architecture.

## External Documentation

Reference real framework documentation via MCP (ADR-009). Use current API signatures, not remembered ones. The feature's tech spec includes research sources with MCP endpoints, URLs, and version numbers — pull the same docs.

## Red Verification

Every test must be verified to fail before implementation begins:
1. Generate all test files for a feature.
2. Run the test suite — all new tests must fail (red).
3. If any test passes without implementation, the test is wrong — it's not testing real behavior.
4. Record the red state as the baseline.

## Test File Isolation (ADR-005)

Test files become read-only to implementation agents starting in Phase 6 (implementation) — they remain writable to Model B during Phase 5 itself, since Model B is the author. Three layers of enforcement:

1. **Different model:** Model B writes tests, Model A implements. Different biases, different perspectives.
2. **File permissions:** `chmod a-w` on test files after tests are generated and verified red, at the end of Phase 5, before Phase 6 begins. Implementation agent cannot write to them.
3. **Post-hoc validation:** `check-phase.sh` verifies test files were not modified after each implementation step. If they changed, reject and revert.

Prompting alone is not enough. Models cheat on tests 46-76% of the time without architectural enforcement (ImpossibleBench).

## Test File Structure

```yaml
---
version: 1.0
built-from:
  - features/notifications/bdd/scenarios: v1.0
  - features/notifications/tech-spec: v1.0
  - external: APNs-documentation-v2
status: current
---
```

Test files live in the feature's `tests/` directory. One file per layer or per scenario — whatever makes sense for the feature's architecture.

## Done Signal

- Every BDD scenario has corresponding tests across relevant architecture layers
- All tests verified red (failing without implementation)
- Test files set to read-only (`chmod a-w`)
- External framework docs referenced via MCP, not from memory
- Test code files inherit their version from the `built-from` chain (BDD + tech-spec); any markdown artifacts produced in this phase (e.g., test-index manifests, if used) carry version frontmatter with dynamic `built-from`

## If Blocked

- BDD scenario is ambiguous → flag to human, reference specific scenario
- Tech spec doesn't define architecture for this feature → flag to human, cannot determine which classes to test
- External docs unavailable via MCP → flag to human, provide URLs as fallback
- Cannot verify red state (tests pass without implementation) → fix the test, not the implementation
