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
Candidate memory (`inbox/candidates.md`)
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

## Why not a fixed category list

An earlier draft of this design used five fixed categories (solutions,
techniques, environment, preferences, lessons) borrowed from an ops/dev
memory pattern. That works for a narrow technical-assistant use case, but
this system is meant to be a general second brain — thesis, flights, meals,
workouts, project business decisions, technical lessons, all of it. Fixed
categories from one domain don't fit knowledge from every domain.

Instead, canonical memory is organized as an **open topic taxonomy** under
three top-level axes:

- `memories/personal/` — health, academic, travel, finance, preferences,
  people, and anything else about your life. Not project- or tool-specific.
- `memories/projects/<project-name>.md` — non-technical project knowledge:
  business logic, decisions and their rationale, periodic summaries. One
  file per project by default. This is deliberately a thin layer, not a
  replacement for a project's own deep technical memory (e.g. Project
  Master's `.project-meta/`) — it's what you'd want to recall about a
  project from *outside* that project's own directory.
  Not created until a project actually has something worth remembering.
- `memories/technical/` — solutions, techniques, and environment facts that
  aren't tied to one project (e.g. durable server/infra facts, reusable
  debugging techniques).

New topic files are created **by the curator, on demand**, not by working
agents mid-session. A working agent proposes a topic tag on its candidate
entry; the curator decides whether that becomes a new file, folds into an
existing one, or doesn't warrant a file at all. This keeps the taxonomy from
sprawling into one file per trivial topic.

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
| Write/edit canonical `memories/**` directly | No |
| Delete anything | No |

Curator (invoked deliberately, e.g. `claude "curate my memory per
ai-memory/CURATOR.md"`):

| Action | Allowed |
| --- | --- |
| Read inbox and canonical memory | Yes |
| Promote a candidate into canonical memory | Yes |
| Merge duplicates, update existing entries | Yes |
| Generalize overly specific candidates | Yes |
| Create a new topic file when genuinely warranted | Yes |
| Archive obsolete canonical content | Yes |
| Clear processed entries from the inbox | Yes |
| Append one line per action to `CURATION-LOG.md` | Yes (required) |

The curator never silently deletes. Discarded candidates and archived
canonical content are both recorded in `CURATION-LOG.md` with a one-line
reason, so every removal has an audit trail without needing a full
versioning system. See [CURATOR.md](CURATOR.md).

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

## Concurrency

Single-agent-at-a-time usage is assumed (confirmed with the user). No file
locking or merge strategy is implemented. If that assumption changes later,
revisit before it causes a lost write.

## Size discipline

`MEMORY.md` stays an index: one line or a short pointer per topic file, not
a growing dump. As a soft rule, split a canonical topic file once it grows
past roughly 150 lines rather than letting it grow indefinitely — this keeps
grep-based retrieval fast without needing to decide a hard limit upfront.
