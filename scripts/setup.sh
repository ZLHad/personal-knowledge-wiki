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

# ─── Step 0: Language Selection ─────────────────────────────────
echo -e "${BOLD}Language / 语言选择:${NC}"
echo "  1. English (default)"
echo "  2. 中文"
read -p "Choose [1/2]: " LANG_CHOICE
LANG_CHOICE="${LANG_CHOICE:-1}"

if [[ "$LANG_CHOICE" == "2" ]]; then
    WIKI_LANG="zh"
else
    WIKI_LANG="en"
fi
print_step "Language: $([ "$WIKI_LANG" = "zh" ] && echo "中文" || echo "English")"

# ─── Localized prompts ──────────────────────────────────────────
if [[ "$WIKI_LANG" == "zh" ]]; then
    L_STEP1="步骤 1/5：Wiki 位置"
    L_WIKI_PATH_PROMPT="Wiki 创建位置（完整路径，如 ~/Documents/个人知识库）: "
    L_DIR_EXISTS="目录已存在: "
    L_CONTINUE="是否继续在该目录中设置？(y/n): "
    L_STEP2="步骤 2/5：配置知识领域"
    L_WIKI_NAME_PROMPT="Wiki 名称（如 '个人知识库'、'科研 Wiki'）: "
    L_DOMAIN_INTRO="定义你的知识领域（将成为 raw/ 下的顶级目录）。"
    L_DOMAIN_EXAMPLES="示例：科研、阅读、工作、生活、编程"
    L_DOMAIN_PROMPT="领域 "
    L_DOMAIN_EMPTY="（留空结束）: "
    L_SUB_PROMPT="  '$DOMAIN' 的子分类（逗号分隔，如 '论文,笔记,工具'）: "
    L_NO_DOMAIN="未指定领域，已创建默认目录: raw/general/"
    L_STEP3="步骤 3/5：创建 Wiki 目录结构"
    L_STEP4="步骤 4/5：安装 Claude Code 技能"
    L_STEP5="步骤 5/5：Obsidian 配置"
    L_OB_PROMPT="安装 Obsidian 插件和主题？(y/n): "
    L_GIT_PROMPT="初始化 git 仓库？(y/n): "
    L_FINISH="完成"
    L_COMPLETE="设置完成！"
    L_WIKI_READY="你的 Wiki 已准备就绪: "
    L_SETUP_LIST="已配置内容："
    L_NEXT_STEPS="后续步骤："
    L_NEXT1="在 Obsidian 中打开上述路径作为 vault"
    L_NEXT2="在 设置 → 社区插件 中启用社区插件"
    L_NEXT3="启动 Claude Code 并说："
    L_NEXT3_CMD="导入这段对话"
    L_NEXT4="浏览你的 wiki，提问，让知识复利增长"
    L_OPS="操作指令："
    L_OPS1="导入"
    L_OPS1_CMD="\"导入知识库\" / \"保存到 wiki\""
    L_OPS2="查询"
    L_OPS2_CMD="\"搜索知识库\" / \"查询 wiki\""
    L_OPS3="检查"
    L_OPS3_CMD="\"检查知识库\" / \"wiki 健康检查\""
    L_HAPPY="祝你知识构建愉快！🧠"
else
    L_STEP1="Step 1/5: Wiki Location"
    L_WIKI_PATH_PROMPT="Where to create the wiki? (full path, e.g. ~/Documents/Personal Knowledge): "
    L_DIR_EXISTS="Directory already exists: "
    L_CONTINUE="Continue and set up inside it? (y/n): "
    L_STEP2="Step 2/5: Configure Your Domains"
    L_WIKI_NAME_PROMPT="Wiki name (e.g. 'Personal Knowledge', 'Research Wiki'): "
    L_DOMAIN_INTRO="Define your knowledge domains (these become top-level directories under raw/)."
    L_DOMAIN_EXAMPLES="Examples: research, reading, work, life, programming"
    L_DOMAIN_PROMPT="Domain "
    L_DOMAIN_EMPTY="(leave empty to finish): "
    L_SUB_PROMPT="  Sub-categories for '$DOMAIN' (comma-separated, e.g. 'papers,notes,tools'): "
    L_NO_DOMAIN="No domains specified, created default: raw/general/"
    L_STEP3="Step 3/5: Creating Wiki Structure"
    L_STEP4="Step 4/5: Installing Claude Code Skills"
    L_STEP5="Step 5/5: Obsidian Configuration"
    L_OB_PROMPT="Install Obsidian plugins and theme? (y/n): "
    L_GIT_PROMPT="Initialize git repository? (y/n): "
    L_FINISH="Finishing Up"
    L_COMPLETE="Setup Complete!"
    L_WIKI_READY="Your wiki is ready at: "
    L_SETUP_LIST="What's been set up:"
    L_NEXT_STEPS="Next steps:"
    L_NEXT1="Open the path above in Obsidian as a vault"
    L_NEXT2="Enable community plugins in Settings → Community plugins"
    L_NEXT3="Start Claude Code and say: "
    L_NEXT3_CMD="ingest this conversation"
    L_NEXT4="Browse your wiki, ask questions, let it compound"
    L_OPS="Operations:"
    L_OPS1="ingest"
    L_OPS1_CMD="\"ingest this conversation\" / \"save to wiki\""
    L_OPS2="query"
    L_OPS2_CMD="\"search wiki\" / \"check knowledge base\""
    L_OPS3="lint"
    L_OPS3_CMD="\"lint wiki\" / \"wiki health check\""
    L_HAPPY="Happy knowledge building! 🧠"
