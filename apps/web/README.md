# apps/web — lisa PWA

Vite + React single screen: big mic button, mode toggle (**Inject** / **Save** / **Display only**), transcript preview and round-trip status. Captures audio via `getUserMedia` + AudioWorklet, downsamples 48k→16k mono and encodes WAV (via `@lisa/audio`), then `POST`s it to the listener (SPEC §7).

Installable on the phone/tablet home screen (manifest + service worker land with the PWA slices). No login; the server address is kept in `localStorage` — no `.env` needed on this app.

## Prerequisite: secure context

Browsers only grant **mic permission** over HTTPS (`window.isSecureContext`). Plain `http://` on a LAN IP is blocked on mobile. Run `scripts/setup-https.sh` (Tailscale Serve, or mkcert + CA install on the device — steps printed by the script and in [`docs/setup.md`](../../docs/setup.md)), then open the `https://` address it prints on the tablet.

## Run

From the repo root:

```sh
pnpm --filter @lisa/web dev       # Vite dev server (desktop testing)
pnpm --filter @lisa/web build     # production bundle in dist/
pnpm --filter @lisa/web preview   # serve the build
```

For phone/tablet use, open the `https://` URL provided by `scripts/setup-https.sh` (Tailscale Serve hostname or mkcert LAN IP), not a `localhost` dev URL — the mic only works on a secure context reachable from the device.

It talks only to `@lisa/listener`; response shapes come from `@lisa/shared`.

## Tests / checks

```sh
pnpm --filter @lisa/web test        # vitest
pnpm --filter @lisa/web typecheck
pnpm --filter @lisa/web lint
```
