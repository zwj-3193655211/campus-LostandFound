<template>
  <div class="item-detail-page app-page">
    <div v-if="item" class="detail-content">
      <div class="detail-header">
        <div class="tags">
          <el-tag :type="getTypeColor(item.type)" size="large">
            {{ item.type === 'LOST' ? '寻物启示' : '失物招领' }}
          </el-tag>
          <el-tag v-if="item.highConfidenceMatched" type="danger">
            已匹配
          </el-tag>
          <el-tag v-if="item.pendingCompletionStatus === 'PENDING'" type="warning">
            {{ item.pendingCompletionTargetStatus === 'FOUND_BACK' ? '已找到审核中' : '已归还审核中' }}
          </el-tag>
          <el-tag v-if="item.potentialOwnerNotified" type="success">
            疑似失主已通知
          </el-tag>
          <el-tag :type="getStatusColor(item.status)">
            {{ formatStatus(item.status) }}
          </el-tag>
        </div>
        <h1 class="item-title">{{ item.title }}</h1>
      </div>

      <div class="item-images">
        <el-image 
          v-for="(img, index) in displayImages" 
          :key="index"
          :src="img" 
          :preview-src-list="displayImages"
          class="item-image"
        />
      </div>

      <div class="detail-info app-grid-2">
        <div class="info-card app-surface app-panel">
          <div class="info-card-title">物品信息</div>
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
            <span class="info-label">序列号</span>
            <span class="info-value">{{ item.serialNumber || '未填写' }}</span>
          </div>
        </div>

        <div class="info-card app-surface app-panel">
          <div class="info-card-title">地点信息</div>
          <div class="info-row">
            <span class="info-label">位置</span>
            <span class="info-value">{{ item.location || '未填写' }}</span>
          </div>
          <div class="info-row">
            <span class="info-label">{{ item.type === 'LOST' ? '丢失时间' : '发现时间' }}</span>
            <span class="info-value">{{ formatDate(item.type === 'LOST' ? item.lostTime : item.foundTime) }}</span>
          </div>
        </div>

        <div class="info-card app-surface app-panel">
          <div class="info-card-title">物品描述</div>
          <p class="description-text">{{ item.description }}</p>
        </div>

        <div v-if="item.potentialOwnerNotified" class="info-card app-surface app-panel">
          <div class="info-card-title">证件匹配提醒</div>
          <p class="description-text">
            系统已根据证件号向疑似失主发出核对通知。请耐心等待对方确认，或由校园管理员协助完成后续联系与归还。
          </p>
        </div>

        <div class="info-card app-surface app-panel">
          <div class="info-card-title">联系方式</div>
          <div class="info-row">
            <span class="info-label">联系人</span>
            <span class="info-value">{{ item.contactInfo || '未公开' }}</span>
          </div>
        </div>
      </div>

      <div class="detail-actions">
        <el-button 
          v-if="item.status === 'APPROVED' && canClaim" 
          @click="handleClaim" 
          type="primary" 
          size="large"
        >
          <el-icon><Message /></el-icon>
          {{ item.type === 'LOST' ? '提交认领申请' : '提交认领申请' }}
        </el-button>
        <el-button
          v-if="canSubmitCompletion"
          @click="handleCompletionRequest"
          type="success"
          size="large"
        >
          <el-icon><CircleCheck /></el-icon>
          {{ item.type === 'LOST' ? '申请标记为已找到' : '申请标记为已归还' }}
        </el-button>
        <el-button @click="goBack" type="default" size="large">
          <el-icon><ArrowLeft /></el-icon>
          返回列表
        </el-button>
      </div>

      <div class="related-section">
        <h3>可能相关的{{ item.type === 'LOST' ? '招领' : '寻物' }}信息</h3>
        <div class="related-items">
          <ItemCard 
            v-for="related in relatedItems" 
            :key="related.id" 
            :item="related" 
          />
        </div>
        <div v-if="relatedItems.length === 0" class="empty-related">
          暂无相关信息
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
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Message, ArrowLeft, CircleCheck, Loading } from '@element-plus/icons-vue'
import { ElMessageBox } from 'element-plus'
import { useItemStore } from '../stores/item'
import { useUserStore } from '../stores/user'
import ItemCard from '../components/ItemCard.vue'
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

