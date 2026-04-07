---
type: synthesis
domain: cross-domain
created: 2026-03-15
updated: 2026-03-15
sources:
  - "[[wiki/concepts/DRY]]"
  - "[[wiki/topics/Code-Review-Best-Practices]]"
  - "[[wiki/entities/React]]"
  - "[[raw/research/notes/2026-03-12-state-management-debate.md]]"
tags: [architecture, decision-making]
aliases: []
---
# When to Abstract vs. When to Duplicate

## Question

In our codebase, we have three React components that share ~60% of their logic but serve different business domains (checkout, profile, admin). Should we extract a shared base component, or keep them separate?

## Analysis

Based on wiki knowledge, the answer is **keep them separate for now**, with a planned review at the next occurrence.

### Evidence from Wiki

1. **[[DRY]] — Rule of Three**: The DRY principle explicitly warns against premature abstraction. With only 3 occurrences, and given that they serve *different business domains*, extracting now creates **coupling across domain boundaries**.

2. **[[Code-Review-Best-Practices]] — Keep PRs Small**: A shared abstraction would require a large refactoring PR that touches all three domains simultaneously. This violates the "one logical change per PR" rule and increases review difficulty.

3. **[[React]] — Server Components**: With React 19 Server Components, the rendering model is shifting. Components that currently share client-side logic may diverge when some move to server-side rendering. Abstracting now may create technical debt.

### Decision Matrix

| Factor | Abstract | Duplicate |
|--------|----------|-----------|
| Current maintenance cost | Lower (fix once) | Higher (fix in 3 places) |
| Cross-domain coupling | High risk | None |
| Flexibility for divergence | Low | High |
| PR complexity | 1 large PR | No change needed |
| Future React 19 migration | Harder | Easier |

### Recommendation

- **Short-term**: Keep duplicated. Add a `// NOTE: similar logic in checkout/profile/admin` comment in each.
- **Trigger for revisiting**: If a 4th component needs the same logic, or if a bug fix needs to be applied to all 3 simultaneously, then extract.
- **Extraction strategy**: When ready, extract a **custom hook** (not a base component) to share logic without coupling UI.

## Related

- [[DRY]]
- [[React]]
- [[Code-Review-Best-Practices]]
- [[Refactoring-Guide]]
