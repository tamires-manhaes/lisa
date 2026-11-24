# lisa — Spec do Projeto

> Piloto de testes: fale no smartphone/tablet (web/PWA) → texto aparece (ou é salvo) no computador, em qualquer campo, estilo Whispering/WhisperFlow.

## 1. Visão

Piloto de testes do **pepper.ai**: app web/PWA que captura a voz do usuário e um serviço no computador que transcreve e **injeta o texto no campo em foco** (ou salva como registro), tudo na rede local. Monorepo p/ compartilhar tipos, protocolo e módulos entre app e servidor.

**Fases do piloto:**

- **v0.1:** PWA grava → serviço transcreve → transcript exibido no app.
- **v0.2:** texto injetado no campo em foco do Mac (clipboard + `Cmd+V`).
- **v0.3:** modo "salvar como registro" (espelha o modelo de dados do pepper v1).

**O que o piloto NÃO é:** sem login, sem CRUD completo, sem interpretação de comandos (v2 do pepper). Código que se provar bom migra para o pepper.

## 2. Relação com o pepper.ai

| Tema | pepper.ai | lisa |
|---|---|---|
| Papel | Produto completo (assistente) | Piloto de interface/teste |
| Codebase | Separada | Separada — **monorepo interno** (§5) |
| Cadastro/JWT | Sim (v1) | Não — rede local de confiança |
| Registros salvos | Sim (core da v1) | Só em v0.3, espelhando o schema |
| Inject de texto no desktop | Não (foco: app + API) | **Sim — o desafio central** |
| ASR | whisper.cpp `large-v3-turbo` | Mesmo modelo |
| Cliente | React Native | Web/PWA (por enquanto; RN pode voltar no pepper) |

Se o lisa virar módulo do pepper: o que migra é o server-side (listener + inject), extraído como pacote — a estrutura de monorepo (`packages/*`) já é preparada para isso.

## 3. Decisões técnicas

| Decisão | Escolha | Motivo |
|---|---|---|
| ASR | **whisper.cpp `large-v3-turbo`** | Decisão confirmada no pepper (WER ~3.8% PT-BR, Metal). Mesma instalação. |
| Áudio | **PCM 16kHz mono WAV** via AudioWorklet | Captura Float32 no browser → downsample para 16k → encode WAV. Mesmo formato do pipeline do pepper. |
| Cliente | **Web app / PWA** (Vite + React 18 + TS) | Entra direto: sem store, sem build nativo. Mic permission via getUserMedia. Instalável na home do tablet/celular (manifest + SW mínimo). |
| Server | Node 20+ (Fastify) + whisper-server (`POST /inference`) | Reusa o pipeline do pepper; acopla pouco. |
| Monorepo | **pnpm workspaces + Turborepo**, TypeScript em tudo | Compartilhamento de tipos/protocolo app↔server via `packages/shared`; build paralelo/cached. |
| Inject de texto (macOS) | **1º: clipboard + `Cmd+V` simulado** (CGEvent via helper nativo / AppleScript); restaura clipboard anterior | Paste é confiável em qualquer campo e rápido; digitação char-a-char é inconsistente entre apps. Requer permissão de Acessibilidade. |
| Inject fallback | AppleScript `keystroke` tipo-a-tipo | Para campos que ignoram paste; lento, só quando paste falhar. |
| Transporte | **HTTPS na LAN** (Tailscale Serve OU mkcert/self-signed) | `getUserMedia` exige secure context — HTTP puro em IP LAN é bloqueado pelo browser no celular. |
| Modo salvar (v0.3) | SQLite (`better-sqlite3`), schema espelhado do pepper | Migração trivial. |
| VAD (v1) | Não — botão stop manual | Silero entra como polimento (mesmo roadmap do pepper). |
| OS alvo | macOS (listener + inject). Cliente: iOS Safari e Android Chrome | Inject de texto varia por OS — só macOS no piloto. |

## 4. Arquitetura

```
┌─ PWA (smartphone/tablet) ────────┐        ┌─ Mac com whisper ──────────────────────────┐
│                                  │ HTTPS  │                                            │
│  config endereço do host         │───────→│  lisa-listener :8080 (Fastify, HTTPS)      │
│  mic → AudioWorklet              │  WAV   │   ├─ valida WAV, chama POST /inference     │
│  downsample 48k→16k mono         │  body  │   ├─ whisper-server :8081 (large-v3-turbo) │
│  encode WAV                      │        │   ├─ modo INJECT:                          │
│  botão grave/stop                │←───────│   │    clipboard ← texto                   │
│  modo: injetar/salvar/mostrar    │ {text} │   │    Cmd+V simulado no app em foco       │
│  preview transcript + status     │        │   │    restaura clipboard (delay ~400ms)   │
│                                  │        │   └─ modo SALVAR: INSERT transcriptions    │
└──────────────────────────────────┘        └────────────────────────────────────────────┘
```

