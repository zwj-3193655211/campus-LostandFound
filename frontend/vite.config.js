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
    // 端口 3000 在 Windows 10 1903+ 上被 Hyper-V/WSL2/WinNAT 划入保留区
    // (见 `netsh int ipv4 show excludedportrange tcp`,3000 在 2945-3044 段),
    // 普通用户 bind 会 EACCES。换 5173(Vite 默认端口)避开。
    port: 5173,
    // 显式绑 IPv4 —— Windows 上 'localhost' 默认先解析 ::1,会触发 EACCES。
    // 强制 127.0.0.1 跳过 IPv6 环回,顺便跟 Vite 代理 target 的 127.0.0.1 对齐。
    host: '127.0.0.1',
    proxy: {
      '/api': {
        // 默认 18090: 避开 Windows Hyper-V/WSL 端口保留区 9045-9144 (含 9090)
        target: process.env.VITE_API_TARGET || 'http://127.0.0.1:18090',
        changeOrigin: true
      }
    }
  }
})
