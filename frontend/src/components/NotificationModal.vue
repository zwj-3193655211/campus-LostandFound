<template>
  <Teleport to="body">
    <Transition name="dialog-fade">
      <div v-if="modelValue" class="notification-overlay" @click.self="handleOverlayClick">
        <div class="notification-dialog">
          <div class="notification-dialog-header">
            <h3 class="notification-dialog-title">
                <el-icon><Message /></el-icon>
                通知消息
                <span class="unread-count" v-if="unreadCount > 0">{{ unreadCount }} 条未读</span>
              </h3>
              <div class="header-actions">
                <el-button @click="handleMarkAllRead" size="small" type="default">全部标为已读</el-button>
                <el-button circle text @click="handleClose">
                  <el-icon><CircleCheck /></el-icon>
                </el-button>
              </div>
          </div>
          
          <div class="notification-body">
            <!-- 左侧：通知列表 -->
            <div class="notification-sidebar">
              <div class="sidebar-tabs">
                <el-button 
                  @click="activeTab = 'all'" 
                  :class="{ active: activeTab === 'all' }"
                  size="small"
                >
                  全部 ({{ notifications.length }})
                </el-button>
                <el-button 
                  @click="activeTab = 'unread'" 
                  :class="{ active: activeTab === 'unread' }"
                  size="small"
                >
                  未读 ({{ unreadCount }})
                </el-button>
              </div>
              
              <div class="notification-list">
                <div v-if="filteredNotifications.length === 0" class="empty-state">
                  <el-icon :size="48" class="empty-icon"><Bell /></el-icon>
                  <p>暂无通知</p>
                </div>
                
                <div 
                  v-for="notification in filteredNotifications" 
                  :key="notification.id"
                  class="notification-item"
                  :class="{ 'active': selectedNotification?.id === notification.id, 'unread': !notification.isRead }"
                  @click="selectNotification(notification)"
                >
                  <div class="notification-item-header">
                    <span v-if="!notification.isRead" class="unread-dot"></span>
                    <span class="notification-item-title">{{ notification.title }}</span>
                  </div>
                  <p class="notification-item-preview">{{ truncate(notification.content, 50) }}</p>
                  <div class="notification-item-footer">
                    <el-tag :type="getTagType(notification.type)" size="small">
                      {{ getTypeName(notification.type) }}
                    </el-tag>
                    <span class="notification-time">{{ formatTime(notification.createdAt) }}</span>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 右侧：详情内容 -->
            <div class="notification-content">
              <div v-if="!selectedNotification" class="empty-content">
                <el-icon :size="64" class="empty-icon"><Box /></el-icon>
                <p>请选择一条通知查看详情</p>
              </div>
              
              <div v-else class="content-detail">
                <div class="content-header">
                  <h2 class="content-title">{{ selectedNotification.title }}</h2>
                  <div class="content-meta">
                    <el-tag :type="getTagType(selectedNotification.type)">
                      {{ getTypeName(selectedNotification.type) }}
                    </el-tag>
                    <span class="content-time">{{ formatFullTime(selectedNotification.createdAt) }}</span>
                  </div>
                </div>
                
                <div class="content-body">
                  <p>{{ selectedNotification.content }}</p>
                </div>
                
                <div class="content-footer">
                  <div class="action-buttons">
                    <template v-if="selectedNotification.type === 'ITEM_PENDING' || selectedNotification.type === 'VERIFICATION_PENDING'">
                      <el-button type="primary" @click="goToAudit">
                        <el-icon><CircleCheck /></el-icon>
                        去审核
                      </el-button>
                    </template>
                    <template v-else-if="selectedNotification.type === 'MATCH_FOUND'">
                      <el-button type="success" @click="goToMatch">
                        <el-icon><Connection /></el-icon>
                        查看匹配
                      </el-button>
                    </template>
                    <template v-else-if="selectedNotification.type === 'VERIFICATION_RESULT' && selectedNotification.relatedId">
                      <el-button type="default" @click="goToItem">
                        <el-icon><Document /></el-icon>
                        查看物品
                      </el-button>
                    </template>
                  </div>
                  
                  <div v-if="!selectedNotification.isRead" class="mark-read">
                    <el-button @click="markAsRead(selectedNotification)" size="small" text>
                      <el-icon><Check /></el-icon>
                      标为已读
                    </el-button>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <div class="notification-dialog-footer">
            <span class="footer-info">{{ notifications.length }} 条通知</span>
            <el-button type="primary" @click="handleClose">关闭</el-button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { computed, ref, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { Bell, CircleCheck, Message, Box, Connection } from '@element-plus/icons-vue'
import { useNotificationStore } from '../stores/notification'
import { formatDate } from '../utils/format'

const props = defineProps(['modelValue'])
const emit = defineEmits(['update:modelValue', 'close'])
const router = useRouter()
const notificationStore = useNotificationStore()

const activeTab = ref('all')
const selectedNotification = ref(null)

const notifications = computed(() => notificationStore.notifications)

const unreadCount = computed(() => notifications.value.filter(n => !n.isRead).length)

const filteredNotifications = computed(() => {
  let result = notifications.value
  
  if (activeTab.value === 'unread') {
    result = result.filter(n => !n.isRead)
  }
  
  return result.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
})

const handleClose = () => {
  emit('update:modelValue', false)
  emit('close')
}

const handleOverlayClick = () => {
  handleClose()
}

const formatTime = (dateStr) => {
  return formatDate(dateStr)
}

const formatFullTime = (dateStr) => {
  return formatDate(dateStr)
}

const truncate = (text, length) => {
  if (!text) return ''
  return text.length > length ? text.substring(0, length) + '...' : text
}

const getTagType = (type) => {
  const typeMap = {
    'MATCH_FOUND': 'success',
    'VERIFICATION_RESULT': 'warning',
    'SYSTEM': 'info',
    'ITEM_PENDING': 'danger',
    'VERIFICATION_PENDING': 'danger'
  }
  return typeMap[type] || 'default'
}

const getTypeName = (type) => {
  const typeMap = {
    'MATCH_FOUND': '匹配通知',
    'VERIFICATION_RESULT': '审核结果',
    'SYSTEM': '系统通知',
    'ITEM_PENDING': '物品待审核',
    'VERIFICATION_PENDING': '实名待审核'
  }
  return typeMap[type] || type
}

const selectNotification = async (notification) => {
  selectedNotification.value = notification
  if (!notification.isRead) {
    await notificationStore.markAsRead(notification.id)
  }
}

const markAsRead = async (notification) => {
  await notificationStore.markAsRead(notification.id)
}

const handleMarkAllRead = async () => {
  await notificationStore.markAllAsRead()
}

const goToAudit = () => {
  if (selectedNotification.value.type === 'ITEM_PENDING') {
    router.push('/admin')
  } else if (selectedNotification.value.type === 'VERIFICATION_PENDING') {
    router.push('/admin/identity-verifications')
  }
  emit('close')
}

const goToMatch = () => {
  router.push('/matches')
  emit('close')
}

const goToItem = () => {
  if (selectedNotification.value.relatedId) {
    router.push(`/item/${selectedNotification.value.relatedId}`)
    emit('close')
  }
}

onMounted(async () => {
  await notificationStore.fetchNotifications()
})

watch(() => props.modelValue, async (newVal) => {
  if (newVal) {
    await notificationStore.fetchNotifications()
    selectedNotification.value = null
  }
})
</script>

<style scoped>
.notification-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 40px;
}

