#!/usr/bin/env bash
# setup-https.sh — secure context for getUserMedia (SPEC §7.4).
#
# Two paths:
#   --tailscale  preferred: tailscale serve proxies the local HTTP listener as
#                HTTPS on the tailnet hostname with an automatic valid cert.
#   --mkcert     fallback: local CA + localhost/LAN-IP cert, emitted to certs/
#                (gitignored) for the listener HTTPS wiring (later slice), with
#                the CA exported to certs/rootCA.pem for device install.
#
# Default: autodetect tailscale, fall back to mkcert.
#
# Note on listener wiring: this script only provisions the cert/URL. The
# listener itself boots on :8080 (HTTP) and gains HTTPS when certs are present
# in a later slice (SPEC §6) — the printed env vars are what it will consume.
#
# CLI syntax note (tailscale >= 1.52, per kb/1242): the old
#   `tailscale serve https / https://localhost:8080`
# form is gone. Current form is a bare target:
#   `tailscale serve --bg 8080`  → https://<node>.<tailnet> proxies to 127.0.0.1:8080
set -euo pipefail

PORT="${PORT:-8080}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CERTS_DIR="${REPO_ROOT}/certs"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--tailscale | --mkcert] [--reset]

  --tailscale   Configure tailscale serve (HTTPS via tailnet hostname).
  --mkcert      Local CA + cert for listener HTTPS (mkcert path).
  --reset       Remove the tailscale serve config (tailscale serve reset).
  (default with no mode flag: tailscale if installed/running, else mkcert)

Env: PORT (default 8080 — listener port, SPEC §6).
EOF
}

log()  { printf '\033[1;36m[setup-https]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[setup-https]\033[0m %s\n' "$*" >&2; }
die()  { warn "$*"; exit 1; }

tailscale_running() {
  command -v tailscale >/dev/null 2>&1 || return 1
  tailscale status >/dev/null 2>&1 || return 1
  return 0
}

tailscale_mode() {
  command -v tailscale >/dev/null 2>&1 \
    || die "tailscale not installed. Preferred path (SPEC §7.4). Install: brew install tailscale && tailscale up (login required)."

  tailscale_running \
    || die "tailscale installed but tailscaled is not connected. Run: 'tailscale up' (or open macOS app and log in), then retry."

  # Serve the local HTTP listener as HTTPS on the tailnet (automatic cert).
  # Needs the control plane to vouch HTTPS certs for this node — some custom
  # forks return 501 (Not implemented) for the feature.
  local serve_err
  if ! serve_err="$(tailscale serve --bg "${PORT}" 2>&1)"; then
    # Autodetected path: fall back to mkcert instead of aborting the whole
    # `make setup` (issue #21/#22). An explicit --tailscale invocation still
    # dies loudly below (no fallback allowed).
    if [[ "${TS_FALLBACK:-0}" -eq 1 ]]; then
      warn "tailscale serve failed — falling back to mkcert. Set --tailscale to make this fatal. Error: ${serve_err}"
      mkcert_mode
      return
    fi
    die "tailscale serve failed: ${serve_err}
  (Control plane may not implement HTTPS cert issuance for this node — custom/self-hosted forks sometimes do not. Fall back: $0 --mkcert)"
  fi

  # <node>.<tailnet>.ts.net — Self.DNSName, strip the trailing dot.
  local host url
  host="$(tailscale status --json | python3 -c 'import json,sys; print(json.load(sys.stdin)["Self"]["DNSName"].rstrip("."))')"
  url="https://${host}"

  log "tailscale serve configured: https://${host} (port 443 → 127.0.0.1:${PORT})"
  log
  log "Open on the phone/tablet (same tailnet): ${url}"
  log "Acceptance: page must load without warning and window.isSecureContext === true"
  log
  log "To undo later: tailscale serve reset"
}

tailscale_reset_mode() {
  command -v tailscale >/dev/null 2>&1 \
    || die "tailscale not installed — nothing to reset."
  tailscale serve reset
  log "tailscale serve config removed (tailnet connection untouched)."
}

lan_ip() {
  # macOS first (primary wifi/en NICs), then a generic Linux fallback.
  if command -v ipconfig >/dev/null 2>&1; then
    ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || true
  else
    ip -4 addr show scope global 2>/dev/null \
      | awk '/inet /{print $2; exit}' | cut -d/ -f1 || true
  fi
}

