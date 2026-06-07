import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  },
  test: {
    environment: 'jsdom',
    include: ['src/**/*.test.{js,ts}'],
    setupFiles: ['src/tests/setup.js']
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (!id.includes('node_modules')) {
            return
          }
          if (id.includes('element-plus') || id.includes('@element-plus/icons-vue')) {
            return 'ui-vendor'
          }
          if (id.includes('vue-router') || id.includes('pinia') || id.includes('axios')) {
            return 'app-vendor'
          }
          if (id.includes('vue')) {
            return 'vue-vendor'
          }
        }
      }
    }
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        // 默认 18090: 避开 Windows Hyper-V/WSL 端口保留区 9045-9144 (含 9090)
        target: process.env.VITE_API_TARGET || 'http://127.0.0.1:18090',
        changeOrigin: true
      }
    }
  }
})
