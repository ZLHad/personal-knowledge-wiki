---
name: wiki-export
description: "Export your personal Wiki as a static website. Recommended path: one-command Quartz install via `bash scripts/setup-quartz.sh` (Obsidian-native, graph view, KaTeX). Also supports MkDocs (Material theme) and plain HTML output. Generates navigation, search index, and styled pages from your wiki/ directory. Trigger phrases: \"export wiki\", \"publish wiki\", \"build wiki site\", \"generate static site\", \"wiki to website\", \"deploy wiki\", \"setup quartz\", \"quartz site\"."
---

# Wiki Export

## Core Function

Export the `wiki/` layer of your personal knowledge base as a browsable static website. This is a local-first alternative to Obsidian Publish — you own the output and can host it anywhere (GitHub Pages, Netlify, Vercel, or just open `index.html` locally).

## Wiki Location

**Wiki path**: `{{WIKI_PATH}}`

## Supported Output Formats

| Format | Best For | Requirements |
|--------|----------|-------------|
| **MkDocs Material** | Full-featured site with search, dark mode, navigation | `pip install mkdocs-material` |
| **Quartz** | Obsidian-native look with graph view, backlinks | `npx quartz` (Node.js) |
| **Simple HTML** | Zero dependencies, offline browsing | None (built-in converter) |

## ⚡ Quick Start: Quartz (Recommended Default)

For most users, **Quartz is the fastest path to a polished web version** because:

- It's **purpose-built for Obsidian vaults** — reads `[[wikilinks]]` natively, no conversion needed
- Handles **LaTeX formulas** via KaTeX out of the box
- Renders **Chinese filenames and content** correctly
- Provides **graph view, backlinks, hover previews, search, dark mode** by default
- Can be deployed to GitHub Pages / Cloudflare / Netlify / Vercel with zero extra config

### One-command install

```bash
bash scripts/setup-quartz.sh
```

This script:
1. Clones Quartz into `site/` (gitignored)
2. Installs npm dependencies
3. Pre-configures `quartz.config.ts` (title, locale, ignorePatterns excluding dashboard.md)
4. Does NOT touch or copy your `wiki/` content — it points directly at it via `--directory` flag

### Preview locally (with hot reload)

```bash
cd site && npx quartz build --directory ../wiki --serve --watch --port 4321
```

Then open **http://localhost:4321** — you'll see your wiki with graph view, search, and popover previews.

**Hot reload is on** (`--watch` flag): edits to any `wiki/*.md` file in Obsidian trigger an incremental rebuild (~200ms) and the browser refreshes automatically. Leave this server running while you write.

### Update workflow (three scenarios)

| Scenario | Command | Behavior |
|----------|---------|----------|
| **Hot reload** (daily writing) | `... --serve --watch --port 4321` | Edit-save in Obsidian → auto rebuild + browser refresh |
| **One-shot preview** | `... --serve --port 4321` | Manual start, full rebuild each time, `Ctrl+C` to stop |
| **Deployed** (GitHub/Cloudflare/Netlify/Vercel) | Platform CI runs `npx quartz build --directory ../wiki` on git push | Edit → commit → push → deployed in 1-2 min |

### Reset

```bash
rm -rf site/ && bash scripts/setup-quartz.sh
```

**Only skip the Quick Start path** if the user explicitly asks for MkDocs, Simple HTML, or a different SSG.

---

## Workflow (for non-Quartz exports or custom flows)

### Step 1: Choose Export Format

Ask the user:
> "Which export format would you like?
> 1. **Quartz** (recommended) — looks like Obsidian, has graph view + KaTeX + backlinks. **Use `bash scripts/setup-quartz.sh` for one-command install.**
> 2. **MkDocs Material** — best for formal doc-site aesthetic with search + navigation + dark mode
> 3. **Simple HTML** — zero dependencies, just open in browser
>
> Or specify a custom static site generator."

### Step 2: Prepare Content

#### 2.1 Collect Exportable Pages
- Scan `wiki/` directory for all `.md` files
- Include `wiki/index.md` as the home page
- Include `wiki/dashboard.md` if it exists
- **Exclude** files matching `.obsidian/`, `meta/`, `raw/` (these are internal)

#### 2.2 Process Wikilinks
Convert Obsidian `[[wikilinks]]` to standard markdown links:
- `[[Page-Name]]` → `[Page-Name](page-name.md)`
- `[[Page-Name|Display Text]]` → `[Display Text](page-name.md)`
- Handle nested paths: `[[topics/Guide]]` → `[Guide](topics/guide.md)`
- **Important**: Create a link map first to resolve shortest-path links correctly

#### 2.3 Process Frontmatter
- Keep YAML frontmatter for generators that support it (MkDocs, Quartz)
- For Simple HTML: extract `title` from frontmatter or first `# heading`
- Add navigation metadata if needed

#### 2.4 Process Assets
- Copy `raw/assets/` images to the output directory
- Rewrite image paths in markdown to point to new locations
- Handle relative paths correctly

### Step 3: Generate Site

#### Option A: MkDocs Material

