<template>
  <div class="my-items-page app-page">
    <div class="page-header app-page-header">
      <div class="app-page-title">
        <el-icon class="page-icon"><Tickets /></el-icon>
        <h2>我的物品</h2>
      </div>
      <div class="filter-tabs">
        <el-button 
          @click="activeTab = 'all'" 
          :type="activeTab === 'all' ? 'primary' : 'default'"
        >
          全部
        </el-button>
        <el-button 
          @click="activeTab = 'lost'" 
          :type="activeTab === 'lost' ? 'primary' : 'default'"
        >
          寻物
        </el-button>
        <el-button 
          @click="activeTab = 'found'" 
          :type="activeTab === 'found' ? 'primary' : 'default'"
        >
          招领
        </el-button>
        <el-button 
          @click="activeTab = 'claimed'" 
          :type="activeTab === 'claimed' ? 'primary' : 'default'"
        >
          已认领
        </el-button>
      </div>
    </div>

    <div class="item-list">
      <el-card 
        v-for="item in filteredItems" 
        :key="item.id" 
        class="item-card"
      >
        <div class="card-content">
          <div class="card-header">
            <div class="tags">
              <el-tag :type="getTypeTagType(item.type)">
                {{ item.type === 'LOST' ? '寻物' : '招领' }}
              </el-tag>
              <el-tag v-if="item.highConfidenceMatched" type="danger">
                已匹配
              </el-tag>
              <el-tag v-if="item.pendingCompletionStatus === 'PENDING'" type="warning">
                {{ formatCompletionTargetStatus(item.pendingCompletionTargetStatus) }}审核中
              </el-tag>
              <el-tag :type="getStatusColor(item.status)">
                {{ formatStatus(item.status) }}
              </el-tag>
            </div>
          </div>
          
          <h3 class="item-title">{{ item.title }}</h3>
          <p class="item-description">{{ truncate(item.description) }}</p>
          
          <div class="item-info">
            <div class="info-item">
              <el-icon><Location /></el-icon>
              <span>{{ getLocationName(item.locationId) }}</span>
            </div>
            <div class="info-item">
              <el-icon><Calendar /></el-icon>
              <span>{{ formatDate(item.type === 'LOST' ? item.lostTime : item.foundTime) }}</span>
            </div>
          </div>

          <div class="card-footer">
            <div class="meta">
              <span class="category">{{ item.category }}</span>
            </div>
            <div class="actions">
              <el-button @click="goDetail(item.id)" type="default" size="small">
                查看详情
              </el-button>
              <el-button 
                v-if="item.status === 'PENDING'" 
                @click="handleEdit(item.id)" 
                type="primary" 
                size="small"
              >
                编辑
              </el-button>
              <el-button 
                v-if="canSubmitCompletion(item)"
                @click="handleCompletionRequest(item)"
                type="success"
                size="small"
              >
                {{ item.type === 'LOST' ? '申请已找到' : '申请已归还' }}
              </el-button>
              <el-button 
                v-if="item.status === 'PENDING' || item.status === 'REJECTED'" 
                @click="handleDelete(item.id)" 
                type="danger" 
                size="small"
              >
                删除
              </el-button>
            </div>
          </div>
        </div>
      </el-card>

      <div v-if="filteredItems.length === 0" class="empty-state">
        <el-icon :size="64" class="empty-icon"><Box /></el-icon>
        <p>暂无{{ getTabLabel() }}物品</p>
        <el-button @click="goPublish" type="primary">发布信息</el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'
import { Location, Calendar, Box, Tickets } from '@element-plus/icons-vue'
import { useItemStore } from '../stores/item'
import { confirmAction, showError, showSuccess } from '../utils/message'
import { formatCompletionTargetStatus, formatDate, formatStatus, getStatusColor, getTypeColor } from '../utils/format'

const router = useRouter()
const itemStore = useItemStore()

const activeTab = ref('all')
const myItems = ref([])

