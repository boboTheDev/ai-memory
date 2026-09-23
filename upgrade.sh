#!/usr/bin/env bash
# Upgrades an already-deployed live data directory's *instruction* files from
# this repo's template/, without touching any real data.
#
# Unlike deploy.sh (one-shot seed of a brand-new live dir), this is meant to
# be re-run any time you improve the template and want that improvement to
# reach a live directory that's already accumulated real content.
#
# Usage:
#   ./upgrade.sh [live-path]
#
# Default live-path: ~/.ai-memory
#
# Only overwrites files under template/ that are pure instructions/process,
# never real data: CURATOR.md, and inbox/manual-inbox/README.md (the
# manual-inbox folder itself holds real user-dropped files, but its README
# is pure instructions, same category as CURATOR.md). DESIGN.md/README.md
# are repo-root docs about the system and are never deployed at all.
#
# Never touches (real data, even though it started as a template seed):
#   MEMORY.md, CURATION-LOG.md, inbox/candidates.md, inbox/manual-inbox/*
#   (except README.md), memories/**
#
# Typical flow:
#   1. Edit template/ in this repo, commit, push.
#   2. On the server: git pull this repo, then run this script against the
#      server's live path.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/template"
LIVE_DIR="${1:-$HOME/.ai-memory}"

# Files copied wholesale from template/ into the live dir. Everything else
# in template/ (MEMORY.md, CURATION-LOG.md, inbox/candidates.md, memories/**)
# is live data once deployed and must never be overwritten here.
INSTRUCTION_FILES=(
  "CURATOR.md"
  "inbox/manual-inbox/README.md"
)

if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "error: template directory not found at $TEMPLATE_DIR" >&2
  exit 1
fi

if [ ! -d "$LIVE_DIR" ]; then
  echo "error: $LIVE_DIR does not exist — nothing to upgrade. Run deploy.sh first." >&2
  exit 1
fi

echo "Upgrading instruction files in $LIVE_DIR from $TEMPLATE_DIR ..."

for f in "${INSTRUCTION_FILES[@]}"; do
  src="$TEMPLATE_DIR/$f"
  dst="$LIVE_DIR/$f"
  if [ ! -f "$src" ]; then
    echo "  skip (not in template): $f"
    continue
  fi
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
    echo "  unchanged: $f"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  updated:   $f"
  fi
done

echo
echo "Done. Untouched (real data): MEMORY.md, CURATION-LOG.md, inbox/candidates.md, memories/**"
echo
echo "Note: bootstrap/ snippets are pasted by hand into ~/.claude/CLAUDE.md and"
echo "~/.codex/AGENTS.md (see bootstrap/*.md in this repo) — they are not copied"
echo "into the live dir. If you changed a bootstrap snippet, re-paste it by hand."
