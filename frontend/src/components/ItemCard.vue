<template>
  <div class="item-card" @click="goDetail">
    <div class="card-badge-wrapper">
      <el-tag :type="getTypeColor(item.type)" class="card-badge type-badge">
        <el-icon :size="14"><component :is="item.type === 'LOST' ? Search : Plus" /></el-icon>
        {{ item.type === 'LOST' ? '寻物' : '招领' }}
      </el-tag>
      <el-tag v-if="item.highConfidenceMatched" type="success" class="card-badge matched-badge">
        <el-icon :size="14"><CircleCheck /></el-icon>
        已匹配
      </el-tag>
      <el-tag v-if="item.status === 'PENDING'" type="warning" class="card-badge pending-badge">
        <el-icon :size="14"><Clock /></el-icon>
        待审核
      </el-tag>
    </div>

    <div class="card-image-wrapper">
      <img :src="coverImage" class="card-image" alt="物品图片" />
      <div class="image-overlay">
        <div class="view-detail">
          <el-icon><View /></el-icon>
          <span>查看详情</span>
        </div>
      </div>
      <div class="image-shine"></div>
      <div class="image-count" v-if="item.images?.length > 1">
        <el-icon :size="12"><Picture /></el-icon>
        <span>{{ item.images.length }}</span>
      </div>
    </div>

    <div class="card-content">
      <h3 class="card-title">{{ item.title }}</h3>
      <p class="card-description">{{ truncate(item.description) }}</p>
      
      <div class="card-info">
        <div class="info-row">
          <el-icon :size="16" class="info-icon"><Location /></el-icon>
          <span class="info-text">{{ item.location || '未知位置' }}</span>
        </div>
        <div class="info-row">
          <el-icon :size="16" class="info-icon"><Calendar /></el-icon>
          <span class="info-text">{{ formatTime(item.type === 'LOST' ? item.lostTime : item.foundTime) }}</span>
        </div>
      </div>

      <div class="card-tags">
        <span class="tag category-tag">{{ item.category }}</span>
        <span v-if="item.brand" class="tag brand-tag">{{ item.brand }}</span>
        <span v-if="item.color" class="tag color-tag">{{ item.color }}</span>
      </div>
    </div>

    <div class="card-footer">
      <span class="author-name">{{ getAuthorName(item.userId) }}</span>
      <el-icon :size="14" class="arrow-icon"><ArrowRight /></el-icon>
    </div>

    <div class="card-glow"></div>
  </div>
</template>

<script setup>
import { Search, Plus, CircleCheck, Clock, View, Location, Calendar, ArrowRight, Picture } from '@element-plus/icons-vue'
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useItemStore } from '../stores/item'
import { buildPlaceholderImage, formatDate, getTypeColor } from '../utils/format'

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
  return props.item.username || itemStore.getUserName(userId) || '匿名用户'
}

const formatTime = (timeStr) => {
  return formatDate(timeStr)
}

const truncate = (text) => {
  if (!text) return '暂无描述'
  return text.length > 50 ? text.substring(0, 50) + '...' : text
}
</script>

<style scoped>
.item-card {
  background: #fff;
  border-radius: 22px;
  border: 1px solid rgba(15, 23, 42, 0.06);
  overflow: hidden;
  cursor: pointer;
  transition: all 0.45s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  box-shadow: 
    0 4px 24px rgba(15, 23, 42, 0.04),
    0 1px 3px rgba(15, 23, 42, 0.06);
}

.item-card:hover {
  transform: translateY(-10px) scale(1.015);
  box-shadow: 
    0 25px 50px rgba(15, 23, 42, 0.16),
    0 8px 20px rgba(99, 102, 241, 0.12);
  border-color: rgba(99, 102, 241, 0.3);
}

.card-badge-wrapper {
  position: absolute;
  top: 14px;
  left: 14px;
  display: flex;
  gap: 8px;
  z-index: 20;
}

.card-badge {
  padding: 6px 14px;
  font-size: 12px;
  font-weight: 600;
  border-radius: 12px;
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  display: inline-flex !important;
  align-items: center !important;
  gap: 6px;
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.18);
  transition: all 0.3s ease;
  border: 1px solid rgba(255, 255, 255, 0.15);
}

/* 穿透 el-tag 内层容器，确保图标和文字垂直居中 */
.card-badge :deep(.el-tag__content) {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  line-height: 1;
}

/* el-tag 内的图标垂直基线对齐 */
.card-badge :deep(.el-icon) {
  vertical-align: middle;
  position: relative;
  top: 0;
  line-height: 1;
}

.card-badge:hover {
  transform: scale(1.05);
}

.type-badge {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.95) 0%, rgba(139, 92, 246, 0.95) 100%);
  border: none;
  color: #fff;
}

.type-badge.el-tag--success {
  background: linear-gradient(135deg, rgba(16, 185, 129, 0.95) 0%, rgba(5, 150, 105, 0.95) 100%);
}

.matched-badge {
  background: linear-gradient(135deg, rgba(16, 185, 129, 0.95) 0%, rgba(5, 150, 105, 0.95) 100%);
  border: none;
  color: #fff;
}

