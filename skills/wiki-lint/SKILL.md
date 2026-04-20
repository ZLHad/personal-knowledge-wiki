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

1. Read `CLAUDE.md` for conventions, **paying special attention to the "Lint Exempt List" section** if present (e.g. `wiki/dashboard.md` is a common Obsidian-only homepage that should be exempt from Rule 2/3)
2. Read `wiki/index.md` for full catalog
3. Read `log.md` for recent operations

## Wikilink Parsing — Critical Constraint

**Before running any regex match for `[[...]]`, you MUST pre-process the text by stripping FOUR syntactic regions** (otherwise you will get many false positives):

1. **Fenced code blocks**: remove everything wrapped in ```` ``` ... ``` ```` (with or without a language tag, multi-line)
2. **Display math blocks**: remove everything wrapped in `$$ ... $$` (multi-line)
3. **Inline code spans**: remove everything wrapped in `` `...` `` (single-line per CommonMark)
4. **Inline math**: remove everything wrapped in `$ ... $` (single-line)
5. **Only then run the regex**: `re.findall(r"\[\[([^\]|#]+)(?:\|[^\]]*)?\]\]", cleaned_text)`

**Why each region matters**:

- **Inline code span** — pages explaining Wikilink syntax contain snippets like `` `[[double-bracket-link]]` ``. These are documentation examples, not real links. Field case (2026-04-11): `wiki/entities/Obsidian.md`.
- **Display math `$$...$$`** — paper notes may include `$$ Q = [[-24.6626, -20.4354]] $$` showing a Python array / matrix in LaTeX. The `[[...]]` is math notation, not a link. Field case (2026-04-11): `wiki/papers/huang2024-ChatNet.md:1435`.
- **Inline math `$...$`** — short expressions like `$[a,b]$` (rare but possible) should also be stripped defensively.
- **Fenced code block** — code examples may contain any `[[x]]` (Python nested lists, Haskell lists, etc.).

