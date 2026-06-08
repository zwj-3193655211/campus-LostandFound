import axios from 'axios'

export function defaultOnUnauthorized() {
  localStorage.removeItem('token')
  localStorage.removeItem('refreshToken')
  localStorage.removeItem('user')
  window.location.href = '/'
}

let isRefreshing = false
let failedQueue = []

const processQueue = (error, token = null) => {
  failedQueue.forEach(prom => {
    if (error) {
      prom.reject(error)
    } else {
      prom.resolve(token)
    }
  })
  failedQueue = []
}

export function createApiClient(options = {}) {
  const { baseURL = '/api', timeout = 10000, onUnauthorized = defaultOnUnauthorized } = options

  const instance = axios.create({
    baseURL,
    timeout,
    headers: {
      'Content-Type': 'application/json'
    }
  })

  instance.interceptors.request.use(
    config => {
      // 登录/注册等 auth 接口不需要带 token，避免脏 token 污染请求
      if (!config.url?.startsWith('/auth/')) {
        const token = localStorage.getItem('token')
        if (token) {
          config.headers['Authorization'] = 'Bearer ' + token
        }
      }
      return config
    },
    error => {
      return Promise.reject(error)
    }
  )

  instance.interceptors.response.use(
    response => {
      const payload = response.data
      if (payload?.code === 200) {
        return payload.data
      }
      // 其他业务错误码，构造统一错误对象
      const err = new Error(payload?.message || '请求失败')
      err.code = payload?.code
      err.data = payload?.data
      return Promise.reject(err)
    },
    async error => {
      const originalRequest = error.config
      const status = error.response?.status

      if (status === 401 && originalRequest && !originalRequest._retry) {
        if (isRefreshing) {
          return new Promise((resolve, reject) => {
            failedQueue.push({ resolve, reject })
          }).then(token => {
            originalRequest.headers['Authorization'] = 'Bearer ' + token
            return instance(originalRequest)
          }).catch(err => {
            return Promise.reject(err)
          })
        }

        originalRequest._retry = true
        isRefreshing = true

        try {
          const refreshToken = localStorage.getItem('refreshToken')
          if (!refreshToken) {
            throw new Error('No refresh token available')
          }

          // 用裸 axios（无响应拦截器），response.data = ApiResponse 外壳
          // 真正的数据在 response.data.data 里
          const response = await axios.post('/api/auth/refresh', { refreshToken })
          const innerData = response.data.data || response.data
          const { accessToken, refreshToken: newRefreshToken } = innerData

          localStorage.setItem('token', accessToken)
          if (newRefreshToken) {
            localStorage.setItem('refreshToken', newRefreshToken)
          }

          originalRequest.headers['Authorization'] = 'Bearer ' + accessToken
          processQueue(null, accessToken)
          return instance(originalRequest)
        } catch (refreshError) {
          processQueue(refreshError, null)
          // 清除过期token
          localStorage.removeItem('token')
          localStorage.removeItem('refreshToken')
          localStorage.removeItem('user')
          // 对于公开接口，不带token重试
          if (originalRequest) {
            delete originalRequest.headers['Authorization']
            return instance(originalRequest)
          }
          return Promise.reject(refreshError)
        } finally {
          isRefreshing = false
        }
      }

      if (status === 403) {
        // 403 可能是 Spring Security 的默认行为，检查是否是没有认证的情况
        // 如果是未认证的请求，不清除 token，直接拒绝
        console.warn('403 Forbidden - 请求被拒绝:', originalRequest?.url)
        return Promise.reject(error.response?.data || '请求被拒绝')
      }

      // 处理网络错误（error.response 为 undefined 的情况）
      if (!error.response) {
        return Promise.reject(new Error('网络请求失败，请检查网络连接'))
      }

      return Promise.reject(error.response?.data || error.message)
    }
  )

  return instance
}

const instance = createApiClient()

export default instance