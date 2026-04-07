---
name: wiki-ingest
description: "Ingest knowledge into your personal Wiki. Analyzes conversations or files, extracts key knowledge, and compiles it into wiki pages (entities, concepts, topics) with cross-references. A single ingest typically touches 5-15 wiki pages. Trigger phrases: \"ingest this conversation\", \"save to wiki\", \"wiki ingest\", \"extract knowledge\", \"update knowledge base\"."
---

# Wiki Ingest

## Core Function

Analyze conversation or file content and **compile** knowledge into the personal Wiki — not just generating a standalone file, but **updating the entire wiki network**: creating/updating entity pages, concept pages, topic pages, maintaining cross-references, and appending the timeline.

## Wiki Location

**Wiki path**: `{{WIKI_PATH}}`

Confirm this path is accessible on first use. All operations are based on this directory.

## Key Files

Before any operation, read these first:
1. `CLAUDE.md` — Wiki Schema (conventions, frontmatter format, approved tags)
2. `wiki/index.md` — Full catalog (know existing pages, avoid duplicates)
3. `log.md` — Timeline (know recent operations)

## Workflow

### Step 1: Content Analysis

Quickly review the entire conversation window or file, identifying:

- **Content type**: academic writing / discussion / technical task / reading notes / other
- **Main topics** (may be multiple)
- **Key knowledge outputs**: rules, patterns, concepts, tool usage, decisions
- **Entities involved**: people, journals, conferences, projects, tools
- **Concepts involved**: methods, theories, terms, principles

Report analysis results to user briefly (3-5 lines), wait for confirmation.

### Step 2: Generate Raw Record

Extract core content into a raw record file.

**File path**: `raw/<domain>/<sub-category>/YYYY-MM-DD-<slug>.md`

**Domain classification** (customize per your CLAUDE.md):
- Defined in CLAUDE.md's Architecture section

**Extraction strategies by content type:**

#### Academic Writing (most detailed)
Reference `references/academic-writing-guide.md`
- Record before/after comparisons
- Extract reusable writing rules
- Note writing preferences and patterns
- Detail level: 3000-5000 words

#### Technical Tasks
Reference `references/technical-task-guide.md`
- Record methods, tools, configurations, decision points
- Key commands and code
- Detail level: 1500-2500 words

#### Reading Notes
Reference `references/reading-notes-guide.md`
- Core insights and personal reflections
- Connections to existing knowledge
- Detail level: 2000-3000 words

#### Other types
- Organize key information by topic
- Detail level: as needed

**Annotation system:**
- `⭐⭐⭐` Core knowledge / frequently asked
- `💡` Important insight / breakthrough
- `⚠️` Warning / common trap
- `🔄` Cognitive evolution
- `📌` Personal preference / habit

### Step 3: Update Wiki Pages (Core Step)

This is the **key difference** from simple note-taking. Update the entire wiki network.

#### 3.1 Entity Page Updates

Scan for named entities in the content:

- **Existing page** → Read `wiki/entities/<name>.md`, append new info to `## Notes`, update `updated:` and `sources:`
- **New entity** → Create `wiki/entities/<name>.md` per CLAUDE.md Entity format
- **Criteria**: The entity has **substantive information** (not just mentioned in passing)

#### 3.2 Concept Page Updates

Scan for methods, theories, principles, terms:

- **Existing page** → Read `wiki/concepts/<name>.md`, update `## Details` or `## Common Pitfalls`
- **New concept** → Create `wiki/concepts/<name>.md` per CLAUDE.md Concept format
- **Criteria**: Enough content for a standalone page (at least 3-5 lines of valuable description)

#### 3.3 Topic Page Updates

If content contributes new rules, patterns, best practices:

- **Existing topic** → Read corresponding `wiki/topics/` page, append new rules/cases
- **New topic** → Create new page (rare, needs sufficient content)
- **Update semantics**: **Overwrite stale content**, don't just append creating contradictions

#### 3.4 Wikilink Weaving

In all created/updated pages:
- Add `[[wikilink]]` on **first mention** of other wiki pages in body text
- List all related page links in `## Related` section
- Ensure **bidirectional links**: if A links to B, B's Related should link back to A

### Step 4: Update Index and Timeline

#### Update `wiki/index.md`
- Add new pages to corresponding category table
- Update `Updated` column date for modified pages
- Update Statistics numbers at bottom

#### Append `log.md`
Format:
```markdown
## [YYYY-MM-DD] ingest | <topic summary>

- Raw record: `raw/<path>/<filename>.md`
- New pages: [[page1]], [[page2]]
- Updated pages: [[page3]], [[page4]], [[page5]]
- Key knowledge: <1-2 sentence core takeaway>
```

### Step 5: Report & Confirm

Output ingest report to user:

```
## Ingest Complete

**Raw record**: raw/path/YYYY-MM-DD-xxx.md
**Pages touched**: X (Y new + Z updated)

### New Pages
- [[entity-name]] (entity)
- [[concept-name]] (concept)

### Updated Pages
- [[topic-name]] — added 2 new rules
- [[entity-name]] — updated Notes

### Key Knowledge
1. xxx
2. xxx
```

## Special Scenarios

### Batch Ingest (external files)
If user provides external files instead of current conversation:
1. Read file content
2. Discuss key points (unless silent mode requested)
3. Store in `raw/` corresponding directory
4. Execute wiki update from Step 3 onward

### Lightweight Ingest
If content is minimal (only 1-2 knowledge points):
- Skip raw record, directly update existing wiki pages
- Still append log.md
- Inform user: "Content is minimal, directly updated existing pages"

### Adding New Categories
When user requests a new knowledge base category (e.g. "add an XX category"), you MUST modify these **three places**:

1. **`CLAUDE.md`** in the wiki directory:
   - Add new subdirectory under `raw/` in `## Architecture` tree
   - Add new tag in `## Approved Tags`

2. **This Skill file** (`wiki-ingest/SKILL.md`):
   - Add new category and description in **domain classification** list

3. **Physical directory**:
   - Create corresponding subdirectory under `raw/` (`mkdir -p`)

All three are required, otherwise ingest routing or lint tag checking will fail.

## Quality Check

Before completing ingest, confirm:
- [ ] Raw record filename follows `YYYY-MM-DD-<slug>.md` convention
- [ ] All new wiki pages have complete YAML frontmatter
- [ ] All `[[wikilinks]]` point to existing pages
- [ ] `wiki/index.md` updated
- [ ] `log.md` appended
- [ ] Updated pages have refreshed `updated:` date
- [ ] `sources:` includes new raw record path

## Reference Files

- [Academic Writing Guide](references/academic-writing-guide.md)
- [Technical Task Guide](references/technical-task-guide.md)
- [Reading Notes Guide](references/reading-notes-guide.md)

## Git Commit

After ingest, execute git commit:
- Stage all new/modified files (raw record + wiki pages + index.md + log.md)
- Commit message format: `ingest: <topic summary>`

## Key Principles

1. **Wiki pages are compiled truth**: Overwrite stale content, don't append creating contradictions
2. **Raw files are immutable**: Never modify after writing
3. **One ingest should touch 5-15 pages**: If only 1-2 updated, you may have missed entities/concepts
4. **Prefer updating existing pages**: Don't easily create new pages, check if existing ones can be supplemented
5. **Frontmatter must be complete**: type, domain, created, updated, sources, tags, aliases
6. **Tags must be in approved list**: See CLAUDE.md Approved Tags section
