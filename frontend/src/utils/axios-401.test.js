import { describe, expect, it, vi, beforeEach } from 'vitest'
import { createApiClient, isPublicEndpoint } from './axios'

const reject401 = (config) => Promise.reject({
  config,
  response: { status: 401, data: { message: 'unauthorized' } }
})

describe('isPublicEndpoint', () => {
  it('recognizes public read-only endpoints', () => {
    expect(isPublicEndpoint('/items')).toBe(true)
    expect(isPublicEndpoint('/items/123')).toBe(true)
    expect(isPublicEndpoint('/items/123/related')).toBe(true)
    expect(isPublicEndpoint('/statistics/overview')).toBe(true)
    expect(isPublicEndpoint('/statistics/categories')).toBe(true)
    expect(isPublicEndpoint('/locations')).toBe(true)
    expect(isPublicEndpoint('/locations/suggestions')).toBe(true)
    expect(isPublicEndpoint('/uploads/images/xxx.jpg')).toBe(true)
  })

  it('does not treat protected endpoints as public', () => {
    // 我的物品列表需要登录
    expect(isPublicEndpoint('/items/my')).toBe(false)
    expect(isPublicEndpoint('/items/my', 'get')).toBe(false)
    // 用户 / 通知 / 匹配 / 管理接口
    expect(isPublicEndpoint('/users/profile')).toBe(false)
    expect(isPublicEndpoint('/notifications')).toBe(false)
    expect(isPublicEndpoint('/matches/recent')).toBe(false)
    expect(isPublicEndpoint('/admin/statistics/dashboard')).toBe(false)
  })

  it('only treats GET requests as public (写操作不算公开接口)', () => {
    expect(isPublicEndpoint('/items', 'post')).toBe(false)
    expect(isPublicEndpoint('/items/123/completion-request', 'post')).toBe(false)
    expect(isPublicEndpoint('/items/123', 'put')).toBe(false)
    expect(isPublicEndpoint('/items/123', 'delete')).toBe(false)
    expect(isPublicEndpoint('/locations', 'post')).toBe(false)
  })
})

describe('axios 401 handler', () => {
  beforeEach(() => {
    localStorage.clear()
  })

  it('calls onUnauthorized when refresh fails on a protected endpoint', async () => {
    const onUnauthorized = vi.fn()
    const client = createApiClient({ onUnauthorized })
    client.defaults.adapter = (config) => reject401(config)

    await expect(client.get('/users/profile')).rejects.toBeTruthy()
    expect(onUnauthorized).toHaveBeenCalledTimes(1)
    // 过期凭证被清除
    expect(localStorage.getItem('token')).toBeNull()
  })

  it('does not call onUnauthorized when status is not 401', async () => {
    const onUnauthorized = vi.fn()
    const client = createApiClient({ onUnauthorized })
    client.defaults.adapter = () =>
      Promise.reject({ response: { status: 500, data: { error: 'boom' } } })

    await expect(client.get('/x')).rejects.toBeTruthy()
    expect(onUnauthorized).not.toHaveBeenCalled()
  })

  it('retries public endpoint without token on 401 and keeps stored credentials', async () => {
    const onUnauthorized = vi.fn()
    const client = createApiClient({ onUnauthorized })
    localStorage.setItem('token', 'stale-token')
    localStorage.setItem('refreshToken', 'valid-refresh-token')

    let calls = 0
    client.defaults.adapter = (config) => {
      calls++
      if (calls === 1) {
        return reject401(config)
      }
      return Promise.resolve({ data: { code: 200, data: { ok: true } } })
    }

    const result = await client.get('/items')
    expect(result).toEqual({ ok: true })
    expect(onUnauthorized).not.toHaveBeenCalled()
    // 全局凭证必须保留：并发的受保护请求可能正要用 refreshToken 续期，
    // 公开接口的 401 只对当前请求去 token 重试，不清全局凭证
    expect(localStorage.getItem('token')).toBe('stale-token')
    expect(localStorage.getItem('refreshToken')).toBe('valid-refresh-token')
  })

  it('rejects public endpoint 401 without token without redirecting to login', async () => {
    const onUnauthorized = vi.fn()
    const client = createApiClient({ onUnauthorized })
    client.defaults.adapter = (config) => reject401(config)

    await expect(client.get('/statistics/overview')).rejects.toMatchObject({
      code: 401
    })
    expect(onUnauthorized).not.toHaveBeenCalled()
  })
})