const filteredItems = computed(() => {
  switch (activeTab.value) {
    case 'lost':
      return myItems.value.filter(i => i.type === 'LOST')
    case 'found':
      return myItems.value.filter(i => i.type === 'FOUND')
    case 'claimed':
      return myItems.value.filter(i => i.highConfidenceMatched || i.status === 'FOUND_BACK' || i.status === 'RETURNED')
    default:
      return myItems.value
  }
})

const getTabLabel = () => {
  const labelMap = {
    'all': '',
    'lost': '寻物',
    'found': '招领',
    'claimed': '已匹配/已完成'
  }
  return labelMap[activeTab.value] || ''
}

const getLocationName = (locationId) => {
  const location = itemStore.locations.find(l => l.id === locationId)
  return location?.name || '未知位置'
}

const getTypeTagType = (type) => getTypeColor(type)

const truncate = (text) => {
  if (!text) return ''
  return text.length > 80 ? text.substring(0, 80) + '...' : text
}

const goDetail = (itemId) => {
  router.push(`/item/${itemId}`)
}

const handleEdit = (itemId) => {
  router.push(`/publish?id=${itemId}`)
}

const handleDelete = async (itemId) => {
  try {
    await confirmAction('确定要删除该物品吗？')
  } catch {
    return
  }
  try {
    await itemStore.deleteItem(itemId)
    myItems.value = myItems.value.filter(i => i.id !== itemId)
    showSuccess('删除成功')
  } catch (error) {
    console.error('删除失败:', error)
    showError(error?.message || error || '删除失败')
  }
}

const canSubmitCompletion = (item) => {
  return item.status === 'APPROVED'
    && item.highConfidenceMatched
    && item.pendingCompletionStatus !== 'PENDING'
}

const handleCompletionRequest = async (item) => {
  try {
    const { value } = await ElMessageBox.prompt(
      item.type === 'LOST' ? '请填写“已找到”的补充说明。' : '请填写“已归还”的补充说明。',
      '提交完成申请',
      {
        confirmButtonText: '提交',
        cancelButtonText: '取消',
        inputType: 'textarea'
      }
    )
    await itemStore.submitCompletionRequest(item.id, {
      targetStatus: item.type === 'LOST' ? 'FOUND_BACK' : 'RETURNED',
      reason: value || ''
    })
    item.pendingCompletionStatus = 'PENDING'
    item.pendingCompletionTargetStatus = item.type === 'LOST' ? 'FOUND_BACK' : 'RETURNED'
    showSuccess(`已提交${formatCompletionTargetStatus(item.pendingCompletionTargetStatus)}申请`)
  } catch (error) {
    if (error === 'cancel' || error === 'close') {
      return
    }
    showError(error?.message || '提交完成申请失败')
  }
}

const goPublish = () => {
  router.push('/publish')
}

onMounted(async () => {
  await itemStore.fetchLocations()
  const result = await itemStore.fetchMyItems({})
  myItems.value = result?.records || []
})
</script>

<style scoped>
.my-items-page {
  margin: 0 auto;
  max-width: var(--app-max-width-narrow);
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0;
}

.page-header h2 {
  margin: 0;
}

.filter-tabs {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.item-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.item-card {
  padding: 20px;
}

.card-content {
  display: flex;
  flex-direction: column;
}

.card-header {
  margin-bottom: 12px;
}

.tags {
  display: flex;
  gap: 8px;
}

.item-title {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 8px;
}

.item-description {
  color: var(--app-muted);
  margin-bottom: 12px;
}

.item-info {
  display: flex;
  gap: 20px;
  margin-bottom: 12px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 4px;
  color: var(--app-muted);
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 12px;
  border-top: 1px solid var(--app-border);
}

.meta {
  display: flex;
  gap: 12px;
}

.category {
  padding: 2px 8px;
  background: var(--app-gray-50);
  border: 1px solid var(--app-border);
  border-radius: 999px;
  font-size: 12px;
  color: var(--app-muted);
}

.actions {
  display: flex;
  gap: 8px;
}

.empty-state {
  text-align: center;
  padding: 60px;
}

.empty-icon {
  margin-bottom: 16px;
  color: var(--app-gray-200);
}

.empty-state p {
  color: var(--app-muted);
  margin-bottom: 16px;
}

.page-icon {
  color: var(--app-primary);
}
</style>
