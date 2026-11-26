/**
 * WAV encoder — PCM16 mono at 16 kHz (SPEC §3: same format as the pepper
 * pipeline; Float32 capture in the browser → downsample → WAV encode).
 *
 * SKELETON — real implementation (used by apps/web and validated against the
 * listener) comes in the dictate slice. Constants are final, so the pipeline
 * can be wired against them already.
 */

export const WAV_SAMPLE_RATE = 16_000
export const WAV_BITS_PER_SAMPLE = 16
export const WAV_CHANNELS = 1

export interface EncodeWavInput {
  /**
   * Interleaved mono samples in [-1, 1].
   */
  samples: Float32Array
  sampleRate?: number
}

/**
 * Encodes PCM float samples into a RIFF/WAVE byte buffer.
 * Not implemented yet — see SPEC §3 and §11.4 (golden-file tests).
 */
export function encodeWav(_input: EncodeWavInput): Uint8Array {
  throw new Error('encodeWav: not implemented yet')
}
