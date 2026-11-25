# lisa — Issues Plan

> Source: `SPEC.md` (§11 "ready to use" checklist + §12 roadmap). No checkbox from the checklists was left without an issue that fulfills it — item-by-item mapping at the end of the doc (§ Coverage).

## Summary — issue tree

```
Setup & Infra (epic, milestone v0.1)
└── S1 chore: monorepo scaffold (pnpm + turbo + packages)
    ├── 1.1 root: pnpm-workspace + turbo.json + base tsconfig + root scripts
    ├── 1.2 packages/shared: skeleton
    ├── 1.3 packages/audio + packages/inject: skeleton
    └── 1.4 apps/listener + apps/web: running skeletons
└── S2 chore: CI + .gitignore + license
    ├── 2.1 GitHub Actions (typecheck + lint + test on PR)
    └── 2.2 .gitignore + LICENSE + badge
└── S3 chore: config with zod + .env.example
    ├── 3.1 apps/listener config.ts (zod)
    └── 3.2 complete .env.example
└── S4 chore: whisper.cpp scripts (setup + run)
    ├── 4.1 scripts/setup-whisper.sh (whisper.cpp + large-v3-turbo, Metal)
    └── 4.2 scripts/run-whisper.sh (:8081)
└── S5 chore: HTTPS-on-LAN script (Tailscale Serve / mkcert)
    ├── 5.1 Tailscale Serve path
    └── 5.2 mkcert + CA on device path
└── S6 docs: step-by-step setup + READMEs + make setup
    ├── 6.1 READMEs (root + apps)
    ├── 6.2 docs/setup.md (with permission screenshots)
    └── 6.3 Makefile: `make setup` target (one-shot)
—
v0.1 — Basic loop (epic, milestone v0.1)
└── S7  feat(shared): protocol v1 + errors + health contract
    ├── 7.1 protocol.ts (DictateRequest/Response + constants)
    ├── 7.2 errors.ts (typed LisaError)
    └── 7.3 /api/health contract + protocol version
└── S8  feat(audio): WAV encoder + downsample + validation
    ├── 8.1 Float32 → 16k mono downsample
    ├── 8.2 WAV encoder
    ├── 8.3 validate.ts (WAV validation)
    └── 8.4 golden files tests
└── S9  chore(listener): Fastify base + whisper client + /api/health + supervision
    ├── 9.1 Fastify bootstrap (HTTP/HTTPS)
    ├── 9.2 whisper client (POST /inference + ping)
    ├── 9.3 basic GET /api/health
    └── 9.4 whisper-server supervision (spawn with backoff)
└── S10 feat(listener): POST /api/dictate — display mode
    ├── 10.1 multipart route + WAV validation
    ├── 10.2 whisper integration → {ok, mode, text}
    └── 10.3 listener tests (fake whisper)
└── S11 feat(web): PWA scaffold + host settings
    ├── 11.1 app shell (routes + layout)
    ├── 11.2 settings.ts (localStorage: host, default mode)
    └── 11.3 connectivity test (/api/health) on the settings screen
└── S12 feat(web): audio capture (AudioWorklet → WAV)
    ├── 12.1 getUserMedia + recorder.ts
    ├── 12.2 worklet.ts (sample collection)
    ├── 12.3 stop pipeline → downsample → WAV
    └── 12.4 unit tests (audio pipeline)
└── S13 feat(web): Record screen — full display flow
    ├── 13.1 mic button + pulse + timer
    ├── 13.2 api/dictate.ts (binary upload)
    ├── 13.3 transcript preview + status machine
    └── 13.4 last-request log (latency, WAV size)
└── S14 feat(web): installable PWA
    ├── 14.1 manifest + icons
    ├── 14.2 minimal service worker (app shell)
    └── 14.3 "add to home" iOS + Android validation
└── S15 feat(web): robustness — readable errors, secure context, reconnection
    ├── 15.1 error→readable message map
    ├── 15.2 secure context guard (inline instructions)
    ├── 15.3 reconnection: re-tests health + aborts buffer if offline
    └── 15.4 a11y: 48px mic button + landscape
└── S16 chore(listener): pino structured logging
    ├── 16.1 pino setup
    └── 16.2 per-dictate log (latencies, size, mode, success)
└── S17 chore: `make smoke` (real e2e via curl)
    ├── 17.1 test WAV fixtures
    └── 17.2 end-to-end smoke script (display)
└── S18 docs: loop latency benchmark
    ├── 18.1 measurement protocol (3s/10s/20s)
    └── 18.2 docs/benchmark.md with results
—
v0.2 — Inject on desktop (epic, milestone v0.2)
└── S19 feat(inject): clipboard (snapshot + write)
    ├── 19.1 pbcopy/pbpaste wrapper (safe spawn)
    └── 19.2 tests with mocked macOS
└── S20 feat(inject): Cmd+V — native Swift helper (CGEvent)
    ├── 20.1 Swift helper (CGEventPost) + paste.ts
    └── 20.2 `make setup` compiles the helper
└── S21 feat(inject): AppleScript keystroke fallback + strategy flag
    ├── 21.1 char-by-char `keystroke` fallback (osascript)
    ├── 21.2 paste.ts selects the strategy
    └── 21.3 x-lisa-inject-strategy header support in the listener
└── S22 feat(inject): clipboard restoration + copy race
    ├── 22.1 restore after 300–500ms
    └── 22.2 don't restore if a concurrent copy happened (changeCount)
└── S23 feat(inject): Accessibility permission + lisa-inject CLI
    ├── 23.1 detect-permissions.ts (real check + undo)
    ├── 23.2 CLI `lisa-inject "text"` (bin)
    └── 23.3 permission grant instructions
└── S24 feat(listener): INJECT mode end-to-end + health with real check
    ├── 24.1 X-Lisa-Mode: inject flow in /api/dictate
    ├── 24.2 /api/health: inject ok | no_permission | failed
    └── 24.3 inject tests (mocked packages/inject)
└── S25 feat(web): Inject mode in the PWA
    ├── 25.1 3-mode toggle (Inject/Save/Display only)
    ├── 25.2 "text delivered" feedback + latency
    └── 25.3 readable INJECT_* errors + permission guide
└── S26 test: e2e Playwright (display mode with fake whisper)
    ├── 26.1 Playwright setup + fake whisper-server
    ├── 26.2 e2e happy-path display flow
    └── 26.3 e2e error scenarios
└── S27 docs: inject matrix (5 apps)
    ├── 27.1 docs/inject-matrix.md template
    └── 27.2 run + record results in the 5 apps
—
v0.3 — Save mode (epic, milestone v0.3)
└── S28 feat(db): SQLite with schema mirrored from pepper
    ├── 28.1 better-sqlite3 + DB bootstrap
    ├── 28.2 transcriptions schema + derived title
    └── 28.3 db/repository + tests
└── S29 feat(listener): SAVE mode + /api/notes routes
    ├── 29.1 X-Lisa-Mode: save → INSERT + response with id
    ├── 29.2 GET /api/notes (list)
    ├── 29.3 DELETE /api/notes/:id
    └── 29.4 /api/health: DB check
└── S30 feat(web): Save mode in the PWA
    ├── 30.1 wire Save mode + feedback with id
    └── 30.2 readable DB_ERROR error
—
v0.4 — Polish (optional epic, milestone v0.4 — feeds pepper)
└── S31 feat(web): VAD (Silero) in the browser
    ├── 31.1 Silero VAD + automatic stop
    ├── 31.2 feature toggle (default off)
    └── 31.3 evaluation for pepper's v1.x roadmap
└── S32 feat(inject): validated keystroke fallback
    ├── 32.1 fallback unit tests (mocked macOS)
    └── 32.2 fallback cells in the matrix + strategy per app
└── S33 docs: pilot report + packages/inject extraction
    ├── 33.1 docs/pilot-report.md (what migrates to pepper)
    └── 33.2 packages/inject packaged standalone
```

## Recommended milestones

- **v0.1** — S1 to S18 (setup & infra + basic loop). Closure criterion: complete §12 v0.1 checklist + §11.2.
- **v0.2** — S19 to S27 (inject). Criterion: inject matrix filled for the 5 apps + display e2e passing.
- **v0.3** — S28 to S30 (save mode). Criterion: dictating with the Save toggle stores in SQLite and listing via `/api/notes` works.
- **v0.4** — S31 to S33 (optional). Create the milestone only when the pilot is declared successful; until then, keep issues without a milestone (backlog).

## Creation rules

- Create in global numeric order (S1 → S33). Within each slice: create the **parent first**, then the children, with `Part of #<parent number>` in the child's body.
- After creating the children, edit the parent and add the `#n` references in a "Tasks" tasklist.
- Suggested labels by type (`feat`/`chore`/`docs`/`test`) + phase (`fase: v0.1`…) + scope (`web`, `listener`, `shared`, `audio`, `inject`, `db`, `infra`, `ci`). Create the labels once before starting.
- Every slice is 1 PR ≈ up to 300–500 diff lines. A slice never depends on a slice from a later phase.

---

# EPIC 0 — Setup & Infra (milestone v0.1)

---

## #S1 — `chore: monorepo scaffold (pnpm + turborepo + packages)` — creation no. 1

Labels: `chore`, `fase: v0.1`, `infra`
> Phase v0.1 — Basic loop: without the monorepo there is no app↔server types/protocol sharing.

**Context:** the spec (§5) defines pnpm workspaces + Turborepo with `packages/shared`, `packages/audio`, `packages/inject` and `apps/listener` + `apps/web`. This slice raises the whole skeleton compiling, before any feature.

