# Design

> Paths below (`MEMORY.md`, `memories/...`, `inbox/candidates.md`) are
> relative to the **live data directory** created by `deploy.sh`, not this
> repo's root. See [README.md](README.md#repo-layout-template-vs-live-data)
> for the template-vs-live split.

## Goal

A simple, durable, shared long-term memory system for Claude Code and Codex
CLI. One brain, shared across both tools — not scoped to a single agent, and
not scoped to a single project. It holds curated knowledge that remains
useful across sessions: technical lessons, non-technical project
business/decisions, and general personal knowledge (anything from thesis
progress to flight details to a durable dietary fact).

This is explicitly **not** a replacement for either tool's session/working
context (current conversation, files being inspected, task state, command
output, in-flight reasoning) and **not** a replacement for deep per-project
technical memory such as Project Master's `.project-meta/`.

## Priorities

1. Very low maintenance
2. Human-readable
3. Shared between Claude Code and Codex
4. Agent-writable
5. Resistant to accumulating junk
6. Easy to inspect and edit manually
7. Easy to back up / sync / version
8. No unnecessary infrastructure
9. Can migrate to SQLite/FTS5/vector search later if scale ever requires it

## Core philosophy: staging + curation, not direct writes

Working context
&nbsp;&nbsp;&nbsp;&nbsp;↓
Potentially reusable discovery
&nbsp;&nbsp;&nbsp;&nbsp;↓
Candidate memory (`inbox/candidates.md`) — or a raw file dropped in
`inbox/manual-inbox/`
&nbsp;&nbsp;&nbsp;&nbsp;↓
Curator (deliberate, on-demand)
&nbsp;&nbsp;&nbsp;&nbsp;↓
Canonical long-term memory (`memories/**`)

Agents working normally do **not** write canonical memory directly. They
freely append cheap, rough candidate entries to the inbox — this should cost
almost no time or context. A separate, deliberate curation pass (run when you
ask for it, not automatically) decides what actually deserves to survive,
and writes canonical memory. This keeps day-to-day writes cheap while
keeping canonical memory high-signal.

`inbox/manual-inbox/` is a second, parallel staging path for the same
pipeline, for material an agent never touched: notes, PDFs, exports, or
other files placed there by hand. It feeds the same curator pass as
`candidates.md` rather than a separate process — the curator analyzes each
file, extracts the durable core (not a full transcription), determines the
file's real title (from its content/metadata, not its on-disk filename),
and writes that into canonical memory exactly as it would any other
candidate. The original file is deleted once digested (or discarded); see
`CURATOR.md` for the full process and the log-only audit trail this implies
(no copy of the original is retained — `CURATION-LOG.md` records the
original filename and identified title as the only trace).

## Why not a fixed category list

An earlier draft of this design used five fixed categories (solutions,
techniques, environment, preferences, lessons) borrowed from an ops/dev
memory pattern. That works for a narrow technical-assistant use case, but
this system is meant to be a general second brain — thesis, flights, meals,
workouts, project business decisions, technical lessons, all of it. Fixed
categories from one domain don't fit knowledge from every domain.

