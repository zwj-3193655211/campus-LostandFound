<template>
  <Teleport to="body">
    <Transition name="dialog-fade">
      <div v-if="modelValue" class="notification-overlay" @click.self="handleOverlayClick">
        <div class="notification-dialog">
          <div class="notification-dialog-header">
            <h3 class="notification-dialog-title">
              <el-icon><Bell /></el-icon>
              通知消息
            </h3>
            <el-button circle text @click="handleClose">
              <el-icon><CloseBold /></el-icon>
            </el-button>
          </div>
          <div class="notification-dialog-body">
            <div class="notification-list">
              <div v-if="notifications.length === 0" class="empty-state">
                <el-icon :size="48" class="empty-icon"><Bell /></el-icon>
                <p>暂无通知</p>
              </div>

              <el-timeline v-else>
                <el-timeline-item 
                  v-for="notification in notifications" 
                  :key="notification.id"
                  :timestamp="formatTime(notification.createdAt)"
                  :class="{ 'unread': !notification.isRead }"
                >
                  <el-card class="notification-card" @click="handleClick(notification)">
                    <div class="notification-header">
                      <span class="notification-title">{{ notification.title }}</span>
                      <el-badge v-if="!notification.isRead" type="danger" />
                    </div>
                    <p class="notification-content">{{ notification.content }}</p>
                    <div class="notification-type">
                      <el-tag :type="getTagType(notification.type)">
                        {{ getTypeName(notification.type) }}
                      </el-tag>
                    </div>
                  </el-card>
                </el-timeline-item>
              </el-timeline>
            </div>
          </div>
          <div class="notification-dialog-footer">
            <el-button @click="handleMarkAllRead" size="small">全部标为已读</el-button>
            <el-button type="primary" size="small" @click="handleClose">关闭</el-button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { Bell, CloseBold } from '@element-plus/icons-vue'
import { useNotificationStore } from '../stores/notification'
import { formatDate } from '../utils/format'

const props = defineProps(['modelValue'])
const emit = defineEmits(['update:modelValue', 'close'])
const router = useRouter()
const notificationStore = useNotificationStore()

const notifications = ref([])

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

const getTagType = (type) => {
  const typeMap = {
    'MATCH_FOUND': 'success',
    'VERIFICATION_RESULT': 'warning',
    'SYSTEM': 'info'
  }
  return typeMap[type] || 'default'
}

const getTypeName = (type) => {
  const typeMap = {
    'MATCH_FOUND': '匹配通知',
    'VERIFICATION_RESULT': '审核结果',
    'SYSTEM': '系统通知'
  }
  return typeMap[type] || type
}

const handleClick = async (notification) => {
  if (!notification.isRead) {
    await notificationStore.markAsRead(notification.id)
  }

  if (notification.type === 'MATCH_FOUND') {
    router.push('/matches')
    emit('close')
    return
  }

  if (notification.type === 'VERIFICATION_RESULT' && notification.relatedId) {
    router.push(`/item/${notification.relatedId}`)
    emit('close')
  }
}

const handleMarkAllRead = async () => {
  await notificationStore.markAllAsRead()
  notifications.value = notificationStore.notifications
}

onMounted(async () => {
  await notificationStore.fetchNotifications()
  notifications.value = notificationStore.notifications
})

watch(() => props.modelValue, async (newVal) => {
  if (newVal) {
    await notificationStore.fetchNotifications()
    notifications.value = notificationStore.notifications
  }
})
</script>

<style scoped>
/* 弹窗遮罩层 */
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
  padding: 20px;
}

/* 弹窗主体 */
.notification-dialog {
  background: white;
  border-radius: 12px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  width: 100%;
  max-width: 520px;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 弹窗头部 */
.notification-dialog-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #e5e7eb;
  background: #f9fafb;
}

.notification-dialog-title {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  display: flex;
  align-items: center;
  gap: 8px;
}

.notification-dialog-title .el-icon {
  color: var(--app-primary);
}

/* 弹窗内容区 */
.notification-dialog-body {
  flex: 1;
  overflow-y: auto;
  padding: 0;
}

/* 弹窗底部 */
.notification-dialog-footer {
  padding: 12px 20px;
  border-top: 1px solid #e5e7eb;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  background: #f9fafb;
}

/* 通知列表 */
.notification-list {
  max-height: 450px;
  overflow-y: auto;
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

.notification-card {
  cursor: pointer;
  transition: all 0.3s;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  margin: 0 16px 12px;
}

.notification-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.notification-title {
  font-weight: 600;
  font-size: 14px;
  color: #1f2937;
}

.notification-content {
  color: #6b7280;
  font-size: 13px;
  margin-bottom: 8px;
  line-height: 1.5;
}

.notification-type {
  text-align: right;
}

.unread .notification-card {
  border-left: 4px solid var(--app-primary);
  background: #f0f9ff;
}

/* 过渡动画 */
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
  transition: transform 0.3s ease;
}

.dialog-fade-enter-from .notification-dialog,
.dialog-fade-leave-to .notification-dialog {
  transform: scale(0.9);
}
</style>
