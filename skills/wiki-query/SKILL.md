---
name: wiki-query
description: "Answer questions based on your personal Wiki. Reads index to find relevant pages, synthesizes answers with citations, and optionally archives as a synthesis page. Trigger phrases: \"search wiki\", \"wiki query\", \"look up in wiki\", \"what does my wiki say about X\", \"check knowledge base\"."
---

# Wiki Query

## Core Function

Answer questions based on wiki content at `{{WIKI_PATH}}`, and optionally archive valuable answers as synthesis pages for compounding knowledge.

## Workflow

### Step 1: Understand the Question

Analyze the user's question:
- Which domains/topics does it involve?
- What type of knowledge is needed? (fact, rule, comparison, overview)
- What format does the user expect? (brief answer, detailed analysis, comparison table, summary)

### Step 2: Search Relevant Pages

1. Read `wiki/index.md` to scan the full catalog
2. Based on question keywords, identify potentially relevant pages (typically 3-10)
3. **Use Grep tool** to search `wiki/` directory for keywords, catching pages index might miss
4. Read these pages' content
5. If deeper information needed, read pages linked via `[[wikilink]]` from related pages
6. If wiki pages insufficient, read raw records in `raw/` for supplementary info

### Step 3: Synthesize Answer

Compose answer with:
- Clear structure (if complex question, use headers/tables)
- `[[wikilink]]` citations for every key claim — so user can trace and verify
- Explicit note if information is absent: "The wiki currently has no content on this"
- If raw sources provide additional context beyond wiki pages, cite those too

### Step 4: Optional Archival

After answering, ask user:
> "Would you like to archive this as a synthesis page?"

**Good candidates for archival:**
- Overview/survey type answers
- Comparison analyses
- Cross-page comprehensive analyses
- Answers the user is likely to reference again

If user agrees:
1. Create `wiki/syntheses/YYYY-MM-DD-<slug>.md` with full frontmatter
2. Add to `wiki/index.md` Syntheses table
3. Append to `log.md`

## Query Types

| Type | Example | Approach |
|------|---------|----------|
| Fact | "What's the standard abstract structure?" | Extract from corresponding topic page |
| Comparison | "Difference between X and Y?" | Cross-page synthesis, generate comparison table |
| Overview | "Most common mistakes in writing?" | Traverse Common Pitfalls across pages |
| Recommendation | "What knowledge should I add next?" | Combine lint gap analysis with wiki status |

## Timeline Recording

Every query operation (whether archived or not) appends to `log.md`:
```markdown
## [YYYY-MM-DD] query | <question summary>

- Pages searched: [[page1]], [[page2]], ...
- Archived: yes/no (if yes, record synthesis path)
```

## Git Commit

If a synthesis page was created, execute git commit:
- Commit message format: `query: filed synthesis on <topic>`

## Key Principles

1. **Wiki first**: Search compiled wiki layer first, then raw records only if needed
2. **Citation transparency**: Annotate source page for every key information point
3. **No fabrication**: If wiki has no relevant knowledge, say so directly
4. **Archive valuable answers**: Overviews, comparisons, cross-page syntheses are most worth archiving