A later revision also dropped a fixed three-axis split (`personal/`,
`projects/`, `technical/`) for the same reason: forcing every topic through
three predetermined buckets is just a coarser version of the same problem.
Some knowledge is genuinely cross-cutting (a project that's also a health
routine, a person who's also a recurring technical collaborator) or deep
enough to want its own multi-file subtree, and a fixed top level fights
that.

Canonical memory under `memories/` is instead a **fully open taxonomy**:
any folder and file structure, at any depth, that best fits the knowledge
being stored. `personal/`, `projects/<name>/`, and `technical/` remain
reasonable, commonly-useful top-level groupings — the seed template ships
with them populated — but they are a starting convention, not a schema.
The curator (see below) is free to:

- create new top-level topic areas alongside them when a topic doesn't fit
  any existing one well (e.g. `memories/recipes/`, `memories/hobby-3d-printing/`)
- create subfolders under any topic once it's grown deep enough to warrant
  splitting (e.g. `memories/projects/<name>/architecture.md` plus
  `memories/projects/<name>/decisions.md` instead of one flat file)
- rename, move, or restructure existing files/folders when a better
  organization becomes obvious, as long as `MEMORY.md` is updated to match

The only hard constraints are: everything canonical still lives under
`memories/` (so retrieval by grepping that one directory keeps working),
and `MEMORY.md` stays an accurate index of whatever structure currently
exists. Within that, structure follows the knowledge rather than the
knowledge being forced into a predetermined structure.

New topic files and folders are created **by the curator, on demand**, not
by working agents mid-session (working agents stage rough entries in the
inbox instead — see "Core philosophy" above). A working agent proposes a
topic tag on its candidate entry; the curator decides whether that becomes
a new file, a new folder, folds into an existing file, or doesn't warrant
a file at all. Curation still applies judgment about when a new file
earns its place (see `CURATOR.md`) — this change removes the fixed-shape
constraint, not the judgment call.

## What's worth remembering

A candidate is appropriate when the information is:

- likely to matter again
- difficult or non-obvious to rediscover
- a verified working solution or reusable technique
- a durable environment constraint
- a stable preference
- a useful lesson from a failure or repeated correction
- a real decision with rationale worth keeping
- something that took meaningful effort to discover or decide

Two tests:

> Would another agent (or you) working weeks or months from now benefit from
> knowing this?

> Could this be trivially rediscovered from the code, a document, or a
> quick search?

If the first is no, or the second is yes, it usually isn't worth saving.

## What NOT to remember

- temporary debugging state or routine command output
- conversation transcripts or summaries kept just for the sake of it
- current task progress or temporary plans
- obvious facts visible directly in source/docs
- generic, easily-searched knowledge (e.g. "Postgres defaults to port 5432")
- speculative conclusions or unverified guesses
- failed experiments with no reusable lesson
- one-off implementation details unlikely to recur
- routine daily detail with no durable pattern (e.g. what you ate today) —
  unless it reveals a durable fact worth keeping (e.g. a food allergy, a
  standing preference), in which case the curator distills that out rather
  than keeping the raw log

The goal is high signal-to-noise, not maximum retention.

Why not a daily-log/journal architecture: a chronological log accumulates
without ever being forced through a judgment pass, so it decays into noise
that's expensive to search and never actually curated down. The
staging-then-curation model forces every candidate through an explicit
promote/merge/discard decision instead.

## Read/write permissions

Normal agent session (Claude Code or Codex, working on anything):

| Action | Allowed |
| --- | --- |
| Read `MEMORY.md` | Yes |
| Read/grep `memories/**` | Yes |
| Append to `inbox/candidates.md` | Yes |
| Place a file in `inbox/manual-inbox/` | Yes (this is a manual/human step in practice, but nothing stops an agent doing it on request) |
| Write/edit canonical `memories/**` directly | No |
| Delete anything | No |

Curator (invoked deliberately, e.g. `claude "curate my memory per
ai-memory/CURATOR.md"`):

| Action | Allowed |
| --- | --- |
| Read inbox (including `manual-inbox/` file contents) and canonical memory | Yes |
| Promote a candidate into canonical memory | Yes |
| Merge duplicates, update existing entries | Yes |
| Generalize overly specific candidates | Yes |
| Create a new topic file or folder when genuinely warranted | Yes |
| Add `[[wikilinks]]` and `#tags` to canonical entries | Yes |
| Archive obsolete canonical content | Yes |
| Clear processed entries from the inbox | Yes |
| Delete a file from `inbox/manual-inbox/` once fully digested (or discarded) | Yes |
| Append one line per action to `CURATION-LOG.md` | Yes (required) |

The curator never silently deletes. Discarded candidates and archived
canonical content are both recorded in `CURATION-LOG.md` with a one-line
reason, so every removal has an audit trail without needing a full
versioning system. This includes files deleted from `manual-inbox/` after
digestion — the log line is the only record of the original file, since no
copy is retained. See [CURATOR.md](CURATOR.md).

## Retrieval

Do not load all of `memories/` into every session. At the start of
substantial work, an agent reads only `MEMORY.md` (kept small — an index,
not a dump). If something looks relevant, it greps `memories/` for on-topic
files and reads only those, e.g.:

```
rg -i "docker|tailscale" memories/
```

Grep-based retrieval over curated Markdown is sufficient at this scale.
Structured storage (SQLite/FTS5) or embeddings/vector search are explicitly
deferred — not rejected — until curated content grows enough that filesystem
search genuinely stops working well. Because canonical memory is already
curated Markdown, migrating it into a database later is an import step, not
a rewrite.

Once an agent has a relevant file open, `[[wikilinks]]` to other files (see
"Linking and tagging" below) are a second retrieval path — following a link
found in a file that's already known to be relevant is often faster than a
fresh grep, especially for cross-cutting topics that don't share obvious
keywords.

## Linking and tagging

Canonical files link to each other with Obsidian-style `[[wikilinks]]`
(target = path under `memories/`, no extension, e.g.
`[[technical/solutions]]`) and carry `#tags` for topics likely to be
referenced again. Both are maintained by the curator, not working agents —
see `CURATOR.md`'s "Linking and tagging" section for the exact conventions.
Linking is favored wherever genuinely relevant but never mandatory; an
unrelated entry should stay plain rather than have a forced link added to
satisfy the convention. This is metadata layered on top of the plain-files
storage model, not a structural requirement — nothing here needs an actual
Obsidian vault or app; it's just a link/tag syntax convention that plain
Markdown, grep, and (if you choose to) Obsidian itself can all read.

## Concurrency

Single-agent-at-a-time usage is assumed (confirmed with the user). No file
locking or merge strategy is implemented. If that assumption changes later,
revisit before it causes a lost write.

## Size discipline

`MEMORY.md` stays an index: one line or a short pointer per topic file, not
a growing dump. As a soft rule, split a canonical topic file once it grows
past roughly 150 lines rather than letting it grow indefinitely — this keeps
grep-based retrieval fast without needing to decide a hard limit upfront.
A split can be a new sibling file, or, once a topic has enough substructure
of its own, a subfolder of related files replacing the single file — the
curator picks whichever shape best fits, per the open taxonomy above.
