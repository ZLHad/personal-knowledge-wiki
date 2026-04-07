---
name: wiki-lint
description: "Run a health check on your personal Wiki. Executes 8 hard-coded rule checks (dead links, orphan pages, frontmatter completeness, tag consistency, source traceability, index sync, file naming, stale detection) plus soft quality analysis (contradictions, missing cross-references, suggested new pages). Outputs a structured lint report. Trigger phrases: \"lint wiki\", \"check wiki\", \"wiki health check\", \"wiki diagnostics\"."
---

# Wiki Lint

## Core Function

Run a comprehensive health check on the wiki, output a structured report.

## Wiki Location

**Wiki path**: `{{WIKI_PATH}}`

## Prerequisites

1. Read `CLAUDE.md` for conventions
2. Read `wiki/index.md` for full catalog
3. Read `log.md` for recent operations

## Workflow

### Phase 1: Hard Rule Checks (must all pass)

Execute these 8 checks sequentially, recording pass/fail and specific issues:

#### Rule 1: Dead Link Detection
- Scan all .md files under wiki/
- Extract all `[[wikilink]]`
- Check each link points to a real existing .md file
- **Fail condition**: Link points to non-existent file

#### Rule 2: Orphan Page Detection
- Count inbound links for each wiki page (times linked by other pages)
- Links from `wiki/index.md` count
- **Fail condition**: Page has 0 inbound links (index.md itself exempt)

#### Rule 3: Frontmatter Completeness
- Every .md file under wiki/ (except index.md) must have YAML frontmatter
- Required fields: `type`, `domain`, `created`, `updated`, `sources`, `tags`, `aliases`
- **Fail condition**: Missing required field

#### Rule 4: Tag Consistency
- Extract all tags from frontmatter across all pages
- Compare against Approved Tags list in `CLAUDE.md`
- **Fail condition**: Tag not in approved list

#### Rule 5: Source Traceability
- Every entity/concept page's `sources:` field must have at least 1 entry
- Each source path must point to an existing file in `raw/`
- **Fail condition**: Empty sources, or source points to non-existent file

#### Rule 6: Index Sync
- Every page listed in `wiki/index.md` must actually exist
- Every wiki page (except index.md) must have an entry in index.md
- **Fail condition**: Index and actual files don't match

#### Rule 7: File Naming Convention
- entities/: `<name>.md`
- concepts/: `<name>.md`
- topics/: `<name>.md` (may be in subdirectory)
- syntheses/: `YYYY-MM-DD-<slug>.md`
- **Fail condition**: Filename doesn't match convention

#### Rule 8: Stale Detection
- Find pages where `updated:` date is more than 90 days ago
- If same domain has newer raw source files, flag as possibly outdated
- **Fail condition**: Possibly stale pages exist (warning level, non-blocking)

### Phase 2: Soft Quality Analysis (LLM judgment)

Read key page contents, check:

1. **Contradiction detection**: Two pages state the same fact differently
2. **Missing page suggestions**: Entities/concepts frequently mentioned in text but lacking their own page
3. **Missing cross-references**: Related pages not linked in each other's Related sections
4. **Thin pages**: Pages with < 10 lines of effective content
5. **Suggested new sources**: Based on existing knowledge, suggest material directions to explore

### Phase 3: Generate Report

Save report to `meta/reports/lint-YYYY-MM-DD.md`

**Report format:**

```markdown
---
type: lint-report
date: YYYY-MM-DD
---

# Wiki Lint Report - YYYY-MM-DD

## Summary

| Check | Status | Issues |
|-------|--------|--------|
| 1. Dead links | PASS/FAIL | N issues |
| 2. Orphan pages | PASS/FAIL | N issues |
| 3. Frontmatter | PASS/FAIL | N issues |
| 4. Tag consistency | PASS/FAIL | N issues |
| 5. Source traceability | PASS/FAIL | N issues |
| 6. Index sync | PASS/FAIL | N issues |
| 7. File naming | PASS/FAIL | N issues |
| 8. Stale detection | PASS/WARN | N warnings |

**Overall: X/8 passed, Y warnings**

## Hard Rule Details

### Rule 1: Dead Links
(specific issues, or "All clear")

(etc.)

## Soft Analysis

### Contradictions Found
- ...

### Suggested New Pages
- ...

### Missing Cross-References
- ...

### Thin Pages
- ...

## Recommended Actions

1. [Priority] Fix: ...
2. [Nice-to-have] ...
```

### Phase 4: Update Timeline

Append to `log.md`:
```markdown
## [YYYY-MM-DD] lint | Wiki health check

- Hard rules: X/8 passed, Y warnings
- Issues found: N (list key issues)
- Report: meta/reports/lint-YYYY-MM-DD.md
```

## Quick Mode

If user only wants a fast check, run hard rules only (Phase 1), skip soft analysis.

Trigger: user says "quick lint" or "hard rules only".

## Auto-Fix

For simple issues, offer auto-fix options:
- Dead links → offer to create missing page or remove link
- Index out of sync → auto-update index.md
- Missing frontmatter fields → auto-fill defaults
- Stale pages → list pages needing review

Ask user confirmation before each fix.

## Git Commit

After lint (whether fixes applied or not), execute git commit:
- Stage lint report and all fixed files
- Commit message format: `lint: <brief result>`
- Example: `lint: fix 3 dead links, add 2 missing entity pages`
- If no fixes, report only: `lint: clean report, 8/8 passed`
