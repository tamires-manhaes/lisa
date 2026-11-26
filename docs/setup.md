# lisa — setup from a fresh machine

Goal (SPEC §11.1): Mac + phone/tablet configured from zero in **< 30 min, with no undocumented manual steps**. This doc is the complete walkthrough — if a step is missing here, that is a bug: report it in an issue.

Tested path: macOS (Apple Silicon). The client is tested on iOS Safari and Android Chrome.

---

## 1. Prerequisites

| Tool | Check with | Install |
|---|---|---|
| Node ≥ 20 | `node --version` | `brew install node` (or nvm/fnm — 20+ is fine) |
| pnpm ≥ 10 | `pnpm --version` | `corepack enable && corepack prepare pnpm@latest --activate` (repo pins `pnpm@10` in `package.json`) |
| Xcode Command Line Tools | `xcode-select -p` | `xcode-select --install` (needed by git, cmake and the later Swift helper) |
| Homebrew | `brew --version` | [brew.sh](https://brew.sh) |
| cmake | `cmake --version` | `brew install cmake` — builds whisper.cpp |
| mkcert | `mkcert -version` | `brew install mkcert` — HTTPS fallback path |
| Tailscale (optional) | `tailscale version` | `brew install tailscale` then `tailscale up` — preferred HTTPS path if you use a tailnet |

Notes:

- `make` itself ships with macOS (install the Command Line Tools first if `make: command not found`).
- The whisper build downloads ~100 MB of source and the model is **~1.6 GB** — disk space matters more than CPU.
- Everything is stored and runs **locally**; the only network traffic is cloning whisper.cpp, downloading the model from Hugging Face and LAN/tailnet traffic between the tablet and your Mac (SPEC §10).

## 2. Clone and run `make setup`

```sh
git clone https://github.com/tamires-manhaes/lisa && cd lisa
make setup
```

`make setup` runs four steps, in this order. It is **safe to re-run** — existing artifacts are detected and skipped:

1. **`pnpm install`** — workspace dependencies (`apps/*`, `packages/*`). Fast after the first run; nothing interactive.
2. **Inject Swift helper** — *reserved placeholder for now.* The native `CGEventPost` helper (SPEC §8) is built in the inject slice — `make setup` prints this instead of compiling anything. The step is already wired so later slices only replace the echo with the real build.
3. **`scripts/setup-whisper.sh`** — three sub-steps, each skipped when its artifact exists:
   - shallow-clone `whisper.cpp` into `./whisper.cpp/` (skipped if already cloned);
   - build `whisper-server` with Metal (`cmake -DGGML_METAL=ON`) into `./whisper.cpp/build/bin/` (skipped if the binary already exists — no forced rebuild);
   - download `ggml-large-v3-turbo.bin` into `./modelos/` (skipped if present; `curl -C -` resumes a partial download).
   - The script prints the model path at the end — you need it for `.env`. To use a smaller model, re-run with `LISA_MODEL_FILE=ggml-large-v3-turbo-q8_0.bin make whisper`.
4. **`scripts/setup-https.sh`** — provisions HTTPS (required because the **mic only works on a secure context**). Autodetect, in this order:
   - **Tailscale Serve** (if `tailscale` is installed *and connected*): configures `tailscale serve` so `https://<node>.<tailnet>.ts.net` → `127.0.0.1:8080`. Valid cert, zero CA install on the desktop; the phone needs to be on the same tailnet. Undo later with `tailscale serve reset`.
   - **mkcert** (fallback): installs the local CA into the macOS trust store (**asks for your admin password** — this is the only password prompt in the whole setup) and emits `certs/listener*.pem` + `certs/rootCA.pem` (gitignored). If no admin password is entered, the cert is still created; the CA must then be trusted manually (§4).
   - Autodetect detail: if `tailscale serve` fails after being autodetected (some control planes return 501 for HTTPS cert issuance — self-hosted forks), the script warns and **falls back to mkcert automatically** instead of aborting; forcing the mode with `--tailscale` makes the failure fatal.
   - Force a mode explicitly: `scripts/setup-https.sh --tailscale` or `--mkcert` (or `make https`); `--reset` removes the tailscale serve config.

If you want to skip HTTPS entirely for desktop-only testing against `localhost`, it is safe for now — but the phone/tablet flow of this pilot requires it (SPEC §7.4).

## 3. Configure `.env` and run

```sh
cp .env.example .env
# set WHISPER_MODEL_PATH to the path printed by setup-whisper.sh
#   (default: <repo>/modelos/ggml-large-v3-turbo.bin)
```

All other vars have defaults (see `.env.example`) — the only required one is `WHISPER_MODEL_PATH` (env config is validated with zod; the listener fails fast without it).

Two terminals (whisper is a separate long-running server):

```sh
# terminal 1 — whisper-server on 127.0.0.1:8081 (Metal, PT-BR) — leave it running
scripts/run-whisper.sh

# terminal 2 — listener (:8080) + web dev server
make dev
```

Open the `https://` URL on the phone/tablet (§4). On the desktop, `http://localhost:5173` (Vite) also works for quick checks — `localhost` counts as a secure context, so the mic is available there too.

Check: `curl http://127.0.0.1:8080/api/health` → `{"ok":true,...}` and the whisper ping reports available.

## 4. Permissions (the documented manual steps)

### 4.1 Accessibility — inject mode on macOS

The process that simulates `Cmd+V` needs the **Accessibility** permission (SPEC §8). macOS only shows the app on prompt-time in later slices; for now, add the terminal/node binary proactively:

1. System Settings → **Privacy & Security** → **Accessibility**.
2. Unlock the pane with your password (Touch ID), press **`+`**.
3. Add the app that runs the listener (e.g. **Terminal** or **iTerm**, or `node` under `/opt/homebrew/bin/` — same binary the listener runs from).
4. Toggle it on.

<!-- TODO: screenshot — System Settings → Privacy & Security → Accessibility pane, with the + button visible. Drop as docs/img/accessibility.png and replace this comment with ![Accessibility permission](img/accessibility.png). macOS 26 path: System Settings → Privacy & Security → Accessibility; the toggle list shows apps allowed to control the computer. -->

Without it, inject mode fails with `INJECT_NO_PERMISSION` — that is the expected, readable error, not a crash.

### 4.2 Microphone — iOS (Safari)

The browser asks on first record — accept it. If you previously denied it:

1. iOS **Settings** → Apps → **Safari** → **Microphone** → allow (or **Settings → Safari → Microphone** on older iOS).
2. Reload the PWA and grant the in-browser prompt.

<!-- TODO: screenshot — iOS Settings → Safari → Microphone (green ON) and/or the Safari mic prompt ("Allow '…' to access the microphone?"). Drop as docs/img/mic-ios.png. -->

Home screen install (PWA): Safari → Share → **Add to Home Screen**. It then runs fullscreen like an app.

### 4.3 Microphone — Android (Chrome)

First record triggers the prompt — choose **While using the app**. If previously denied: **Settings → Apps → Chrome → Permissions → Microphone** → allow, then reload the page.

<!-- TODO: screenshot — Android Chrome's mic permission dialog and/or Settings → Apps → Chrome → Permissions → Microphone. Drop as docs/img/mic-android.png. -->

### 4.4 mkcert CA on the tablet (only on the mkcert path)

Skip this section entirely if you went the **Tailscale Serve** path — the cert is valid automatically.

On the mkcert path, the tablet needs to trust the local CA once (`certs/rootCA.pem`, printed at the end of `setup-https.sh`):

**iOS / iPadOS (Safari):**

1. Send `certs/rootCA.pem` to the device (AirDrop/email) and tap it.
2. Settings → **Profile Downloaded** → Install (passcode) → confirm.
3. Settings → General → **About → Certificate Trust Settings** → enable full trust for `mkcert <user>` CA. (Without this step Safari still shows a warning.)

**Android (Chrome):**

1. Copy `certs/rootCA.pem` to device storage.
2. Settings → Security → **Encryption & credentials** → **Install a certificate** → CA certificate → pick `rootCA.pem` (set a lock-screen PIN if asked).
3. Reload the PWA — user CAs are trusted by browsers over HTTPS. (Chrome may show a lock with a warning badge; the page still loads as a secure context.)

Verification: open the HTTPS URL on the device → recording works and, in the browser console, `window.isSecureContext === true`.

## 5. First-run acceptance checklist

- [ ] `make setup` finished with no error (and re-runs with "skipping" messages)
- [ ] `scripts/run-whisper.sh` loads the model (Metal active in the log)
- [ ] `make dev` serves the PWA; `curl http://127.0.0.1:8080/api/health` is ok
- [ ] Tablet opens the HTTPS URL with no blocking warning
- [ ] Mic permission granted (§4.2/§4.3); record → transcript appears (display mode)
- [ ] Later (inject slice): transcript is typed into a focused field with Accessibility granted (§4.1)

Anything that required a step not in this doc → file an issue referencing SPEC §11.1.
