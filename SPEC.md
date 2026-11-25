# lisa — Project Spec

> Test pilot: speak on the smartphone/tablet (web/PWA) → text appears (or is saved) on the computer, in any focused field, in the style of Whispering/WhisperFlow.

## 1. Vision

Test pilot for **pepper.ai**: a web/PWA app that captures the user's voice plus a service on the computer that transcribes and **injects the text into the focused field** (or saves it as a record), all on the local network. Monorepo to share types, protocol and modules between app and server.

**Pilot phases:**

- **v0.1:** PWA records → service transcribes → transcript displayed in the app.
- **v0.2:** text injected into the focused field of the Mac (clipboard + `Cmd+V`).
- **v0.3:** "save as record" mode (mirrors pepper v1's data model).

**What the pilot is NOT:** no login, no full CRUD, no command interpretation (pepper v2). Code that proves itself good migrates to pepper.

## 2. Relationship with pepper.ai

| Topic | pepper.ai | lisa |
|---|---|---|
| Role | Full product (assistant) | Interface/test pilot |
| Codebase | Separate | Separate — **internal monorepo** (§5) |
| Sign-up/JWT | Yes (v1) | No — trusted local network |
| Saved records | Yes (core of v1) | Only in v0.3, mirroring the schema |
| Text inject on desktop | No (focus: app + API) | **Yes — the central challenge** |
| ASR | whisper.cpp `large-v3-turbo` | Same model |
| Client | React Native | Web/PWA (for now; RN may come back in pepper) |

If lisa becomes a pepper module: what migrates is the server-side (listener + inject), extracted as a package — the monorepo structure (`packages/*`) is already prepared for it.

## 3. Technical decisions

| Decision | Choice | Reason |
|---|---|---|
| ASR | **whisper.cpp `large-v3-turbo`** | Decision confirmed in pepper (WER ~3.8% PT-BR, Metal). Same installation. |
| Audio | **PCM 16kHz mono WAV** via AudioWorklet | Float32 capture in the browser → downsample to 16k → WAV encode. Same format as pepper's pipeline. |
| Client | **Web app / PWA** (Vite + React 18 + TS) | Direct entry: no store, no native build. Mic permission via getUserMedia. Installable on the tablet/phone home (manifest + minimal SW). |
| Server | Node 20+ (Fastify) + whisper-server (`POST /inference`) | Reuses pepper's pipeline; couples little. |
| Monorepo | **pnpm workspaces + Turborepo**, TypeScript everywhere | Types/protocol sharing app↔server via `packages/shared`; parallel/cached build. |
| Text inject (macOS) | **1st: clipboard + simulated `Cmd+V`** (CGEvent via native helper / AppleScript); restores the previous clipboard | Paste is reliable in any field and fast; char-by-char typing is inconsistent across apps. Requires the Accessibility permission. |
| Inject fallback | AppleScript `keystroke` type-as-you-type | For fields that ignore paste; slow, only when paste fails. |
| Transport | **HTTPS on the LAN** (Tailscale Serve OR mkcert/self-signed) | `getUserMedia` requires a secure context — plain HTTP on a LAN IP is blocked by the browser on mobile. |
| Save mode (v0.3) | SQLite (`better-sqlite3`), schema mirrored from pepper | Trivial migration. |
| VAD (v1) | No — manual stop button | Silero comes in as polish (same roadmap as pepper). |
| Target OS | macOS (listener + inject). Client: iOS Safari and Android Chrome | Text inject varies by OS — macOS only in the pilot. |

## 4. Architecture

```
┌─ PWA (smartphone/tablet) ────────┐        ┌─ Mac with whisper ──────────────────────────┐
│                                  │ HTTPS  │                                            │
│  host address config             │───────→│  lisa-listener :8080 (Fastify, HTTPS)      │
│  mic → AudioWorklet              │  WAV   │   ├─ validates WAV, calls POST /inference  │
│  downsample 48k→16k mono         │  body  │   ├─ whisper-server :8081 (large-v3-turbo) │
│  encode WAV                      │        │   ├─ INJECT mode:                          │
│  record/stop button              │←───────│   │    clipboard ← text                    │
│  mode: inject/save/display       │ {text} │   │    simulated Cmd+V in the focused app  │
│  transcript preview + status     │        │   │    restores clipboard (~400ms delay)   │
│                                  │        │   └─ SAVE mode: INSERT into transcriptions │
└──────────────────────────────────┘        └────────────────────────────────────────────┘
```

- The PWA talks **only to the lisa-listener** (:8080). The listener orchestrates the whisper-server (:8081).
- Same topology as pepper (app → API :8080 → whisper :8081) — validated on a single host, with no sign-up.

## 5. Monorepo

```
lisa/
├── pnpm-workspace.yaml
├── turbo.json
├── package.json                 # root scripts: dev, build, lint, typecheck, test, e2e
├── .env.example
├── Makefile                     # one-shot setup (§11.1)
├── apps/
│   ├── listener/                # Fastify :8080 — API, orchestrates whisper, inject, persistence
│   │   └── src/
│   │       ├── routes/dictate.ts, notes.ts, health.ts
│   │       ├── whisper/client.ts
│   │       ├── inject/          # macOS: clipboard.ts, keyevent.ts (osascript/CGEvent), fallback.ts
│   │       ├── db/              # SQLite (v0.3)
│   │       └── config.ts        # env via zod
│   └── web/                     # PWA — Vite + React
│       ├── public/manifest.webmanifest, icons/, sw.js
│       └── src/
│           ├── audio/worklet.ts (downsample), wav.ts (encoder), recorder.ts
│           ├── screens/Gravar.tsx
│           ├── api/dictate.ts
│           └── settings.ts      # host address (localStorage)
├── packages/
│   ├── shared/                  # protocol types, zod schema, constants (API versioning)
│   │   └── src/protocol.ts, types.ts, errors.ts
│   ├── inject/                  # pure inject helper (CLI + lib) — the package that migrates to pepper
│   │   └── src/clipboard.ts, paste.ts, detect-permissions.ts
│   └── audio/                   # WAV encoder + downsample + validation (used by web and listener)
│       └── src/wav.ts, validate.ts
├── scripts/
│   ├── setup-whisper.sh         # downloads/builds whisper.cpp + large-v3-turbo model
│   ├── run-whisper.sh           # starts the whisper-server on :8081 with Metal
│   └── setup-https.sh           # mkcert OR Tailscale Serve
└── tests/
    ├── listener/ (vitest)
    ├── packages/ (vitest)
    └── e2e/ (Playwright — against the PWA on desktop; simulated mic)
```

Rules:

- `apps/*` depend on `packages/*`, never the other way around.
- The app↔server contract lives **only** in `packages/shared` (`protocol.ts`) — no duplicated types.
- `packages/inject` knows nothing about Express/Fastify — pure lib + CLI (`lisa-inject "text"`), so it can ship as a pepper module.

## 6. Protocol (packages/shared)

```ts
// POST /api/dictate — multipart: { audio: WAV file } + X-Lisa-Mode: inject | save | display
type DictateResponse =
  | { ok: true; mode: 'display' | 'save'; text: string; id?: string }
  | { ok: true; mode: 'inject'; injected: boolean; text: string; detail?: string }
  | { ok: false; error: LisaError }
```

- No auth. `Z-Lisa-Client` header for simple telemetry (`web/1.0`).
- Typed errors in `packages/shared/errors.ts`: `WAV_INVALID`, `WHISPER_DOWN`, `INJECT_NO_PERMISSION`, `INJECT_FAILED`, `DB_ERROR`.
- Versioning: `protocol` field in `/api/health` (int) — if it diverges from what the client expects (constant in shared), the PWA shows an "update the listener" banner.

## 7. PWA

### 7.1. Stack

- Vite + React 18 + TypeScript
- Audio: `getUserMedia` + **AudioWorklet** (not ScriptProcessor — deprecated) → Float32 → downsample → WAV from `packages/audio`
- HTTP: `fetch` with binary WAV upload (Content-Type `audio/wav`)
- PWA: `manifest.webmanifest` (icons, standalone, free orientation) + minimal service worker (app shell cache — recording doesn't work offline anyway)
- Settings persisted in `localStorage` (host address, default mode)

### 7.2. Screens

1. **Record** (single screen):
   - big mic button (record/stop), recording indicator (pulse + timer)
   - mode toggle: **Inject** / **Save** / **Display only**
   - transcript preview + round-trip status (`recording → uploading → transcribing → delivered/error`)
   - last-request log (latency, WAV size) — pilot telemetry
2. **Settings** (sheet/route): host address, connectivity test (`/api/health`), default mode
3. No login, no list, no sign-up.

### 7.3. Flow (Inject mode)

```
[mic button] → getUserMedia + AudioWorklet → Float32 buffer
[stop] → encode WAV 16k mono → POST /api/dictate (X-Lisa-Mode: inject)
listener → whisper-server → {text}
  inject → clipboard ← text; Cmd+V in the focused app; restores clipboard
PWA receives {injected: true} → "text delivered" feedback + latency
```

### 7.4. Secure context (usage prerequisite)

`getUserMedia` requires HTTPS. Options (automated setup in `scripts/setup-https.sh`):

1. **Tailscale Serve** (preferred if Tailscale is already installed): `tailscale serve https / https://localhost:8080` — valid cert automatically, accessible via the tailnet hostname.
2. **mkcert** + Node/Fastify `--https`: install the local CA on the device. For tablets/phones: export `rootCA.pem`, install as a profile/trust on iOS/Android.

The PWA blocks recording over plain HTTP — the screen shows setup instructions when `!window.isSecureContext && origin is not localhost`.

## 8. Text inject (macOS)

- Isolated helper in `packages/inject`. Sequence of the inject mode:
  1. capture + save the current clipboard (with timestamp)
  2. write the transcript to the clipboard (`pbcopy` via spawn or NSPasteboard wrapper)
  3. send `Cmd+V` — order of preference: native Swift helper compiled at setup (`CGEventPost`) → AppleScript `System Events keystroke 'v' using command down`
  4. delay 300–500ms → restore the previous clipboard (if the user hasn't made a new copy in that interval)
- Permissions: **Accessibility** for the listener process (System Settings → Privacy → Accessibility). `/api/health` runs a real check (inject + undo of a character in a testable field) and reports `inject: ok | no_permission | failed`.
- Edge cases measured in the pilot (matrix in `docs/inject-matrix.md`): apps that block paste (some Electron apps with custom fields), copy race during inject, sandboxed apps. `keystroke` type-as-you-type fallback configurable per flag in the request (`x-lisa-inject-strategy: paste | type`).
- Validation in: Safari, Obsidian, VS Code, Notes, Slack.

## 9. Data model (save mode only, v0.3)

```sql
transcriptions (
  id         TEXT PK,                  -- UUID
  title      TEXT NOT NULL,            -- derived from the first sentence
  text       TEXT NOT NULL,
  audio_size INTEGER NOT NULL,          -- WAV bytes, for latency debugging
  source     TEXT DEFAULT 'dictation', -- distinguishes from a future pepper record
  created_at TEXT NOT NULL DEFAULT now()
)
```

DB: SQLite at `~/Library/Application Support/lisa/lisa.db` (not in the repo). Fields mirrored from pepper, minus `user_id` — migration: copy + fill `user_id`.

## 10. Security

- HTTPS on the LAN via Tailscale Serve or a local cert (§7.4) — required for secure context, not just for the mic permission: it also encrypts the audio.
- No auth — trusted local network premise, like pepper's sign-up-free model (§6 of it). If it leaves the LAN via Tailscale, the tailnet acts as an access control layer.
- Accessibility permission for the listener = least privilege; the listener is a dev tool running for the user, not a system daemon.
- `packages/inject` never sends third-party keystrokes — only the transcript, and it restores the clipboard.
- Sanitization: the transcript goes to the clipboard (no shell execution) — no audio data passes through any external process other than the local whisper.

## 11. "Ready to use" checklist

Criterion: a new machine + tablet configured from zero in < 30 min, with no undocumented manual steps.

### 11.1. Setup and DX
- [ ] `make setup` — root: installs pnpm deps, compiles the Swift inject helper, runs `scripts/setup-whisper.sh` (whisper.cpp + large-v3-turbo model with Metal), runs `scripts/setup-https.sh`
- [ ] Complete `.env.example` + `config.ts` with zod (listener: port, whisper db/model path, default inject mode, secret of nothing — no secrets)
- [ ] `make dev` (turbo: web + listener + whisper-server), `make build`, `make lint`, `make typecheck`, `make test`
- [ ] README per app + root, `docs/setup.md` step-by-step doc with screenshots of the permissions (Accessibility, mic on iOS/Android)

### 11.2. Operation
- [ ] Complete `/api/health`: whisper available (ping on :8081), inject permission (real check), DB, model path version, `protocol` version
- [ ] Error states handled with readable messages in the app: whisper down, invalid WAV, inject without permission, unreachable host (timeout)
- [ ] Structured logs (pino): each dictate → total latency + whisper latency + inject latency, WAV size, mode, success/failure
- [ ] Listener restarts the whisper-server if the ping fails (light supervision, `spawn` with backoff)

### 11.3. Client
- [ ] Installable PWA (manifest + icons + SW) — tested "add to home" on iOS and Android
- [ ] Inline instruction on the screen when the secure context is missing (§7.4)
- [ ] Reconnection: if the host is offline, a button re-tests `/api/health`; recording aborts with a message instead of accumulating buffers
- [ ] Accessibility: mic button with minimum 48px touch area, works in landscape orientation

### 11.4. Pilot validation
- [ ] Documented latency benchmark: speech→text on screen for sentences of 3s/10s/20s (target: < 2s on stop, ~15s sentence)
- [ ] Inject matrix (§8) complete across the 5 apps — with recorded results
- [ ] Clipboard restoration works under concurrent user copy
- [ ] Tests: unit (packages/audio WAV encode golden files, packages/inject with mocked macOS), e2e Playwright (display mode flow with fake whisper-server), smoke script `make smoke` (real end-to-end with a WAV fixture via `curl`)

### 11.5. Repository
- [ ] git init + light CI (GitHub Actions: typecheck + lint + test on PR)
- [ ] `.gitignore` (models, db, certs, temporary recordings)
- [ ] License + status badge on the README

## 12. Roadmap

### v0.1 — Basic loop (MVP)
- [ ] Monorepo scaffold (pnpm + turbo + `packages/shared` + `packages/audio`)
- [ ] whisper-server running with `large-v3-turbo` (Metal) — setup script
- [ ] lisa-listener: `/api/dictate` + `/api/health` → whisper → `{text}`
- [ ] PWA: AudioWorklet → WAV 16k mono, upload, display transcript
- [ ] HTTPS via Tailscale Serve or mkcert (§7.4)
- [ ] Latency logging + `make smoke`

### v0.2 — Inject on desktop
- [ ] `packages/inject`: clipboard + paste + restoration + Accessibility permission
- [ ] Inject mode in the PWA + protocol error matrices
- [ ] Validation Safari/Obsidian/VS Code/Notes/Slack — `docs/inject-matrix.md`
- [ ] e2e Playwright of display mode

### v0.3 — Save mode
- [ ] SQLite + schema mirrored from pepper (§9)
- [ ] `/api/notes` routes (GET list, DELETE)
- [ ] Save mode toggle + in-app feedback

### v0.4 — Polish (optional, feeds pepper)
- [ ] VAD (Silero) in the browser — goes into pepper's v1.x roadmap
- [ ] `keystroke` type-as-you-type fallback tested
- [ ] Pilot report: what migrated/decided for pepper + extraction of `packages/inject` as a standalone module

## 13. Decisions and open questions

**Decided:**

- [x] Separate codebases from pepper (2026-11-24) — if integrated, `packages/inject` + listener migrate as a server-side module/package. Monorepo **internal to lisa** to share types/protocol between app and server.
- [x] Audio input = **web/PWA** (2026-11-24, replaces the original RN app) — AudioWorklet + WAV; RN only comes back if pepper decisions require it.
- [x] macOS first (listener + inject); client: iOS Safari and Android Chrome.

**Open:**

- [ ] HTTPS transport: Tailscale Serve vs mkcert+CA on the device — decide when running `setup-https.sh` on the real machine.
- [ ] Inject on Windows/Linux: enters the pilot or only pepper v2? (default: macOS only)

## 14. References

- [Whispering (reference style)](https://github.com/braden-w/whispering) — open-source dictation app, model for the inject UX
- [whisper.cpp](https://github.com/ggml-org/whisper.cpp) — local ASR, server mode
- [CGEvent / Event Taps](https://developer.apple.com/documentation/coregraphics/cgevent) — keyboard simulation on macOS
- [AudioWorklet](https://developer.mozilla.org/en-US/docs/Web/API/AudioWorklet) — audio capture in the browser
- [Tailscale Serve](https://tailscale.com/kb/1242/tailscale-serve) — valid HTTPS on the LAN/tailnet
- pepper.ai — `../pepper-ai/SPEC.md` (inherited decisions, schema, stack)
