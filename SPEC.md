# lisa — Project Spec (v3)

> Test pilot: press **Record** on a dedicated ESP32 recorder → text appears on the computer — displayed in a Next.js panel (v0.1) or **typed into the focused field** (v0.2) — in the style of Whispering/WhisperFlow. 100% local, self-hosted on the owner's Mac.

Major pivot decided by the owner on **2026-11-27**: phone/PWA capture is out; services are Python; frontend is Next.js; the capture device is now dedicated ESP32 hardware. Nx replaces pnpm+turborepo. See §15 for the dated decision log.

## 1. Vision

Test pilot for **pepper.ai**: a hardware recorder (ESP32 + I2S mic + 3 buttons + mini display) captures the user's voice and sends a WAV session to a **self-hosted Python API** running on the owner's Mac. The API transcribes with **whisper.cpp** (local binary, Metal) and:

- **v0.1** — displays the transcript in a **Next.js control panel** (responsive, phone-friendly browser).
- **v0.2** — when the user places the cursor in any text field on the desktop, the same flow ends with the transcript **injected into the focused field** (clipboard + `Cmd+V`). The panel remains the control plane.
- **v0.3** — polish: save-mode UI, optional PWA installability, streaming evaluation.

Everything runs on the owner's infrastructure: the Mac hosts the API, whisper.cpp, SQLite and the frontend ("temos um server próprio que pode gerenciar tudo"). Monorepo (Nx) shared between web, server, firmware and inject.

**Pilot phases:**

- **v0.1:** ESP32 records → upload → Python API transcribes → transcript displayed in the Next.js panel.
- **v0.2:** transcript injected into the focused field of the Mac (clipboard + `Cmd+V`).
- **v0.3:** save-mode UI + optional PWA + streaming evaluation (feeds pepper).

**What the pilot is NOT:** no login, no full CRUD, no command interpretation (pepper v2), **no live/streaming transcription** (v0 is session-based: Stop → WAV → upload → transcript; see §15 open), no phone-as-microphone. Code that proves itself good migrates to pepper.

## 2. Relationship with pepper.ai

| Topic | pepper.ai | lisa |
|---|---|---|
| Role | Full product (assistant) | Interface/test pilot — dictation hardware loop |
| Codebase | Separate | Separate — **internal Nx monorepo** (§5) |
| Sign-up/JWT | Yes (v1) | No — trusted local network |
| Client | React Native | **Next.js (App Router, TS)** — control panel; RN may come back in pepper |
| Capture device | Phone mic | **ESP32 external recorder** (hardware) |
| API/server | Node (pepper pipeline) | **Python (FastAPI) + whisper.cpp binary** — server-side candidate to extract |
| Text inject on desktop | No (focus: app + API) | **Yes — the central challenge (lisa v0.2)** |
| ASR | whisper.cpp `large-v3-turbo` | Same model, called as **binary subprocess** |
| PWA | — | Secondary/optional (v0.3) |
| Saved records | Yes (core of v1) | v0.3 save mode, mirroring the schema (§11) |

If lisa becomes a pepper module: what migrates is the **server-side** (FastAPI orchestration + whisper call + inject) extracted as a Python package; the panel's UX patterns (session cards, status, latency feedback) port to the pepper client. The inject package is already isolated for this (§5/§8).

## 3. Technical decisions

New decisions from the 2026-11-27 pivot are marked **(+ 2026-11-27)**.

