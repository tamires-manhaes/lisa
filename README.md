# lisa

[![CI](https://github.com/tamires-manhaes/lisa/actions/workflows/ci.yml/badge.svg)](https://github.com/tamires-manhaes/lisa/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> Hardware dictation pilot: press **Record** on an ESP32 mic device → the local server transcribes with local whisper.cpp → the text appears in the Next.js panel (or, in phase 2, is typed into the focused field on the desktop) — in the style of [Whispering/WhisperFlow](https://github.com/braden-w/whispering).

## What it is

**lisa** is the test pilot for [pepper.ai](https://github.com/tamires-manhaes) — a local voice assistant under construction. After a major pivot (2026-11-27) it validates the full cycle *"hardware capture → local transcription → use of the text"*:

1. **ESP32 recorder** (firmware app): I2S mic (INMP441), 3 buttons (**Record / Pause / Stop**), ST7735 mini TFT showing status + waveform + elapsed time; spools audio to LittleFS and uploads the 16 kHz mono WAV to the server on Stop
2. **lisa-server** (Python/FastAPI): orchestrates a background worker that runs the **whisper.cpp binary** (`large-v3-turbo`, Metal) on the recording; stores sessions in SQLite
3. **Destinations of the transcript**:
   - **Display** (v0.1) — in the **Next.js panel** (history, status, replay)
   - **Inject** (v0.2, phase 2) — typed into the focused text field on the desktop (clipboard + `Cmd+V`, Accessibility) *— the central challenge*
4. Everything self-hosted on the user's machine; mkcert HTTPS on the LAN; nothing leaves the home network

Pilot criteria: machine from zero running in < 30 min (`make setup`); **Stop → transcript ≤ 4 s** for a ~19 s phrase (M4 measured 3.0 s).

## v0 goal

| Milestone | Deliverable |
|---|---|
| **v0.1** | Basic loop: ESP32 records → server transcribes → transcript in the Next.js panel + latency benchmark gate |
| **v0.2** | Phase 2: transcript injected into the focused field of macOS (validation matrix Safari/Obsidian/VS Code/Notes/Slack) |
| **v0.3** | Polish: save/delete mode, retry queue hardening, streaming decision, pilot report |

If the pilot passes: the inject package + server dictation core are extracted as a **pepper.ai module**. lisa is not the final product.

## Monorepo (Nx)

```
apps/web         Next.js — panel: live session status, transcripts, history, settings
apps/server      FastAPI (Python/uv) — sessions API, whisper worker, SQLite, inject (v0.2)
apps/firmware    ESP32 firmware (PlatformIO/Arduino) — capture, buttons, display, upload
packages/inject  Python — clipboard/paste helper + Swift helper (the future pepper module)
```

Contract: **OpenAPI-first** — FastAPI exports the schema, the TS client is generated into `apps/web` (CI checks the sync). Nx task graph: `export-openapi → api-client → web build`.

## How to contribute

1. Check the board: https://github.com/users/tamires-manhaes/projects/3 — `Backlog` grouped by `Phase`
2. Pick an unlocked **Slice** (parent issue) — dependencies in `Dependencies` of the body. Sub-tasks are the slice's steps: do all of them, close, PR.
3. Branch `feat/<scope>/<desc>`, PR to `main` — CI runs Python typecheck/lint/test, Next.js lint/build and the firmware build
4. Spec: [`SPEC.md`](SPEC.md) (v3); issue plan: [`docs/issues-plan-v2.md`](docs/issues-plan-v2.md); fresh-machine walkthrough: [`docs/setup.md`](docs/setup.md)

Rules of thumb: slice = 1 PR ≈ up to ~500 diff lines; nothing outside the spec (questions → SPEC.md first, issue second).

> The 2026-11-27 pivot (Nx / Python / Next.js / ESP32) superseded the original pnpm+Fastify+PWA design; PRs #131–136 and issues #1–130 were closed as superseded.
