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
| Import 50+ files, quick indexing | **migrate** (catalog mode) |
| Import 10-50 files from another system | **migrate** (standard mode) |
| Import <10 high-value files with full detail | **migrate** (deep mode) or per-file **ingest** |
| Single conversation or file | **ingest** |

## Depth Modes

Controls how deeply knowledge is extracted during migration:

| Mode | Description | Wiki Page Depth | Use Case |
|------|-------------|----------------|----------|
| `catalog` | Only create raw records + minimal wiki pages | Definition only | 100+ files, quick indexing |
| `standard` (default) | Raw records + extract per domain checklist | Definition + Details + Common Pitfalls | Normal batch import |
| `deep` | Equivalent to per-file `ingest --depth deep` | Full system models, formula derivations, algorithm flows | High-value files |

Users can specify depth mode during Step 2 classification approval. If unspecified, defaults to `standard`.

**Domain-Specific Extraction Checklists (standard/deep mode):**

Refer to the "Domain-Specific Extraction Checklists" section in the wiki-ingest skill. Apply the corresponding checklist based on each source file's domain automatically.

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
4. **Wiki page candidates**: What page type(s) can be produced?

**7 wiki page types — routing rules**:
- **`entities/`** — specific named things: journals, conferences, people, tools (e.g. `IEEE-TCOM`, `Zotero`)
- **`concepts/`** — methods, theories, cross-paper syntheses (e.g. `MARL`, `Conditional-Diffusion`)
- **`topics/`** — guides, norms, best practices (writing specs, workflow guides)
- **`papers/`** — **per-paper briefs**: promote only if raw filename matches `-<author><year>` pattern, OR content is a self-authored submitted manuscript. Skip self-authored drafts / method-details / proof-fragments / reference-lists (those enrich concept pages' `sources:`)
- **`territories/`** — **research-field maps**: usually NOT auto-generated from a single raw file; created when a field has accumulated enough papers+concepts
- **`ideas/`** — **user's research ideas**: NOT auto-generated from raw; comes only from user dictation
- **`syntheses/`** — filed query answers / user's written plans (grants, revisions)

**Classification strategy:**
- Read file title, frontmatter (if any), and first 20 lines
- Match keywords against existing domains in CLAUDE.md
- Check filename for patterns: `-<author><year>` → paper candidate; `-details` / `-params` / `-proof` / `-analysis` / `-literature` → concept supplement (don't create paper page)
- Group similar files for batch processing

Present classification plan to user for approval:
```
## Migration Plan

| # | File | → Domain | → Type | Wiki Pages |
|---|------|----------|--------|------------|
| 1 | zhou2025-HDL-MDRS.md | research/papers | paper | papers/zhou2025-HDL-MDRS |
| 2 | CD-TD3-algorithm-details.md | research/papers | concept supplement | enrich Conditional-Diffusion sources |
| 3 | abstract-writing-spec.md | research/writing | topic | topics/abstract-writing-spec |
| 4 | react-hooks.md | programming/notes | entity+concept | React, Hooks |
| ... | | | | |

Approve? (y/n, or specify changes)
```

### Step 2.5: Sample Approval (when batch > 3 files)

**Process file #1 first**, show complete results:
1. Raw record (filename + size)
2. Generated wiki page content preview
3. Extracted entities/concepts list

Ask user to confirm:
- "Is the depth satisfactory?"
- "Need to adjust the depth mode?"
- "After confirmation, continue processing remaining N files"

**Purpose**: Avoid completing the entire batch only to find the depth doesn't match expectations, reducing rework.

### Step 3: Batch Processing

For each file in the approved plan:

#### 3.1 Create Raw Record
- Copy/move file to `raw/<domain>/<sub-category>/`
- Rename to follow `YYYY-MM-DD-<slug>.md` convention if needed
  - Use file modification date if no date in filename
  - Use file creation date as fallback
- Add YAML frontmatter if missing
- **NEVER modify the original content** — raw files are immutable

#### 3.2 Verify Raw Record
Output file verification info to confirm complete copy:
```
✓ 2024-12-13-react-hooks-guide.md (29KB, complete)
✓ 2024-12-18-api-design-patterns.md (38KB, complete)
✗ empty-file.md (0KB, skipped: empty file)
```

#### 3.3 Extract Wiki Pages (by depth mode)

**catalog mode**:
- Entity pages: Overview only (1-2 sentences)
- Concept pages: Definition only (1-2 sentences)
- No Common Pitfalls, no formula extraction

**standard mode**:
- Entity pages: Overview + Key Facts
- Concept pages: Definition + Details (per domain checklist) + Common Pitfalls
- Apply domain-specific extraction checklists

**deep mode**:
- Equivalent to wiki-ingest's deep level
- Full system models, formula derivations, algorithm flows, experiment data
- Apply domain-specific extraction checklists, confirm each item covered

#### 3.4 Weave Wikilinks
- Add `[[wikilinks]]` in all new/updated pages
- Cross-reference related pages found during migration
- Build `## Related` sections

#### 3.5 Checkpoint / Parallel Processing

Choose processing mode based on total file count:

**≤ 5 files: Sequential + Checkpoint**
- Git commit every 3 files
- Output brief progress summary: `Processed X/N files, created Y wiki pages`

**> 5 files: Parallel Processing**

Use sub-Agents for parallel processing to avoid context compaction and repeated file reads.

```
Main Agent (Coordinator)
├── 1. Read index.md / CLAUDE.md, pre-analyze all source files
├── 2. Group by wiki page dependencies (prevent multiple Agents writing same page)
├── 3. Launch sub-Agents in parallel (2-4 files per group)
├── 4. Collect sub-Agent manifests
└── 5. Merge: index.md / log.md / cross-group wikilinks / git commit

Sub-Agent-A          Sub-Agent-B          Sub-Agent-C
├── files 1, 3, 7    ├── files 2, 5, 8    ├── files 4, 6, 9
├── raw records      ├── raw records      ├── raw records
├── wiki pages       ├── wiki pages       ├── wiki pages
└── return manifest  └── return manifest  └── return manifest
```

**Grouping Strategy**:
- Pre-read each file's first 20 lines, identify target wiki pages
- Files updating the **same wiki page** go in the **same group**
- Non-overlapping files can be freely assigned, balancing workload
- 2-4 files per group, max 5
- **Single-file groups**: Groups with only 1 file should be merged into the nearest related group, or processed directly by Main Agent
- **Near-synonym deduplication**: During pre-analysis, check for near-synonyms (e.g., MEC / Edge Computing) and ensure they map to the same wiki page

**Sub-Agent Responsibilities**:
- ✅ Create raw records
- ✅ Create/update wiki pages within its group only
- ✅ Weave wikilinks within group
- ❌ Do NOT modify index.md
- ❌ Do NOT modify log.md
- ❌ Do NOT create cross-group wikilinks
- 📤 Return manifest (raw_records + new_pages + updated_pages + key_knowledge)

**Sub-Agent Prompt Template**:
```
You are a wiki migrate sub-Agent. Process the following files and migrate them into the wiki.

## Wiki Path
{{WIKI_PATH}}

## Required Reading
Read CLAUDE.md first for format conventions.

## Existing Wiki Pages (avoid duplicates)
<page list from Main Agent's index.md>

## Files to Process
1. <file_path_1>
2. <file_path_2>

## Depth Mode
<catalog / standard / deep>

## Your Tasks
1. Create raw record for each file (copy to raw/<domain>/<sub-category>/)
2. Extract entities/concepts per depth mode, create or update wiki pages
3. Weave wikilinks within your group's pages
4. ❌ Do NOT modify index.md
5. ❌ Do NOT modify log.md
6. ❌ Do NOT create/modify cross-group pages; you MAY use `[[wikilink]]` in body text to reference cross-group concepts, but only list your group's pages in `## Related`

## Expected Pages
Pages this group is expected to create/update:
<Main Agent provides target page list for this group>
Only operate on the above pages. If you discover a page that should be created but is not in your scope, add it to the suggested_pages field in your manifest.

## Output Manifest
When done, output:
- raw_records: [filename + size list]
- new_pages: [new wiki page paths]
- updated_pages: [updated wiki page paths]
- suggested_pages: [pages suggested but outside this group's scope]
- key_knowledge: [core takeaways]
```

**Main Agent Wrap-up**:
1. Merge index.md (add all new/updated pages)
2. Append log.md (summarize all sub-Agent results)
3. Process suggested_pages (review each group's suggestions, create missing pages as needed)
4. Cross-group wikilinks (link related pages across groups)
5. File verification (aggregate all raw record checks)
6. Git commit (single commit for all changes)

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

1. **Depth is configurable**: Users control extraction depth via depth modes. Default is `standard`, not the shallowest option.
2. **Don't lose data**: Every source file becomes a raw record, even if its wiki extraction is minimal.
3. **Sample before batch**: Process file #1 first, show results, confirm depth before continuing. Avoid rework.
4. **Verify raw records**: Output file verification summaries confirming complete copy. Users should not need to manually check raw files.
5. **Checkpoint regularly**: Git commit every 3-5 files to reduce context pressure and loss risk.
6. **Apply domain checklists**: Different domains (papers, writing guides, tools) have different key information — extract per checklist to avoid missing critical content.
7. **Run lint after**: Always recommend a lint check post-migration.
