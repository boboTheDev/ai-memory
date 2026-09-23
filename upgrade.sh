#!/usr/bin/env bash
# Upgrades an already-deployed live data directory's *instruction* files from
# this repo, without touching any real data.
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
# Only overwrites files that are pure instructions/process, never real
# data: template/CURATOR.md, template/inbox/manual-inbox/README.md and
# template/archive/README.md (those two folders hold real user-dropped or
# curator-archived content, but their READMEs are pure instructions, same
# category as CURATOR.md), and repo-root DESIGN.md (deploy.sh copies it
# into the live dir too, since CURATOR.md and the bootstrap snippets both
# point agents at <live>/DESIGN.md). README.md is the only repo-root doc
# that stays repo-only.
#
# Never touches (real data, even though it started as a template seed):
#   MEMORY.md, CURATION-LOG.md, inbox/candidates.md, inbox/manual-inbox/*
#   (except README.md), memories/**, archive/* (except README.md)
#
# Note: template/archive/ is untracked-empty in a fresh clone unless it
# holds at least one file (git doesn't track empty directories) — this
# script and deploy.sh both assume template/archive/README.md exists so
# the folder itself is always present to seed/sync.
#
# Typical flow:
#   1. Edit template/ (or DESIGN.md) in this repo, commit, push.
#   2. On the server: git pull this repo, then run this script against the
#      server's live path.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/template"
LIVE_DIR="${1:-$HOME/.ai-memory}"

# Instruction files copied wholesale into the live dir, as "<source path
# relative to repo root>:<destination path relative to the live dir>".
# Everything else under template/ (MEMORY.md, CURATION-LOG.md,
# inbox/candidates.md, memories/**) is live data once deployed and must
# never be overwritten here.
INSTRUCTION_FILES=(
  "template/CURATOR.md:CURATOR.md"
  "template/inbox/manual-inbox/README.md:inbox/manual-inbox/README.md"
  "template/archive/README.md:archive/README.md"
  "DESIGN.md:DESIGN.md"
)

if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "error: template directory not found at $TEMPLATE_DIR" >&2
  exit 1
fi

if [ ! -d "$LIVE_DIR" ]; then
  echo "error: $LIVE_DIR does not exist — nothing to upgrade. Run deploy.sh first." >&2
  exit 1
fi

echo "Upgrading instruction files in $LIVE_DIR from $SCRIPT_DIR ..."

for entry in "${INSTRUCTION_FILES[@]}"; do
  f="${entry%%:*}"
  dest_rel="${entry#*:}"
  src="$SCRIPT_DIR/$f"
  dst="$LIVE_DIR/$dest_rel"
  if [ ! -f "$src" ]; then
    echo "  skip (not found in repo): $f"
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
echo "Done. Untouched (real data): MEMORY.md, CURATION-LOG.md, inbox/candidates.md,"
echo "inbox/manual-inbox/* (except README.md), archive/* (except README.md), memories/**"
echo
echo "Note: bootstrap/ snippets are pasted by hand into ~/.claude/CLAUDE.md and"
echo "~/.codex/AGENTS.md (see bootstrap/*.md in this repo) — they are not copied"
echo "into the live dir. If you changed a bootstrap snippet, re-paste it by hand."
