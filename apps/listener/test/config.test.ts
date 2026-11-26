import { describe, expect, it } from 'vitest'
import { parseConfig, ConfigError, type ListenerConfig } from '../src/config.js'

describe('@lisa/listener config', () => {
  it('applies the defaults (SPEC §11.1) and accepts only the model path', () => {
    const config = parseConfig({ WHISPER_MODEL_PATH: '/models/ggml-large-v3-turbo.bin' })

    expect(config).toEqual<ListenerConfig>({
      port: 8080,
      whisperUrl: 'http://127.0.0.1:8081',
      whisperModelPath: '/models/ggml-large-v3-turbo.bin',
      lisaDbPath: '~/Library/Application Support/lisa/lisa.db',
      injectStrategy: 'paste',
    })
  })

  it('fails naming WHISPER_MODEL_PATH when it is missing', () => {
    expect(() => parseConfig({})).toThrow(ConfigError)
    expect(() => parseConfig({})).toThrow(/WHISPER_MODEL_PATH is required/)
  })

  it('rejects an unknown INJECT_STRATEGY', () => {
    expect(() => parseConfig({ WHISPER_MODEL_PATH: '/m.bin', INJECT_STRATEGY: 'pasteboard' }))
      .toThrow(/INJECT_STRATEGY/)
  })

  it('coerces PORT and accepts INJECT_STRATEGY=type', () => {
    const config = parseConfig({
      PORT: '9000',
      WHISPER_MODEL_PATH: '/m.bin',
      INJECT_STRATEGY: 'type',
    })

    expect(config.port).toBe(9000)
    expect(config.injectStrategy).toBe('type')
  })
})
