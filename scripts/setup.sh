#!/bin/bash
#
# Personal Knowledge Wiki — Interactive Setup Script
# Inspired by Andrej Karpathy's LLM Wiki pattern
#
# Usage: bash setup.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# ─── Welcome ─────────────────────────────────────────────────────
print_header "Personal Knowledge Wiki Setup"

echo -e "This script will set up a personal knowledge wiki powered by"
echo -e "Claude Code + Obsidian, based on ${BOLD}Andrej Karpathy's LLM Wiki${NC} pattern."
echo ""
echo -e "Architecture: ${CYAN}raw/${NC} (immutable sources) → ${CYAN}wiki/${NC} (compiled knowledge) → ${CYAN}meta/${NC} (reports)"
echo -e "Operations:   ${GREEN}ingest${NC} | ${GREEN}query${NC} | ${GREEN}lint${NC}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# ─── Step 1: Wiki Location ──────────────────────────────────────
print_header "Step 1/5: Wiki Location"

read -p "Where to create the wiki? (full path, e.g. ~/Documents/Personal Knowledge): " WIKI_PATH
WIKI_PATH="${WIKI_PATH/#\~/$HOME}"

if [ -d "$WIKI_PATH" ]; then
    print_warn "Directory already exists: $WIKI_PATH"
    read -p "Continue and set up inside it? (y/n): " CONFIRM
    [[ "$CONFIRM" != "y" ]] && echo "Aborted." && exit 1
fi

mkdir -p "$WIKI_PATH"
print_step "Wiki directory: $WIKI_PATH"

# ─── Step 2: Wiki Name & Domains ────────────────────────────────
print_header "Step 2/5: Configure Your Domains"

read -p "Wiki name (e.g. 'Personal Knowledge', 'Research Wiki'): " WIKI_NAME
WIKI_NAME="${WIKI_NAME:-Personal Knowledge}"

echo ""
echo "Define your knowledge domains (these become top-level directories under raw/)."
echo "Examples: research, reading, work, life, programming"
echo ""

