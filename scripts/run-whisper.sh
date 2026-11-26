#!/usr/bin/env bash
#
# scripts/run-whisper.sh — start the whisper-server on :8081 loading large-v3-turbo
# with Metal (SPEC §11.1, issue #15).
#
# Args kept minimal and documented:
#   --host/--port  → bound to 127.0.0.1:8081 (matches WHISPER_URL in .env)
#   -m             → model path resolved from LISA_MODEL_DIR (same default as setup)
#   -l             → language 'pt' (the pilot is PT-BR; whisper's default is 'en')
#   -t             → threads = host core count (env-overridable)
#
# NOT passed: --convert (client already sends 16 kHz mono WAV, SPEC §3);
# -ng/--no-gpu (Metal is on by default in the Metal build from setup-whisper.sh).
#
# Env:
#   LISA_MODEL_DIR     model dir   (default: <repo>/modelos)
#   LISA_MODEL_FILE    model file  (default: ggml-large-v3-turbo.bin)
#   LISA_WHISPER_PORT  server port (default: 8081)
#   LISA_WHISPER_LANG  language    (default: pt)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER_BIN="$REPO_ROOT/whisper.cpp/build/bin/whisper-server"
MODEL_DIR="${LISA_MODEL_DIR:-$REPO_ROOT/modelos}"
MODEL_FILE="${LISA_MODEL_FILE:-ggml-large-v3-turbo.bin}"
MODEL_PATH="$MODEL_DIR/$MODEL_FILE"
PORT="${LISA_WHISPER_PORT:-8081}"
LANG_CODE="${LISA_WHISPER_LANG:-pt}"

if [ ! -x "$SERVER_BIN" ]; then
  echo "[run-whisper] whisper-server not built: $SERVER_BIN" >&2
  echo "[run-whisper] run scripts/setup-whisper.sh first" >&2
  exit 1
fi
if [ ! -s "$MODEL_PATH" ]; then
  echo "[run-whisper] model not found: $MODEL_PATH" >&2
  echo "[run-whisper] run scripts/setup-whisper.sh first" >&2
  exit 1
fi

echo "[run-whisper] starting whisper-server on 127.0.0.1:$PORT (model: $MODEL_PATH, Metal)"
exec "$SERVER_BIN" \
  --host 127.0.0.1 \
  --port "$PORT" \
  -m "$MODEL_PATH" \
  -l "$LANG_CODE" \
  -t "$(getconf _NPROCESSORS_ONLN)"
