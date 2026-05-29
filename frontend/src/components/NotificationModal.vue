<template>
  <el-dialog title="通知消息" :visible="true" @close="$emit('close')" width="500px">
    <div class="notification-list">
      <div v-if="notifications.length === 0" class="empty-state">
        <el-icon :size="48" class="empty-icon"><Bell /></el-icon>
        <p>暂无通知</p>
      </div>

      <el-timeline v-else mode="left">
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

    <template #footer>
      <el-button @click="handleMarkAllRead">全部标为已读</el-button>
      <el-button type="primary" @click="$emit('close')">关闭</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Bell } from '@element-plus/icons-vue'
import { useNotificationStore } from '../stores/notification'
import { formatDate } from '../utils/format'

const emit = defineEmits(['close'])
const router = useRouter()
const notificationStore = useNotificationStore()

const notifications = ref([])

const formatTime = (dateStr) => {
  return formatDate(dateStr)
}

const getTagType = (type) => {
  const typeMap = {
    'MATCH_FOUND': 'success',
    'VERIFICATION_RESULT': 'warning',
    'CLAIM_REVIEW_RESULT': 'primary',
    'SYSTEM': 'info'
  }
  return typeMap[type] || 'default'
}

const getTypeName = (type) => {
  const typeMap = {
    'MATCH_FOUND': '匹配通知',
    'VERIFICATION_RESULT': '审核结果',
    'CLAIM_REVIEW_RESULT': '认领审核',
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

  if ((notification.type === 'VERIFICATION_RESULT' || notification.type === 'CLAIM_REVIEW_RESULT') && notification.relatedId) {
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
</script>

<style scoped>
.notification-list {
  max-height: 400px;
  overflow-y: auto;
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: var(--app-muted);
}

.empty-icon {
  margin-bottom: 16px;
  color: var(--app-gray-200);
}

.notification-card {
  cursor: pointer;
  transition: all 0.3s;
  border-radius: var(--app-radius);
  border: 1px solid var(--app-border);
}

.notification-card:hover {
  box-shadow: var(--app-shadow-hover);
  transform: translateY(-2px);
}

.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.notification-title {
  font-weight: bold;
}

.notification-content {
  color: var(--app-muted);
  margin-bottom: 8px;
}

.notification-type {
  text-align: right;
}

.unread .notification-card {
  border-left: 4px solid var(--app-primary);
}
</style>
