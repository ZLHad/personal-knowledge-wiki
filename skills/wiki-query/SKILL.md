---
name: wiki-query
description: "Answer questions based on your personal Wiki. Reads index to find relevant pages, synthesizes answers with citations, and optionally archives as a synthesis page. Trigger phrases: \"search wiki\", \"wiki query\", \"look up in wiki\", \"what does my wiki say about X\", \"check knowledge base\", \"find in wiki\", \"wiki search\"."
---

# Wiki Query

## Core Function

Answer questions based on wiki content at `{{WIKI_PATH}}`, and optionally archive valuable answers as synthesis pages for compounding knowledge.

## Wiki Location

**Wiki path**: `{{WIKI_PATH}}`

## Prerequisites

Before querying, read:
1. `CLAUDE.md` — understand schema and approved tags
2. `wiki/index.md` — full catalog of all wiki pages
3. `log.md` — recent operations (for context)

## Wiki architecture (7 page types, by query priority)

Know which page type to search FIRST based on question type. This is the key to answer quality.

| Page type | Answers | Trigger examples |
|---|---|---|
| **`wiki/territories/`** | Research-field maps: current state / gaps / user's angle | "What's happening in SAGIN?", "Open problems in GAI for wireless?", "World Model 6G gaps?" |
| **`wiki/papers/`** | A specific paper / author / method's implementation in that paper | "What did Zhou 2025 do?", "HDL-MDRS innovations?", "Which papers used diffusion for MEC?" |
| **`wiki/concepts/`** | Standardized definitions / cross-paper syntheses of a method/theory | "What is Conditional Diffusion?", "MARL vs MDP?", "Optimization-Embedded-DRL definition" |
| **`wiki/entities/`** | Named entities (journals / tools / people) factual info | "IEEE-TCOM requirements", "algorithm2e usage", "Zotero setup" |
| **`wiki/topics/`** | Reusable rules / patterns / writing norms | "How to write abstract?", "IEEE colon restriction?", "Symbol consistency rule" |
| **`wiki/ideas/`** | User's own research ideas being incubated | "What ideas am I working on?", "Which ideas are in drafting status?", "Shelved ideas" |
| **`wiki/syntheses/`** | Archived prior query answers | "Did we discuss X before?" |

**Typical routing**:
- Field-level question ("how is X going?") → start in `territories/`, then follow `[[wikilink]]` to papers/concepts
- Specific-paper question → go directly to `papers/`
- Method-principle question → start in `concepts/`, supplement with specific cases from `papers/`
- "My own work" question → prioritize `ideas/` + `syntheses/`
- Writing/format question → `topics/`

## Workflow

### Step 1: Understand the Question

Analyze the user's question:
- Which **domains/topics** does it involve?
- What **type of knowledge** is needed? (fact, rule, comparison, overview, recommendation)
- What **format** does the user expect? (brief answer, detailed analysis, comparison table, summary)
- What **keywords** to search for? (generate 3-5 search terms, including synonyms and aliases)

### Step 2: Search Relevant Pages

Use a **multi-strategy search** to maximize recall:

#### Strategy A: Index Scan
1. Read `wiki/index.md` to scan the full catalog
2. Identify pages with matching titles or summaries (typically 3-10 candidates)

#### Strategy B: Keyword Grep
3. **Use Grep tool** to search `wiki/` directory for keywords from Step 1
4. Search for both exact terms and related terms
5. This catches pages that index summaries might miss
6. Example: searching for "latency" should also try "delay", "response time"

#### Strategy C: Alias Matching
7. If initial searches return few results, search for known aliases
8. Check `aliases:` fields in frontmatter of related pages
9. Try partial matches (e.g., "RL" → "Reinforcement Learning")

#### Strategy D: Link Traversal
10. Read the most relevant pages found so far
11. Follow `[[wikilinks]]` in their `## Related` sections to discover connected pages
12. Read those linked pages if they seem relevant

#### Strategy E: Raw Source Fallback
13. If wiki pages are insufficient, search `raw/` for supplementary information
14. Use Grep on `raw/` directory with broader keywords
15. Cite raw sources separately from wiki pages

### Step 3: Synthesize Answer

Compose the answer following these rules:

#### Structure
- **Simple factual questions**: Direct answer in 2-5 sentences
- **Comparison questions**: Use a comparison table with clear dimensions
- **Overview questions**: Use headers to organize by sub-topic
- **How-to questions**: Step-by-step format with examples

#### Citation Requirements
- Every key claim must have a `[[wikilink]]` citation so the user can trace and verify
- Format: "According to [[page-name]], ..." or "...([[page-name]])"
- If citing raw sources, use the full path: `[[raw/domain/file.md]]`

#### Confidence Levels
- **Full coverage**: Wiki has comprehensive information → answer confidently with citations
- **Partial coverage**: Wiki has some relevant info → answer what's known, clearly mark gaps
- **No coverage**: Wiki has no relevant information → respond with:
  > "The wiki currently has no content on **[topic]**. Would you like me to:
  > 1. Search raw sources for any related notes?
  > 2. Create a placeholder page for future ingestion?
  > 3. Answer from general knowledge (without wiki backing)?"