- A PWA conversa **só com o lisa-listener** (:8080). Listener orquestra o whisper-server (:8081).
- Mesma topologia do pepper (app → API :8080 → whisper :8081) — valida num host só, sem cadastro.

## 5. Monorepo

```
lisa/
├── pnpm-workspace.yaml
├── turbo.json
├── package.json                 # scripts raiz: dev, build, lint, typecheck, test, e2e
├── .env.example
├── Makefile                     # setup one-shot (§11.1)
├── apps/
│   ├── listener/                # Fastify :8080 — API, orquestra whisper, inject, persistência
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
│           └── settings.ts      # endereço do host (localStorage)
├── packages/
│   ├── shared/                  # tipos do protocolo, schema zod, constantes (versionamento de API)
│   │   └── src/protocol.ts, types.ts, errors.ts
│   ├── inject/                  # helper de inject puro (CLI + lib) — o pacote que migra p/ pepper
│   │   └── src/clipboard.ts, paste.ts, detect-permissions.ts
│   └── audio/                   # WAV encoder + downsample + validação (usado por web e listener)
│       └── src/wav.ts, validate.ts
├── scripts/
│   ├── setup-whisper.sh         # baixa/compila whisper.cpp + modelo large-v3-turbo
│   ├── run-whisper.sh           # sobe whisper-server na :8081 c/ Metal
│   └── setup-https.sh           # mkcert OU Tailscale Serve
└── tests/
    ├── listener/ (vitest)
    ├── packages/ (vitest)
    └── e2e/ (Playwright — contra a PWA em desktop; mic simulado)
```

Regras:

- `apps/*` dependem de `packages/*`, nunca o inverso.
- Contrato app↔server vive **só** em `packages/shared` (`protocol.ts`) — nenhum tipo duplicado.
- `packages/inject` não conhece Express/Fastify — lib pura + CLI (`lisa-inject "texto"`), para poder sair como módulo do pepper.

## 6. Protocolo (packages/shared)

```ts
// POST /api/dictate — multipart: { audio: WAV file } + X-Lisa-Mode: inject | save | display
type DictateResponse =
  | { ok: true; mode: 'display' | 'save'; text: string; id?: string }
  | { ok: true; mode: 'inject'; injected: boolean; text: string; detail?: string }
  | { ok: false; error: LisaError }
```

- Sem auth. `Z-Lisa-Client` header p/ telemetria simples (`web/1.0`).
- Erros tipados no `packages/shared/errors.ts`: `WAV_INVALID`, `WHISPER_DOWN`, `INJECT_NO_PERMISSION`, `INJECT_FAILED`, `DB_ERROR`.
- Versionamento: campo `protocol` no `/api/health` (int) — se divergir do client com esperado (constante no shared), a PWA mostra banner "atualize o listener".

## 7. PWA

### 7.1. Stack

- Vite + React 18 + TypeScript
- Áudio: `getUserMedia` + **AudioWorklet** (no ScriptProcessor — deprecated) → Float32 → downsample → WAV do `packages/audio`
- HTTP: `fetch` com upload binário do WAV (Content-Type `audio/wav`)
- PWA: `manifest.webmanifest` (ícones, standalone, orientação livre) + service worker mínimo (app shell cache — a gravação não funciona offline de qualquer forma)
- Settings persistidos em `localStorage` (endereço do host, modo default)

### 7.2. Telas

1. **Gravar** (única tela):
   - botão grande mic (grave/stop), indicador de gravação (pulso + timer)
   - toggle do modo: **Injetar** / **Salvar** / **Só mostrar**
   - preview do transcript + status do round-trip (`gravando → enviando → transcrevendo → entregue/erro`)
   - last-request log (latência, tamanho WAV) — telemetria do piloto
2. **Settings** (sheet/rota): endereço do host, teste de conectividade (`/api/health`), modo default
3. Sem login, sem lista, sem cadastro.

### 7.3. Fluxo (modo Injetar)

```
[botão mic] → getUserMedia + AudioWorklet → buffer Float32
[stop] → encode WAV 16k mono → POST /api/dictate (X-Lisa-Mode: inject)
listener → whisper-server → {text}
  inject → clipboard ← texto; Cmd+V no app em foco; restaura clipboard
PWA recebe {injected: true} → feedback "texto entregue" + latência
```

