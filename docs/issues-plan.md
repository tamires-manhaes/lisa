# lisa — Plano de Issues

> Fonte: `SPEC.md` (§11 checklist "pronto para uso" + §12 roadmap). Nenhuma caixa dos checklists ficou sem issue que a realize — mapeamento item-a-item no fim do doc (§ Cobertura).

## Sumário — árvore de issues

```
Setup & Infra (épico, milestone v0.1)
└── S1 chore: scaffold do monorepo (pnpm + turbo + packages)
    ├── 1.1 root: pnpm-workspace + turbo.json + tsconfig base + scripts raiz
    ├── 1.2 packages/shared: esqueleto
    ├── 1.3 packages/audio + packages/inject: esqueleto
    └── 1.4 apps/listener + apps/web: esqueletos rodando
└── S2 chore: CI + .gitignore + licença
    ├── 2.1 GitHub Actions (typecheck + lint + test no PR)
    └── 2.2 .gitignore + LICENSE + badge
└── S3 chore: config com zod + .env.example
    ├── 3.1 apps/listener config.ts (zod)
    └── 3.2 .env.example completo
└── S4 chore: scripts whisper.cpp (setup + run)
    ├── 4.1 scripts/setup-whisper.sh (whisper.cpp + large-v3-turbo, Metal)
    └── 4.2 scripts/run-whisper.sh (:8081)
└── S5 chore: script HTTPS na LAN (Tailscale Serve / mkcert)
    ├── 5.1 caminho Tailscale Serve
    └── 5.2 caminho mkcert + CA no dispositivo
└── S6 docs: setup passo-a-passo + READMEs + make setup
    ├── 6.1 READMEs (raiz + apps)
    ├── 6.2 docs/setup.md (com prints de permissões)
    └── 6.3 Makefile: target `make setup` (one-shot)
—
v0.1 — Loop básico (épico, milestone v0.1)
└── S7  feat(shared): protocolo v1 + erros + contrato de health
    ├── 7.1 protocol.ts (DictateRequest/Response + constantes)
    ├── 7.2 errors.ts (LisaError tipado)
    └── 7.3 contrato /api/health + versão de protocolo
└── S8  feat(audio): WAV encoder + downsample + validação
    ├── 8.1 downsample Float32 → 16k mono
    ├── 8.2 encoder WAV
    ├── 8.3 validate.ts (validação de WAV)
    └── 8.4 testes golden files
└── S9  chore(listener): Fastify base + whisper client + /api/health + supervisão
    ├── 9.1 bootstrap Fastify (HTTP/HTTPS)
    ├── 9.2 whisper client (POST /inference + ping)
    ├── 9.3 GET /api/health básico
    └── 9.4 supervisão do whisper-server (spawn com backoff)
└── S10 feat(listener): POST /api/dictate — modo display
    ├── 10.1 rota multipart + validação de WAV
    ├── 10.2 integração whisper → {ok, mode, text}
    └── 10.3 testes do listener (whisper fake)
└── S11 feat(web): scaffold PWA + settings do host
    ├── 11.1 shell do app (rotas + layout)
    ├── 11.2 settings.ts (localStorage: host, modo default)
    └── 11.3 teste de conectividade (/api/health) na tela de settings
└── S12 feat(web): captura de áudio (AudioWorklet → WAV)
    ├── 12.1 getUserMedia + recorder.ts
    ├── 12.2 worklet.ts (coleta de amostras)
    ├── 12.3 pipeline stop → downsample → WAV
    └── 12.4 testes unit (pipeline de áudio)
└── S13 feat(web): tela Gravar — fluxo display completo
    ├── 13.1 botão mic + pulso + timer
    ├── 13.2 api/dictate.ts (upload binário)
    ├── 13.3 preview transcript + máquina de status
    └── 13.4 last-request log (latência, tamanho WAV)
└── S14 feat(web): PWA instalável
    ├── 14.1 manifest + ícones
    ├── 14.2 service worker mínimo (app shell)
    └── 14.3 validação "adicionar à home" iOS + Android
└── S15 feat(web): robustez — erros legíveis, secure context, reconexão
    ├── 15.1 mapa erro→mensagem legível
    ├── 15.2 guard de secure context (instrução inline)
    ├── 15.3 reconexão: re-testa health + aborta buffer se offline
    └── 15.4 a11y: botão mic 48px + landscape
└── S16 chore(listener): logging estruturado pino
    ├── 16.1 setup pino
    └── 16.2 log por dictate (latências, tamanho, modo, sucesso)
└── S17 chore: `make smoke` (e2e real via curl)
    ├── 17.1 fixtures WAV de teste
    └── 17.2 script smoke end-to-end (display)
└── S18 docs: benchmark de latência do loop
    ├── 18.1 protocolo de medição (3s/10s/20s)
    └── 18.2 docs/benchmark.md com resultados
—
v0.2 — Inject no desktop (épico, milestone v0.2)
└── S19 feat(inject): clipboard (snapshot + write)
    ├── 19.1 wrapper pbcopy/pbpaste (spawn seguro)
    └── 19.2 testes com macOS mockado
└── S20 feat(inject): Cmd+V — helper nativo Swift (CGEvent)
    ├── 20.1 helper Swift (CGEventPost) + paste.ts
    └── 20.2 `make setup` compila o helper
└── S21 feat(inject): fallback AppleScript keystroke + strategy flag
    ├── 21.1 fallback `keystroke` tipo-a-tipo (osascript)
    ├── 21.2 paste.ts seleciona estratégia
    └── 21.3 suporte ao header x-lisa-inject-strategy no listener
└── S22 feat(inject): restauração de clipboard + race de cópia
    ├── 22.1 restaurar após 300–500ms
    └── 22.2 não restaurar se houve cópia concorrente (changeCount)
└── S23 feat(inject): permissão de Acessibilidade + CLI lisa-inject
    ├── 23.1 detect-permissions.ts (check real + undo)
    ├── 23.2 CLI `lisa-inject "texto"` (bin)
    └── 23.3 instrução de concessão de permissão
└── S24 feat(listener): modo INJECT end-to-end + health com check real
    ├── 24.1 fluxo X-Lisa-Mode: inject em /api/dictate
    ├── 24.2 /api/health: inject ok | no_permission | failed
    └── 24.3 testes inject (packages/inject mockado)
└── S25 feat(web): modo Injetar na PWA
    ├── 25.1 toggle 3 modos (Injetar/Salvar/Só mostrar)
    ├── 25.2 feedback "texto entregue" + latência
    └── 25.3 erros INJECT_* legíveis + guia de permissão
└── S26 test: e2e Playwright (modo display com whisper fake)
    ├── 26.1 setup Playwright + fake whisper-server
    ├── 26.2 e2e fluxo feliz display
    └── 26.3 e2e cenários de erro
└── S27 docs: matriz de inject (5 apps)
    ├── 27.1 template docs/inject-matrix.md
    └── 27.2 executar + registrar resultados nos 5 apps
—
v0.3 — Modo salvar (épico, milestone v0.3)
└── S28 feat(db): SQLite com schema espelhado do pepper
    ├── 28.1 better-sqlite3 + bootstrap do DB
    ├── 28.2 schema transcriptions + title derivada
    └── 28.3 db/repository + testes
└── S29 feat(listener): modo SAVE + rotas /api/notes
    ├── 29.1 X-Lisa-Mode: save → INSERT + resposta com id
    ├── 29.2 GET /api/notes (lista)
    ├── 29.3 DELETE /api/notes/:id
    └── 29.4 /api/health: check do DB
└── S30 feat(web): modo Salvar na PWA
    ├── 30.1 wire modo Salvar + feedback com id
    └── 30.2 erro DB_ERROR legível
—
v0.4 — Polimento (épico opcional, milestone v0.4 — alimenta pepper)
└── S31 feat(web): VAD (Silero) no browser
    ├── 31.1 VAD Silero + stop automático
    ├── 31.2 feature toggle (default off)
    └── 31.3 avaliação p/ roadmap v1.x do pepper
└── S32 feat(inject): fallback keystroke validado
    ├── 32.1 testes unit do fallback (macOS mockado)
    └── 32.2 células de fallback na matriz + strategy por app
└── S33 docs: relatório do piloto + extração do packages/inject
    ├── 33.1 docs/pilot-report.md (o que migra p/ pepper)
    └── 33.2 packages/inject empacotado standalone
```

## Milestones recomendados

- **v0.1** — S1 a S18 (setup & infra + loop básico). Critério de fechamento: checklist §12 v0.1 completo + §11.2.
- **v0.2** — S19 a S27 (inject). Critério: matriz de inject preenchida nos 5 apps + e2e display passando.
- **v0.3** — S28 a S30 (modo salvar). Critério: ditar com toggle Salvar grava no SQLite e lista via `/api/notes`.
- **v0.4** — S31 a S33 (opcional). Criar o milestone só quando o piloto for declarado bem-sucedido; até lá, manter issues sem milestone (backlog).

## Regras de criação

- Criar na ordem numérica global (S1 → S33). Dentro de cada slice: criar o **pai primeiro**, depois as filhas, com `Parte de #<nº do pai>` no corpo da filha.
- Após criar as filhas, editar o pai e adicionar as referências `#n` em um tasklist "Tasks".
- Labels sugeridas por tipo (`feat`/`chore`/`docs`/`test`) + fase (`fase: v0.1`…) + escopo (`web`, `listener`, `shared`, `audio`, `inject`, `db`, `infra`, `ci`). Criar os labels uma vez antes de começar.
- Todo slice é 1 PR ≈ até 300–500 linhas de diff. Slice nunca depende de slice de fase posterior.

---

# ÉPICO 0 — Setup & Infra (milestone v0.1)

---

## #S1 — `chore: scaffold do monorepo (pnpm + turborepo + packages)` — criação nº 1

Labels: `chore`, `fase: v0.1`, `infra`
> Fase v0.1 — Loop básico: sem monorepo não existe compartilhamento de tipos/protocolo app↔server.

**Contexto:** a spec (§5) define pnpm workspaces + Turborepo com `packages/shared`, `packages/audio`, `packages/inject` e `apps/listener` + `apps/web`. Este slice levanta a carcaça toda compilando, antes de qualquer feature.

