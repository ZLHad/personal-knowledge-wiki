# Personal Knowledge Wiki — Schema

This is a personal knowledge base maintained by LLM (Claude Code). The human curates sources, asks questions, and directs analysis. The LLM does all bookkeeping — summarizing, cross-referencing, filing, and maintenance.

---

## Architecture

```
{{WIKI_NAME}}/
├── CLAUDE.md              # THIS FILE — schema & rules
├── README.md              # Human-readable project description
├── log.md                 # Append-only timeline
│
├── raw/                   # Layer 1: Raw sources (IMMUTABLE)
│   ├── {{DOMAIN_1}}/      # e.g. research/, work/, study/
│   │   ├── {{SUB_1}}/     # e.g. papers/, notes/
│   │   └── {{SUB_2}}/
│   ├── {{DOMAIN_2}}/      # e.g. reading/
│   ├── {{DOMAIN_3}}/      # e.g. life/
│   └── assets/            # Images, PDFs, attachments
│
├── wiki/                  # Layer 2: LLM-maintained wiki (MUTABLE)
│   ├── index.md           # Master catalog of all wiki pages
│   ├── entities/          # Entity pages (people, journals, projects, tools)
│   ├── concepts/          # Concept pages (methods, theories, terms)
│   ├── topics/            # Topic pages (guides, norms, best practices)
│   └── syntheses/         # Filed query answers, comparisons, analyses
│
└── meta/                  # Reports & diagnostics
    └── reports/
```

## Layer Semantics

### raw/ — Source of Truth (Read-Only)

- **NEVER modify files in raw/.** They are immutable once ingested.
- Sources include: conversation extracts, articles, papers, book notes, clipped web pages.
- File naming: `YYYY-MM-DD-<slug>.md` (e.g. `2026-03-28-system-model-revision.md`)
- Images and attachments go in `raw/assets/`, referenced by relative path.

### wiki/ — Compiled Knowledge (LLM-Owned)

