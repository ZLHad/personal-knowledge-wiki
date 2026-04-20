---
name: wiki-ingest
description: "Ingest knowledge into your personal Wiki. Analyzes conversations or files, extracts key knowledge, and compiles it into wiki pages (entities, concepts, topics) with cross-references. A single ingest typically touches 5-15 wiki pages. Supports depth parameter for extraction depth control. Trigger phrases: \"ingest this conversation\", \"save to wiki\", \"wiki ingest\", \"extract knowledge\", \"update knowledge base\"."
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

## Depth Parameter

Controls how deeply knowledge is extracted:

| Level | Usage | Extraction Depth |
|-------|-------|-----------------|
| `shallow` | `/ingest --depth shallow` | Definition + brief Details, skip formula derivations |
| `deep` (default) | `/ingest` or `/ingest --depth deep` | Full system models, formulas, algorithm flows, comparison tables |
| `exhaustive` | `/ingest --depth exhaustive` | Section-by-section extraction, code examples, experiment data tables |

## Domain-Specific Extraction Checklists

Automatically apply the corresponding checklist based on the source file's domain to avoid missing key information:

### Research Papers / Technical Notes
- [ ] System model (variable definitions + objective function + constraints)
- [ ] Core formulas (full derivation chain, not just conclusions)
- [ ] Algorithm flow (pseudocode or step-by-step breakdown)
- [ ] Innovation points and baseline comparisons
- [ ] Experiment results (key data tables, comparison metrics)
- [ ] Method comparisons (if multi-method comparison tables exist)
- [ ] **Create `wiki/papers/<paper_id>.md` brief** (see "Paper Routing Rules" below)
- [ ] Identify the paper's gap → append to the matching `wiki/territories/<domain>.md` Open Gaps section
- [ ] Identify the paper's research field → fill the `territory:` field in papers/ frontmatter with `[[territories/xxx]]`

**Paper Routing Rules** (decide whether a file under `raw/科研/论文资料/` becomes a `wiki/papers/` page):

