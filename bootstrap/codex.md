# Codex bootstrap snippet

Paste this into your **global** `~/.codex/AGENTS.md`. Global, not
per-project — it must apply regardless of which directory a session was
started in. Replace `<AI_MEMORY_PATH>` with the real absolute path on this
machine (e.g. `~/.ai-memory` if you symlinked it there, or the direct clone
path). This is the same store and same rules as the Claude Code snippet
(`../bootstrap/claude-code.md`) — content should stay in sync between the
two since they share one memory store.

```markdown
## Long-term memory

You have access to a shared long-term memory store, independent of the
current project, at <AI_MEMORY_PATH>. It is not project memory — it holds
durable personal, project-business, and technical knowledge worth keeping
across sessions and tools (shared with Claude Code). Full design:
<AI_MEMORY_PATH>/DESIGN.md.

- At the start of substantial work, if the task might benefit from prior
  knowledge, read <AI_MEMORY_PATH>/MEMORY.md (it's small — an index). If a
  listed topic looks relevant, read that specific file. Don't read the
  whole memories/ tree.
- To find something without knowing the exact file, grep it, e.g.
  rg -i "<keywords>" <AI_MEMORY_PATH>/memories/.
- When the user says "save this to memory inbox" (or "save to memory"),
  append a short, rough candidate entry to
  <AI_MEMORY_PATH>/inbox/candidates.md, following the format at the top of
  that file. Keep it cheap — a few lines, no polishing, don't interrupt the
  current task to do this well. Include a proposed topic tag.
- The user may also drop whole files (notes, PDFs, exports) into
  <AI_MEMORY_PATH>/inbox/manual-inbox/ by hand for the same purpose — you
  don't need to do anything with that folder during normal work; it's
  processed by curation, not on the fly.
- Never write directly to <AI_MEMORY_PATH>/memories/** during normal work.
  Only the deliberate curation process (see <AI_MEMORY_PATH>/CURATOR.md,
  run when the user explicitly asks for curation) writes canonical memory,
  digests inbox/manual-inbox/ files, and maintains [[wikilinks]]/#tags
  between entries.
- Separately, <AI_MEMORY_PATH>/agenda/ holds dated events/reminders (e.g.
  "pick up X on the 25th") — not curated knowledge, no inbox, no curation
  gate. When the user says something like "add to my agenda: ...", append
  a one-line dated entry directly to
  <AI_MEMORY_PATH>/agenda/<year>/<month>.md (create the year folder/month
  file if they don't exist), following the format in
  <AI_MEMORY_PATH>/agenda/README.md. When a task might involve upcoming
  dates or scheduling, read the current month's file (and next month's if
  looking ahead is relevant) — don't scan the whole agenda/ tree, and don't
  route dated events through inbox/candidates.md instead.
```
