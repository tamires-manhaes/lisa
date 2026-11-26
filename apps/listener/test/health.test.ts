import { describe, expect, it } from 'vitest'
import { LISA_PROTOCOL_VERSION } from '@lisa/shared'
import { createApp } from '../src/app.js'

describe('@lisa/listener smoke', () => {
  it('answers GET /api/health with the placeholder payload', async () => {
    const app = createApp()
    const res = await app.inject({ method: 'GET', url: '/api/health' })

    expect(res.statusCode).toBe(200)
    expect(res.json()).toEqual({
      ok: true,
      protocol: LISA_PROTOCOL_VERSION,
      availableModes: ['inject', 'save', 'display'],
    })
    await app.close()
  })
})
