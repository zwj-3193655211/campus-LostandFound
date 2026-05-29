import axios from 'axios'

export function defaultOnUnauthorized() {
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  window.location.href = '/'
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
      return Promise.reject(payload?.message || '请求失败')
    },
    error => {
      if (error.response) {
        const { status, data } = error.response
        if (status === 401) {
          onUnauthorized()
        }
        return Promise.reject(data || error.message)
      }
      return Promise.reject(error)
    }
  )

  return instance
}

const instance = createApiClient()

export default instance
