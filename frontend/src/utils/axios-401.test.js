import { describe, expect, it, vi } from 'vitest'
import { createApiClient } from './axios'

describe('axios 401 handler', () => {
  it('should call onUnauthorized when response status is 401', async () => {
    const onUnauthorized = vi.fn()
    const client = createApiClient({ onUnauthorized })
    client.defaults.adapter = () =>
      Promise.reject({ response: { status: 401, data: { message: 'unauthorized' } } })

    await expect(client.get('/x')).rejects.toEqual({ message: 'unauthorized' })
    expect(onUnauthorized).toHaveBeenCalledTimes(1)
  })

  it('should not call onUnauthorized when status is not 401', async () => {
    const onUnauthorized = vi.fn()
    const client = createApiClient({ onUnauthorized })
    client.defaults.adapter = () => Promise.reject({ response: { status: 500, data: { error: 'boom' } } })

    await expect(client.get('/x')).rejects.toEqual({ error: 'boom' })
    expect(onUnauthorized).not.toHaveBeenCalled()
  })
})

