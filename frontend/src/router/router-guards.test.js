import { describe, expect, it, vi } from 'vitest'
import { createAuthGuard } from './index'

describe('router auth guards', () => {
  it('should redirect to home when route requiresAuth and token is missing', () => {
    localStorage.clear()
    const guard = createAuthGuard()
    const next = vi.fn()

    guard({ meta: { requiresAuth: true }, fullPath: '/publish' }, {}, next)

    expect(next).toHaveBeenCalledWith({
      path: '/',
      query: {
        login: '1',
        toast: 'need_login',
        redirect: '/publish'
      }
    })
  })

  it('should redirect to home when route requiresAdmin and role is not admin', () => {
    localStorage.setItem('token', 't')
    localStorage.setItem('user', JSON.stringify({ role: 'USER' }))

    const guard = createAuthGuard()
    const next = vi.fn()

    guard({ meta: { requiresAuth: true, requiresAdmin: true } }, {}, next)

    expect(next).toHaveBeenCalledWith({
      path: '/',
      query: {
        toast: 'need_admin'
      }
    })
  })

  it('should allow navigation when role is CAMPUS_ADMIN', () => {
    localStorage.setItem('token', 't')
    localStorage.setItem('user', JSON.stringify({ role: 'CAMPUS_ADMIN' }))

    const guard = createAuthGuard()
    const next = vi.fn()

    guard({ meta: { requiresAuth: true, requiresAdmin: true } }, {}, next)

    expect(next).toHaveBeenCalledWith()
  })

  it('should clear invalid user json and treat as non-admin', () => {
    localStorage.setItem('token', 't')
    localStorage.setItem('user', '{')

    const guard = createAuthGuard()
    const next = vi.fn()

    guard({ meta: { requiresAuth: true, requiresAdmin: true } }, {}, next)

    expect(localStorage.getItem('user')).toBeNull()
    expect(next).toHaveBeenCalledWith({
      path: '/',
      query: {
        toast: 'need_admin'
      }
    })
  })
})