.notification-dialog {
  background: white;
  border-radius: 16px;
  box-shadow: 0 25px 80px rgba(0, 0, 0, 0.25);
  width: 100%;
  max-width: 1200px;
  max-height: 90vh;
  height: 90vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.notification-dialog-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid #e5e7eb;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
}

.notification-dialog-title {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
  color: #1e293b;
  display: flex;
  align-items: center;
  gap: 10px;
}

.notification-dialog-title .el-icon {
  color: var(--app-primary);
}

.unread-count {
  font-size: 12px;
  font-weight: 600;
  color: #ef4444;
  background: #fef2f2;
  padding: 2px 8px;
  border-radius: 10px;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.notification-body {
  flex: 1;
  display: flex;
  overflow: hidden;
}

.notification-sidebar {
  width: 420px;
  border-right: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.sidebar-tabs {
  display: flex;
  gap: 8px;
  padding: 16px;
  border-bottom: 1px solid #e5e7eb;
}

.sidebar-tabs .el-button {
  flex: 1;
  border-radius: 8px;
  font-size: 13px;
}

.sidebar-tabs .el-button.active {
  background: var(--app-primary);
  color: white;
}

.audit-badge {
  --el-badge-bg-color: #ef4444;
}

.notification-list {
  flex: 1;
  overflow-y: auto;
  padding: 12px;
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #6b7280;
}

.empty-icon {
  margin-bottom: 16px;
  color: #d1d5db;
}

.notification-item {
  padding: 14px;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.25s ease;
  border: 1px solid transparent;
  margin-bottom: 8px;
}

.notification-item:hover {
  background: #f8fafc;
  border-color: #e5e7eb;
}

.notification-item.active {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.08) 0%, rgba(139, 92, 246, 0.08) 100%);
  border-color: rgba(99, 102, 241, 0.3);
}

