/**
 * Paste simulation on macOS (SPEC §8 step 3), in order of preference:
 * 1. native Swift helper compiled at setup (`CGEventPost`);
 * 2. AppleScript `System Events keystroke 'v' using command down`;
 * 3. fallback: `keystroke` type-as-you-type for apps that block paste
 *    (`x-lisa-inject-strategy: type`, slow — SPEC §8).
 *
 * SKELETON — real implementation comes in the inject slice (v0.2).
 */

export type InjectStrategy = 'paste' | 'type'

export interface InjectResult {
  injected: boolean
  /** Which mechanism actually performed the injection (telemetry/debug). */
  detail?: string
}

/** Not implemented yet — see SPEC §8 (CGEvent helper, then AppleScript). */
export async function paste(
  _strategy: InjectStrategy = 'paste',
): Promise<InjectResult> {
  throw new Error('paste: not implemented yet')
}