**Reference Python implementation** (recommended to reuse verbatim):
```python
import re

def strip_noise(text):
    """Strip all syntactic regions that could contain fake wikilinks."""
    # 1. fenced code blocks (triple backticks, multi-line)
    text = re.sub(r"```[\s\S]*?```", "", text)
    # 2. display math blocks ($$...$$, multi-line)
    text = re.sub(r"\$\$[\s\S]*?\$\$", "", text)
    # 3. inline code spans (single backticks, single-line per CommonMark)
    text = re.sub(r"`[^`\n]*`", "", text)
    # 4. inline math ($...$, single-line)
    text = re.sub(r"\$[^\$\n]+\$", "", text)
    return text

def extract_wikilinks(text):
    cleaned = strip_noise(text)
    return re.findall(r"\[\[([^\]|#]+)(?:\|[^\]]*)?\]\]", cleaned)
```

**Both Rule 1 (dead links) and Rule 2 (inbound-link counting) must use `strip_noise()`-cleaned text**, or fake links will simultaneously produce false dead-link reports and inflated inbound counts.

**Version history**:
- v1 (before 2026-04-11): stripped only code spans
- v2 (2026-04-11 Phase 1): added display math + inline math stripping. Function renamed from `strip_code` to `strip_noise` to reflect broader coverage.

## Workflow

### Phase 1: Hard Rule Checks (must all pass)

Execute these 8 checks sequentially, recording pass/fail and specific issues:

#### Rule 1: Dead Link Detection
- Scan all .md files under wiki/
- For each file, first apply `strip_noise()` (see "Wikilink Parsing — Critical Constraint" above — strips fenced code + inline code span + `$$...$$` display math + `$...$` inline math), then extract `[[wikilink]]`
- Check each link points to a real existing .md file (match by stem; support both `folder/page` and plain `page` forms)
- `[[raw/...]]` form links additionally verify the corresponding raw file exists
- **Fail condition**: Link points to non-existent file (excluding fake links inside code spans)

#### Rule 2: Orphan Page Detection
- Count inbound links for each wiki page (times linked by other pages, **using cleaned text**)
- Links from `wiki/index.md` count
- **Exempt**: files listed in `CLAUDE.md`'s "Lint Exempt List" section (typically `wiki/index.md` and any Obsidian-only homepage like `wiki/dashboard.md`)
- **Fail condition**: Page has 0 inbound links (exempt files excluded)

#### Rule 3: Frontmatter Completeness
- Every .md file under wiki/ must have YAML frontmatter
- Required fields: `type`, `domain`, `created`, `updated`, `sources`, `tags`, `aliases`
- **Exempt**: files listed in `CLAUDE.md`'s "Lint Exempt List" section (typically `wiki/index.md` and any Obsidian-only homepage like `wiki/dashboard.md`)
- **Fail condition**: Missing required field (exempt files excluded)

#### Rule 4: Tag Consistency
- Extract all tags from frontmatter across all pages
- Compare against Approved Tags list in `CLAUDE.md`
- **Fail condition**: Tag not in approved list

#### Rule 5: Source Traceability
- Every entity/concept page's `sources:` field must have at least 1 entry
- Each source path must point to an existing file in `raw/`
- **Scope / implicit exemption**: this rule only scans `wiki/entities/` and `wiki/concepts/` subdirectories. Pages under `wiki/topics/`, `wiki/syntheses/`, as well as `wiki/index.md` and any Obsidian-only homepage, are naturally out of scope.
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

## Auto-Fix Mode

**Trigger**: user says "lint + fix", "auto-fix", "lint and repair", or after a regular lint produces issues and user says "go ahead and fix them".

### Workflow

1. **Scan**: run all 8 hard rules, classify issues into **auto-fixable** (safe to fix) vs **human-required** (needs user judgment)
2. **Present manifest**: list each issue, proposed fix, confidence level (LOW/MEDIUM/HIGH need-to-confirm)
3. **Ask user in one shot**: user replies "fix all" / "fix 1,2,5" / "skip" / "change 3 to X"
4. **Execute + verify**: apply Edit operations per user instruction; re-run lint to confirm 0 issues
5. **Report**: before/after diff summary + new lint report

### Auto-fixable issue categories

| Issue type | Auto-fix strategy | Confirm level |
|---|---|---|
| **Rule 6 index unsynced**: page missing from index.md | Auto-append to matching table in index.md using page frontmatter description | LOW (almost always correct) |
| **Rule 6 index unsynced**: index row points to non-existent file | Remove the row | MEDIUM (could be a typo — show) |
| **Rule 3 frontmatter missing**: common fields like `aliases: []`, `tags: []` | Add with empty-list default | LOW |
| **Rule 3 frontmatter missing**: missing `updated:` | Fill with today's date | LOW |
| **Rule 4 tag violation**: tag is close to an approved list item (e.g. `工具` vs `工具与工作流`) | Propose the closest approved replacement | MEDIUM (show before/after) |
| **Rule 1 dead link**: stem is very close to an existing page (spelling diff) | Propose nearest-neighbor stem | MEDIUM |

### Issues that MUST require human judgment (never auto)

| Issue type | Why not auto-fixable |
|---|---|
| **Rule 1 dead link** to a truly-nonexistent page | user must decide: create new page vs delete reference vs link to another existing page |
| **Rule 2 orphan page** | user must decide: add to which other pages' Related / add to index / delete |
| **Rule 4 tag violation**: completely new word | user must decide: add to approved list vs switch term |
| **Rule 5 sources empty** | user must identify which source belongs |
| **Rule 8 stale** (>90 days) | content freshness requires user judgment |

### Display format (before user confirms)

```markdown
## Lint found N auto-fixable + M need-human

### Auto-fixable (N)
| # | File | Issue | Proposed fix | Confirm |
|---|---|---|---|---|
| 1 | wiki/entities/X.md | missing from index.md | append to ## Entities | LOW |
| 2 | wiki/papers/y.md | tag "论文" not in approved list | replace with `论文笔记` | MEDIUM |
| ... |

### Need-human (M)
| # | File | Issue | Options |
|---|---|---|---|
| 1 | wiki/papers/z.md references [[UnknownConcept]] | dead link | (a) create [[UnknownConcept]] / (b) delete reference / (c) point to [[RelatedConcept]] |
| ...

Please instruct:
- "fix all" — apply all LOW fixes (MEDIUM still shown for before/after approval)
- "1,2,5" — selective
- "change 0 to xxx" — custom instruction
- "skip" — produce lint report only
```

**Every MEDIUM-confirm fix shows before/after before executing**. LOW-confirm fixes batch-apply without per-item confirmation (but are all listed in the manifest above).

## Git Commit

After lint (whether fixes applied or not), execute git commit:
- Stage lint report and all fixed files
- Commit message format: `lint: <brief result>`
- Example: `lint: fix 3 dead links, add 2 missing entity pages`
- If no fixes, report only: `lint: clean report, 8/8 passed`
