<template>
  <div class="match-list-page app-page">
    <div class="page-header app-page-header">
      <BackButton show-text />
      <div>
        <div class="app-page-title">
          <el-icon class="page-icon"><Connection /></el-icon>
          <h2>匹配列表</h2>
        </div>
        <p class="app-page-subtitle">系统为您匹配的可能相关物品</p>
      </div>
    </div>

    <div class="stats-row app-surface app-panel">
      <el-statistic title="匹配总数" :value="total" />
      <el-statistic title="待确认" :value="pendingCount" />
      <el-statistic title="已确认" :value="confirmedCount" />
      <el-statistic title="已拒绝" :value="rejectedCount" />
    </div>

    <div class="filter-bar">
      <el-select v-model="filterStatus" placeholder="筛选状态" @change="handleFilter">
        <el-option label="全部" value="" />
        <el-option label="待确认" value="PENDING" />
        <el-option label="已确认" value="CONFIRMED" />
        <el-option label="已拒绝" value="REJECTED" />
      </el-select>
    </div>

    <div class="match-list">
      <el-card 
        v-for="match in matches" 
        :key="match.id" 
        class="match-card"
        shadow="never"
      >
        <div class="match-header">
          <div class="match-score">
            <span class="score-label">匹配度</span>
            <span class="score-value" :class="getScoreClass(match.score)">
              {{ formatScore(match.score) }}
            </span>
          </div>
          <el-tag :type="getStatusTagType(match.status)">
            {{ getStatusText(match.status) }}
          </el-tag>
        </div>

        <div class="match-content">
          <div class="item-pair">
            <div class="item-box lost">
              <h4>寻物启示</h4>
              <p class="item-title">{{ match.lostItemTitle || '寻物启示' }}</p>
              <p class="item-category">{{ match.lostItemCategory || '未分类' }}</p>
            </div>
            
            <div class="arrow">
              <el-icon :size="32"><ArrowRight /></el-icon>
            </div>
            
            <div class="item-box found">
              <h4>失物招领</h4>
              <p class="item-title">{{ match.foundItemTitle || '失物招领' }}</p>
              <p class="item-category">{{ match.foundItemCategory || '未分类' }}</p>
            </div>
          </div>
        </div>

        <div class="match-footer">
          <span class="match-time">匹配时间: {{ formatDate(match.createdAt) }}</span>
          <div class="actions">
            <el-button 
              v-if="match.status === 'PENDING'" 
              @click="handleConfirm(match.id)" 
              type="success" 
              size="small"
            >
              确认匹配
            </el-button>
            <el-button 
              v-if="match.status === 'PENDING'" 
              @click="handleReject(match.id)" 
              type="danger" 
              size="small"
            >
              拒绝匹配
            </el-button>
            <el-button 
              v-if="match.status === 'CONFIRMED' || match.status === 'REJECTED'" 
              @click="handleCancel(match.id)" 
              type="warning" 
              size="small"
            >
              {{ match.status === 'CONFIRMED' ? '取消匹配' : '恢复匹配' }}
            </el-button>
            <div class="detail-buttons">
              <el-button 
                @click="goDetail(match.lostItemId)" 
                type="default" 
                size="small"
              >
                查看寻物
              </el-button>
              <el-button 
                @click="goDetail(match.foundItemId)" 
                type="default" 
                size="small"
              >
                查看招领
              </el-button>
            </div>
          </div>
        </div>
      </el-card>

      <div v-if="matches.length === 0" class="empty-state">
        <el-icon :size="64" class="empty-icon"><Search /></el-icon>
        <p>暂无匹配记录</p>
      </div>
    </div>

    <div v-if="total > pageSize" class="pagination-wrapper">
      <el-pagination
        v-model:current-page="currentPage"
        :page-size="pageSize"
        :total="total"
        :page-sizes="[20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handlePageChange"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ArrowRight, Search, Connection } from '@element-plus/icons-vue'
import { useRouter } from 'vue-router'
import { useItemStore } from '../stores/item'
import { formatDate } from '../utils/format'
import { showError, showSuccess } from '../utils/message'
import BackButton from '../components/BackButton.vue'

const router = useRouter()
const itemStore = useItemStore()

const matches = ref([])
const filterStatus = ref('')
const currentPage = ref(1)
const pageSize = ref(50)
const total = ref(0)

const pendingCount = computed(() => matches.value.filter(m => m.status === 'PENDING').length)
const confirmedCount = computed(() => matches.value.filter(m => m.status === 'CONFIRMED').length)
const rejectedCount = computed(() => matches.value.filter(m => m.status === 'REJECTED').length)

const getScoreClass = (score) => {
  if (score === null || score === undefined) return 'low'
  const num = typeof score === 'number' ? score : parseFloat(score)
  if (num > 1) {
    return num >= 80 ? 'high' : num >= 60 ? 'medium' : 'low'
  }
  return num >= 0.8 ? 'high' : num >= 0.6 ? 'medium' : 'low'
}

const formatScore = (score) => {
  if (score === null || score === undefined) return '0%'
  if (typeof score === 'number') {
    return score > 1 ? Math.round(score * 100) + '%' : Math.round(score * 100) + '%'
  }
  const num = parseFloat(score)
  return num > 1 ? Math.round(num) + '%' : Math.round(num * 100) + '%'
}

const getStatusTagType = (status) => {
  const statusMap = {
    'PENDING': 'warning',
    'CONFIRMED': 'success',
    'REJECTED': 'danger'
  }
  return statusMap[status] || 'default'
}

