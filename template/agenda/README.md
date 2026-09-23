# Agenda

Dated events and commitments — the "remind me about X on this date" side of
this system, kept deliberately separate from `../memories/` (curated
durable knowledge). Events don't fit the promote/merge/discard/durability
judgment `../CURATOR.md` applies to `memories/`: a one-off airport pickup
is exactly the kind of thing that model discards, but it's still real and
worth an agent knowing about *until the date passes*. Full rationale in
`../DESIGN.md`.

This is **not** a real calendar app. Nothing here sends notifications,
alerts, or reminders on its own — it's a plain-text agenda that an agent
reads and reasons about when you're talking to it (e.g. "what's coming up
this week", "does this new thing conflict with anything"). For actual
alarms/notifications, use a real calendar.

## Structure

One file per month: `YYYY/MM.md` (e.g. `2026/09.md`), created on demand —
don't pre-create empty months. Keeps any single file small no matter how
long this has been running, unlike one giant chronological log.

## Entry format

One line per event, inside the relevant month file:

```markdown
- YYYY-MM-DD [HH:MM] — Event description
```

Time is optional — omit it for all-day/date-only items. Keep the
description short; put extra detail after an em dash on the same line
rather than spreading one event across multiple lines. Example:

```markdown
- 2026-09-25 14:00 — Pick up Sam at airport, terminal 2, flight UA482
- 2026-09-28 — Rent due
```

Within a month file, keep entries in date order (append in order, or
resort if inserting out of order — small enough files that this is cheap).

## Writing to it

Unlike `../memories/`, agents may append directly to the current/relevant
month file — no inbox staging, no curation pass required. There's no
promote/discard judgment to make for "this event happens on this date";
the date itself is the only fact that matters, and it's either right or
wrong, not more or less durable. Say "add to my agenda: ..." (or similar)
and the agent appends a line to `agenda/<year>/<month>.md`, creating the
year folder and month file if they don't exist yet.

## Reading it

At the start of work where it's relevant, an agent checks `../MEMORY.md`
as usual, and additionally the current month's file (and next month's, if
looking ahead makes sense for the task) under `agenda/`, rather than
scanning every month ever created.

## Cleanup

Past events aren't curated, merged, or promoted anywhere — they just age
out. Periodically (not automatically), you can delete month files once
everything in them is safely in the past and no longer useful context;
there's no requirement to keep history here the way `../CURATION-LOG.md`
keeps one for `memories/`. If a past event turned out to reveal a durable
fact worth keeping (e.g. a recurring commitment, a standing preference),
that's a `memories/` candidate — add it to `../inbox/candidates.md`
separately; the agenda entry itself still just ages out.
