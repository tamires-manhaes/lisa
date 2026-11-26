# lisa — one-shot setup + targets that delegate to pnpm/turbo (SPEC §11.1, issue #22).
#
# `make setup` orchestrates: deps → inject helper (reserved) → whisper → https.
# Every step is idempotent by design (scripts/setup-whisper.sh skips existing
# artifacts; deps install is incremental), so `make setup` is safe to re-run.

SHELL := /bin/bash

.DEFAULT_GOAL := help
.PHONY: help setup install inject-helper whisper https dev build lint typecheck test

help: ## show the targets
	@echo "lisa — targets (SPEC §11.1):"
	@echo "  make setup    one-shot: deps + inject helper + whisper.cpp/model + HTTPS"
	@echo "  make dev      run web + listener via turbo (whisper: scripts/run-whisper.sh)"
	@echo "  make build    turbo build"
	@echo "  make lint     turbo lint"
	@echo "  make typecheck  turbo typecheck"
	@echo "  make test     turbo test"
	@echo "  make whisper  run scripts/setup-whisper.sh alone"
	@echo "  make https    run scripts/setup-https.sh alone"

setup: install inject-helper whisper https ## one-shot fresh-machine setup (~deps + whisper + https)
	@echo "[setup] done. Next: cp .env.example .env (set WHISPER_MODEL_PATH printed above), make dev"

install: ## pnpm dependencies (workspace)
	@echo "[setup] pnpm install..."
	@pnpm install

inject-helper: ## RESERVED — Swift CGEvent helper build wire-up (placeholder)
	@echo "[setup] inject Swift helper: reserved placeholder — nothing to build yet."
	@echo "        Swift helper (CGEventPost, SPEC §8) lands in the inject slice (#79),"
	@echo "        and its compilation step is wired here in #80 (chore(make))."

whisper: ## clone/build whisper.cpp (Metal) + download large-v3-turbo (idempotent)
	@bash scripts/setup-whisper.sh

https: ## provision HTTPS for the secure context (Tailscale Serve or mkcert)
	@bash scripts/setup-https.sh

dev: ## turbo dev (web + listener) — start whisper first with scripts/run-whisper.sh
	@pnpm dev

build:
	@pnpm build

lint:
	@pnpm lint

typecheck:
	@pnpm typecheck

test:
	@pnpm test