.notification-item.unread {
  background: #fffbeb;
}

.notification-item-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 6px;
}

.unread-dot {
  width: 8px;
  height: 8px;
  background-color: #ef4444;
  border-radius: 50%;
  box-shadow: 0 0 0 2px rgba(239, 68, 68, 0.2);
  flex-shrink: 0;
}

.notification-item-title {
  font-weight: 600;
  font-size: 14px;
  color: #1e293b;
}

.notification-item-preview {
  font-size: 13px;
  color: #6b7280;
  margin: 0 0 10px 0;
  line-height: 1.4;
}

.notification-item-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.notification-item-footer .el-tag {
  font-size: 11px;
}

.notification-time {
  font-size: 12px;
  color: #9ca3af;
}

.notification-content {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
}

.empty-content {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #9ca3af;
}

.content-detail {
  max-width: 100%;
}

.content-header {
  margin-bottom: 24px;
}

.content-title {
  font-size: 20px;
  font-weight: 700;
  color: #1e293b;
  margin: 0 0 12px 0;
}

.content-meta {
  display: flex;
  align-items: center;
  gap: 12px;
}

.content-time {
  font-size: 13px;
  color: #9ca3af;
}

.content-body {
  padding: 20px;
  background: #f8fafc;
  border-radius: 12px;
  margin-bottom: 24px;
}

.content-body p {
  font-size: 15px;
  color: #475569;
  line-height: 1.7;
  margin: 0;
}

.content-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.action-buttons {
  display: flex;
  gap: 12px;
}

.action-buttons .el-button {
  display: flex;
  align-items: center;
  gap: 6px;
}

.mark-read .el-button {
  color: #6b7280;
}

.notification-dialog-footer {
  padding: 16px 24px;
  border-top: 1px solid #e5e7eb;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #f8fafc;
}

.footer-info {
  font-size: 13px;
  color: #6b7280;
}

.dialog-fade-enter-active,
.dialog-fade-leave-active {
  transition: opacity 0.3s ease;
}

.dialog-fade-enter-from,
.dialog-fade-leave-to {
  opacity: 0;
}

.dialog-fade-enter-active .notification-dialog,
.dialog-fade-leave-active .notification-dialog {
  transition: transform 0.35s ease;
}

.dialog-fade-enter-from .notification-dialog,
.dialog-fade-leave-to .notification-dialog {
  transform: scale(0.95);
}

@media (max-width: 768px) {
  .notification-overlay {
    padding: 20px;
  }
  
  .notification-dialog {
    max-height: 90vh;
  }
  
  .notification-body {
    flex-direction: column;
  }
  
  .notification-sidebar {
    width: 100%;
    border-right: none;
    border-bottom: 1px solid #e5e7eb;
    max-height: 200px;
  }
}
</style>
