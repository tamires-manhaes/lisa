# apps/listener — lisa-listener

Fastify service on `:8080` — the orchestrator of the pilot (SPEC §4): receives the WAV from the PWA, calls the whisper-server, and routes the result to its destination (**inject** on macOS, **save** (SQLite, v0.3), or **display**). No auth — trusted LAN dev tool; nothing leaves the machine except the local whisper call.

Routes live in `src/app.ts`; env config is validated with zod in [`src/config.ts`](src/config.ts).

## Environment variables

All optional-with-defaults except `WHISPER_MODEL_PATH`. `.env` is read from the repo root (dotenv walks up from the cwd; real env vars win — `run-whisper.sh` and `setup-https.sh` print the values to copy there). See [`.env.example`](../../.env.example).

| Var | Default | Notes |
|---|---|---|
| `PORT` | `8080` | Listener port — change only if taken |
| `WHISPER_URL` | `http://127.0.0.1:8081` | whisper-server from `scripts/run-whisper.sh`. Change only if it runs on another host/port |
| `WHISPER_MODEL_PATH` | — (**required**) | Path to the `.bin` model downloaded by `scripts/setup-whisper.sh` |
| `LISA_DB_PATH` | `~/Library/Application Support/lisa/lisa.db` | SQLite file (save mode, v0.3) |
| `INJECT_STRATEGY` | `paste` | Default strategy when the request has no `x-lisa-inject-strategy` flag (`paste` \| `type`, SPEC §8) |

## Run

From the repo root (whisper must already be built/model downloaded — `make setup`):

```sh
scripts/run-whisper.sh   # whisper-server on :8081, Metal, PT-BR — leave it running
pnpm --filter @lisa/listener dev    # tsx watch — auto-reload
pnpm --filter @lisa/listener start  # production: node dist/index.js
```

Endpoints: `POST /api/dictate` (multipart WAV + `X-Lisa-Mode`), `GET /api/health` (whisper reachability + protocol version). Protocol shapes come from `@lisa/shared` (`packages/shared`) — the single source of truth.

## Tests / checks

```sh
pnpm --filter @lisa/listener test        # vitest
pnpm --filter @lisa/listener typecheck
pnpm --filter @lisa/listener lint
```
