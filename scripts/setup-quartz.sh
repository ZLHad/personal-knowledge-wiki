#!/usr/bin/env bash
#
# Personal Knowledge Wiki — Quartz Static Site Setup
#
# One-shot installer for Quartz (https://quartz.jzhao.xyz/) — an Obsidian-native
# static site generator. Reads your wiki/ directory and produces a polished
# web version with graph view, backlinks, wikilinks, and LaTeX rendering.
#
# Usage (run from repo root):
#   bash scripts/setup-quartz.sh
#
# After setup, preview with:
#   cd site && npx quartz build --directory ../wiki --serve --port 4321
#
# Open http://localhost:4321
#
# To reset:  rm -rf site/ && bash scripts/setup-quartz.sh
#

set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_step() { echo -e "${GREEN}[✓]${NC} $1"; }
print_info() { echo -e "${BLUE}[i]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

# ─── Locate repo root (one level up from scripts/) ──────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SITE_DIR="$REPO_ROOT/site"
WIKI_DIR="$REPO_ROOT/wiki"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Quartz Setup for Personal Knowledge Wiki${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ─── Preflight checks ────────────────────────────────────────────
print_info "Checking prerequisites..."

if [ ! -d "$WIKI_DIR" ]; then
  print_warn "wiki/ directory not found at $WIKI_DIR"
  print_warn "Run 'bash scripts/setup.sh' first to create your wiki."
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  print_warn "Node.js not found. Install from https://nodejs.org (v20+ required)"
  exit 1
fi

NODE_VERSION=$(node --version | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
  print_warn "Node.js v$NODE_VERSION detected. Quartz requires v20+. Please upgrade."
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  print_warn "git not found. Please install git first."
  exit 1
fi

print_step "Node $(node --version) ✓"
print_step "wiki/ found at $WIKI_DIR ✓"
echo ""

# ─── Existing install guard ──────────────────────────────────────
if [ -d "$SITE_DIR" ]; then
  print_warn "site/ directory already exists at $SITE_DIR"
  echo ""
  echo "  Options:"
  echo "    • Preview existing install: cd site && npx quartz build --directory ../wiki --serve --port 4321"
  echo "    • Reinstall: rm -rf site/ && bash scripts/setup-quartz.sh"
  echo ""
  exit 1
fi

# ─── Clone Quartz ────────────────────────────────────────────────
print_info "Cloning Quartz into site/..."
git clone --depth 1 https://github.com/jackyzha0/quartz.git "$SITE_DIR" 2>&1 | sed 's/^/    /'
print_step "Cloned Quartz"

# ─── Remove Quartz's git history ────────────────────────────────
print_info "Removing Quartz's git history (avoiding nested repo)..."
rm -rf "$SITE_DIR/.git"
print_step "Cleaned git history"

# ─── Remove demo content (we'll use --directory flag) ───────────
print_info "Removing Quartz demo content (will use --directory ../wiki flag)..."
rm -rf "$SITE_DIR/content"
print_step "Removed demo content"

# ─── Install npm dependencies ───────────────────────────────────
print_info "Installing npm dependencies (may take 1–2 minutes)..."
cd "$SITE_DIR"
npm install --silent 2>&1 | sed 's/^/    /' || {
  print_warn "npm install failed. Trying with --ignore-scripts as fallback..."
  npm install --ignore-scripts --silent
}
print_step "Dependencies installed"

# ─── Customize quartz.config.ts ─────────────────────────────────
print_info "Customizing quartz.config.ts..."

CONFIG_FILE="$SITE_DIR/quartz.config.ts"

# Use sed to update key fields (works on both macOS BSD sed and GNU sed)
if [[ "$OSTYPE" == "darwin"* ]]; then
  SED_INPLACE=(-i '')
else
  SED_INPLACE=(-i)
fi

# 1. pageTitle: replace "Quartz 4" with placeholder (user edits later)
sed "${SED_INPLACE[@]}" 's|pageTitle: "Quartz 4"|pageTitle: "My Knowledge Wiki"|' "$CONFIG_FILE"

# 2. baseUrl: placeholder for local preview (empty string causes 404 plugin to fail)
sed "${SED_INPLACE[@]}" 's|baseUrl: "quartz.jzhao.xyz"|baseUrl: "localhost:4321"|' "$CONFIG_FILE"

# 3. ignorePatterns: add dashboard.md (Dataview blocks don't render in Quartz)
sed "${SED_INPLACE[@]}" 's|ignorePatterns: \["private", "templates", ".obsidian"\]|ignorePatterns: ["private", "templates", ".obsidian", "dashboard.md"]|' "$CONFIG_FILE"

print_step "Customized pageTitle, baseUrl, ignorePatterns"

# ─── Done ────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  ✓ Quartz installed successfully${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo ""
echo -e "  1. ${BLUE}Preview:${NC}"
echo -e "     ${CYAN}cd site && npx quartz build --directory ../wiki --serve --port 4321${NC}"
echo ""
echo -e "  2. ${BLUE}Open in browser:${NC}"
echo -e "     ${CYAN}http://localhost:4321${NC}"
echo ""
echo -e "  3. ${BLUE}Customize (optional):${NC}"
echo -e "     Edit ${CYAN}site/quartz.config.ts${NC}"
echo -e "     • ${YELLOW}pageTitle${NC} — your site's title"
echo -e "     • ${YELLOW}theme.colors${NC} — light/dark mode palette"
echo -e "     • ${YELLOW}theme.typography${NC} — fonts"
echo -e "     • ${YELLOW}locale${NC} — e.g. \"zh-CN\" for Chinese content"
echo ""
echo -e "${BOLD}Deployment:${NC}"
echo -e "  • GitHub Pages:    ${CYAN}cd site && npx quartz sync${NC}"
echo -e "  • Cloudflare/Netlify/Vercel: point to ${CYAN}site/${NC}, build cmd: ${CYAN}npx quartz build --directory ../wiki${NC}"
echo ""
echo -e "${BOLD}Reset:${NC}"
echo -e "  ${CYAN}rm -rf site/ && bash scripts/setup-quartz.sh${NC}"
echo ""
echo -e "${BOLD}Docs:${NC}"
echo -e "  • Quartz: https://quartz.jzhao.xyz/"
echo -e "  • This project: README.md (English) / README_CN.md (中文)"
echo ""
