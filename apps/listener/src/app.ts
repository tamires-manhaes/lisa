import Fastify from 'fastify'
import { LISA_PROTOCOL_VERSION, type LisaMode } from '@lisa/shared'

/**
 * lisa-listener :8080 (SPEC §4). Boot-only skeleton — whisper orchestration,
 * inject, persistence and config (zod) come in later slices.
 */
export function createApp() {
  const app = Fastify({
    logger: true,
  })

  // Placeholder health — full checks (whisper ping, inject permission, db)
  // land in a later slice (SPEC §11.2). `/health` alias kept for the v0.1
  // smoke convention (`curl localhost:8080/health`).
  const health = async () => ({
    ok: true,
    protocol: LISA_PROTOCOL_VERSION,
    availableModes: ['inject', 'save', 'display'] satisfies LisaMode[],
  })

  app.get('/api/health', health)

  app.get('/health', health)

  return app
}