### 7.4. Secure context (pré-requisito de uso)

`getUserMedia` exige HTTPS. Opções (setup automatizado no `script setup-https.sh`):

1. **Tailscale Serve** (preferido se Tailscale já instalado): `tailscale serve https / https://localhost:8080` — cert válido automaticamente, acessível via hostname do tailnet.
2. **mkcert** + `--https` do Node/Fastify: instalar CA local no dispositivo. Para tablets/celulares: exportar `rootCA.pem`, instalar como perfil/confiança no iOS/Android.

A PWA bloqueia gravação em HTTP puro — tela mostra instrução de setup quando `!window.isSecureContext && origin não é localhost`.

## 8. Inject de texto (macOS)

- Helper isolado em `packages/inject`. Sequência do modo inject:
  1. captura + guarda clipboard atual (com timestamp)
  2. escreve transcript no clipboard (`pbcopy` via spawn ou wrapper NSPasteboard)
  3. envia `Cmd+V` — ordem de preferência: helper nativo Swift compilado no setup (`CGEventPost`) → AppleScript `System Events keystroke 'v' using command down`
  4. delay 300–500ms → restaura clipboard anterior (se não houve cópia nova do usuário nesse intervalo)
- Permissões: **Acessibilidade** p/ o processo do listener (System Settings → Privacy → Accessibility). `/api/health` roda check real (inject + undo de caractere em campo testável) e reporta `inject: ok | no_permission | failed`.
- Edge cases medidos no piloto (matriz em `docs/inject-matrix.md`): apps que bloqueiam paste (alguns Electron com campo custom), race de cópia durante inject, apps sandboxed. Fallback `keystroke` tipo-a-tipo configurável por flag no request (`x-lisa-inject-strategy: paste | type`).
- Validação em: Safari, Obsidian, VS Code, Notes, Slack.

## 9. Modelo de dados (só no modo salvar, v0.3)

```sql
transcriptions (
  id         TEXT PK,                  -- UUID
  title      TEXT NOT NULL,            -- deriva da primeira frase
  text       TEXT NOT NULL,
  audio_size INTEGER NOT NULL,          -- bytes do WAV, p/ debug de latência
  source     TEXT DEFAULT 'dictation', -- distingue de registro futuro do pepper
  created_at TEXT NOT NULL DEFAULT now()
)
```

DB: SQLite em `~/Library/Application Support/lisa/lisa.db` (não no repo). Campos espelhados do pepper, menos `user_id` — copy + preencher `user_id` na migração.

## 10. Segurança

- HTTPS na LAN via Tailscale Serve ou cert local (§7.4) — exige secure context, não só por permissão de mic: também criptografa o áudio.
- Sem auth — premissa de confiança da rede local, igual ao cadastro do pepper (§6 dele). Se sair da LAN por Tailscale, o tailnet funciona como camada de controle de acesso.
- Permissão de Acessibilidade ao listener = menor privilégio; listener é dev-tool rodando no usuário, não daemon de sistema.
- `packages/inject` nunca manda keystrokes digitados por terceiros — só o transcript, e restaura clipboard.
- Sanitização: transcript vai para o clipboard (sem execução por shell) — nenhum dado do áudio passa por processo externo além do whisper local.

## 11. Checklist "pronto para uso"

Critério: nova máquina + tablet configurado do zero em < 30 min, sem passos manuais não-documentados.

### 11.1. Setup e DX
- [ ] `make setup` — raiz: instala pnpm deps, compila helper Swift de inject, roda `scripts/setup-whisper.sh` (whisper.cpp + modelo large-v3-turbo com Metal), roda `scripts/setup-https.sh`
- [ ] `.env.example` completo + `config.ts` com zod (listener: porta, caminho whisper db/modelo, modo inject default, secret de nada — nada de secret)
- [ ] `make dev` (turbo: web + listener + whisper-server), `make build`, `make lint`, `make typecheck`, `make test`
- [ ] README por app + raiz, doc `docs/setup.md` passo-a-passo com prints das permissões (Acessibilidade, mic no iOS/Android)

### 11.2. Operação
- [ ] `/api/health` completo: whisper disponível (ping no :8081), permissão de inject (check real), DB, caminho do modelo versão, `protocol` version
- [ ] Estados de erro tratados com mensagem legível no app: whisper down, WAV inválido, inject sem permissão, host inacessível (timeout)
- [ ] Logs estruturados (pino): cada dictate → latência total + latência whisper + latência inject, tamanho de WAV, modo, sucesso/falha
- [ ] Listener reinicia whisper-server se ping falhar (supervisão leve, `spawn` com backoff)

