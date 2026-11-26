/**
 * Typed error codes shared by listener and web (SPEC §6).
 *
 * SKELETON — the LisaError class / serialization is implemented in the
 * dictate slice; for now these are the codes that every slice must respect.
 */
export const LISA_ERROR_CODES = [
  'WAV_INVALID',
  'WHISPER_DOWN',
  'INJECT_NO_PERMISSION',
  'INJECT_FAILED',
  'DB_ERROR',
] as const

export type LisaErrorCode = (typeof LISA_ERROR_CODES)[number]
