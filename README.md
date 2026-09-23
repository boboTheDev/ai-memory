# ai-memory

A shared, curated, long-term memory system for Claude Code and Codex CLI. One
brain, shared by both tools, not tied to any single project. It is a "second
brain" — technical lessons, project business/decisions, and general personal
knowledge (health, travel, academic, finance, people, and anything else you
feed it) — kept small, high-signal, and easy to inspect by hand.

It does **not** replace either tool's normal session/working context, and it
does **not** replace per-project technical memory (e.g. Project Master's
`.project-meta/`). It exists one level above all of that, for knowledge worth
keeping across sessions, projects, and tools.

Full design rationale: [DESIGN.md](DESIGN.md).

## Repo layout: template vs. live data

This repository holds only the **template** — structure, instructions, and
seed topic files (each just a header + short description, no real content) —
plus a couple of repo-root files that get deployed alongside it. Everything
under [template/](template/), and `DESIGN.md`, is safe to commit and push
in full; there is nothing to gitignore inside either.

The **live data** — the actual store agents read and write, where your real
candidates, curated memories, and curation log end up — is a separate
directory *outside* this git repository entirely, created by
[deploy.sh](deploy.sh). Real content can never land in this repo, because
the live directory is never part of this working copy in the first place —
not a discipline you have to maintain, a directory that simply isn't here.

`deploy.sh` copies `template/` wholesale into the live path, plus
`DESIGN.md` (agents are told to read `<live>/DESIGN.md`, so it has to be
there too, not just at the repo root for humans). `upgrade.sh` keeps that
same handful of pure-instruction files — `CURATOR.md`,
`inbox/manual-inbox/README.md`, `DESIGN.md` — in sync on an
already-deployed live dir later; see "Upgrading instructions" below.

```
ai-memory/                    (this repo — template + a couple of root files, always safe to push)
├── template/
│   ├── MEMORY.md
│   ├── CURATOR.md
│   ├── CURATION-LOG.md
│   ├── inbox/candidates.md
│   ├── inbox/manual-inbox/README.md
│   ├── archive/README.md
│   └── memories/{personal,technical,projects}/...  (open taxonomy — not fixed)
├── deploy.sh                  (copies template/ + DESIGN.md → live path, once)
├── upgrade.sh                  (re-syncs CURATOR.md/manual-inbox README/archive README/DESIGN.md later)
├── bootstrap/                  (snippets for each tool's global config)
├── DESIGN.md                   (also deployed to the live dir — see above)
└── README.md                   (repo-only; never deployed)

~/.ai-memory/                 (live data — NOT in this repo, created by deploy.sh)
├── MEMORY.md                  (grows with real entries)
├── CURATOR.md
├── CURATION-LOG.md              (real audit trail)
├── DESIGN.md                    (copy of the repo-root doc, kept in sync by upgrade.sh)
├── inbox/candidates.md           (real candidates)
├── inbox/manual-inbox/           (drop files here by hand; curator digests + deletes)
├── archive/                      (superseded canonical content, moved here by curator, never deleted)
└── memories/**                   (real curated content — [[linked]] + #tagged by curator)
```

## Deploying on a new machine

1. Clone this repo (or pull it) to wherever you keep it, e.g.
   `~/Projects/AGENT-SKILLS/ai-memory/`.
2. Run `./deploy.sh` (or `./deploy.sh /some/other/path` to override the
   default). This copies `template/` and `DESIGN.md` to `~/.ai-memory` by
   default. It refuses to run if that path already exists, so it never
   overwrites real data on a re-run.
3. Wire up each tool's global bootstrap instructions to point at the live
   path — see [bootstrap/claude-code.md](bootstrap/claude-code.md) and
   [bootstrap/codex.md](bootstrap/codex.md) for the exact snippet to paste
   into each tool's global config file (`~/.claude/CLAUDE.md` and
   `~/.codex/AGENTS.md`), replacing `<AI_MEMORY_PATH>` with the live path
   `deploy.sh` printed.
4. Start using it. See [template/MEMORY.md](template/MEMORY.md) for the
   index format and [template/CURATOR.md](template/CURATOR.md) for how
   curation works — both apply identically to the deployed live copy.

From this point on, agents only ever read/write the live path. This repo's
`template/` stays exactly as seeded unless you deliberately improve the
template itself (e.g. adding a better starter topic file) and choose to
commit that.

## Day-to-day usage

- Normal work in any project, any directory: the agent reads
  `<live>/MEMORY.md` at the start of substantial work if memory looks
  relevant, and greps `<live>/memories/` for anything on-topic.
- To save a discovery, decision, or fact for later: say **"save this to
  memory inbox"** (or "save to memory"). The agent appends a short candidate
  entry to `<live>/inbox/candidates.md` — cheap, no polishing, doesn't break
  flow.
- To save a whole file (a note, a PDF, an export, anything not worth
  typing up as a text entry): drop it directly in
  `<live>/inbox/manual-inbox/` yourself. Nothing reads it until curation
  runs — the curator analyzes it, extracts the durable core, figures out
  its real title, writes it into canonical memory, and deletes the
  original.
- Periodically, run curation deliberately: e.g.
  `claude "curate my memory per ~/.ai-memory/CURATOR.md"`. The curator
  reviews `inbox/candidates.md` and `inbox/manual-inbox/`, promotes/merges/
  discards into canonical topic files under `<live>/memories/` — linking
  related entries with `[[wikilinks]]` and adding `#tags` along the way —
  and logs what it did.
- You can also open and edit any file in the live directory by hand at any
  time — it's all plain Markdown.

## Upgrading instructions on an already-deployed live directory

`deploy.sh` is one-shot — it refuses to touch a live path that already
exists, so it can't be used to push a later improvement out to a live copy
that's accumulated real content. For that, use [upgrade.sh](upgrade.sh)
instead, which only overwrites the pure-instruction files in the live
directory (`CURATOR.md`, `inbox/manual-inbox/README.md`,
`archive/README.md`, `DESIGN.md`) and never touches real data (`MEMORY.md`,
`CURATION-LOG.md`, `inbox/candidates.md`, any files a user has dropped in
`inbox/manual-inbox/`, anything the curator has archived under `archive/`,
`memories/**`).

Local machine → server, some folder there:

1. Edit `template/CURATOR.md`, `DESIGN.md`, or another instruction file in
   this repo, commit, and push.
2. On the server, `git pull` this repo in whatever folder it's checked out
   to there.
3. On the server, run `./upgrade.sh <live-path>` (e.g. `./upgrade.sh
   ~/.ai-memory`), pointing at that server's live directory.

Re-running `upgrade.sh` is always safe — it only copies files whose content
actually changed and leaves everything else alone.

If you change a `bootstrap/*.md` snippet, there's no file to sync — repaste
the updated snippet into that machine's `~/.claude/CLAUDE.md` or
`~/.codex/AGENTS.md` by hand, on each machine.

## Improving the template itself

If you land on a better starter file, a clearer instruction, or a new
seed topic worth shipping to every future deploy, edit it under
`template/` (or `DESIGN.md` at the repo root) in this repo — never the live
copy — and commit that. That's the legitimate path for real content-shaped
text to enter this repo, since it's meant as a reusable starting point or
system documentation, not personal data.
