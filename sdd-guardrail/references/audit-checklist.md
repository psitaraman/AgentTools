# Audit Checklist

The authoritative checklist for all audits in the pipeline — Phase 6 self-audit and level-by-level evaluation, Phase 7 branch review, Phase 8 trunk audit, Phase 9 final audit, audit-on-change, and post-conflict resolution. Every audit references this checklist.

## Checklist

### Correctness
- **Logical and reasoning** — does the code do what the spec says
- **Edge cases** — boundary conditions, empty states, concurrent access, race conditions
- **Error handling** — errors handled gracefully, not swallowed, not exposing internals

### Security and Compliance
- **Security** — injection, auth bypass, data exposure, insecure defaults, OWASP top 10
- **PII and data privacy** — GDPR, CCPA, data minimization, consent, right to deletion, data retention
- **Legal and regulatory compliance** — domain-specific requirements, licensing, terms of service

### Architecture and Design
- **Architectural consistency** — follows tech spec's patterns, SOLID, dependency direction
- **Design principles** — matches the explicit design principles stated in the tech spec
- **Testability** — is the code testable, are dependencies injectable
- **Maintainability** — readable, well-structured, future developers can understand and modify

### Quality Attributes
- **Performance** — algorithmic complexity, memory usage, unnecessary network calls, battery impact
- **Scalability** — handles growth in data, users, and load
- **Reliability** — consistent correct behavior under expected conditions
- **Fault tolerance** — graceful degradation under failure, recovery paths, retry strategies

### User Experience
- **Usability** — user-facing behavior matches product spec intent
- **Accessibility** — screen readers, keyboard navigation, color contrast, WCAG compliance

### Documentation Alignment (ADR-022, ADR-023)
- **BDD ↔ TDD coverage** — every BDD scenario has at least one TDD test covering it (ADR-008)
- **File header ↔ code** — Public API list in each file's header matches actual exports (mechanical check); Purpose line captures WHY the file exists and still applies to the code as written — not a restatement of behavior (ADR-023)
- **Header WHY ↔ spec WHY** — file header Purpose and Invariants do not contradict the governing tech spec section (ADR-023)
- **RFC 2119 disambiguation snippet** — in-scope protocol specs begin with the disambiguation statement (ADR-022)
- **MUST/SHOULD → BDD pairing** — every MUST and SHOULD in in-scope tech specs has a paired behavioral scenario in BDD (ADR-022)

## Audit Scripts and Tools

Scripts and tools to automate parts of the audit. Executed by the harness — only output enters context.

### Static Analysis
- **Linter** — run the platform's linter (SwiftLint, ESLint, Clippy, etc.). Zero warnings policy.
- **Type checker** — run the type checker if the language has one. Zero errors.
- **Dependency audit** — check for known vulnerabilities in dependencies (`npm audit`, `cargo audit`, `pip audit`, etc.).

### Security Scanning
- **SAST (Static Application Security Testing)** — run a static security scanner (Semgrep, Bandit, Brakeman, etc.) against new/changed code.
- **Secrets detection** — scan for hardcoded secrets, API keys, credentials (trufflehog, gitleaks, etc.).
- **PII detection** — scan for patterns that look like PII being logged, stored unencrypted, or transmitted insecurely.

### Test Verification
- **Test coverage** — measure coverage of new/changed code. Not a target number — use judgment on whether critical paths are covered.
- **Test file integrity** — compare test files against Phase 5 baseline by modification time (`find -newer`). Any file newer than baseline → reject. (Content-hash diff is a future enhancement.)
- **Red-green verification** — the harness (or reviewer) confirms tests were red at Phase 5 baseline and green at Phase 6 exit. Not enforced by `check-phase.sh`.

### Accessibility
- **Automated accessibility audit** — run platform accessibility tools (axe, Accessibility Inspector, etc.) against UI components.

### Performance
- **Static performance checks** — flag O(n²) or worse algorithms, unbounded allocations, synchronous network calls on main thread.

## How to Use

### During Phase 6 (Implementation)
1. Model A self-audits against the full checklist after implementing.
2. Model A runs applicable audit scripts and includes output in self-audit report.
3. Model B reviews the script output from Model A's audit.
4. Model B independently evaluates the judgment-based checklist items (architecture, design, usability, scalability, fault tolerance, etc.) — this is where independent perspective adds value.

### During Phase 7 (Branch Review)
1. Model B walks evaluation checklists (from Phase 4) item by item.
2. Model B evaluates against the full audit checklist.
3. All findings tagged with severity and scope per `references/severity-classification.md`.

### During Phase 8 (Trunk Audit)
1. Model B runs the full checklist against the merged trunk.
2. All audit scripts run against the full codebase, not just the merged feature.
3. Findings tagged with severity only (no scope tagging).

### During Phase 9 (Final Audit)
1. Both Model A and Model B independently run the full checklist.
2. Both walk all evaluation checklists.
3. Both run all audit scripts.
4. Findings tagged with severity only (no scope tagging).
5. Results compared — disagreements go to human.

### On Spec/Test Change
1. Both models audit the changed document against applicable checklist items.
2. Security and compliance items always apply to spec changes.
3. Downstream staleness flagged per document-hierarchy.md.

### After Conflict Resolution
1. Both models audit the resolved specs against the full checklist.
2. If audit passes → resume pipeline.
3. If audit finds new issues → iterate with human.

## Adding New Checks

As the project evolves, add new checklist items or audit scripts here. Audits pick up additions when agents re-read this file at each phase — update once, and reviewers load the current version on their next run. This is propagation by reference, not by push: the harness does not notify running agents of changes.
