/**
 * Accessibility permission probe — the listener needs Accessibility
 * (System Settings → Privacy → Accessibility) to send `Cmd+V` (SPEC §8).
 * `GET /api/health` runs a real check and reports `inject: ok | no_permission
 * | failed` (SPEC §11.2).
 *
 * SKELETON — real implementation comes in the inject slice (v0.2).
 */

export type InjectPermission = 'ok' | 'no_permission' | 'failed'

/** Not implemented yet — see SPEC §8 (inject + undo in a testable field). */
export async function detectPermissions(): Promise<InjectPermission> {
  throw new Error('detectPermissions: not implemented yet')
}