| Decision | Choice | Reason |
|---|---|---|
| Monorepo | **Nx** (one workspace, cache + task graph) **(+ 2026-11-27)** | Replaces pnpm workspaces + Turborepo. Single task graph across TS, Python and firmware projects; `nx run-many`, affected, remote cache when needed. |
| Node package manager | **pnpm** (still, inside the Nx workspace) | Nx runs fine on pnpm; keeps the fast install from v2. |
| Python project manager | **uv** per Python project (`apps/server`, `packages/inject`) **(+ 2026-11-27)** | Fast, lockfile-based (`uv.lock`), venv management; Nx wraps `uv` commands (§5), it does not replace them. |
| API/server | **Python 3.12+ (FastAPI + uvicorn)** **(+ 2026-11-27)** | Replaces Node/Fastify. Native `subprocess` for whisper.cpp, clean OpenAPI generation, type-safe Pydantic models. |
| ASR | **whisper.cpp `large-v3-turbo`** — **binary subprocess** **(change, 2026-11-27)** | Confirmed in pepper (WER ~3.8% PT-BR, Metal). The Python service calls the **whisper.cpp binary directly** via `subprocess` — validated **3.0 s / 19 s phrase** on the owner's M4. The separate **whisper-server HTTP process is dropped**: one hop less, no second port/process to supervise. Revisit criteria in §15. |
| Frontend | **Next.js (App Router, TypeScript), responsive** **(+ 2026-11-27)** | Control panel + transcript display, phone-friendly. PWA (manifest/SW) demoted to secondary/optional (v0.3). |
| Capture device | **ESP32 hardware recorder** — external, dedicated **(+ 2026-11-27)** | Replaces phone capture entirely. Physical buttons (Record/Pause/Stop), always-on device, no browser mic permissions. |
| Mic | **INMP441-class I2S digital mic** | Cheap, digital I2S (no analog gain tuning), 16 kHz mono PCM direct. |
| Display | **ST7735-class mini TFT ~160×80 (SPI)** | Color + enough pixels for status line, live bar-graph waveform and elapsed timer together. SSD1306 OLED 128×64 (alternative): cheaper/monochrome, but cramped for waveform + timer + status simultaneously, no color states. Exact module still open (§15). |
| Firmware framework | **PlatformIO + Arduino framework** (fallback: ESP-IDF) **(+ 2026-11-27)** | Dev speed: batteries-included WiFi/HTTP/I2S/SPI libs. Revisit to ESP-IDF if the Arduino core gets in the way of I2S DMA timing or display performance, or if OTA/multi-core scheduling becomes a need (§15). |
| Audio format | **PCM 16 kHz mono** → WAV (16-bit) on Stop | Same format as pepper's pipeline; direct whisper.cpp input. ESP32-side downsample/crop handled in firmware, not on the server. |
| Audio spooling | Raw PCM streamed to **LittleFS** during recording; WAV assembled at Stop | ESP32 RAM (~300–500 KB usable) cannot hold long sessions: 16 kHz × 2 B = **32 KB/s**. LittleFS absorbs it trivially; enables retry-upload after connectivity loss (§6.5). |
| Transport | **HTTPS on the LAN via mkcert** **(decided, 2026-11-27 — closes v2 §13 Q1)** | **Tailscale Serve returned 501 on the owner's tailnet** → mkcert path chosen. mkcert CA is trusted on macOS for the panel and embedded into the ESP32 for upload validation (§10). |
| Protocol | **OpenAPI-first**: FastAPI generates the schema; **openapi-typescript** generates the TS client into the web app **(+ 2026-11-27)** | Replaces `packages/shared` TS types as the source of truth. Server drifts → regenerate → web build breaks on type mismatch (§7.1). |
| Status transport | **REST + client polling** (no WebSocket). SSE optional later | One pending session max; 1 s poll is enough. SSE enters the open list for v0.3. |
| Streaming (live audio → server) | **Not in v0** — explicit deferral | Session-based flow only. Live capture = firmware streaming protocol + server ingestion; deferred, tracked in §15. |
| Mode | `display` (v0.1) / `inject` (v0.2) / `save` — server-side default + panel toggle | In v0.2 the flow is: user focuses a field on the desktop → presses Record on the ESP32 → Stop → API transcribes → injects. No ESP32 change needed. |
| Text inject (macOS) | **1st: clipboard + simulated `Cmd+V`** (Swift helper via `CGEventPost`); restores the previous clipboard | Inherited from v2 §8. Now a **Python package** (`packages/inject`) invoked from the FastAPI service in v0.2. Requires Accessibility permission. |
| Inject fallback | AppleScript `keystroke` type-as-you-type | For fields that ignore paste; slow, only when paste fails. |
| DB | **SQLite** — schema from v2 §9 | Save mode (§11). `source` gains `'esp32'`. |
| VAD | No — physical **Stop** button | Hardware button beats VAD for v0; Silero only as polish, same roadmap as pepper. |
| Target OS | **macOS** (server + inject); panel usable from any browser on the LAN | Text inject varies by OS — macOS only in the pilot. ESP32 recorder is OS-agnostic. |

## 4. Architecture

```
┌─ ESP32 recorder (hardware) ─────────┐          ┌─ Mac (owner) — self-hosted lisa server ──────────────────────┐
│                                     │  HTTPS   │                                                              │
│  INMP441 I2S mic 16 kHz mono        │─────────→│  apps/server — FastAPI :8000 (uvicorn, uv)                   │
│  buttons: RECORD / PAUSE / STOP     │ multipart│   ├─ POST /api/sessions (WAV) → SQLite row (queued)          │
│  (GPIO, debounced)                  │   WAV    │   ├─ worker: whisper.cpp BINARY (subprocess)                 │
│  ST7735 TFT 160×80:                 │          │   │    large-v3-turbo, Metal — 3.0s / 19s phrase (M4)        │
│    status + bar-graph waveform      │←─────────│   ├─ GET /api/sessions[/{id}] → status + transcript          │
│    + elapsed time (mm:ss)           │  polling │   ├─ v0.2 INJECT: clipboard ← text, Cmd+V in focused field   │
│  WiFi + soft-AP provisioning portal │          │   │    (packages/inject: Python + Swift CGEvent helper)      │
│  NVS: ssid/pass/server URL/CA       │          │   └─ SQLite ~/Library/Application Support/lisa/lisa.db       │
└─────────────────────────────────────┘          │                                                              │
                                                 │  apps/web — Next.js :3000 (mkcert HTTPS, responsive)         │
        firmware: PlatformIO + Arduino           │    panel: session cards (polling), transcript, history,      │
        (Nx target wraps `pio run`)              │    settings, health check. OpenAPI-generated TS client       │
                                                 └──────────────────────────────────────────────────────────────┘
```

