# lisa — Issues Plan v2 (post-pivot, SPEC v3)

> Source: `SPEC.md` **v3** (rewritten 2026-11-27 — pivot: Nx, Python/FastAPI+uv, Next.js panel, ESP32 hardware recorder, OpenAPI-first, whisper.cpp as binary subprocess, mkcert HTTPS). No §12 checklist item and no roadmap item is left without an issue — § Coverage at the end.
> The v1 plan (`docs/issues-plan.md`, pnpm/turborepo + Fastify + PWA capture) is **superseded**; see the Supersede Mapping section. The old file stays untouched for archive.

## Summary — issue tree

```
Epic 0 — Nx workspace + tooling (milestone v0.1)
├── S1  chore(infra): Nx workspace root
├── S2  chore(web): Next.js skeleton in the workspace
├── S3  chore(server): FastAPI skeleton with uv
├── S4  chore(firmware): PlatformIO skeleton
├── S5  chore(infra): environment scripts — whisper.cpp + mkcert HTTPS
├── S6  chore(repo): CI matrix + .gitignore + LICENSE
└── S7  docs(infra): Makefile make setup + READMEs + docs/setup.md
Epic 1 — v0.1 server + panel (milestone v0.1)
├── S8  feat(server): SQLite session store
├── S9  feat(server): POST /api/sessions — WAV upload + validation
├── S10 feat(server): whisper.cpp worker — subprocess queue + crash recovery
├── S11 feat(server): GET sessions + /api/health complete + structured logs
├── S12 chore(web): OpenAPI-generated client chain
├── S13 feat(web): panel shell + settings/connectivity
├── S14 feat(web): dashboard — session cards + polling + transcript
└── S15 feat(web): history + expandable transcripts
Epic 2 — v0.1 ESP32 firmware (milestone v0.1)
├── S16 chore(firmware): bring-up — display + buttons
├── S17 feat(firmware): I2S mic capture — 16 kHz mono
├── S18 feat(firmware): session state machine + LittleFS spooling + live display
├── S19 feat(firmware): WiFi + HTTPS upload + health probe
├── S20 feat(firmware): pending-session retry queue
└── S21 feat(firmware): soft-AP provisioning portal
Epic 3 — v0.1 integration & gate (milestone v0.1)
├── S22 test: make smoke — real e2e via curl
├── S23 test(web): Playwright display smoke (fake sessions)
└── S24 docs: latency benchmark (§13) + v0.1 gate
Epic 4 — v0.2 inject on desktop (milestone v0.2)
├── S25 feat(inject): packages/inject skeleton + clipboard
├── S26 feat(inject): Cmd+V — Swift CGEvent helper
├── S27 feat(inject): keystroke fallback + strategy selection
├── S28 feat(inject): clipboard restoration + copy race
├── S29 feat(inject): Accessibility permission + lisa-inject CLI
├── S30 feat(server): mode=inject end-to-end + /api/sessions/{id}/inject
├── S31 feat(web): inject mode in the panel
├── S32 test(web): Playwright inject smoke (mocked inject)
└── S33 docs: inject matrix (5 apps)
Epic 5 — v0.3 polish (milestone v0.3, optional items)
├── S34 feat(server): save mode + session delete
├── S35 feat(web): save-mode UI + history delete
├── S36 feat(web): PWA installable (optional)
├── S37 docs: SSE evaluation + streaming feasibility decision
└── S38 docs: pilot report + pepper migration plan
```

**Totals:** 38 slices → 94 children → **132 issues**. Milestones: v0.1 = S1–S24 (84 issues), v0.2 = S25–S33 (27), v0.3 = S34–S38 (21). **No v0.4 milestone** — the spec creates it only after pilot success; the pilot-report slice (S38) is already v0.3-scoped.

## Why 6 epics (deviation from the 4-milestone grouping)

- The v0.1 milestone carries the whole hardware program. Firmware is moved to its own epic (Epic 2) because bring-up risk is staged (display/buttons → mic → spooling → upload → provisioning) and `firmware:build` is independent in the Nx graph (SPEC §5) — it can proceed in parallel with S8–S15.
- A small integration epic (Epic 3) holds the artifacts that only make sense after device + server + panel converge: `make smoke`, Playwright smoke, and the §13 latency gate (`Stop → transcript ≤ 4 s` for a 19 s phrase).
- Inject stays one epic (Epic 4) and polish one (Epic 5), matching SPEC §14 v0.2/v0.3.

## Creation rules

- Create in global order S1 → S38. Within each slice: create the **parent first** (`gh issue create` with title/body/labels/milestone), then the children, each with `Part of #<parent number>` as the first line of the child body. Then edit the parent and append the children numbers to its **Tasks** tasklist.
- Labels to create once before starting: `feat`, `chore`, `docs`, `test`, `milestone: v0.1`, `milestone: v0.2`, `milestone: v0.3`, and scopes `web`, `server`, `firmware`, `inject`, `infra`.
- Milestones to create: `v0.1`, `v0.2`, `v0.3` only.
- Every slice = 1 PR ≈ up to ~500 diff lines. A slice never depends on a slice from a later epic/milestone.
- Hardware slices (S16–S21) require the physical devkit/mic/display; their "Acceptance" lines assume `pio run -t upload` onto real hardware.

---

# EPIC 0 — Nx workspace + tooling (milestone v0.1)

---

## #S1 — `chore(infra): Nx workspace root — nx.json, pnpm, shared configs` — creation no. 1

Labels: `chore`, `milestone: v0.1`, `infra`
> SPEC §5: "One Nx workspace. `project.json` per project wraps the real tool (pnpm, uv, pio) — Nx never replaces the toolchain."

**Context:** the pivot replaces pnpm workspaces + Turborepo with Nx (§3). This slice raises the workspace root: `nx.json`, pnpm as node PM, root scripts via `nx run-many`, and shared lint/ts configs. Python and firmware projects join in S3/S4.

**DoD (parent)**
- [ ] `pnpm install` at the root resolves the workspace
- [ ] root scripts (`dev`, `build`, `lint`, `test`, `typecheck`) run through `nx run-many` and exit green on an empty graph
- [ ] `.env.example` placeholder committed at root (§12.1 — files listed in SPEC §5 tree)

**Tasks**
- [ ] #1.1

**Children**

### #1.1 — `chore(infra): nx.json + root package.json + pnpm-workspace + root scripts`
- Body: `nx.json` (cacheable targets: build/lint/test/typecheck; no cache for serve/dev/upload), `pnpm-workspace.yaml` (node deps only — SPEC §5: Python uses uv, firmware uses pio), root `package.json` scripts delegating to `nx run-many`.
- Acceptance: `pnpm dev` (or `nx run-many -t dev`) exits 0 with zero projects; `nx graph` renders.

### #1.2 — `chore(infra): shared configs — tsconfig base, eslint, prettier, .editorconfig`
- Body: `tsconfig.base.json` (strict, bundler resolution), shared flat eslint + prettier, `.editorconfig`. Consumed by S2; adopted by Python projects only for editor defaults (ruff owns Python lint).
- Acceptance: a throwaway TS file lint+typechecks green via the shared config.

**Dependencies:** none (first issue).

---

## #S2 — `chore(web): Next.js skeleton in the workspace` — creation no. 2

Labels: `chore`, `milestone: v0.1`, `web`, `infra`
> SPEC §5: `apps/web` — Next.js (App Router, TS), targets `dev, build, lint, test, api-client`.

**Context:** the panel replaces the v1 PWA-capture app (§3). v0.1 ships a skeleton with targets wired so S8+ can bolt features on.

**DoD (parent)**
- [ ] `nx run web:build` and `nx run web:lint` green
- [ ] `/api/*` proxied to `http://localhost:8000` (no CORS, §9.4)
- [ ] responsive viewport verified at phone width (§9.1)

**Tasks**
- [ ] #2.1
- [ ] #2.2

**Children**

### #2.1 — `chore(web): Next.js App Router scaffold + project.json targets`
- Body: `apps/web` Next.js (App Router, TS) with `project.json` targets `dev/build/lint/test` and `src/` layout per §5. Empty single-column page, mobile-first viewport meta.
- Acceptance: `nx run web:build` produces a working production build (part of §12.1 "targets wired").

### #2.2 — `chore(web): Next rewrites proxy /api/* → localhost:8000`
- Body: `next.config` rewrites `/api/:path*` → `http://localhost:8000/api/:path*` (§9.4 — same-origin from the browser, no CORS config). Port/host configurable via env.
- Acceptance: with the server stub from S3 running, a browser call to `:3000/api/health` returns the server's JSON.

**Dependencies:** #S1.

---

## #S3 — `chore(server): FastAPI skeleton with uv in the workspace` — creation no. 3

Labels: `chore`, `milestone: v0.1`, `server`, `infra`
> SPEC §3: "Python 3.12+ (FastAPI + uvicorn)… uv per Python project (pyproject + uv.lock)."

**Context:** replaces the v1 Fastify listener. Nx wraps uv via `run-commands` executors (§5 — chosen over `@nxlv/python`, fallback tracked in §15 open). Ships config, minimal health, and the `export-openapi` target that anchors the OpenAPI-first contract.

**DoD (parent)**
- [ ] `nx run server:serve/test/lint` all work through `uv`
- [ ] `apps/server/openapi.json` generated by FastAPI and committed (§7.1 — source of truth)
- [ ] config validated at boot via pydantic-settings; no secrets in the repo (§12.1)

**Tasks**
- [ ] #3.1
- [ ] #3.2
- [ ] #3.3

**Children**

### #3.1 — `chore(server): pyproject + uv sync + project.json run-commands targets`
- Body: `apps/server/pyproject.toml` (+ generated `uv.lock` committed) with fastapi, uvicorn, pytest, ruff, pydantic-settings. `project.json` with `run-commands` targets: `serve` (`uv run uvicorn app.main:app`), `test` (`uv run pytest`), `lint` (`uv run ruff check .`), `sync`, and `export-openapi` (writes `apps/server/openapi.json`, declared as cached output). `uv sync` as implicit target dependency (§5).
- Acceptance: `nx run server:serve` serves uvicorn; `nx run server:test` runs pytest (1 smoke test) — §12.1 "targets wired".

### #3.2 — `chore(server): config.py (pydantic-settings) + root .env.example`
- Body: `app/config.py`: port, whisper binary path, whisper model path, db path (default `~/Library/Application Support/lisa/lisa.db`), default mode. Root `.env.example` with one comment line per var (§12.1). Parse at boot; invalid env fails with a readable error listing the offending fields.
- Acceptance: `cp .env.example .env` + defaults → server starts with no edits beyond the whisper paths.

### #3.3 — `feat(server): minimal GET /api/health + export-openapi target output committed`
- Body: `routes/health.py` returning `{status, version, protocol}` (whisper/db/inject fields join in S11 / v0.2, §7.2). `nx run server:export-openapi` writes `apps/server/openapi.json` and it is committed (§7.1 step 2).
- Acceptance: `nx run server:export-openapi` regenerates a byte-stable `openapi.json`; curl `:8000/api/health` answers.

**Dependencies:** #S1.

---

## #S4 — `chore(firmware): PlatformIO skeleton in the workspace` — creation no. 4

Labels: `chore`, `milestone: v0.1`, `firmware`, `infra`
> SPEC §3/§5: "PlatformIO + Arduino framework (fallback: ESP-IDF)… Nx target wraps `pio run`."

**Context:** the capture device is now an ESP32-S3 recorder (§6). Skeleton = buildable firmware with the §5 directory layout (`audio/`, `display/`, `net/`, `provision/`), LittleFS partition, and Nx targets. Board assumed ESP32-S3 devkit (DevKitC-1-class, §6.1).

