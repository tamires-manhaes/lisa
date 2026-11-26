/**
 * Clipboard write/restore for inject mode (SPEC §8 steps 1, 2 and 4):
 * capture the current clipboard (with timestamp) → write the transcript
 * (`pbcopy` via spawn or NSPasteboard wrapper) → after 300–500 ms, restore
 * the previous clipboard (unless the user copied something new meanwhile).
 *
 * SKELETON — real implementation comes in the inject slice (v0.2). This
 * package stays framework-free (no Fastify/Express) so it can ship standalone
 * as a pepper module (SPEC §5 rules).
 */

export interface ClipboardSnapshot {
  /** Text content of the clipboard at capture time, if any. */
  text: string
  /** When the snapshot was taken (epoch ms) — used for the restore race check. */
  capturedAt: number
}

/** Not implemented yet — see SPEC §8. */
export function captureClipboard(): ClipboardSnapshot {
  throw new Error('captureClipboard: not implemented yet')
}

/** Not implemented yet — see SPEC §8 (`pbcopy` via spawn). */
export async function writeClipboard(_text: string): Promise<void> {
  throw new Error('writeClipboard: not implemented yet')
}

/** Not implemented yet — see SPEC §8 (restore only if no newer user copy). */
export async function restoreClipboard(_snapshot: ClipboardSnapshot): Promise<void> {
  throw new Error('restoreClipboard: not implemented yet')
}