- The ESP32 talks **only to the FastAPI server** (:8000). The panel (:3000) proxies `/api` to :8000 via Next rewrites (no CORS, §9.4).
- **No whisper-server process**: the API subprocesses the whisper.cpp binary on demand (queued worker, concurrency 1 — Metal is serial anyway).
- Session flow: `[Record] → capture 16k mono → [Pause]/resume → [Stop] → WAV header → POST /api/sessions → queued → transcribing → done(panel picks up) | injected (v0.2) | save (v0.3)`.

## 5. Monorepo (Nx)

One Nx workspace. `project.json` per project wraps the real tool (pnpm, uv, pio) — Nx never replaces the toolchain, only orchestrates caching/task-graph.

```
lisa/
├── nx.json
├── package.json                 # pnpm; root scripts → nx run-many
├── pnpm-workspace.yaml          # node deps only (npm-side); Python uses uv, firmware uses pio
├── .env.example
├── Makefile                     # one-shot setup (§12)
├── apps/
│   ├── web/                     # Next.js (TS) — apps/web/project.json: dev, build, lint, test, api-client
│   │   └── src/app/…            # App Router; src/lib/api/schema.d.ts ← generated (openapi-typescript)
│   ├── server/                  # FastAPI (Python/uv) — pyproject.toml + uv.lock + project.json:
│   │   ├── app/                 #   serve (uv run uvicorn), test (uv run pytest), lint (ruff),
│   │   │   ├── main.py          #   export-openapi (writes apps/server/openapi.json, committed)
│   │   │   ├── routes/          #   sessions.py, health.py, inject.py (v0.2)
│   │   │   ├── whisper/         #   binary runner + session worker queue
│   │   │   ├── db/              #   SQLite (save mode)
│   │   │   └── config.py        #   env via pydantic-settings
│   │   ├── openapi.json         # ← committed contract artifact (source of truth)
│   │   └── tests/
│   └── firmware/                # PlatformIO (Arduino framework) — platformio.ini + project.json:
│       ├── src/                 #   build (pio run), upload (pio run -t upload), monitor (pio device monitor)
│       │   ├── main.cpp         #   session state machine, audio task, display, buttons
│       │   ├── audio/           #   I2S driver + spooler (LittleFS)
│       │   ├── display/         #   ST7735 driver, waveform, timer
│       │   ├── net/             #   WiFi, HTTPS upload (mkcert CA), retry queue
│       │   └── provision/       #   soft-AP captive portal → NVS
│       └── data/                #   LittleFS partition
├── packages/
│   └── inject/                  # Python package (v0.2) — clipboard + paste helper + Swift build step
│       ├── pyproject.toml       #   uv-managed; CLI: `lisa-inject "text"`
│       ├── src/lisa_inject/     #   clipboard.py, paste.py, permissions.py
│       └── native/InjectKey.swift  #  compiled at setup (§12) → CGEventPaste
├── scripts/
│   ├── setup-whisper.sh         # downloads/builds whisper.cpp (Metal) + large-v3-turbo model — survives from v2
│   ├── run-whisper.sh           # repurposed: smoke-run of the whisper.cpp CLI on a fixture WAV (server process no longer exists)
│   └── setup-https.sh           # mkcert: CA install, cert issuance for :3000/:8000 hosts, exports rootCA.pem path (§10)
└── docs/
    ├── inject-matrix.md         # v0.2 validation matrix (inherited from v2 §8)
    └── firmware-bringup.md      # pins, display variant, provisioning walkthrough
```

**Python-in-Nx choice:** Nx targets for Python projects are **`@nx/js:run-commands` executors delegating to `uv`** (`uv run uvicorn …`, `uv run pytest`, `uv sync` as an implicit target dependency), with `inputs`/`outputs` declared for cache correctness (hash `uv.lock`, source globs; outputs: none for test, artifacts where applicable).

- Rationale: zero extra plugin dependency; `uv` already solves env/lock resolution — duplicating that in a community plugin adds a maintenance surface (the plugin tracks Nx majors with lag) for a 2-project Python workspace.
- **Fallback / revisit:** `@nxlv/python` (community plugin: native `uv` integration, lockfile-aware caching). Swap in if run-commands cache hashing for Python gets annoying to maintain or the server test suite grows. Tracked in §15 open.
- Firmware likewise: `run-commands` wrapping `pio run` (PlatformIO CLI must be on PATH; cache off for upload/monitor targets).

Rules:

- `apps/*` depend on `packages/*`, never the other way around.
- The web↔server contract lives **only** in `apps/server/openapi.json` (generated by FastAPI). No hand-written TS API types anywhere — the web client is 100% generated (`openapi-typescript` + `openapi-fetch`).
- Firmware knows only the HTTP contract (§7) — it never imports shared code from web/server.
- `packages/inject` knows nothing about FastAPI — pure Python lib + CLI (`lisa-inject "text"`), shippable standalone to pepper.

Nx target dependency graph (concept):

