# lisa

> Piloto de dictation: fale no celular/tablet → texto aparece (ou é salvo) no computador, em qualquer campo, estilo [Whispering/WhisperFlow](https://github.com/braden-w/whispering).

## O que é

**lisa** é o piloto de testes do [pepper.ai](https://github.com/tamires-manhaes) — assistente de voz local em construção. Aqui validamos o ciclo completo *"captura no mobile → transcrição no Mac → uso do texto no desktop"* antes de integrar ao pepper:

1. **PWA** (web, instalável no celular/tablet) captura a voz — `getUserMedia` + AudioWorklet → WAV PCM 16kHz mono
2. **lisa-listener** (Fastify, HTTPS na LAN) orquestra o [whisper.cpp `large-v3-turbo`](https://github.com/ggml-org/whisper.cpp)
3. O resultado tem 3 destinos:
   - **Injetar** — texto digita no campo em foco do macOS (clipboard + `Cmd+V` simulado) *— o desafio central do piloto*
   - **Salvar** — registro em SQLite (schema espelhado do pepper, migração fácil)
   - **Mostrar** — só transcript no app

Sem auth: roda na rede local/de confiança. Nada sai da LAN. Critério do piloto: máquina do zero rodando em < 30 min, latência grave→texto < 2s.

## Objetivo da v0

Provar o loop. Os milestones contam a história:

| Milestone | Entrega |
|---|---|
| **v0.1** | Loop básico: PWA grava → listener transcreve → transcript exibido + benchmark de latência |
| **v0.2** | Texto injetado no campo em foco do macOS (matriz de validação: Safari/Obsidian/VS Code/Notes/Slack) |
| **v0.3** | Modo salvar (SQLite, schema do pepper) |
| v0.4 | (Opcional, só se o piloto der bom) VAD + relatório do piloto |

Se o piloto passar: `packages/inject` + listener são extraídos como **módulo do pepper.ai**. O lisa não é o produto final.

## Monorepo

```
apps/listener      Fastify :8080 — API, orquestra whisper, inject, persistência
apps/web           PWA (Vite + React) — tela de gravação
packages/shared    protocolo + tipos + erros (fonte única de verdade app↔server)
packages/audio     encode WAV + downsample + validação
packages/inject    lib de inject pura + CLI (o futuro módulo do pepper)
```

Regras: `apps/*` → `packages/*`, nunca o contrário; o protocolo vive **só** em `packages/shared`.

## Como contribuir

1. Veja o board: https://github.com/tamires-manhaes/lisa/projects — `Backlog` agrupado por `Fase`
2. Pegue um **Slice** (issue pai) desbloqueado — dependências no campo `Dependências` do corpo. As sub-tasks são os passos do slice: faça todas, feche, PR.
3. Branch `feat/desc`, PR pra `main` — CI roda typecheck + lint + test.
4. A spec completa tá em [`SPEC.md`](SPEC.md); o plano de issues c/ cobertura item-a-item do checklist em [`docs/issues-plan.md`](docs/issues-plan.md).

Regras de bolso: slice = 1 PR ≈ até ~500 linhas de diff; nada fora da spec (dúvidas → `SPEC.md` primeiro, issue depois).
