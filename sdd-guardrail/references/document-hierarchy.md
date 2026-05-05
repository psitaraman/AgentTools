# Document Hierarchy and Version Pinning

Everything is a feature. The product itself is the top-level feature. Every feature has a product spec (WHAT/WHY) and a tech spec (HOW). Features can nest — a feature can have child features. Dependencies between features are dynamic and marked in the specs.

## Hierarchy

```
my-product/ (top-level feature)
  ├── product-spec.md
  ├── tech-spec.md
  ├── features/login/
  │     ├── product-spec.md
  │     ├── tech-spec.md
  │     ├── bdd/
  │     └── tests/
  ├── features/dashboard/ (depends-on: login)
  │     ├── product-spec.md
  │     ├── tech-spec.md
  │     ├── bdd/
  │     └── tests/
  └── features/settings/
        ├── product-spec.md
        ├── tech-spec.md
        └── ...
```

- **Product spec** describes a feature's WHAT/WHY. Links to child feature specs, PRDs, business documents, external references — anything pertinent.
- **Tech spec** describes a feature's HOW. Links to child feature tech specs, external technical documentation, architecture decisions, standards.
- **Evaluation checklists** (Phase 4) are derived from product specs, tech specs, and BDD scenarios. They have their own `built-from` version pinning.
- **BDD scenarios** derive from the feature's product spec and tech spec.
- **Tests** derive from BDD scenarios and the feature's tech spec.

## Reusability

All artifacts should be reusable when possible while achieving the goals. In cross-platform projects:
- Product specs and core BDD scenarios are written once and reused across platforms.
- Tech specs, platform-specific BDD additions, tests, and implementation are per-platform.

In single-platform projects, the entire chain is platform-specific. The pipeline structure stays the same — reusability is a benefit when it applies, not a constraint.

## Version Frontmatter

Every pipeline document includes:

```yaml
---
version: X.Y
built-from:
  - features/login/product-spec: v1.0
  - features/auth-shared/tech-spec: v2.1
  - external: RFC-6749-OAuth2
status: current | stale | draft
---
```

`built-from` is a dynamic list. It references whatever this document was derived from — other feature specs, external docs, standards, anything. No rigid template.

## Version Numbering

- **Major (X):** Feature added/removed, fundamental behavior changed.
- **Minor (.Y):** Wording clarified, edge case added, typo fixed.

## Staleness Rules

1. When a document's version increments, downstream documents referencing it in `built-from` are flagged `status: stale`.
2. Stale documents must be regenerated before use as inputs.
3. The pipeline blocks on stale inputs — escalates via BLOCKED protocol.
4. Version bumps propagate downstream only.

## Conflicts

Any conflict at any level — between specs, between a spec and its dependencies, between features — is flagged to the human with AI recommendations for resolution. Resolved iteratively with AI assistance using external resources.

## Audit on Change

When any spec or test is updated, both Model A and Model B audit the change against the full audit checklist (see `references/audit-checklist.md`). If issues are found, they are flagged to the human for collaborative resolution with AI assistance.

## Staleness Check

Before each phase, `check-phase.sh` verifies:
1. All required input documents exist.
2. No input has `status: stale`.

`built-from` version comparison against current upstream versions is a harness or human responsibility — `check-phase.sh` does not parse or validate `built-from` chains. When an upstream document's version increments, the harness (or author) is responsible for marking affected downstream documents `status: stale` per the rules above; the script then catches the stale flag.
