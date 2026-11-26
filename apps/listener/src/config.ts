import { existsSync } from 'node:fs'
import path from 'node:path'

import { config as loadDotenv } from 'dotenv'
import { z } from 'zod'

// `.env` lives at the repo root (SPEC §11.1), but the listener can be booted
// from any cwd (pnpm filter exec, dist, watch) — so walk up and take the
// nearest one. Real env vars always win (dotenv never overrides).
let envFile: string | undefined
for (let dir = process.cwd(); ; dir = path.dirname(dir)) {
  const candidate = path.join(dir, '.env')
  if (existsSync(candidate)) {
    envFile = candidate
    break
  }
  if (dir === path.dirname(dir)) break
}
if (envFile) loadDotenv({ path: envFile, quiet: true })

/**
 * Listener env config (SPEC §11.1). No secrets — port, paths, flags only.
 * `.env` is loaded via dotenv when present; real env vars always win.
 */
const configSchema = z.object({
  PORT: z.coerce.number().int().positive().default(8080),
  WHISPER_URL: z.url().default('http://127.0.0.1:8081'),
  WHISPER_MODEL_PATH: z.string({ error: 'is required' }),
  LISA_DB_PATH: z.string().default('~/Library/Application Support/lisa/lisa.db'),
  INJECT_STRATEGY: z.enum(['paste', 'type']).default('paste'),
})

export type ListenerConfig = {
  port: number
  whisperUrl: string
  whisperModelPath: string
  lisaDbPath: string
  injectStrategy: 'paste' | 'type'
}

export class ConfigError extends Error {}

function formatIssues(issues: z.core.$ZodIssue[]): string {
  return issues
    .map((issue) => {
      const field = issue.path.map(String).join('.')
// zod v4: a required primitive missing from the env yields `invalid_type`
// without a `received` key (an invalid value keeps `received`).
      const missing = issue.code === 'invalid_type' && !('received' in issue)
      return missing ? `${field} is required` : `${field || '(env)'}: ${issue.message}`
    })
    .join(', ')
}

/** Pure parse — throws `ConfigError` naming the offending fields. */
export function parseConfig(env: NodeJS.ProcessEnv = process.env): ListenerConfig {
  const parsed = configSchema.safeParse(env)
  if (!parsed.success) {
    throw new ConfigError(`invalid listener env: ${formatIssues(parsed.error.issues)}`)
  }

  return {
    port: parsed.data.PORT,
    whisperUrl: parsed.data.WHISPER_URL,
    whisperModelPath: parsed.data.WHISPER_MODEL_PATH,
    lisaDbPath: parsed.data.LISA_DB_PATH,
    injectStrategy: parsed.data.INJECT_STRATEGY,
  }
}

/** Boot entry: parse the real env, print a readable error and exit(1) on failure. */
export function loadConfig(env: NodeJS.ProcessEnv = process.env): ListenerConfig {
  try {
    return parseConfig(env)
  } catch (err) {
    if (err instanceof ConfigError) {
      console.error(err.message)
      process.exit(1)
    }
    throw err
  }
}
