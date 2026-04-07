# Reading Notes Extraction Guide

## Focus

Reading content (papers, books, articles, podcasts, videos) — the value lies in **distilling core ideas and capturing personal reflections**.

## Raw Record Structure

```markdown
---
extraction_date: YYYY-MM-DDTHH:MM:SSZ
conversation_type: reading-notes
source_type: paper/book/article/podcast/video
source_title: <original title>
source_author: <author>
source_url: <link if available>
main_topics: [topic list]
importance_level: high/medium/low
tags: [tag list]
---

# <Source Title> Reading Notes - YYYYMMDD

## Executive Summary
200-300 words: what was read, core takeaways, connections to existing knowledge.

## Core Ideas
Ranked by importance, for each:
1. **Claim**: One-sentence summary
2. **Original quote**: Key citation (if available)
3. **Personal understanding**: Restate in own words
4. **Connection to existing knowledge**: Which wiki pages relate

## Methodology/Framework
If the source introduces reusable methods or frameworks:
- Framework name
- Core steps/elements
- Applicable scenarios
- Limitations

## Key Terms
| Term | Definition | Notes |
|------|-----------|-------|
| ... | ... | ... |

## Personal Reflections
- What do I agree with? Why?
- What do I question? Why?
- What existing beliefs changed?
- How can I apply this to my work?

## Action Items
- [ ] TODOs generated from this reading
```

## Wiki Update Guidance

From reading notes, typically update:
- **Entity pages**: Tools, projects, people mentioned → `wiki/entities/`
- **Concept pages**: New methods, theories, terms → `wiki/concepts/`
- **Topic pages**: Additions to existing topics (less common) → `wiki/topics/`

## Routing Guide

| Information Type | Where to File |
|-----------------|---------------|
| New methodology/framework | Create or update concept page |
| New tool/project/person | Create or update entity page |
| New understanding of existing concept | Update Details in concept page |
| Pure personal feelings | Keep in raw record only |
| Reusable best practices | Update or create topic page |
