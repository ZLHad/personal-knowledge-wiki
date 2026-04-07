# Personal Knowledge Wiki

[中文版 README](README_CN.md)

> **Your LLM is not a chatbot. It's a persistent wiki maintainer.**

An open-source framework for building a **personal knowledge base** where you curate sources and ask questions, while **Claude Code** handles all the bookkeeping — summarizing, cross-referencing, filing, quality control, and maintenance.

One interactive script. Three Claude Code skills. Zero databases. Just plain markdown files that compound over time.

Inspired by [Andrej Karpathy's LLM Wiki](https://gist.github.com/karpathy/1dd0294ef9567971c1e4348a90d69285) pattern, [GBrain](https://github.com/jmozzart/gbrain)'s codified lint rules, and the [Obsidian](https://obsidian.md) local-first philosophy.

---

## Why This Exists

Traditional note-taking is broken:

- You write something down → forget where it is → never find it again
- Each conversation with an LLM produces insights → they vanish when the chat closes
- You accumulate hundreds of files → no cross-references, no quality control, no structure

This project fixes that by treating knowledge management as a **compilation process**:

```
                         ┌─────────────────────────────┐
  Conversations          │                             │
  Papers         ───→    │   LLM Compiler (Claude)     │   ───→  Structured Wiki
  Notes                  │                             │         with cross-references
  Articles               │   ingest │ query │ lint     │         and quality control
                         └─────────────────────────────┘
```

**Key insight from Karpathy**: The LLM doesn't just answer questions — it **maintains a persistent wiki**. Every piece of knowledge gets compiled into interconnected pages, not dumped into isolated files.

---

## How It Works

### Three-Layer Architecture

```
Your Wiki/
├── CLAUDE.md              # Constitution — schema, rules, workflows
├── README.md              # Human-readable description
├── log.md                 # Append-only operation timeline
│
├── raw/                   # Layer 1: Raw Sources (IMMUTABLE)
│   ├── research/          │   Human-owned. Write once, never modify.
│   │   ├── papers/        │   Conversation extracts, paper notes,
│   │   ├── notes/         │   articles, book notes, clipped web pages.
│   │   └── tools/         │
│   ├── reading/           │
│   └── assets/            │   Images, PDFs, attachments
│
├── wiki/                  # Layer 2: Compiled Knowledge (LLM-OWNED)
│   ├── index.md           │   Master catalog — LLM's entry point
│   ├── entities/          │   People, tools, journals, projects
│   ├── concepts/          │   Methods, theories, terms, principles
│   ├── topics/            │   Guides, norms, best practices
│   └── syntheses/         │   Archived query answers, analyses
│
└── meta/                  # Layer 3: Diagnostics
    └── reports/           │   Lint reports, health checks
```

**The core rule**: `raw/` is history (immutable), `wiki/` is truth (always current), `log.md` is the operation log (append-only).

### Three Operations

#### 1. Ingest — Feed knowledge in

Analyzes a conversation or file and **compiles** it into the wiki network. A single ingest typically touches **5-15 wiki pages** — creating/updating entity pages, concept pages, topic pages, and weaving `[[wikilinks]]` between them.

```
You: ingest this conversation
Claude:
  1. Analyzes content → identifies entities, concepts, topics
  2. Stores raw record in raw/ (immutable)
  3. Creates or updates 5-15 wiki pages
  4. Weaves [[wikilinks]] for cross-references
  5. Updates wiki/index.md and log.md
  6. Reports what was touched
```

**What can you ingest?**

| Input | How | Example |
|-------|-----|---------|
| Current conversation | "ingest this conversation" | After a paper revision session |
| External file | "ingest this file: /path/to/notes.md" | Paper reading notes from Zotero |
| Batch files | "ingest all .md files in /path/" | Migrating old notes |
| Pasted content | Just paste + "ingest this" | Web article, email, etc. |

#### 2. Query — Get knowledge out

Answers questions based on **your own accumulated knowledge**, not generic LLM knowledge. Every claim cites a `[[wikilink]]` source. Valuable answers can be archived as synthesis pages.

```
You: what does my wiki say about clean code principles?
Claude:
  1. Searches index + grep wiki/ for relevant pages
  2. Reads and synthesizes from your pages
  3. Returns answer with [[wikilink]] citations
  4. Asks: "Archive this as a synthesis page?"
```

#### 3. Lint — Keep it healthy

8 hard-coded deterministic rules + soft LLM analysis. Outputs structured reports to `meta/reports/`.

| # | Rule | What It Checks |
|---|------|---------------|
| 1 | Dead links | Every `[[wikilink]]` points to an existing file |
| 2 | Orphan pages | Every page has ≥1 inbound link |
| 3 | Frontmatter completeness | 7 required YAML fields present |
| 4 | Tag consistency | All tags in approved list |
| 5 | Source traceability | Entity/concept pages cite ≥1 raw source |
| 6 | Index sync | `wiki/index.md` matches actual files |
| 7 | File naming | Files follow naming conventions |
| 8 | Stale detection | Flags 90+ day old pages with newer sources |

**Why hard-coded rules?** Inspired by [GBrain](https://github.com/jmozzart/gbrain). Pure LLM judgment is unreliable for quality control — the LLM "forgets" to check certain rules. These 8 rules are **deterministic** and execute completely every time. Soft analysis (contradictions, thin pages, missing links) supplements them.

### Four Page Types

| Type | What It Stores | File Location | Example |
|------|---------------|---------------|---------|
| **Entity** | Named things: people, tools, journals, projects | `wiki/entities/` | `React.md`, `IEEE-TWC.md`, `Zotero.md` |
| **Concept** | Ideas, methods, principles, patterns | `wiki/concepts/` | `DRY.md`, `MARL.md`, `Clean-Code.md` |
| **Topic** | Guides, norms, accumulated best practices | `wiki/topics/` | `Git-Workflow.md`, `Code-Review-Guide.md` |
| **Synthesis** | Archived query answers, comparison analyses | `wiki/syntheses/` | `2026-04-10-X-vs-Y-comparison.md` |

Every page has:
- **YAML frontmatter**: type, domain, created, updated, sources, tags, aliases
- **Structured sections**: Overview/Definition → Details → Common Pitfalls → Related
- **`[[wikilink]]` cross-references**: bidirectional, first-mention-per-page

---

## Quick Start

### Prerequisites

| Tool | Required? | Purpose |
|------|-----------|---------|
| [Claude Code](https://claude.ai/code) | **Required** | The LLM engine that runs all operations |
| [Obsidian](https://obsidian.md) | Recommended | IDE for browsing wiki (graph view, wikilinks) |
| [Git](https://git-scm.com) | Recommended | Version control, track knowledge evolution |
| bash / zsh | Required | For the setup script |

### One-Command Setup

```bash
git clone https://github.com/ZLHad/personal-knowledge-wiki.git
cd personal-knowledge-wiki
bash scripts/setup.sh
```

### What the Setup Script Does

The script is **fully interactive** — it asks questions and builds everything for you:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Step 1/5: Wiki Location
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Where to create the wiki? ~/Documents/My Knowledge

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Step 2/5: Configure Your Domains
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Domain 1: research
  Sub-categories: papers, notes, tools
Domain 2: reading
  Sub-categories: books, articles
Domain 3: (enter to finish)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Step 3/5: Creating Wiki Structure
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[✓] raw/         (immutable sources)
[✓] wiki/        (LLM-maintained compiled knowledge)
[✓] meta/        (lint reports, diagnostics)
[✓] CLAUDE.md    (wiki schema)
[✓] log.md       (timeline)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Step 4/5: Installing Claude Code Skills
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[✓] wiki-ingest → ~/.claude/skills/wiki-ingest
[✓] wiki-lint   → ~/.claude/skills/wiki-lint
[✓] wiki-query  → ~/.claude/skills/wiki-query

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Step 5/5: Obsidian Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[✓] Minimal theme installed
[✓] 7 plugins downloaded and registered
[✓] Wikilink mode configured
```

### After Setup

```bash
# 1. Open your wiki folder in Obsidian as a vault
# 2. Enable community plugins: Settings → Community plugins → Turn off Safe Mode → Enable all

# 3. Start Claude Code (from ANY directory!)
claude

# 4. Have a productive conversation, then:
> ingest this conversation

# 5. Query your accumulated knowledge:
> search wiki: what do I know about X?

# 6. Run a health check:
> lint wiki
```

### Manual Setup (No Script)

If you prefer to set things up yourself:

1. Copy `templates/CLAUDE.md` to your wiki directory, replace `{{placeholders}}` with your values
2. Create directory structure: `raw/`, `wiki/{entities,concepts,topics,syntheses}`, `meta/reports/`
3. Copy `templates/index.md` → `wiki/index.md`, `templates/log.md` → `log.md`
4. Copy `skills/` contents to `~/.claude/skills/`, replace `{{WIKI_PATH}}` in each SKILL.md
5. (Optional) Configure Obsidian vault manually

---

## Usage Guide

### Daily Workflow

#### Scenario 1: After a productive conversation

```
You: (finish discussing a code review with Claude)
You: ingest this conversation

Claude: Analyzing conversation...
  - Type: technical discussion
  - Entities: ESLint, Prettier, VS Code
  - Concepts: linting pipeline, auto-formatting
  - Topics: Code Review Guide

  Confirm? (y)

Claude: Ingest complete!
  Raw record: raw/work/tools/2026-04-07-eslint-prettier-setup.md
  Pages touched: 7 (3 new + 4 updated)
  New: [[ESLint]], [[Prettier]], [[Linting-Pipeline]]
  Updated: [[VS-Code]], [[Code-Review-Guide]], ...
```

#### Scenario 2: Before starting work

```
You: search wiki: what are my code review best practices?

Claude: Based on your wiki:
  From [[Code-Review-Guide]]:
  - Always run [[ESLint]] before submitting...
  - Check for [[DRY]] violations in new code...
  From [[Clean-Code]]:
  - Functions should do one thing...

  Archive this as a synthesis page? (y/n)
```

#### Scenario 3: Periodic maintenance

```
You: lint wiki

Claude: Wiki Lint Report - 2026-04-07
  | Check              | Status | Issues |
  |--------------------|--------|--------|
  | 1. Dead links      | PASS   | 0      |
  | 2. Orphan pages    | FAIL   | 2      |
  | 3. Frontmatter     | PASS   | 0      |
  ...
  Overall: 7/8 passed, 1 warning

  Auto-fix orphan pages? (y/n)
```

### Skills Work Globally

All three skills are installed to `~/.claude/skills/` with your wiki path hardcoded. You can trigger them **from any project directory**:

```bash
# Working on a React project
cd ~/projects/my-app
claude
> ingest this conversation    # → saves to your wiki, not the React project

# Working on a paper
cd ~/papers/my-paper
claude
> search wiki: how to write related work?   # → queries your wiki
```

### Trigger Phrases

| Operation | Trigger Phrases |
|-----------|----------------|
| **Ingest** | "ingest this conversation", "save to wiki", "extract knowledge", "wiki ingest", "update knowledge base" |
| **Query** | "search wiki", "wiki query", "check knowledge base", "what does my wiki say about", "look up in wiki" |
| **Lint** | "lint wiki", "wiki health check", "wiki diagnostics", "check wiki" |

### Adding New Domains

As your interests grow, you can add new knowledge domains at any time:

```
You: add a "programming" category to the knowledge base

Claude: (automatically modifies three places)
  1. CLAUDE.md — adds raw/programming/ to architecture + "programming" tag
  2. wiki-ingest SKILL.md — adds domain routing
  3. Creates raw/programming/ directory
```

---

## Obsidian Integration

The setup script configures [Obsidian](https://obsidian.md) as the visual "IDE" for your wiki.

### Pre-installed Theme & Plugins

| Component | Purpose | Why |
|-----------|---------|-----|
| **Minimal** (theme) | Clean wiki-style typography | By Obsidian CEO kepano; best Dataview table styling |
| **Dataview** | Dynamic tables from YAML frontmatter | Query pages by domain, tag, update date |
| **Templater** | Template engine for new pages | Quick-create pages with correct frontmatter |
| **Obsidian Git** | Auto-backup via git | Full history, rollback, multi-device sync |
| **Tag Wrangler** | Batch rename/merge tags | Essential for frontmatter-heavy vaults |
| **Style Settings** | Theme customization GUI | Adjust colors, fonts, layout without CSS |
| **Iconize** | File/folder icons | Visual category indicators in sidebar |
| **Excalidraw** | Embedded whiteboard/diagrams | Concept maps, architecture diagrams |

### Browsing Your Wiki

| Action | How |
|--------|-----|
| Jump to page | `Cmd+O` → type page name |
| Follow wikilink | `Cmd+Click` on `[[link]]` |
| Graph view | `Cmd+G` or sidebar icon |
| Global search | `Cmd+Shift+F` |

### Example Dataview Query

Add this to any page to see a dynamic table:

````markdown
```dataview
TABLE domain, updated, tags
FROM "wiki/concepts"
SORT updated DESC
```
````

---

## Design Decisions

### Why plain text markdown?

- Human and LLM can both read/write directly
- `git diff` shows knowledge evolution clearly
- Obsidian-compatible out of the box
- Zero dependencies — no database, no vector store, no server

### Why overwrite instead of append?

Wiki pages represent **compiled truth** — the latest understanding. When new knowledge contradicts old content, the old content gets replaced. History is preserved in `raw/` (immutable source records) and `log.md` (operation timeline), not in wiki pages.

### Why 5-15 pages per ingest?

The old pattern of "one conversation → one standalone file" creates knowledge silos. Requiring each ingest to update the entire wiki network — entities, concepts, topics, cross-references — ensures knowledge is **woven**, not archived. The value compounds as cross-references multiply.

### Why Obsidian as the IDE?

As [Karpathy noted](https://x.com/karpathy/status/1761467904737067456): plain-text files on disk, extensive plugin ecosystem, high composability with other tools. And as [Kepano (Obsidian CEO) suggested](https://x.com/kepano/status/2039831289533227446): Obsidian is the browser, Claude Code is the engine.

---

## Project Structure

```
personal-knowledge-wiki/
├── README.md                  # English documentation (this file)
├── README_CN.md               # Chinese documentation
├── LICENSE                    # MIT License
├── .gitignore
│
├── templates/                 # Template files with {{placeholders}}
│   ├── CLAUDE.md              # Wiki schema template
│   ├── index.md               # Empty index template
│   └── log.md                 # Initial log template
│
├── skills/                    # Claude Code skills (installed to ~/.claude/skills/)
│   ├── wiki-ingest/           # Knowledge ingestion skill
│   │   ├── SKILL.md           # Skill definition
│   │   └── references/        # Extraction strategy guides
│   │       ├── academic-writing-guide.md
│   │       ├── technical-task-guide.md
│   │       └── reading-notes-guide.md
│   ├── wiki-lint/             # Health check skill
│   │   └── SKILL.md           # 8 hard rules + soft analysis
│   └── wiki-query/            # Knowledge retrieval skill
│       └── SKILL.md           # Search + synthesize + archive
│
├── scripts/                   # Automation
│   └── setup.sh               # Interactive one-command setup
│
└── examples/                  # Example wiki pages
    ├── entity-example.md      # Sample entity page (React)
    └── concept-example.md     # Sample concept page (DRY principle)
```

---

## Contributing

This is a framework, not a product. Fork it, customize it, make it yours.

### Ideas for Extension

- [ ] Additional extraction guides (meeting notes, code review, lecture notes)
- [ ] Dataview query template library
- [ ] CSS snippets for enhanced wiki styling
- [ ] Additional lint rules (circular references, broken images, etc.)
- [ ] Export skills (Marp slides, PDF summary, cheat sheet generator)
- [ ] Spaced repetition skill (surface pages for periodic review)
- [ ] Multi-vault support (separate vaults for work/personal)

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-extraction-guide`)
3. Make your changes
4. Submit a Pull Request

---

## FAQ

**Q: Does this work with GPT / other LLMs?**
A: The skills are written for Claude Code, but the architecture (CLAUDE.md schema, directory structure, page formats) is LLM-agnostic. You could adapt the skills for other LLM tools.

**Q: Can I use this without Obsidian?**
A: Yes. Obsidian is optional — it's just a nice viewer. The wiki is plain markdown files. Any editor works. You lose graph view and wikilink navigation, but the core system works fine.

**Q: How big can the wiki get?**
A: There's no hard limit. The system uses plain text files + YAML frontmatter, which scales to thousands of pages. Obsidian handles large vaults well. The LLM reads pages on-demand via index.md, so it doesn't need to load everything.

**Q: Is my data private?**
A: Everything stays on your local machine. No data is sent anywhere except to the Claude API during active conversations (same as normal Claude Code usage). The wiki files are just markdown on disk.

**Q: Can I sync across devices?**
A: Push your wiki to a private GitHub repo. The setup script can initialize git for you. Obsidian Git plugin handles auto-commit/push.

---

## Credits

- [Andrej Karpathy](https://gist.github.com/karpathy/1dd0294ef9567971c1e4348a90d69285) — LLM Wiki pattern and the core insight
- [GBrain](https://github.com/jmozzart/gbrain) — Codified lint rules inspiration
- [Obsidian](https://obsidian.md) — Local-first knowledge IDE
- [Claude Code](https://claude.ai/code) — LLM engine powering all operations
- [Kepano](https://x.com/kepano) — Obsidian CEO, vault architecture advice

---

## Contact

- **Author**: ZLHad
- **Email**: zhangczssx@gmail.com
- **Issues**: [GitHub Issues](https://github.com/ZLHad/personal-knowledge-wiki/issues)

## License

[MIT](LICENSE) — Use it however you want. Attribution appreciated but not required.
