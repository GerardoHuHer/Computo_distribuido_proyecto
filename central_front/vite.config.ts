import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const middlewareUrl = env.VITE_MIDDLEWARE_URL || 'http://localhost:4000'

  return {
    plugins: [react()],
    server: {
      proxy: {
        // Mismo patrón que nginx.conf en producción: el front pide siempre
        // rutas relativas /api/* y algo más adelante las reenvía al
        // middleware, así nunca hay que lidiar con CORS.
        '/api': {
          target: middlewareUrl,
          changeOrigin: true,
        },
      },
    },
  }
})