```
server:export-openapi ──→ web:api-client ──→ web:build
       │                      ▲
whisper setup (Makefile)      │
uv sync (implicit dep) ───────┘
firmware:build (pio) — independent; upload/monitor: no cache
```

## 6. ESP32 recorder

### 6.1. Hardware

| Component | Choice | Notes |
|---|---|---|
| MCU | ESP32-S3 devkit (DevKitC-1-class) | More RAM/flash headroom for spooling + display; classic ESP32 acceptable but tighter. Final devkit = bring-up decision (§15). |
| Mic | INMP441 (or INMP441-class) I2S | L/R pin → GND (left channel); 24-bit sample in 32-bit frame → shift/scale to int16 in firmware. |
| Display | **ST7735-class TFT 160×80, SPI** | Driver: LovyanGFX (preferred — variant auto-config) or TFT_eSPI. Exact module (green/black tab variants, or ST7789 240×135) in §15 open. |
| Buttons | 3 × tactile on GPIO with pull-ups | Record / Pause / Stop. Debounce ~30 ms. Proposed pins (tentative, fix at bring-up): REC=GPIO4, PAUSE=GPIO5, STOP=GPIO6; I2S: SCK=GPIO12, WS=GPIO13, SD=GPIO14; SPI: SCK/MOSI/CS/DC/RST per devkit defaults. |
| Storage | LittleFS partition (~2–4 MB) | PCM spool + one pending-session WAV if offline. |
| Provisioned data | NVS | SSID, password, server URL, mkcert root CA (§6.6). |

### 6.2. Session state machine (buttons)

```
              REC                 REC (resume)                STOP
   IDLE ──────────────→ RECORDING ─────────→  RECORDING  ──────────→ FINALIZING
    ↑   ▲ (buffer kept)      │   PAUSE        │    (WAV header on    → UPLOADING → DONE ─→ IDLE
    │   │                    ▼       │        │     spooled PCM)          │            │
    │   └──────────────── PAUSED ◄───┘        │                           ▼            │
    │                                          │                      UPLOAD-FAILED    │
    │   STOP while PAUSED = same path          └── REC while recording     (retry queue)  │
    │                                              = ignored / short-beep  ▲              │
    └──────────────────────────────────────────────────────────────────────┴──────────────┘
```

- **Record**: idle → start I2S capture, spool to LittleFS, display RED + bar-graph + elapsed timer. While paused → resume (same session, timer continues but paused time excluded).
- **Pause**: recording → PAUSED (yellow display, frozen timer, mic muted, spooler paused).
- **Stop**: recording/paused → FINALIZING (assemble WAV: RIFF header + spool) → UPLOADING (progress %) → DONE (green + round-trip latency) → IDLE.
- Upload failure → keep WAV in flash, state UPLOAD-FAILED with periodic auto-retry (exp. backoff, cap 5 min) — one pending session queued. New Record allowed after retry queue has 1 item max.
- Errors (mic init, WiFi, upload) → display message 5 s → previous idle/paused state. Recorded audio is never dropped silently.

### 6.3. Audio

| Property | Value |
|---|---|
| Capture | I2S Philips, 32-bit slots, INMP441 → int16 (scale ≫14) |
| Rate/channels | **16 kHz mono** |
| Encoded | WAV (RIFF header) at FINALIZING |
| Session cap | ~10 min (LittleFS partition budget); cap enforced with warning at wall |
| Gain/volume | Fixed at bring-up; no server-side normalization in v0 |

### 6.4. Display UI (ST7735 160×80)

| State | Layout |
|---|---|
| IDLE | "LISA" + wifi/online badge + pending-upload indicator |
| RECORDING | RED bar — **bar-graph waveform** (rolling RMS bars, ~24 bars, 10 Hz refresh) + elapsed **mm:ss** |
| PAUSED | YELLOW — "PAUSED" + frozen timer |
| FINALIZING | "PACKING…" |
| UPLOADING | "UPLOAD" + progress % |
| DONE | GREEN — "OK ✓" + `whisper` latency (e.g. "3.1s") |
| UPLOAD-FAILED / ERROR | RED — short message (`WIFI FAIL` / `SRV 503` / `RETRY 3`) |

### 6.5. Connectivity

- WiFi STA, auto-reconnect; single `host + port + scheme` server URL from NVS.
- HTTPS via **esp-tls (esp_http_client / esp_https_ota-compatible)** validating the **mkcert root CA** provisioned on the device (§10).
- Health probe (`GET /api/health`) on boot + on demand: display shows `SRV ✓/✗`.
- All timeouts explicit (connect 5 s, response 30 s…); upload chunked, watchdog fed during transfer.

### 6.6. Provisioning (setup item)

**Soft-AP provisioning portal** (recommended, chosen):

- On first boot (or STOP held 5 s at boot, or 3 failed WiFi joins): ESP32 starts AP `lisa-setup-XXXX` with captive portal (DNS redirect).
- Form fields: WiFi SSID, WiFi password, **server URL** (`https://<mac-host>:8000`), **mkcert root CA (PEM, pasted/uploaded)**.
- Saved to NVS; device reboots into STA mode.