**DoD (parent)**
- [ ] `nx run firmware:build` compiles via pio; `upload`/`monitor` targets exist without cache (§5)
- [ ] LittleFS `data/` partition declared in `platformio.ini`
- [ ] PlatformIO CLI documented as a PATH prerequisite (§5)

**Tasks**
- [ ] #4.1
- [ ] #4.2

**Children**

### #4.1 — `chore(firmware): platformio.ini (ESP32-S3, Arduino, LittleFS) + stub main.cpp + src/ layout`
- Body: `platformio.ini` for the ESP32-S3 devkit (Arduino framework frame per §6.1), `src/main.cpp` printing a boot banner over serial, empty `src/audio|display|net|provision/` modules, `data/` partition (~2–4 MB LittleFS, §6.1).
- Acceptance: `pio run` compiles and the banner appears over `pio device monitor`.

### #4.2 — `chore(firmware): project.json targets build/upload/monitor (no cache for upload/monitor)`
- Body: `apps/firmware/project.json` with `run-commands` targets `build` (`pio run`), `upload` (`pio run -t upload`), `monitor` (`pio device monitor`) — cache disabled for upload/monitor (§5). Note in the app README: pio CLI must be on PATH.
- Acceptance: `nx run firmware:upload` flashes the stub to the connected devkit (§12.2 "flash" item).

**Dependencies:** #S1.

---

## #S5 — `chore(infra): environment scripts — whisper.cpp + mkcert HTTPS` — creation no. 5

Labels: `chore`, `milestone: v0.1`, `infra`
> SPEC §3/§10: "HTTPS on the LAN via mkcert — DECIDED (2026-11-27). Tailscale Serve returned 501…" and "whisper.cpp binary subprocess… validated 3.0 s / 19 s phrase."

**Context:** re-commits the v1 scripts into the new workspace with updated semantics: whisper.cpp is now a **binary called via subprocess** (no whisper-server process, §3); HTTPS is **mkcert only** (Tailscale Serve dropped). Feeds `make setup` (S7) and the worker (S10).

**DoD (parent)**
- [ ] `scripts/setup-whisper.sh` builds whisper.cpp (Metal) + downloads `large-v3-turbo`, idempotent (§12.1 make setup step)
- [ ] `scripts/run-whisper.sh` repurposed as a CLI smoke run on a fixture WAV (no server, §5 scripts comment)
- [ ] `scripts/setup-https.sh` issues mkcert certs for :3000/:8000, installs the CA on macOS, exports `rootCA.pem` path (§10) — panel opens with no trust warning (§12.4)

**Tasks**
- [ ] #5.1
- [ ] #5.2
- [ ] #5.3

**Children**

### #5.1 — `chore(scripts): setup-whisper.sh — build whisper.cpp (Metal) + large-v3-turbo`
- Body: idempotent script (clones/builds whisper.cc with Metal, downloads `large-v3-turbo` to the configured model path — skips done steps). Paths read from `.env` conventions of #3.2. Model/binary artifacts stay out of the repo.
- Acceptance: running twice in a row doesn't redo download/build; `whisper-cli -m <model> --metal` exists.

### #5.2 — `chore(scripts): run-whisper.sh repurposed — CLI smoke on a fixture WAV`
- Body: §5 comment: "repurposed: smoke-run of the whisper.cpp CLI on a fixture WAV (server process no longer exists)". Script runs `whisper-cli` (subprocess-equivalent from shell) on a committed/pointed fixture and prints the transcript + wall time.
- Acceptance: a ~19 s PT-BR phrase transcribes in ≈3.0 s on the owner's M4 (§3 benchmark reference).

### #5.3 — `chore(scripts): setup-https.sh — mkcert CA + certs for :3000/:8000 + macOS trust + rootCA.pem export`
- Body: creates local CA with mkcert, issues certs for the panel and API hosts, installs the CA in the macOS trust store, prints/exports the `rootCA.pem` path (consumed by firmware provisioning, S21; §6.6/§10). `.env` entries for cert/key consumed by uvicorn and `next dev` (§9.4 — HTTPS on both).
- Acceptance: panel on `https://<mac>:3000` and API on `:8000` open with no browser warning on macOS (§12.4 last item); `rootCA.pem` path printed.

**Dependencies:** #S1 (repo conventions), #S3 (config paths).

---

## #S6 — `chore(repo): CI matrix + .gitignore + LICENSE` — creation no. 6

Labels: `chore`, `milestone: v0.1`, `infra`
> SPEC §12.6: "git init + light CI (GitHub Actions: nx run-many lint/typecheck/test, openapi sync)" — plus `.gitignore` and license.

**Context:** three-language repo → the CI workflow covers uv-based Python, Next.js and the firmware build matrix (§12.6 + build matrix constraint).

**DoD (parent)**
- [ ] CI on PR: web (lint/build/test) + server (ruff, pytest via uv) + firmware (`pio run` build) + openapi sync check (§12.3 last item, §12.6)
- [ ] `.gitignore` covers models, `*.db`, certs, LittleFS fixtures, generated `schema.d.ts` policy (§12.6 item 2 — pick committed-or-not and enforce)
- [ ] LICENSE + status badge on the root README (§12.6 item 3)

**Tasks**
- [ ] #6.1
- [ ] #6.2

**Children**

### #6.1 — `ci: GitHub Actions — pnpm + uv + pio build matrix + openapi sync`
- Body: workflow on PR with three jobs: (1) web — pnpm install, `nx run web:lint web:test web:build`; (2) server — `uv sync`, ruff, pytest; (3) firmware — pio CLI install, `nx run firmware:build`. Plus an `openapi.json` sync step: run `export-openapi`, fail if the file changed (§7.1 step 4).
- Acceptance: PR with a failing job blocks merge; all three jobs green on an empty repo.

### #6.2 — `chore(repo): .gitignore + LICENSE + badge`
- Body: `.gitignore` for whisper models (`*.ggml`, build trees), `*.db`, `*.pem`/certs, LittleFS spool fixtures, dist/. Decide and document: generated `apps/web/src/lib/api/schema.d.ts` is **not** committed (regenerated by `web:api-client` — one policy, enforced). LICENSE (MIT — confirm with the owner) + CI badge on the root README stub.
- Acceptance: clean `git status` after `make setup` runs (no models/db/certs tracked); PR touching api types with stale `schema.d.ts` cannot break the build.

**Dependencies:** #S2, #S3, #S4 (all targets must exist for CI to run).

---

## #S7 — `docs(infra): Makefile make setup + READMEs + docs/setup.md` — creation no. 7

Labels: `docs`, `milestone: v0.1`, `infra`
> SPEC §12.1: "a new Mac + a new ESP32 board configured from zero in < 30 min, with no undocumented manual steps."

**Context:** closes the setup DX: `make setup` orchestrates pnpm/uv/whisper/https (Swift helper compile step activates in v0.2, S26 — reserved placeholder), READMEs per app, and the step-by-step setup doc.

**DoD (parent)**
- [ ] `make setup` runs: `pnpm install`, `uv sync` (server — inject joins in v0.2), `setup-whisper.sh`, `setup-https.sh` (§12.1 item 1)
- [ ] READMEs: root + `apps/web` + `apps/server` + `apps/firmware` (§12.1 item 4)
- [ ] `docs/setup.md` step-by-step incl. mkcert trust + ESP32 flashing/provisioning walkthrough, with screenshots (§12.1 item 4)

**Tasks**
- [ ] #7.1
- [ ] #7.2
- [ ] #7.3

**Children**

### #7.1 — `chore(make): Makefile — one-shot make setup + dev/build/lint/typecheck/test targets`
- Body: `setup` target orchestrating the §12.1 list, with a **reserved** `swift-inject-compile` step (no-op until S26, keeps the one-shot promise stable). Thin targets delegating to `nx run-many`.
- Acceptance: after erasing deps, `make setup` restores a working build on a fresh Mac without manual steps.

### #7.2 — `docs: READMEs (root + apps/web + apps/server + apps/firmware)`
- Body: root README: 5-line pitch, §4 topology sketch, command table. Per-app READMEs: purpose, env/paths, how to run standalone. Firmware README includes the "pio on PATH" prerequisite (§5 rules).
- Acceptance: a new reader runs the project from the READMEs alone.

