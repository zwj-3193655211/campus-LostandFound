<template>
  <el-card class="item-card" @click="goDetail" shadow="never">
    <div class="card-header">
      <el-tag :type="getTypeColor(item.type)" size="small">
        {{ item.type === 'LOST' ? '寻物' : '招领' }}
      </el-tag>
      <el-tag v-if="item.highConfidenceMatched" type="danger" size="small">
        已匹配
      </el-tag>
      <el-tag v-if="item.pendingCompletionStatus === 'PENDING'" type="warning" size="small">
        完成审核中
      </el-tag>
      <el-tag v-if="item.potentialOwnerNotified" type="success" size="small">
        疑似失主已通知
      </el-tag>
      <el-tag :type="getStatusColor(item.status)" size="small">
        {{ formatStatus(item.status) }}
      </el-tag>
    </div>

    <div class="card-body">
      <div class="cover-wrapper">
        <img :src="coverImage" class="cover-image" alt="物品图片" />
      </div>
      <h3 class="item-title">{{ item.title }}</h3>
      <p class="item-description">{{ truncate(item.description) }}</p>
      
      <div class="item-info">
        <div class="info-item">
          <el-icon><Location /></el-icon>
          <span>{{ item.location || '未知位置' }}</span>
        </div>
        <div class="info-item">
          <el-icon><Calendar /></el-icon>
          <span>{{ formatTime(item.type === 'LOST' ? item.lostTime : item.foundTime) }}</span>
        </div>
      </div>

      <div class="item-meta">
        <span class="category">{{ item.category }}</span>
        <span v-if="item.brand" class="brand">{{ item.brand }}</span>
        <span v-if="item.color" class="color">{{ item.color }}</span>
      </div>

      <div class="item-footer">
        <span class="author">{{ getAuthorName(item.userId) }}</span>
      </div>
    </div>
  </el-card>
</template>

<script setup>
import { Location, Calendar } from '@element-plus/icons-vue'
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useItemStore } from '../stores/item'
import { buildPlaceholderImage, formatDate, formatStatus, getStatusColor, getTypeColor } from '../utils/format'

const props = defineProps({
  item: {
    type: Object,
    required: true
  }
})

const router = useRouter()
const itemStore = useItemStore()

const coverImage = computed(() => props.item.images?.[0] || buildPlaceholderImage(props.item))

const goDetail = () => {
  router.push(`/item/${props.item.id}`)
}

const getAuthorName = (userId) => {
  return itemStore.getUserName(userId)
}

const formatTime = (timeStr) => {
  return formatDate(timeStr)
}

const truncate = (text) => {
  if (!text) return ''
  return text.length > 60 ? text.substring(0, 60) + '...' : text
}
</script>

<style scoped>
.item-card {
  cursor: pointer;
  transition: transform 0.22s ease, box-shadow 0.22s ease, border-color 0.22s ease;
  margin-bottom: 16px;
  border-radius: var(--app-radius);
  border: 1px solid var(--app-border);
  overflow: hidden;
}

.item-card:hover {
  box-shadow: 0 16px 36px rgba(15, 23, 42, 0.12);
  transform: translateY(-4px);
  border-color: rgba(79, 70, 229, 0.22);
}

.card-header {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

.cover-wrapper {
  margin-bottom: 12px;
  border-radius: var(--app-radius-sm);
  overflow: hidden;
  border: 1px solid var(--app-border);
}

.cover-image {
  width: 100%;
  height: 190px;
  object-fit: cover;
  background: var(--app-gray-50);
  display: block;
}

.item-title {
  font-size: 18px;
  font-weight: 800;
  margin-bottom: 8px;
  color: var(--app-text);
}

.item-description {
  color: var(--app-muted);
  font-size: 14px;
  line-height: 1.6;
  margin-bottom: 12px;
}

.item-info {
  display: flex;
  gap: 16px;
  margin-bottom: 12px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 4px;
  color: var(--app-muted);
  font-size: 13px;
}

.item-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 12px;
}

.category, .brand, .color {
  padding: 2px 8px;
  background: rgba(15, 23, 42, 0.04);
  border: 1px solid var(--app-border);
  border-radius: 999px;
  font-size: 12px;
  color: var(--app-muted);
}

.item-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 12px;
  border-top: 1px solid var(--app-border);
}

.author {
  color: var(--app-muted);
  font-size: 13px;
}

</style>