USB-serial provisioning remains the fallback (documented in `docs/firmware-bringup.md`), but the portal is the primary path to keep "new device → working" under 10 minutes.

## 7. API (FastAPI, OpenAPI-first)

### 7.1. Contract flow

1. Models/endpoints defined in FastAPI (Pydantic) — the **single source of truth**.
2. Export target: `nx run server:export-openapi` → writes **`apps/server/openapi.json`** (committed — diffs reviewable).
3. `nx run web:api-client` → `openapi-typescript` generates `apps/web/src/lib/api/schema.d.ts`; the web uses the generated schema via `openapi-fetch` (thin typed fetch wrapper).
4. Drift: CI runs `export-openapi` and fails if `openapi.json` is out of sync; `web:api-client` runs before `web:build` in the task graph.

(Replaces v2's `packages/shared` TS protocol as source of truth.)

### 7.2. Endpoints

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/api/sessions` | Multipart upload of a finalized WAV. Fields: `audio` (WAV file), `mode` (`display` \| `save` \| `inject` — inject = v0.2). Returns `SessionCreated` `{id, status: "queued"}`. |
| `GET` | `/api/sessions` | List, newest first. Query: `limit`, `offset`. `SessionSummary[]` (id, status, title, excerpt, `audio_size`, `source`, `created_at`, `latency_ms`). |
| `GET` | `/api/sessions/{id}` | `SessionDetail`: status + full transcript + latencies. The panel polls this for active sessions. |
| `GET` | `/api/health` | `{status, whisper: {ok, model}, db, inject: {ok, permission} (v0.2), version, protocol}`. |
| `POST` | `/api/sessions/{id}/inject` | **v0.2 only**: (re)inject a ready transcript into the focused field. |

Session status enum: `queued → transcribing → done | failed`; with `inject`: `done → injected | inject_failed`; with `save`: persists to SQLite (`source='esp32'`), same as v2's save mode.

### 7.3. Worker (whisper orchestration)

- Single in-process worker (asyncio; concurrency 1 — Metal is serial). Pulls `queued` sessions, writes WAV to temp, runs **`subprocess` → whisper.cpp binary** (`whisper-cli -m large-v3-turbo --metal —output-json`) with a timeout, parses output, updates the row.
- Measured reference on the owner's M4: **3.0 s / 19 s phrase** — the budget benchmark of §13.
- Crash recovery: on server boot, `transcribing` rows older than a timeout are re-queued (idempotent re-run).
- No auth. `X-Lisa-Device` header for telemetry (`esp32/1.0`, `web/1.0`).
- Typed errors via OpenAPI responses: `WAV_INVALID`, `WHISPER_TIMEOUT`, `INJECT_NO_PERMISSION`, `INJECT_FAILED`, `DB_ERROR`, `SESSION_NOT_FOUND`, `SERVER_OFFLINE` (client-side).
- **No WebSocket.** REST + polling. SSE for session status is optional polish (v0.3); firmware never needs it (upload is one blocking POST).

## 8. Text inject (v0.2, macOS)

Design inherited from v2 §8, re-homed:

- Helper: **`packages/inject` (Python lib + CLI)**, invoked from the FastAPI service when `mode=inject` after transcription. Sequence:
  1. capture + save the current clipboard (timestamped)
  2. write the transcript to the clipboard (NSPasteboard via native bridge; `pbcopy` spawn fallback)
  3. send `Cmd+V` — order of preference: **native Swift helper compiled at setup** (`CGEventPost`, `native/InjectKey.swift`) → AppleScript `System Events keystroke 'v' using command down`
  4. delay 300–500 ms → restore the previous clipboard (unless the user copied something new in that window)
- Permissions: **Accessibility** for the server process (System Settings → Privacy → Accessibility). `/api/health` performs a real check (inject + undo in a test field) → `inject: ok | no_permission | failed`.
- Edge cases (matrix `docs/inject-matrix.md`): apps that block paste (some Electron custom fields), copy race during inject, sandboxed apps. `keystroke` type-as-you-type fallback selectable per session (`mode` extension or `inject_strategy: paste | type`).
- Validation in: Safari, Obsidian, VS Code, Notes, Slack.
- Flow note: in v0.2 the user places the cursor in any focused field on the desktop → presses **Record** on the ESP32 → **Stop** → API transcribes → inject. The panel remains the control plane (mode default, retry, history). No new hardware button in v0.2.

## 9. Frontend (Next.js)

### 9.1. Stack

- **Next.js (App Router) + TypeScript**, responsive single-column (phone-friendly — the panel is consumable from a phone browser over the LAN, even though the phone is no longer the capture device).
- Server state: `openapi-fetch` typed client (generated, §7.1), polling.
- PWA: **secondary/optional** — manifest + minimal SW deferred to v0.3; the app must be fully usable without it.

### 9.2. Screens

1. **Dashboard `/`** — session cards, newest first: status badge (`queued → transcribing → done/failed`), title + excerpt once done, round-trip latency, copy-transcript button. Cards for in-flight sessions poll `GET /api/sessions/{id}` (1 s while active, backoff to 5 s; poll only on page focus). Mode indicator (display/save/inject).
2. **History `/history`** — paginated list (GET /api/sessions), card → expandable full transcript. (Save mode rows surface here, v0.3.)
3. **Settings `/settings`** — default mode, connectivity test (`/api/health` with whisper/inject/db status), inject permission status (v0.2).

No login, no signup. Plain server-side rendering + client polling; no extra state library.

### 9.3. Flow (v0.1 display)

```
ESP32 [Stop] → POST /api/sessions {WAV} → {id, queued} (device shows UPLOAD ✓)
server worker → whisper.cpp subprocess → status=done, text stored
panel dashboard → poll picks up `done` → session card shows transcript + latency
               → copy button (v0.1) · auto-inject into focused field (v0.2)
```

### 9.4. Networking

- Next rewrites proxy `/api/*` → `http://localhost:8000` — same-origin from the browser's perspective, no CORS config.
- Secure context via **mkcert** (§10) for `:3000` — needed once the PWA lands (v0.3); until then HTTPS still on (audio privacy + consistent URLs + ESP32 expects HTTPS).

## 10. Security

- **HTTPS on the LAN via mkcert — DECIDED (2026-11-27).** `scripts/setup-https.sh` creates the local CA, issues certs for the server hosts (`:3000`, `:8000`), installs the CA on macOS. Tailscale Serve was tried first and **501s on the owner's tailnet** → mkcert is the path. This closes v2 §13 open question 1. If exposure off-LAN is ever needed, Tailscale (plain, no Serve) becomes the access-control layer.
- **ESP32 cert handling (open, §15):** the device validates the server chain against the **mkcert root CA** provisioned via the portal (§6.6) and stored in NVS/firmware. Open points: CA rotation procedure, whether to bundle the CA in firmware vs NVS at provisioning, and OTA implications.
- No auth — trusted local network premise (same as pepper's sign-up-free model). LAN-only premise is load-bearing; no tunnels to the public internet.
- Accessibility permission for the server = least privilege; `packages/inject` only sends the transcript as keystrokes/paste, never third-party content, and restores the clipboard.
- Audio never leaves the LAN: whisper.cpp runs locally; there is no cloud path in the whole diagram.
- Upload validation server-side: WAV header check (16 kHz/mono/16-bit), size cap, content-type check — the ESP32 is trusted hardware but the endpoint still validates.

## 11. Data model (save mode; v0.3 UI)

Schema from v2 §9, unchanged:

```sql
transcriptions (
  id         TEXT PK,                   -- UUID
  title      TEXT NOT NULL,             -- derived from the first sentence
  text       TEXT NOT NULL,
  audio_size INTEGER NOT NULL,           -- WAV bytes, for latency debugging
  source     TEXT DEFAULT 'dictation',  -- gains 'esp32' for ESP32-originated sessions
  created_at TEXT NOT NULL DEFAULT now()
)
```

DB: SQLite at `~/Library/Application Support/lisa/lisa.db` (not in repo). Fields mirrored from pepper, minus `user_id` — migration: copy + fill `user_id`. Server-side driver: Python (via `sqlite3` stdlib; no ORM needed at this scale).

## 12. "Ready to use" checklist

Criterion: a new Mac + a new ESP32 board configured from zero in < 30 min, with no undocumented manual steps.

### 12.1. Setup and DX
- [ ] Nx workspace scaffold (`nx.json`, root `package.json`, `project.json` per app/package) — `make setup` runs: `pnpm install`, per-project `uv sync` (server, inject), `scripts/setup-whisper.sh` (whisper.cpp Metal + large-v3-turbo), `scripts/setup-https.sh` (mkcert CA + certs + macOS trust), Swift inject helper compile
- [ ] `.env.example` + `server/app/config.py` (pydantic-settings: port, whisper bin/model paths, db path, default mode) — no secrets on the server
- [ ] Targets wired: `server:serve/test/export-openapi/lint`, `web:dev/build/api-client/lint/test`, `firmware:build/upload/monitor` — run through `nx run-many` root scripts
- [ ] README per app + root; `docs/setup.md` step-by-step (macOS trust, ESP32 flashing, provisioning portal) with screenshots (Accessibility permission, etc.)

### 12.2. Firmware (ESP32)
- [ ] Flash: `nx run firmware:upload` (pio) onto the devkit
- [ ] **Buttons**: record/pause/stop state machine exercised — debounce verified, pause excluded from the timer, stop-while-paused works
- [ ] **Display**: all 7 UI states render (§6.4), bar-graph refresh ≥ 10 Hz, elapsed timer correct across pause/resume
- [ ] **Mic**: INMP441 → 16 kHz mono validated (spectral sanity check via a captured WAV fixture)
- [ ] LittleFS spool: 5-min session recorded without failure; session cap enforced
- [ ] **Provisioning portal**: soft-AP `lisa-setup` → SSID/password/server URL/root CA → NVS; re-provision path (STOP 5 s) verified; USB-serial fallback documented
- [ ] HTTPS upload against the mkcert-signed server passes chain validation; retry queue survives a server outage mid-recording

### 12.3. Server
- [ ] `/api/health` complete: whisper binary presence + model check, DB, inject permission (v0.2), `version`/`protocol`
- [ ] Worker: queued→transcribing→done happy path; crash recovery re-queue; whisper timeout → `failed` with readable error
- [ ] Upload validation: WAV_INVALID for wrong rate/channels, size cap
- [ ] Structured logs: each session → total latency + whisper latency + inject latency (v0.2), WAV size, source, success/failure
- [ ] `openapi.json` sync check in CI; `web:api-client` runs before `web:build`

### 12.4. Web panel
- [ ] Dashboard/History/Settings responsive at phone width; transcript copy button
- [ ] Polling: active session 1 s → backoff 5 s; stops on page blur; no drift-induced misses
- [ ] Error states readable in the panel: server offline, whisper timeout, inject without permission (v0.2), invalid session
- [ ] HTTPS (`:3000`) via mkcert — panel opens with no trust warning on macOS clients

### 12.5. Pilot validation
- [ ] Latency benchmark §13: documented (3 s/10 s/19 s sentences, stop→transcript)
- [ ] Inject matrix (§8) complete across the 5 apps — with recorded results (v0.2)
- [ ] Clipboard restoration under concurrent user copy
- [ ] Tests: `pytest` server (routes + worker with fake whisper binary fixture), `pytest` inject (mocked macOS), web — Playwright smoke (display flow with fake sessions), `make smoke`: WAV fixture → `curl` upload → transcript out

### 12.6. Repository
- [ ] git init + light CI (GitHub Actions: nx run-many lint/typecheck/test, openapi sync)
- [ ] `.gitignore` (models, db, certs, LittleFS spool fixtures, generated `schema.d.ts` committed or not — pick one and enforce)
- [ ] License + status badge on README

## 13. Benchmarks

Target: **Stop press → transcript visible in the panel**, WAV 16 kHz mono.

| Stage | Budget | Reference |
|---|---|---|
| FINALIZING (WAV header + spool read) | < 200 ms | LittleFS sequential read |
| Upload (LAN, HTTPS) | < 500 ms | ~480 KB per 15 s session |
| whisper.cpp (subprocess, Metal) | ~3.0 s per 19 s phrase | **measured on owner's M4 (2026-11-27)** |
| Server-side bookkeeping (DB + status) | < 50 ms | SQLite insert/update |
| Panel pickup (poll granularity) | ≤ 1 s | 1 s poll while active |
| **End-to-end** | **≤ 4 s after Stop for a ~19 s sentence; ≤ 2 s for short phrases** | v0.1 acceptance gate |

Regression bar: any refactor that pushes a 19 s sentence past 4 s end-to-end fails the benchmark. Streaming (§15 open) would attack the tail (transcript starts before Stop) but is explicitly out of v0.

## 14. Roadmap

### v0.1 — Basic loop (MVP)
- [ ] Nx workspace scaffold (web + server + firmware projects, targets, cache)
- [ ] FastAPI: `POST /api/sessions` + `GET /api/sessions[/{id}]` + `/api/health`; OpenAPI export + openapi-typescript client gen wired
- [ ] whisper.cpp binary worker (subprocess, Metal, queue + recovery) + `scripts/setup-whisper.sh`
- [ ] ESP32 firmware: I2S capture + spool, buttons state machine, ST7735 display UI, WiFi + HTTPS upload w/ retry, provisioning portal
- [ ] Next.js panel: dashboard (session cards + polling, transcript), history, settings; responsive
- [ ] mkcert HTTPS path (`setup-https.sh`, §10)
- [ ] Latency logging + `make smoke` + benchmark pass (§13)

### v0.2 — Inject on desktop
- [ ] `packages/inject` (Python + Swift helper): clipboard + paste + restoration + Accessibility check
- [ ] `mode=inject` in the API + `/api/sessions/{id}/inject`; panel: mode toggle + permission status + inject feedback/errors
- [ ] Error matrices (`WAV_INVALID`, `INJECT_*`) end-to-end through the OpenAPI client
- [ ] Validation Safari/Obsidian/VS Code/Notes/Slack — `docs/inject-matrix.md`
- [ ] Playwright smoke of the inject flow (mocked clipboard/keystroke)

### v0.3 — Polish (optional, feeds pepper)
- [ ] Save-mode UI (SQLite §11 already wired; panel history + delete)
- [ ] PWA (manifest + minimal SW) — optional, only if the panel earns home-screen use
- [ ] SSE for session status (replaces polling) — evaluate vs 1 s poll reality
- [ ] Streaming evaluation: live capture → server (protocol sketch + feasibility, NOT implementation unless proven trivial); decision feeds pepper
- [ ] Pilot report: what migrates to pepper (server-side package extraction, inject as standalone)

## 15. Decisions and open questions

**Decided:**

- [x] Separate codebases from pepper (2026-11-24, still standing) — server-side extracted as a Python package if integrated. Monorepo **internal to lisa**.
- [x] **Monorepo tooling = Nx** (2026-11-27) — replaces pnpm+turborepo workspaces (pnpm remains the node package manager).
- [x] **Services in Python** (2026-11-27) — FastAPI + uv; Python-in-Nx via run-commands delegating to uv (fallback `@nxlv/python`, see open 2).
- [x] **Frontend = Next.js App Router, TS, responsive** (2026-11-27) — replaces PWA-as-client; PWA demoted to optional v0.3.
- [x] **Capture = ESP32 hardware recorder** (2026-11-27) — INMP441 I2S, buttons Record/Pause/Stop, mini display, WiFi. Streaming/live-to-server explicitly NOT in v0 (deferred; open 5).
- [x] **Session-based flow** (2026-11-27): `[Record] → capture 16k mono → [Pause] → [Stop] → WAV → upload → transcript` — no streaming in v0.
- [x] **whisper.cpp called as binary subprocess** (2026-11-27) — drops the whisper-server HTTP process (v2 had `run-whisper.sh` serving `:8081`). Validated 3.0 s/19 s phrase on the owner's M4. Revisit criteria: (a) need for >1 concurrent transcription lane on a second machine, (b) measured subprocess/spawn overhead becomes significant (< ~5% of budget today), (c) pepper requires a shared ASR HTTP service → reintroduce a server mode behind the same API.
- [x] **Two-phase flow** (2026-11-27): v0.1 display-only; v0.2 inject into the focused desktop field (cursor-focused-field flow, §8); the panel remains the control plane.
- [x] **HTTPS = mkcert** (2026-11-27) — Tailscale Serve 501s on the owner's tailnet. **Closes v2 §13 open question 1.**
- [x] Self-hosted server (owner's Mac) runs everything: Python API, whisper.cpp, inject (v0.2), SQLite, Next.js — the "server próprio" premise.
- [x] Audio = PCM 16 kHz mono WAV (inherited); VAD stays out (physical Stop button).
- [x] macOS-first (server + inject) — inherited from v2.

**Open:**

- [ ] **ESP32 display exact model**: which ST7735 variant (green/black tab 160×80? ST7789 240×135 as upgrade?) and driver lib (LovyanGFX vs TFT_eSPI). Decide at display bring-up; §6 choice stands as recommended.
- [ ] **Firmware framework validation**: PlatformIO + Arduino is the pick (dev speed); re-evaluate for ESP-IDF if the Arduino core fights back on I2S DMA timing, display refresh, or later OTA/multi-core needs. Decide after the first mic+display bring-up sprint.
- [ ] **Nx Python approach**: run-commands+uv is the pick; swap to `@nxlv/python` if cache hashing / task deps for Python get painful. Revisit once the `export-openapi → api-client` chain runs in CI.
- [ ] **ESP32 cert handling**: mkcert root CA — bundled in firmware vs provisioned via NVS in the portal; rotation procedure when the CA is regenerated; impact on OTA (if OTA ever lands). Also: exact ESP32-S3 devkit to buy.
- [ ] **Streaming deferral**: live audio → server (no Stop-finalize). Explicitly not v0; roadmap v0.3 only evaluates. Owner may drop it permanently — protocol was designed not to depend on it.
- [ ] Inject on Windows/Linux: pilot or pepper v2 only? (default: macOS only — inherited from v2).

## 16. References

- [Nx](https://nx.dev) — monorepo orchestration (cache, task graph)
- [FastAPI](https://fastapi.tiangolo.com) + [uv](https://docs.astral.sh/uv/) — Python API + project/env management
- [@nxlv/python](https://github.com/lucasvieirasilva/nx-plugins) — community Nx↔Python plugin (fallback, §5)
- [openapi-typescript](https://openapi-ts.dev) / [openapi-fetch](https://openapi-ts.dev/openapi-fetch) — generated typed client (§7.1)
- [Next.js App Router](https://nextjs.org/docs) — panel (§9)
- [whisper.cpp](https://github.com/ggml-org/whisper.cpp) — local ASR (binary subprocess, Metal)
- [INMP441](https://invensense.tdk.com/products/inoic-inmp441/) — I2S digital mic
- [ST7735 / LovyanGFX](https://github.com/lovyan03/LovyanGFX) — mini TFT + display driver
- [PlatformIO](https://platformio.org) / [ESP-IDF](https://developer.espressif.com) — firmware toolchains (pick + fallback, §3/§15)
- [esp_http_client / esp-tls](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/protocols/esp_https_client.html) — HTTPS upload + CA validation on the ESP32
- [mkcert](https://github.com/FiloSottile/mkcert) — local HTTPS certs (decided path)
- [CGEvent / Event Taps](https://developer.apple.com/documentation/coregraphics/cgevent) — keyboard simulation on macOS
- [Whispering (reference style)](https://github.com/braden-w/whispering) — open-source dictation app, model for the inject UX
- pepper.ai — `../pepper-ai/SPEC.md` (inherited decisions, schema, stack)
- lisa SPEC v2 — superseded English spec (pnpm/turborepo, Fastify, PWA capture); §13 open question closed by this doc