const canClaim = computed(() => {
  return !!item.value
    && !!userStore.user
    && userStore.user.id !== item.value.userId
    && item.value.status === 'APPROVED'
})

const canSubmitCompletion = computed(() => {
  return !!item.value
    && !!userStore.user
    && userStore.user.id === item.value.userId
    && item.value.status === 'APPROVED'
    && item.value.highConfidenceMatched
    && item.value.pendingCompletionStatus !== 'PENDING'
})

const handleClaim = async () => {
  try {
    const { value } = await ElMessageBox.prompt(
      '请简要填写能证明物品归属的信息，提交后由审核员处理。',
      '提交认领申请',
      {
        confirmButtonText: '提交',
        cancelButtonText: '取消',
        inputPlaceholder: '例如：物品特征、购买记录、证件信息等',
        inputType: 'textarea'
      }
    )
    await itemStore.claimItem(item.value.id, value || '')
    showInfo('认领申请已提交，请等待审核')
  } catch (error) {
    if (error === 'cancel' || error === 'close') {
      return
    }
    showError(error?.message || '提交认领申请失败')
  }
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

onMounted(async () => {
  try {
    const itemId = parseInt(route.params.id)
    item.value = await itemStore.fetchItem(itemId)

    const params = {
      type: item.value?.type === 'LOST' ? 'FOUND' : 'LOST',
      category: item.value?.category
    }
    const result = await itemStore.fetchItems(params)
    relatedItems.value = result?.records?.slice(0, 3) || []
  } catch (error) {
    console.error('获取物品详情失败:', error)
    showError(typeof error === 'string' ? error : (error?.message || '获取物品详情失败'))
  }
})
</script>

<style scoped>
.item-detail-page {
  margin: 0 auto;
  max-width: var(--app-max-width-medium);
}

.detail-header {
  text-align: center;
  margin-bottom: var(--app-space-6);
}

.tags {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-bottom: 16px;
}

.item-title {
  font-size: 32px;
  margin: 0;
}

.item-images {
  display: flex;
  gap: 12px;
  margin-bottom: var(--app-space-6);
  overflow-x: auto;
}

.item-image {
  width: 200px;
  height: 200px;
  object-fit: cover;
  border-radius: var(--app-radius-sm);
  border: 1px solid var(--app-border);
}

.detail-info {
  margin-bottom: var(--app-space-6);
}

.info-card {
  overflow: hidden;
}

.info-card-title {
  font-weight: 800;
  letter-spacing: 0.2px;
  margin-bottom: var(--app-space-4);
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 10px 0;
  border-bottom: 1px solid var(--app-border);
}

.info-row:last-child {
  border-bottom: none;
}

.info-label {
  color: var(--app-muted);
}

.info-value {
  color: var(--app-text);
  font-weight: 500;
}

.description-text {
  line-height: 1.8;
  color: var(--app-muted);
  margin: 0;
}

.detail-actions {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-bottom: var(--app-space-8);
  flex-wrap: wrap;
}

.related-section {
  margin-top: var(--app-space-8);
}

.related-section h3 {
  font-size: 20px;
  margin-bottom: var(--app-space-4);
}

.related-items {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.empty-related {
  text-align: center;
  padding: 40px;
  color: var(--app-muted);
}

.loading-state {
  text-align: center;
  padding: 100px;
}

.loading-state p {
  margin-top: 16px;
  color: var(--app-muted);
}

.loading-icon {
  font-size: 44px;
  color: var(--app-primary);
}
</style>
