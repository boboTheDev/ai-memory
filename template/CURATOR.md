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

1. Read every entry in `inbox/candidates.md`, and list every file sitting in
   `inbox/manual-inbox/` (skip its `README.md`). Both are processed in the
   same pass, as one queue of candidates.
2. For each file in `manual-inbox/`, analyze it before treating it as a
   candidate:
   - Extract the core idea(s) — not a transcription. A 20-page PDF might
     reduce to a few durable facts; a short note might reduce to one line.
     Apply the same "would this matter weeks from now" / "not trivially
     rediscoverable" tests from `DESIGN.md` to what's inside it, same as
     any other candidate.
   - Determine the file's *real* name/title. Don't trust the filename on
     disk (e.g. `scan0042.pdf`, `Untitled 14.pdf`) — look at the document's
     own title, metadata (PDF title/author properties, front-matter, a
     heading), or generate a clear descriptive title if none exists.
   - Treat the extracted content as a candidate from here on (steps 3–6
     below apply identically), using the real title/topic to guide where it
     lands. If a single file clearly contains multiple unrelated ideas,
     split it into multiple candidates rather than one mixed entry.
   - Once fully digested into canonical memory (or explicitly discarded),
     delete the original file from `manual-inbox/`. Never leave a processed
     file behind and never keep a copy elsewhere — the `CURATION-LOG.md`
     line (original filename, real title, destination) is the only record.
     If a file can't be read/parsed, leave it in place, don't delete it, and
     log why (`SKIP`, see log format below) so it's revisited next pass.
3. For each candidate (from either inbox), search `memories/` for related
   existing entries (`rg -i "<keywords>" memories/`) — this also feeds
   linking (see below), not just dedup.
4. Decide one of: **PROMOTE**, **MERGE**, **UPDATE**, **DISCARD**.
5. For anything promoted, merged, or updated: write it into the right
   canonical file under `memories/` — rewritten and generalized where
   appropriate, not copy-pasted raw. Use the candidate's proposed topic tag
   as a starting point, but override it if a better fit exists. `memories/`
   has no fixed schema: `personal/`, `projects/<name>/`, and `technical/`
   are a useful starting convention, not a ceiling. Create whatever
   folder/file structure — new top-level topic areas, subfolders under an
   existing topic, however deep it needs to go — actually fits the
   knowledge, as long as it stays under `memories/` and `MEMORY.md` is
   updated to match.
6. If no existing file or folder fits and the topic is genuinely recurring
   or important enough to warrant its own place, create one (a new file, or
   a new folder if the topic has enough substructure to need more than one
   file), and add a line for it under the right section of `MEMORY.md`,
   adding a new section there too if the topic doesn't fit an existing one.
7. Link and tag the entry — see "Linking and tagging" below. Do this for
   every promote/merge/update, not just new files.
8. Also handle canonical memory itself, not just the inbox:
   - Detect contradictions between entries and resolve them, preferring
     verified information over speculation.
   - Merge duplicate or overlapping entries.
   - Archive content that's clearly obsolete (move it to `archive/`,
     don't delete).
   - Keep files concise; split a file that's grown past ~150 lines — into
     more specific sibling topic files, or into a subfolder once the topic
     has real substructure — updating `MEMORY.md` accordingly.
   - Restructure existing files/folders when a clearly better organization
     becomes obvious (e.g. promoting a flat file to a folder of files, or
     merging a sparse folder back into one file), always keeping
     `MEMORY.md` in sync with whatever the current shape is.
   - While in here, check whether any existing entries elsewhere in
     `memories/` should now link to something just written (see below) —
     linking is a two-way opportunity, not just something the new entry
     does.
9. Clear every processed entry out of `inbox/candidates.md` (leave the file
   present with its header, just empty of processed entries). Confirm
   `inbox/manual-inbox/` contains only `README.md` — every file dropped
   there should now be either digested-and-deleted or left in place with a
   logged `SKIP` reason.
10. Append one line per action taken to `CURATION-LOG.md` (format below).
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
  silent. Applies to `manual-inbox/` files too: if a file has nothing worth
  keeping, delete it and log DISCARD with the original filename.
- **SKIP** — `manual-inbox/` only: the file couldn't be processed this pass
  (unreadable, unclear, needs the user to clarify what it is). Leave the
  file in place, don't delete it, log why. Not a real fifth outcome for
  ordinary candidates — those should always resolve to one of the four
  above.

## Linking and tagging

Canonical memory files link to each other Obsidian-style, so related
knowledge is discoverable by following references, not just by grep:

- **Links**: use `[[target]]` wikilinks, where `target` is the linked
  file's path relative to `memories/`, without the `.md` extension (e.g.
  `[[technical/solutions]]`, `[[projects/acme/decisions]]`). When curating
  an entry, check the related-entries search from step 3 and add a `[[...]]`
  link wherever another canonical file is genuinely relevant — a shared
  project, a related technical dependency, a person mentioned elsewhere, a
  decision this one builds on. Linking is favored but optional: don't force
  a link where nothing is actually related, and don't link a file to itself.
  Prefer linking a whole file over a specific heading unless a specific
  section is clearly what's relevant.
- **Tags**: add `#tags` (lowercase, hyphenated, e.g. `#docker`,
  `#project-acme`, `#health-sleep`) to entries or section headings likely to
  be referenced again later, even if nothing links to them yet — tags are
  what make a *future* entry findable and linkable, not just this one. Put
  them at the end of the entry (or in the heading line) rather than
  scattered inline. Don't over-tag a trivial entry; a handful of meaningful
  tags beats a dozen generic ones.
- Links and tags are metadata, not padding — if an entry has genuinely
  nothing to link or tag, leave it plain rather than inventing connections.

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
(e.g. a systemd dependency or wait condition). See [[technical/environment]]
for this machine's Tailscale setup.

**Verification:** Confirmed by reboot testing.

#docker #tailscale #boot-order
```

The same discipline applies outside technical topics — a rough personal or
project candidate gets distilled into the durable fact or decision it
represents, not kept as a narrated log of how it was discovered. The same
applies to a `manual-inbox/` file: a 15-page PDF export of a project spec
doesn't get pasted in — it gets reduced to the same shape, linked and
tagged the same way, e.g.:

```markdown
### Acme onboarding flow — v2 redesign rationale

**Source:** digested from manual-inbox (originally `IMG_scan_0091.pdf`,
identified via document title as "Acme Onboarding Redesign — Proposal v2").

**Decision:** Move email verification before payment step to cut drop-off.

**Rationale:** Prior flow had payment before verification, causing support
load from unverified accounts. See [[projects/acme/decisions]] for the
earlier flow this replaces.

#project-acme #onboarding
```

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
2026-09-22 PROMOTE memories/projects/acme/decisions.md — from manual-inbox `IMG_scan_0091.pdf` ("Acme Onboarding Redesign — Proposal v2"), original deleted
2026-09-22 DISCARD (n/a) — from manual-inbox `IMG_2044.jpg`, meme with no durable content, original deleted
2026-09-22 SKIP (n/a) — manual-inbox `notes.docx` unreadable (corrupt/unsupported), left in place
```

For anything sourced from `manual-inbox/`, the log line should name the
original filename and (for PROMOTE/MERGE/UPDATE) the real title the curator
identified, so there's a record of what the deleted file was even though the
file itself is gone.

This is the safety net in place of a full versioning/archival system: every
promotion, merge, update, and discard is traceable to one line, even though
individual file edits aren't otherwise versioned beyond whatever backup/git
strategy you use for this repo.
