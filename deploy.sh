#!/usr/bin/env bash
# Deploys the ai-memory template (plus DESIGN.md) into a live data
# directory, outside this git repository, so real memory content can
# never end up committed here.
#
# Usage:
#   ./deploy.sh [live-path]
#
# Default live-path: ~/.ai-memory
#
# Safe to re-run: if the live path already exists, this refuses to touch
# it (so it never overwrites real curated content). Delete or move the
# live path yourself first if you actually want a clean reseed.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/template"
LIVE_DIR="${1:-$HOME/.ai-memory}"

if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "error: template directory not found at $TEMPLATE_DIR" >&2
  exit 1
fi

if [ -e "$LIVE_DIR" ]; then
  echo "error: $LIVE_DIR already exists — refusing to overwrite a possibly-live memory store." >&2
  echo "Move or delete it yourself first if you really want to reseed from the template." >&2
  exit 1
fi

cp -R "$TEMPLATE_DIR" "$LIVE_DIR"
cp "$SCRIPT_DIR/DESIGN.md" "$LIVE_DIR/DESIGN.md"

echo "Deployed template to $LIVE_DIR"
echo
echo "Next steps:"
echo "1. Paste the snippet from bootstrap/claude-code.md into ~/.claude/CLAUDE.md,"
echo "   replacing <AI_MEMORY_PATH> with: $LIVE_DIR"
echo "2. Paste the snippet from bootstrap/codex.md into ~/.codex/AGENTS.md,"
echo "   replacing <AI_MEMORY_PATH> with: $LIVE_DIR"
echo "3. Start using it. Real content now lives only at $LIVE_DIR, never in this git repo."
