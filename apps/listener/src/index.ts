import { createApp } from './app.js'

const app = createApp()

await app.listen({ port: 8080, host: '0.0.0.0' })