DOMAINS=()
DOMAIN_TAGS=""
i=1
while true; do
    read -p "Domain $i (leave empty to finish): " DOMAIN
    [[ -z "$DOMAIN" ]] && break
    DOMAINS+=("$DOMAIN")

    read -p "  Sub-categories for '$DOMAIN' (comma-separated, e.g. 'papers,notes,tools'): " SUBS
    IFS=',' read -ra SUB_ARRAY <<< "$SUBS"

    mkdir -p "$WIKI_PATH/raw/$DOMAIN"
    for sub in "${SUB_ARRAY[@]}"; do
        sub=$(echo "$sub" | xargs)  # trim whitespace
        mkdir -p "$WIKI_PATH/raw/$DOMAIN/$sub"
    done

    DOMAIN_TAGS="${DOMAIN_TAGS}- \`$DOMAIN\`"
    if [ ${#SUB_ARRAY[@]} -gt 0 ]; then
        DOMAIN_TAGS="${DOMAIN_TAGS}: $(printf "\`%s\`, " "${SUB_ARRAY[@]}" | sed 's/, $//')"
    fi
    DOMAIN_TAGS="${DOMAIN_TAGS}\n"

    print_step "Created: raw/$DOMAIN/ with ${#SUB_ARRAY[@]} sub-categories"
    ((i++))
done

if [ ${#DOMAINS[@]} -eq 0 ]; then
    DOMAINS=("general")
    mkdir -p "$WIKI_PATH/raw/general"
    DOMAIN_TAGS="- \`general\`\n"
    print_warn "No domains specified, created default: raw/general/"
fi

# ─── Step 3: Create Directory Structure ──────────────────────────
print_header "Step 3/5: Creating Wiki Structure"

mkdir -p "$WIKI_PATH/raw/assets"
mkdir -p "$WIKI_PATH/wiki/entities"
mkdir -p "$WIKI_PATH/wiki/concepts"
mkdir -p "$WIKI_PATH/wiki/topics"
mkdir -p "$WIKI_PATH/wiki/syntheses"
mkdir -p "$WIKI_PATH/meta/reports"

print_step "raw/         (immutable sources)"
print_step "raw/assets/  (images, PDFs, attachments)"
print_step "wiki/        (LLM-maintained compiled knowledge)"
print_step "  entities/  (people, tools, journals, projects)"
print_step "  concepts/  (methods, theories, terms)"
print_step "  topics/    (guides, norms, best practices)"
print_step "  syntheses/ (archived query answers)"
print_step "meta/        (lint reports, diagnostics)"

# ─── Generate CLAUDE.md ──────────────────────────────────────────
print_info "Generating CLAUDE.md..."

TODAY=$(date +%Y-%m-%d)

# Build architecture tree
ARCH_TREE=""
for domain in "${DOMAINS[@]}"; do
    ARCH_TREE="${ARCH_TREE}│   ├── ${domain}/\n"
    if [ -d "$WIKI_PATH/raw/$domain" ]; then
        for sub in "$WIKI_PATH/raw/$domain"/*/; do
            if [ -d "$sub" ]; then
                subname=$(basename "$sub")
                ARCH_TREE="${ARCH_TREE}│   │   ├── ${subname}/\n"
            fi
        done
    fi
done

# Process CLAUDE.md template — use python for safe multiline replacement
DOMAIN_1="${DOMAINS[0]:-general}"
DOMAIN_2="${DOMAINS[1]:-}"
DOMAIN_3="${DOMAINS[2]:-}"

# Collect sub-directory names for architecture tree
SUB_1=""
SUB_2=""
if [ -d "$WIKI_PATH/raw/$DOMAIN_1" ]; then
    SUB_DIRS=()
    for sub in "$WIKI_PATH/raw/$DOMAIN_1"/*/; do
        [ -d "$sub" ] && SUB_DIRS+=("$(basename "$sub")")
    done
    SUB_1="${SUB_DIRS[0]:-sub-category-1}"
    SUB_2="${SUB_DIRS[1]:-sub-category-2}"
fi

python3 - "$PROJECT_ROOT/templates/CLAUDE.md" "$WIKI_PATH/CLAUDE.md" \
    "$WIKI_NAME" "$TODAY" "$DOMAIN_1" "${DOMAIN_2:-other}" "${DOMAIN_3:-other}" \
    "$SUB_1" "$SUB_2" <<'PYEOF'
import sys
template_path = sys.argv[1]
output_path = sys.argv[2]
wiki_name = sys.argv[3]
today = sys.argv[4]
domain_1 = sys.argv[5]
domain_2 = sys.argv[6]
domain_3 = sys.argv[7]
sub_1 = sys.argv[8] if len(sys.argv) > 8 and sys.argv[8] else "sub-category-1"
sub_2 = sys.argv[9] if len(sys.argv) > 9 and sys.argv[9] else "sub-category-2"

with open(template_path, 'r') as f:
    content = f.read()

# Build domain tags
domain_tags_input = sys.stdin.read() if not sys.stdin.isatty() else ""
# Domain tags are passed via environment instead

content = content.replace("{{WIKI_NAME}}", wiki_name)
content = content.replace("{{DATE}}", today)
content = content.replace("{{DOMAIN_1}}", domain_1)
content = content.replace("{{DOMAIN_2}}", domain_2)
content = content.replace("{{DOMAIN_3}}", domain_3)
content = content.replace("{{SUB_1}}", sub_1)
content = content.replace("{{SUB_2}}", sub_2)
content = content.replace("{{SUB_TAGS}}", "- (add your sub-tags here)")
content = content.replace("{{TOOL_TAGS}}", "- (add your tool tags here)")

with open(output_path, 'w') as f:
    f.write(content)
PYEOF

# Now replace DOMAIN_TAGS using python (handles multiline safely)
python3 -c "
import sys
domain_tags = sys.argv[1]
path = sys.argv[2]
with open(path, 'r') as f:
    content = f.read()
content = content.replace('{{DOMAIN_TAGS}}', domain_tags)
with open(path, 'w') as f:
    f.write(content)
" "$(echo -e "$DOMAIN_TAGS")" "$WIKI_PATH/CLAUDE.md"

print_step "CLAUDE.md (wiki schema)"

# Generate log.md
sed "s|{{DATE}}|${TODAY}|g" "$PROJECT_ROOT/templates/log.md" > "$WIKI_PATH/log.md"
print_step "log.md (timeline)"

# Copy index.md
cp "$PROJECT_ROOT/templates/index.md" "$WIKI_PATH/wiki/index.md"
print_step "wiki/index.md (master catalog)"

# ─── Step 4: Install Claude Code Skills ──────────────────────────
print_header "Step 4/5: Installing Claude Code Skills"

SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

for skill in wiki-ingest wiki-lint wiki-query wiki-migrate; do
    SKILL_SRC="$PROJECT_ROOT/skills/$skill"
    SKILL_DST="$SKILLS_DIR/$skill"

    if [ -d "$SKILL_DST" ]; then
        print_warn "$skill already exists, backing up to ${skill}.bak"
        mv "$SKILL_DST" "${SKILL_DST}.bak"
    fi

    cp -r "$SKILL_SRC" "$SKILL_DST"

    # Replace wiki path placeholder
    find "$SKILL_DST" -name "*.md" -exec sed -i '' "s|{{WIKI_PATH}}|${WIKI_PATH}|g" {} \; 2>/dev/null || \
    find "$SKILL_DST" -name "*.md" -exec sed -i "s|{{WIKI_PATH}}|${WIKI_PATH}|g" {} \;

    print_step "Installed skill: $skill → $SKILL_DST"
done

# ─── Step 5: Obsidian Setup ─────────────────────────────────────
print_header "Step 5/5: Obsidian Configuration"

read -p "Install Obsidian plugins and theme? (y/n): " INSTALL_OB
if [[ "$INSTALL_OB" == "y" ]]; then
    OB_DIR="$WIKI_PATH/.obsidian"
    mkdir -p "$OB_DIR/plugins" "$OB_DIR/themes"

    # app.json
    cat > "$OB_DIR/app.json" << 'APPEOF'
{
  "useMarkdownLinks": false,
  "newLinkFormat": "shortest",
  "attachmentFolderPath": "raw/assets",
  "showFrontmatter": true,
  "readableLineLength": true,
  "strictLineBreaks": false
}
APPEOF
    print_step "Obsidian wikilink mode configured"

    # Helper: download with retry and validation
    download_file() {
        local url="$1"
        local dest="$2"
        local desc="$3"
        local attempts=0
        local max_attempts=3

        while [ $attempts -lt $max_attempts ]; do
            curl -sL --connect-timeout 10 --max-time 60 -o "$dest" "$url" 2>/dev/null
            if [ -f "$dest" ] && [ -s "$dest" ]; then
                return 0
            fi
            ((attempts++))
            [ $attempts -lt $max_attempts ] && sleep 1
        done

        print_warn "Failed to download $desc after $max_attempts attempts"
        rm -f "$dest"
        return 1
    }

    # Install Minimal theme
    print_info "Downloading Minimal theme..."
    mkdir -p "$OB_DIR/themes/Minimal"
    download_file \
        "https://github.com/kepano/obsidian-minimal/releases/latest/download/theme.css" \
        "$OB_DIR/themes/Minimal/theme.css" "Minimal theme CSS"
    download_file \
        "https://raw.githubusercontent.com/kepano/obsidian-minimal/master/manifest.json" \
        "$OB_DIR/themes/Minimal/manifest.json" "Minimal theme manifest"
    print_step "Minimal theme installed"

    # appearance.json
    cat > "$OB_DIR/appearance.json" << 'APPEEOF'
{
  "accentColor": "",
  "theme": "obsidian",
  "cssTheme": "Minimal"
}
APPEEOF

    # Install plugins
    PLUGINS=(
        "blacksmithgu/obsidian-dataview:dataview"
        "SilentVoid13/Templater:obsidian-templater-plugin"
        "Vinzent03/obsidian-git:obsidian-git"
        "pjeby/tag-wrangler:tag-wrangler"
        "mgmeyers/obsidian-style-settings:obsidian-style-settings"
        "FlorianWoelki/obsidian-iconize:obsidian-icon-folder"
        "zsviczian/obsidian-excalidraw-plugin:obsidian-excalidraw-plugin"
    )

    PLUGIN_IDS="["
    for entry in "${PLUGINS[@]}"; do
        REPO="${entry%%:*}"
        PLUGIN_ID="${entry##*:}"

        print_info "Downloading $PLUGIN_ID..."
        mkdir -p "$OB_DIR/plugins/$PLUGIN_ID"
        if download_file \
            "https://github.com/$REPO/releases/latest/download/main.js" \
            "$OB_DIR/plugins/$PLUGIN_ID/main.js" "$PLUGIN_ID main.js"; then

            download_file \
                "https://github.com/$REPO/releases/latest/download/manifest.json" \
                "$OB_DIR/plugins/$PLUGIN_ID/manifest.json" "$PLUGIN_ID manifest"
            download_file \
                "https://github.com/$REPO/releases/latest/download/styles.css" \
                "$OB_DIR/plugins/$PLUGIN_ID/styles.css" "$PLUGIN_ID styles" 2>/dev/null || true

            PLUGIN_IDS="$PLUGIN_IDS\"$PLUGIN_ID\","
            print_step "$PLUGIN_ID installed"
        else
            print_warn "$PLUGIN_ID skipped (download failed — install manually in Obsidian later)"
            rm -rf "$OB_DIR/plugins/$PLUGIN_ID"
        fi
    done

    PLUGIN_IDS="${PLUGIN_IDS%,}]"
    echo "$PLUGIN_IDS" | python3 -m json.tool > "$OB_DIR/community-plugins.json" 2>/dev/null || \
    echo "$PLUGIN_IDS" > "$OB_DIR/community-plugins.json"

    print_step "All plugins registered"

    # Install Templater templates
    TEMPLATE_DIR="$WIKI_PATH/.obsidian-templates"
    mkdir -p "$TEMPLATE_DIR"
    for tmpl in entity-template concept-template topic-template synthesis-template; do
        if [ -f "$PROJECT_ROOT/templates/obsidian/$tmpl.md" ]; then
            cp "$PROJECT_ROOT/templates/obsidian/$tmpl.md" "$TEMPLATE_DIR/$tmpl.md"
        fi
    done
    print_step "Templater templates installed (4 page types)"

    # Configure Templater to use template directory
    TEMPLATER_DIR="$OB_DIR/plugins/obsidian-templater-plugin"
    if [ -d "$TEMPLATER_DIR" ]; then
        cat > "$TEMPLATER_DIR/data.json" << TMPLEOF
{
  "templates_folder": ".obsidian-templates",
  "trigger_on_file_creation": false,
  "auto_jump_to_cursor": true,
  "command_timeout": 5
}
TMPLEOF
    fi

    # Install Dataview dashboard
    if [ -f "$PROJECT_ROOT/templates/obsidian/dashboard.md" ]; then
        cp "$PROJECT_ROOT/templates/obsidian/dashboard.md" "$WIKI_PATH/wiki/dashboard.md"
        print_step "Dataview dashboard (wiki/dashboard.md)"
    fi
else
    print_info "Skipping Obsidian setup. You can configure it manually later."
fi

# ─── Claude Code Project Settings ──────────────────────────────
CLAUDE_PROJECT_DIR="$WIKI_PATH/.claude"
mkdir -p "$CLAUDE_PROJECT_DIR"
if [ -f "$PROJECT_ROOT/templates/settings.json" ]; then
    cp "$PROJECT_ROOT/templates/settings.json" "$CLAUDE_PROJECT_DIR/settings.json"
    print_step "Claude Code project settings (.claude/settings.json)"
fi

# ─── Step 6: Git Init ───────────────────────────────────────────
print_header "Finishing Up"

read -p "Initialize git repository? (y/n): " INIT_GIT
if [[ "$INIT_GIT" == "y" ]]; then
    cd "$WIKI_PATH"

    # .gitignore
    cat > .gitignore << 'GITEOF'
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/cache
.trash/
.DS_Store
GITEOF

    GIT_CMD=$(command -v git 2>/dev/null || echo "/usr/bin/git")
    $GIT_CMD init
    $GIT_CMD add -A
    $GIT_CMD commit -m "init: personal knowledge wiki"
    print_step "Git repository initialized with initial commit"
fi

# ─── Summary ────────────────────────────────────────────────────
print_header "Setup Complete!"

echo -e "Your wiki is ready at: ${BOLD}$WIKI_PATH${NC}"
echo ""
echo -e "${BOLD}What's been set up:${NC}"
echo -e "  ${GREEN}[✓]${NC} Wiki directory structure (raw → wiki → meta)"
echo -e "  ${GREEN}[✓]${NC} CLAUDE.md schema with your domains"
echo -e "  ${GREEN}[✓]${NC} Claude Code skills (wiki-ingest, wiki-lint, wiki-query, wiki-migrate)"
if [[ "$INSTALL_OB" == "y" ]]; then
echo -e "  ${GREEN}[✓]${NC} Obsidian vault with Minimal theme + 7 plugins"
fi
if [[ "$INIT_GIT" == "y" ]]; then
echo -e "  ${GREEN}[✓]${NC} Git repository"
fi
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo -e "  1. Open ${CYAN}$WIKI_PATH${NC} in Obsidian as a vault"
echo -e "  2. Enable community plugins in Settings → Community plugins"
echo -e "  3. Start Claude Code and say: ${GREEN}\"ingest this conversation\"${NC}"
echo -e "  4. Browse your wiki, ask questions, let it compound"
echo ""
echo -e "${BOLD}Operations:${NC}"
echo -e "  ${CYAN}ingest${NC}  → \"ingest this conversation\" / \"save to wiki\""
echo -e "  ${CYAN}query${NC}   → \"search wiki\" / \"check knowledge base\""
echo -e "  ${CYAN}lint${NC}    → \"lint wiki\" / \"wiki health check\""
echo ""
echo -e "Happy knowledge building! 🧠"
