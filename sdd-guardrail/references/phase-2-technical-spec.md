# Phase 2: Technical Spec (Per Feature)

**Participants:** Human + Model A (co-creation)
**Context:** Current context
**Input:** Feature's product spec + any dependencies
**Output:** Feature's `tech-spec.md`

## What This Phase Produces

A technical specification describing HOW a feature will be built. Always platform-specific. Every feature gets a tech spec — the top-level feature's tech spec covers shared architecture and links to child feature tech specs.

Each feature's tech spec is the bridge between behavioral descriptions (BDD) and testable classes (TDD). It must be detailed enough that a TDD generator can read a BDD scenario and know exactly which classes to write tests for.

## Research Before Design

Before proposing architecture, Model A researches:

1. **Framework documentation** via MCP — current API signatures, not remembered ones. Without real docs, regressions increase 60% (ADR-009).
2. **Architecture and design patterns** — SOLID principles, dependency injection, protocol-oriented design, repository pattern, coordinator pattern, or whatever fits the platform and problem. The chosen patterns should be explicit in the spec, not implied.
3. **Platform conventions and standards** — platform-specific conventions (e.g., Apple HIG, Material Design), industry standards (OWASP for security, accessibility guidelines), coding standards for the language/framework.
4. **Current best practices** via web search — how the community currently solves this class of problem. What's recommended, what's deprecated, what's emerging.
5. **Existing libraries and tools** — what's available, what's maintained, what fits. No new dependencies without human approval.

Research informs the architecture proposal. The human reviews and refines.

## Co-Creation Process

1. Human and Model A review the feature's product spec.
2. Choose or confirm the target platform and technology stack.
3. Model A researches: pulls latest docs via MCP, searches for current best practices, checks relevant standards.
4. Model A proposes architecture informed by research.
5. Human and Model A refine together:
   - Classes/types and their responsibilities
   - Protocols and interfaces (contracts between layers)
   - Dependency relationships (who calls whom)
   - Layer mapping: view, state, network, persistence (ADR-008)
6. Identify shared infrastructure this feature depends on.

## Tech Spec Structure

```yaml
---
version: 1.0
built-from:
  - features/login/product-spec: v1.0
  - features/auth-shared/tech-spec: v2.1
  - external: Apple-Keychain-Services-docs
status: current
platform: [target platform]
---
```

`built-from` is a dynamic list — references whatever this spec was derived from.

- **Platform & Stack:** Target platform, language, frameworks, key dependencies.
- **Architecture:** Classes/types with responsibilities. How they connect.
- **Protocols & Interfaces:** Contracts between components. What each protocol requires.
- **Layer Mapping:** Which classes live at which layer:
  - View: UI components, rendering
  - State: view models, state machines, business logic
  - Network: API clients, request/response handling
  - Persistence: storage, caching, migrations
- **Design Principles:** Which architectural and design patterns apply and why. Be explicit — e.g., "SOLID with constructor injection via protocol conformance" or "MVVM with unidirectional data flow." This tells the TDD generator how classes should be structured and tested.
- **Dependency Graph:** Who calls whom. Direction of dependencies. Where injection points are.
- **Shared Infrastructure:** Components from other features this one uses.
- **Research Sources:** Documentation, standards, and best practices referenced during design. Include MCP endpoints, URLs, and version numbers so downstream phases can pull the same docs.

## Keyword Discipline for Protocol Specs (ADR-022)

When any section of the tech spec defines wire formats, state machines with external observability, cross-module API contracts, tool/interface schemas, or protocol error handling and retry semantics, apply RFC 2119 / RFC 8174 keyword discipline:

- Begin the in-scope section with the disambiguation statement: *"The key words MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY in this document are to be interpreted as described in RFC 2119 and RFC 8174 when, and only when, they appear in all capitals."*
- Use MUST / MUST NOT / SHOULD / SHOULD NOT / MAY only in their capitalized form. Lowercase versions carry no special meaning.
- Every MUST and SHOULD MUST be paired with a corresponding behavioral scenario in Phase 3 BDD (ADR-022, ADR-003). RFC 2119 defines conformance; BDD defines verification. Both required; neither substitutes.

Out of scope for keyword discipline: product specs, UX flows, feature descriptions, internal implementation details not crossing module boundaries, and operational documentation.

## File Header Requirement (ADR-023)

The tech spec MUST require that every source file produced in Phase 6 carry a structured short header (~15–30 lines) containing:

- **Purpose** — WHY this file exists, referencing the tech spec section it implements.
- **Public API** — enumerated list of exports; mechanically comparable to the file's actual exports.
- **Invariants / gotchas** — only when non-obvious.
- **Pointers** — to the governing tech spec section and BDD scenarios.

Model A generates headers alongside code in Phase 6; Model B verifies alignment in Phase 7. See ADR-023 for the full convention.

## Why This Detail Matters

BDD says "user adds item to cart and sees updated total." TDD needs to know which classes to test:
- `CartView` (view layer)
- `CartViewModel` (state layer)
- `CartService` (network layer)
- `CartStore` conforming to `PersistenceProtocol` (persistence layer)

This mapping comes from the tech spec. Without it, the TDD generator invents architecture, leading to inconsistent designs across features.

## Done Signal

- Feature's tech spec written with architecture, protocols, and layer mapping
- Design principles explicitly stated
- Research sources documented (MCP endpoints, URLs, versions)
- In-scope protocol sections carry the RFC 2119 disambiguation snippet (ADR-022)
- File header requirement stated for Phase 6 implementation (ADR-023)
- Human has reviewed and approved
- `built-from` references all dependencies

## If Blocked

- Unclear how to map feature to architecture → ask human
- External docs unavailable via MCP → flag, provide URLs as fallback
- Conflicting architectural approaches → flag to human with AI recommendations
- Feature depends on shared infrastructure that doesn't exist yet → flag the dependency
- Best practices conflict with project constraints → flag to human with AI recommendations
