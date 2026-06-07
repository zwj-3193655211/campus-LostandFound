import { defineStore } from 'pinia'
import axios from '../utils/axios'

const loadStoredUser = () => {
  const storedUser = localStorage.getItem('user')
  if (!storedUser) {
    return null
  }

  try {
    return JSON.parse(storedUser)
  } catch (error) {
    localStorage.removeItem('user')
    return null
  }
}

export const useUserStore = defineStore('user', {
  state: () => ({
    user: loadStoredUser(),
    token: localStorage.getItem('token') || null,
    refreshToken: localStorage.getItem('refreshToken') || null
  }),

  getters: {
    isLoggedIn: (state) => !!state.token,
    isAdmin: (state) => {
      const role = state.user?.role
      return role === 'CAMPUS_ADMIN' || role === 'SUPER_ADMIN'
    }
  },

  actions: {
    persistAuth() {
      if (this.token) {
        localStorage.setItem('token', this.token)
      } else {
        localStorage.removeItem('token')
      }

      if (this.refreshToken) {
        localStorage.setItem('refreshToken', this.refreshToken)
      } else {
        localStorage.removeItem('refreshToken')
      }

      if (this.user) {
        localStorage.setItem('user', JSON.stringify(this.user))
      } else {
        localStorage.removeItem('user')
      }
    },

    setAuth(data) {
      this.token = data?.token || data?.accessToken || null
      this.refreshToken = data?.refreshToken || null
      this.user = data?.user || null
      this.persistAuth()
    },

    setUser(user) {
      this.user = user
      this.persistAuth()
    },

    clearAuth() {
      this.token = null
      this.refreshToken = null
      this.user = null
      this.persistAuth()
    },

    clearUser() {
      this.clearAuth()
    },

    async login(username, password) {
      const data = await axios.post('/auth/login', { username, password })
      this.setAuth(data)
      return data
    },

    async register(data) {
      return await axios.post('/auth/register', data)
    },

    /**
     * 发送注册验证码到目标邮箱。
     * 后端 60 秒冷却:data=true 真正发送,data=false 冷却中。
     */
    async sendRegisterCode(email) {
      return await axios.post('/auth/send-register-code', { email })
    },

    async logout() {
      this.clearAuth()
    },

    async updateProfile(data) {
      const profile = await axios.put('/users/profile', data)
      this.user = { ...this.user, ...profile }
      this.persistAuth()
      return profile
    },

    async changePassword(oldPassword, newPassword) {
      return await axios.post('/users/change-password', {
        oldPassword,
        newPassword
      })
    },

    async verifyIdentity(realName, idCard) {
      const profile = await axios.post('/users/verify', {
        realName,
        idCard
      })
      this.user = { ...this.user, ...profile }
      this.persistAuth()
      return profile
    },

    async fetchPendingIdentityVerifications() {
      return await axios.get('/admin/identity-verifications')
    },

    async fetchIdentityVerificationHistory() {
      return await axios.get('/admin/identity-verifications/history')
    },

    async reviewIdentityVerification(requestId, approved, reason = '') {
      return await axios.put(`/admin/identity-verifications/${requestId}/review`, null, {
        params: { approved, reason: reason || undefined }
      })
    },

    async forgotPassword(email) {
      throw new Error('后端暂未实现找回密码功能')
    },

    async updateNotificationSettings(settings) {
      const profile = await axios.put('/users/notification-settings', settings)
      this.user = { ...this.user, ...profile }
      this.persistAuth()
      return profile
    },

    loadUserFromStorage() {
      this.user = loadStoredUser()
      this.token = localStorage.getItem('token') || null
    }
  }
})