mkcert_mode() {
  command -v mkcert >/dev/null 2>&1 \
    || die "mkcert not installed. Install: brew install mkcert (then re-run; 'mkcert -install' is done by this script)."

  # Install the local CA into the system/browser trust stores on this machine
  # (sudo password prompt on macOS). Non-fatal: cert generation below works
  # anyway; without this step desktop Safari/Chrome show warnings until the
  # CA is trusted manually.
  log "Installing local CA into the macOS trust store (may ask for your password)..."
  local err
  if ! err="$(mkcert -install 2>&1)"; then
    warn "mkcert -install failed (needs sudo/admin): ${err}"
    warn "CA is created but not trusted on this machine. Run 'sudo mkcert -install' manually, or install certs/rootCA.pem on the device (steps printed below)."
  fi

  mkdir -p "${CERTS_DIR}"

  local lan hosts
  lan="$(lan_ip)"
  hosts=(localhost 127.0.0.1 ::1)
  if [[ -n "${lan}" ]]; then
    hosts+=("${lan}")
    log "LAN IP included in the cert: ${lan}"
  else
    warn "No LAN IP found on en0/en1 — cert covers localhost/127.0.0.1/::1 only. Phone access will need to re-run this on a network with a routable IP."
  fi

  # -p12-file only sets the path; -pkcs12 is what triggers the bundle (for
  # keystore-style consumers). Without it mkcert silently skips the p12.
  mkcert \
    -cert-file "${CERTS_DIR}/listener.pem" \
    -key-file "${CERTS_DIR}/listener-key.pem" \
    -pkcs12 \
    -p12-file "${CERTS_DIR}/listener.p12" \
    "${hosts[@]}"

  local caroot
  caroot="$(mkcert -CAROOT)"
  cp "${caroot}/rootCA.pem" "${CERTS_DIR}/rootCA.pem"
  chmod 644 "${CERTS_DIR}/rootCA.pem"

  log
  log "Files written (gitignored):"
  log "  ${CERTS_DIR}/listener.pem    cert the listener will mount"
  log "  ${CERTS_DIR}/listener-key.pem    key (listener wiring = later slice, SPEC §6)"
  log "  ${CERTS_DIR}/listener.p12    PKCS#12 bundle"
  log "  ${CERTS_DIR}/rootCA.pem    local CA to install on the device"
  log
  log "Once the listener mounts TLS (later slice), start it with:"
  log "  LISTENER_TLS_CERT=${CERTS_DIR}/listener.pem LISTENER_TLS_KEY=${CERTS_DIR}/listener-key.pem"
  log
  log "Device install — iOS/iPadOS (Safari):"
  log "  1. Send ${CERTS_DIR}/rootCA.pem to the device (AirDrop/email) and tap it."
  log "  2. Settings → Profile Downloaded → Install (passcode) → confirm."
  log "  3. Settings → General → About → Certificate Trust Settings → enable full trust for 'mkcert <user>' CA."
  log "     (Without step 3 Safari still warns.)"
  log
  log "Device install — Android:"
  log "  1. Copy ${CERTS_DIR}/rootCA.pem to the device storage."
  log "  2. Settings → Security → Encryption & credentials → Install a certificate → CA certificate → pick rootCA.pem (set a lock-screen PIN if asked)."
  log "  3. Reload the PWA in Chrome/Firefox — user CAs are trusted by browsers over HTTPS."
  log
  warn "Android note: since 7.0, native apps do NOT trust user CAs by default — fine for the browser/PWA path, insufficient for native WebView apps."
  warn "Chrome may show a lock with a warning badge; the page still loads as a secure context (window.isSecureContext === true)."
  log
  log "Acceptance: open https://<this-machine-LAN-IP>:${PORT}/ on the tablet (CA installed) — loads without blocking warning."
}

MODE=""
RESET_FLAG=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tailscale) MODE="tailscale" ;;
    --mkcert)    MODE="mkcert" ;;
    --reset)     RESET_FLAG=1 ;;
    -h|--help)   usage; exit 0 ;;
    *)           usage >&2; die "unknown argument: $1" ;;
  esac
  shift
done

if [[ "${RESET_FLAG}" -eq 1 ]]; then
  [[ -z "${MODE}" ]] || die "--reset cannot be combined with a mode."
  tailscale_reset_mode
  exit 0
fi

if [[ -z "${MODE}" ]]; then
  if tailscale_running; then
    log "Autodetect: tailscale installed and connected → tailscale serve path (SPEC §7.4 preferred)."
    MODE="tailscale"
    # Autodetect only: if the control plane cannot issue HTTPS certs, fall
    # back to mkcert instead of failing the whole setup run (issues #21/#22).
    TS_FALLBACK=1
  elif command -v tailscale >/dev/null 2>&1; then
    die "tailscale installed but not connected (run 'tailscale up'), and mkcert mode was not forced. Use --mkcert to fall back."
  else
    log "Autodetect: no tailscale → mkcert fallback."
    MODE="mkcert"
  fi
fi

case "${MODE}" in
  tailscale) tailscale_mode ;;
  mkcert)    mkcert_mode ;;
esac
