---
name: wiki-pdf-ingest
description: "**ONLY** triggered when the user explicitly wants to **import a paper PDF into their personal wiki knowledge base** (not for generic PDF reading / summarizing / translating). Extracts the PDF into a deep-read markdown note under `raw/科研/论文资料/` and can chain into wiki-ingest to produce a wiki/papers/ brief. [STRICT triggers]: 'add this PDF to wiki / knowledge base', 'import pdf to wiki', 'wiki-pdf-ingest', 'ingest this pdf into wiki', 'add paper pdf to knowledge base', 'deep-read this PDF into my wiki'. [DO NOT trigger]: generic 'read this PDF' / 'summarize PDF' / 'translate PDF' / 'convert PDF to PPT' / paper-review use cases — those belong to anthropic-skills:pdf / paper-mkdocs-site / paper-reviewer respectively."
---

# wiki-pdf-ingest — PDF Paper → Personal Wiki

## Trigger threshold (strict)

Only trigger in these situations:

1. User explicitly requests a wiki-scoped PDF import (e.g. "add this PDF to wiki", "import paper pdf to my knowledge base", "ingest pdf into wiki")
2. User drops a PDF AND the conversation is clearly continuing wiki-related work (previously discussed wiki/ directory, currently doing ingest, organizing papers/, etc.)

Do NOT trigger for (use other tools/skills instead):
- Generic PDF reading → Read tool / `anthropic-skills:pdf`
- PDF summary / translation → regular conversation
- PDF → slide / PPT → `paper-figure-to-pptx` / `paper-mkdocs-site`
- PDF merge / split / edit → `anthropic-skills:pdf`
- Peer-review critique on the PDF → `paper-reviewer`

## Disambiguation default behavior

If user's request is ambiguous between "read PDF" and "import into wiki" (e.g. "help me look at this PDF"):
- Do NOT auto-trigger this skill
- Ask back: "For this PDF do you want: (a) quick read of content (I'll just read) / (b) deep-read and add to wiki knowledge base (trigger wiki-pdf-ingest) / (c) peer-review critique / (d) other?"

## Core Function

Automatically convert a paper PDF into a **deep-read markdown note** in the user's wiki style, saved to `raw/科研/论文资料/YYYY-MM-DD-<author><year>-<short-slug>.md`. Optionally trigger wiki-ingest to produce a `wiki/papers/` brief.

## Reference format

Deep-read notes follow the style of existing high-quality examples in `raw/科研/论文资料/`. Read one for calibration, e.g. any 1000+ line file.

## Mandatory skeleton

Every deep-read note MUST include these H2 sections, in order:

```markdown
# <Paper Title>

## 文章信息 / Article Metadata
- **Title**: <full>
- **Authors**: <author1, author2, ... or "X et al.">
- **Venue**: <journal/conference + year>
- **DOI**: <10.xxxx/...>
- **Keywords**: <from paper>

## 摘要整理 / Abstract Digest

### Research Background
<1-2 paragraphs, paraphrased>

### Research Goal
<1 paragraph, what the paper claims to solve>

### Main Findings
<1-2 paragraphs, core contributions>

## 论文框架结构 / Paper Structure

<chapter-by-chapter, 2-5 sentences each>

## 核心技术 / Core Techniques

### System Model
<variable definitions + objective function + constraints>

### Core Formulas
<LaTeX preserved + physical meaning; full derivation chain, not just conclusions>

### Algorithm
<pseudocode or step-by-step>

### Key Design Tradeoffs
<which parameters/structure are knobs, their roles>

## 创新点 / Innovation Points

<3-5 contributions claimed by authors, extracted verbatim>

## 实验 / Experiments

### Simulation Setup
<hardware, baseline methods, scenarios, metrics>

### Key Results
<core comparison data>

### Ablation Studies
<if any>

## 个人反思 / Personal Reflection (AI draft, user to refine)

<!-- TODO (user): refine personal angle -->
- Why read this (logical linkage to my work): <TBD>
- Method transfer points: <AI draft based on related wiki concepts>
- Assumptions/limitations: <AI draft based on paper limitations>
- Baseline alignment: <TBD>

## References
- DOI: <10.xxxx/...>
- <other URLs / Zotero link / arXiv ID if present>
```

## Workflow

### Step 0: Pre-check PDF

1. **Confirm PDF exists** via the user-provided path
2. **Check size**: if > 50 pages, use Read tool's `pages` parameter to process in chunks (max 20 pages each)
3. **Detect type**: paper / survey / tech report / slide deck — slide decks aren't suitable input, warn user

### Step 1: Extract PDF metadata + content

Prefer `anthropic-skills:pdf` skill if loaded; otherwise use the Read tool (supports PDF up to 20 pages).

