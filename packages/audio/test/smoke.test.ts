import { describe, expect, it } from 'vitest'
import {
  WAV_BITS_PER_SAMPLE,
  WAV_CHANNELS,
  WAV_SAMPLE_RATE,
  encodeWav,
  validateWav,
} from '../src/index.js'

describe('@lisa/audio smoke', () => {
  it('pins the pipeline constants (SPEC §3: PCM16 mono 16 kHz)', () => {
    expect(WAV_SAMPLE_RATE).toBe(16_000)
    expect(WAV_BITS_PER_SAMPLE).toBe(16)
    expect(WAV_CHANNELS).toBe(1)
  })

  it('exposes stubbed encode/validate until the dictate slice lands', () => {
    expect(() => encodeWav({ samples: new Float32Array(0) })).toThrowError(
      'encodeWav: not implemented yet',
    )
    expect(() => validateWav(new Uint8Array(8))).toThrowError(
      'validateWav: not implemented yet',
    )
  })
})
