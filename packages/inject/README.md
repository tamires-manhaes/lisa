# packages/inject — text injection on macOS

Pure inject library + CLI (`lisa-inject`) — **no framework code** (nothing Fastify/Express touches this package). Sequence (SPEC §8): snapshot the clipboard → write the transcript → paste (`Cmd+V`) → restore the previous clipboard after the settle delay. This is the central challenge of the pilot.

- `src/clipboard.ts` — `captureClipboard` / `writeClipboard` / `restoreClipboard` (via `pbcopy`/`pbpaste`, safe spawn)
- `src/paste.ts` — `paste(strategy)`: `paste` (clipboard + `Cmd+V`) with a `type` (AppleScript `keystroke`, char-by-char) fallback for fields that block paste
- `src/detect-permissions.ts` — Accessibility probe feeding `GET /api/health` (`inject: ok | no_permission | failed`)
- `src/cli.ts` — `lisa-inject "text"` bin (declared in `package.json`, wired in the inject slice)

## Permission required

The process sending keystrokes needs **Accessibility** — System Settings → Privacy & Security → Accessibility (grant steps and how to verify in [`docs/setup.md`](../../docs/setup.md)). Only the transcript is ever sent; no other keys are simulated, and the clipboard is restored.

## Run / test

From the repo root:

```sh
pnpm --filter @lisa/inject build
pnpm --filter @lisa/inject test      # vitest, macOS mocked
pnpm --filter @lisa/inject typecheck
pnpm --filter @lisa/inject lint
```

macOS only (CGEvent/osascript). The listener imports this package — it knows nothing about HTTP by design.

## This package migrates to pepper

The whole point of keeping this package pure: when the pilot passes (SPEC §2, §13), **lisa does not become pepper's codebase** — the server side migrates. `packages/inject` + the listener are extracted as a **pepper.ai server-side module/package**; the monorepo layout (`packages/*`, no framework coupling, protocol isolated in `packages/shared`) exists precisely to make that extraction trivial. Decided: separate codebases (2026-11-24, SPEC §13) — inject keeps working unchanged inside pepper, with pepper's auth/record model layered above it, not baked into it.
