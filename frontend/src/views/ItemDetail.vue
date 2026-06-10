<template>
  <div class="item-detail-page app-page">
    <div class="page-header">
      <BackButton show-text size="default" />
      <div class="header-title">物品详情</div>
    </div>
    <div v-if="item" class="detail-content animate-fade-in-up">
      <div class="detail-header">
        <div class="tags">
          <el-tag :type="getTypeColor(item.type)" size="large" class="tag-item">
            <el-icon class="tag-icon"><component :is="item.type === 'LOST' ? Help : Box" /></el-icon>
            {{ item.type === 'LOST' ? '寻物启示' : '失物招领' }}
          </el-tag>
          <el-tag v-if="item.highConfidenceMatched" type="danger" class="tag-item">
            <el-icon class="tag-icon"><Trophy /></el-icon>
            已匹配
          </el-tag>
          <el-tag v-if="item.pendingCompletionStatus === 'PENDING'" type="warning" class="tag-item">
            <el-icon class="tag-icon"><Clock /></el-icon>
            {{ item.pendingCompletionTargetStatus === 'FOUND_BACK' ? '已找到审核中' : '已归还审核中' }}
          </el-tag>
          <el-tag v-if="item.potentialOwnerNotified" type="success" class="tag-item">
            <el-icon class="tag-icon"><Bell /></el-icon>
            疑似失主已通知
          </el-tag>
          <el-tag :type="getStatusColor(item.status)" class="tag-item">
            <el-icon class="tag-icon"><component :is="getStatusIcon(item.status)" /></el-icon>
            {{ formatStatus(item.status) }}
          </el-tag>
        </div>
        <h1 class="item-title">{{ item.title }}</h1>
        <p class="item-meta">
          <span class="meta-item">发布于 {{ formatDate(item.createdAt) }}</span>
          <span class="meta-divider">|</span>
          <span class="meta-item">{{ item.category }}</span>
        </p>
      </div>

      <div class="item-images-wrapper">
        <div class="item-images">
          <el-image 
            v-for="(img, index) in displayImages" 
            :key="index"
            :src="img" 
            :preview-src-list="displayImages"
            class="item-image"
            :style="{ animationDelay: `${index * 0.1}s` }"
          />
        </div>
        <div v-if="item.images?.length" class="image-count">
          <el-icon><Picture /></el-icon>
          <span>{{ item.images.length }} 张图片</span>
        </div>
      </div>

      <div class="detail-info app-grid-2">
        <div class="info-card app-surface app-panel animate-slide-up" style="animation-delay: 0.1s">
          <div class="info-card-header">
            <div class="info-card-icon info-icon-item">
              <el-icon><Briefcase /></el-icon>
            </div>
            <div class="info-card-title">物品信息</div>
          </div>
          <div class="info-row">
            <span class="info-label">类别</span>
            <span class="info-value">{{ item.category }}</span>
          </div>
          <div class="info-row">
            <span class="info-label">品牌</span>
            <span class="info-value">{{ item.brand || '未填写' }}</span>
          </div>
          <div class="info-row">
            <span class="info-label">颜色</span>
            <span class="info-value">{{ item.color || '未填写' }}</span>
          </div>
          <div class="info-row">
            <span class="info-label">证件号</span>
            <span class="info-value">{{ item.serialNumber || '未填写' }}</span>
          </div>
        </div>

        <div class="info-card app-surface app-panel animate-slide-up" style="animation-delay: 0.2s">
          <div class="info-card-header">
            <div class="info-card-icon info-icon-location">
              <el-icon><Location /></el-icon>
            </div>
            <div class="info-card-title">地点信息</div>
          </div>
          <div class="info-row">
            <span class="info-label">位置</span>
            <span class="info-value">{{ item.location || '未填写' }}</span>
          </div>
          <div class="info-row">
            <span class="info-label">{{ item.type === 'LOST' ? '丢失时间' : '发现时间' }}</span>
            <span class="info-value">{{ formatDate(item.type === 'LOST' ? item.lostTime : item.foundTime) }}</span>
          </div>
        </div>

        <div class="info-card app-surface app-panel animate-slide-up" style="animation-delay: 0.3s">
          <div class="info-card-header">
            <div class="info-card-icon info-icon-desc">
              <el-icon><Document /></el-icon>
            </div>
            <div class="info-card-title">物品描述</div>
          </div>
          <p class="description-text">{{ item.description }}</p>
        </div>

        <div v-if="item.potentialOwnerNotified" class="info-card app-surface app-panel animate-slide-up" style="animation-delay: 0.4s">
          <div class="info-card-header">
            <div class="info-card-icon info-icon-notify">
              <el-icon><Bell /></el-icon>
            </div>
            <div class="info-card-title">证件匹配提醒</div>
          </div>
          <p class="description-text">
            系统已根据证件号向疑似失主发出核对通知。请耐心等待对方确认，或由校园管理员协助完成后续联系与归还。
          </p>
        </div>

        <div class="info-card app-surface app-panel animate-slide-up" style="animation-delay: 0.5s">
          <div class="info-card-header">
            <div class="info-card-icon info-icon-contact">
              <el-icon><Phone /></el-icon>
            </div>
            <div class="info-card-title">联系方式</div>
          </div>
          <div class="info-row">
            <span class="info-label">联系人</span>
            <span class="info-value">{{ item.contactInfo || '未公开' }}</span>
          </div>
        </div>
      </div>

      <div class="detail-actions">

        <el-button
          v-if="canSubmitCompletion"
          @click="handleCompletionRequest"
          type="success"
          size="large"
          class="action-btn action-btn-success"
        >
          <el-icon><CircleCheck /></el-icon>
          {{ item.type === 'LOST' ? '申请标记为已找到' : '申请标记为已归还' }}
        </el-button>
        <el-button @click="goBack" type="default" size="large" class="action-btn action-btn-default">
          <el-icon><ArrowLeft /></el-icon>
          返回列表
        </el-button>
      </div>

      <div class="related-section">
        <div class="section-header">
          <div class="section-title-wrapper">
            <el-icon :size="24" class="section-icon"><Ticket /></el-icon>
            <h3>可能相关的{{ item.type === 'LOST' ? '招领' : '寻物' }}信息</h3>
          </div>
        </div>
        <div class="related-items">
          <div 
            v-for="(related, index) in relatedItems" 
            :key="related.id" 
            class="related-item-wrapper"
            :style="{ animationDelay: `${index * 0.15}s` }"
          >
            <ItemCard :item="related" />
          </div>
        </div>
        <div v-if="relatedItems.length === 0" class="empty-related">
          <el-icon :size="48" class="empty-icon"><Search /></el-icon>
          <p>暂无相关信息</p>
        </div>
      </div>
    </div>

    <div v-else class="loading-state">
      <el-icon class="loading-icon is-loading"><Loading /></el-icon>
      <p>加载中...</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Message, ArrowLeft, CircleCheck, Loading, Help, Box, Trophy, Clock, Bell, Picture, Briefcase, Location, Document, Phone, Ticket, Search, View, Warning } from '@element-plus/icons-vue'