**DoD (parent)**
- [ ] `pnpm install` at the root installs everything (workspaces resolved)
- [ ] `pnpm -r typecheck`, `pnpm -r lint` and `pnpm test` pass (empty projects, but green pipeline)
- [ ] correct dep graph: `apps/*` import from `packages/*`, never the other way around
- [ ] `packages/inject` and `packages/shared` with zero Fastify/Express dependencies

**Children**

### #1.1 — `chore(infra): workspace root — pnpm-workspace, turbo.json, base tsconfig, scripts`
Labels: `chore`, `fase: v0.1`, `infra`
- Body: creates `pnpm-workspace.yaml` (apps/*, packages/*), `turbo.json` with a `build`/`lint`/`typecheck`/`test`/`dev` pipeline, `tsconfig.base.json` (strict, moduleResolution bundler). Root scripts in `package.json`: `dev`, `build`, `lint`, `typecheck`, `test` — all via turbo.
- Acceptance: `turbo run build` runs without error even with empty packages.

### #1.2 — `chore(shared): packages/shared skeleton`
Labels: `chore`, `fase: v0.1`, `shared`
- Body: compilable TS package (`tsup` or tsc build) with `src/protocol.ts`, `src/types.ts`, `src/errors.ts` (placeholder exports) and a `src/index.ts` barrel. `apps/*` must be able to import from `@lisa/shared`.
- Acceptance: `pnpm typecheck` on the workspace resolves the package import without error.

### #1.3 — `chore(audio+inject): packages/audio and packages/inject skeleton`
Labels: `chore`, `fase: v0.1`, `audio`, `inject`
- Body: `packages/audio` (`src/wav.ts`, `src/validate.ts`) and `packages/inject` (`src/clipboard.ts`, `src/paste.ts`, `src/detect-permissions.ts`) as pure TS libs (zero framework deps), `vitest` configured in both. `packages/inject` already with a `bin` field pointing to a placeholder `cli.ts` (real CLI = issue 23.2).
- Acceptance: `pnpm test` runs vitest in both packages (1 smoke test each).

### #1.4 — `chore(apps): apps/listener and apps/web skeletons`
Labels: `chore`, `fase: v0.1`, `listener`, `web`
- Body: `apps/listener`: minimal Fastify with `GET /health` answering `{ok: true}`. `apps/web`: Vite + React 18 + TS scaffold with an empty page. Both import something from `@lisa/shared` to validate the dep graph.
- Acceptance: `pnpm dev` starts listener and web in parallel; `curl localhost:8080/health` answers.

**Dependencies:** none (first issue).

---

## #S2 — `chore: light CI + .gitignore + license` — creation no. 2

Labels: `chore`, `fase: v0.1`, `infra`, `ci`
> Fulfills §11.5 entirely (CI, .gitignore, license + badge) — better to lock the repo early.

**Context:** §11.5 calls for GitHub Actions with typecheck + lint + test on PR, `.gitignore` covering models/db/certs/recordings, and a license with a badge on the README.

**DoD (parent)**
- [ ] CI runs on PR: typecheck + lint + test (§11.5, item 1)
- [ ] `.gitignore` covers models, `*.db`, certs, temporary recordings (§11.5, item 2)
- [ ] LICENSE + status badge on the root README (§11.5, item 3)

**Children**

### #2.1 — `ci: GitHub Actions — typecheck + lint + test on PR`
Labels: `chore`, `fase: v0.1`, `ci`
- Body: `.github/workflows/ci.yml` workflow on PR: installs pnpm (with store cache) and runs `turbo run typecheck lint test`.
- Acceptance: PR with a failing test blocks merge; green PR passes.

### #2.2 — `chore(repo): .gitignore + LICENSE + status badge on README`
Labels: `chore`, `fase: v0.1`, `infra`
- Body: `.gitignore` with models (`.bin`/`.ggml`, `whisper.cpp/`), `*.db`, certs (`*.pem`, `*.p12`, `certs/`), `recordings/`, `node_modules`, `.turbo`, `dist`. LICENSE (MIT, to confirm with the author) + CI badge on the root README.
- Acceptance: clean `git status` after running the whisper setup (no tracked model/DB).

**Dependencies:** #S1 merged (CI needs the workspace).

---

## #S3 — `chore: listener config with zod + .env.example` — creation no. 3

Labels: `chore`, `fase: v0.1`, `listener`
> Fulfills §11.1 — "complete .env.example + config.ts with zod". No secrets: it's a dev tool on a trusted LAN (§10).

**Context:** the listener needs port, whisper model path, DB path and default inject mode — validated at boot, failing readably.

**DoD (parent)**
- [ ] complete `.env.example` (§11.1, item 2)
- [ ] `apps/listener/src/config.ts` with zod, failing at boot with a readable error if the env is invalid
- [ ] no secret in the file (only port, paths, flags)

**Children**

### #3.1 — `feat(listener): config.ts with zod (port, paths, flags)`
Labels: `feat`, `fase: v0.1`, `listener`
- Body: zod schema with `PORT` (default 8080), `WHISPER_URL` (default `http://127.0.0.1:8081`), `WHISPER_MODEL_PATH`, `LISA_DB_PATH` (default `~/Library/Application Support/lisa/lisa.db`), `INJECT_STRATEGY` (default `paste`). Parse at boot; on error it prints the missing fields and exits.
- Acceptance: starting without `WHISPER_MODEL_PATH` fails pointing at the field; complete env starts cleanly.

### #3.2 — `chore: documented .env.example`
Labels: `chore`, `fase: v0.1`, `listener`, `docs`
- Body: `.env.example` with all vars from 3.1, one comment line per var (default and when to change it).
- Acceptance: `cp .env.example .env` + defaults → listener starts with no adjustments beyond the model path.

**Dependencies:** #S1.

---

## #S4 — `chore: whisper.cpp scripts — setup + run (large-v3-turbo, Metal)` — creation no. 4

Labels: `chore`, `fase: v0.1`, `infra`
> Fulfills §12 v0.1 item 2 — "whisper-server running with large-v3-turbo (Metal) — setup script". Feeds `make setup` (§11.1).

**Context:** ASR is the whisper-server (:8081), same model/pipeline as pepper. Reproducible setup on a new machine (§11 criterion: new machine in < 30 min).

**DoD (parent)**
- [ ] `scripts/setup-whisper.sh` downloads/builds whisper.cpp and the `large-v3-turbo` model
- [ ] `scripts/run-whisper.sh` starts the server on :8081 with Metal enabled
- [ ] `POST /inference` with a PT-BR WAV fixture returns a transcript (manual validation recorded in the PR)

**Children**

### #4.1 — `chore(scripts): setup-whisper.sh — clone/build whisper.cpp + download large-v3-turbo`
Labels: `chore`, `fase: v0.1`, `infra`
- Body: idempotent shell script: clones whisper.cpp, builds with Metal, downloads the `large-v3-turbo` model to a configurable path — skipping steps already done.
- Acceptance: running twice in a row doesn't redo download/build.

### #4.2 — `chore(scripts): run-whisper.sh — server :8081 with Metal`
Labels: `chore`, `fase: v0.1`, `infra`
- Body: script that starts the `whisper-server` on :8081 loading `large-v3-turbo` with Metal (Metal build flags), logging the model load.
- Acceptance: `POST /inference` with a PT-BR test WAV returns text in < 5s for a ~10s sentence.

**Dependencies:** none (standalone scripts); create after #S3 to follow the .env path conventions.

---

## #S5 — `chore: HTTPS-on-LAN script (Tailscale Serve or mkcert)` — creation no. 5

Labels: `chore`, `fase: v0.1`, `infra`, `web`
> Fulfills §12 v0.1 item 5 — "HTTPS via Tailscale Serve or mkcert (§7.4)". getUserMedia requires a secure context; HTTPS also encrypts the audio (§10).

**Context:** §7.4 defines the two options, automated in `scripts/setup-https.sh`. The decision between them stays open until it runs on the real machine (§13).

**DoD (parent)**
- [ ] `scripts/setup-https.sh` supports both paths
- [ ] PWA reachable from the device over HTTPS with no cert warning (on the chosen path)
- [ ] `window.isSecureContext === true` on the device

**Children**

### #5.1 — `chore(scripts): Tailscale Serve path in setup-https.sh`
Labels: `chore`, `fase: v0.1`, `infra`
- Body: if `tailscale` is installed, the script configures `tailscale serve https / https://localhost:8080` and prints the tailnet URL.
- Acceptance: the tailnet URL loads the app on the phone as a secure context.

### #5.2 — `chore(scripts): mkcert + CA on device path`
Labels: `chore`, `fase: v0.1`, `infra`
- Body: mkcert fallback: generates a localhost cert, configures the listener for HTTPS, exports `rootCA.pem` with printed installation instructions for iOS (profile + trust) and Android.
- Acceptance: with the CA installed on the tablet, the app loads with no warning.

**Dependencies:** #S1 (repo), #S3 (listener port). Close it after updating §13 (Tailscale vs mkcert) following the real test.

---

## #S6 — `docs: step-by-step setup + READMEs + one-shot make setup` — creation no. 6

Labels: `docs`, `fase: v0.1`, `infra`
> Fulfills §11.1 — root + per-app READMEs, `docs/setup.md` with permission screenshots, and the `make setup` that ties everything together.

**Context:** the pilot criterion is a new machine + tablet from zero in < 30 min, with no undocumented steps. This slice closes the setup as a new-machine experience.

**DoD (parent)**
- [ ] root + per-app READMEs (§11.1, item 4)
- [ ] `docs/setup.md` step-by-step with permission screenshots (Accessibility, mic on iOS/Android) (§11.1, item 4)
- [ ] `make setup` runs deps + Swift helper + whisper + https (§11.1, item 1)
- [ ] `make dev/build/lint/typecheck/test` targets work (§11.1, item 3)

**Children**

### #6.1 — `docs: READMEs (root + apps/listener + apps/web + packages/inject)`
Labels: `docs`, `fase: v0.1`
- Body: root README (5-line overview, §4 topology, commands). Per-app READMEs: purpose, env vars, how to run standalone. `packages/inject` with a "this package migrates to pepper" section (§2).
- Acceptance: a new person understands the project and how to run it from the READMEs alone.

### #6.2 — `docs: docs/setup.md with permission screenshots`
Labels: `docs`, `fase: v0.1`
- Body: new-machine step-by-step: prereqs (Node, pnpm, Xcode CLT), `make setup`, granting Accessibility (System Settings → Privacy → Accessibility) with screenshot, mic permission on iOS/Android with screenshot, mkcert CA installation on the tablet if applicable.
- Acceptance: complete setup on a virgin machine following only the doc.

### #6.3 — `chore(make): one-shot make setup target + base targets`
Labels: `chore`, `fase: v0.1`, `infra`
- Body: Makefile with `setup` orchestrating: `pnpm install`, compilation of the Swift inject helper (reserved step — actually activated in issue 20.2), `scripts/setup-whisper.sh` and `scripts/setup-https.sh`. Targets `dev`, `build`, `lint`, `typecheck`, `test`.
- Acceptance: `make setup` runs end-to-end on a new machine without error; the other targets work.

**Dependencies:** #S1, #S4, #S5 merged.

---

# EPIC 1 — v0.1: Basic loop (milestone v0.1)

---

## #S7 — `feat(shared): protocol v1 + typed errors + health contract` — creation no. 7

Labels: `feat`, `fase: v0.1`, `shared`
> Phase v0.1 — the app↔server contract lives ONLY here (§5): no duplicated types in app or listener.

**Context:** §6 defines `POST /api/dictate` (multipart WAV + `X-Lisa-Mode`), the `DictateResponse`, `LisaError` errors and versioning via `/api/health`. Implementing in `packages/shared` first locks the contract.

**DoD (parent)**
- [ ] `protocol.ts` with the dictate request/response exactly as §6 (inject/save variants included — fields used starting in v0.2/v0.3)
- [ ] `errors.ts` with the 5 codes: `WAV_INVALID`, `WHISPER_DOWN`, `INJECT_NO_PERMISSION`, `INJECT_FAILED`, `DB_ERROR`
- [ ] constant `LISA_PROTOCOL_VERSION` (int, starts at 1) + `/api/health` body type
- [ ] zod schemas to validate request and response on both sides

**Children**

### #7.1 — `feat(shared): protocol.ts — POST /api/dictate types + headers`
Labels: `feat`, `fase: v0.1`, `shared`
- Body: `DictateResponse` types (display/inject/save variants + error) and header constants (`X-Lisa-Mode`, `Z-Lisa-Client`, `x-lisa-inject-strategy`).
- Zod schemas of the payloads, parse on both sides.
- Acceptance: shared typecheck passes; types cover the 3 phases of §1.

### #7.2 — `feat(shared): errors.ts — LisaError with typed codes`
Labels: `feat`, `fase: v0.1`, `shared`
- Body: `LisaError = { code, message?, detail? }`, a `LisaErrorCode` union with the 5 codes and a `toLisaError(code, detail)` helper.
- Acceptance: listener and web import the same codes — no error code literals outside shared.

### #7.3 — `feat(shared): /api/health contract + protocol version`
Labels: `feat`, `fase: v0.1`, `shared`
- Body: `HealthResponse { protocol, whisper: { up, model }, inject, db, version }` + constant `LISA_PROTOCOL_VERSION = 1`. Fields `inject`/`db` null until their phases.
- Acceptance: a zod schema validates a sample health JSON of each phase.

**Dependencies:** #S1 (shared skeleton, 1.2).

---

## #S8 — `feat(audio): audio package — downsample + WAV encoder + validation` — creation no. 8

Labels: `feat`, `fase: v0.1`, `audio`
> Phase v0.1 — PCM 16kHz mono WAV (§3) is the pipeline format; used by web, validated by the listener.

**Context:** §5/§7.1: Float32 capture → downsample 48k→16k mono → WAV encode. Pure lib, running on both sides.

**DoD (parent)**
- [ ] `packages/audio/src/wav.ts` generates valid 16k mono WAV from Float32 (basis of §12 v0.1 item 4)
- [ ] `packages/audio/src/validate.ts` rejects invalid WAV (wrong rate, truncated header, channels > 1)
- [ ] golden files tests: generated WAV matches the fixture byte-for-byte (§11.4, item 4)

**Children**

### #8.1 — `feat(audio): Float32 downsample (48k/44.1k) → 16k mono`
Labels: `feat`, `fase: v0.1`, `audio`
- Body: pure fn `downsampleTo16k(input: Float32Array, inputRate: number): Float32Array` (average of samples per bucket). Handles 48000, 44100 and 16000 (no-op).
- Acceptance: unit test 48000→16000 with a sine wave preserves frequency (consistent zero-crossings).

### #8.2 — `feat(audio): WAV encoder (PCM 16-bit, mono) in wav.ts`
Labels: `feat`, `fase: v0.1`, `audio`
- Body: `encodeWav(samples: Float32Array, sampleRate = 16000): ArrayBuffer` — RIFF/WAVE header + PCM 16-bit LE mono.
- Acceptance: output recognized by `afinfo` as PCM 16k mono WAV.

### #8.3 — `feat(audio): validate.ts — validation of the received WAV`
Labels: `feat`, `fase: v0.1`, `audio`
- Body: `validateWav(buffer): { ok: true, sampleRate, durationSec } | { ok: false, reason }` — RIFF magic, PCM, sample rate 16k, max sanable duration. Runs in Node (listener) and browser.
- Acceptance: tests pass in both environments.

### #8.4 — `test(audio): encoder golden files`
Labels: `test`, `fase: v0.1`, `audio`
- Body: committed `.wav` fixtures (1s of sine / silence / noise) + tests comparing the generated byte stream against the fixture (§11.4, item 4).
- Acceptance: `pnpm test` in `packages/audio` covers encoder + validate + downsample; CI enforces it.

**Dependencies:** #S1 (skeleton, 1.3).

---

## #S9 — `chore(listener): Fastify base + whisper client + /api/health + supervision` — creation no. 9

Labels: `feat`, `chore`, `fase: v0.1`, `listener`
> Phase v0.1 — "lisa-listener: /api/dictate + /api/health → whisper → {text}" (§12 v0.1, item 3). Health = half of §11.2 item 1.

**Context:** foundation of the listener: server :8080 (HTTP/HTTPS), client for the whisper-server :8081, health with real ping and supervision with restart (§11.2, item 4).

**DoD (parent)**
- [ ] `GET /api/health` with `protocol`, `whisper.up`, `whisper.model` — minimal version of §11.2 item 1 (inject and db join in their phases)
- [ ] whisper client (`apps/listener/src/whisper/client.ts`) with `POST /inference` + ping and timeouts
- [ ] listener restarts the whisper-server if the ping fails, spawn with backoff (§11.2, item 4)
- [ ] server starts on HTTP and, with certs present (§S5), on HTTPS

**Children**

### #9.1 — `feat(listener): Fastify bootstrap (port, multipart, optional https)`
Labels: `feat`, `fase: v0.1`, `listener`
- Body: `buildServer()` factory: multipart plugin (@fastify/multipart), routes per module (`routes/`), native pino logging. HTTPS if `LISA_CERT`/`LISA_KEY` are set (mkcert path of #S5).
- Acceptance: starts with and without certs; unknown route → JSON 404.

### #9.2 — `feat(listener): whisper client — POST /inference + ping`
Labels: `feat`, `fase: v0.1`, `listener`
- Body: `apps/listener/src/whisper/client.ts`: `transcribe(wav: Buffer)` (multipart to :8081) and `ping()` with short timeout. Configurable timeout; connection failure → `WHISPER_DOWN`.
- Acceptance: against the real whisper (#S4) it transcribes the fixture; against a dead port → `WHISPER_DOWN`.

### #9.3 — `feat(listener): GET /api/health — whisper ping + protocol version`
Labels: `feat`, `fase: v0.1`, `listener`
- Body: `routes/health.ts` returning the shared `HealthResponse`: `protocol`, `whisper: { up, model }` (reading `WHISPER_MODEL_PATH`), `inject: null`, `db: null`, `version`. Ping with a short cache (not pinging on every request).
- Acceptance: whisper up → `up: true` + model path; whisper down → `up: false` without bringing the health down.

### #9.4 — `feat(listener): whisper-server supervision (spawn + backoff)`
Labels: `feat`, `fase: v0.1`, `listener`
- Body: module that, with the ping failing N times, `spawn`s `scripts/run-whisper.sh` with exponential backoff (cap 60s), logging each attempt. Env flag to disable.
- Acceptance: killing whisper manually → listener restarts within ≤ 2 min and health returns to `up: true` (§11.2, item 4).

**Dependencies:** #S1, #S3, #S7 (health contract).

---

## #S10 — `feat(listener): POST /api/dictate — display mode end-to-end` — creation no. 10

Labels: `feat`, `fase: v0.1`, `listener`
> Phase v0.1 — core of the loop: WAV → whisper → `{text}` displayable in the app.

**Context:** §6: multipart `{audio: WAV}` + `X-Lisa-Mode: display` → validate WAV, call whisper, answer `{ok: true, mode: 'display', text}`. Errors: `WAV_INVALID` and `WHISPER_DOWN`.

**DoD (parent)**
- [ ] `POST /api/dictate` with valid WAV + `X-Lisa-Mode: display` → `{ok: true, mode: 'display', text}` (§12 v0.1, item 3)
- [ ] invalid WAV → `{ok: false, error: {code: 'WAV_INVALID'}}`; whisper down → `WHISPER_DOWN`
- [ ] mode not yet supported (inject/save) → typed error from shared, no crash
- [ ] unit tests with fake whisper covering happy path + 2 errors

**Children**

### #10.1 — `feat(listener): dictate route — multipart + WAV validation`
Labels: `feat`, `fase: v0.1`, `listener`
- Body: `routes/dictate.ts`: extracts buffer + `X-Lisa-Mode` + `Z-Lisa-Client`, validates with `validateWav` from packages/audio. Invalid WAV → `WAV_INVALID` with detail.
- Acceptance: curl with a valid WAV moves forward on; renamed PNG → `WAV_INVALID`.

### #10.2 — `feat(listener): dictate display — integration with the whisper client`
Labels: `feat`, `fase: v0.1`, `listener`
- Body: in `display` mode, calls `transcribe()` and answers the shared display variant. `WHISPER_DOWN` from the client; latency measurements prepared for #S16.
- Acceptance: dictate via curl (fixture) with the real server returns coherent PT-BR text.

### #10.3 — `test(listener): vitest suite with fake whisper-server`
Labels: `test`, `fase: v0.1`, `listener`
- Body: fake whisper in `tests/listener/` + tests: happy path, `WAV_INVALID`, `WHISPER_DOWN`, unknown mode.
- Acceptance: covers all response branches; runs in CI without a real whisper.

**Dependencies:** #S7, #S8, #S9.

---

## #S11 — `feat(web): PWA scaffold in the monorepo + host settings` — creation no. 11

Labels: `feat`, `fase: v0.1`, `web`
> Phase v0.1 — before recording, the app must know where the listener is (§7.2, Settings screen).

**Context:** the PWA keeps the host address in localStorage (§7.1) and tests connectivity with `/api/health`. No login, no sign-up.

**DoD (parent)**
- [ ] `apps/web` integrated into turbo (`dev` in parallel with the listener) — basis of §12 v0.1 item 4
- [ ] settings persists host address + default mode in localStorage (§7.1)
- [ ] connectivity test calls `/api/health` and shows status (§7.2, screen 2)

**Children**

### #11.1 — `feat(web): app shell — routes + base layout`
Labels: `feat`, `fase: v0.1`, `web`
- Body: minimal routes (Record + Settings sheet), mobile-first layout (viewport, safe-areas), base fetch client resolved from the configured host.
- Acceptance: app renders in mobile Safari with the correct viewport, no unwanted zoom.

### #11.2 — `feat(web): settings.ts — host + default mode in localStorage`
Labels: `feat`, `fase: v0.1`, `web`
- Body: read/write of `hostUrl` and `defaultMode` in localStorage, with URL validation (`http(s)://`).
- Acceptance: reload preserves values; invalid URL rejected with a message.

### #11.3 — `feat(web): Settings screen — host field + connectivity test`
Labels: `feat`, `fase: v0.1`, `web`
- Body: host field + "test" button calling `/api/health` (shared types) — shows status, model and `protocol`. Divergence of `health.protocol` vs `LISA_PROTOCOL_VERSION` → "update the listener" banner (§6).
- Acceptance: correct host shows green + model; wrong host shows red with a hint; protocol divergence shows the banner.

**Dependencies:** #S1 (skeleton, 1.4), #S7.

---

## #S12 — `feat(web): audio capture — AudioWorklet + downsample + WAV` — creation no. 12

Labels: `feat`, `fase: v0.1`, `web`, `audio`
> Phase v0.1 — heart of the client: mic → Float32 → 16k mono → WAV (§3, §7.1). AudioWorklet, not ScriptProcessor (deprecated).

**Context:** `getUserMedia` + AudioWorklet collect Float32; downsample and encode use `packages/audio`; the generated WAV is what goes up in the dictate.

**DoD (parent)**
- [ ] record and stop generates a decodable 16k mono WAV `ArrayBuffer` (§12 v0.1, item 4)
- [ ] capture via AudioWorkletNode (§7.1 — no ScriptProcessor)
- [ ] unit tests of the numeric path pass without a real device

**Children**

### #12.1 — `feat(web): recorder.ts — getUserMedia + record/stop cycle`
Labels: `feat`, `fase: v0.1`, `web`
- Body: `recorder.ts`: asks for the mic, creates AudioContext + AudioWorkletNode loading `worklet.ts`, accumulates Float32 chunks, exposes `start()` / `stop(): Promise<Float32Array>`. Mic denied → local typed error.
- Acceptance: recording 3s on Safari iOS returns a Float32Array with the correct duration.

### #12.2 — `feat(web): worklet.ts — sample collection in the AudioWorklet`
Labels: `feat`, `fase: v0.1`, `web`, `audio`
- Body: worklet in `src/audio/worklet.ts` posting Float32 blocks to the main thread (transferable), no per-process allocation.
- Acceptance: 30s recording with no audible glitch; device disconnect cleans up without hanging.

### #12.3 — `feat(web): stop pipeline → downsample → WAV (via packages/audio)`
Labels: `feat`, `fase: v0.1`, `web`, `audio`
- Body: web wrapper: accumulated Float32 → `downsampleTo16k` → `encodeWav` from the package. Also exposes the byte size (audio_size) for telemetry.
- Acceptance: generated WAV passes `validateWav` from the same package (roundtrip).

### #12.4 — `test(web): audio pipeline unit tests`
Labels: `test`, `fase: v0.1`, `web`, `audio`
- Body: covers chunk → merge → downsample → encode with mocked AudioContext (or testing the pure path in packages).
- Acceptance: runs in CI without a real device.

**Dependencies:** #S8, #S11.

---

## #S13 — `feat(web): Record screen — complete display flow` — creation no. 13

Labels: `feat`, `fase: v0.1`, `web`
> Phase v0.1 — closes the visible loop: speak → transcript appears in the app (§1, v0.1).

**Context:** §7.2 screen 1: big button, recording indication, transcript preview, round-trip status and last-request log (latency, WAV size).

**DoD (parent)**
- [ ] complete flow: record → stop → upload → transcript displayed (§12 v0.1, item 4)
- [ ] visible status: recording → uploading → transcribing → delivered/error (§7.2)
- [ ] last-request log shows latency and WAV size (§7.2 — pilot telemetry)
- [ ] mode toggle visible, with "Display only" functional (Inject/Save disabled with a "v0.2/v0.3" hint)

**Children**

### #13.1 — `feat(web): mic button + pulse + recording timer`
Labels: `feat`, `fase: v0.1`, `web`
- Body: big central button, idle/recording states, pulsing ring, `mm:ss` timer. Touch area ≥ 48px (§11.3, item 4), stable layout in landscape.
- Acceptance: visually distinct states; record↔stop transition without heavy re-render.

### #13.2 — `feat(web): api/dictate.ts — binary WAV upload`
Labels: `feat`, `fase: v0.1`, `web`
- Body: fetch client: multipart with the WAV blob (Content-Type `audio/wav`), headers `X-Lisa-Mode` and `Z-Lisa-Client: web/1.0`; parse of the `DictateResponse` with the shared schema. Measures the request duration (latency).
- Acceptance: ok and error responses typed; network timeout becomes a handleable error.

### #13.3 — `feat(web): transcript preview + status machine`
Labels: `feat`, `fase: v0.1`, `web`
- Body: state machine `idle → recording → uploading → transcribing → done | error` reflected in the UI; transcript in preview with a large font.
- Acceptance: each transition visible; error renders the message from issue 15.1.

### #13.4 — `feat(web): last-request log (latency + WAV size)`
Labels: `feat`, `fase: v0.1`, `web`
- Body: discreet post-request card: total latency (ms), WAV size (KB), mode — data that feeds the benchmark (#S18).
- Acceptance: values match the listener's server-side log for the same request.

**Dependencies:** #S10, #S12.

---

## #S14 — `feat(web): installable PWA (manifest + icons + service worker)` — creation no. 14

Labels: `feat`, `fase: v0.1`, `web`
> Fulfills §11.3 item 1 — "installable PWA, tested add to home on iOS and Android".

**Context:** §7.1: `manifest.webmanifest` (icons, standalone, free orientation) + minimal app shell SW. Recording doesn't work offline anyway (accepted in the spec).

**DoD (parent)**
- [ ] icon on the home screen, opening standalone (§11.3, item 1)
- [ ] manifest with `display: standalone`, free orientation, 192/512 + maskable icons
- [ ] SW caches the app shell; `/api/*` never cached

**Children**

### #14.1 — `feat(web): manifest.webmanifest + icons`
Labels: `feat`, `fase: v0.1`, `web`
- Body: manifest (lisa name, standalone, `any` orientation, theme/color, 192/512 + maskable icons) and generated icons.
- Acceptance: DevTools/lighthouse point to a valid, installable manifest.

### #14.2 — `feat(web): minimal service worker (app shell cache)`
Labels: `feat`, `fase: v0.1`, `web`
- Body: `public/sw.js`: cache-first for shell (index/assets), network-only for `/api/*`; version bump on deploy. Offline with shell served → clear message that the API doesn't respond.
- Acceptance: offline reload after 1 visit loads the shell; API calls are never cached.

### #14.3 — `docs: iOS + Android installation validation`
Labels: `docs`, `fase: v0.1`, `web`
- Body: section in docs/setup.md with the steps and screenshots of "Add to Home Screen" on iOS and Android, and the standalone check (§11.3, item 1).
- Acceptance: installed and tested on iOS Safari and Android Chrome, screenshots attached in the PR.

**Dependencies:** #S11.

---

## #S15 — `feat(web): client robustness — readable errors, secure context, reconnection` — creation no. 15

Labels: `feat`, `fase: v0.1`, `web`
> Fulfills §11.2 item 2 (readable errors) and §11.3 items 2–4 (inline secure context, reconnection, a11y).

**Context:** for real handheld use: plain HTTP blocks the mic — the app needs to instruct the setup (§7.4); an offline host needs re-test and clean abort; protocol errors become human sentences.

**DoD (parent)**
- [ ] errors handled with readable messages: whisper down, invalid WAV, unreachable host (timeout) — inject without permission joins in v0.2 (§11.2, item 2)
- [ ] screen instructs setup when `!window.isSecureContext && origin is not localhost` (§11.3, item 2 / §7.4)
- [ ] button re-tests `/api/health` when offline; recording aborts with a message instead of accumulating buffer (§11.3, item 3)
- [ ] mic button with a minimum 48px area, works in landscape (§11.3, item 4)

**Children**

### #15.1 — `feat(web): LisaErrorCode → readable message map`
Labels: `feat`, `fase: v0.1`, `web`
- Body: helper converting a `LisaError` (shared) into a UI message + suggested action (e.g. `WHISPER_DOWN` → "whisper-server didn't respond; check the health"). Network/timeout error → "host unreachable".
- Acceptance: every shared code has its own message rendered in the error preview.

### #15.2 — `feat(web): secure context guard with setup instructions`
Labels: `feat`, `fase: v0.1`, `web`
- Body: on the Record screen, if `!isSecureContext && origin is not localhost`: block the mic and show a card with the two options (Tailscale Serve / mkcert), pointing to docs/setup.md.
- Acceptance: opened over HTTP on a LAN IP → recording blocked with instructions; on HTTPS/localhost → normal flow.

### #15.3 — `feat(web): reconnection — health re-test + offline buffer abort`
Labels: `feat`, `fase: v0.1`, `web`
- Body: health failing (or dictate failing due to network) → "host offline" banner + re-test button. A new mic touch with the host offline discards the buffer with a message, doesn't accumulate (§11.3, item 3).
- Acceptance: kill the listener mid-use → banner with re-test; listener comes back → re-test green and the flow resumes.

### #15.4 — `feat(web): a11y — touch targets and landscape`
Labels: `feat`, `fase: v0.1`, `web`
- Body: 48px minimum area on the mic and controls, functional layout in portrait and landscape (§11.3, item 4), contrast of the states.
- Acceptance: manual test on both target devices with screenshots in the PR.

**Dependencies:** #S13.

---

## #S16 — `chore(listener): structured logging with pino` — creation no. 16

Labels: `chore`, `fase: v0.1`, `listener`
> Fulfills §12 v0.1 item 6 (latency logging) and §11.2 item 3.

**Context:** §11.2 item 3: each dictate logs total latency + whisper latency + inject latency + WAV size + mode + success/failure. (inject stays `null` until v0.2.)

**DoD (parent)**
- [ ] each dictate logs one structured line with the fields of §11.2 item 3 (§12 v0.1, item 6)
- [ ] pino logs with request-id; health logs slow pings (> 1s)

**Children**

### #16.1 — `chore(listener): pino setup (level, transport, request-id)`
Labels: `chore`, `fase: v0.1`, `listener`
- Body: pino configured (level via env, pretty in dev), request-id per request propagated between hooks and routes.
- Acceptance: readable JSON logs in the dev terminal.

### #16.2 — `feat(listener): dictate log — latencies + size + mode + success`
Labels: `feat`, `fase: v0.1`, `listener`
- Body: per dictate request: total latency, whisper latency, `inject: null` (reserved field), audio_size, mode, ok/error with code.
- Acceptance: 1 request = 1 line with all fields (or documented null).

**Dependencies:** #S9, #S10.

---

## #S17 — `chore: make smoke — real end-to-end test via curl` — creation no. 17

Labels: `chore`, `test`, `fase: v0.1`, `listener`
> Fulfills §12 v0.1 item 6 ("make smoke") and §11.4 item 4 (real e2e smoke script with a WAV fixture via curl).

**Context:** unlike the unit tests: starts with a real whisper and validates the entire server-side loop with a WAV fixture, in a single command.

**DoD (parent)**
- [ ] `make smoke` runs the real cycle: listener + whisper + `POST /api/dictate` with fixture → valid transcript JSON (§11.4, item 4)
- [ ] exit code ≠ 0 on any failing step (server doesn't start, response without `text`, protocol error)

**Children**

### #17.1 — `chore(tests): committed WAV fixtures of speech (3s/10s)`
Labels: `chore`, `fase: v0.1`, `test`, `audio`
- Body: 2 PT-BR WAV fixtures (≈3s and ≈10s) in `tests/fixtures/`, 16k mono, generated by the same pipeline as the app.
- Acceptance: fixtures pass `validateWav` and get transcribed by whisper to approximately the expected text.

### #17.2 — `chore(make): make smoke script (spawn + curl + assertions)`
Labels: `chore`, `fase: v0.1`, `test`
- Body: `scripts/smoke.sh` + `make smoke` target: starts the listener (and whisper, if it isn't up), waits for health, sends the fixture with `X-Lisa-Mode: display`, asserts the response and tears down the processes.
- Acceptance: `make smoke` green with the real stack; clear failure if the whisper doesn't come up.

**Dependencies:** #S9, #S10, #S4.

---

## #S18 — `docs: latency benchmark of the basic loop` — creation no. 18

Labels: `docs`, `fase: v0.1`
> Fulfills §11.4 item 1 — documented benchmark: speech→text on screen, sentences of 3s/10s/20s, target < 2s on stop (~15s sentence).

**Context:** the pilot exists to measure. Sources of the numbers: last-request log (#13.4) + pino logs (#S16).

**DoD (parent)**
- [ ] latency recorded for sentences of 3s/10s/20s, with breakdown (network + whisper) (§11.4, item 1)
- [ ] `docs/benchmark.md` with method (n runs, device, network) and results — declared target: < 2s on stop for a ~15s sentence
- [ ] a result outside the target documented as a gap, not hidden

**Children**

### #18.1 — `docs: latency measurement protocol`
Labels: `docs`, `fase: v0.1`
- Body: method: device, network (same LAN/Wi-Fi), test sentences, number of repetitions, which last-request log/pino fields to use.
- Acceptance: anyone reproduces the measurement by reading only the doc.

### #18.2 — `docs: docs/benchmark.md with v0.1 loop results`
Labels: `docs`, `fase: v0.1`
- Body: results table (3s/10s/20s × n runs), comparison against the < 2s target, notes (model, Metal, network).
- Acceptance: results taken from the real log (not estimated), PR with a link to the runs.

**Dependencies:** #S13, #S16 merged (telemetry in the app and in the logs).

---

# EPIC 2 — v0.2: Inject on desktop (milestone v0.2)

---

## #S19 — `feat(inject): clipboard — snapshot and write in packages/inject` — creation no. 19

Labels: `feat`, `fase: v0.2`, `inject`
> Phase v0.2 — "packages/inject: clipboard + paste + restoration + Accessibility permission" (§12 v0.2, item 1). Pure lib, no Fastify (§5).

**Context:** steps 1 and 2 of §8: read the current clipboard (with timestamp) and write the transcript (`pbcopy` via spawn). Sanitization by construction: only text goes to the clipboard, no shell execution (§10).

**DoD (parent)**
- [ ] `packages/inject/src/clipboard.ts`: `getClipboard(): { text, changeCount }` and `setClipboard(text)` via pbcopy/pbpaste (spawn)
- [ ] content never interpolated into a shell string (spawn with an arg array — §10)
- [ ] unit tests with mocked macOS (§11.4, item 4)

**Children**

### #19.1 — `feat(inject): clipboard.ts — get/set via pbcopy/pbpaste (safe spawn)`
Labels: `feat`, `fase: v0.2`, `inject`
- Body: `getClipboard()` (text + changeCount) and `setClipboard(text)` with `spawn('pbcopy', [])` + stdin — never a string interpolated into a shell. Process errors mapped to package errors.
- Acceptance: set→get roundtrip preserves accents/emoji; sanitization test covers a string with `"; rm -rf` without side effects.

### #19.2 — `test(inject): vitest suite with mocked macOS`
Labels: `test`, `fase: v0.2`, `inject`
- Body: mock of `child_process`/osascript with deterministic responses; tests for clipboard, spawn errors and timeouts (§11.4, item 4).
- Acceptance: `pnpm test` covers the package without real macOS (CI runs on Linux).

**Dependencies:** #S1 (skeleton, 1.3).

---

## #S20 — `feat(inject): Cmd+V — native Swift helper (CGEventPost)` — creation no. 20

Labels: `feat`, `fase: v0.2`, `inject`
> Phase v0.2 — step 3 of §8: simulated Cmd+V; 1st preference is the Swift helper compiled at setup.

**Context:** §8: Cmd+V via a Swift helper (`CGEventPost`), compiled in `make setup`; AppleScript stays as fallback (issue #S21).

**DoD (parent)**
- [ ] `packages/inject/src/paste.ts` fires Cmd+V via the Swift helper compiled at setup
- [ ] helper compiles in `make setup` — clear error if Xcode CLT or Accessibility is missing
- [ ] Cmd+V reaching the focused app, validated manually (Safari + VS Code)

**Children**

### #20.1 — `feat(inject): Swift helper (CGEventPost) + paste.ts`
Labels: `feat`, `fase: v0.2`, `inject`
- Body: minimal Swift source (`sendCmdV`) using CGEventPost for keyDown/keyUp of V with the Command flag; `paste.ts` invokes the compiled binary at a stable path.
- Acceptance: with Accessibility granted to the calling process, Cmd+V pastes into the focused app (manual test documented in the PR).

### #20.2 — `chore(make): Swift helper compilation in make setup`
Labels: `chore`, `fase: v0.2`, `inject`, `infra`
- Body: activates the reserved step in 6.3: compiles the Swift helper → binary at the package path; fails with instructions if the toolchain is missing.
- Acceptance: `make setup` on a new machine produces the binary; without the binary, paste.ts fails with a typed error (not a crash).

**Dependencies:** #S19, #S6 (make setup target).

---

## #S21 — `feat(inject): AppleScript keystroke fallback + strategy flag` — creation no. 21

Labels: `feat`, `fase: v0.2`, `inject`, `listener`
> Phase v0.2 — §3/§8: char-by-char `keystroke` fallback for fields that ignore paste, selectable per request (`x-lisa-inject-strategy`).

**Context:** §8 expects the fallback per flag in the request. The implementation lands here; the extensive validation ("tested") is the v0.4 checkbox (#S32).

**DoD (parent)**
- [ ] `packages/inject` supports the `type` (AppleScript keystroke, char by char) and `paste` (helper/Cmd+V) strategies
- [ ] listener honors the `x-lisa-inject-strategy: paste | type` header
- [ ] `type` validated manually in 1 app that blocks paste

**Children**

### #21.1 — `feat(inject): type fallback — osascript keystroke char by char`
Labels: `feat`, `fase: v0.2`, `inject`
- Body: `typeText(text)`: osascript `System Events` `keystroke` per character (sanitization for special chars), size limit and progress logging.
- Acceptance: types accented text into Notes; text above the limit aborts with an error (avoids uncontrolled typing).

### #21.2 — `feat(inject): paste.ts selects the strategy (paste | type)`
Labels: `feat`, `fase: v0.2`, `inject`
- Body: unified `injectText(text, strategy)`: `paste` → clipboard + Cmd+V (restore closes in #S22), `type` → 21.1.
- Acceptance: same signature for both strategies; switch covered by a mocked test.

### #21.3 — `feat(listener): x-lisa-inject-strategy header in the dictate route`
Labels: `feat`, `fase: v0.2`, `listener`
- Body: parse of the header (default from config `INJECT_STRATEGY`), passed along to the inject; unknown value → shared error.
- Acceptance: curl with `x-lisa-inject-strategy: type` uses typing; no header uses the default.

**Dependencies:** #S20 (paste base), #S7 (protocol headers).

---

## #S22 — `feat(inject): clipboard restoration + concurrent copy race` — creation no. 22

Labels: `feat`, `fase: v0.2`, `inject`
> Fulfills §8 step 4 and §11.4 item 3 — "clipboard restoration works under concurrent user copy".

**Context:** §8: 300–500ms delay after the Cmd+V → restores the previous clipboard, unless the user copied something new in that interval (detection via changeCount).

**DoD (parent)**
- [ ] after the inject, clipboard restored to the previous content (§12 v0.2, item 1 — restoration)
- [ ] clipboard changed during the delay (user copy) → restore does NOT run (§11.4, item 3)
- [ ] automated test of the concurrent copy scenario (mocked changeCount)

**Children**

### #22.1 — `feat(inject): restoreClipboard — snapshot → delay → restore`
Labels: `feat`, `fase: v0.2`, `inject`
- Body: in the `injectText` paste flow: captures snapshot + changeCount before; restores after a configurable delay (300–500ms, §8); timer cleaned on abort.
- Acceptance: manual — copy something before dictating, dictate, clipboard returns to the previous content (§11.4, item 3).

### #22.2 — `feat(inject): concurrent copy race (changeCount guard)`
Labels: `feat`, `fase: v0.2`, `inject`
- Body: before restoring, re-read changeCount: changed since the snapshot → user copied → skip the restore, with a log. Mocked test of both outcomes (§11.4, item 3).
- Acceptance: simulating a copy during the delay preserves the user's new content; unit test passes.

**Dependencies:** #S19, #S20.

---

## #S23 — `feat(inject): Accessibility permission + lisa-inject CLI` — creation no. 23

Labels: `feat`, `fase: v0.2`, `inject`
> Fulfills §12 v0.2 item 1 (permission part) and §5 — CLI `lisa-inject "text"`: the package that migrates to pepper.

**Context:** §8: Accessibility for the listener process; the check with a real test (inject of 1 character + undo) will feed `/api/health` (#S24).

**DoD (parent)**
- [ ] `packages/inject/src/detect-permissions.ts`: real Accessibility check with result `ok | no_permission | failed`
- [ ] CLI `lisa-inject "text"` works standalone (without the listener) — bin linked
- [ ] no Fastify/Express imports in `packages/inject` (§5 rule)

**Children**

### #23.1 — `feat(inject): detect-permissions — real inject + undo check`
Labels: `feat`, `fase: v0.2`, `inject`
- Body: `checkAccessibility()`: tries a 1-character inject followed by undo and reports ok/no_permission/failed according to the observed behavior (§8).
- Acceptance: without permission → `no_permission`; after granting → `ok` without recompiling.

### #23.2 — `feat(inject): CLI lisa-inject "text" (standalone bin)`
Labels: `feat`, `fase: v0.2`, `inject`
- Body: `cli.ts` with the text as arg + flags (`--strategy`, `--no-restore`), bin `lisa-inject`; exit codes mirror the check results.
- Acceptance: `lisa-inject "olá"` pastes the text into the focused app on the Mac with the listener off (proof of the §5 decoupling).

### #23.3 — `docs(inject): Accessibility grant instructions`
Labels: `docs`, `fase: v0.2`, `inject`
- Body: section in the docs with a screenshot of System Settings → Privacy → Accessibility, the correct process to allow, and the re-test via CLI.
- Acceptance: going from `no_permission` to `ok` following only the doc.

**Dependencies:** #S20, #S21.

---

## #S24 — `feat(listener): INJECT mode end-to-end + health with real check` — creation no. 24

Labels: `feat`, `fase: v0.2`, `listener`, `inject`
> Phase v0.2 — the central challenge of the spec: text into the focused field of the Mac (§1, v0.2).

**Context:** §6: inject variant of the response (`{injected, detail}`); §8/§11.2 item 1: `/api/health` runs the real permission check and reports `inject: ok | no_permission | failed`.

**DoD (parent)**
- [ ] `POST /api/dictate` with `X-Lisa-Mode: inject`: transcribe → inject → `{ok: true, mode: 'inject', injected: true, text}` (§12 v0.2, item 2 — server side)
- [ ] without permission → `{injected: false, error: {code: 'INJECT_NO_PERMISSION'}}`; technical failure → `INJECT_FAILED` (§6)
- [ ] `/api/health` reports `inject: ok | no_permission | failed` with a real check (§11.2, item 1)
- [ ] sanitization: transcript only via spawn with an arg array, never a shell string (§10)

**Children**

### #24.1 — `feat(listener): inject flow in the dictate route`
Labels: `feat`, `fase: v0.2`, `listener`
- Body: in `inject` mode, after transcribe: calls `injectText` from `@lisa/inject` (strategy from the header) and builds the inject variant of the response with `{injected, detail}`.
- Mapping of `INJECT_NO_PERMISSION` vs `INJECT_FAILED` from the package errors.
- Acceptance: dictating in Inject mode with Safari focused pastes the text on the Mac and the app shows `injected: true`.

### #24.2 — `feat(listener): inject health — real Accessibility check`
Labels: `feat`, `fase: v0.2`, `listener`
- Body: `/api/health` consumes `checkAccessibility()` (23.1), with the result cached for a few minutes (the real check is invasive — inject+undo on every ping is not). The `inject: null` field from v0.1 becomes a real value (§11.2, item 1).
- Acceptance: health reflects the real permission state; revoked → `no_permission` and the app (#25.3) guides the user.

### #24.3 — `test(listener): inject with mocked packages/inject`
Labels: `test`, `fase: v0.2`, `listener`
- Body: tests of the inject route with the package mocked: happy path, `no_permission`, `failed`, invalid strategy.
- Acceptance: covers all response branches without real macOS.

**Dependencies:** #S10, #S21, #S22, #S23.

---

## #S25 — `feat(web): Inject mode in the PWA` — creation no. 25

Labels: `feat`, `fase: v0.2`, `web`
> Phase v0.2 — the user picks Inject and sees the delivery feedback (§7.3 flow).

**Context:** §7.2: 3-mode toggle; §7.3: "text delivered" feedback + latency; inject errors with a permission guide.

**DoD (parent)**
- [ ] Inject/Save/Display only toggle — Inject functional end-to-end (§12 v0.2, item 2)
- [ ] success shows "text delivered" + latency; `injected: false` shows the reason (§7.3)
- [ ] `INJECT_NO_PERMISSION` explains how to grant it (link to the docs); `INJECT_FAILED` clear message (§11.2, item 2 — inject case)

**Children**

### #25.1 — `feat(web): mode toggle (Inject | Save | Display only)`
Labels: `feat`, `fase: v0.2`, `web`
- Body: selector on the Record screen, linked to `defaultMode` from the settings (11.2); Save disabled with a "v0.3" hint until #S30. `X-Lisa-Mode` header according to the selection.
- Acceptance: mode change persists between sessions; correct header on the request.

### #25.2 — `feat(web): inject delivery feedback + latency`
Labels: `feat`, `fase: v0.2`, `web`
- Body: in inject mode: `injected: true` → toast/card "text delivered" with the last-request log latency; `injected: false` → failure detail.
- Acceptance: complete §7.3 flow visible (recording → … → text delivered).

### #25.3 — `feat(web): readable INJECT_* errors + permission guide`
Labels: `feat`, `fase: v0.2`, `web`
- Body: extends the error map (15.1) with `INJECT_NO_PERMISSION` (Accessibility + docs link) and `INJECT_FAILED` (suggests re-testing the health).
- Acceptance: revoked permission → error guides the user until resolved; health in the app reflects `no_permission`.

**Dependencies:** #S13, #S24.

---

## #S26 — `test: e2e Playwright of display mode (fake whisper)` — creation no. 26

Labels: `test`, `fase: v0.2`, `web`, `listener`
> Fulfills §12 v0.2 item 4 and §11.4 item 4 (e2e Playwright against the PWA on desktop, simulated mic).

**Context:** §5: `tests/e2e/` Playwright against the PWA on desktop, with a simulated mic and fake whisper-server — loop regression without a real device.

**DoD (parent)**
- [ ] e2e of the display flow passes headless (runnable in CI — §12 v0.2, item 4)
- [ ] deterministic fake whisper-server (fixed text per fixture) — no real network in the test
- [ ] error scenario (whisper down → readable message in the UI) covered

**Children**

### #26.1 — `test(e2e): Playwright setup + fake whisper + simulated mic`
Labels: `test`, `fase: v0.2`, `web`
- Body: Playwright config (desktop chromium/webkit), fake whisper (deterministic mock on an alternate port), mic permission via launch flags/fake device.
- Acceptance: `pnpm e2e` starts web + listener (fake whisper) and opens the PWA in a secure context (localhost).

### #26.2 — `test(e2e): happy-path display flow — record → transcript on screen`
Labels: `test`, `fase: v0.2`, `web`
- Body: script: click the mic, record ~2s (fake audio), stop, assert the fake transcript on screen and the "delivered" status (§11.4, item 4).
- Acceptance: green headless; separate job from unit in CI.

### #26.3 — `test(e2e): whisper down error — readable message in the UI`
Labels: `test`, `fase: v0.2`, `web`
- Body: dead fake whisper → dictate → `WHISPER_DOWN` message visible and readable (§11.2, item 2, client side).
- Acceptance: green test asserting the exact message.

**Dependencies:** #S13, #S16.

---

## #S27 — `docs: inject matrix in the 5 apps` — creation no. 27

Labels: `docs`, `fase: v0.2`, `inject`
> Fulfills §12 v0.2 item 3 and §8 — matrix in `docs/inject-matrix.md`, validation in Safari, Obsidian, VS Code, Notes, Slack.

**Context:** §8 lists the edge cases to measure: apps that block paste, copy race, sandboxed apps. The structured record feeds the pilot report (#S33) and the fallback strategy (#S32).

**DoD (parent)**
- [ ] `docs/inject-matrix.md` with a row per app × columns: paste, type, clipboard race, latency
- [ ] 5 apps measured with recorded results — no empty cells ("not testable" counts, with a reason) (§12 v0.2, item 3 / §11.4, item 2)
- [ ] actionable conclusions at the end of the doc (which apps require the type strategy)

**Children**

### #27.1 — `docs: docs/inject-matrix.md template`
Labels: `docs`, `fase: v0.2`, `inject`
- Body: matrix template (5 apps × §8 experiments) + instructions on how to run each cell (lisa-inject CLI, app in focus, concurrent copies).
- Acceptance: template committed; anyone reproduces an experiment.

### #27.2 — `docs: matrix results — 5 apps measured`
Labels: `docs`, `fase: v0.2`, `inject`
- Body: run and record Safari, Obsidian, VS Code, Notes, Slack — paste / type / race / latency per app (§8, §11.4 item 2).
- Acceptance: complete matrix; apps with blocked paste with a recommended alternative strategy.

**Dependencies:** #S23 (CLI), #S24 (inject mode in the listener).

---

# EPIC 3 — v0.3: Save mode (milestone v0.3)

---

## #S28 — `feat(db): SQLite with schema mirrored from pepper` — creation no. 28

Labels: `feat`, `fase: v0.3`, `db`
> Phase v0.3 — "SQLite + schema mirrored from pepper (§9)" (§12 v0.3, item 1). Trivial migration to pepper is the reason for the mirror.

**Context:** §9: `transcriptions` (UUID id, title derived from the 1st sentence, text, audio_size, source='dictation', created_at) in SQLite at `~/Library/Application Support/lisa/lisa.db` — outside the repo. Fields mirror pepper, minus `user_id` (copy + fill on migration).

**DoD (parent)**
- [ ] DB at `~/Library/Application Support/lisa/` (honors `LISA_DB_PATH`), nothing in the repo (§12 v0.3, item 1)
- [ ] `transcriptions` schema identical to §9 (§12 v0.3, item 1)
- [ ] `title` derived automatically from the first sentence
- [ ] repository in `apps/listener/src/db/` with tests

**Children**

### #28.1 — `feat(db): better-sqlite3 + DB bootstrap at the user path`
Labels: `feat`, `fase: v0.3`, `db`, `listener`
- Body: `better-sqlite3` dependency, DB opened at the config path (creates the directory if missing), WAL mode, schema v1 migration.
- Acceptance: starting the listener creates `lisa.db` in the right place; no DB in the repo (.gitignore already covers it).

### #28.2 — `feat(db): transcriptions schema mirrored from pepper + derived title`
Labels: `feat`, `fase: v0.3`, `db`
- Body: DDL from §9 (`id` UUID PK, `title` derived from the 1st sentence, `text`, `audio_size`, `source` default 'dictation', `created_at`), with a code comment pointing at the missing `user_id` and the migration step (§9).
- Acceptance: schema matching §9 column by column; migration to pepper becomes copy + fill of `user_id`.

### #28.3 — `feat(db): repository (insert/get/list/delete) + vitest`
Labels: `feat`, `fase: v0.3`, `db`, `test`
- Body: `apps/listener/src/db/` with typed access functions; tests with a temporary DB in tmp.
- Acceptance: CRUD covered by tests; runs in CI (SQLite depends on no service).

**Dependencies:** #S3 (path in config), #S7 (errors — `DB_ERROR`).

---

## #S29 — `feat(listener): SAVE mode in /api/dictate + /api/notes routes` — creation no. 29

Labels: `feat`, `fase: v0.3`, `db`, `listener`
> Phase v0.3 — "/api/notes routes (GET list, DELETE)" (§12 v0.3, item 2) + wire of save mode + DB health (§11.2, item 1).

**Context:** §6: `save` mode answers `{ok: true, mode: 'save', text, id}`; §9 persists with `source: 'dictation'`. No list in the app (§7.2) — the routes are for debugging and pepper.

**DoD (parent)**
- [ ] `X-Lisa-Mode: save` → INSERT with derived title → response with `id`
- [ ] `GET /api/notes` (list) and `DELETE /api/notes/:id` (§12 v0.3, item 2)
- [ ] `/api/health` reports `db: ok | error` (§11.2, item 1 — DB part)
- [ ] `DB_ERROR` on any DB failure (§6)

**Children**

### #29.1 — `feat(listener): save mode → INSERT + response with id`
Labels: `feat`, `fase: v0.3`, `db`, `listener`
- Body: branch `routes/dictate.ts` for save: transcribe, INSERT with audio_size, return `{mode: 'save', text, id}`. DB errors → `DB_ERROR`.
- Acceptance: dictating with save persists the correct row (source dictation, derived title) and the id comes back to the app.

### #29.2 — `feat(listener): GET /api/notes (list)`
Labels: `feat`, `fase: v0.3`, `db`, `listener`
- Body: GET route with simple pagination (limit/offset), records by created_at desc; route contract added to `packages/shared`.
- Acceptance: curl lists what was saved; limit with a sane cap.

### #29.3 — `feat(listener): DELETE /api/notes/:id`
Labels: `feat`, `fase: v0.3`, `db`, `listener`
- Body: DELETE by id; 404 with a shared error when missing; physical deletion (pilot).
- Acceptance: create → delete → list confirms the removal; nonexistent id → JSON 404.

### #29.4 — `feat(listener): db health — real connection check`
Labels: `feat`, `fase: v0.3`, `db`, `listener`
- Body: the `db` health field becomes real: cheap query (SELECT 1) with an ok/error result, short cache.
- Acceptance: DB unavailable → health `error`; back → `ok`.

**Dependencies:** #S28, #S10 (base dictate route).

---

## #S30 — `feat(web): Save mode in the PWA` — creation no. 30

Labels: `feat`, `fase: v0.3`, `web`
> Phase v0.3 — "Save mode toggle + in-app feedback" (§12 v0.3, item 3). No list/CRUD in the app (§7.2: "no list") — the feedback is the saved record.

**Context:** the toggle already exists since #S25; here the Save mode becomes functional, with feedback of the saved record and handling of `DB_ERROR`.

**DoD (parent)**
- [ ] Save mode functional end-to-end: dictate → saved → feedback with id (§12 v0.3, item 3)
- [ ] `DB_ERROR` with a readable message (§11.2, item 2 — db case)
- [ ] no list/CRUD UI in the app (out of scope — §1)

**Children**

### #30.1 — `feat(web): wire Save mode + record feedback`
Labels: `feat`, `fase: v0.3`, `web`
- Body: enables the Save option in the toggle (25.1), sends `X-Lisa-Mode: save`, feedback shows "saved" + short id.
- Acceptance: dictating with Save stores in the DB and shows the confirmation; last-request log updates the same way.

### #30.2 — `feat(web): readable DB_ERROR error`
Labels: `feat`, `fase: v0.3`, `web`
- Body: error map (15.1) with `DB_ERROR` → "could not save; check the listener health".
- Acceptance: DB unavailable (rename the file) → proper message in the app.

**Dependencies:** #S25, #S29.

---

# EPIC 4 — v0.4: Polish (optional — feeds pepper)

> Milestone v0.4 created only when the pilot is declared successful.

---

## #S31 — `feat(web): VAD (Silero) in the browser` — creation no. 31

Labels: `feat`, `fase: v0.4`, `web`
> Phase v0.4 — "VAD (Silero) in the browser — goes into pepper's v1.x roadmap" (§12 v0.4, item 1). Experiment: evaluate before it becomes default.

**Context:** §3: VAD doesn't enter the pilot — Silero is polish and input for the pepper decision. Feature flag, default off; the manual stop button remains the main path.

**DoD (parent)**
- [ ] Silero VAD in the browser detects end of speech and stops the recording (§12 v0.4, item 1)
- [ ] toggle off by default (flag in the app); manual stop keeps working the same
- [ ] evaluation note documented (latency, false positives in PT-BR) for pepper's v1.x roadmap

**Children**

### #31.1 — `feat(web): Silero VAD with automatic stop`
Labels: `feat`, `fase: v0.4`, `web`
- Body: integration of the Silero VAD (in the browser, wasm model) into `recorder.ts`: with the flag active, `stop()` fires on the post-speech silence.
- Acceptance: a finished sentence ends the recording on its own in plausible time.

### #31.2 — `feat(web): VAD feature toggle (default off)`
Labels: `feat`, `fase: v0.4`, `web`
- Body: flag in the settings (localStorage) + discreet UI; default off.
- Acceptance: off didn't regress anything in the v0.1 manual flow.

### #31.3 — `docs: VAD evaluation for pepper v1.x`
Labels: `docs`, `fase: v0.4`
- Body: short doc with what to measure (cutoff precision, latency, model cost on device) and a preliminary conclusion for pepper's roadmap.
- Acceptance: written recommendation (adopt / defer / discard) with test data.

**Dependencies:** #S13 (consolidated recording cycle).

---

## #S32 — `feat(inject): validated keystroke fallback (matrix + tests)` — creation no. 32

Labels: `feat`, `docs`, `fase: v0.4`, `inject`
> Phase v0.4 — "char-by-char keystroke fallback tested" (§12 v0.4, item 2). Implemented in v0.2 (#S21); here is the deep validation.

**Context:** moves the fallback from "works in 1 app" to "validated in the matrix apps", backed by unit tests.

**DoD (parent)**
- [ ] unit tests of the `type` fallback cover special chars/accents/limits (§11.4, item 4)
- [ ] fallback cells filled in the matrix for the apps that block paste (§12 v0.4, item 2)
- [ ] per-app default strategy recommendation recorded (#S27)

**Children**

### #32.1 — `test(inject): type fallback — special chars and limits coverage`
Labels: `test`, `fase: v0.4`, `inject`
- Body: mocked tests of `typeText` with accents, emoji, quotes, size limit and aborts.
- Acceptance: runs without macOS; covers the cases that break `keystroke`.

### #32.2 — `docs(inject): fallback cells in the matrix + strategy per app`
Labels: `docs`, `fase: v0.4`, `inject`
- Body: fill in `docs/inject-matrix.md` (#S27) the results of `x-lisa-inject-strategy: type` per app; conclude which default to use.
- Acceptance: matrix with no empty cell in the fallback column; recommendation recorded.

**Dependencies:** #S21, #S27 merged.

---

## #S33 — `docs: pilot report + standalone extraction of packages/inject` — creation no. 33

Labels: `docs`, `feat`, `fase: v0.4`, `inject`
> Phase v0.4 — "Pilot report: what migrated/decided for pepper + extraction of packages/inject as a standalone module" (§12 v0.4, item 3). The pilot exists to produce this.

**Context:** §2/§5: what migrates to pepper is the server-side (listener + inject) extracted as a package — `packages/inject` never depended on a framework for this reason.

**DoD (parent)**
- [ ] `docs/pilot-report.md` with decisions, numbers (benchmark, matrix) and what migrates (§12 v0.4, item 3)
- [ ] `packages/inject` compilable/packageable standalone: its own build, own README, zero dependency on app/listener (§12 v0.4, item 3 / §5)
- [ ] extraction path of the listener documented (how it becomes a pepper package)

**Children**

### #33.1 — `docs: docs/pilot-report.md — conclusions and migrations to pepper`
Labels: `docs`, `fase: v0.4`
- Body: report: what worked/didn't work, real latency vs target (#S18), inject matrix (#S27), reviewed technical decisions (§13), explicit list "migrates to pepper" (listener + packages/inject) and "stays in lisa".
- Acceptance: doc approved as input for pepper's roadmap.

### #33.2 — `feat(inject): standalone packaging of packages/inject`
Labels: `feat`, `fase: v0.4`, `inject`
- Body: build/pack of the package (`pnpm pack`) without monorepo deps, own README (usage as lib and CLI), import review (no `@lisa/shared` import if that couples pepper — decide: minimal duplicated types or joint export).
- Acceptance: `pnpm pack` generates a tarball installable in another project; CLI works from it.

**Dependencies:** #S27, #S32 and the closing of the pilot (v0.1–v0.3).

---

## Coverage — §11 checklist → issues

| §11 Item | Issue(s) |
|---|---|
| 11.1 `make setup` | #6.3 (#S6) |
| 11.1 `.env.example` + config zod | #S3 (3.1, 3.2) |
| 11.1 `make dev/build/lint/typecheck/test` | #1.1, #6.3 |
| 11.1 READMEs + docs/setup.md with screenshots | #6.1, #6.2 |
| 11.2 complete `/api/health` | #9.3 (whisper/protocol) + #24.2 (inject) + #29.4 (db) |
| 11.2 readable errors in the app | #15.1 (+ #25.3, #30.2 for inject/db) |
| 11.2 pino structured logs | #S16 |
| 11.2 whisper restart with backoff | #9.4 |
| 11.3 installable PWA | #S14 |
| 11.3 secure context instruction | #15.2 |
| 11.3 reconnection + buffer abort | #15.3 |
| 11.3 accessibility 48px + landscape | #13.1 (button), #15.4 |
| 11.4 latency benchmark | #S18 |
| 11.4 inject matrix, 5 apps | #S27 |
| 11.4 clipboard restoration under copy | #22.2 |
| 11.4 audio unit tests, golden files | #8.4 |
| 11.4 inject unit tests, mocked macOS | #19.2 (+ #32.1) |
| 11.4 e2e Playwright display, fake whisper | #S26 |
| 11.4 `make smoke` curl fixture | #S17 |
| 11.5 CI GitHub Actions | #2.1 |
| 11.5 `.gitignore` | #2.2 |
| 11.5 license + badge | #2.2 |

## Coverage — §12 roadmap → slices

| §12 v0.1 Item | Slice |
|---|---|
| monorepo scaffold | #S1 |
| whisper-server setup | #S4 |
| listener dictate + health | #S9, #S10 |
| PWA worklet→WAV→upload→display | #S11, #S12, #S13 |
| HTTPS | #S5 |
| latency logging + make smoke | #S16, #S17 |

| §12 v0.2 Item | Slice |
|---|---|
| complete packages/inject | #S19–#S23 |
| Inject mode + error matrices | #S24, #S25 |
| inject matrix 5 apps | #S27 |
| display e2e | #S26 |

| §12 v0.3 Item | Slice |
|---|---|
| SQLite pepper schema | #S28 |
| /api/notes GET/DELETE | #S29 |
| Save toggle + feedback | #S30 |

| §12 v0.4 Item | Slice |
|---|---|
| Silero VAD | #S31 |
| tested keystroke fallback | #S32 |
| report + inject extraction | #S33 |

## Decisions made beyond the spec (to review)

1. **Phasing of the §11 items** — the checklist doesn't bind items to phases. I distributed: health/errors/logs/restart/PWA/robustness in v0.1 (usable loop), inject parts in v0.2, DB health in v0.3. Reviewable.
2. **Keystroke fallback implemented in v0.2 (#S21), "tested" in v0.4 (#S32)** — §8 lists the fallback as a technical decision (flag in the protocol) and §12 only validates it in v0.4; splitting impl × validation avoids a broken protocol in v0.2.
3. **The 3-mode toggle enters in v0.2 (#25.1)** with Save disabled by hint — avoids UI rework in v0.3. Alternative: only 2 modes in v0.2.
4. **`/api/notes` server-only, no list UI** — §7.2 says "no list" in the app; GET/DELETE exist for debugging and pepper.
5. **`make setup` as a child of #S6** and not of the scaffold — the target orchestrates whisper + https (D slices), and the "compiles Swift helper" step stays reserved, actually activating in #20.2.
6. **Benchmark in v0.1 (#S18)** as its own docs slice — §11.4 doesn't fix a phase; measuring early gives data for model/latency decisions before the inject.
7. **Benchmark and matrix method** (number of runs, device) not defined in the spec — issues #18.1 and #27.1 establish the method before collecting numbers.
8. **MIT license assumed** — confirm with the author in #2.2.
