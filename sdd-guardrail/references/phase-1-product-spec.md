# Phase 1: Product Spec

**Participants:** Human + Model A (co-creation)
**Context:** Current context
**Output:** Top-level `product-spec.md` + child feature `product-spec.md` files

## What This Phase Produces

Product specifications describing WHAT each feature does and WHY. Written in user experience terms.

Everything is a feature. The product itself is the top-level feature. Every feature has a product spec. Features can nest — a feature can have child features. The top-level product spec lists child features and links to their specs, PRDs, business documents, and anything else pertinent.

Features are dynamic — they can be added or removed over time. Dependencies between features are marked in the specs.

## Co-Creation Process

1. Human provides the product idea, goals, and constraints.
2. Model A asks clarifying questions — target audience, core value proposition, scope boundaries.
3. Together, identify distinct features. Each feature gets its own spec. Features may depend on other features and reference other feature specs.
4. For each feature, create a product spec in its feature directory.
5. Map dependencies between features and determine build order.

## Product Spec Structure

Top-level product spec:
```yaml
---
version: 1.0
built-from:
  - external: PRD-2026-Q2
  - external: market-research-user-interviews
status: current
---
```

Child feature product spec:
```yaml
---
version: 1.0
built-from:
  - product-spec: v1.0
  - features/auth/product-spec: v1.0
status: current
---
```

- **Overview:** What this feature does and why it matters.
- **Child Features:** List of child features with references to their specs (if any).
- **User Stories:** As a [user], I want [action], so that [value].
- **Acceptance Criteria:** High-level conditions for done. BDD will expand these into exhaustive scenarios later.
- **Dependencies:** Other features this one depends on.
- **External References:** Links to PRDs, business documents, market research, regulatory requirements, standards — anything pertinent.
- **Build Order:** Ordered list of child features based on dependencies and value (top-level only).
- **Out of Scope:** What this feature does NOT cover.
- **Constraints:** Technical, business, or regulatory constraints.

## Platform Scope

Product specs are platform-independent when the product spans platforms, platform-dependent when the product is inherently single-platform. Determined by the product, not the pipeline.

## Done Signal

- Top-level product spec written with child features listed and build order defined
- Each child feature has its own product spec
- Dependencies mapped between features
- Human has reviewed and approved

## If Blocked

- Ambiguity about scope → ask human
- Features too intertwined to spec separately → flag, propose how to restructure
- Conflicting requirements → flag to human with AI recommendations for resolution
