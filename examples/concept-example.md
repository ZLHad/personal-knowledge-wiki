---
type: concept
domain: research
created: 2026-02-10
updated: 2026-04-01
sources:
  - "[[raw/research/papers/2026-02-10-clean-code-discussion.md]]"
  - "[[raw/research/notes/2026-03-15-refactoring-session.md]]"
tags: [programming, best-practices]
aliases: [DRY principle, Don't Repeat Yourself]
---
# DRY (Don't Repeat Yourself)

## Definition

DRY is a software development principle stating that every piece of knowledge should have a single, unambiguous, authoritative representation in a system. It's not just about code duplication — it's about **knowledge duplication**.

## Details

### What DRY Really Means

DRY is often misunderstood as "don't copy-paste code." The actual principle is broader:

- **Not DRY**: Two functions that happen to look similar but represent different business rules
- **Actually DRY violation**: The same business rule expressed in two different places (even if the code looks different)

### When to Apply

| Scenario | Apply DRY? | Why |
|----------|-----------|-----|
| Same business rule in 2 places | Yes | Single source of truth |
| Similar-looking utility functions | Maybe | Only if they evolve together |
| Test setup code | Carefully | Over-DRYing tests hurts readability |
| Configuration | Yes | Use environment variables / config files |

### The Rule of Three

Don't extract until you've seen the pattern **three times**. Premature abstraction (DRYing too early) creates coupling that's harder to fix than duplication.

## Common Pitfalls

| Scenario | Mistake | Correction |
|----------|---------|------------|
| Similar code blocks | Extract immediately after 2nd occurrence | Wait for 3rd occurrence (Rule of Three) |
| Test files | Share all setup via helpers | Keep tests self-contained; some duplication is OK |
| Microservices | Share models across services | Each service owns its models; duplication across boundaries is fine |

## Related

- [[Clean-Code]]
- [[SOLID-Principles]]
- [[Refactoring-Guide]]