### #7.3 — `docs: docs/setup.md — from-zero walkthrough (macOS trust, ESP32 flash, screenshots)`
- Body: step-by-step: prerequisites (Node/pnpm, uv, PlatformIO, Xcode CLT), `make setup`, mkcert CA trust on macOS (screenshot), ESP32 flash via `nx run firmware:upload`, and a pointer to the provisioning portal walk (full text lands in S21/#21.3). Timeboxed to the < 30 min criterion (§12 header).
- Acceptance: an owner following only this doc reaches "devkit flashed + panel reachable over HTTPS".

**Dependencies:** #S1–#S6 merged.

# EPIC 1 — v0.1 server + panel (milestone v0.1)

---

## #S8 — `feat(server): SQLite session store` — creation no. 8

Labels: `feat`, `milestone: v0.1`, `server`
> SPEC §11: "DB: SQLite at `~/Library/Application Support/lisa/lisa.db` (not in repo)… Python (via sqlite3 stdlib; no ORM)".

**Context:** v0.1 already persists sessions (the worker updates status/transcript rows, §7.3; `/api/health` reports `db`, §12.3), so the store lands here — the save-mode extras (`mode` column usage, UI) come in v0.3 (S34). **Deviation note:** the §11 `transcriptions` schema (save-mode, mirrored from pepper) has no `status`/latency columns, but §7.2 `SessionSummary` carries `status` and `latency_ms` — we add them now (documented in the schema migration comment) so pepper migration stays copy + fill `user_id` + optional column mapping.

**DoD (parent)**
- [ ] DB created at `~/Library/Application Support/lisa/lisa.db` (honors `LISA_DB_PATH` from #3.2), dir auto-created, nothing in the repo
- [ ] `transcriptions` table = §11 columns + additive v0 columns (`status`, `mode`, `latency_ms`, `error`) with a comment referencing §11 and the pepper migration
- [ ] typed repository (insert/get/list) + pytest with a temp DB

**Tasks**
- [ ] #8.1
- [ ] #8.2

**Children**

### #8.1 — `feat(server): SQLite bootstrap at the user path (+ additive columns over §11 schema)`
- Body: `app/db/` bootstrap with stdlib `sqlite3` (WAL), schema v1: §11 `transcriptions` columns (`id` UUID PK, `title` derived from the first sentence, `text`, `audio_size`, `source` default `'dictation'` gaining `'esp32'`, `created_at`) + additive `status TEXT`, `mode TEXT`, `latency_ms INTEGER`, `error TEXT` (deviation documented in a comment: needed by §7.2 status enum + summary fields).
- Acceptance: server boot creates the DB at the configured path with the expected schema; `.gitignore` keeps it untracked.

### #8.2 — `feat(server): repository insert/get/list + pytest temp DB`
- Body: typed access fns (`insert_session`, `get_session`, `list_sessions`, `update_result`) with `DB_ERROR` mapping for low-level failures. Tests against a tmp file DB — SQLite needs no service (runs in CI).
- Acceptance: CRUD covered by pytest in the `nx run server:test` suite.

**Dependencies:** #S3.

---

## #S9 — `feat(server): POST /api/sessions — WAV upload + validation` — creation no. 9

Labels: `feat`, `milestone: v0.1`, `server`
> SPEC §7.2: "POST /api/sessions — Multipart upload of a finalized WAV… Returns `SessionCreated` {id, status: "queued"}".

**Context:** the contract is OpenAPI-first (§7.1): Pydantic models are the single source of truth; `openapi.json` is regenerated and committed at the end of the slice. Server-side validation per §10: WAV header check (16 kHz/mono/16-bit), size cap, content-type.

**DoD (parent)**
- [ ] valid WAV upload → row with `status=queued` → `{id, status: "queued"}` (§7.2)
- [ ] invalid WAV (wrong rate/channels/truncated/oversize) → typed `WAV_INVALID` response (§12.3)
- [ ] `openapi.json` regenerated + committed; CI sync check green

**Tasks**
- [ ] #9.1
- [ ] #9.2

**Children**

### #9.1 — `feat(server): Pydantic models + status enum + typed OpenAPI error responses`
- Body: `SessionCreated`, `SessionSummary`, `SessionDetail`, status enum `queued → transcribing → done | failed` (+ inject/save extensions reserved), error payloads (`WAV_INVALID`, `WHISPER_TIMEOUT`, `SESSION_NOT_FOUND`, `DB_ERROR` — §7.3) declared as OpenAPI responses.
- Acceptance: `nx run server:export-openapi` shows the full request/response schema; committed artifact diffed in the PR.

### #9.2 — `feat(server): multipart POST route + WAV validation + size cap`
- Body: `routes/sessions.py`: takes `audio` (multipart) + `mode` (`display|save|inject`, §7.2), validates RIFF header (16 kHz/mono/16-bit, §10) and size cap, inserts a `queued` row (`source='esp32'` when `X-Lisa-Device: esp32/1.0`), returns `SessionCreated`. Telemetry header `X-Lisa-Device` accepted per §7.3.
- Acceptance: curl upload of a valid 16k mono WAV → 201 `{id, queued}`; PNG-renamed-as-wav or 48 kHz file → `WAV_INVALID` with detail (§12.3).

**Dependencies:** #S8.

---

## #S10 — `feat(server): whisper.cpp worker — subprocess queue + crash recovery` — creation no. 10

Labels: `feat`, `milestone: v0.1`, `server`
> SPEC §7.3: "subprocess → whisper.cpp binary (`whisper-cli -m large-v3-turbo --metal --output-json`) with a timeout… Crash recovery: on server boot, `transcribing` rows older than a timeout are re-queued."

**Context:** the core of §12.3's worker item: concurrency 1 (Metal is serial), timeout → `failed` with a readable error, boot-time re-queue of stale rows. No whisper-server process — one hop less (§3).

**DoD (parent)**
- [ ] queued → transcribing → done happy path with transcript stored (§12.3)
- [ ] whisper timeout → `failed` + `WHISPER_TIMEOUT`, no hang; worker never runs > 1 transcription
- [ ] crash recovery: stale `transcribing` rows re-queued on boot, re-run idempotent (§7.3)
- [ ] pytest with a fake whisper binary fixture (§12.5)

**Tasks**
- [ ] #10.1
- [ ] #10.2
- [ ] #10.3
- [ ] #10.4

**Children**

### #10.1 — `feat(server): whisper runner — subprocess call with timeout + output parse`
- Body: `app/whisper/runner.py`: writes WAV to temp, `subprocess.run` on `whisper-cli -m <model> --metal --output-json` (paths from config), parses the JSON transcript, enforces a configurable timeout. Missing binary/model → typed error (feeds health in S11).
- Acceptance: against the real binary (#5.1) it transcribes the fixture; unit-tested with a fake binary printing canned JSON.

### #10.2 — `feat(server): asyncio worker (concurrency 1) — queued → transcribing → done/failed`
- Body: single-worker loop (§7.3): pulls oldest `queued`, sets `transcribing`, calls the runner, stores text + `latency_ms`, sets `done` or `failed` (`WHISPER_TIMEOUT` on timeout, `DB_ERROR` mapped). Concurrency 1 enforced; crashes of the process itself don't lose rows (SQLite is the queue).
- Acceptance: two rapid uploads complete strictly sequentially; timeout produces `failed` with a readable error.

### #10.3 — `feat(server): crash recovery — re-queue stale transcribing rows on boot`
- Body: startup hook re-queues `transcribing` rows older than the runner timeout (§7.3); re-run is idempotent (same output row, fresh `latency_ms`).
- Acceptance: kill the server mid-transcription with a fake binary; on restart the session completes.

### #10.4 — `test(server): fake whisper binary fixture suite`
- Body: fixture script emitting deterministic transcripts (also with a delay > timeout variant) used by worker tests — §12.5 "pytest server (routes + worker with fake whisper binary fixture)".
- Acceptance: worker branch coverage (done/failed/timeout/recovery) runs in CI without real whisper.

**Dependencies:** #S8, #S9, #S5 (real binary for manual validation).

---

## #S11 — `feat(server): GET sessions + /api/health complete + structured logs` — creation no. 11

Labels: `feat`, `milestone: v0.1`, `server`
> SPEC §7.2: "GET /api/sessions — List, newest first… GET /api/sessions/{id} — the panel polls this for active sessions."

**Context:** completing the v0.1 API surface (§7.2) plus two §12.3 items: full health and structured per-session logs.

**DoD (parent)**
- [ ] `GET /api/sessions`, `GET /api/sessions/{id}` per §7.2 (incl. latencies in detail)
- [ ] `/api/health` complete for v0.1: whisper (ok, model), db, version, protocol (§12.3 item 1 — inject field arrives in v0.2)
- [ ] one structured log line per session: total latency, whisper latency, WAV size, source, mode, success/failure (§12.3 item 4)
- [ ] `openapi.json` updated for the GET routes + errors

**Tasks**
- [ ] #11.1
- [ ] #11.2
- [ ] #11.3
- [ ] #11.4

**Children**

### #11.1 — `feat(server): GET /api/sessions — list (limit/offset, newest first)`
- Body: paginated list returning `SessionSummary[]` (id, status, title, excerpt, audio_size, source, created_at, latency_ms — §7.2). Sane `limit` cap; stable ordering.
- Acceptance: curl after 3 uploads lists 3 newest-first with correct summaries.

### #11.2 — `feat(server): GET /api/sessions/{id} — detail + latencies`
- Body: `SessionDetail` (status + full transcript + total/whisper latencies — §7.2); unknown id → `SESSION_NOT_FOUND`.
- Acceptance: in-flight poll shows `transcribing`, then `done` with transcript and latency values.

### #11.3 — `feat(server): /api/health complete (whisper ok/model, db, version, protocol)`
- Body: fills the v0.1 health fields (§7.2): whisper binary+model presence check, db check (cheap query), `version`, `protocol`. `inject` reserved (`null` until v0.2, S30).
- Acceptance: with the binary removed from PATH/model path wrong → `whisper.ok=false`, endpoint still 200 (§12.3 item 1).

### #11.4 — `feat(server): structured per-session log line`
- Body: on each session completion emit one structured line: id, total latency, whisper latency, audio_size, source, mode, ok/error+code (§12.3 item 4). Logger configured with level via env (#3.2).
- Acceptance: one upload = one grep-able JSON line with all fields (§12.5 telemetry source).

**Dependencies:** #S9, #S10.

---

## #S12 — `chore(web): OpenAPI-generated client chain` — creation no. 12

Labels: `chore`, `milestone: v0.1`, `web`, `infra`
> SPEC §7.1: "web:api-client → openapi-typescript generates apps/web/src/lib/api/schema.d.ts; the web uses the generated schema via openapi-fetch."

**Context:** replaces v1's `packages/shared` types entirely — no hand-written TS API types anywhere (§5 rules). This slice closes the chain `export-openapi → generate-client → web build` and enforces it in CI.

**DoD (parent)**
- [ ] `nx run web:api-client` generates `schema.d.ts` from the committed `openapi.json` (§7.1 step 3)
- [ ] `openapi-fetch` client wired and used from a smoke call against `/api/health`
- [ ] Nx task graph: `server:export-openapi → web:api-client → web:build`; CI runs the sync check (§7.1 step 4, §12.3 last item)

**Tasks**
- [ ] #12.1
- [ ] #12.2

**Children**

### #12.1 — `chore(web): openapi-typescript + openapi-fetch wiring (web:api-client target)`
- Body: add `openapi-typescript` + `openapi-fetch`, `api-client` target generating `src/lib/api/schema.d.ts` (not committed — policy from #6.2), plus a thin typed client module consumed by S13/S14.
- Acceptance: `nx run web:api-client` regenerates types matching the current `openapi.json`; a typed health call compiles.

### #12.2 — `chore(infra): nx task graph export-openapi → api-client → build + regenerate on drift`
- Body: declare the dependency chain in Nx so `web:build` always runs after a fresh client generation (§7.1 diagram); the drift check from #6.1 (stale `openapi.json`) covers the contract side — add the client stale check too.
- Acceptance: editing a server route and running `nx run web:build` without regenerating fails fast with a clear "contract stale" error.

**Dependencies:** #S2, #S3, #S11 (routes exist).

---

## #S13 — `feat(web): panel shell + settings/connectivity` — creation no. 13

Labels: `feat`, `milestone: v0.1`, `web`
> SPEC §9.2: screens Dashboard `/`, History `/history`, Settings `/settings` — "no login, no signup."

**Context:** app shell with the three §9.2 routes, responsive single column, plus the connectivity screen backed by `/api/health` (openapi-fetch client of S12).

**DoD (parent)**
- [ ] three routes render, responsive at phone width (§9.1, §12.4)
- [ ] settings shows live `/api/health` status (whisper/db/version) and a default-mode choice (§9.2 screen 3)

**Tasks**
- [ ] #13.1
- [ ] #13.2

**Children**

### #13.1 — `feat(web): app shell — /, /history, /settings + responsive layout`
- Body: App Router shell with nav between the three screens, single-column responsive layout (§9.1), polling/refresh primitives installed for S14.
- Acceptance: usable browser at ~380 px width with no horizontal scroll (§12.4 item 1).

### #13.2 — `feat(web): settings — health connectivity test + default mode`
- Body: settings screen calling `/api/health` via the generated client: status badges (whisper/db), `version`/`protocol`, default mode select (`display|inject|save` — inject/save inert until v0.2/v0.3, §9.2 screen 3).
- Acceptance: server up → green + model shown; server down → red with hint (§12.4 item 3 groundwork).

**Dependencies:** #S12.

---

## #S14 — `feat(web): dashboard — session cards + polling + transcript` — creation no. 14

Labels: `feat`, `milestone: v0.1`, `web`
> SPEC §9.3: "panel dashboard → poll picks up `done` → session card shows transcript + latency → copy button (v0.1)."

**Context:** the visible half of the v0.1 loop (§1). Status transport is REST + polling — no WebSocket (§3). Poll discipline from §9.2: 1 s while active, backoff to 5 s, only on page focus.

**DoD (parent)**
- [ ] session cards newest-first with status badge, transcript + excerpt, round-trip latency, mode indicator (§9.2 screen 1)
- [ ] polling: active sessions at 1 s → backoff 5 s on inactivity; stops on page blur; no drift-induced misses (§12.4 item 2)
- [ ] copy-transcript button (§12.4 item 1)
- [ ] readable error states: server offline, `WHISPER_TIMEOUT`, `WAV_INVALID`, invalid session (§12.4 item 3)

**Tasks**
- [ ] #14.1
- [ ] #14.2
- [ ] #14.3
- [ ] #14.4

**Children**

### #14.1 — `feat(web): session cards — status badge, excerpt, latency, mode`
- Body: dashboard cards per `SessionSummary`/`SessionDetail`: status badge (`queued → transcribing → done/failed`), title + excerpt when done, round-trip latency, mode indicator (§9.2 screen 1).
- Acceptance: a completed upload appears as a `done` card with transcript + latency.

### #14.2 — `feat(web): polling hook — 1 s active → 5 s backoff, page-focus gated`
- Body: poll `GET /api/sessions/{id}` for in-flight cards at 1 s, back off to 5 s when the page is blurred or after an idle window (§9.2/§12.4 item 2). Single shared poller, no duplicate intervals.
- Acceptance: with the tab backgrounded no polls fire (verified in devtools); on focus it resumes with no missed transitions.

### #14.3 — `feat(web): copy-transcript button`
- Body: copy the full transcript to the clipboard with success feedback (§9.2 screen 1).
- Acceptance: paste after copy matches the transcript exactly.

### #14.4 — `feat(web): readable error states (offline / WHISPER_TIMEOUT / WAV_INVALID / not found)`
- Body: error map from typed API errors to UI messages + suggested action (§12.4 item 3): server offline → "check server", timeout → re-poll hint, invalid session → card removed with note.
- Acceptance: each error state reachable and rendered per §12.4 item 3.

**Dependencies:** #S12, #S11.

---

## #S15 — `feat(web): history + expandable transcripts` — creation no. 15

Labels: `feat`, `milestone: v0.1`, `web`
> SPEC §9.2 screen 2: "History /history — paginated list (GET /api/sessions), card → expandable full transcript."

**Context:** consumes the list endpoint from S11; save-mode rows surface here in v0.3 (§9.2 screen 2 note) — no extra work then.

**DoD (parent)**
- [ ] paginated history using `limit/offset` (§9.2 screen 2)
- [ ] card → expandable full transcript, responsive (§12.4 item 1)

**Tasks**
- [ ] #15.1
- [ ] #15.2

**Children**

### #15.1 — `feat(web): history page — pagination over GET /api/sessions`
- Body: list page with older/newer or `limit/offset` pagination wired to the generated client; same card component as S14.
- Acceptance: with > one page of sessions, pagination shows all items without gaps or duplicates.

### #15.2 — `feat(web): expandable full transcript in history cards`
- Body: card expands to the full transcript (detail fetch on expand), collapses cleanly; reuses the S14 error states.
- Acceptance: expand shows the exact stored transcript at phone width.

**Dependencies:** #S11, #S13, #S14.

# EPIC 2 — v0.1 ESP32 firmware (milestone v0.1)

> Staged bring-up, one hardware concern per slice (display/buttons → mic → spooling → upload → retry → provisioning). Each acceptance is validated on a real devkit (`nx run firmware:upload`).

---

## #S16 — `chore(firmware): bring-up — ST7735 display + 3 buttons` — creation no. 16

Labels: `chore`, `milestone: v0.1`, `firmware`
> SPEC §6.1/§6.4: "ST7735-class TFT 160×80 (SPI)… Driver: LovyanGFX (preferred) or TFT_eSPI. 3 × tactile on GPIO, debounce ~30 ms."

**Context:** first contact with the hardware. Resolves two §15 open points in-slice via a decision record: exact display variant and pins (§6.1 tentative pins get fixed here). Display renders the 7 §6.4 states as static layouts; live waveform/timer data arrives in S18.

**DoD (parent)**
- [ ] display shows all 7 UI state layouts (IDLE/RECORDING/PAUSED/FINALIZING/UPLOADING/DONE/ERROR placeholders) (§6.4)
- [ ] 3 buttons produce debounced events; debounce ~30 ms verified (§12.2)
- [ ] `docs/firmware-bringup.md` pins + display variant decision recorded (§5 docs; §15 open display model closed)

**Tasks**
- [ ] #16.1
- [ ] #16.2
- [ ] #16.3

**Children**

### #16.1 — `chore(firmware): ST7735 driver bring-up (LovyanGFX) + display-variant decision record`
- Body: integrate LovyanGFX (or TFT_eSPI if the exact module fights back — record why), wire SPI pins, render a test pattern; then the 7 static layouts of §6.4 (colors: IDLE neutral, RECORDING red, PAUSED yellow, DONE green, failures red).
- Acceptance: all 7 §6.4 layouts render legibly on the physical display; module variant + driver lib decision written to `docs/firmware-bringup.md` (closes §15 open 1).

### #16.2 — `feat(firmware): GPIO buttons — debounced Record/Pause/Stop events`
- Body: button module emitting state-change events from the 3 GPIOs (tentative pins REC=4/PAUSE=5/STOP=6, §6.1) with pull-ups and ~30 ms debounce; final pins fixed at bring-up and written to the bring-up doc.
- Acceptance: button events render on the display (state label); no double-fires within the debounce window (§12.2 "debounce verified").

### #16.3 — `docs(firmware): firmware-bringup.md — pins, display variant, flashing walkthrough`
- Body: pins (buttons/I2S/SPI as actually wired), display module + driver choice, flash steps from a clean devkit (§5 tree lists this doc). Feeds `docs/setup.md` (§7.3).
- Acceptance: flashing a second devkit using only this doc works.

**Dependencies:** #S4.

---

## #S17 — `feat(firmware): I2S mic capture — INMP441 16 kHz mono` — creation no. 17

Labels: `feat`, `milestone: v0.1`, `firmware`
> SPEC §6.3: "I2S Philips, 32-bit slots, INMP441 → int16 (scale ≫14), 16 kHz mono."

**Context:** validates mic capture in isolation, before spooling/UI complexity. Sanity check per §12.2: captured-WAV fixture with a spectral sanity check.

**DoD (parent)**
- [ ] INMP441 → int16 samples at 16 kHz mono (32-bit frames shifted/scaled, §6.3)
- [ ] captured session saved as a WAV fixture and passes a spectral sanity check (§12.2 mic item)

**Tasks**
- [ ] #17.1
- [ ] #17.2

**Children**

### #17.1 — `feat(firmware): I2S driver — 32-bit slot read → int16 (≫14) at 16 kHz mono`
- Body: I2S Philips standard, 32-bit slots, L/R pin → GND per §6.1; scale ≫14 to int16; fixed gain at bring-up (§6.3 — no server-side normalization in v0). Sample-rate accuracy verified.
- Acceptance: recorded 5 s of speech produces audible, undistorted playback of the dumped WAV.

### #17.2 — `test(firmware): capture→WAV fixture + spectral sanity check`
- Body: debug path writing captured PCM to a WAV on LittleFS/SD or serial dump; fixture reviewed for DC offset, clipping and frequency content (sine reference + speech) per §12.2 "spectral sanity check via a captured WAV fixture".
- Acceptance: fixture WAV passes the documented sanity check; rate confirmed 16 kHz.

**Dependencies:** #S16.

---

## #S18 — `feat(firmware): session state machine + LittleFS spooling + live display` — creation no. 18

Labels: `feat`, `milestone: v0.1`, `firmware`
> SPEC §6.2 (state machine diagram) + §6.4 RECORDING layout: "bar-graph waveform (~24 bars, 10 Hz refresh) + elapsed mm:ss".

**Context:** the recording core: buttons drive the §6.2 machine, PCM spools to LittleFS (RAM can't hold long sessions — §3), WAV (RIFF header) assembled at Stop. FINALIZING budget < 200 ms (§13).

**DoD (parent)**
- [ ] full button machine per §6.2: pause/resume keeps the session and excludes paused time; stop-while-paused finalizes; REC-while-recording ignored/short beep (§12.2 buttons item)
- [ ] 5-min session spools to LittleFS without failure; ~10 min session cap enforced with warning (§12.2, §6.3)
- [ ] live display: bar-graph RMS ≥ 10 Hz + mm:ss timer correct across pause/resume (§12.2 display item)
- [ ] Stop → WAV assembled (header + spool) in < 200 ms (§13 FINALIZING budget)

**Tasks**
- [ ] #18.1
- [ ] #18.2
- [ ] #18.3
- [ ] #18.4

**Children**

### #18.1 — `feat(firmware): session state machine per §6.2 (IDLE/RECORDING/PAUSED/FINALIZING/…)`
- Body: implement the §6.2 transitions: REC start/resume, PAUSE (mic muted, spooler paused, frozen timer), STOP (from recording or paused) → FINALIZING; REC-while-recording ignored with a short beep; errors show a 5 s message and return to the previous state — audio never dropped silently (§6.2 error rule).
- Acceptance: scripted button sequences match the §6.2 diagram; paused minutes are excluded from the final timer (§12.2).

### #18.2 — `feat(firmware): LittleFS spooler + WAV assembly at Stop (< 200 ms)`
- Body: stream int16 PCM to a LittleFS file during RECORDING (32 KB/s, §3); at Stop write the RIFF/WAV header + spool content — measured FINALIZING time logged (budget < 200 ms, §13).
- Acceptance: a 5-min session spools without data loss (byte count matches expectations); a 10-min wall produces a warning per the cap rules (§6.3 session cap).

### #18.3 — `feat(firmware): session cap ~10 min with wall warning`
- Body: enforce the §6.3 cap (~10 min within the LittleFS partition budget): approaching the wall shows a warning state; hitting it auto-finalizes.
- Acceptance: a forced 11-min record ends as a valid finalized session with the warning shown (§12.2 "session cap enforced").

### #18.4 — `feat(firmware): live display — rolling RMS bar-graph (≥ 10 Hz) + mm:ss elapsed timer`
- Body: RECORDING layout of §6.4: ~24 rolling RMS bars refreshed ≥ 10 Hz plus the elapsed mm:ss timer (paused time excluded). PAUSED layout shows "PAUSED" + frozen timer.
- Acceptance: bar refresh measured ≥ 10 Hz with no display tearing; timer correct across pause/resume cycles (§12.2 display item).

**Dependencies:** #S17.

---

## #S19 — `feat(firmware): WiFi + HTTPS upload + health probe` — creation no. 19

Labels: `feat`, `milestone: v0.1`, `firmware`
> SPEC §6.5: "HTTPS via esp-tls… validating the mkcert root CA provisioned on the device (§10). Health probe (GET /api/health) on boot + on demand: display shows SRV ✓/✗."

**Context:** device talks only to FastAPI :8000 (§4). Upload = one blocking multipart POST (§7.3 — "firmware never needs SSE/WebSocket"). All timeouts explicit; watchdog fed during transfer (§6.5). Retry queue is S20.

**DoD (parent)**
- [ ] finalized WAV POSTs to `/api/sessions` over HTTPS with chain validated against the provisioned root CA (§12.2 HTTPS item)
- [ ] chunked upload with explicit timeouts (connect 5 s, response 30 s…) and watchdog fed (§6.5)
- [ ] `SRV ✓/✗` badge from a health probe on boot and on demand (§6.5)

**Tasks**
- [ ] #19.1
- [ ] #19.2
- [ ] #19.3

**Children**

### #19.1 — `feat(firmware): WiFi STA auto-reconnect + explicit timeouts`
- Body: STA mode with auto-reconnect (§6.5); server host/port/scheme read from NVS (provisioned values); connection/response timeouts wired as constants per §6.5.
- Acceptance: router bounce re-joins without reboot; server host comes from NVS values set at provisioning time.

### #19.2 — `feat(firmware): HTTPS multipart POST with mkcert CA validation (esp-tls) + progress`
- Body: `esp_http_client` with the root CA from NVS validating the server chain (§6.5/§10); chunked multipart upload of the finalized WAV, progress driving the UPLOADING display %, watchdog fed during transfer. **Note:** CA-in-NVS vs CA-in-firmware is a §15 open point — decide in this PR and record it (rotation stays open, §15 open 4).
- Acceptance: on-device upload against the mkcert-signed server passes TLS validation and a session appears server-side as `queued` (§12.2 HTTPS item).

### #19.3 — `feat(firmware): health probe on boot + on demand → SRV ✓/✗ badge`
- Body: `GET /api/health` on boot and on demand (button/menu or after upload failure); result shown as `SRV ✓/✗` in the IDLE badge (§6.4 IDLE layout, §6.5).
- Acceptance: server down → `SRV ✗`; back up → probe restores `✓` without reboot.

**Dependencies:** #S11 (health endpoint), #S18. Provisioning (S21) supplies NVS values — during bring-up, values are injected via a temporary IDF/serial path and replaced by S21.

---

## #S20 — `feat(firmware): pending-session retry queue` — creation no. 20

Labels: `feat`, `milestone: v0.1`, `firmware`
> SPEC §6.2: "Upload failure → keep WAV in flash, state UPLOAD-FAILED with periodic auto-retry (exp. backoff, cap 5 min) — one pending session queued. New Record allowed after retry queue has 1 item max."

**Context:** connectivity-loss resilience (§6.5): recorded audio is never dropped silently. DONE state shows the whisper latency — the device polls `GET /api/sessions/{id}` after a successful upload (§6.4 DONE: "OK ✓ + whisper latency").

**DoD (parent)**
- [ ] upload failure → WAV kept in flash, UPLOAD-FAILED shown, auto-retry with exponential backoff capped at 5 min (§6.2)
- [ ] retry queue ≤ 1 pending session; new Record allowed only when the queue has ≤ 1 item (§6.2)
- [ ] retry queue survives a server outage mid-recording and a power cycle (§12.2 retry item)

**Tasks**
- [ ] #20.1
- [ ] #20.2

**Children**

### #20.1 — `feat(firmware): UPLOAD-FAILED state + backoff retry (cap 5 min)`
- Body: on failed upload persist the pending WAV path; display `UPLOAD-FAILED`/`RETRY n` message (§6.4); retry with exponential backoff capped at 5 min; success transitions to UPLOADING→DONE.
- Acceptance: server stopped at Stop-press → retry loop starts; server restored → upload completes within one backoff window (§12.2 "retry queue survives a server outage").

### #20.2 — `feat(firmware): pending-session persistence + queue cap + DONE latency via polling`
- Body: pending pointer in NVS/LittleFS survives reboot; cap of 1 pending session gates Record (§6.2). After a successful upload, poll `GET /api/sessions/{id}` until `done` and display the whisper latency on DONE (§6.4 "OK ✓ + 3.1s").
- Acceptance: power-cycle mid-retry → session still uploads after boot; DONE shows the real whisper latency from the API.

**Dependencies:** #S19, #S11 (session detail endpoint).

---

## #S21 — `feat(firmware): soft-AP provisioning portal` — creation no. 21

Labels: `feat`, `milestone: v0.1`, `firmware`
> SPEC §6.6: "On first boot (or STOP held 5 s at boot, or 3 failed WiFi joins): ESP32 starts AP `lisa-setup-XXXX` with captive portal… Form: WiFi SSID, password, server URL, mkcert root CA (PEM). Saved to NVS; reboots into STA."

**Context:** keeps "new device → working" under 10 minutes (§6.6); USB-serial provisioning stays as the documented fallback.

**DoD (parent)**
- [ ] soft-AP `lisa-setup-XXXX` with captive portal (DNS redirect) per §6.6
- [ ] form saves SSID/password/server URL/root CA (PEM) to NVS and reboots into STA (§12.2 portal item)
- [ ] re-provision triggers verified: first boot, STOP held 5 s at boot, 3 failed joins (§12.2)
- [ ] USB-serial fallback documented (§6.6, §12.2)

**Tasks**
- [ ] #21.1
- [ ] #21.2
- [ ] #21.3

**Children**

### #21.1 — `feat(firmware): soft-AP captive portal + form → NVS`
- Body: AP `lisa-setup-XXXX` with DNS-captive portal serving the §6.6 form (SSID, password, server URL `https://<mac>:8000`, root CA PEM paste/upload); validation of the PEM before accepting; save to NVS and reboot into STA.
- Acceptance: from a phone, joining `lisa-setup-XXXX` and submitting the form yields a device that joins the LAN and validates the server chain (§12.2 portal item).

### #21.2 — `feat(firmware): re-provision triggers (first boot / STOP 5 s / 3 failed joins)`
- Body: implement the three §6.6 entry conditions into the portal, plus a "portal active" display state; ensure a bad CA/URL can always be re-entered.
- Acceptance: STOP held 5 s at boot reopens the portal; three wrong-SSID joins also trigger it (§12.2 re-provision path verified).

### #21.3 — `docs(firmware): provisioning walkthrough + USB-serial fallback`
- Body: extend `docs/firmware-bringup.md`: portal walkthrough with screenshots, CA paste source (`rootCA.pem` from #5.3), and the USB-serial fallback procedure (§6.6). Cross-link from `docs/setup.md`.
- Acceptance: a new device goes from flash → uploading sessions following this doc only (§12.2).

**Dependencies:** #S19, #S5 (rootCA.pem).

# EPIC 3 — v0.1 integration & gate (milestone v0.1)

---

## #S22 — `test: make smoke — real end-to-end via curl` — creation no. 22

Labels: `test`, `chore`, `milestone: v0.1`, `server`, `infra`
> SPEC §12.5: "make smoke: WAV fixture → curl upload → transcript out" (roadmap v0.1: "make smoke").

**Context:** unlike unit tests, starts the real stack (FastAPI + worker + real whisper binary) and validates the server-side loop in one command. The full-device gate (§13) is measured in S24 — the smoke covers server + fixture WAV only.

**DoD (parent)**
- [ ] `make smoke` runs: server + worker up → `POST /api/sessions` with a fixture → transcript asserts non-empty & plausible → teardown (§12.5)
- [ ] exit code ≠ 0 on any failing step (server not up, no transcript, protocol error)

**Tasks**
- [ ] #22.1
- [ ] #22.2

**Children**

### #22.1 — `chore(tests): committed WAV fixtures (≈3 s / ≈10 s / ≈19 s PT-BR)`
- Body: 16 kHz mono WAV fixtures generated with the same parameters the ESP32 produces (§6.3), used by smoke + benchmark (S24).
- Acceptance: fixtures upload and transcribe to approximately the expected text.

### #22.2 — `chore(make): scripts/smoke.sh + make smoke (spawn, curl, assert, teardown)`
- Body: start server (real whisper if present), poll health, upload fixture, poll the session to `done`, assert a non-empty transcript and print latencies; non-zero exit on any failure.
- Acceptance: `make smoke` green from a clean checkout with `setup-whisper.sh` run once (§12.5).

**Dependencies:** #S10, #S11.

---

## #S23 — `test(web): Playwright display smoke (fake sessions)` — creation no. 23

Labels: `test`, `milestone: v0.1`, `web`
> SPEC §12.5: "web — Playwright smoke (display flow with fake sessions)."

**Context:** panel regression without a real device: fake sessions injected through a mocked server fixture; loop regression runs in CI.

**DoD (parent)**
- [ ] Playwright runs headless against the panel with a mocked API fixture (§12.5)
- [ ] happy path: fake queued→done session appears as a transcript card; error scenario renders the readable message (§12.4 item 3)

**Tasks**
- [ ] #23.1
- [ ] #23.2
- [ ] #23.3

**Children**

### #23.1 — `test(web): Playwright setup + mocked API fixture (fake sessions)`
- Body: Playwright config (chromium/webkit desktop), route-mocked `/api/*` responses (no real server needed), panel served in dev mode.
- Acceptance: `nx run web:e2e` boots and reaches the dashboard against mocks.

### #23.2 — `test(web): happy-path card → transcript render`
- Body: scripted mock: list shows `transcribing` session; poll returns `done` with transcript + latency; card updates live (§9.3 flow).
- Acceptance: green headless run asserting the transcript appears.

### #23.3 — `test(web): error scenario — offline/timeout message`
- Body: mock network failure / `failed` status → readable error state renders (S14.4 map, §12.4 item 3).
- Acceptance: green test asserting the exact message.

**Dependencies:** #S14.

---

## #S24 — `docs: latency benchmark (§13) + v0.1 gate` — creation no. 24

Labels: `docs`, `milestone: v0.1`
> SPEC §13: "End-to-end ≤ 4 s after Stop for a ~19 s sentence; ≤ 2 s for short phrases — v0.1 acceptance gate."

**Context:** the pilot exists to measure. Sources: device DONE display latency (S20.2), server structured logs (S11.4), panel card latency (S14.1). Regression bar: any refactor pushing a 19 s sentence past 4 s fails (§13).

**DoD (parent)**
- [ ] protocol documented (sentences, n runs, device, network) — reproducible from the doc alone
- [ ] results table incl. breakdown: FINALIZING < 200 ms, upload < 500 ms, whisper ~3.0 s, bookkeeping < 50 ms, panel pickup ≤ 1 s (§13 stage budget)
- [ ] the gate verdict explicit: ≤ 4 s for the 19 s phrase, ≤ 2 s short — including the ESP32 path (§12.5 item 1)
- [ ] misses documented as gaps, not hidden

**Tasks**
- [ ] #24.1
- [ ] #24.2

**Children**

### #24.1 — `docs: latency measurement protocol`
- Body: method: sentence set (3 s/10 s/19 s), hardware (M4 + devkit), LAN conditions, run count, which log fields/latencies to read (device DONE, server JSON logs, panel card).
- Acceptance: anyone reproduces the measurement from the doc alone.

### #24.2 — `docs: benchmark results + §13 gate verdict`
- Body: results table vs the §13 stage budgets and the e2e gate; notes (Metal, model, network); gaps called out with hypotheses.
- Acceptance: verdict recorded with real measured numbers (taken from logs, not estimates); gate ≤ 4 s / 19 s sentence passes or the gap is documented.

**Dependencies:** #S20, #S22 merged (device path + server loop + telemetry).

---

# EPIC 4 — v0.2 inject on desktop (milestone v0.2)

> Flow per §8: focus a field on the desktop → Record on the ESP32 → Stop → API transcribes → injects (clipboard + Cmd+V). Panel remains the control plane. No ESP32 change (§3 mode decision).

---

## #S25 — `feat(inject): packages/inject skeleton + clipboard` — creation no. 25

Labels: `feat`, `milestone: v0.2`, `inject`, `infra`
> SPEC §3/§5: "Text inject: clipboard + simulated Cmd+V… Now a Python package (packages/inject)… CLI: lisa-inject "text"".

**Context:** pure Python lib + CLI (uv-managed, `pyproject.toml` + `uv.lock`), knows nothing about FastAPI (§5 rules) — shippable standalone to pepper. Clipboard step 1–2 of §8: snapshot with changeCount, write the transcript.

**DoD (parent)**
- [ ] `packages/inject` uv project with `lisa_inject` module + CLI placeholder + pytest; zero FastAPI imports (§5)
- [ ] `clipboard.py`: read current clipboard (text + changeCount, timestamped snapshot), write text via the native bridge with `pbcopy` spawn fallback (§8 steps 1–2)
- [ ]Nx `packages/inject` wired as a uv run-commands project like the server (§5)

**Tasks**
- [ ] #25.1
- [ ] #25.2

**Children**

### #25.1 — `feat(inject): uv package skeleton — pyproject + lisa_inject module + CLI placeholder + Nx targets`
- Body: `packages/inject/pyproject.toml` (+ `uv.lock`), `src/lisa_inject/` (`clipboard.py`, `paste.py`, `permissions.py` stubs per §5 tree), CLI entry `lisa-inject` (real behavior in S29.2), pytest wired; `project.json` with uv run-commands targets mirroring S3.1 — added to `make setup`'s `uv sync` list (#7.1).
- Acceptance: `uv run pytest` green in the package; `nx run inject:test` works; no framework imports.

### #25.2 — `feat(inject): clipboard.py — snapshot (text, changeCount) + write (native bridge, pbcopy fallback)`
- Body: `getClipboard(): {text, changeCount}` and `setClipboard(text)` via the native NSPasteboard bridge with a `pbcopy` spawn fallback (§8 step 2). Only text crosses the boundary; never interpolated into a shell string (spawn with args, §10 least-privilege note).
- Acceptance: set→get roundtrip preserves accents/emoji; a malicious-looking string injects literally with no shell side effects; pytest with mocked macOS (§12.5).

**Dependencies:** #S1 (workspace), #S7 (`make setup` reserved step).

---

## #S26 — `feat(inject): Cmd+V — Swift CGEvent helper` — creation no. 26

Labels: `feat`, `milestone: v0.2`, `inject`, `infra`
> SPEC §8: "order of preference: native Swift helper compiled at setup (CGEventPost, native/InjectKey.swift) → AppleScript System Events keystroke."

**Context:** step 3 of §8, first preference. The helper compiles in `make setup` (activates the reserved step from #7.1). Requires Accessibility permission for the calling process (checked for real in S29).

**DoD (parent)**
- [ ] `native/InjectKey.swift` sends Cmd+V via CGEventPost; `paste.py` invokes the compiled binary at a stable path
- [ ] `make setup` compiles the helper (reserved step activated) with a clear toolchain error if Xcode CLT is missing (§12.1)

**Tasks**
- [ ] #26.1
- [ ] #26.2

**Children**

### #26.1 — `feat(inject): InjectKey.swift (CGEventPost Cmd+V) + paste.py invoking the compiled binary`
- Body: minimal Swift source sending keyDown/keyUp of V with the Command flag (§8 step 3); `paste.py` locates the compiled binary, maps failures to typed package errors; AppleScript fallback is S27.
- Acceptance: with Accessibility granted, Cmd+V pastes into Safari and VS Code (manual test logged in the PR).

### #26.2 — `chore(inject): activate the Swift compile step in make setup`
- Body: replace the #7.1 reserved placeholder with the real `swiftc` compile → binary at the package path; fail with instructions if the toolchain is absent.
- Acceptance: `make setup` on a fresh Mac produces the helper binary; without it, `paste.py` returns a typed error (no crash).

**Dependencies:** #S25.

---

## #S27 — `feat(inject): keystroke fallback + strategy selection` — creation no. 27

Labels: `feat`, `milestone: v0.2`, `inject`
> SPEC §8: "Inject fallback: AppleScript keystroke type-as-you-type. For fields that ignore paste; slow, only when paste fails… inject_strategy: paste | type."

**Context:** the fallback ships in v0.2 as a selectable strategy (protocol already carries `inject_strategy`); deep validation across apps lands in the inject matrix (S33) — the v1 split of implement-now/validate-later is preserved.

**DoD (parent)**
- [ ] `type` strategy: AppleScript `System Events keystroke` per char with sanitization + size limit
- [ ] `injectText(text, strategy: paste | type)` unified entry; strategy configurable via config/env and per request (§8)

**Tasks**
- [ ] #27.1
- [ ] #27.2

**Children**

### #27.1 — `feat(inject): type strategy — osascript keystroke char-by-char with limits`
- Body: `typeText(text)` via osascript with shell-safe arg passing, special-char handling, a typing-size limit that aborts with a typed error (uncontrolled typing guard), progress logging.
- Acceptance: types accented PT-BR text into Notes; oversized text aborts cleanly; mocked pytest covers it (§12.5).

### #27.2 — `feat(inject): injectText(text, strategy) unified + default strategy from config`
- Body: unified entry choosing `paste` (S26) or `type` (27.1); default from server config `.env`; per-session override via the mode/strategy field the API exposes (S30 defines it in the OpenAPI contract).
- Acceptance: same-signature switch covered by mocked tests; manual check of both strategies in one app each.

**Dependencies:** #S26.

---

## #S28 — `feat(inject): clipboard restoration + copy race` — creation no. 28

Labels: `feat`, `milestone: v0.2`, `inject`
> SPEC §8: "delay 300–500 ms → restore the previous clipboard (unless the user copied something new in that window)."

**Context:** §12.5 item 3 — "clipboard restoration under concurrent user copy". Race guard via changeCount (snapshot from S25.2).

**DoD (parent)**
- [ ] after inject, clipboard restored to the previous content after the 300–500 ms delay (§8 step 4)
- [ ] clipboard changed during the delay → restore skipped (§12.5 item 3)
- [ ] mocked tests of both race outcomes (§12.5)

**Tasks**
- [ ] #28.1
- [ ] #28.2

**Children**

### #28.1 — `feat(inject): restoreClipboard — snapshot → delay → restore`
- Body: in the paste flow: capture snapshot + changeCount before writing the transcript; restore after a configurable 300–500 ms delay; timer cleaned on abort (§8 step 4).
- Acceptance: manual — copy X, dictate, clipboard returns to X within ~0.5 s.

### #28.2 — `feat(inject): concurrent-copy guard (changeCount) + race tests`
- Body: before restoring, re-read changeCount: changed since snapshot → user copied → skip restore with a log (§8). Mocked tests for both outcomes.
- Acceptance: simulating a user copy during the delay preserves the user's content; pytest covers both branches (§12.5 item 3 evidence).

**Dependencies:** #S25, #S26.

---

## #S29 — `feat(inject): Accessibility permission + lisa-inject CLI` — creation no. 29

Labels: `feat`, `milestone: v0.2`, `inject`, `docs`
> SPEC §8: "Permissions: Accessibility for the server process… real check (inject + undo in a test field) → inject: ok | no_permission | failed."

**Context:** the real check (inject one char + undo) feeds `/api/health` in S30. The CLI proves §5 decoupling — the package works with the server off.

**DoD (parent)**
- [ ] `permissions.py`: real inject+undo Accessibility probe → `ok | no_permission | failed` (§8)
- [ ] CLI `lisa-inject "text"` works standalone (flags: `--strategy`, `--no-restore`); exit codes mirror the probe result
- [ ] grant instructions doc (§8 — System Settings → Privacy → Accessibility)

**Tasks**
- [ ] #29.1
- [ ] #29.2

**Children**

### #29.1 — `feat(inject): permissions.py — real inject+undo Accessibility check`
- Body: `checkAccessibility()`: performs the §8 probe (inject 1 char + undo) in a safe test field and reports ok/no_permission/failed; used by health in S30 (cached there — invasive checks are not run on every ping).
- Acceptance: without permission → `no_permission`; granting it (no recompile) flips to `ok`.

### #29.2 — `feat(inject): CLI lisa-inject "text" standalone + permission docs`
- Body: CLI with text arg + `--strategy`/`--no-restore` flags, exit codes mirroring the check; uv-linked binary. Doc section: granting Accessibility with screenshot + re-test via CLI (feeds `docs/setup.md`).
- Acceptance: `uv run lisa-inject "olá"` pastes into the focused app with the server off (§5 decoupling proof); `no_permission` → `ok` achievable by following the doc only.

**Dependencies:** #S28.

---

## #S30 — `feat(server): mode=inject end-to-end + POST /api/sessions/{id}/inject` — creation no. 30

Labels: `feat`, `milestone: v0.2`, `server`, `inject`
> SPEC §7.2: "POST /api/sessions/{id}/inject — v0.2 only: (re)inject a ready transcript into the focused field." / §7.3: status adds `done → injected | inject_failed`.

**Context:** the central challenge of the spec (§2 table). Server invokes `lisa_inject` when `mode=inject` after transcription (§8); `/api/sessions/{id}/inject` re-injects a ready transcript (panel retry). Health grows the real inject status.

**DoD (parent)**
- [ ] upload with `mode=inject` → transcribe → inject → status `injected`; failure → `inject_failed` with typed errors `INJECT_NO_PERMISSION` / `INJECT_FAILED` (§7.2/§7.3)
- [ ] `POST /api/sessions/{id}/inject` re-injects ready transcripts (§7.2) incl. strategy override
- [ ] `/api/health.inject` reports the real permission state (cached — the probe is invasive, §8)
- [ ] `openapi.json` + generated client updated end to end (§12 roadmap v0.2 "error matrices end-to-end through the OpenAPI client")

**Tasks**
- [ ] #30.1
- [ ] #30.2
- [ ] #30.3
- [ ] #30.4

**Children**

### #30.1 — `feat(server): mode=inject flow — transcribe → lisa_inject → injected/inject_failed`
- Body: worker/routes accept `mode=inject` (§7.2); after `done`, call `injectText(text, strategy)` from `packages/inject` (default strategy from config, §27.2); statuses per §7.3; error mapping `INJECT_NO_PERMISSION` (probe result) vs `INJECT_FAILED` (technical failure); inject latency added to the structured log (§12.3 item 4 — inject latency field activates).
- Acceptance: dictating with Safari focused → text pasted; session shows `injected` in the API and panel.

### #30.2 — `feat(server): POST /api/sessions/{id}/inject — re-inject + strategy override`
- Body: route re-injecting a `done` transcript (§7.2), with optional `inject_strategy` (§8); errors `INJECT_*`, `SESSION_NOT_FOUND`; only valid when transcript ready (`injected` states per §7.3).
- Acceptance: a failed inject can be retried from the panel with the opposite strategy successfully.

### #30.3 — `feat(server): health inject — real permission check, cached`
- Body: `/api/health` consumes `checkAccessibility()` (S29.1) with a short TTL cache (§8 note — the probe is invasive); the v0.1 `inject: null` placeholder becomes real (`ok | no_permission | failed`), plus package/version info.
- Acceptance: revoking Accessibility flips health to `no_permission` within the cache window and back on re-grant.

### #30.4 — `chore(server): openapi.json + client regenerated for inject surface`
- Body: regenerate the contract for the new endpoint/fields/errors and commit (§7.1); ensure the generated client type-checks against the new union of statuses (§12 v0.2 "error matrices end-to-end through the OpenAPI client").
- Acceptance: CI openapi/`schema.d.ts` sync checks stay green; web S31 consumes typed inject errors without any hand-written types.

**Dependencies:** #S25–#S29, #S10/#S11 (worker + health).

## #S31 — `feat(web): inject mode in the panel` — creation no. 31

Labels: `feat`, `milestone: v0.2`, `web`, `inject`
> SPEC §9.2/§3 mode note: mode default + panel toggle; "the panel remains the control plane (mode default, retry, history)."

**Context:** the panel is where the user sets the inject default, retries a failed injection (S30.2 route), and gets permission guidance — capture stays on the ESP32.

**DoD (parent)**
- [ ] mode toggle display|inject (save visible, disabled with a v0.3 hint) persisted as default (§3 server-side default + panel toggle)
- [ ] inject feedback: `injected` state + latency; `inject_failed` states readable (§12.4 item 3 — inject case)
- [ ] permission status from `/api/health` with a grant guide for `INJECT_NO_PERMISSION`

**Tasks**
- [ ] #31.1
- [ ] #31.2
- [ ] #31.3

**Children**

### #31.1 — `feat(web): mode toggle (display | inject | save-disabled) with persisted default`
- Body: mode selector bound to the settings default (S13.2); correct `mode` sent to `POST /api/sessions` via the generated client; Save present but disabled ("v0.3", avoids UI rework later — convention carried from v1).
- Acceptance: switching to inject persists across reloads and is sent in uploads.

### #31.2 — `feat(web): injected feedback + inject_failed/error states`
- Body: session card / status shows `injected` with inject latency; `inject_failed` and API errors mapped to readable messages; retry button calling `POST /api/sessions/{id}/inject` (S30.2) with a strategy choice.
- Acceptance: failed inject → readable state → retry succeeds from the panel.

### #31.3 — `feat(web): permission status + grant guide`
- Body: settings shows `health.inject` (`ok | no_permission | failed`, §8); on `no_permission`, error states link to the grant doc (S29.2 instructions).
- Acceptance: revoked permission → panel guides the user until health turns `ok`.

**Dependencies:** #S30, #S13.

---

## #S32 — `test(web): Playwright inject smoke (mocked inject)` — creation no. 32

Labels: `test`, `milestone: v0.2`, `web`, `inject`
> SPEC §14 v0.2: "Playwright smoke of the inject flow (mocked clipboard/keystroke)."

**Context:** the server's inject step is mocked (the real CGEvent path can't be e2e-tested in CI); the panel flow through the typed client is what's under regression.

**DoD (parent)**
- [ ] inject-mode happy path (mode=inject → status `injected`) green headless
- [ ] `INJECT_NO_PERMISSION` → guidance + retry path rendered (§12.4 item 3)

**Tasks**
- [ ] #32.1
- [ ] #32.2

**Children**

### #32.1 — `test(web): mocked inject fixture (server responses with injected/inject_failed states)`
- Body: route-mocked API returning the inject states of §7.3; panel runs against it.
- Acceptance: fixture-driven runs reproduce all inject statuses deterministically.

### #32.2 — `test(web): inject happy path + no-permission error path`
- Body: scripted flows: card → `injected` with latency; `no_permission` → guide link + retry button visible (S31 output).
- Acceptance: both tests green headless in CI.

**Dependencies:** #S31.

---

## #S33 — `docs: inject matrix (5 apps)` — creation no. 33

Labels: `docs`, `milestone: v0.2`, `inject`
> SPEC §14 v0.2: "Validation Safari/Obsidian/VS Code/Notes/Slack — docs/inject-matrix.md."

**Context:** §8 edge cases to record: apps blocking paste, copy race, sandboxed apps; per-app default strategy conclusion (§8 `inject_strategy` note).

**DoD (parent)**
- [ ] `docs/inject-matrix.md` — 5 apps × paste / type / copy-race / latency (§12.5 item 2 — recorded results, no empty cells)
- [ ] actionable conclusion: which apps need the `type` strategy, recommended defaults (§8)

**Tasks**
- [ ] #33.1
- [ ] #33.2

**Children**

### #33.1 — `docs: inject-matrix.md template + experiment protocol`
- Body: matrix template (apps × experiments: paste via helper, type fallback, race, latency) + how-to-run instructions (lisa-inject CLI, focused app, concurrent copy), per §8.
- Acceptance: template committed; anyone can reproduce a cell.

### #33.2 — `docs: run + record the 5 apps; per-app strategy conclusion`
- Body: fill results for Safari, Obsidian, VS Code, Notes, Slack (§14 v0.2); conclude per-app default strategy; "not testable" counts with a reason (no empty cells, §12.5 item 2).
- Acceptance: complete matrix + recorded defaults; feeds the pilot report (S38).

**Dependencies:** #S29 (CLI), #S30 (inject mode).

---

# EPIC 5 — v0.3 polish (milestone v0.3)

> Optional-but-planned items from §14 v0.3. No v0.4 milestone is created — §14/§15 tie streaming decisions and anything else to pilot success.

---

## #S34 — `feat(server): save mode + session delete` — creation no. 34

Labels: `feat`, `milestone: v0.3`, `server`
> SPEC §14 v0.3: "Save-mode UI (SQLite §11 already wired; panel history + delete)." / §11: `source` gains `'esp32'`.

**Context:** SQLite and the transcriptions schema exist since v0.1 (S8); v0.3 activates the `save` mode (§7.2 mode enum) and persistence semantics. **Deviation note:** §7.2's endpoint table has no DELETE, but the roadmap's "panel history + delete" requires one — add `DELETE /api/sessions/{id}` and record it in the contract PR.

**DoD (parent)**
- [ ] uploads with `mode=save` persist to SQLite (`source='esp32'`, derived title, audio_size — §11) mirroring pepper's schema
- [ ] `DELETE /api/sessions/{id}` (roadmap requirement — flagged deviation from §7.2) + openapi regen
- [ ] `DB_ERROR` path covered (§7.3)

**Tasks**
- [ ] #34.1
- [ ] #34.2

**Children**

### #34.1 — `feat(server): mode=save persistence (source=esp32, derived title)`
- Body: `save` branch stores the transcript per §11 (title from the first sentence, `audio_size`, `source='esp32'`); DB failures → `DB_ERROR`; health/db already reported (S11.3).
- Acceptance: a save-mode upload creates the expected row; schema remains pepper-mirroring (§11).

### #34.2 — `feat(server): DELETE /api/sessions/{id} + contract regen`
- Body: delete by id with `SESSION_NOT_FOUND` handling; physical delete of text row (pilot scope); regenerate + commit `openapi.json` (§7.1 flow). Keep the deviation note in the route docstring referencing §14 v0.3.
- Acceptance: delete → list/details 404 afterwards; CI openapi sync green.

**Dependencies:** #S8, #S9.

---

## #S35 — `feat(web): save-mode UI + history delete` — creation no. 35

Labels: `feat`, `milestone: v0.3`, `web`
> SPEC §14 v0.3: "Save-mode UI… panel history + delete."

**Context:** the toggle and history pages already exist (S14/S15/S31); v0.3 activates Save and adds delete affordances.

**DoD (parent)**
- [ ] Save mode functional end to end: record on device → row persisted → panel history shows it (§11 note "save mode rows surface in History")
- [ ] delete action on history/dashboard cards via `DELETE /api/sessions/{id}` (§14 v0.3)

**Tasks**
- [ ] #35.1
- [ ] #35.2

**Children**

### #35.1 — `feat(web): enable Save mode + persisted-row feedback`
- Body: enable the disabled Save option (S31.1), `mode=save` uploads, feedback on the card (saved/`DB_ERROR` readable message per §12.4 item 3 via the S14.4 map).
- Acceptance: ESP32 record with mode=save → transcript appears in History with the saved state.

### #35.2 — `feat(web): delete action on cards (history + dashboard)`
- Body: delete button → `DELETE /api/sessions/{id}` via the generated client; optimistic removal with undo-less confirm (pilot scope).
- Acceptance: deleted session disappears from history and can't be fetched again (404 state handled readably).

**Dependencies:** #S34, #S15, #S31.

---

## #S36 — `feat(web): PWA installable (optional)` — creation no. 36

Labels: `feat`, `milestone: v0.3`, `web`
> SPEC §9.1: "PWA: secondary/optional — manifest + minimal SW deferred to v0.3; the app must be fully usable without it."

**Context:** HTTPS via mkcert has been on since v0.1 (§9.4 — "needed once the PWA lands"), so the secure-context prerequisite is already met.

**DoD (parent)**
- [ ] manifest (standalone, icons) + minimal service worker; `/api/*` never cached (§9.1)
- [ ] installable validation on macOS/iOS browsers; app fully usable without installation

**Tasks**
- [ ] #36.1
- [ ] #36.2

**Children**

### #36.1 — `feat(web): manifest + icons + minimal service worker`
- Body: manifest (name, standalone, icons), minimal SW: shell cache, network-only for `/api/*` (§9.1); offline shell explains the API needs the server.
- Acceptance: Chrome DevTools flags the app installable; a reload offline serves the shell and never a cached API response.

### #36.2 — `docs: install validation note (HTTPS already in place)`
- Body: short doc/README section validating add-to-home on macOS + iOS Safari over the mkcert HTTPS `:3000` (§9.4); note the optional status per §14 v0.3.
- Acceptance: installed app opens standalone with no trust warnings.

**Dependencies:** #S13 (shell), #S5 (HTTPS).

---

## #S37 — `docs: SSE evaluation + streaming feasibility decision` — creation no. 37

Labels: `docs`, `milestone: v0.3`
> SPEC §14 v0.3: "SSE for session status (replaces polling) — evaluate vs 1 s poll reality" and "Streaming evaluation: live capture → server (protocol sketch + feasibility, NOT implementation unless proven trivial); decision feeds pepper."

**Context:** both are evaluate-and-decide items (implementation explicitly deferred, §15 open 5: owner may drop streaming permanently). Decision-record pattern: small docs slice, no code.

**DoD (parent)**
- [ ] written decision: SSE vs 1 s polling — adopt / defer / discard, with the measured poll reality as evidence (§14 v0.3 item 3)
- [ ] streaming protocol sketch + feasibility note (firmware live-capture implications, §15 open 5) feeding pepper; explicit adopt/drop recommendation

**Tasks**
- [ ] #37.1
- [ ] #37.2

**Children**

### #37.1 — `docs: SSE vs 1 s polling decision record`
- Body: measure/argue the actual benefit at 1 s polling with ≤ 1 pending session (§3 status transport rationale); decision with criteria to reopen.
- Acceptance: decision recorded; if kept as polling, polling code stays (no change).

### #37.2 — `docs: streaming evaluation sketch (feeds pepper)`
- Body: what live audio → server would require (firmware streaming protocol + server ingestion, §3 deferral note), cost/risk sketch, feasibility verdict ("not implemented unless proven trivial", §14 v0.3 item 4); adopt/drop recommendation for pepper.
- Acceptance: verdict written with data; §15 open 5 updated with the decision pointer.

**Dependencies:** #S24 (latency data), #S14 (polling reality).

---

## #S38 — `docs: pilot report + pepper migration plan` — creation no. 38

Labels: `docs`, `milestone: v0.3`
> SPEC §14 v0.3: "Pilot report: what migrates to pepper (server-side package extraction, inject as standalone)." / §2: what migrates is the server-side (FastAPI orchestration + whisper call + inject) as a Python package.

**Context:** the pilot's purpose (§1: "code that proves itself good migrates to pepper"). This replaces v1's S33; no code move happens here — the report + extraction plan only.

**DoD (parent)**
- [ ] `docs/pilot-report.md`: what worked/didn't, real numbers (S24 benchmark, S33 matrix), reviewed decisions (§15), explicit "migrates to pepper" list (§14 v0.3 item 5)
- [ ] extraction plan: server-side as a Python package; `packages/inject` standalone packaging path (already framework-free by §5 rule, proven by S29.2 CLI)

**Tasks**
- [ ] #38.1
- [ ] #38.2

**Children**

### #38.1 — `docs: pilot-report.md — results + migration list`
- Body: consolidate benchmark (S24), inject matrix (S33), latency gates, reviewed §15 decisions; list exactly what migrates (FastAPI server package + inject) and what stays.
- Acceptance: report approved by the owner as input to pepper's roadmap.

### #38.2 — `docs: extraction plan — server package + inject standalone`
- Body: concrete steps to lift `apps/server` orchestration (whisper worker + inject) into a Python package and ship `packages/inject` standalone (uv build notes); pepper-integration points from §2.
- Acceptance: a pepper engineer could follow the plan without lisa knowledge.

**Dependencies:** #S33, #S24 and pilot completion (v0.1–v0.3).

## Supersede mapping — v1 issues → v2 slices

The ~130 v1 issues (parents S1–S33 + children per the v1 plan) are superseded as follows. "Salvage" = the concept or file survives from v1 and is re-committed in a v2 slice. v1 children follow their parent unless noted. v1 slices with **no v2 counterpart** were dropped by the pivot (phone capture, TS audio/package protocol).

| v1 slice (plan) | Fate v2 | v2 slice(s) | Salvage / notes |
|---|---|---|---|
| S1 monorepo scaffold (pnpm + turbo + packages) | Superseded (different tooling) | #S1, #S2, #S3, #S4 | Nx replaces turbo; `packages/shared` and `packages/audio` dropped (OpenAPI-first + firmware-side encoding) |
| S2 CI + .gitignore + license | Superseded (re-committed) | #S6 (#6.1, #6.2) | concept survives; now 3-language matrix (uv/pnpm/pio) + openapi sync |
| S3 zod config + .env.example | Superseded (Python now) | #S3 (#3.2) | same vars, pydantic-settings instead of zod |
| S4 whisper.cpp scripts | Superseded-with-salvage | #S5 (#5.1, #5.2) | `setup-whisper.sh` survives; `run-whisper.sh` repurposed to CLI smoke (no :8081 server, §3) |
| S5 HTTPS script (Tailscale or mkcert) | Superseded-with-salvage | #S5 (#5.3) | Tailscale Serve path **dropped** (501 on tailnet); mkcert-only, now trusted on-device via provisioning |
| S6 setup docs + make setup | Superseded (re-committed) | #S7 | Makefile/READMEs/setup.md re-created for the new stack + firmware flash |
| S7 shared protocol v1 (TS) | Superseded (OpenAPI-first) | #S9 (#9.1), #S11 (#11.1/#11.3), #S12 | no hand-written TS types anywhere (§5) |
| S8 audio package (TS encode/validate) | Superseded (different owner) | #S9 (#9.2) | WAV **encoding** now firmware-side (§6.3); server keeps **validation** only |
| S9 Fastify listener base + supervision | Superseded (Python) | #S3, #S10 | uvicorn+FastAPI; whisper supervision → subprocess runner + crash recovery (§7.3) |
| S10 POST /api/dictate | Superseded (new API) | #S9 | endpoints are `POST /api/sessions` + async worker (§7.2) |
| S11 PWA scaffold + host settings | Superseded (Next.js panel) | #S2, #S13 (#13.2) | settings concept kept; host no longer user-set (device talks to :8000, §4) |
| S12 web audio capture (AudioWorklet) | **Dropped by pivot** | — | phone-as-microphone removed (§1 "what NOT"); capture = ESP32 |
| S13 web Record screen | Superseded (UI reshaped) | #S14 | recording control moves to hardware buttons; panel shows session cards |
| S14 installable PWA | Deferred | #S36 (v0.3, optional) | demoted per §3/§9.1 |
| S15 web robustness | Split / partially dropped | #S14 (#14.4), #S20 | secure-context guard dropped (mkcert decided); reconnection → firmware retry queue (#S20) |
| S16 pino structured logging | Superseded (re-committed) | #S11 (#11.4) | same fields, Python structured logs (+ inject latency in v0.2) |
| S17 make smoke via curl | Superseded (re-committed) | #S22 | same pattern, new API; fixture WAVs also feed the benchmark |
| S18 latency benchmark docs | Superseded (re-committed) | #S24 | gate tightened: ≤ 4 s / 19 s sentence incl. device path (§13) |
| S19–S23 inject package slices (TS) | Superseded-with-salvage | #S25–#S29 | same design, Python (`pbcopy`→NSPasteboard-bridge, `CGEvent` Swift helper survives as `native/InjectKey.swift`, changeCount race, real Accessibility check, standalone CLI) |
| S24 INJECT mode in listener + health | Superseded (re-located) | #S30 (#30.1, #30.3) | now FastAPI + `/api/sessions/{id}/inject`; statuses `injected/inject_failed` (§7.3) |
| S25 web inject mode | Superseded (Next.js panel) | #S31 | mode toggle + permission status + retry kept |
| S26 Playwright display e2e | Moved earlier | #S23 (v0.1), #S32 (v0.2 inject variant) | now mocks the API instead of a fake whisper-server |
| S27 inject matrix (5 apps) | Superseded (re-committed) | #S33 | same 5 apps, now with per-app strategy conclusion |
| S28 SQLite + pepper schema | Superseded (Python) | #S8 | stdlib `sqlite3` (no ORM) instead of better-sqlite3; lands in v0.1 (sessions need status) |
| S29 save mode + `/api/notes` | Superseded (API reshaped) | #S34 | no `/api/notes`; saves are sessions (§7.2), delete via `DELETE /api/sessions/{id}` |
| S30 web save mode | Superseded | #S35 | |
| S31 VAD (Silero) in browser | **Dropped by pivot** | — | §3: "No VAD — physical Stop button"; Silero only as pepper-side polish, untracked in v2 |
| S32 keystroke fallback validation | Folded | #S33 (#33.2) | fallback implemented + validated within the matrix slice now (no separate v0.4) |
| S33 pilot report + inject extraction | Superseded (re-committed) | #S38 (#38.1, #38.2) | scope widened: server-side package extraction is §2's headline migration |

## Coverage — §12 "Ready to use" checklist → issues

### 12.1 Setup and DX
| Checklist item | Issue(s) |
|---|---|
| Nx workspace scaffold + `make setup` (pnpm install, uv sync ×2, setup-whisper.sh, setup-https.sh, Swift helper compile) | #S1 (scaffold), #7.1 (make setup; Swift step activated in #26.2, inject `uv sync` added in #25.1) |
| `.env.example` + `config.py` (pydantic-settings), no secrets | #3.2 |
| Targets wired (server:serve/test/export-openapi/lint, web:dev/build/api-client/lint/test, firmware:build/upload/monitor) via nx run-many | #1.1 (root), #2.1, #3.1, #4.2, #12.1 (api-client) |
| READMEs per app + root; docs/setup.md step-by-step with screenshots | #7.2, #7.3 (+ #16.3, #21.3, #29.2 for firmware/inject sections) |

### 12.2 Firmware
| Checklist item | Issue(s) |
|---|---|
| Flash via `nx run firmware:upload` | #4.2 (target), #16.1/#16.2 (first real flash) |
| Buttons state machine (debounce, pause excluded from timer, stop-while-paused) | #16.2, #18.1 |
| Display: all 7 UI states, bar-graph ≥ 10 Hz, timer across pause | #16.1 (static layouts), #18.4 (live) |
| Mic: INMP441 → 16 kHz mono, spectral sanity check | #17.1, #17.2 |
| LittleFS spool: 5-min session, session cap enforced | #18.2, #18.3 |
| Provisioning portal (SSID/pass/URL/CA → NVS, STOP-5 s re-provision, USB fallback doc) | #21.1, #21.2, #21.3 |
| HTTPS upload passes CA validation; retry queue survives outage mid-recording | #19.2, #20.1, #20.2 |

### 12.3 Server
| Checklist item | Issue(s) |
|---|---|
| /api/health complete (whisper model, db, inject v0.2, version/protocol) | #11.3 (v0.1), #30.3 (inject) |
| Worker happy path, crash recovery re-queue, timeout → failed readable | #10.1–#10.4 |
| Upload validation: WAV_INVALID rate/channels, size cap | #9.2 |
| Structured logs (total/whisper/inject latency, size, source, outcome) | #11.4 (+ inject latency in #30.1) |
| openapi.json sync check in CI; api-client before build | #6.1, #12.2 |

### 12.4 Web panel
| Checklist item | Issue(s) |
|---|---|
| Dashboard/History/Settings responsive at phone width; copy button | #13.1, #14.3, #15.1 |
| Polling 1 s → 5 s backoff, stops on blur, no missed transitions | #14.2 |
| Readable error states (offline, whisper timeout, no inject permission, invalid session) | #14.4, #31.2, #31.3 |
| HTTPS :3000 via mkcert, no trust warning on macOS | #5.3 |

### 12.5 Pilot validation
| Checklist item | Issue(s) |
|---|---|
| Latency benchmark §13 documented (incl. ≤ 4 s / 19 s gate) | #S24 |
| Inject matrix 5 apps with recorded results | #S33 |
| Clipboard restoration under concurrent copy | #28.2 |
| Tests: pytest server (fake whisper binary), pytest inject (mocked macOS), web Playwright smoke (fake sessions), make smoke | #10.4, #25.2/#27.1/#28.2/#29.1, #S23, #S22 (+ inject Playwright #S32) |

### 12.6 Repository
| Checklist item | Issue(s) |
|---|---|
| git init + CI (nx run-many lint/typecheck/test, openapi sync) | #6.1 |
| .gitignore (models, db, certs, fixtures; schema.d.ts policy enforced) | #6.2 |
| License + status badge on README | #6.2 |

## Coverage — §14 roadmap → slices

| Roadmap item | Slice(s) |
|---|---|
| **v0.1** Nx workspace scaffold | #S1–#S4 |
| **v0.1** FastAPI sessions+health, OpenAPI export + client gen | #S9, #S11, #S12 (+ #S3 skeleton) |
| **v0.1** whisper.cpp binary worker + setup script | #S10, #S5 (#5.1) |
| **v0.1** ESP32 firmware: I2S+spool, buttons, display, WiFi+HTTPS retry, provisioning | #S16–#S21 |
| **v0.1** Next.js panel: dashboard/history/settings, responsive | #S13, #S14, #S15 |
| **v0.1** mkcert HTTPS path | #S5 (#5.3) |
| **v0.1** latency logging + make smoke + benchmark pass | #11.4, #S22, #S24 |
| **v0.2** packages/inject (Python + Swift, restoration, Accessibility) | #S25–#S29 |
| **v0.2** mode=inject + /inject route + panel toggle/status/errors | #S30, #S31 |
| **v0.2** error matrices through the OpenAPI client | #30.4, #31.2 |
| **v0.2** inject matrix docs (5 apps) | #S33 |
| **v0.2** Playwright smoke of inject flow | #S32 |
| **v0.3** Save-mode UI (SQLite already wired; history + delete) | #S34, #S35 |
| **v0.3** PWA (manifest + minimal SW), optional | #S36 |
| **v0.3** SSE evaluation | #37.1 |
| **v0.3** Streaming evaluation (sketch + feasibility, not impl) | #37.2 |
| **v0.3** Pilot report: pepper migration + extraction | #S38 |

## Decisions made beyond the spec (to review)

1. **Sessions table lives in v0.1 with additive columns** (`status`, `mode`, `latency_ms`, `error`) on top of the §11 `transcriptions` schema — §7.2's status enum and summary fields require them, but §11 defines only the save-mode columns. Pepper migration stays copy + fill `user_id` + column mapping. Deviation flagged in #8.1.
2. **`DELETE /api/sessions/{id}` added (in #34.2)** — §14 v0.3 "panel history + delete" requires it; §7.2's endpoint table lacks any DELETE. Flagged deviation.
3. **6 epics instead of 4** — firmware split into its own epic (staged hardware bring-up, independent build graph) and a small integration epic (Epic 3) owns the cross-stack gate (smoke + Playwright + §13 benchmark ≤ 4 s).
4. **Device-side DONE latency** — the ESP32 polls `GET /api/sessions/{id}` after a successful upload to display the whisper latency on DONE (§6.4), via child #20.2. Implied by the spec, not spelled out.
5. **Playwright display smoke moved to v0.1** (§12.5 lists it under pilot validation; v1 had it in v0.2) with API mocks instead of a fake whisper-server.
6. **Display/driver + CA-placement open points** (§15 opens 1 and 4) are closed by decision records inside the bring-up slices (#16.1, #19.2) rather than separate docs slices.
7. **`packages/inject` skeleton in v0.2** (#25), not Epic 0 — the workspace runs fine without it and §14 places the package in v0.2. `make setup` carries a reserved compile step from #7.1, activated in #26.2.
8. **Retry-queue semantics kept literally from §6.2** — exp backoff capped at 5 min, max 1 pending session gating Record (#S20).
9. **No v0.4 milestone** — v1's S31 (VAD) is dropped per the pivot; S32/S33 content is folded into #S33 and #S38. Streaming stays an evaluation-only docs decision (#37.2) consistent with §15 open 5.
10. **MIT license assumed** — confirm with the owner in #6.2.





