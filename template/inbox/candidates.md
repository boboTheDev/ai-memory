# Candidate Inbox

Append-only staging area. Any agent (Claude Code or Codex) writes here when
the user says "save this to memory inbox" (or similar). Keep entries cheap
and rough — no polishing, this should cost almost no time or context. The
curator reads and processes these later; see `../CURATOR.md`.

For whole files (notes, PDFs, exports) instead of a short text entry, drop
them in `manual-inbox/` instead — see `manual-inbox/README.md`. The curator
processes both in the same pass.

Do not edit or delete other entries when appending. Do not write directly to
`../memories/` from a normal working session.

## Entry format

```markdown
## Candidate

Topic: <proposed topic, e.g. health / travel / technical/environment / projects/<name> — best guess, curator may override>

<A few lines: what happened / what was decided / what was learned. Rough is fine.>

Evidence: <how you know it's true/verified, if applicable>
```

---

<!-- New candidates go below this line. Curator: remove processed entries,
     keep this header and the line above. -->
