import type { LisaErrorCode } from './errors.js'

/** Canonical error shape shared by every listener response (SPEC §6). */
export interface LisaError {
  code: LisaErrorCode
  message?: string
}
