# Memory Curator

This defines a dedicated role, invoked deliberately (not automatically):

```
claude "curate my memory per ai-memory/CURATOR.md"
```

or the Codex equivalent. Manual invocation is fully expected for v1 — no
scheduled automation.

The curator's job is **knowledge maintenance**, not summarization of what
happened in past sessions. It turns rough candidates into durable,
well-structured canonical memory, and keeps that canonical memory correct
and non-redundant over time.

## Process

1. Read every entry in `inbox/candidates.md`.
2. For each candidate, search `memories/` for related existing entries
   (`rg -i "<keywords>" memories/`).
3. Decide one of: **PROMOTE**, **MERGE**, **UPDATE**, **DISCARD**.
4. For anything promoted, merged, or updated: write it into the right
   canonical file under `memories/personal/`, `memories/projects/`, or
   `memories/technical/` — rewritten and generalized where appropriate, not
   copy-pasted raw. Use the candidate's proposed topic tag as a starting
   point, but override it if a better fit exists.
5. If no existing file fits and the topic is genuinely recurring or
   important enough to warrant its own file, create one, and add a line for
   it under the right section of `MEMORY.md`.
6. Also handle canonical memory itself, not just the inbox:
   - Detect contradictions between entries and resolve them, preferring
     verified information over speculation.
   - Merge duplicate or overlapping entries.
   - Archive content that's clearly obsolete (move it to `archive/`,
     don't delete).
   - Keep files concise; split a file that's grown past ~150 lines into
     more specific topic files, updating `MEMORY.md` accordingly.
7. Clear every processed entry out of `inbox/candidates.md` (leave the file
   present with its header, just empty of processed entries).
8. Append one line per action taken to `CURATION-LOG.md` (format below).
   This is required — it's the only audit trail, since candidates and
   canonical content don't otherwise keep version history.

## Decision guide

- **PROMOTE** — genuinely new, durable, passes the "would this matter weeks
  from now" and "not trivially rediscoverable" tests from `DESIGN.md`.
  Write it into canonical memory as a clean, generalized entry.
- **MERGE** — overlaps with an existing entry. Combine them into one
  improved entry rather than keeping both.
- **UPDATE** — supersedes or corrects an existing canonical entry. Replace
  the outdated part; if the old version has standalone value (e.g. it
  documents a past decision that was later reversed), move the superseded
  text to `archive/` instead of deleting it outright.
- **DISCARD** — trivial, redundant with nothing gained by merging, a
  one-off with no reusable lesson, or fails the rediscoverability tests.
  Still gets a `CURATION-LOG.md` line with a short reason — discard is not
  silent.

## What "improve, don't copy" means

A raw candidate like:

> Today Claude spent 40 minutes debugging Docker. Attempt A failed. Attempt
> B failed. Eventually discovered Tailscale didn't have its IP when Docker
> started. Added a systemd wait and it worked.

should not be pasted into canonical memory as a session narrative. It
becomes something like:

```markdown
### Docker service binding to a dynamically initialized network address

**Problem:** A Compose service bound to an address supplied by another
network service can fail during boot.

**Cause:** Docker may start before the required interface/address is
available.

**Solution:** Gate Compose startup on that interface/address being ready
(e.g. a systemd dependency or wait condition).

**Verification:** Confirmed by reboot testing.
```

The same discipline applies outside technical topics — a rough personal or
project candidate gets distilled into the durable fact or decision it
represents, not kept as a narrated log of how it was discovered.

## CURATION-LOG.md format

Append-only. One line per action, newest at the bottom:

```
YYYY-MM-DD [ACTION] <topic file> — <one-line reason/summary>
```

Example:

```
2026-09-22 PROMOTE memories/technical/solutions.md — Docker/Tailscale boot-order fix
2026-09-22 DISCARD (n/a) — one-off typo fix, no reusable lesson
2026-09-22 UPDATE memories/personal/travel.md — corrected passport renewal date
```

This is the safety net in place of a full versioning/archival system: every
promotion, merge, update, and discard is traceable to one line, even though
individual file edits aren't otherwise versioned beyond whatever backup/git
strategy you use for this repo.