import { ElMessageBox } from 'element-plus'
import { useItemStore } from '../stores/item'
import { useUserStore } from '../stores/user'
import ItemCard from '../components/ItemCard.vue'
import BackButton from '../components/BackButton.vue'
import { buildPlaceholderImage, formatDate, formatStatus, getStatusColor, getTypeColor } from '../utils/format'
import { showError, showInfo, showWarning } from '../utils/message'

const route = useRoute()
const router = useRouter()
const itemStore = useItemStore()
const userStore = useUserStore()

const item = ref(null)
const relatedItems = ref([])

const displayImages = computed(() => {
  if (!item.value) return []
  if (item.value.images?.length) return item.value.images
  return [buildPlaceholderImage(item.value)]
})

const canSubmitCompletion = computed(() => {
  return !!item.value
    && !!userStore.user
    && userStore.user.id === item.value.userId
    && item.value.status === 'APPROVED'
    && item.value.highConfidenceMatched
    && item.value.pendingCompletionStatus !== 'PENDING'
})

const getStatusIcon = (status) => {
  const icons = {
    'PENDING': Clock,
    'APPROVED': CircleCheck,
    'REJECTED': Warning,
    'FOUND_BACK': CircleCheck,
    'RETURNED': CircleCheck,
    'EXPIRED': Warning
  }
  return icons[status] || View
}