.pending-badge {
  background: linear-gradient(135deg, rgba(245, 158, 11, 0.95) 0%, rgba(217, 119, 6, 0.95) 100%);
  border: none;
  color: #fff;
}

.card-image-wrapper {
  position: relative;
  overflow: hidden;
  aspect-ratio: 1.5;
}

.card-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  display: block;
  transition: transform 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}

.item-card:hover .card-image {
  transform: scale(1.08);
}

.image-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.55);
  opacity: 0;
  transition: opacity 0.35s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(4px);
}

.item-card:hover .image-overlay {
  opacity: 1;
}

.view-detail {
  display: flex;
  align-items: center;
  gap: 10px;
  color: #fff;
  font-size: 15px;
  font-weight: 600;
  padding: 12px 26px;
  background: rgba(255, 255, 255, 0.18);
  border-radius: 24px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.25);
  transform: translateY(10px);
  transition: all 0.35s ease;
}

.item-card:hover .view-detail {
  transform: translateY(0);
}

.image-shine {
  position: absolute;
  top: 0;
  left: -100%;
  width: 50%;
  height: 100%;
  background: linear-gradient(
    90deg,
    transparent 0%,
    rgba(255, 255, 255, 0.15) 50%,
    transparent 100%
  );
  transition: left 0.6s ease;
}

.item-card:hover .image-shine {
  left: 150%;
}

.image-count {
  position: absolute;
  bottom: 12px;
  right: 12px;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(8px);
  padding: 4px 10px;
  border-radius: 14px;
  font-size: 12px;
  color: #fff;
  display: flex;
  align-items: center;
  gap: 4px;
}

.card-content {
  padding: 20px;
}

.card-title {
  font-size: 18px;
  font-weight: 700;
  color: #1e293b;
  margin: 0 0 10px 0;
  line-height: 1.4;
  transition: color 0.2s ease;
}

.item-card:hover .card-title {
  color: var(--app-primary);
}

.card-description {
  font-size: 14px;
  color: #64748b;
  line-height: 1.7;
  margin: 0 0 16px 0;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-info {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 16px;
}

.info-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.info-icon {
  color: #94a3b8;
}

.info-text {
  font-size: 13px;
  color: #64748b;
}

.card-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag {
  padding: 5px 14px;
  font-size: 12px;
  border-radius: 10px;
  font-weight: 500;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.tag::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
  transition: left 0.5s ease;
}

.item-card:hover .tag::before {
  left: 100%;
}

.category-tag {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.08) 0%, rgba(139, 92, 246, 0.08) 100%);
  color: #6366f1;
  border: 1px solid rgba(99, 102, 241, 0.15);
}

.item-card:hover .category-tag {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.18) 0%, rgba(139, 92, 246, 0.18) 100%);
  border-color: rgba(99, 102, 241, 0.3);
  transform: translateY(-2px);
}

.brand-tag {
  background: rgba(15, 23, 42, 0.06);
  color: #64748b;
  border: 1px solid rgba(15, 23, 42, 0.08);
}

.item-card:hover .brand-tag {
  background: rgba(15, 23, 42, 0.1);
  transform: translateY(-2px);
}

.color-tag {
  background: rgba(15, 23, 42, 0.06);
  color: #64748b;
  border: 1px solid rgba(15, 23, 42, 0.08);
}

.item-card:hover .color-tag {
  background: rgba(15, 23, 42, 0.1);
  transform: translateY(-2px);
}

.card-footer {
  padding: 16px 20px;
  border-top: 1px solid rgba(15, 23, 42, 0.06);
  background: linear-gradient(180deg, #fafbfc 0%, #f8fafc 100%);
  display: flex;
  align-items: center;
  justify-content: space-between;
  transition: all 0.3s ease;
}

.item-card:hover .card-footer {
  background: linear-gradient(180deg, rgba(99, 102, 241, 0.04) 0%, rgba(139, 92, 246, 0.04) 100%);
}

.author-name {
  font-size: 13px;
  color: #94a3b8;
  transition: color 0.3s ease;
}

.item-card:hover .author-name {
  color: var(--app-primary);
}

.arrow-icon {
  color: #cbd5e1;
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
}

.item-card:hover .arrow-icon {
  color: var(--app-primary);
  transform: translateX(6px) scale(1.1);
}

.card-glow {
  position: absolute;
  bottom: -60px;
  left: 50%;
  transform: translateX(-50%);
  width: 80%;
  height: 80px;
  background: radial-gradient(circle, rgba(99, 102, 241, 0.1) 0%, transparent 70%);
  opacity: 0;
  transition: opacity 0.4s ease;
}

.item-card:hover .card-glow {
  opacity: 1;
}

@media (max-width: 600px) {
  .card-image-wrapper {
    aspect-ratio: 1.4;
  }

  .card-title {
    font-size: 17px;
  }

  .card-content {
    padding: 16px;
  }

  .card-footer {
    padding: 12px 16px;
  }
}
</style>