1. Create `mkdocs.yml` configuration:
```yaml
site_name: "{{WIKI_NAME}}"
theme:
  name: material
  features:
    - navigation.instant
    - navigation.sections
    - navigation.expand
    - search.suggest
    - search.highlight
    - content.tabs.link
  palette:
    - scheme: default
      primary: indigo
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - scheme: slate
      primary: indigo
      toggle:
        icon: material/brightness-4
        name: Switch to light mode

nav:
  - Home: index.md
  - Territories:
    - (auto-generated from wiki/territories/)   # research field maps
  - Papers:
    - (auto-generated from wiki/papers/)        # per-paper briefs
  - Concepts:
    - (auto-generated from wiki/concepts/)      # methods / theories / terms
  - Entities:
    - (auto-generated from wiki/entities/)      # journals / tools / people
  - Topics:
    - (auto-generated from wiki/topics/)        # writing norms / guides
  - Ideas:
    - (auto-generated from wiki/ideas/)         # user's incubating research ideas
  - Syntheses:
    - (auto-generated from wiki/syntheses/)

plugins:
  - search
  - tags

markdown_extensions:
  - toc:
      permalink: true
  - tables
  - admonition
  - pymdownx.details
  - pymdownx.superfences
```

2. Copy processed markdown files to `docs/` directory
3. Run `mkdocs build` to generate static site in `site/`
4. Optionally run `mkdocs serve` for local preview

#### Option B: Quartz

1. Initialize Quartz if not present:
```bash
npx quartz create
```

2. Copy processed markdown files to `content/` directory
3. Configure `quartz.config.ts`:
   - Set `pageTitle` to wiki name
   - Enable `Graph`, `Backlinks`, `TableOfContents` components
   - Configure `ContentIndex` for search

4. Build:
```bash
npx quartz build
```

#### Option C: Simple HTML

Generate standalone HTML files with embedded CSS:

1. For each markdown file:
   - Convert markdown → HTML (using python `markdown` library or `pandoc`)
   - Wrap in HTML template with navigation sidebar
   - Include minimal CSS for readability

2. Generate `index.html` with:
   - Full page listing organized by type
   - Simple search (JavaScript-based, no server needed)
   - Navigation links

3. CSS template (clean, readable):
   - Max-width content container
   - Sidebar navigation
   - Responsive design
   - Code block syntax highlighting
   - Table styling

### Step 4: Output and Deploy Options

After building, inform the user:

```
## Export Complete

**Format**: MkDocs Material / Quartz / Simple HTML
**Output**: {{WIKI_PATH}}/site/ (or /public/)
**Pages exported**: N

### Preview Locally
  mkdocs serve          # MkDocs
  npx quartz build --directory ../wiki --serve --watch --port 4321  # Quartz (with hot reload)
  open site/index.html  # Simple HTML

### Deploy Options
1. **GitHub Pages**: Push to gh-pages branch
   git subtree push --prefix site origin gh-pages

2. **Netlify**: Connect repo, set build command
   Build: mkdocs build
   Publish: site/

3. **Vercel**: Import project
   Output: site/

4. **Self-hosted**: Copy site/ to any web server
```

## Privacy Controls

Before exporting, check with the user:
- "Should I export **all** wiki pages, or only specific domains?"
- "Any pages to **exclude** from export? (e.g., personal notes)"
- Check for sensitive content markers in frontmatter (e.g., `private: true`)

Pages with `private: true` in frontmatter are **always excluded** from export.

## Incremental Export

If the site was previously exported:
- Only re-process files with `updated:` date newer than last export
- Rebuild navigation and search index
- Store last export timestamp in `meta/last-export.json`

## Git Commit

After export:
- Don't commit the generated site files to the wiki repo
- Suggest user create a separate repo or branch for the published site
- If user wants it in the same repo, add `site/` to `.gitignore`

## Key Principles

1. **Wiki content only**: Never export `raw/` or `meta/` — only compiled wiki pages
2. **Privacy first**: Always check for private/sensitive pages before export. Default excludes: Obsidian-only Dataview homepage (e.g. `wiki/dashboard.md`); `wiki/ideas/` pages with `status: seed` or `status: shelved` (personal in-progress ideas, not for public)
3. **Links must work**: Every `[[wikilink]]` must become a working HTML link
4. **Preserve structure**: Maintain the **7 page types** organization:
   - `wiki/territories/` — research field maps
   - `wiki/papers/` — per-paper briefs
   - `wiki/concepts/` — methods / theories
   - `wiki/entities/` — journals / tools / people
   - `wiki/topics/` — writing norms
   - `wiki/ideas/` — incubating ideas (selective export, only `status ≥ sketched`)
   - `wiki/syntheses/` — archived query answers
5. **Offline-friendly**: Generated site should work without internet connection

## Quartz-specific guidance (field-tested 2026-04-11)

If using Quartz (`npx quartz build --serve`), the following gotchas were learned the hard way:

1. **Quartz does NOT follow symlinks**: `ln -s ../wiki content` is silently ignored by globby, resulting in "Found 0 input files". Solution: use `rsync -a --delete --exclude='.obsidian' --exclude='dashboard.md' ../wiki/ content/` to mirror content, re-rsync after each wiki change.

2. **`.gitignore` swallows everything**: Quartz defaults `gitignore: true`. If `site/` is in the parent repo's `.gitignore`, Quartz treats every `site/content/*.md` as ignored, again "Found 0 input files". Solution: edit `site/quartz/util/glob.ts` to set `gitignore: false`.

3. **LaTeX unicode warnings**: `$...Chinese...$` triggers KaTeX `unicodeTextInMathMode` warning (non-blocking). Clean by wrapping Chinese in `\text{...}` inside math environments.

4. **Critical config options**: set `pageTitle` to a user-friendly name; `baseUrl: "localhost:4321"`; `ignorePatterns` includes the dashboard page; `defaultDateType: "modified"`.

5. **Recommended workflow**:
   ```bash
   cd site
   rsync -a --delete --exclude='.obsidian' --exclude='dashboard.md' ../wiki/ content/
   npx quartz build --serve --port 4321
   ```