| raw file characteristic | Target | Rationale |
|---|---|---|
| Filename matches `-<author><year>` pattern (e.g. `-zhou2025`) | `wiki/papers/<paper_id>.md` | External published paper |
| Self-authored paper that is submitted or published | `wiki/papers/`, `origin: self-authored-manuscript` | Fully-written Paper |
| Self-authored survey/manuscript **in draft** (not finalized) | **Do NOT go into papers/**; keep in raw/ as scaffolding source for `wiki/territories/` | Drafts are field-survey raw material |
| Filename contains `-details` / `-params` / `-proof` / `-analysis` / `-literature` etc. (method details / parameters / proofs / analyses / reference lists) | Do NOT go into papers/; append to the matching concept page's `sources:` | Not a standalone Paper |
| Filename has no author-year; first-person research notes | Do NOT go into papers/; place under concept or topic | Personal investigation notes |

**Handling raw files with pre-existing frontmatter** (learned in Phase 1):
- Some raw notes (especially those produced by conversation-knowledge-extractor or similar tools) already have a YAML frontmatter block at the head with **non-standard fields** like `extraction_date`, `conversation_type`, `source_type`, `main_topics`, `importance_level`, `source_url`, etc.
- When Editing a Paper page, **you MUST detect and remove the raw's old frontmatter** before writing the new spec-compliant one.
- Valuable fields (e.g. `source_url` for Zotero links, `source_author` for author list, `source_title` for the original paper title) should **migrate to the body** as a subtitle block below the H1:
  ```markdown
  # <Paper Title>

  **Authors**: <...>
  **Original title**: <...>
  **Zotero**: `zotero://...`

  ## TL;DR
  ...
  ```
- Never let old and new frontmatter fields coexist in the same YAML block — lint's completeness check passes but field pollution remains.

**Paper Generation Strategy (token-efficient)**:
- **Thorough close-read (≥ 300 lines)**: `bash cp raw/*.md wiki/papers/<slug>.md`, then Edit only the top (frontmatter + H1 + TL;DR) and bottom (Related + optional `## 对我的启发 / ## Personal Takeaways` stub). Body is byte-preserved.
- **Thin quick-read (< 200 lines)**: Fill the skeleton per CLAUDE.md's "Paper Pages" format, with `status: skimmed`, leaving empty sections empty.
- **Reflection handling**: grep the raw file for headings like `启发|思考|心得|讨论|评价|反思|改进意见|Insight|Takeaway|Reflection|对我的|Personal|My view`. If matched, set `has_reflection: true` and skip the stub. If not matched, append `## 对我的启发 / ## Personal Takeaways <!-- TODO -->` stub. Do NOT let sub-agents fabricate reflections — they lack personal context.

### Writing / Style Guides
- [ ] Writing rules/patterns (reusable rules)
- [ ] Before/after comparisons
- [ ] Style preferences and habits
- [ ] Error examples with corrections

### Tools & Workflows
- [ ] Configuration steps (commands or settings)
- [ ] Usage tips (non-obvious techniques)
- [ ] Common problems and solutions

### Other Domains
- Organize key information by topic, no fixed checklist

### Territory / Idea Pages (non-typical ingest triggers)

**territories/** pages are **not usually auto-generated from a single raw file**. They are created after a meaningful number of papers + concepts have accumulated, triggered by an explicit user request like "build a territory page for XX" or "organize the X research field". Scaffolding sources:
- 1-2 self-authored survey drafts (e.g. `raw/科研/论文资料/*-survey.md`)
- N papers/ pages from the same field (already generated)
- Clusters of related concepts/ pages

Mandatory skeleton: strictly follow CLAUDE.md's "Territory Pages" 5 sections (problem boundary / methods landscape / key papers lineage / open gaps / my angle).

**ideas/** pages are **not auto-generated from raw files** at all, but ingest flow does include an explicit **post-ingest idea-suggestion hook** (see below). New ideas default to `status: seed`, `confidence: low`; the user drives status transitions and confidence manually.

---

## Academic-framing criteria for ideas (STRICT)

⚠️ Field report 2026-04-11: first batch of ideas was written in "engineering project plan" voice (build/measure/prototype), user rejected as not academic. Apply ALL 4 criteria below when:
(a) the post-ingest idea-suggestion hook fires,
(b) the user explicitly asks to generate idea seeds,
(c) Phase 3 cold-start batch generation.

### Criterion 1: Motivation starts with a scientific question / scenario-problem pair, NOT "gap to fill"

❌ Engineering voice:
> "Existing SAGIN methods ignore resource failure correlation [gap], so we propose a method to handle it."

✅ Academic voice:
> "Is the iid assumption in SAGIN resource failure modeling still valid when LEO overhead times become correlated? What's the systemic regret of violating it?" (pose an answerable **scientific question** first)

### Criterion 2: Emphasis varies by `idea_type` — NOT a universal 3-step template

| idea_type | Main emphasis (80%) | Secondary | Can omit |
|---|---|---|---|
| **theory** | Theoretical formulation + proof sketch + novelty | Experiment validating bound | Engineering steps |
| **method** | **Theoretical innovation core** (why it works) + essential difference from existing methods | Target scenario + expected effect | Engineering details |
| **system** | Architectural idea + key design tradeoffs + formalized sub-question | Experiment validating key claim | Benchmark numbers |
| **scenario** | **Structural features** of the new scenario + **structural reasons** existing methods fail | Sketch of new method | Concrete algorithm implementation |
| **position** | Problem **structure + critique logic** + constructive directions | Often no experiment needed | Implementation |
| **paradigm** | **First-principle argumentation** for the perspective shift | 1-2 concrete protocol instances | Full prototype |
| **infrastructure** | Structural characterization of the field's **methodological gap** | Evaluability criterion | Engineering steps |

### Criterion 3: Demote `## 最小可行实验` (minimum viable experiment)

- NOT every idea needs heavy ink on this section. position / paradigm ideas may omit or give one sentence.
- Experiment, if present, must be framed as **theory validation** ("verify the predicted bound"), NOT **benchmark reporting** ("measure X%").
- If an idea's core contribution is "I built a X", re-check whether it's misclassified as infrastructure / needs reshape.

### Criterion 4: `## 科学贡献 (Intellectual contribution)` is MANDATORY

Every idea page MUST have this section. Format: 2-4 sentences using **academic verbs**:

✅ characterize / formulate / prove / bound / reveal / establish / unify / instantiate / challenge
❌ build / measure / implement / deliver / develop / test

Content answers **"what we learn" (insight)** NOT **"what we build" (artifact)**.

---

## Post-ingest idea-suggestion hook (NEW)

⚠️ Field report 2026-04-11: the user wants skill to *proactively* suggest possible idea seeds after ingesting new papers / notes, rather than waiting for the user to dictate.

### Trigger conditions

- When the ingest writes a raw file into `wiki/papers/` (an external paper brief), **MANDATORY** trigger
- When the ingest causes a concept or territory to first cross the "3 related papers" threshold, **MANDATORY** trigger
- When the conversation explicitly discussed "could do XX" / "is XX researchable", **MANDATORY** trigger

### Suggestion workflow

1. **Scan** the new papers from this ingest + relevant territory's current Open Gaps
2. Identify **possible idea candidates** (typically 0-2, don't flood)
3. For each candidate, draft a **pitch + Motivation + Novelty claim** per criteria 1-4 (NOT a full idea page — just a **candidate pitch**)
4. **Ask the user**:

```markdown
## Possible idea seeds (based on this ingest)

1. **<candidate 1 slug>** (`idea_type: <type>`)
   - Scientific question: <1 sentence>
   - Novelty claim: <1-2 sentences>
   - Links to: [[papers/<just-ingested X>]] + [[territories/Y]] gap G<N>

2. **<candidate 2 slug>** ...

Seed which to `wiki/ideas/`?
- All (status: seed, confidence: low)
- Selective: [1], [2]
- Log only here, don't seed
- None, ignore
```

5. After user decision, **generate the full idea page** per criteria 1-4 (only for selected candidates)

### Cases where NOT to actively suggest
- Ingest is primarily topics/ (writing guides) or entities/ (journals/tools)
- Ingest is about a sub-domain where the user already has committed ideas
- User explicitly said "don't suggest ideas for this ingest"

---

## Idea state-transition workflow (idea-flow)

⚠️ User's review / promotion / shelving of ideas is an **ongoing process**, not a one-shot action. This section governs the standard flow when user requests "promote idea X".

### State machine (as defined in CLAUDE.md)

```
seed → sketched → prototyping → drafting → submitted → landed
              ↓         ↓            ↓
            shelved   shelved    shelved
```

### Per-transition criteria + actions

| Transition | User instruction examples | Criteria | Automated actions |
|---|---|---|---|
| **seed → sketched** | "promote X to sketched" | Motivation developed / Novelty claim concrete / at least 1 paragraph of technical route | Change frontmatter `status: sketched`; append to `状态日志`: `YYYY-MM-DD: promoted to sketched by user` |
| **sketched → prototyping** | "start prototyping X" | Specific experiment / simulator / codebase target exists | Change status; guide user to write `next_action` |
| **prototyping → drafting** | "X has preliminary results, start writing" | Initial experimental results exist | Optionally create `raw/科研/论文资料/<paper_id>-draft.tex` as writing anchor |
| **drafting → submitted** | "X has been submitted" | LaTeX generated + submission confirmation | Append submission date; suggest creating corresponding `wiki/papers/<paper_id>.md` entry with `origin: self-authored-manuscript` |
| **submitted → landed** | "X was accepted" | Acceptance notification | Update status + venue + mark "my own paper" on wiki/papers/ page |
| **any → shelved** | "shelve X" | — | Change status: shelved; append `状态日志`: `YYYY-MM-DD: shelved — <reason>` (reason required) |

### Batch review flow ("review all my ideas")

1. Read `wiki/ideas/*.md`, group by status
2. For each `seed` idea, run this **review checklist**:
   - Still interested? (if no → shelve candidate)
   - Motivation / Novelty claim still valid? (literature / user work changed?)
   - Clear next action? (if no → remain seed)
   - Should confidence be adjusted?
3. Report batch suggestions to user: promote X / shelve Y / refine Z; wait for user's final decision
4. Execute user-confirmed transitions in one git commit

### Do NOT auto-transition (needs user judgment) for:

- Jumping two stages from seed to prototyping (usually too aggressive; suggest sketched first)
- Shelving without a reason (reason required)
- Repeated seed ↔ sketched ping-pong within one week (remind user this idea is unstable)

---

## Workflow

### Step 1: Content Analysis

Quickly review the entire conversation window or file, identifying:

- **Content type**: academic writing / discussion / technical task / reading notes / other
- **Main topics** (may be multiple)
- **Key knowledge outputs**: rules, patterns, concepts, tool usage, decisions
- **Entities involved**: people, journals, conferences, projects, tools
- **Concepts involved**: methods, theories, terms, principles
- **Determine depth level**: Based on content complexity and user specification

Report analysis results to user briefly (3-5 lines), wait for confirmation.

### Step 2: Generate Raw Record

Extract core content into a raw record file. If the user provides an external file (paper notes, etc.), **copy the original file completely** as the raw record without modifying any content.

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

### Batch Ingest (multiple external files)
If user provides multiple external files:
1. Scan file list, present classification plan
2. **Confirm depth level** (shallow/deep/exhaustive), default deep
3. **Process file #1**: Execute full ingest workflow, show results
4. **Sample Approval**: Show file #1's raw record + wiki page sample, ask user to confirm depth is satisfactory
5. After user confirms, choose processing mode based on file count:
   - **≤ 5 files**: Sequential processing, checkpoint every 3 files
   - **> 5 files**: Enable **parallel processing** (see Parallel Processing section below)
6. After completion, output **file verification summary** and overall report

**File verification summary format** (per raw record):
```
✓ YYYY-MM-DD-slug.md (XXkB → raw/domain/category/, complete)
✗ bad-file.md (0kB, skipped: empty file)
```

### Parallel Processing

When batch file count > 5, use sub-Agents for parallel processing to avoid context compaction:

#### Architecture

```
Main Agent (Coordinator)
├── 1. Read index.md / CLAUDE.md, analyze all source files
├── 2. Group by wiki page dependencies (prevent multiple Agents writing same page)
├── 3. Launch sub-Agents in parallel (2-3 files per group)
├── 4. Collect sub-Agent manifests
└── 5. Merge: update index.md / log.md / cross-group wikilinks / git commit

Sub-Agent-A          Sub-Agent-B          Sub-Agent-C
├── files 1, 3, 7    ├── files 2, 5, 8    ├── files 4, 6, 9
├── raw records      ├── raw records      ├── raw records
├── wiki pages       ├── wiki pages       ├── wiki pages
└── return manifest  └── return manifest  └── return manifest
```

#### Grouping Strategy

Main Agent pre-analyzes each file's wiki page targets before dispatching:
- Files that update the **same wiki page** go in the **same group** (e.g. papers both touching [[MEC]])
- Non-overlapping files can be freely assigned, balancing workload
- 2-4 files per group, max 5
- **Single-file groups**: Groups with only 1 file should be merged into the nearest related group, or processed directly by Main Agent
- **Near-synonym deduplication**: During pre-analysis, check for near-synonyms (e.g., MEC / Edge Computing) and ensure they map to the same wiki page

#### Sub-Agent Responsibilities

Each sub-Agent:
- ✅ Create raw records
- ✅ Create/update wiki pages **within its group only**
- ✅ Weave wikilinks within group
- ❌ Do NOT modify `index.md`
- ❌ Do NOT modify `log.md`
- ❌ Do NOT create cross-group wikilinks
- 📤 Return manifest (raw_records + new_pages + updated_pages + key_knowledge)

#### Sub-Agent Prompt Template

```
You are a wiki ingest sub-Agent. Process the following files and ingest knowledge into the wiki.

## Wiki Path
{{WIKI_PATH}}

## Required Reading
Read CLAUDE.md first for format conventions.

## Existing Wiki Pages (avoid duplicates)
<page list from Main Agent's index.md>

## Files to Process
1. <file_path_1>
2. <file_path_2>
3. <file_path_3>

## Depth Level
<shallow / deep / exhaustive>

## Your Tasks
1. Create raw record for each file (copy to raw/<domain>/<sub-category>/)
2. Extract entities/concepts, create or update wiki pages (only pages in your group)
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
- key_knowledge: [1-2 sentence core takeaways]
```

#### Main Agent Wrap-up

After collecting all sub-Agent manifests:
1. **Merge index.md**: Add all new/updated pages to the catalog
2. **Append log.md**: Summarize all sub-Agent results
3. **Process suggested_pages**: Review each group's suggested_pages, create missing pages as needed
4. **Cross-group wikilinks**: Link related pages across groups in their `## Related` sections
5. **File verification**: Aggregate all raw record verification results
6. **Git commit**: Single commit for all changes

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
