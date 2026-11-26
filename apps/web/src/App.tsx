import { LISA_PROTOCOL_VERSION } from '@lisa/shared'

/**
 * Placeholder screen — the record screen (mic, modes, transcript) is the
 * dictate slice (SPEC §7.2). Importing `@lisa/shared` validates the
 * apps/* → packages/* dep graph (SPEC §5).
 */
export default function App() {
  return (
    <main>
      <h1>lisa</h1>
      <p>placeholder — dictation pilot (protocol v{LISA_PROTOCOL_VERSION})</p>
    </main>
  )
}
