import { describe, expect, it } from 'vitest'
import {
  captureClipboard,
  detectPermissions,
  paste,
  writeClipboard,
} from '../src/index.js'

describe('@lisa/inject smoke', () => {
  it('exposes stubbed lib surfaces until the inject slice lands (v0.2)', () => {
    expect(() => captureClipboard()).toThrowError('captureClipboard: not implemented yet')
    expect(writeClipboard('text')).rejects.toThrowError(
      'writeClipboard: not implemented yet',
    )
    expect(paste('paste')).rejects.toThrowError('paste: not implemented yet')
    expect(detectPermissions()).rejects.toThrowError(
      'detectPermissions: not implemented yet',
    )
  })
})