**DoD (pai)**
- [ ] `pnpm install` na raiz instala tudo (workspaces resolvidos)
- [ ] `pnpm -r typecheck`, `pnpm -r lint` e `pnpm test` passam (projetos vazios, mas pipeline verde)
- [ ] grafo de deps correto: `apps/*` importam de `packages/*`, nunca o inverso
- [ ] `packages/inject` e `packages/shared` sem nenhuma dependência de Fastify/Express

**Filhas**

### #1.1 — `chore(infra): raiz do workspace — pnpm-workspace, turbo.json, tsconfig base, scripts`
Labels: `chore`, `fase: v0.1`, `infra`
- Corpo: cria `pnpm-workspace.yaml` (apps/*, packages/*), `turbo.json` com pipeline de `build`/`lint`/`typecheck`/`test`/`dev`, `tsconfig.base.json` (strict, moduleResolution bundler). Scripts raiz em `package.json`: `dev`, `build`, `lint`, `typecheck`, `test` — todos via turbo.
- Aceite: `turbo run build` executa sem erro mesmo com pacotes vazios.

### #1.2 — `chore(shared): esqueleto do packages/shared`
Labels: `chore`, `fase: v0.1`, `shared`
- Corpo: pacote TS compilável (`tsup` ou tsc build) com `src/protocol.ts`, `src/types.ts`, `src/errors.ts` (exports placeholder) e barrel `src/index.ts`. `apps/*` devem poder importar de `@lisa/shared`.
- Aceite: `pnpm typecheck` no workspace resolve o import do pacote sem erro.

### #1.3 — `chore(audio+inject): esqueleto de packages/audio e packages/inject`
Labels: `chore`, `fase: v0.1`, `audio`, `inject`
- Corpo: `packages/audio` (`src/wav.ts`, `src/validate.ts`) e `packages/inject` (`src/clipboard.ts`, `src/paste.ts`, `src/detect-permissions.ts`) como libs TS puras (zero deps de framework), `vitest` configurado em ambos. `packages/inject` já com campo `bin` apontando para um `cli.ts` placeholder (CLI real = issue 23.2).
- Aceite: `pnpm test` roda vitest nos dois pacotes (1 teste de fumaça cada).

### #1.4 — `chore(apps): esqueletos de apps/listener e apps/web`
Labels: `chore`, `fase: v0.1`, `listener`, `web`
- Corpo: `apps/listener`: Fastify mínimo com `GET /health` respondendo `{ok: true}`. `apps/web`: scaffold Vite + React 18 + TS com página vazia. Ambos importam algo de `@lisa/shared` para validar o grafo de deps.
- Aceite: `pnpm dev` sobe listener e web em paralelo; `curl localhost:8080/health` responde.

**Dependências:** nenhuma (primeira issue).

---

## #S2 — `chore: CI leve + .gitignore + licença` — criação nº 2

Labels: `chore`, `fase: v0.1`, `infra`, `ci`
> Realiza §11.5 inteiro (CI, .gitignore, licença + badge) — melhor travar o repo cedo.

**Contexto:** §11.5 pede GitHub Actions com typecheck + lint + test no PR, `.gitignore` cobrindo modelos/db/certs/recordings, e licença com badge no README.

**DoD (pai)**
- [ ] CI roda no PR: typecheck + lint + test (§11.5, item 1)
- [ ] `.gitignore` cobre modelos, `*.db`, certs, recordings temporários (§11.5, item 2)
- [ ] LICENSE + badge de status no README raiz (§11.5, item 3)

**Filhas**

### #2.1 — `ci: GitHub Actions — typecheck + lint + test no PR`
Labels: `chore`, `fase: v0.1`, `ci`
- Corpo: workflow `.github/workflows/ci.yml` em PR: instala pnpm (com cache do store) e roda `turbo run typecheck lint test`.
- Aceite: PR com teste falhando bloqueia merge; PR verde passa.

### #2.2 — `chore(repo): .gitignore + LICENSE + badge de status no README`
Labels: `chore`, `fase: v0.1`, `infra`
- Corpo: `.gitignore` com modelos (`.bin`/`.ggml`, `whisper.cpp/`), `*.db`, certs (`*.pem`, `*.p12`, `certs/`), `recordings/`, `node_modules`, `.turbo`, `dist`. LICENSE (MIT, a confirmar com a autora) + badge de CI no README raiz.
- Aceite: `git status` limpo após rodar o setup do whisper (nada de modelo/DB trackado).

**Dependências:** #S1 mergeado (CI precisa do workspace).

---

## #S3 — `chore: config do listener com zod + .env.example` — criação nº 3

Labels: `chore`, `fase: v0.1`, `listener`
> Realiza §11.1 — ".env.example completo + config.ts com zod". Nada de secret: é dev-tool em LAN de confiança (§10).

**Contexto:** o listener precisa de porta, caminho do modelo whisper, caminho do DB e modo inject default — validados na boot, com falha legível.

**DoD (pai)**
- [ ] `.env.example` completo (§11.1, item 2)
- [ ] `apps/listener/src/config.ts` com zod, falhando na boot com erro legível se env inválida
- [ ] nenhum secret no arquivo (apenas porta, paths, flags)

**Filhas**

### #3.1 — `feat(listener): config.ts com zod (porta, caminhos, flags)`
Labels: `feat`, `fase: v0.1`, `listener`
- Corpo: schema zod com `PORT` (default 8080), `WHISPER_URL` (default `http://127.0.0.1:8081`), `WHISPER_MODEL_PATH`, `LISA_DB_PATH` (default `~/Library/Application Support/lisa/lisa.db`), `INJECT_STRATEGY` (default `paste`). Parse na boot; erro imprime os campos faltantes e encerra.
- Aceite: subir sem `WHISPER_MODEL_PATH` falha apontando o campo; env completa sobe limpo.

### #3.2 — `chore: .env.example documentado`
Labels: `chore`, `fase: v0.1`, `listener`, `docs`
- Corpo: `.env.example` com todas as vars de 3.1, uma linha de comentário por var (default e quando mudar).
- Aceite: `cp .env.example .env` + defaults → listener sobe sem ajustes além do model path.

**Dependências:** #S1.

---

## #S4 — `chore: scripts do whisper.cpp — setup + run (large-v3-turbo, Metal)` — criação nº 4

Labels: `chore`, `fase: v0.1`, `infra`
> Realiza §12 v0.1 item 2 — "whisper-server rodando com large-v3-turbo (Metal) — script setup". Alimenta o `make setup` (§11.1).

**Contexto:** o ASR é o whisper-server (:8081), mesmo modelo/pipeline do pepper. Setup reproduzível em máquina nova (critério §11: máquina nova em < 30 min).

**DoD (pai)**
- [ ] `scripts/setup-whisper.sh` baixa/compila whisper.cpp e o modelo `large-v3-turbo`
- [ ] `scripts/run-whisper.sh` sobe o server na :8081 com Metal habilitado
- [ ] `POST /inference` com WAV fixture PT-BR retorna transcript (validação manual registrada no PR)

**Filhas**

### #4.1 — `chore(scripts): setup-whisper.sh — clone/build whisper.cpp + download large-v3-turbo`
Labels: `chore`, `fase: v0.1`, `infra`
- Corpo: shell script idempotente: clona whisper.cpp, build com Metal, baixa o modelo `large-v3-turbo` para path configurável — pulando passos já prontos.
- Aceite: rodar duas vezes seguidas não refaz download/build.

### #4.2 — `chore(scripts): run-whisper.sh — server :8081 com Metal`
Labels: `chore`, `fase: v0.1`, `infra`
- Corpo: script que sobe o `whisper-server` na :8081 carregando `large-v3-turbo` com Metal (flags da build Metal), logando a carga do modelo.
- Aceite: `POST /inference` com WAV PT-BR de teste retorna texto em < 5s para frase de ~10s.

**Dependências:** nenhuma (scripts standalone); criar após #S3 para seguir as convenções de path do .env.

---

## #S5 — `chore: script HTTPS na LAN (Tailscale Serve ou mkcert)` — criação nº 5

Labels: `chore`, `fase: v0.1`, `infra`, `web`
> Realiza §12 v0.1 item 5 — "HTTPS por Tailscale Serve ou mkcert (§7.4)". getUserMedia exige secure context; HTTPS também criptografa o áudio (§10).

**Contexto:** §7.4 define as duas opções, automatizadas em `scripts/setup-https.sh`. A decisão entre elas fica aberta até rodar na máquina real (§13).

**DoD (pai)**
- [ ] `scripts/setup-https.sh` suporta os dois caminhos
- [ ] PWA acessível do dispositivo via HTTPS sem warning de cert (no caminho escolhido)
- [ ] `window.isSecureContext === true` no dispositivo

**Filhas**

### #5.1 — `chore(scripts): caminho Tailscale Serve no setup-https.sh`
Labels: `chore`, `fase: v0.1`, `infra`
- Corpo: se `tailscale` está instalado, script configura `tailscale serve https / https://localhost:8080` e imprime a URL do tailnet.
- Aceite: URL do tailnet no celular carrega o app como secure context.

### #5.2 — `chore(scripts): caminho mkcert + CA no dispositivo`
Labels: `chore`, `fase: v0.1`, `infra`
- Corpo: fallback mkcert: gera cert localhost, configura o listener para HTTPS, exporta `rootCA.pem` com instruções impressas de instalação no iOS (perfil + confiança) e no Android.
- Aceite: com a CA instalada no tablet, app carrega sem warning.

**Dependências:** #S1 (repo), #S3 (porta do listener). Fechar atualizando §13 (Tailscale vs mkcert) após o teste real.

---

## #S6 — `docs: setup passo-a-passo + READMEs + make setup one-shot` — criação nº 6

Labels: `docs`, `fase: v0.1`, `infra`
> Realiza §11.1 — READMEs raiz + por app, `docs/setup.md` com prints das permissões, e o `make setup` que amarra tudo.

**Contexto:** o critério do piloto é máquina nova + tablet do zero em < 30 min, sem passos não-documentados. Este slice fecha o setup como experiência de máquina nova.

**DoD (pai)**
- [ ] READMEs raiz + por app (§11.1, item 4)
- [ ] `docs/setup.md` passo-a-passo com prints das permissões (Acessibilidade, mic no iOS/Android) (§11.1, item 4)
- [ ] `make setup` executa deps + helper Swift + whisper + https (§11.1, item 1)
- [ ] targets `make dev/build/lint/typecheck/test` funcionam (§11.1, item 3)

**Filhas**

### #6.1 — `docs: READMEs (raiz + apps/listener + apps/web + packages/inject)`
Labels: `docs`, `fase: v0.1`
- Corpo: README raiz (visão em 5 linhas, topologia §4, comandos). READMEs por app: propósito, env vars, como rodar sozinho. `packages/inject` com seção "este pacote migra para o pepper" (§2).
- Aceite: pessoa nova entende o projeto e como rodar só pelos READMEs.

### #6.2 — `docs: docs/setup.md com prints das permissões`
Labels: `docs`, `fase: v0.1`
- Corpo: passo-a-passo de máquina nova: prereqs (Node, pnpm, Xcode CLT), `make setup`, concessão de Acessibilidade (System Settings → Privacy → Accessibility) com print, permissão de mic no iOS/Android com print, instalação da CA mkcert no tablet se aplicável.
- Aceite: setup completo em máquina virgem seguindo só o doc.

### #6.3 — `chore(make): target make setup one-shot + targets base`
Labels: `chore`, `fase: v0.1`, `infra`
- Corpo: Makefile com `setup` orquestrando: `pnpm install`, compilação do helper Swift de inject (passo reservado — ativa de fato na issue 20.2), `scripts/setup-whisper.sh` e `scripts/setup-https.sh`. Targets `dev`, `build`, `lint`, `typecheck`, `test`.
- Aceite: `make setup` roda ponta-a-ponta em máquina nova sem erro; demais targets funcionam.

**Dependências:** #S1, #S4, #S5 mergeados.

---

# ÉPICO 1 — v0.1: Loop básico (milestone v0.1)

---

## #S7 — `feat(shared): protocolo v1 + erros tipados + contrato de health` — criação nº 7

Labels: `feat`, `fase: v0.1`, `shared`
> Fase v0.1 — o contrato app↔server vive SÓ aqui (§5): nenhum tipo duplicado em app ou listener.

**Contexto:** §6 define `POST /api/dictate` (multipart WAV + `X-Lisa-Mode`), a `DictateResponse`, erros `LisaError` e versionamento via `/api/health`. Implementar no `packages/shared` primeiro trava o contrato.

**DoD (pai)**
- [ ] `protocol.ts` com request/response do dictate exatamente como §6 (variantes inject/save incluídas — campos usados a partir de v0.2/v0.3)
- [ ] `errors.ts` com os 5 códigos: `WAV_INVALID`, `WHISPER_DOWN`, `INJECT_NO_PERMISSION`, `INJECT_FAILED`, `DB_ERROR`
- [ ] constante `LISA_PROTOCOL_VERSION` (int, começa em 1) + tipo do corpo `/api/health`
- [ ] schemas zod para validar request e response nos dois lados

**Filhas**

### #7.1 — `feat(shared): protocol.ts — tipos do POST /api/dictate + headers`
Labels: `feat`, `fase: v0.1`, `shared`
- Corpo: tipos `DictateResponse` (variantes display/inject/save + erro) e constantes de headers (`X-Lisa-Mode`, `Z-Lisa-Client`, `x-lisa-inject-strategy`).
- Schemas zod dos payloads, parse nos dois lados.
- Aceite: typecheck do shared passa; tipos cobrem as 3 fases do §1.

### #7.2 — `feat(shared): errors.ts — LisaError com códigos tipados`
Labels: `feat`, `fase: v0.1`, `shared`
- Corpo: `LisaError = { code, message?, detail? }`, union `LisaErrorCode` com os 5 códigos e helper `toLisaError(code, detail)`.
- Aceite: listener e web importam os mesmos códigos — nenhum literal de error code fora do shared.

### #7.3 — `feat(shared): contrato de /api/health + versão do protocolo`
Labels: `feat`, `fase: v0.1`, `shared`
- Corpo: `HealthResponse { protocol, whisper: { up, model }, inject, db, version }` + constante `LISA_PROTOCOL_VERSION = 1`. Campos `inject`/`db` nulos até as fases deles.
- Aceite: schema zod valida um JSON de health exemplo de cada fase.

**Dependências:** #S1 (esqueleto do shared, 1.2).

---

## #S8 — `feat(audio): pacote de áudio — downsample + encoder WAV + validação` — criação nº 8

Labels: `feat`, `fase: v0.1`, `audio`
> Fase v0.1 — PCM 16kHz mono WAV (§3) é o formato do pipeline; usado pela web, validado pelo listener.

**Contexto:** §5/§7.1: captura Float32 → downsample 48k→16k mono → encode WAV. Lib pura, rodando nos dois lados.

**DoD (pai)**
- [ ] `packages/audio/src/wav.ts` gera WAV 16k mono válido a partir de Float32 (base do item 4 do §12 v0.1)
- [ ] `packages/audio/src/validate.ts` rejeita WAV inválido (rate errado, header cortado, canais > 1)
- [ ] testes golden files: WAV gerado bate byte-a-byte com fixture (§11.4, item 4)

**Filhas**

### #8.1 — `feat(audio): downsample Float32 (48k/44.1k) → 16k mono`
Labels: `feat`, `fase: v0.1`, `audio`
- Corpo: fn pura `downsampleTo16k(input: Float32Array, inputRate: number): Float32Array` (média das amostras por bucket). Trata 48000, 44100 e 16000 (no-op).
- Aceite: unit test 48000→16000 com senoide preserva a frequência (zero-crossings consistentes).

### #8.2 — `feat(audio): encoder WAV (PCM 16-bit, mono) em wav.ts`
Labels: `feat`, `fase: v0.1`, `audio`
- Corpo: `encodeWav(samples: Float32Array, sampleRate = 16000): ArrayBuffer` — header RIFF/WAVE + PCM 16-bit LE mono.
- Aceite: output reconhecido por `afinfo` como WAV PCM 16k mono.

### #8.3 — `feat(audio): validate.ts — validação do WAV recebido`
Labels: `feat`, `fase: v0.1`, `audio`
- Corpo: `validateWav(buffer): { ok: true, sampleRate, durationSec } | { ok: false, reason }` — magic RIFF, PCM, sample rate 16k, duração máxima sanável. Roda em Node (listener) e browser.
- Aceite: testes passam nos dois ambientes.

### #8.4 — `test(audio): golden files do encoder`
Labels: `test`, `fase: v0.1`, `audio`
- Corpo: fixtures `.wav` commitadas (1s de seno / silêncio / ruído) + testes comparando o byte stream gerado com a fixture (§11.4, item 4).
- Aceite: `pnpm test` em `packages/audio` cobre encoder + validate + downsample; CI aplica.

**Dependências:** #S1 (esqueleto, 1.3).

---

## #S9 — `chore(listener): Fastify base + whisper client + /api/health + supervisão` — criação nº 9

Labels: `feat`, `chore`, `fase: v0.1`, `listener`
> Fase v0.1 — "lisa-listener: /api/dictate + /api/health → whisper → {text}" (§12 v0.1, item 3). Health = metade do §11.2 item 1.

**Contexto:** fundação do listener: server :8080 (HTTP/HTTPS), cliente do whisper-server :8081, health com ping real e supervisão com restart (§11.2, item 4).

**DoD (pai)**
- [ ] `GET /api/health` com `protocol`, `whisper.up`, `whisper.model` — versão mínima do §11.2 item 1 (inject e db entram nas fases deles)
- [ ] whisper client (`apps/listener/src/whisper/client.ts`) com `POST /inference` + ping e timeouts
- [ ] listener reinicia o whisper-server se o ping falhar, spawn com backoff (§11.2, item 4)
- [ ] server sobe em HTTP e, com certs presentes (§S5), em HTTPS

**Filhas**

### #9.1 — `feat(listener): bootstrap Fastify (porta, multipart, https opcional)`
Labels: `feat`, `fase: v0.1`, `listener`
- Corpo: factory `buildServer()`: plugin multipart (@fastify/multipart), rotas por módulo (`routes/`), log pino nativo. HTTPS se `LISA_CERT`/`LISA_KEY` definidos (caminho mkcert do #S5).
- Aceite: sobe com e sem certs; rota inexistente → 404 JSON.

### #9.2 — `feat(listener): whisper client — POST /inference + ping`
Labels: `feat`, `fase: v0.1`, `listener`
- Corpo: `apps/listener/src/whisper/client.ts`: `transcribe(wav: Buffer)` (multipart para :8081) e `ping()` com timeout curto. Timeout configurável; falha de conexão → `WHISPER_DOWN`.
- Aceite: contra whisper real (#S4) transcreve fixture; contra porta morta → `WHISPER_DOWN`.

### #9.3 — `feat(listener): GET /api/health — ping whisper + versão do protocolo`
Labels: `feat`, `fase: v0.1`, `listener`
- Corpo: `routes/health.ts` retornando o `HealthResponse` do shared: `protocol`, `whisper: { up, model }` (lendo `WHISPER_MODEL_PATH`), `inject: null`, `db: null`, `version`. Ping com cache curto (não pingar a cada request).
- Aceite: whisper up → `up: true` + caminho do modelo; whisper down → `up: false` sem derrubar o health.

### #9.4 — `feat(listener): supervisão do whisper-server (spawn + backoff)`
Labels: `feat`, `fase: v0.1`, `listener`
- Corpo: módulo que, com ping falhando N vezes, faz `spawn` do `scripts/run-whisper.sh` com backoff exponencial (cap 60s), logando cada tentativa. Flag de env para desabilitar.
- Aceite: matar o whisper manualmente → listener reinicia em ≤ 2 min e health volta a `up: true` (§11.2, item 4).

**Dependências:** #S1, #S3, #S7 (contrato de health).

---

## #S10 — `feat(listener): POST /api/dictate — modo display end-to-end` — criação nº 10

Labels: `feat`, `fase: v0.1`, `listener`
> Fase v0.1 — núcleo do loop: WAV → whisper → `{text}` exibível no app.

**Contexto:** §6: multipart `{audio: WAV}` + `X-Lisa-Mode: display` → valida WAV, chama whisper, responde `{ok: true, mode: 'display', text}`. Erros: `WAV_INVALID` e `WHISPER_DOWN`.

**DoD (pai)**
- [ ] `POST /api/dictate` com WAV válido + `X-Lisa-Mode: display` → `{ok: true, mode: 'display', text}` (§12 v0.1, item 3)
- [ ] WAV inválido → `{ok: false, error: {code: 'WAV_INVALID'}}`; whisper down → `WHISPER_DOWN`
- [ ] modo ainda não suportado (inject/save) → erro tipado do shared, não crash
- [ ] testes unit com fake whisper cobrindo feliz + 2 erros

**Filhas**

### #10.1 — `feat(listener): rota dictate — multipart + validação de WAV`
Labels: `feat`, `fase: v0.1`, `listener`
- Corpo: `routes/dictate.ts`: extrai buffer + `X-Lisa-Mode` + `Z-Lisa-Client`, valida com `validateWav` do packages/audio. WAV inválido → `WAV_INVALID` com detail.
- Aceite: curl com WAV válido passa adiante; PNG renomeado → `WAV_INVALID`.

### #10.2 — `feat(listener): dictate display — integração com o whisper client`
Labels: `feat`, `fase: v0.1`, `listener`
- Corpo: no modo `display`, chama `transcribe()` e responde a variante display do shared. `WHISPER_DOWN` do cliente; medições de latência preparadas p/ #S16.
- Aceite: dictate via curl (fixture) com server real retorna texto PT-BR coerente.

### #10.3 — `test(listener): suite vitest com fake whisper-server`
Labels: `test`, `fase: v0.1`, `listener`
- Corpo: fake whisper em `tests/listener/` + testes: feliz, `WAV_INVALID`, `WHISPER_DOWN`, modo desconhecido.
- Aceite: cobre todos os branches de resposta; roda em CI sem whisper real.

**Dependências:** #S7, #S8, #S9.

---

## #S11 — `feat(web): scaffold PWA no monorepo + settings do host` — criação nº 11

Labels: `feat`, `fase: v0.1`, `web`
> Fase v0.1 — antes de gravar, o app precisa saber onde está o listener (§7.2, tela Settings).

**Contexto:** a PWA guarda o endereço do host em localStorage (§7.1) e testa conectividade com `/api/health`. Sem login, sem cadastro.

**DoD (pai)**
- [ ] `apps/web` integrado ao turbo (`dev` paralelo com listener) — base do item 4 do §12 v0.1
- [ ] settings persiste endereço do host + modo default em localStorage (§7.1)
- [ ] teste de conectividade chama `/api/health` e mostra status (§7.2, tela 2)

**Filhas**

### #11.1 — `feat(web): shell do app — rotas + layout base`
Labels: `feat`, `fase: v0.1`, `web`
- Corpo: rotas mínimas (Gravar + Settings-sheet), layout mobile-first (viewport, safe-areas), cliente fetch base resolvido do host configurado.
- Aceite: app renderiza no Safari mobile com viewport correto, sem zoom indesejado.

### #11.2 — `feat(web): settings.ts — host + modo default em localStorage`
Labels: `feat`, `fase: v0.1`, `web`
- Corpo: leitura/escrita de `hostUrl` e `defaultMode` em localStorage, com validação de URL (`http(s)://`).
- Aceite: reload preserva valores; URL inválida rejeitada com mensagem.

### #11.3 — `feat(web): tela Settings — campo host + teste de conectividade`
Labels: `feat`, `fase: v0.1`, `web`
- Corpo: campo do host + botão "testar" chamando `/api/health` (tipos do shared) — mostra status, modelo e `protocol`. Divergência de `health.protocol` vs `LISA_PROTOCOL_VERSION` → banner "atualize o listener" (§6).
- Aceite: host correto mostra verde + modelo; host errado mostra vermelho com dica; divergência de protocolo mostra banner.

**Dependências:** #S1 (esqueleto, 1.4), #S7.

---

## #S12 — `feat(web): captura de áudio — AudioWorklet + downsample + WAV` — criação nº 12

Labels: `feat`, `fase: v0.1`, `web`, `audio`
> Fase v0.1 — coração do cliente: mic → Float32 → 16k mono → WAV (§3, §7.1). AudioWorklet, não ScriptProcessor (deprecated).

**Contexto:** `getUserMedia` + AudioWorklet coletam Float32; downsample e encode usam `packages/audio`; o WAV gerado é o que sobe no dictate.

**DoD (pai)**
- [ ] gravar e parar gera `ArrayBuffer` WAV 16k mono decodável (§12 v0.1, item 4)
- [ ] captura via AudioWorkletNode (§7.1 — nada de ScriptProcessor)
- [ ] testes unit do caminho numérico passam sem device real

**Filhas**

### #12.1 — `feat(web): recorder.ts — getUserMedia + ciclo grave/stop`
Labels: `feat`, `fase: v0.1`, `web`
- Corpo: `recorder.ts`: pede mic, cria AudioContext + AudioWorkletNode carregando `worklet.ts`, acumula chunks Float32, expõe `start()` / `stop(): Promise<Float32Array>`. Mic denegado → erro tipado local.
- Aceite: gravar 3s no Safari iOS retorna Float32Array com duração correta.

### #12.2 — `feat(web): worklet.ts — coleta de amostras no AudioWorklet`
Labels: `feat`, `fase: v0.1`, `web`, `audio`
- Corpo: worklet em `src/audio/worklet.ts` postando blocos Float32 ao main thread (transferable), sem alocação por processamento.
- Aceite: gravação de 30s sem glitch audível; desconexão do device limpa sem travar.

### #12.3 — `feat(web): pipeline stop → downsample → WAV (via packages/audio)`
Labels: `feat`, `fase: v0.1`, `web`, `audio`
- Corpo: wrapper web: Float32 acumulado → `downsampleTo16k` → `encodeWav` do package. Expõe também o tamanho em bytes (audio_size) p/ telemetria.
- Aceite: WAV gerado passa no `validateWav` do mesmo package (roundtrip).

### #12.4 — `test(web): unit do pipeline de áudio`
Labels: `test`, `fase: v0.1`, `web`, `audio`
- Corpo: cobre chunk → merge → downsample → encode com mocks de AudioContext (ou testando o caminho puro no packages).
- Aceite: roda em CI sem device real.

**Dependências:** #S8, #S11.

---

## #S13 — `feat(web): tela Gravar — fluxo display completo` — criação nº 13

Labels: `feat`, `fase: v0.1`, `web`
> Fase v0.1 — fecha o loop visível: fale → transcript aparece no app (§1, v0.1).

**Contexto:** §7.2 tela 1: botão grande, indicação de gravação, preview do transcript, status do round-trip e last-request log (latência, tamanho do WAV).

**DoD (pai)**
- [ ] fluxo completo: gravar → stop → upload → transcript exibido (§12 v0.1, item 4)
- [ ] status visível: gravando → enviando → transcrevendo → entregue/erro (§7.2)
- [ ] last-request log mostra latência e tamanho do WAV (§7.2 — telemetria do piloto)
- [ ] toggle de modo visível, com "Só mostrar" funcional (Injetar/Salvar desabilitados com hint "v0.2/v0.3")

**Filhas**

### #13.1 — `feat(web): botão mic + pulso + timer de gravação`
Labels: `feat`, `fase: v0.1`, `web`
- Corpo: botão central grande, estados idle/gravando, anel pulsante, timer `mm:ss`. Área de toque ≥ 48px (§11.3, item 4), layout estável em landscape.
- Aceite: estados visuais distintos; transição grave↔stop sem re-render pesado.

### #13.2 — `feat(web): api/dictate.ts — upload binário do WAV`
Labels: `feat`, `fase: v0.1`, `web`
- Corpo: cliente fetch: multipart com blob WAV (Content-Type `audio/wav`), headers `X-Lisa-Mode` e `Z-Lisa-Client: web/1.0`; parse da `DictateResponse` com schema do shared. Mede a duração do request (latência).
- Aceite: resposta ok e erro tipadas; timeout de rede vira erro tratável.

### #13.3 — `feat(web): preview do transcript + máquina de status`
Labels: `feat`, `fase: v0.1`, `web`
- Corpo: máquina de estados `idle → recording → uploading → transcribing → done | error` refletida na UI; transcript em preview com fonte grande.
- Aceite: cada transição visível; erro renderiza mensagem da issue 15.1.

### #13.4 — `feat(web): last-request log (latência + tamanho do WAV)`
Labels: `feat`, `fase: v0.1`, `web`
- Corpo: card discreto pós-request: latência total (ms), tamanho do WAV (KB), modo — dados que alimentam o benchmark (#S18).
- Aceite: valores batem com o log server-side do listener na mesma request.

**Dependências:** #S10, #S12.

---

## #S14 — `feat(web): PWA instalável (manifest + ícones + service worker)` — criação nº 14

Labels: `feat`, `fase: v0.1`, `web`
> Realiza §11.3 item 1 — "PWA instalável, testada adicionar na home em iOS e Android".

**Contexto:** §7.1: `manifest.webmanifest` (ícones, standalone, orientação livre) + SW mínimo de app shell. Gravação não funciona offline de qualquer forma (aceito na spec).

**DoD (pai)**
- [ ] ícone na home, abrindo standalone (§11.3, item 1)
- [ ] manifest com `display: standalone`, orientação livre, ícones 192/512 + maskable
- [ ] SW cacheia o app shell; `/api/*` nunca cacheado

**Filhas**

### #14.1 — `feat(web): manifest.webmanifest + ícones`
Labels: `feat`, `fase: v0.1`, `web`
- Corpo: manifest (nome lisa, standalone, orientação `any`, theme/color, ícones 192/512 + maskable) e ícones gerados.
- Aceite: DevTools/lighthouse apontam manifest válido e instalável.

### #14.2 — `feat(web): service worker mínimo (cache de app shell)`
Labels: `feat`, `fase: v0.1`, `web`
- Corpo: `public/sw.js`: cache-first para shell (index/assets), network-only para `/api/*`; bump de versão no deploy. Offline com shell servido → mensagem clara que a API não responde.
- Aceite: reload offline após 1 visita carrega o shell; chamadas de API nunca cacheadas.

### #14.3 — `docs: validação de instalação iOS + Android`
Labels: `docs`, `fase: v0.1`, `web`
- Corpo: seção em docs/setup.md com os passos e prints de "Adicionar à Tela de Início" no iOS e Android, e verificação standalone (§11.3, item 1).
- Aceite: instalado e testado em iOS Safari e Android Chrome, prints anexados no PR.

**Dependências:** #S11.

---

## #S15 — `feat(web): robustez do cliente — erros legíveis, secure context, reconexão` — criação nº 15

Labels: `feat`, `fase: v0.1`, `web`
> Realiza §11.2 item 2 (erros legíveis) e §11.3 itens 2–4 (secure context inline, reconexão, a11y).

**Contexto:** para uso real na mão: HTTP puro bloqueia mic — o app precisa instruir o setup (§7.4); host offline precisa de re-teste e aborto limpo; erros do protocolo viram frases humanas.

**DoD (pai)**
- [ ] erros tratados com mensagem legível: whisper down, WAV inválido, host inacessível (timeout) — inject sem permissão entra em v0.2 (§11.2, item 2)
- [ ] tela instrui setup quando `!window.isSecureContext && origin não é localhost` (§11.3, item 2 / §7.4)
- [ ] botão re-testa `/api/health` quando offline; gravação aborta com mensagem em vez de acumular buffer (§11.3, item 3)
- [ ] botão mic com área mínima de 48px, funciona em landscape (§11.3, item 4)

**Filhas**

### #15.1 — `feat(web): mapa LisaErrorCode → mensagem legível`
Labels: `feat`, `fase: v0.1`, `web`
- Corpo: helper convertendo `LisaError` (shared) em mensagem de UI + ação sugerida (ex.: `WHISPER_DOWN` → "whisper-server não respondeu; veja o health"). Erro de rede/timeout → "host inacessível".
- Aceite: cada código do shared tem mensagem própria renderizada no preview de erro.

### #15.2 — `feat(web): guard de secure context com instrução de setup`
Labels: `feat`, `fase: v0.1`, `web`
- Corpo: na tela Gravar, se `!isSecureContext && origin não é localhost`: bloquear mic e mostrar card com as duas opções (Tailscale Serve / mkcert), apontando para docs/setup.md.
- Aceite: aberto por HTTP em IP LAN → gravação bloqueada com instrução; em HTTPS/localhost → fluxo normal.

### #15.3 — `feat(web): reconexão — re-test de health + aborto de buffer offline`
Labels: `feat`, `fase: v0.1`, `web`
- Corpo: health falhando (ou dictate falhando por rede) → banner "host offline" + botão re-testar. Novo toque no mic com host offline descarta o buffer com mensagem, não acumula (§11.3, item 3).
- Aceite: matar o listener em uso → banner com re-test; listener volta → re-test verde e fluxo retoma.

### #15.4 — `feat(web): a11y — touch targets e landscape`
Labels: `feat`, `fase: v0.1`, `web`
- Corpo: 48px de área mínima no mic e controles, layout funcional em portrait e landscape (§11.3, item 4), contraste dos estados.
- Aceite: teste manual nos dois dispositivos-alvo com screenshots no PR.

**Dependências:** #S13.

---

## #S16 — `chore(listener): logging estruturado com pino` — criação nº 16

Labels: `chore`, `fase: v0.1`, `listener`
> Realiza §12 v0.1 item 6 (logging de latência) e §11.2 item 3.

**Contexto:** §11.2 item 3: cada dictate loga latência total + latência whisper + latência inject + tamanho do WAV + modo + sucesso/falha. (inject fica `null` até v0.2.)

**DoD (pai)**
- [ ] cada dictate loga uma linha estruturada com os campos do §11.2 item 3 (§12 v0.1, item 6)
- [ ] logs pino com request-id; health loga pings lentos (> 1s)

**Filhas**

### #16.1 — `chore(listener): setup pino (nível, transport, request-id)`
Labels: `chore`, `fase: v0.1`, `listener`
- Corpo: pino configurado (nível por env, pretty em dev), request-id por request propagado entre hooks e rotas.
- Aceite: logs JSON legíveis no terminal do dev.

### #16.2 — `feat(listener): log de dictate — latências + tamanho + modo + sucesso`
Labels: `feat`, `fase: v0.1`, `listener`
- Corpo: por request de dictate: latência total, latência whisper, `inject: null` (campo reservado), audio_size, mode, ok/erro com code.
- Aceite: 1 request = 1 linha com todos os campos (ou null documentado).

**Dependências:** #S9, #S10.

---

## #S17 — `chore: make smoke — teste end-to-end real via curl` — criação nº 17

Labels: `chore`, `test`, `fase: v0.1`, `listener`
> Realiza §12 v0.1 item 6 ("make smoke") e §11.4 item 4 (smoke script e2e real com WAV fixture via curl).

**Contexto:** diferente dos unit: sobe com whisper real e valida o loop server-side inteiro com um WAV fixture, num único comando.

**DoD (pai)**
- [ ] `make smoke` roda o ciclo real: listener + whisper + `POST /api/dictate` com fixture → transcript JSON válido (§11.4, item 4)
- [ ] exit code ≠ 0 em qualquer passo falho (server não sobe, resposta sem `text`, erro de protocolo)

**Filhas**

### #17.1 — `chore(tests): fixtures WAV de fala (3s/10s) commitadas`
Labels: `chore`, `fase: v0.1`, `test`, `audio`
- Corpo: 2 fixtures WAV PT-BR (≈3s e ≈10s) em `tests/fixtures/`, 16k mono, geradas pelo mesmo pipeline do app.
- Aceite: fixtures passam no `validateWav` e são transcritas pelo whisper com texto esperado aproximado.

### #17.2 — `chore(make): script make smoke (spawn + curl + asserções)`
Labels: `chore`, `fase: v0.1`, `test`
- Corpo: `scripts/smoke.sh` + target `make smoke`: sobe listener (e whisper, se não estiver de pé), espera o health, envia a fixture com `X-Lisa-Mode: display`, asserta a resposta e derruba os processos.
- Aceite: `make smoke` verde com stack real; falha clara se o whisper não sobe.

**Dependências:** #S9, #S10, #S4.

---

## #S18 — `docs: benchmark de latência do loop básico` — criação nº 18

Labels: `docs`, `fase: v0.1`
> Realiza §11.4 item 1 — benchmark documentado: grave→texto na tela, frases de 3s/10s/20s, alvo < 2s no stop (~15s de frase).

**Contexto:** o piloto existe para medir. Fontes dos números: last-request log (#13.4) + logs pino (#S16).

**DoD (pai)**
- [ ] latência registrada para frases de 3s/10s/20s, com breakdown (rede + whisper) (§11.4, item 1)
- [ ] `docs/benchmark.md` com método (n runs, device, rede) e resultados — alvo declarado: < 2s no stop para ~15s de frase
- [ ] resultado fora do alvo documentado como gap, não escondido

**Filhas**

### #18.1 — `docs: protocolo de medição de latência`
Labels: `docs`, `fase: v0.1`
- Corpo: método: dispositivo, rede (mesma LAN/Wi-Fi), frases de teste, nº de repetições, quais campos do last-request log/pino usar.
- Aceite: qualquer pessoa reproduz a medição lendo só o doc.

### #18.2 — `docs: docs/benchmark.md com resultados do loop v0.1`
Labels: `docs`, `fase: v0.1`
- Corpo: tabela de resultados (3s/10s/20s × n runs), comparação com o alvo < 2s, observações (modelo, Metal, rede).
- Aceite: resultados colhidos do log real (não estimados), PR com link para os runs.

**Dependências:** #S13, #S16 mergeados (telemetria no app e nos logs).

---

# ÉPICO 2 — v0.2: Inject no desktop (milestone v0.2)

---

## #S19 — `feat(inject): clipboard — snapshot e write no packages/inject` — criação nº 19

Labels: `feat`, `fase: v0.2`, `inject`
> Fase v0.2 — "packages/inject: clipboard + paste + restauração + permissão de Acessibilidade" (§12 v0.2, item 1). Lib pura, sem Fastify (§5).

**Contexto:** passo 1 e 2 do §8: ler o clipboard atual (com timestamp) e escrever o transcript (`pbcopy` via spawn). Sanitização por construção: só texto no clipboard, sem execução por shell (§10).

**DoD (pai)**
- [ ] `packages/inject/src/clipboard.ts`: `getClipboard(): { text, changeCount }` e `setClipboard(text)` via pbcopy/pbpaste (spawn)
- [ ] conteúdo nunca interpolado em shell string (spawn com array de args — §10)
- [ ] testes unit com macOS mockado (§11.4, item 4)

**Filhas**

### #19.1 — `feat(inject): clipboard.ts — get/set via pbcopy/pbpaste (spawn seguro)`
Labels: `feat`, `fase: v0.2`, `inject`
- Corpo: `getClipboard()` (texto + changeCount) e `setClipboard(text)` com `spawn('pbcopy', [])` + stdin — nunca string interpolada em shell. Erros de processo mapeados para erros do pacote.
- Aceite: set→get roundtrip preserva acentos/emoji; teste de sanitização cobre string com `"; rm -rf` sem efeito colateral.

### #19.2 — `test(inject): suite vitest com macOS mockado`
Labels: `test`, `fase: v0.2`, `inject`
- Corpo: mock de `child_process`/osascript com respostas determinísticas; testes de clipboard, erros de spawn e timeouts (§11.4, item 4).
- Aceite: `pnpm test` cobre o pacote sem macOS real (CI roda em Linux).

**Dependências:** #S1 (esqueleto, 1.3).

---

## #S20 — `feat(inject): Cmd+V — helper nativo Swift (CGEventPost)` — criação nº 20

Labels: `feat`, `fase: v0.2`, `inject`
> Fase v0.2 — passo 3 do §8: Cmd+V simulado; 1ª preferência é helper Swift compilado no setup.

**Contexto:** §8: Cmd+V via helper Swift (`CGEventPost`), compilado no `make setup`; AppleScript fica como fallback (issue #S21).

**DoD (pai)**
- [ ] `packages/inject/src/paste.ts` dispara Cmd+V via helper Swift compilado no setup
- [ ] helper compila no `make setup` — erro claro se faltar Xcode CLT ou Acessibilidade
- [ ] Cmd+V chegando ao app em foco, validado manualmente (Safari + VS Code)

**Filhas**

### #20.1 — `feat(inject): helper Swift (CGEventPost) + paste.ts`
Labels: `feat`, `fase: v0.2`, `inject`
- Corpo: fonte Swift mínima (`sendCmdV`) usando CGEventPost para keyDown/keyUp de V com flag Command; `paste.ts` invoca o binário compilado em path estável.
- Aceite: com Acessibilidade concedida ao processo chamador, Cmd+V colará no app em foco (teste manual documentado no PR).

### #20.2 — `chore(make): compilação do helper Swift no make setup`
Labels: `chore`, `fase: v0.2`, `inject`, `infra`
- Corpo: ativa o passo reservado em 6.3: compila o helper Swift → binário no path do pacote; falha com instrução se faltar toolchain.
- Aceite: `make setup` em máquina nova produz o binário; sem o binário, paste.ts falha com erro tipado (não crash).

**Dependências:** #S19, #S6 (target make setup).

---

## #S21 — `feat(inject): fallback AppleScript keystroke + strategy flag` — criação nº 21

Labels: `feat`, `fase: v0.2`, `inject`, `listener`
> Fase v0.2 — §3/§8: fallback `keystroke` tipo-a-tipo para campos que ignoram paste, escolhível por request (`x-lisa-inject-strategy`).

**Contexto:** §8 prevê o fallback por flag no request. A implementação entra aqui; a validação extensiva ("testado") é o checkbox v0.4 (#S32).

**DoD (pai)**
- [ ] `packages/inject` suporta as estratégias `type` (AppleScript keystroke, char a char) e `paste` (helper/Cmd+V)
- [ ] listener respeita o header `x-lisa-inject-strategy: paste | type`
- [ ] `type` validado manualmente em 1 app que bloqueia paste

**Filhas**

### #21.1 — `feat(inject): fallback type — osascript keystroke char a char`
Labels: `feat`, `fase: v0.2`, `inject`
- Corpo: `typeText(text)`: osascript `System Events` `keystroke` por caractere (sanitização p/ chars especiais), limite de tamanho e log de progresso.
- Aceite: digita texto com acentos no Notes; texto acima do limite aborta com erro (evita digitação descontrolada).

### #21.2 — `feat(inject): paste.ts seleciona estratégia (paste | type)`
Labels: `feat`, `fase: v0.2`, `inject`
- Corpo: `injectText(text, strategy)` unificado: `paste` → clipboard + Cmd+V (restore fecha em #S22), `type` → 21.1.
- Aceite: mesma assinatura p/ as duas estratégias; switch coberto por teste mockado.

### #21.3 — `feat(listener): header x-lisa-inject-strategy na rota dictate`
Labels: `feat`, `fase: v0.2`, `listener`
- Corpo: parse do header (default da config `INJECT_STRATEGY`), repassado ao inject; valor desconhecido → erro do shared.
- Aceite: curl com `x-lisa-inject-strategy: type` usa digitação; sem header usa o default.

**Dependências:** #S20 (paste base), #S7 (headers do protocolo).

---

## #S22 — `feat(inject): restauração de clipboard + race de cópia concorrente` — criação nº 22

Labels: `feat`, `fase: v0.2`, `inject`
> Realiza §8 passo 4 e §11.4 item 3 — "restauração de clipboard funciona sob cópia concorrente do usuário".

**Contexto:** §8: delay de 300–500ms após o Cmd+V → restaura o clipboard anterior, exceto se o usuário copiou algo novo nesse intervalo (detecção via changeCount).

**DoD (pai)**
- [ ] após o inject, clipboard restaurado ao conteúdo anterior (§12 v0.2, item 1 — restauração)
- [ ] clipboard mudado durante o delay (cópia do usuário) → restaura NÃO roda (§11.4, item 3)
- [ ] teste automatizado do cenário de cópia concorrente (mock changeCount)

**Filhas**

### #22.1 — `feat(inject): restoreClipboard — snapshot → delay → restore`
Labels: `feat`, `fase: v0.2`, `inject`
- Corpo: no fluxo paste do `injectText`: captura snapshot + changeCount antes; restaura após delay configurável (300–500ms, §8); timer limpo em abort.
- Aceite: manual — copiar algo antes do ditado, ditar, clipboard volta ao anterior (§11.4, item 3).

### #22.2 — `feat(inject): race de cópia concorrente (changeCount guard)`
Labels: `feat`, `fase: v0.2`, `inject`
- Corpo: antes de restaurar, re-ler changeCount: mudou desde o snapshot → usuário copiou → pula restore, com log. Teste mockado dos dois desfechos (§11.4, item 3).
- Aceite: simulação de cópia durante o delay preserva o conteúdo novo do usuário; teste unit passa.

**Dependências:** #S19, #S20.

---

## #S23 — `feat(inject): permissão de Acessibilidade + CLI lisa-inject` — criação nº 23

Labels: `feat`, `fase: v0.2`, `inject`
> Realiza §12 v0.2 item 1 (parte permissão) e §5 — CLI `lisa-inject "texto"`: o pacote que migra para o pepper.

**Contexto:** §8: Acessibilidade p/ o processo do listener; checagem com teste real (inject de 1 caractere + undo) alimentará o `/api/health` (#S24).

**DoD (pai)**
- [ ] `packages/inject/src/detect-permissions.ts`: check real de Acessibilidade com resultado `ok | no_permission | failed`
- [ ] CLI `lisa-inject "texto"` funciona standalone (sem listener) — bin linkado
- [ ] nenhum import de Fastify/Express em `packages/inject` (régua do §5)

**Filhas**

### #23.1 — `feat(inject): detect-permissions — check real inject + undo`
Labels: `feat`, `fase: v0.2`, `inject`
- Corpo: `checkAccessibility()`: tenta inject de 1 caractere seguido de undo e reporta ok/no_permission/failed conforme o comportamento observado (§8).
- Aceite: sem permissão → `no_permission`; após conceder → `ok` sem recompilar.

### #23.2 — `feat(inject): CLI lisa-inject "texto" (bin standalone)`
Labels: `feat`, `fase: v0.2`, `inject`
- Corpo: `cli.ts` com o texto como arg + flags (`--strategy`, `--no-restore`), bin `lisa-inject`; exit codes espelham os resultados do check.
- Aceite: `lisa-inject "olá"` cola o texto no app em foco do Mac com o listener desligado (prova do desacoplamento §5).

### #23.3 — `docs(inject): instruções de concessão de Acessibilidade`
Labels: `docs`, `fase: v0.2`, `inject`
- Corpo: seção nos docs com print do System Settings → Privacy → Accessibility, o processo correto a permitir e o re-test via CLI.
- Aceite: sair de `no_permission` para `ok` seguindo só o doc.

**Dependências:** #S20, #S21.

---

## #S24 — `feat(listener): modo INJECT end-to-end + health com check real` — criação nº 24

Labels: `feat`, `fase: v0.2`, `listener`, `inject`
> Fase v0.2 — o desafio central da spec: texto no campo em foco do Mac (§1, v0.2).

**Contexto:** §6: variante inject da resposta (`{injected, detail}`); §8/§11.2 item 1: `/api/health` roda o check real de permissão e reporta `inject: ok | no_permission | failed`.

**DoD (pai)**
- [ ] `POST /api/dictate` com `X-Lisa-Mode: inject`: transcreve → injeta → `{ok: true, mode: 'inject', injected: true, text}` (§12 v0.2, item 2 — lado server)
- [ ] sem permissão → `{injected: false, error: {code: 'INJECT_NO_PERMISSION'}}`; falha técnica → `INJECT_FAILED` (§6)
- [ ] `/api/health` reporta `inject: ok | no_permission | failed` com check real (§11.2, item 1)
- [ ] sanitização: transcript só via spawn com array de args, nunca shell string (§10)

**Filhas**

### #24.1 — `feat(listener): fluxo inject na rota dictate`
Labels: `feat`, `fase: v0.2`, `listener`
- Corpo: no modo `inject`, após transcribe: chama `injectText` do `@lisa/inject` (strategy do header) e constrói a variante inject da resposta com `{injected, detail}`.
- Mapeamento `INJECT_NO_PERMISSION` vs `INJECT_FAILED` dos erros do pacote.
- Aceite: ditar em modo Inject com o Safari em foco cola o texto no Mac e o app mostra `injected: true`.

### #24.2 — `feat(listener): health inject — check real de Acessibilidade`
Labels: `feat`, `fase: v0.2`, `listener`
- Corpo: `/api/health` consome `checkAccessibility()` (23.1), com resultado cacheado por alguns minutos (o check real é invasivo — inject+undo a cada ping não). Campo `inject: null` da v0.1 vira valor real (§11.2, item 1).
- Aceite: health reflete o estado real da permissão; revogada → `no_permission` e o app (#25.3) orienta.

### #24.3 — `test(listener): inject com packages/inject mockado`
Labels: `test`, `fase: v0.2`, `listener`
- Corpo: testes da rota inject com o pacote mockado: feliz, `no_permission`, `failed`, strategy inválida.
- Aceite: cobre todos os branches de resposta sem macOS real.

**Dependências:** #S10, #S21, #S22, #S23.

---

## #S25 — `feat(web): modo Injetar na PWA` — criação nº 25

Labels: `feat`, `fase: v0.2`, `web`
> Fase v0.2 — o usuário escolhe Injetar e vê o feedback de entrega (fluxo §7.3).

**Contexto:** §7.2: toggle 3 modos; §7.3: feedback "texto entregue" + latência; erros de inject com guia de permissão.

**DoD (pai)**
- [ ] toggle Injetar/Salvar/Só mostrar — Injetar funcional end-to-end (§12 v0.2, item 2)
- [ ] sucesso mostra "texto entregue" + latência; `injected: false` mostra o motivo (§7.3)
- [ ] `INJECT_NO_PERMISSION` explica como conceder (link para os docs); `INJECT_FAILED` mensagem clara (§11.2, item 2 — caso inject)

**Filhas**

### #25.1 — `feat(web): toggle de modo (Injetar | Salvar | Só mostrar)`
Labels: `feat`, `fase: v0.2`, `web`
- Corpo: seletor na tela Gravar, ligado ao `defaultMode` das settings (11.2); Salvar desabilitado com hint "v0.3" até #S30. Header `X-Lisa-Mode` conforme a seleção.
- Aceite: troca de modo persiste entre sessões; header correto na request.

### #25.2 — `feat(web): feedback de entrega do inject + latência`
Labels: `feat`, `fase: v0.2`, `web`
- Corpo: no modo inject: `injected: true` → toast/card "texto entregue" com a latência do last-request log; `injected: false` → detalhe da falha.
- Aceite: fluxo §7.3 completo visível (gravando → … → texto entregue).

### #25.3 — `feat(web): erros INJECT_* legíveis + guia de permissão`
Labels: `feat`, `fase: v0.2`, `web`
- Corpo: estende o mapa de erros (15.1) com `INJECT_NO_PERMISSION` (Acessibilidade + link dos docs) e `INJECT_FAILED` (sugere re-testar o health).
- Aceite: permissão revogada → erro orienta até resolver; health no app reflete `no_permission`.

**Dependências:** #S13, #S24.

---

## #S26 — `test: e2e Playwright do modo display (whisper fake)` — criação nº 26

Labels: `test`, `fase: v0.2`, `web`, `listener`
> Realiza §12 v0.2 item 4 e §11.4 item 4 (e2e Playwright contra a PWA em desktop, mic simulado).

**Contexto:** §5: `tests/e2e/` Playwright contra a PWA em desktop, com mic simulado e fake whisper-server — regressão do loop sem device real.

**DoD (pai)**
- [ ] e2e do fluxo display passa headless (rodável em CI — §12 v0.2, item 4)
- [ ] fake whisper-server determinístico (texto fixo por fixture) — sem rede real no teste
- [ ] cenário de erro (whisper down → mensagem legível na UI) coberto

**Filhas**

### #26.1 — `test(e2e): setup Playwright + fake whisper + mic simulado`
Labels: `test`, `fase: v0.2`, `web`
- Corpo: config Playwright (desktop chromium/webkit), fake whisper (mock determinístico em porta alternativa), permissão de mic via launch flags/fake device.
- Aceite: `pnpm e2e` sobe web + listener (fake whisper) e abre a PWA em secure context (localhost).

### #26.2 — `test(e2e): fluxo feliz display — gravar → transcript na tela`
Labels: `test`, `fase: v0.2`, `web`
- Corpo: script: clicar mic, gravar ~2s (áudio fake), stop, assertar transcript do fake na tela e status "entregue" (§11.4, item 4).
- Aceite: verde headless; job separado do unit no CI.

### #26.3 — `test(e2e): erro whisper down — mensagem legível na UI`
Labels: `test`, `fase: v0.2`, `web`
- Corpo: fake whisper morto → dictate → mensagem de `WHISPER_DOWN` visível e legível (§11.2, item 2, lado client).
- Aceite: teste verde assertando a mensagem exata.

**Dependências:** #S13, #S16.

---

## #S27 — `docs: matriz de inject nos 5 apps` — criação nº 27

Labels: `docs`, `fase: v0.2`, `inject`
> Realiza §12 v0.2 item 3 e §8 — matriz em `docs/inject-matrix.md`, validação em Safari, Obsidian, VS Code, Notes, Slack.

**Contexto:** §8 lista os edge cases a medir: apps que bloqueiam paste, race de cópia, apps sandboxed. O registro estruturado alimenta o relatório do piloto (#S33) e a estratégia de fallback (#S32).

**DoD (pai)**
- [ ] `docs/inject-matrix.md` com linha por app × colunas: paste, type, race de clipboard, latência
- [ ] 5 apps medidos com resultados registrados — sem célula vazia ("não testável" vale, com motivo) (§12 v0.2, item 3 / §11.4, item 2)
- [ ] conclusões acionáveis no fim do doc (quais apps exigem strategy type)

**Filhas**

### #27.1 — `docs: template da docs/inject-matrix.md`
Labels: `docs`, `fase: v0.2`, `inject`
- Corpo: template da matriz (5 apps × experimentos do §8) + instruções de como rodar cada célula (CLI lisa-inject, app em foco, cópias concorrentes).
- Aceite: template commitado; qualquer pessoa reproduz um experimento.

### #27.2 — `docs: resultados da matriz — 5 apps medidos`
Labels: `docs`, `fase: v0.2`, `inject`
- Corpo: executar e registrar Safari, Obsidian, VS Code, Notes, Slack — paste / type / race / latência por app (§8, §11.4 item 2).
- Aceite: matriz completa; apps com paste bloqueado com estratégia alternativa recomendada.

**Dependências:** #S23 (CLI), #S24 (modo inject no listener).

---

# ÉPICO 3 — v0.3: Modo salvar (milestone v0.3)

---

## #S28 — `feat(db): SQLite com schema espelhado do pepper` — criação nº 28

Labels: `feat`, `fase: v0.3`, `db`
> Fase v0.3 — "SQLite + schema espelhado do pepper (§9)" (§12 v0.3, item 1). Migração trivial p/ o pepper é o porquê do espelho.

**Contexto:** §9: `transcriptions` (id UUID, title derivada da 1ª frase, text, audio_size, source='dictation', created_at) em SQLite no `~/Library/Application Support/lisa/lisa.db` — fora do repo. Campos espelham o pepper, menos `user_id` (copy + preencher na migração).

**DoD (pai)**
- [ ] DB em `~/Library/Application Support/lisa/` (respeita `LISA_DB_PATH`), nada no repo (§12 v0.3, item 1)
- [ ] schema `transcriptions` idêntico ao §9 (§12 v0.3, item 1)
- [ ] `title` derivada automaticamente da primeira frase
- [ ] repository em `apps/listener/src/db/` com testes

**Filhas**

### #28.1 — `feat(db): better-sqlite3 + bootstrap do DB no caminho do usuário`
Labels: `feat`, `fase: v0.3`, `db`, `listener`
- Corpo: dependência `better-sqlite3`, abertura do DB no path de config (cria diretório se não existir), WAL mode, migração v1 do schema.
- Aceite: subir o listener cria o `lisa.db` no lugar certo; nada de DB no repo (.gitignore já cobre).

### #28.2 — `feat(db): schema transcriptions espelhado do pepper + title derivada`
Labels: `feat`, `fase: v0.3`, `db`
- Corpo: DDL do §9 (`id` UUID PK, `title` derivada da 1ª frase, `text`, `audio_size`, `source` default 'dictation', `created_at`), com comentário no código apontando o `user_id` ausente e o passo da migração (§9).
- Aceite: schema batendo coluna-a-coluna com §9; migração p/ pepper vira copy + fill de `user_id`.

### #28.3 — `feat(db): repository (insert/get/list/delete) + vitest`
Labels: `feat`, `fase: v0.3`, `db`, `test`
- Corpo: `apps/listener/src/db/` com functions tipadas de acesso; testes com DB temporário em tmp.
- Aceite: CRUD coberto por testes; roda em CI (SQLite não depende de serviço).

**Dependências:** #S3 (path na config), #S7 (erros — `DB_ERROR`).

---

## #S29 — `feat(listener): modo SAVE em /api/dictate + rotas /api/notes` — criação nº 29

Labels: `feat`, `fase: v0.3`, `db`, `listener`
> Fase v0.3 — "rotas /api/notes (GET lista, DELETE)" (§12 v0.3, item 2) + wire do modo save + health do DB (§11.2, item 1).

**Contexto:** §6: modo `save` responde `{ok: true, mode: 'save', text, id}`; §9 persiste com `source: 'dictation'`. Sem lista no app (§7.2) — as rotas são para debug e o pepper.

**DoD (pai)**
- [ ] `X-Lisa-Mode: save` → INSERT com title derivada → resposta com `id`
- [ ] `GET /api/notes` (lista) e `DELETE /api/notes/:id` (§12 v0.3, item 2)
- [ ] `/api/health` reporta `db: ok | error` (§11.2, item 1 — parte DB)
- [ ] `DB_ERROR` em qualquer falha de DB (§6)

**Filhas**

### #29.1 — `feat(listener): modo save → INSERT + resposta com id`
Labels: `feat`, `fase: v0.3`, `db`, `listener`
- Corpo: ramificar `routes/dictate.ts` p/ save: transcreve, INSERT com audio_size, retorna `{mode: 'save', text, id}`. Erros de banco → `DB_ERROR`.
- Aceite: ditar com save persiste a linha correta (source dictation, title derivada) e o id volta para o app.

### #29.2 — `feat(listener): GET /api/notes (lista)`
Labels: `feat`, `fase: v0.3`, `db`, `listener`
- Corpo: rota GET com paginação simples (limit/offset), registros por created_at desc; contrato da rota adicionado ao `packages/shared`.
- Aceite: curl lista o que foi salvo; limit com cap sanável.

### #29.3 — `feat(listener): DELETE /api/notes/:id`
Labels: `feat`, `fase: v0.3`, `db`, `listener`
- Corpo: DELETE por id; 404 com erro do shared quando não existe; deleção física (piloto).
- Aceite: criar → deletar → listar confirma a remoção; id inexistente → 404 JSON.

### #29.4 — `feat(listener): health db — check real de conexão`
Labels: `feat`, `fase: v0.3`, `db`, `listener`
- Corpo: campo `db` do health vira real: query barata (SELECT 1) com resultado ok/error, cache curto.
- Aceite: DB indisponível → health `error`; de volta → `ok`.

**Dependências:** #S28, #S10 (rota dictate base).

---

## #S30 — `feat(web): modo Salvar na PWA` — criação nº 30

Labels: `feat`, `fase: v0.3`, `web`
> Fase v0.3 — "Toggle modo Salvar + feedback no app" (§12 v0.3, item 3). Sem lista/CRUD no app (§7.2: "sem lista") — o feedback é o registro salvo.

**Contexto:** o toggle já existe desde #S25; aqui o modo Salvar vira funcional, com feedback do registro salvo e tratamento de `DB_ERROR`.

**DoD (pai)**
- [ ] modo Salvar funcional end-to-end: ditar → salvo → feedback com id (§12 v0.3, item 3)
- [ ] `DB_ERROR` com mensagem legível (§11.2, item 2 — caso db)
- [ ] nenhuma UI de lista/CRUD no app (fora de escopo — §1)

**Filhas**

### #30.1 — `feat(web): wire modo Salvar + feedback do registro`
Labels: `feat`, `fase: v0.3`, `web`
- Corpo: habilita a opção Salvar no toggle (25.1), envia `X-Lisa-Mode: save`, feedback mostra "salvo" + id curto.
- Aceite: ditar com Salvar grava no DB e mostra a confirmação; last-request log atualiza igual.

### #30.2 — `feat(web): erro DB_ERROR legível`
Labels: `feat`, `fase: v0.3`, `web`
- Corpo: mapa de erros (15.1) com `DB_ERROR` → "não foi possível salvar; veja o health do listener".
- Aceite: DB indisponível (renomear o arquivo) → mensagem adequada no app.

**Dependências:** #S25, #S29.

---

# ÉPICO 4 — v0.4: Polimento (opcional — alimenta pepper)

> Milestone v0.4 criado só quando o piloto for declarado bem-sucedido.

---

## #S31 — `feat(web): VAD (Silero) no browser` — criação nº 31

Labels: `feat`, `fase: v0.4`, `web`
> Fase v0.4 — "VAD (Silero) no browser — para o roadmap v1.x do pepper" (§12 v0.4, item 1). Experimento: avaliar antes de virar default.

**Contexto:** §3: VAD não entra no piloto — Silero é polimento e insumo p/ a decisão do pepper. Feature flag, default off; botão stop manual segue sendo o caminho principal.

**DoD (pai)**
- [ ] VAD Silero no browser detecta fim de fala e para a gravação (§12 v0.4, item 1)
- [ ] toggle off por default (flag no app); stop manual segue funcionando igual
- [ ] nota de avaliação documentada (latência, falsos positivos em PT-BR) p/ o roadmap v1.x do pepper

**Filhas**

### #31.1 — `feat(web): VAD Silero com stop automático`
Labels: `feat`, `fase: v0.4`, `web`
- Corpo: integração do VAD Silero (no browser, modelo wasm) no `recorder.ts`: com a flag ativa, `stop()` dispara no silêncio pós-fala.
- Aceite: frase finalizada encerra a gravação sozinha em tempo plausível.

### #31.2 — `feat(web): feature toggle do VAD (default off)`
Labels: `feat`, `fase: v0.4`, `web`
- Corpo: flag nas settings (localStorage) + UI discreta; default off.
- Aceite: off não regrediu nada no fluxo manual do v0.1.

### #31.3 — `docs: avaliação do VAD p/ pepper v1.x`
Labels: `docs`, `fase: v0.4`
- Corpo: doc curto com o que medir (precisão de corte, latência, custo do modelo no device) e conclusão preliminar p/ o roadmap do pepper.
- Aceite: recomendação escrita (adotar / adiar / descartar) com dados dos testes.

**Dependências:** #S13 (ciclo de gravação consolidado).

---

## #S32 — `feat(inject): fallback keystroke validado (matriz + testes)` — criação nº 32

Labels: `feat`, `docs`, `fase: v0.4`, `inject`
> Fase v0.4 — "Fallback keystroke tipo-a-tipo testado" (§12 v0.4, item 2). Implementado em v0.2 (#S21); aqui é a validação a fundo.

**Contexto:** transforma o fallback de "funciona em 1 app" para "validado nos apps da matriz", sustentado por testes unit.

**DoD (pai)**
- [ ] testes unit do fallback `type` cobrem chars especiais/acentos/limites (§11.4, item 4)
- [ ] células de fallback preenchidas na matriz nos apps que bloqueiam paste (§12 v0.4, item 2)
- [ ] recomendação de strategy default por app registrada (#S27)

**Filhas**

### #32.1 — `test(inject): fallback type — cobertura de chars especiais e limites`
Labels: `test`, `fase: v0.4`, `inject`
- Corpo: testes mockados de `typeText` com acentos, emoji, aspas, limite de tamanho e abortos.
- Aceite: roda sem macOS; cobre os casos que travam o `keystroke`.

### #32.2 — `docs(inject): células de fallback na matriz + strategy por app`
Labels: `docs`, `fase: v0.4`, `inject`
- Corpo: preencher na `docs/inject-matrix.md` (#S27) os resultados de `x-lisa-inject-strategy: type` por app; concluir qual default usar.
- Aceite: matriz sem célula vazia na coluna de fallback; recomendação registrada.

**Dependências:** #S21, #S27 mergeados.

---

## #S33 — `docs: relatório do piloto + extração do packages/inject standalone` — criação nº 33

Labels: `docs`, `feat`, `fase: v0.4`, `inject`
> Fase v0.4 — "Relatório do piloto: o que migrou/decidiu p/ o pepper + extração de packages/inject como módulo standalone" (§12 v0.4, item 3). O piloto existe p/ gerar isto.

**Contexto:** §2/§5: o que migra para o pepper é o server-side (listener + inject) extraído como pacote — `packages/inject` nunca dependeu de framework por isso.

**DoD (pai)**
- [ ] `docs/pilot-report.md` com decisões, números (benchmark, matriz) e o que migra (§12 v0.4, item 3)
- [ ] `packages/inject` compilável/empacotável standalone: build próprio, README próprio, zero dependência de app/listener (§12 v0.4, item 3 / §5)
- [ ] caminho de extração do listener documentado (como vira pacote do pepper)

**Filhas**

### #33.1 — `docs: docs/pilot-report.md — conclusões e migrações p/ pepper`
Labels: `docs`, `fase: v0.4`
- Corpo: relatório: o que funcionou/não funcionou, latência real vs alvo (#S18), matriz de inject (#S27), decisões técnicas revisadas (§13), lista explícita "migra p/ pepper" (listener + packages/inject) e "fica no lisa".
- Aceite: doc aprovado como insumo do roadmap do pepper.

### #33.2 — `feat(inject): empacotamento standalone do packages/inject`
Labels: `feat`, `fase: v0.4`, `inject`
- Corpo: build/pack do pacote (`pnpm pack`) sem deps do monorepo, README próprio (uso como lib e CLI), revisão de imports (nenhum import de `@lisa/shared` se isso acoplar o pepper — decidir: tipos mínimos duplicados ou export em conjunto).
- Aceite: `pnpm pack` gera tarball instalável em outro projeto; CLI funciona a partir dele.

**Dependências:** #S27, #S32 e o fechamento do piloto (v0.1–v0.3).

---

## Cobertura — checklist §11 → issues

| Item §11 | Issue(s) |
|---|---|
| 11.1 `make setup` | #6.3 (#S6) |
| 11.1 `.env.example` + config zod | #S3 (3.1, 3.2) |
| 11.1 `make dev/build/lint/typecheck/test` | #1.1, #6.3 |
| 11.1 READMEs + docs/setup.md com prints | #6.1, #6.2 |
| 11.2 `/api/health` completo | #9.3 (whisper/protocolo) + #24.2 (inject) + #29.4 (db) |
| 11.2 erros legíveis no app | #15.1 (+ #25.3, #30.2 p/ inject/db) |
| 11.2 logs estruturados pino | #S16 |
| 11.2 restart do whisper com backoff | #9.4 |
| 11.3 PWA instalável | #S14 |
| 11.3 instrução de secure context | #15.2 |
| 11.3 reconexão + aborto de buffer | #15.3 |
| 11.3 acessibilidade 48px + landscape | #13.1 (botão), #15.4 |
| 11.4 benchmark de latência | #S18 |
| 11.4 matriz de inject, 5 apps | #S27 |
| 11.4 restauração de clipboard sob cópia | #22.2 |
| 11.4 testes unit audio, golden files | #8.4 |
| 11.4 testes unit inject, macOS mockado | #19.2 (+ #32.1) |
| 11.4 e2e Playwright display, fake whisper | #S26 |
| 11.4 `make smoke` curl fixture | #S17 |
| 11.5 CI GitHub Actions | #2.1 |
| 11.5 `.gitignore` | #2.2 |
| 11.5 licença + badge | #2.2 |

## Cobertura — roadmap §12 → slices

| Item §12 v0.1 | Slice |
|---|---|
| monorepo scaffold | #S1 |
| whisper-server setup | #S4 |
| listener dictate + health | #S9, #S10 |
| PWA worklet→WAV→upload→display | #S11, #S12, #S13 |
| HTTPS | #S5 |
| logging latência + make smoke | #S16, #S17 |

| Item §12 v0.2 | Slice |
|---|---|
| packages/inject completo | #S19–#S23 |
| modo Injetar + matrizes de erro | #S24, #S25 |
| matriz inject 5 apps | #S27 |
| e2e display | #S26 |

| Item §12 v0.3 | Slice |
|---|---|
| SQLite schema pepper | #S28 |
| /api/notes GET/DELETE | #S29 |
| toggle Salvar + feedback | #S30 |

| Item §12 v0.4 | Slice |
|---|---|
| VAD Silero | #S31 |
| fallback keystroke testado | #S32 |
| relatório + extração inject | #S33 |

## Decisões tomadas além da spec (p/ revisar)

1. **Faseação dos itens do §11** — o checklist não associa itens a fases. Distribuí: health/erros/logs/restart/PWA/robustez em v0.1 (loop usável), partes de inject em v0.2, health do DB em v0.3. Revisável.
2. **Fallback keystroke implementado em v0.2 (#S21), "testado" em v0.4 (#S32)** — §8 lista o fallback como decisão técnica (flag no protocolo) e §12 só valida em v0.4; separar impl × validação evita protocolo furado em v0.2.
3. **Toggle dos 3 modos entra em v0.2 (#25.1)** com Salvar desabilitado por hint — evita retrabalho de UI em v0.3. Alternativa: só 2 modos em v0.2.
4. **`/api/notes` só server, sem UI de lista** — §7.2 diz "sem lista" no app; GET/DELETE existem p/ debug e o pepper.
5. **`make setup` como filho de #S6** e não do scaffold — o target orquestra whisper + https (slices D), e o passo "compila helper Swift" fica reservado, ativando de fato em #20.2.
6. **Benchmark em v0.1 (#S18)** como slice de docs próprio — §11.4 não fixa fase; medir cedo dá dado p/ decisões de modelo/latência antes do inject.
7. **Método do benchmark e da matriz** (nº de runs, device) não definido na spec — issues #18.1 e #27.1 estabelecem o método antes de coletar números.
8. **Licença MIT presumida** — confirmar com a autora no #2.2.