const handleCompletionRequest = async () => {
  try {
    const { value } = await ElMessageBox.prompt(
      item.value.type === 'LOST' ? '请填写“已找到”的补充说明。' : '请填写“已归还”的补充说明。',
      '提交完成申请',
      {
        confirmButtonText: '提交',
        cancelButtonText: '取消',
        inputPlaceholder: '可填写归还经过、领取方式等',
        inputType: 'textarea'
      }
    )
    await itemStore.submitCompletionRequest(item.value.id, {
      targetStatus: item.value.type === 'LOST' ? 'FOUND_BACK' : 'RETURNED',
      reason: value || ''
    })
    item.value.pendingCompletionStatus = 'PENDING'
    item.value.pendingCompletionTargetStatus = item.value.type === 'LOST' ? 'FOUND_BACK' : 'RETURNED'
    showInfo('完成申请已提交，请等待审核员确认')
  } catch (error) {
    if (error === 'cancel' || error === 'close') {
      return
    }
    showError(error?.message || '提交完成申请失败')
  }
}

const goBack = () => {
  router.push('/items')
}

const loadItem = async (itemId) => {
  try {
    item.value = await itemStore.fetchItem(itemId)
    // 使用新接口获取按匹配度排序的相关物品
    relatedItems.value = await itemStore.fetchRelatedItems(itemId)
  } catch (error) {
    console.error('获取物品详情失败:', error)
    showError(typeof error === 'string' ? error : (error?.message || '获取物品详情失败'))
  }
}

onMounted(async () => {
  const itemId = parseInt(route.params.id)
  await loadItem(itemId)
})

watch(() => route.params.id, async (newId) => {
  if (newId) {
    const itemId = parseInt(newId)
    await loadItem(itemId)
  }
})
</script>

<style scoped>
.item-detail-page {
  margin: 0 auto;
  max-width: var(--app-max-width-medium);
}

.detail-content {
  opacity: 0;
}

.detail-header {
  text-align: center;
  margin-bottom: var(--app-space-8);
}

.tags {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-bottom: 24px;
  flex-wrap: wrap;
}