- The LLM creates, updates, and deletes wiki pages freely.
- Every wiki page represents **compiled truth** — the latest understanding, not a historical record.
- When new information contradicts old content, **overwrite** the old content (don't append).
- Historical record lives in `raw/` and `log.md`, not in wiki pages.
- Use `[[wikilinks]]` for all cross-references between wiki pages.

### log.md — Timeline (Append-Only)

- **NEVER delete or modify existing entries.** Only append new ones.
- Format: `## [YYYY-MM-DD] <operation> | <title>`
- Operations: `ingest`, `query`, `lint`, `update`, `migrate`
- Each entry: 2-5 bullet points summarizing what happened.

---

## Page Formats

### Required YAML Frontmatter

Every wiki page MUST have this frontmatter:

```yaml
---
type: entity | concept | topic | synthesis
domain: {{DOMAIN_1}} | {{DOMAIN_2}} | {{DOMAIN_3}} | cross-domain
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources:
  - "[[raw/path/to/source.md]]"
tags: [tag1, tag2]
aliases: []           # Alternative names for this entity/concept
---
```

### Entity Pages (`wiki/entities/`)

Entities are specific, named things: people, journals, conferences, projects, tools.

**File naming:** `<name>.md` (e.g. `React.md`, `Zotero.md`)

**Structure:**
```markdown
---
(frontmatter)
---
# <Entity Name>

## Overview
One-paragraph description.

## Key Facts
- Bullet points of important attributes.

## Notes
Accumulated observations, preferences, patterns related to this entity.

## Related
- [[other-entity]]
- [[some-concept]]
```

### Concept Pages (`wiki/concepts/`)

Concepts are ideas, methods, theories, terms, patterns.

**File naming:** `<concept-name>.md`

**Structure:**
```markdown
---
(frontmatter)
---
# <Concept Name>

## Definition
Clear, concise definition.

## Details
Elaboration, nuances, how it applies in the user's work.

## Common Pitfalls
Mistakes or misunderstandings encountered (with corrections).

## Related
- [[other-concept]]
- [[some-entity]]
```

### Topic Pages (`wiki/topics/`)

Topics are guides, norms, accumulated best practices.

**File naming:** `<topic-name>.md`

**Structure:**
```markdown
---
(frontmatter)
---
# <Topic Title>

## Overview
What this topic covers and why it matters.

## Rules & Patterns
Numbered or bulleted rules with examples.

## Examples
Before/after pairs or illustrative cases.

## Related
- [[other-topic]]
- [[some-concept]]
```

### Synthesis Pages (`wiki/syntheses/`)

Syntheses are filed answers to queries, comparisons, analyses.

**File naming:** `YYYY-MM-DD-<slug>.md`

**Structure:**
```markdown
---
(frontmatter)
---
# <Title>

## Question
The question or prompt that led to this synthesis.

## Analysis
The answer, with citations to wiki pages and raw sources.

## Related
- [[links]]
```

---

## Operations

### 1. Ingest

Triggered when the user adds a new source to `raw/` or asks to extract knowledge from a conversation.

**Depth Levels:**

| Level | Use Case | Extraction Depth |
|-------|----------|-----------------|
| `shallow` | Quick indexing, minimal sources | Definition + brief Details |
| `deep` (default) | Paper notes, technical docs | Full system models, formula derivations, algorithm flows |
| `exhaustive` | Core reference papers, deep reads | Section-by-section extraction, code examples, experiment data tables |

Default is `deep`. Users can specify via parameter (e.g. `/ingest --depth shallow`). For batch processing, confirm depth level before starting.

**Domain-Specific Extraction Checklists:**

Apply the corresponding checklist based on the source file's domain to avoid missing key information:

#### Research Papers
```
□ System model (variable definitions + objective function + constraints)
□ Core formulas (full derivation chain, not just conclusions)
□ Algorithm flow (pseudocode or step-by-step breakdown)
□ Innovation points and baseline comparisons
□ Experiment results (key data tables, comparison metrics)
□ Method comparisons (if multi-method comparison tables exist)
```

#### Writing / Style Guides
```
□ Writing rules/patterns (reusable rules)
□ Before/after comparisons
□ Style preferences and habits
□ Error examples with corrections
```

#### Tools & Workflows
```
□ Configuration steps (commands or settings)
□ Usage tips (non-obvious techniques)
□ Common problems and solutions
```

**Workflow:**
1. Read the source material thoroughly.
2. Discuss key takeaways with the user (unless batch mode).
3. Write/update the source file in `raw/<domain>/` (if not already there).
4. **Verify raw record**: Output file size verification (confirm complete copy).
5. **Identify entities** mentioned → create or update `wiki/entities/*.md`.
6. **Identify concepts** mentioned → create or update `wiki/concepts/*.md`.
7. **Apply domain checklist**: Check extraction checklist items per source domain, ensure key information is covered.
8. **Update topic pages** if the source contributes new rules/patterns → `wiki/topics/*.md`.
9. **Update `wiki/index.md`** — add new pages, update summaries.
10. **Append to `log.md`** — record what was ingested and what pages were touched.
11. **Add `[[wikilinks]]`** in all touched pages to cross-reference related pages.

**Batch Ingest (3+ files):**
- After processing files 1-2, **pause** — show wiki page samples, let user confirm depth is satisfactory
- After confirmation, choose processing mode:
  - **≤ 5 files**: Sequential processing, checkpoint every 3 files
  - **> 5 files**: Parallel processing via sub-Agents (see wiki-ingest/wiki-migrate skill files for details)
- Parallel mode: group files by wiki page dependencies, launch sub-Agents per group, merge results at the end
- After completion, output raw file verification summary

**Rules:**
- A single ingest should touch **5-15 wiki pages** on average.
- When updating an entity/concept page, **overwrite stale content** rather than appending.
- Always update the `updated:` date in frontmatter of touched pages.
- Always update `sources:` in frontmatter to include the new raw source.

### 2. Query

Triggered when the user asks a question about their knowledge base.

**Workflow:**
1. Read `wiki/index.md` to find relevant pages.
2. Read the relevant wiki pages.
3. Synthesize an answer with `[[wikilink]]` citations.
4. Ask the user: "Should I file this as a synthesis page?"
5. If yes → create `wiki/syntheses/YYYY-MM-DD-<slug>.md`, update index, append log.

### 3. Lint

Triggered by the user or periodically as maintenance.

**Lint Exempt List** (files intentionally excluded from all hard rules):
- `wiki/index.md` — the catalog itself; exempt from Rule 2 (orphan) and Rule 3 (frontmatter), but still scanned by Rule 1 (dead links).
- *(optional)* `wiki/dashboard.md` — if you keep an Obsidian Dataview homepage at this path, add it here so lint doesn't nag. Such pages should also be in your static-site generator's `ignorePatterns` (e.g. Quartz).

Add your own exempt files below as needed. Keep the list short — every exemption is a place where lint can no longer catch regressions.

**Lint script hard requirements** (any script implementing these rules must):

Before regex-matching `[[...]]`, scripts MUST strip the following **4 syntactic regions** (otherwise expect many false positives):

1. **Fenced code blocks** (multi-line ``` ``` ```) — code examples contain `[[...]]` literals (nested Python lists, etc.)
2. **Display math `$$...$$`** (multi-line LaTeX) — paper notes may contain `$$ Q = [[-24.6626, -20.4354]] $$` which is a Python array in math, not a wikilink. (2026-04-11 field case.)
3. **Inline code spans `` `...` ``** (single-line, per CommonMark) — pages explaining Wikilink syntax use snippets like `` `[[double-bracket-link]]` `` that are docs, not links.
4. **Inline math `$...$`** (single-line LaTeX) — short expressions like `$[a,b]$` should be stripped defensively.

See `skills/wiki-lint/SKILL.md` for reference Python implementation (`strip_noise()`).

**Hard Rules (must all pass):**
1. **Dead links**: Every `[[wikilink]]` must point to an existing file.
2. **Orphan pages**: Every wiki page must have at least 1 inbound `[[wikilink]]` from another page (index.md counts).
3. **Frontmatter completeness**: Every wiki page must have all required frontmatter fields.
4. **Tag consistency**: Tags used in frontmatter must be from the approved tag list (see below).
5. **Source traceability**: Every entity/concept page must list at least 1 source in frontmatter.
6. **Index sync**: Every wiki page must appear in `wiki/index.md`; every entry in index must point to an existing file.
7. **File naming**: Files must follow the naming conventions defined above.
8. **Stale detection**: Flag pages where `updated:` is older than 90 days and newer raw sources exist in the same domain.

**Soft Checks (LLM judgment):**
- Contradictions between pages.
- Concepts mentioned in text but lacking their own page.
- Pages that could benefit from more cross-references.
- Suggested new sources to investigate.

**Output:** A lint report saved to `meta/reports/lint-YYYY-MM-DD.md`.

---

## Approved Tags

Tags are hierarchical. Use the most specific applicable tag.

### Domain Tags
{{DOMAIN_TAGS}}

### Sub-tags
{{SUB_TAGS}}

### Tool Tags
{{TOOL_TAGS}}

New tags may be added, but must be documented here first.

---

## Wikilink Conventions

- Use `[[page-name]]` format (Obsidian-compatible, shortest path match).
- For display text: `[[page-name|display text]]`.
- Every page's `## Related` section must contain at least 1 wikilink.
- When mentioning an entity or concept in running text, link it on **first mention** in each page.
- Do NOT link the same target more than once per section.

---

## Git Conventions

- Commit after every ingest or lint operation.
- Commit message format: `<operation>: <brief description>`
  - e.g. `ingest: system-model-revision conversation extract`
  - e.g. `lint: fix 3 dead links, add 2 missing entity pages`
  - e.g. `query: filed synthesis on common review comments`

---

## Future Extensions

This schema will evolve. Planned additions:
- [ ] Multi-domain expansion
- [ ] Dataview queries via YAML frontmatter
- [ ] Search integration
- [ ] Automated ingest via hooks