### 11.3. Cliente
- [ ] PWA instalável (manifest + ícones + SW) — testada adicionar na home em iOS e Android
- [ ] Instrução inline na tela quando secure context ausente (§7.4)
- [ ] Reconexão: se host offline, botão re-testa `/api/health`; gravação aborta com mensagem em vez de acumular buffer
- [ ] Acessibilidade: botão mic em área mínima de toque 48px, funciona com orientação landscape

### 11.4. Validação do piloto
- [ ] Benchmark de latência documentado: grave→texto na tela para frases de 3s/10s/20s (alvo: < 2s no stop, ~15s de frase)
- [ ] Matriz de inject (§8) completa nos 5 apps — com resultados registrados
- [ ] Restauração de clipboard funciona sob cópia concorrente do usuário
- [ ] Testes: unit (packages/audio encode WAV golden files, packages/inject com macOS mocked), e2e Playwright (fluxo display mode com fake whisper-server), smoke script `make smoke` (end-to-end real com WAV fixture via `curl`)

### 11.5. Repositório
- [ ] git init + CI leve (GitHub Actions: typecheck + lint + test no PR)
- [ ] `.gitignore` (modelos, db, certs, recordings temporários)
- [ ] Licença + badge de status no README

## 12. Roadmap

### v0.1 — Loop básico (MVP)
- [ ] Monorepo scaffold (pnpm + turbo + `packages/shared` + `packages/audio`)
- [ ] whisper-server rodando com `large-v3-turbo` (Metal) — script setup
- [ ] lisa-listener: `/api/dictate` + `/api/health` → whisper → `{text}`
- [ ] PWA: AudioWorklet → WAV 16k mono, upload, exibir transcript
- [ ] HTTPS por Tailscale Serve ou mkcert (§7.4)
- [ ] Logging de latência + `make smoke`

### v0.2 — Inject no desktop
- [ ] `packages/inject`: clipboard + paste + restauração + permissão de Acessibilidade
- [ ] Modo Injetar na PWA + matrizes de erro do protocolo
- [ ] Validação Safari/Obsidian/VS Code/Notes/Slack — `docs/inject-matrix.md`
- [ ] e2e Playwright do modo display

### v0.3 — Modo salvar
- [ ] SQLite + schema espelhado do pepper (§9)
- [ ] Rotas `/api/notes` (GET lista, DELETE)
- [ ] Toggle modo Salvar + feedback no app

### v0.4 — Polimento (opcional, alimenta pepper)
- [ ] VAD (Silero) no browser — para o roadmap v1.x do pepper
- [ ] Fallback `keystroke` tipo-a-tipo testado
- [ ] Relatório do piloto: o que migrou/decidiu para o pepper + extração de `packages/inject` como módulo standalone

## 13. Decisões e perguntas abertas

**Decidido:**

- [x] Codebases separadas do pepper (2026-11-24) — se integrar, `packages/inject` + listener migram como módulo/pacote server-side. Monorepo **interno do lisa** p/ compartilhar tipos/protocolo entre app e server.
- [x] Entrada de áudio = **web/PWA** (2026-11-24, substitui o app RN original) — AudioWorklet + WAV; RN só volta se o pepper a decisão do pepper exigir.
- [x] macOS primeiro (listener + inject); cliente: iOS Safari e Android Chrome.

**Abertas:**

- [ ] Transporte HTTPS: Tailscale Serve vs mkcert+CA no dispositivo — decidir ao rodar `setup-https.sh` na máquina real.
- [ ] Inject no Windows/Linux: entra no piloto ou só no pepper v2? (default: só macOS)

## 14. Referências

- [Whispering (estilo de referência)](https://github.com/braden-w/whispering) — dictation app open-source, modelo de UX do inject
- [whisper.cpp](https://github.com/ggml-org/whisper.cpp) — ASR local, server mode
- [CGEvent / Event Taps](https://developer.apple.com/documentation/coregraphics/cgevent) — simulação de teclado no macOS
- [AudioWorklet](https://developer.mozilla.org/en-US/docs/Web/API/AudioWorklet) — captura de áudio no browser
- [Tailscale Serve](https://tailscale.com/kb/1242/tailscale-serve) — HTTPS válido na LAN/tailnet
- pepper.ai — `../pepper-ai/SPEC.md` (decisões herdadas, schema, stack)
