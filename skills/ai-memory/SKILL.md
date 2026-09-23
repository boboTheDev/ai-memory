---
name: ai-memory
description: Read or update the shared ai-memory store when the user asks about remembered facts, memory inbox items, or dated agendas, including requests prefixed with "memory inbox".
---

# AI memory

Use the live store named in the global memory instructions, typically `~/.ai-memory`. The project repository contains templates, not personal data. Let the user's actual request determine which part of the store to use; a bare "memory inbox" prefix only invokes this workflow.

- For remembered facts, read `MEMORY.md`, then relevant files under `memories/`. Search that tree when the topic is unclear. Do not read the entire tree by default.
- For pending or unprocessed memory, read `inbox/candidates.md`; inspect `inbox/manual-inbox/` when the request concerns files placed there.
- For plans, dates, schedules, or agendas, read `agenda/YYYY/MM.md`. For an open-ended question such as "any future agendas", list the month files and read all months from the current month onward, then filter out past entries. For a bounded period, read only the relevant months.
- For a mixed request, consult each relevant part. Do not infer that an empty inbox means the agenda or canonical memory is empty.

Append to `inbox/candidates.md` only when the user asks to save something to memory. Add a dated event directly to the appropriate agenda month only when the user asks to add it. Follow the live store's `agenda/README.md` for event format and `CURATOR.md` for deliberate curation. Do not edit canonical `memories/**` during ordinary use.
