/**
 * App ↔ listener contract (SPEC §6).
 *
 * SKELETON — full protocol (DictateResponse, /api/dictate payload, zod schemas)
 * is implemented in the dictate slice. Only the version constant lives here for
 * now so apps can wire the protocol-version check (SPEC §6: "update the
 * listener" banner when client and listener versions diverge).
 */
export const LISA_PROTOCOL_VERSION = 1

/** Requested delivery mode for a dictation (header `X-Lisa-Mode`). */
export type LisaMode = 'inject' | 'save' | 'display'
