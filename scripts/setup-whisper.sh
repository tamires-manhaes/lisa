#!/usr/bin/env bash
#
# scripts/setup-whisper.sh — clone/build whisper.cpp + download the large-v3-turbo
# model (SPEC §11.1, issue #14). Idempotent: each step is skipped if its artifact
# already exists, so running it twice does not rebuild or re-download.
#
# Model choice: ggml-large-v3-turbo.bin (fp16, ~1.6 GB) from the official
# ggml-org/whisper.cpp repo on Hugging Face — same file pepper uses (SPEC §3).
# The exact filename exists there verbatim; it needs no variant. If you want the
# smaller quantized build, override LISA_MODEL_FILE (e.g. ggml-large-v3-turbo-q8_0.bin).
#
# Env:
#   LISA_MODEL_DIR   where the model is stored  (default: <repo>/modelos — gitignored)
#   LISA_MODEL_FILE  model filename             (default: ggml-large-v3-turbo.bin)
#
# When done, point WHISPER_MODEL_PATH in .env at the printed model path.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WHISPER_DIR="$REPO_ROOT/whisper.cpp"
SERVER_BIN="$WHISPER_DIR/build/bin/whisper-server"
MODEL_DIR="${LISA_MODEL_DIR:-$REPO_ROOT/modelos}"
MODEL_FILE="${LISA_MODEL_FILE:-ggml-large-v3-turbo.bin}"
MODEL_PATH="$MODEL_DIR/$MODEL_FILE"
MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/$MODEL_FILE"
WHISPER_REPO="https://github.com/ggml-org/whisper.cpp"

echo "[setup-whisper] repo root: $REPO_ROOT"

# 1. Clone whisper.cpp (shallow — we only need the current build).
if [ ! -d "$WHISPER_DIR/.git" ]; then
  echo "[setup-whisper] cloning whisper.cpp (shallow)..."
  git clone --depth 1 "$WHISPER_REPO" "$WHISPER_DIR"
else
  echo "[setup-whisper] whisper.cpp already cloned — skipping"
fi

# 2. Build the whisper-server with Metal (GGML_METAL is the default on Apple
#    Silicon today, but passed explicitly so the acceleration intent is on record).
if [ ! -x "$SERVER_BIN" ]; then
  echo "[setup-whisper] building whisper-server (Metal)..."
  cmake -S "$WHISPER_DIR" -B "$WHISPER_DIR/build" \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_METAL=ON \
    -DBUILD_SHARED_LIBS=ON
  cmake --build "$WHISPER_DIR/build" --config Release --target whisper-server -j "$(getconf _NPROCESSORS_ONLN)"
else
  echo "[setup-whisper] whisper-server already built — skipping"
fi

# 3. Download the model.
mkdir -p "$MODEL_DIR"
if [ -s "$MODEL_PATH" ]; then
  echo "[setup-whisper] model already present — skipping"
else
  echo "[setup-whisper] downloading $MODEL_FILE (large, may take a while)..."
  # -C - resumes a partial download instead of starting over.
  curl -L --fail --retry 3 -C - -o "$MODEL_PATH" "$MODEL_URL"
fi

echo "[setup-whisper] done."
echo "[setup-whisper] server binary: $SERVER_BIN"
echo "[setup-whisper] model file:    $MODEL_PATH"
echo "[setup-whisper] set WHISPER_MODEL_PATH=$MODEL_PATH in your .env"
