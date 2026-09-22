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
- Never write directly to <AI_MEMORY_PATH>/memories/** during normal work.
  Only the deliberate curation process (see <AI_MEMORY_PATH>/CURATOR.md,
  run when the user explicitly asks for curation) writes canonical memory.
```
