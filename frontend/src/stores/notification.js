import { defineStore } from 'pinia'
import axios from '../utils/axios'

export const useNotificationStore = defineStore('notification', {
  state: () => ({
    notifications: [],
    unreadCount: 0
  }),

  actions: {
    async fetchNotifications() {
      const pageData = await axios.get('/notifications')
      this.notifications = pageData?.records || []
      this.unreadCount = await axios.get('/notifications/unread-count')
      return pageData
    },

    async markAsRead(id) {
      const result = await axios.post(`/notifications/${id}/read`)
      const notification = this.notifications.find(n => n.id === id)
      if (notification) {
        notification.isRead = true
        this.unreadCount = Math.max(0, this.unreadCount - 1)
      }
      return result
    },

    async markAllAsRead() {
      const result = await axios.post('/notifications/read-all')
      this.notifications.forEach(n => n.isRead = true)
      this.unreadCount = 0
      return result
    }
  }
})
