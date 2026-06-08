import { defineStore } from 'pinia'
import axios from '../utils/axios'

export const useNotificationStore = defineStore('notification', {
  state: () => ({
    notifications: [],
    unreadCount: 0
  }),

  actions: {
    async fetchNotifications() {
      try {
        const pageData = await axios.get('/notifications')
        this.notifications = pageData?.records || []
        const unreadData = await axios.get('/notifications/unread-count')
        this.unreadCount = unreadData || 0
        return pageData
      } catch (error) {
        console.warn('获取通知失败:', error)
        this.notifications = []
        this.unreadCount = 0
        return null
      }
    },

    async markAsRead(id) {
      try {
        const result = await axios.post(`/notifications/${id}/read`)
        const notification = this.notifications.find(n => n.id === id)
        if (notification) {
          notification.isRead = true
          this.unreadCount = Math.max(0, this.unreadCount - 1)
        }
        return result
      } catch (error) {
        console.warn('标记已读失败:', error)
        return null
      }
    },

    async markAllAsRead() {
      try {
        const result = await axios.post('/notifications/read-all')
        this.notifications.forEach(n => n.isRead = true)
        this.unreadCount = 0
        return result
      } catch (error) {
        console.warn('标记全部已读失败:', error)
        return null
      }
    }
  }
})
