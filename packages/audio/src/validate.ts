/**
 * WAV validation for uploads hitting `POST /api/dictate` (SPEC §4: "validates
 * WAV" before calling whisper-server) — PCM16 mono 16 kHz accepted; anything
 * else maps to the `WAV_INVALID` error from `@lisa/shared`.
 *
 * SKELETON — real implementation (header/magic/length checks) comes in the
 * dictate slice.
 */
export interface WavValidation {
  valid: boolean
  /** Human-readable rejection reason when `valid` is false. */
  reason?: string
}

/** Not implemented yet — see SPEC §3. */
export function validateWav(_bytes: Uint8Array): WavValidation {
  throw new Error('validateWav: not implemented yet')
}
