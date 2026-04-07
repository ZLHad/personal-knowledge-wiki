---
name: wiki-migrate
description: "Batch migrate existing notes into your personal Wiki. Scans a directory of markdown files, classifies each into the wiki architecture, and bulk-creates raw records + wiki pages with cross-references. Designed for first-time setup or importing from other note systems (Notion, Obsidian, Roam, plain markdown). Trigger phrases: \"migrate notes\", \"import notes\", \"batch import\", \"migrate from Notion\", \"import existing notes\", \"bulk ingest\"."
---

# Wiki Migrate

## Core Function

Batch-import existing markdown notes into the wiki. Unlike single-file **ingest** (which is interactive and detailed), **migrate** is designed for bulk operations — scanning directories, auto-classifying content, and creating wiki pages in batch with minimal user interaction per file.

## Wiki Location

**Wiki path**: `{{WIKI_PATH}}`

## Prerequisites

1. Read `CLAUDE.md` — understand architecture, approved tags, page formats
2. Read `wiki/index.md` — know existing pages to avoid duplicates
3. Read `log.md` — know recent operations

## When to Use Migrate vs. Ingest

| Scenario | Use |
|----------|-----|
| Import 10+ files from another system | **migrate** |
| First-time wiki setup with existing notes | **migrate** |
| Single conversation or file | **ingest** |
| A few files needing deep analysis | **ingest** |

## Workflow

### Step 1: Source Discovery

Ask the user for the source directory or files:
- "Which directory should I scan?" or "Which files to import?"
- Optionally: "Should I scan subdirectories recursively?"

Then scan and present a summary:
```
Found 23 markdown files in /path/to/source/
  - 8 files in papers/
  - 6 files in notes/
  - 5 files in tools/
  - 4 files in misc/

Proceed with migration? (y/n)
```

### Step 2: Classification

For each file, quickly determine:

1. **Domain**: Which `raw/<domain>/` directory does it belong to?
2. **Sub-category**: Which sub-category under the domain?
3. **Content type**: What kind of knowledge does it contain?
4. **Wiki page candidates**: What entities/concepts/topics can be extracted?

**Classification strategy:**
- Read file title, frontmatter (if any), and first 20 lines
- Match keywords against existing domains in CLAUDE.md
- Group similar files for batch processing

Present classification plan to user for approval:
```
## Migration Plan

| # | File | → Domain | → Type | Wiki Pages |
|---|------|----------|--------|------------|
| 1 | react-hooks.md | programming/notes | entity+concept | React, Hooks |
| 2 | api-design.md | programming/tools | topic | API-Design-Guide |
| 3 | meeting-2026-01.md | work/meetings | entity | Project-X |
| ... | | | | |

Approve? (y/n, or specify changes)
```

### Step 3: Batch Processing

For each file in the approved plan:

#### 3.1 Create Raw Record
- Copy/move file to `raw/<domain>/<sub-category>/`
- Rename to follow `YYYY-MM-DD-<slug>.md` convention if needed
  - Use file modification date if no date in filename
  - Use file creation date as fallback
- Add YAML frontmatter if missing
- **NEVER modify the original content** — raw files are immutable

#### 3.2 Extract Wiki Pages (Lightweight Mode)
- For each file, extract **key entities and concepts only**
- Create new wiki pages or append to existing ones
- Use lightweight extraction (shorter than full ingest):
  - Entity pages: Overview + Key Facts (skip detailed Notes)
  - Concept pages: Definition + brief Details (skip Common Pitfalls unless obvious)
  - Topic pages: Only create if file IS a topic guide; don't extract topic fragments

#### 3.3 Weave Wikilinks
- Add `[[wikilinks]]` in all new/updated pages
- Cross-reference related pages found during migration
- Build `## Related` sections

### Step 4: Update Index & Timeline

#### Update `wiki/index.md`
- Batch-add all new pages to corresponding tables
- Update Statistics at bottom

#### Append `log.md`
```markdown
## [YYYY-MM-DD] migrate | Batch import from <source>

- Source: <source directory or description>
- Files processed: N
- New raw records: N
- New wiki pages: X entities, Y concepts, Z topics
- Updated wiki pages: W
- Key domains: domain1, domain2
```

### Step 5: Migration Report

Output a summary report:

```
## Migration Complete

**Source**: /path/to/source/
**Files processed**: 23
**Raw records created**: 23

### New Wiki Pages (18)
- Entities (7): [[React]], [[Next.js]], [[PostgreSQL]], ...
- Concepts (6): [[REST-API]], [[OAuth2]], [[Hooks]], ...
- Topics (5): [[API-Design-Guide]], [[Database-Indexing]], ...

### Updated Wiki Pages (4)
- [[TypeScript]] — added 3 new facts
- [[Git-Workflow]] — added branching strategy

### Skipped Files (2)
- empty-file.md — no content
- binary-data.md — not a markdown file

### Recommended Follow-ups
1. Run `lint wiki` to check for dead links and orphan pages
2. These pages need more detail (consider full ingest):
   - [[OAuth2]] — only has definition, no examples
   - [[PostgreSQL]] — minimal notes
```

## Special Scenarios

### Migrating from Notion
- Notion exports include UUID-based filenames — rename to slugs
- Notion uses `/` for sub-pages — flatten to wiki structure
- Notion databases → may become topic pages with tables
- Handle Notion-specific markdown (callouts, toggles)

### Migrating from Obsidian
- Wikilinks are already compatible — preserve them
- Check for broken links after migration (paths may change)
- Migrate tags from `#tag` format to YAML frontmatter `tags: []`
- Copy attachments to `raw/assets/`

### Migrating from Roam Research
- Convert `[[page references]]` to wiki format (usually compatible)
- Daily notes → group by topic, not by date
- Block references → expand inline

### Duplicate Detection
- Before creating a wiki page, check if one with same or similar name exists
- If duplicate found: merge content into existing page, don't create new
- Use `aliases:` field to capture alternative names

### Handling Non-Markdown Files
- PDFs → create a wiki entity page referencing the PDF path
- Images → copy to `raw/assets/`, reference in relevant wiki pages
- Skip binary files, warn user

## Quality Check

After migration, verify:
- [ ] All raw records have proper `YYYY-MM-DD-<slug>.md` naming
- [ ] All new wiki pages have complete YAML frontmatter
- [ ] `wiki/index.md` is updated with all new pages
- [ ] `log.md` has migration entry
- [ ] No obvious duplicate pages
- [ ] Key wikilinks are in place (full link coverage comes with later ingests/lints)

## Git Commit

After migration:
- Stage all new files (raw records + wiki pages + index.md + log.md)
- Commit message format: `migrate: batch import N files from <source>`
- Example: `migrate: batch import 23 files from old-notes/`

## Key Principles

1. **Speed over depth**: Migration prioritizes coverage over detail. Deep analysis comes later via individual ingests.
2. **Don't lose data**: Every source file becomes a raw record, even if its wiki extraction is minimal.
3. **User approves the plan**: Always show the classification plan before executing.
4. **Recommend follow-ups**: Tell the user which pages need more detail after migration.
5. **Run lint after**: Always recommend a lint check post-migration.
