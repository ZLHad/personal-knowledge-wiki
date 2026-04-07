---
type: topic
domain: research
created: 2026-01-20
updated: 2026-03-25
sources:
  - "[[raw/research/papers/2026-01-20-code-review-practices.md]]"
  - "[[raw/research/notes/2026-03-10-team-retro-coding-standards.md]]"
tags: [programming, best-practices]
aliases: [Code Review Guide, Review Checklist]
---
# Code Review Best Practices

## Overview

A set of accumulated rules and patterns for conducting effective code reviews — both as a reviewer and as an author. These practices reduce review cycles, catch real bugs, and maintain team velocity.

## Rules & Patterns

### As a Reviewer

1. **Review in layers**: Read the PR description first, then file-by-file, then run the code mentally.
2. **Distinguish severity**: Use labels like `[blocking]`, `[suggestion]`, `[nit]` so the author knows what must be fixed.
3. **Ask, don't command**: "What happens if `users` is empty here?" works better than "Handle the empty case."
4. **Limit scope**: Review max 400 lines per session. Beyond that, accuracy drops sharply.
5. **Check the tests first**: If tests are solid, the implementation is likely sound.

### As an Author

1. **Self-review before requesting**: Read your own diff as if you were the reviewer.
2. **Keep PRs small**: One logical change per PR. Refactoring and feature work go in separate PRs.
3. **Write a good description**: Include *why* (not just *what*), link to the issue, and describe your test plan.
4. **Respond to every comment**: Even if it's just "Done" or "Won't fix because X."

### Anti-patterns

| Anti-pattern | Problem | Fix |
|-------------|---------|-----|
| Rubber-stamping | Approving without reading | Set minimum review time (10 min) |
| Bikeshedding | Arguing about style | Adopt a formatter (Prettier, Black) |
| Gatekeeping | Blocking for personal preference | Distinguish blocking vs. suggestion |
| Ghost reviews | Assigned but never reviewed | Set SLA (24h response time) |

## Examples

**Before (vague comment):**
> "This doesn't look right."

**After (actionable comment):**
> "[blocking] `fetchUser()` can return `null` when the user is deleted, but line 42 accesses `.name` without a null check. This will crash in production. Consider adding a guard: `if (!user) return notFound()`"

## Related

- [[DRY]]
- [[Clean-Code]]
- [[Git-Workflow]]
