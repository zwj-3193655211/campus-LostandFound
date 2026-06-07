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
      const token = localStorage.getItem('token')
      if (token) {
        config.headers['Authorization'] = 'Bearer ' + token
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
      const { status } = error.response

      if (status === 401 && !originalRequest._retry) {
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

          const response = await axios.post('/api/auth/refresh', { refreshToken })
          const { accessToken, refreshToken: newRefreshToken } = response.data

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
        // 清除无效token并重试公开接口
        localStorage.removeItem('token')
        localStorage.removeItem('refreshToken')
        localStorage.removeItem('user')
        if (originalRequest) {
          delete originalRequest.headers['Authorization']
          return instance(originalRequest)
        }
        onUnauthorized()
      }

      return Promise.reject(error.response?.data || error.message)
    }
  )

  return instance
}

const instance = createApiClient()

export default instance