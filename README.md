# lisa

> Dictation pilot: speak on the phone/tablet → text appears (or is saved) on the computer, in any focused field, in the style of [Whispering/WhisperFlow](https://github.com/braden-w/whispering).

## What it is

**lisa** is the test pilot for [pepper.ai](https://github.com/tamires-manhaes) — a local voice assistant under construction. Here we validate the full cycle *"capture on mobile → transcription on the Mac → use the text on desktop"* before integrating into pepper:

1. **PWA** (web, installable on phone/tablet) captures the voice — `getUserMedia` + AudioWorklet → WAV PCM 16kHz mono
2. **lisa-listener** (Fastify, HTTPS on the LAN) orchestrates [whisper.cpp `large-v3-turbo`](https://github.com/ggml-org/whisper.cpp)
3. The result has 3 destinations:
   - **Inject** — text gets typed into the focused field on macOS (clipboard + simulated `Cmd+V`) *— the central challenge of the pilot*
   - **Save** — record in SQLite (schema mirrored from pepper, easy migration)
   - **Display** — just the transcript in the app

No auth: runs on the local/trusted network. Nothing leaves the LAN. Pilot criteria: machine from zero running in < 30 min, speech→text latency < 2s.

## v0 goal

Prove the loop. The milestones tell the story:

| Milestone | Deliverable |
|---|---|
| **v0.1** | Basic loop: PWA records → listener transcribes → transcript displayed + latency benchmark |
| **v0.2** | Text injected into the focused field of macOS (validation matrix: Safari/Obsidian/VS Code/Notes/Slack) |
| **v0.3** | Save mode (SQLite, pepper's schema) |
| v0.4 | (Optional, only if the pilot goes well) VAD + pilot report |

If the pilot passes: `packages/inject` + listener are extracted as a **pepper.ai module**. lisa is not the final product.

## Monorepo

```
apps/listener      Fastify :8080 — API, orchestrates whisper, inject, persistence
apps/web           PWA (Vite + React) — recording screen
packages/shared    protocol + types + errors (single source of truth app↔server)
packages/audio     WAV encode + downsample + validation
packages/inject    pure inject lib + CLI (the future pepper module)
```

Rules: `apps/*` → `packages/*`, never the other way around; the protocol lives **only** in `packages/shared`.

## How to contribute

1. Check the board: https://github.com/tamires-manhaes/lisa/projects — `Backlog` grouped by `Phase`
2. Pick an unlocked **Slice** (parent issue) — dependencies in the `Dependencies` section of the body. Sub-tasks are the steps of the slice: do all of them, close it, PR.
3. Branch `feat/desc`, PR to `main` — CI runs typecheck + lint + test.
4. The full spec is in [`SPEC.md`](SPEC.md); the issue plan with item-by-item checklist coverage is in [`docs/issues-plan.md`](docs/issues-plan.md).

Rules of thumb: slice = 1 PR ≈ up to ~500 diff lines; nothing outside the spec (questions → `SPEC.md` first, issue second).
