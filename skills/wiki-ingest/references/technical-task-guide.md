# Technical Task Extraction Guide

## Focus

Technical tasks (tool configuration, debugging, workflow optimization) produce **reusable methods and decisions**. The value is in recording what worked, what didn't, and why.

## Raw Record Structure

```markdown
---
extraction_date: YYYY-MM-DDTHH:MM:SSZ
conversation_type: technical-task
main_topics: [topic list]
importance_level: medium
tags: [tag list]
---

# <Task Name> - YYYYMMDD

## Executive Summary
150-300 words: what was accomplished, key decisions, tools used.

## Problem & Context
- What needed to be done
- Initial constraints/requirements

## Solution Process
### Step 1: ...
- What was tried
- Key commands/code
- Result

### Step 2: ...
(repeat...)

## Key Decisions
| Decision | Options Considered | Choice | Rationale |
|----------|-------------------|--------|-----------|
| ... | A, B, C | B | ... |

## Pitfalls Encountered
- ⚠️ Problem: ...
  - Root cause: ...
  - Fix: ...

## Reusable Patterns
1. 📌 ...
2. 📌 ...
```

## Wiki Update Guidance

From technical tasks, typically update:
- **Entity pages**: Tools, platforms, services used → `wiki/entities/`
- **Concept pages**: Methods, patterns, design decisions → `wiki/concepts/`
- **Topic pages**: Best practices, configuration guides → `wiki/topics/`