#### Handling Contradictions
If two wiki pages contradict each other:
- Present both views with their sources
- Note the contradiction explicitly
- Suggest running `lint` to flag for resolution

### Step 4: Archival (auto-tiered)

#### Archival-value auto-score (don't miss valuable answers)

After the answer, **internally score** the answer and route to different paths:

| Score | Criteria | Action |
|---|---|---|
| **auto-archive (4/4)** | Answer synthesizes ≥ 5 wiki pages + contains comparison table / decision matrix / generational diagram + user explicit "reuse intent" (e.g. "I'll cite this later") | **Archive automatically** (no prompt), show archival result |
| **suggest-strong (3/4)** | ≥ 3 wiki pages + at least 1 structured output (table / list / taxonomy) | Strongly suggest archival with one-line prompt |
| **suggest-weak (2/4)** | 2 wiki pages + prose answer | Light prompt "archive this?" |
| **skip (1/4)** | 1-page factual lookup / "wiki has no content" / trivial / time-sensitive | Don't archive |

**auto-archive workflow** (no user prompt):
1. Generate slug: `YYYY-MM-DD-<topic-slug>` (3-5 kebab-case words extracted from question)
2. Create `wiki/syntheses/<slug>.md` with full frontmatter + answer
3. Append answer with: `> 📌 Archived as [[syntheses/<slug>]].`
4. Update index.md Syntheses table + log.md

**suggest-strong / suggest-weak workflow** (ask user):
> "This answer synthesizes N wiki pages with X comparison tables. Archive as a synthesis page for future `[[wikilink]]` reference? [y/n/change slug]"

If user agrees, same archival actions.

#### Synthesis skeleton (auto-filled)

```markdown
---
type: synthesis
domain: 科研   # inferred from the territory involved
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources:
  - <all referenced wiki pages>
tags: [<extracted from question keywords>]
aliases: []
---

# <title distilled from question>

## Question
<original question, user's verbatim words>

## Analysis
<answer body, preserving all [[wikilinks]]>

## Related
<wikilinks list of all referenced pages>
```

#### Back-link after archival

Automatically append to each **referenced wiki page's `## Related`** section: `[[syntheses/<slug>]] — <synthesis title>`. This way browsing a concept page in the future shows "this concept was discussed in these syntheses".

## Query Types

| Type | Example | Search Strategy | Output Format |
|------|---------|----------------|---------------|
| Fact | "What's the standard abstract structure?" | Index → specific topic page | Direct answer, 2-5 sentences |
| Comparison | "Difference between X and Y?" | Grep both terms → cross-page synthesis | Comparison table |
| Overview | "Most common mistakes in writing?" | Broad grep → traverse Common Pitfalls | Bulleted list with citations |
| How-to | "How do I write a Related Work section?" | Index → topic page → linked concepts | Step-by-step guide |
| Recommendation | "What knowledge should I add next?" | Lint gap analysis + index stats | Prioritized list |
| Fuzzy | "That paper about latency" | Grep synonyms → alias check → raw scan | Best match with confirmation |

## Fuzzy Query Handling

When the user's question is vague or uses informal language:

1. **Extract intent**: "that latency paper" → searching for papers about latency/delay
2. **Generate synonyms**: latency → delay, response time, RTT, timeout
3. **Search broadly**: Grep all synonyms across wiki/ and raw/
4. **Present candidates**: If multiple matches, show a numbered list:
   ```
   Found 3 possible matches:
   1. [[MEC]] — discusses delay decomposition in edge computing
   2. [[双时间尺度建模]] — models slow/fast timescale delays
   3. raw/research/papers/2026-04-06-latency-optimization.md

   Which one did you mean?
   ```
5. **Confirm before answering**: Don't assume — let the user pick

## Multi-Domain Queries

When a question spans multiple domains:
1. Search across all domain directories
2. Clearly separate information by domain in the answer
3. Look for cross-domain connections (pages with `domain: cross-domain`)
4. These are prime candidates for synthesis archival

## Timeline Recording

**Every query** (whether archived or not) appends to `log.md`:
```markdown
## [YYYY-MM-DD] query | <question summary>

- Question: "<user's original question>"
- Pages searched: [[page1]], [[page2]], ...
- Pages cited in answer: [[page3]], [[page4]]
- Archived: yes/no (if yes: wiki/syntheses/YYYY-MM-DD-<slug>.md)
- Coverage: full / partial / none
```

## Git Commit

If a synthesis page was created, execute git commit:
- Stage: synthesis page + index.md + log.md
- Commit message format: `query: filed synthesis on <topic>`

## Key Principles

1. **Wiki first**: Search compiled wiki layer first, then raw records only if needed
2. **Citation transparency**: Annotate source page for every key information point
3. **No fabrication**: If wiki has no relevant knowledge, say so directly — never mix general knowledge with wiki knowledge without labeling
4. **Archive valuable answers**: Overviews, comparisons, cross-page syntheses are most worth archiving
5. **Fuzzy is OK**: Users won't always use exact page names — be smart about matching
6. **Show your search**: Briefly mention which pages you searched, so the user knows the scope
