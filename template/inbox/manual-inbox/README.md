# Manual Inbox

Drop raw material here by hand: notes, PDFs, text files, exports, screenshots
— anything you want folded into long-term memory but haven't written up as a
candidate entry yourself. Unlike `../candidates.md` (short text entries an
agent appends during normal work), this is for whole files.

Just place files directly in this folder (no naming convention required).
Do not create subfolders here — flat only, so the curator doesn't have to
guess whether a subfolder is meaningful structure or accidental.

## What the curator does with them

Handled only during a deliberate curation pass (see `../../CURATOR.md`),
same as `candidates.md`. For each file found here, the curator:

1. Reads/analyzes the file to extract the core idea — not everything in it,
   just what's durable and worth keeping (same bar as any other candidate,
   per `../../DESIGN.md`).
2. Determines the file's *real* name/title — from its content, metadata,
   or a clear title if present; generates a descriptive one if not. The
   original filename on disk is not trusted as the title (e.g. `scan0042.pdf`
   tells you nothing).
3. Writes a summary (plus any other durable detail worth keeping) into the
   right place under `../../memories/` — same PROMOTE/MERGE/UPDATE
   judgment as any other candidate, same linking/tagging conventions.
4. Deletes the original file from this folder. No copy is kept — the
   `CURATION-LOG.md` entry (original filename, generated title, where the
   digest landed) is the only record that it existed.

This folder should be empty between curation passes. If you see files
sitting here, curation hasn't run yet.