**Chunked reading strategy for large PDFs**:
- Chunk 1: pages 1-5 → title, authors, abstract, keywords, intro opening
- Chunk 2: pages 6-10 (or Intro + Related Work) → related work
- Chunk 3: pages 11-15 (or System Model + Method) → core techniques
- Chunk 4: pages 16-20 (or Experiment) → experiments
- Final chunk: pages N-5 ~ N → conclusion + bibtex (if last page)

### Step 2: Structured extraction

Fill per-section per the skeleton above:

1. **Article Metadata**: extract from first-page metadata. `DOI` is priority. `venue` typically appears in the copyright line ("0000-0000 © IEEE" followed by venue name for IEEE papers).
2. **Abstract Digest**: translate/paraphrase the paper's abstract into 3 paragraphs (background / goal / findings). Don't copy verbatim — paraphrase while preserving key claims.
3. **Paper Structure**: scan all H1/H2 titles + 2-5 sentence summary per section.
4. **Core Techniques**: for the heavy chapters:
   - System model → variables + objective + constraints (complete, no pruning)
   - Formulas → preserve LaTeX + add commentary
   - Algorithm → convert to step-by-step or pseudocode
5. **Innovation Points**: prefer extracting the author's own contribution list (usually in Intro or a Contributions subsection).
6. **Experiments**: baselines, metrics, key numbers — replicate essential tables.

### Step 3: Personal reflection auto-draft (constrained)

> ⚠️ **Academic framing**: follow the "Academic-framing criteria for ideas" in wiki-ingest SKILL.md.

Draft 4 reflection items (user refines later), similar to wiki-ingest's paper-scaffold style:

1. **Logical linkage** (not "personal motivation"): how the paper connects logically to the user's existing wiki concepts / syntheses / territories.
2. **Method transfer points**: which component could transfer to which concept/work the user has.
3. **Assumptions/limitations**: does the paper's implicit assumption hold in the user's typical scenarios?
4. **Baseline alignment** (if user has a matching task): can the paper's baselines serve as reference?

Each item gets a `<!-- TODO (user): ... -->` marker for review.

### Step 4: Name + write + verify

1. **File naming**: `YYYY-MM-DD-<author><year>-<short-slug>.md`
   - YYYY-MM-DD = today's date (ingest date, not paper publication date)
   - `<author>` = first author surname (lowercase)
   - `<year>` = paper publication year
   - `<short-slug>` = 3-5 English words, kebab-case
   - Example: `2026-04-20-wang2025-satellite-aav-priority.md`
2. **Write to**: `raw/科研/论文资料/<filename>.md` (don't touch the original PDF)
3. **Verify**:
   - wc -l (expected 300-1500)
   - grep to confirm all mandatory sections present
   - Show first 30 lines for user quick-review

### Step 5: (Optional) Trigger wiki-ingest

Ask the user:
> "Generated `raw/科研/论文资料/<filename>.md` (N lines). Continue with wiki-ingest to create `wiki/papers/<paper_id>.md` brief?"

If yes:
- Call wiki-ingest skill (paper branch)
- Apply cp + Edit strategy to generate paper brief
- Update wiki/index.md + log.md
- Trigger post-ingest idea-suggestion hook

## Token budget

- Small PDF (< 20 pages): ~15-25K tokens
- Medium PDF (20-50 pages, surveys / long papers): ~30-50K tokens
- Large PDF (> 50 pages): recommend user pre-split

## Fallback: scanned PDFs / image-heavy PDFs

- If PDF is scanned (image-only), Read cannot extract text
- Prompt user: use OCR tool first, or manually paste abstract

## Common failure modes

1. **DOI not extractable**: some arXiv preprints lack DOI; leave blank or use arXiv ID
2. **Formula extraction fails**: complex figures may produce garbled LaTeX; ask user to hand-verify
3. **Table extraction fails**: complex-layout tables may lose structure; mark `<!-- TODO: manually supplement Table X -->`
4. **Author name parsing error**: Chinese PDFs or very long author lists may overflow; fall back to "X et al."

## Collaboration with wiki-ingest

This skill handles **PDF → raw/*.md** (steps 1-4).
wiki-ingest handles **raw/*.md → wiki/papers/ + concept/entity extraction** (the rest).

They couple loosely through the `raw/科研/论文资料/` directory. User can:
- Only call this skill (generate deep-read notes, don't enter wiki)
- Chain this skill + wiki-ingest (one-shot from PDF to wiki/papers/)

## Git convention

Files generated by this skill:
- **raw/** new files go to git stage (raw is the immutable audit trail)
- **Do NOT** commit the original PDF itself (usually too large; gitignore or raw/assets/ but not in git)
- Commit message: `pdf-ingest: <short paper title>`