.tag-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  border-radius: 24px;
  font-weight: 600;
  font-size: 13px;
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.tag-item::before {
  content: '';
  position: absolute;
  inset: 0;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.tag-item:hover {
  transform: translateY(-3px) scale(1.05);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.tag-item:hover::before {
  opacity: 0.1;
}

.tag-icon {
  font-size: 15px;
}

.item-title {
  font-size: 36px;
  font-weight: 700;
  margin: 0 0 12px 0;
  background: linear-gradient(135deg, #1e293b 0%, #475569 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.item-meta {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 16px;
  color: var(--app-muted);
  font-size: 14px;
  margin: 0;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
}

.meta-divider {
  color: #cbd5e1;
}

.item-images-wrapper {
  position: relative;
  margin-bottom: var(--app-space-8);
}

.item-images {
  display: flex;
  gap: 14px;
  margin-bottom: var(--app-space-4);
  overflow-x: auto;
  padding-bottom: 12px;
}

.item-image {
  width: 220px;
  height: 220px;
  object-fit: cover;
  border-radius: var(--app-radius);
  border: 1px solid var(--app-border);
  box-shadow: 0 4px 15px rgba(15, 23, 42, 0.08);
  opacity: 0;
  animation: fadeInUp 0.5s ease-out forwards;
  transition: all 0.3s ease;
  cursor: pointer;
}

.item-image:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 30px rgba(15, 23, 42, 0.12);
}

.image-count {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--app-muted);
  font-size: 13px;
  margin-left: 4px;
}

.detail-info {
  margin-bottom: var(--app-space-8);
}

.info-card {
  overflow: hidden;
  opacity: 0;
  border-radius: 20px;
  border: 1px solid rgba(15, 23, 42, 0.06);
  box-shadow: 0 4px 20px rgba(15, 23, 42, 0.04);
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.info-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 40px rgba(15, 23, 42, 0.1);
  border-color: rgba(99, 102, 241, 0.15);
}

.info-card-header {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: var(--app-space-4);
  padding: 20px 20px 0;
}

.info-card-icon {
  width: 44px;
  height: 44px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  position: relative;
  transition: all 0.3s ease;
}

.info-card-icon::before {
  content: '';
  position: absolute;
  inset: -3px;
  border-radius: 18px;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.info-card:hover .info-card-icon {
  transform: scale(1.1);
}

.info-card:hover .info-card-icon::before {
  opacity: 0.15;
}

.info-icon-item {
  background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%);
  color: #6366f1;
}

.info-icon-item::before {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
}

.info-icon-location {
  background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
  color: #10b981;
}

.info-icon-location::before {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
}

.info-icon-desc {
  background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
  color: #3b82f6;
}

.info-icon-desc::before {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
}

.info-icon-notify {
  background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
  color: #f59e0b;
}

.info-icon-notify::before {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
}

.info-icon-contact {
  background: linear-gradient(135deg, #fce7f3 0%, #fbcfe8 100%);
  color: #ec4899;
}

.info-icon-contact::before {
  background: linear-gradient(135deg, #ec4899 0%, #db2777 100%);
}

.info-card-title {
  font-weight: 700;
  font-size: 16px;
  letter-spacing: 0.2px;
  color: #1e293b;
  margin: 0;
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 12px 0;
  border-bottom: 1px solid var(--app-border);
  transition: background 0.2s ease;
}

.info-row:hover {
  background: rgba(99, 102, 241, 0.02);
}

.info-row:last-child {
  border-bottom: none;
}

.info-label {
  color: var(--app-muted);
  font-size: 14px;
}

.info-value {
  color: var(--app-text);
  font-weight: 500;
  font-size: 14px;
}

.description-text {
  line-height: 1.8;
  color: var(--app-muted);
  margin: 0;
  font-size: 14px;
  padding: 8px 0;
}

.detail-actions {
  display: flex;
  justify-content: center;
  gap: 20px;
  margin-bottom: var(--app-space-10);
  flex-wrap: wrap;
  padding: 24px;
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.03) 0%, rgba(139, 92, 246, 0.03) 100%);
  border-radius: 20px;
  border: 1px solid rgba(99, 102, 241, 0.08);
}

.action-btn {
  padding: 16px 40px;
  font-weight: 600;
  font-size: 16px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  min-width: 200px;
  justify-content: center;
}

.action-btn-primary {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  border: none;
  box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
}

.action-btn-primary:hover {
  background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
  transform: translateY(-3px);
  box-shadow: 0 12px 35px rgba(99, 102, 241, 0.5);
}

.action-btn-success {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  border: none;
  box-shadow: 0 6px 20px rgba(16, 185, 129, 0.4);
}

.action-btn-success:hover {
  background: linear-gradient(135deg, #059669 0%, #047857 100%);
  transform: translateY(-3px);
  box-shadow: 0 12px 35px rgba(16, 185, 129, 0.5);
}

.action-btn-success:active {
  transform: translateY(-1px);
}

.action-btn-default {
  background: #fff;
  border: 2px solid rgba(15, 23, 42, 0.1);
  color: var(--app-text);
  box-shadow: 0 4px 15px rgba(15, 23, 42, 0.06);
}

.action-btn-default:hover {
  background: rgba(99, 102, 241, 0.04);
  border-color: rgba(99, 102, 241, 0.3);
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(15, 23, 42, 0.1);
}

.related-section {
  margin-top: var(--app-space-10);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--app-space-5);
}

.section-title-wrapper {
  display: flex;
  align-items: center;
  gap: 12px;
}

.section-icon {
  color: var(--app-primary);
}

.related-section h3 {
  font-size: 22px;
  font-weight: 700;
  margin: 0;
  background: linear-gradient(135deg, #1e293b 0%, #475569 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.related-items {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}

.related-item-wrapper {
  opacity: 0;
  animation: fadeInUp 0.5s ease-out forwards;
}

.empty-related {
  text-align: center;
  padding: 60px 20px;
  background: rgba(15, 23, 42, 0.02);
  border-radius: var(--app-radius);
  border: 1px dashed var(--app-border);
}

.empty-icon {
  color: #cbd5e1;
  margin-bottom: 16px;
}

.empty-related p {
  color: var(--app-muted);
  font-size: 14px;
  margin: 0;
}

.loading-state {
  text-align: center;
  padding: 120px 20px;
}

.loading-state p {
  margin-top: 20px;
  color: var(--app-muted);
  font-size: 15px;
}

.loading-icon {
  font-size: 56px;
  color: var(--app-primary);
  animation: pulse 2s ease-in-out infinite;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

@media (max-width: 900px) {
  .related-items {
    grid-template-columns: repeat(2, 1fr);
  }

  .item-image {
    width: 180px;
    height: 180px;
  }
}

@media (max-width: 600px) {
  .item-title {
    font-size: 28px;
  }

  .tags {
    gap: 8px;
  }

  .tag-item {
    padding: 6px 12px;
    font-size: 12px;
  }

  .item-image {
    width: 150px;
    height: 150px;
  }

  .related-items {
    grid-template-columns: 1fr;
  }

  .action-btn {
    padding: 12px 24px;
    font-size: 14px;
  }

  .detail-info {
    grid-template-columns: 1fr;
  }
}
</style>