const getStatusText = (status) => {
  const statusMap = {
    'PENDING': '待确认',
    'CONFIRMED': '已确认',
    'REJECTED': '已拒绝'
  }
  return statusMap[status] || status
}

const handleFilter = () => {
  currentPage.value = 1
  fetchMatchList()
}

const handleSizeChange = (newSize) => {
  pageSize.value = newSize
  currentPage.value = 1
  fetchMatchList()
}

const handlePageChange = (newPage) => {
  currentPage.value = newPage
  fetchMatchList()
}

const fetchMatchList = async () => {
  try {
    const params = {
      page: currentPage.value,
      pageSize: pageSize.value
    }
    if (filterStatus.value) {
      params.status = filterStatus.value
    }
    const result = await itemStore.fetchMatches(params)
    matches.value = result?.records || []
    // 注意：total 字段在 fetchTotalCount 中独立更新，保持匹配总数不变
    return true
  } catch (error) {
    console.error('获取匹配列表失败:', error)
    showError(error?.message || '获取匹配列表失败')
    return false
  }
}

// 单独获取匹配总数（不随筛选条件变化）
const fetchTotalCount = async () => {
  try {
    const result = await itemStore.fetchMatches({
      page: 1,
      pageSize: 1
      // 不传 status，获取所有匹配的总数
    })
    total.value = result?.total || 0
  } catch (error) {
    console.error('获取匹配总数失败:', error)
  }
}

const handleConfirm = async (matchId) => {
  try {
    await itemStore.confirmMatch(matchId)
    const refreshed = await fetchMatchList()
    showSuccess(refreshed ? '匹配确认成功' : '匹配确认成功，请手动刷新查看最新结果')
  } catch (error) {
    console.error('确认失败:', error)
    showError(error?.message || '匹配确认失败')
  }
}

const handleReject = async (matchId) => {
  try {
    await itemStore.rejectMatch(matchId)
    const match = matches.value.find(m => m.id === matchId)
    if (match) match.status = 'REJECTED'
    showSuccess('匹配已拒绝')
  } catch (error) {
    console.error('拒绝失败:', error)
    showError(error?.message || '匹配拒绝失败')
  }
}

const handleCancel = async (matchId) => {
  try {
    const previousStatus = matches.value.find(m => m.id === matchId)?.status
    await itemStore.cancelMatch(matchId)
    const refreshed = await fetchMatchList()
    if (previousStatus === 'CONFIRMED') {
      showSuccess(refreshed ? '匹配已取消，已重新匹配并刷新列表' : '匹配已取消，请手动刷新查看最新结果')
    } else {
      showSuccess(refreshed ? '已恢复为待确认状态并刷新列表' : '已恢复为待确认状态，请手动刷新查看最新结果')
    }
  } catch (error) {
    console.error('取消失败:', error)
    showError(error?.message || '操作失败')
  }
}

const goDetail = (itemId) => {
  router.push(`/item/${itemId}`)
}

onMounted(async () => {
  // 初始化时同时获取列表和总数
  await fetchMatchList()
  await fetchTotalCount()
})
</script>

<style scoped>
.match-list-page {
  margin: 0 auto;
  max-width: var(--app-max-width-medium);
}

.page-header {
  margin-bottom: 0;
}

.stats-row {
  display: flex;
  gap: 40px;
  margin-bottom: 0;
  flex-wrap: wrap;
}

.filter-bar {
  margin-bottom: 0;
}

.match-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.match-card {
  border-radius: var(--app-radius);
  border: 1px solid var(--app-border);
  overflow: hidden;
}

.match-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.match-score {
  display: flex;
  align-items: baseline;
  gap: 8px;
}

.score-label {
  font-size: 14px;
  color: var(--app-muted);
}

.score-value {
  font-size: 28px;
  font-weight: bold;
}

.score-value.high {
  color: var(--app-success);
}

.score-value.medium {
  color: var(--app-warning);
}

.score-value.low {
  color: var(--app-danger);
}

.item-pair {
  display: flex;
  align-items: center;
  gap: 20px;
}

.item-box {
  flex: 1;
  padding: 16px;
  border-radius: var(--app-radius-sm);
  border: 1px solid var(--app-border);
}

.item-box.lost {
  background: var(--app-danger-bg);
  border-left: 4px solid var(--app-danger);
}

.item-box.found {
  background: var(--app-success-bg);
  border-left: 4px solid var(--app-success);
}

.item-box h4 {
  margin: 0 0 8px 0;
  font-size: 14px;
  color: var(--app-muted);
}

.item-box .item-title {
  margin: 0 0 4px 0;
  font-weight: bold;
}

.item-box .item-category {
  margin: 0;
  font-size: 14px;
  color: var(--app-muted);
}

.arrow {
  color: var(--app-primary);
}

.match-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid var(--app-border);
  gap: var(--app-space-4);
  flex-wrap: wrap;
}

.match-time {
  color: var(--app-muted);
  font-size: 14px;
}

.actions {
  display: flex;
  gap: 8px;
}

.detail-buttons {
  display: flex;
  gap: 6px;
}

.empty-state {
  text-align: center;
  padding: 60px;
  color: var(--app-muted);
}

.empty-icon {
  margin-bottom: 16px;
  color: var(--app-gray-200);
}

.page-icon {
  color: var(--app-primary);
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  padding: 20px 0;
}
</style>
