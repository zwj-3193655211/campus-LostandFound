import { defineStore } from 'pinia'
import axios from '../utils/axios'

export const useItemStore = defineStore('item', {
  state: () => ({
    items: [],
    currentItem: null,
    matches: [],
    userMap: {},
    categories: [
      { value: '电子产品', label: '电子产品' },
      { value: '证件', label: '证件' },
      { value: '书籍', label: '书籍' },
      { value: '衣物', label: '衣物' },
      { value: '饰品', label: '饰品' },
      { value: '文具', label: '文具' },
      { value: '其他', label: '其他' }
    ],
    locations: []
  }),

  actions: {
    async fetchItems(params = {}) {
      const requestParams = { ...params }
      if (requestParams.size && !requestParams.pageSize) {
        requestParams.pageSize = requestParams.size
        delete requestParams.size
      }

      const pageData = await axios.get('/items', { params: requestParams })
      this.items = pageData?.records || []
      return pageData
    },

    async fetchMyItems(params = {}) {
      const query = {
        page: params.page || 1,
        pageSize: params.pageSize || 20,
        ...params
      }
      return await axios.get('/items/my', { params: query })
    },

    async fetchItem(id) {
      const item = await axios.get(`/items/${id}`)
      this.currentItem = item
      return item
    },

    async createItem(data) {
      return await axios.post('/items', data)
    },

    async updateItem(id, data) {
      return await axios.put(`/items/${id}`, data)
    },

    async deleteItem(id) {
      return await axios.delete(`/items/${id}`)
    },

    async fetchLocations() {
      const locations = await axios.get('/locations')
      this.locations = locations || []
      return locations
    },

    async createLocation(data) {
      const location = await axios.post('/locations', data)
      await this.fetchLocations()
      return location
    },

    async updateLocation(id, data) {
      const location = await axios.put(`/locations/${id}`, data)
      await this.fetchLocations()
      return location
    },

    async deleteLocation(id) {
      const result = await axios.delete(`/locations/${id}`)
      await this.fetchLocations()
      return result
    },

    async fetchMatches(params = {}) {
      const query = {
        page: params.page || 1,
        pageSize: params.pageSize || 20,
        ...params
      }
      const pageData = await axios.get('/matches/recent', { params: query })
      this.matches = pageData?.records || []
      return pageData
    },



    async submitCompletionRequest(itemId, data) {
      return await axios.post(`/items/${itemId}/completion-request`, data)
    },

    async confirmMatch(matchId) {
      return await axios.put(`/matches/${matchId}/confirm`)
    },

    async rejectMatch(matchId, reason = '用户拒绝当前匹配') {
      return await axios.put(`/matches/${matchId}/reject`, null, {
        params: { reason }
      })
    },

    async fetchDashboardStats() {
      return await axios.get('/admin/statistics/dashboard')
    },

    async fetchPublicOverview() {
      return await axios.get('/statistics/overview')
    },

    async fetchPublicCategories() {
      return await axios.get('/statistics/categories')
    },

    async fetchTodayStats() {
      return await axios.get('/admin/statistics/today')
    },

    async fetchCategoryStats() {
      return await axios.get('/admin/statistics/categories')
    },

    async fetchLocationStats() {
      return await axios.get('/admin/statistics/locations')
    },

    async fetchPendingItems() {
      return await axios.get('/admin/items/pending')
    },

    /**
     * 管理员审核物品。后端实现是 PUT /api/admin/items/{id}/review。
     * @param {number} itemId
     * @param {boolean} approved
     * @param {string} [reason] 拒绝原因,仅当 approved=false 时使用
     */
    async verifyItem(itemId, approved, reason = '') {
      return axios.put(`/admin/items/${itemId}/review`, {
        approved,
        reason: approved ? undefined : (reason || '管理员审核未通过')
      })
    },

    async fetchCompletionRequests() {
      return await axios.get('/admin/completion-requests')
    },

    async reviewCompletionRequest(requestId, approved, reason = '') {
      return await axios.put(`/admin/completion-requests/${requestId}/review`, null, {
        params: { approved, reason: reason || undefined }
      })
    },

    async uploadItemImage(file) {
      const formData = new FormData()
      formData.append('image', file)
      const token = localStorage.getItem('token')
      const response = await fetch('/api/uploads/images', {
        method: 'POST',
        headers: token ? { Authorization: 'Bearer ' + token } : undefined,
        body: formData
      })
      const payload = await response.json()
      if (!response.ok || payload?.code !== 200) {
        throw payload?.message || payload?.error || '图片上传失败'
      }
      return payload.data
    },

    async fetchUsers() {
      return []
    },

    getUserName(userId) {
      const user = this.userMap[userId]
      return user?.username || user?.realName || '用户' + userId
    }
  }
})
