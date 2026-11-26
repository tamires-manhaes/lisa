import { describe, expect, it } from 'vitest'
import { LISA_ERROR_CODES, LISA_PROTOCOL_VERSION, type LisaErrorCode } from '../src/index.js'

describe('@lisa/shared smoke', () => {
  it('exposes the protocol version constant', () => {
    expect(LISA_PROTOCOL_VERSION).toBeTypeOf('number')
    expect(LISA_PROTOCOL_VERSION).toBeGreaterThanOrEqual(1)
  })

  it('exposes the canonical error codes (SPEC §6)', () => {
    const codes: readonly LisaErrorCode[] = LISA_ERROR_CODES
    expect(codes).toContain('WAV_INVALID')
    expect(codes).toContain('INJECT_NO_PERMISSION')
  })
})