fi

# ─── Step 1: Wiki Location ──────────────────────────────────────
print_header "$L_STEP1"

read -p "$L_WIKI_PATH_PROMPT" WIKI_PATH
WIKI_PATH="${WIKI_PATH/#\~/$HOME}"

if [ -d "$WIKI_PATH" ]; then
    print_warn "${L_DIR_EXISTS}$WIKI_PATH"
    read -p "$L_CONTINUE" CONFIRM
    [[ "$CONFIRM" != "y" ]] && echo "Aborted." && exit 1
fi

mkdir -p "$WIKI_PATH"
print_step "Wiki directory: $WIKI_PATH"

# ─── Step 2: Wiki Name & Domains ────────────────────────────────
print_header "$L_STEP2"

read -p "$L_WIKI_NAME_PROMPT" WIKI_NAME
WIKI_NAME="${WIKI_NAME:-Personal Knowledge}"

echo ""
echo "$L_DOMAIN_INTRO"
echo "$L_DOMAIN_EXAMPLES"
echo ""

DOMAINS=()
DOMAIN_TAGS=""
i=1
while true; do
    read -p "${L_DOMAIN_PROMPT}$i ${L_DOMAIN_EMPTY}" DOMAIN
    [[ -z "$DOMAIN" ]] && break
    DOMAINS+=("$DOMAIN")

    if [[ "$WIKI_LANG" == "zh" ]]; then
        read -p "  '$DOMAIN' 的子分类（逗号分隔，如 '论文,笔记,工具'）: " SUBS
    else
        read -p "  Sub-categories for '$DOMAIN' (comma-separated, e.g. 'papers,notes,tools'): " SUBS
    fi
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
    print_warn "$L_NO_DOMAIN"
fi

# ─── Step 3: Create Directory Structure ──────────────────────────
print_header "$L_STEP3"

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
print_header "$L_STEP4"

SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

for skill in wiki-ingest wiki-lint wiki-query wiki-migrate wiki-export; do
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
print_header "$L_STEP5"

read -p "$L_OB_PROMPT" INSTALL_OB
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
print_header "$L_FINISH"

read -p "$L_GIT_PROMPT" INIT_GIT
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
print_header "$L_COMPLETE"

echo -e "${L_WIKI_READY}${BOLD}$WIKI_PATH${NC}"
echo ""
echo -e "${BOLD}${L_SETUP_LIST}${NC}"
echo -e "  ${GREEN}[✓]${NC} Wiki directory structure (raw → wiki → meta)"
echo -e "  ${GREEN}[✓]${NC} CLAUDE.md schema"
echo -e "  ${GREEN}[✓]${NC} Claude Code skills (ingest, lint, query, migrate, export)"
if [[ "$INSTALL_OB" == "y" ]]; then
echo -e "  ${GREEN}[✓]${NC} Obsidian vault + Minimal theme + 7 plugins"
echo -e "  ${GREEN}[✓]${NC} Templater templates (4 page types)"
echo -e "  ${GREEN}[✓]${NC} Dataview dashboard"
fi
if [[ "$INIT_GIT" == "y" ]]; then
echo -e "  ${GREEN}[✓]${NC} Git repository"
fi
echo ""
echo -e "${BOLD}${L_NEXT_STEPS}${NC}"
echo -e "  1. ${L_NEXT1}"
echo -e "  2. ${L_NEXT2}"
echo -e "  3. ${L_NEXT3}${GREEN}\"${L_NEXT3_CMD}\"${NC}"
echo -e "  4. ${L_NEXT4}"
echo ""
echo -e "${BOLD}${L_OPS}${NC}"
echo -e "  ${CYAN}${L_OPS1}${NC}  → ${L_OPS1_CMD}"
echo -e "  ${CYAN}${L_OPS2}${NC}  → ${L_OPS2_CMD}"
echo -e "  ${CYAN}${L_OPS3}${NC}   → ${L_OPS3_CMD}"
echo ""
echo -e "$L_HAPPY"
