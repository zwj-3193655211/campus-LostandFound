<template>
  <div class="admin-dashboard">
    <div class="dashboard-header">
      <BackButton show-text />
      <h2>管理员控制台</h2>
      <span class="current-time">{{ currentTime }}</span>
    </div>

    <div class="stats-grid">
      <el-card class="stat-card">
        <div class="stat-icon users-icon">
          <el-icon :size="40"><User /></el-icon>
        </div>
        <div class="stat-info">
          <p class="stat-value">{{ stats.totalUsers }}</p>
          <p class="stat-label">用户总数</p>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-icon items-icon">
          <el-icon :size="40"><Box /></el-icon>
        </div>
        <div class="stat-info">
          <p class="stat-value">{{ stats.totalItems }}</p>
          <p class="stat-label">物品总数</p>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-icon pending-icon">
          <el-icon :size="40"><Clock /></el-icon>
        </div>
        <div class="stat-info">
          <p class="stat-value">{{ stats.pendingItems }}</p>
          <p class="stat-label">待审核物品</p>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-icon match-icon">
          <el-icon :size="40"><CircleCheck /></el-icon>
        </div>
        <div class="stat-info">
          <p class="stat-value">{{ stats.totalMatches }}</p>
          <p class="stat-label">匹配总数</p>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-icon claimed-icon">
          <el-icon :size="40"><Check /></el-icon>
        </div>
        <div class="stat-info">
          <p class="stat-value">{{ stats.claimedItems }}</p>
          <p class="stat-label">已完成物品</p>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-icon rate-icon">
          <el-icon :size="40"><ArrowUp /></el-icon>
        </div>
        <div class="stat-info">
          <p class="stat-value">{{ stats.claimRate }}%</p>
          <p class="stat-label">完成率</p>
        </div>
      </el-card>
    </div>

    <div class="quick-actions-bar">
      <el-card class="quick-actions-card">
        <div class="quick-actions">
          <el-button @click="goToUsers" type="primary" class="action-btn">
            <el-icon><UsersIcon /></el-icon>
            用户管理
          </el-button>
          <el-button @click="goToIdentityVerifications" type="danger" class="action-btn">
            <el-icon><User /></el-icon>
            实名审核
          </el-button>
          <el-button @click="goToItems" type="success" class="action-btn">
            <el-icon><Box /></el-icon>
            物品管理
          </el-button>
          <el-button @click="goToStatistics" type="info" class="action-btn">
            <el-icon><Cellphone /></el-icon>
            数据统计
          </el-button>
        </div>
      </el-card>
    </div>

    <div class="dashboard-content">
      <div class="left-panel">
        <el-card title="待审核物品">
          <div v-if="pendingItems.length === 0" class="empty-tip">
            暂无待审核物品
          </div>
          <el-table v-else :data="pendingItems" border>
            <el-table-column prop="title" label="物品名称" />
            <el-table-column prop="category" label="类别" />
            <el-table-column prop="type" label="类型">
              <template #default="scope">
                <el-tag :type="scope.row.type === 'LOST' ? 'danger' : 'success'">
                  {{ scope.row.type === 'LOST' ? '寻物' : '招领' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createdAt" label="发布时间" />
            <el-table-column label="操作">
              <template #default="scope">
                <el-button @click="handleVerify(scope.row.id, true)" type="success" size="small">
                  通过
                </el-button>
                <el-button @click="handleVerify(scope.row.id, false)" type="danger" size="small">
                  拒绝
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </div>

      <div class="right-panel">
        <el-card title="待审核实名认证">
          <div v-if="pendingIdentityRequests.length === 0" class="empty-tip">
            暂无待审核实名认证
          </div>
          <el-table v-else :data="pendingIdentityRequests" border>
            <el-table-column prop="username" label="用户名" />
            <el-table-column prop="realName" label="姓名" />
            <el-table-column prop="idCard" label="身份证号" show-overflow-tooltip />
            <el-table-column prop="createdAt" label="申请时间">
              <template #default="scope">
                {{ scope.row.createdAt || '未知' }}
              </template>
            </el-table-column>
            <el-table-column label="操作" width="180">
              <template #default="scope">
                <el-button @click="handleReviewIdentity(scope.row.id, true)" type="success" size="small">
                  通过
                </el-button>
                <el-button @click="handleReviewIdentity(scope.row.id, false)" type="danger" size="small">
                  拒绝
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>

        <el-card title="待审核完成申请">
          <div v-if="completionRequests.length === 0" class="empty-tip">
            暂无待审核完成申请
          </div>
          <el-table v-else :data="completionRequests" border>
            <el-table-column prop="itemId" label="物品ID" width="88" />
            <el-table-column prop="targetStatusText" label="目标状态" />
            <el-table-column prop="reason" label="申请说明" show-overflow-tooltip />
            <el-table-column label="操作" width="180">
              <template #default="scope">
                <el-button @click="handleReviewCompletion(scope.row.id, true)" type="success" size="small">
                  通过
                </el-button>
                <el-button @click="handleReviewCompletion(scope.row.id, false)" type="danger" size="small">
                  拒绝
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>

        <el-card title="最近匹配">
          <div v-if="recentMatches.length === 0" class="empty-tip">
            暂无匹配记录
          </div>
          <el-table v-else :data="recentMatches" border>
            <el-table-column prop="score" label="匹配度">
              <template #default="scope">
                <span :class="getScoreClass(scope.row.score)">{{ scope.row.score }}%</span>
              </template>
            </el-table-column>
            <el-table-column prop="lostItemTitle" label="寻物启示" />
            <el-table-column prop="foundItemTitle" label="失物招领" />
            <el-table-column prop="status" label="状态">
              <template #default="scope">
                <el-tag :type="getStatusTagType(scope.row.status)">
                  {{ getStatusText(scope.row.status) }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useItemStore } from '../stores/item'
import { useUserStore } from '../stores/user'
import { showError, showSuccess } from '../utils/message'
import BackButton from '../components/BackButton.vue'
import { 
  User, Box, Clock, CircleCheck, Check, ArrowUp, 
  User as UsersIcon, Location, Cellphone 
} from '@element-plus/icons-vue'

const router = useRouter()
const itemStore = useItemStore()
const userStore = useUserStore()

const currentTime = ref('')
const stats = reactive({
  totalUsers: 0,
  totalItems: 0,
  pendingItems: 0,
  totalMatches: 0,
  claimedItems: 0,
  claimRate: 0
})

const pendingItems = ref([])
const recentMatches = ref([])
const completionRequests = ref([])
const pendingIdentityRequests = ref([])

let timer = null

const updateTime = () => {
  const now = new Date()
  currentTime.value = now.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

const getScoreClass = (score) => {
  if (score >= 80) return 'score-high'
  if (score >= 60) return 'score-medium'
  return 'score-low'
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

const handleVerify = async (itemId, approved) => {
  try {
    await itemStore.verifyItem(itemId, approved)
    await fetchData()
    showSuccess(approved ? '审核通过' : '审核拒绝')
  } catch (error) {
    console.error('审核失败:', error)
    showError(error?.message || '审核失败')
  }
}

const handleReviewCompletion = async (requestId, approved) => {
  try {
    await itemStore.reviewCompletionRequest(requestId, approved, approved ? '' : '管理员审核未通过')
    await fetchData()
    showSuccess(approved ? '完成申请已通过' : '完成申请已拒绝')
  } catch (error) {
    console.error('审核完成申请失败:', error)
    showError(error?.message || '审核完成申请失败')
  }
}

const handleReviewIdentity = async (requestId, approved) => {
  try {
    await userStore.reviewIdentityVerification(requestId, approved, approved ? '' : '管理员审核未通过')
    await fetchData()
    showSuccess(approved ? '实名认证已通过' : '实名认证已拒绝')
  } catch (error) {
    console.error('审核实名认证失败:', error)
    showError(error?.message || '审核实名认证失败')
  }
}

const goToUsers = () => {
  router.push('/admin/users')
}

const goToItems = () => {
  router.push('/items')
}

const goToIdentityVerifications = () => {
  router.push('/admin/identity-verifications')
}

const goToStatistics = () => {
  router.push('/admin/statistics')
}

const fetchData = async () => {
  try {
    const dashboardData = await itemStore.fetchDashboardStats()
    if (dashboardData) {
      stats.totalUsers = dashboardData.totalUsers || 0
      stats.totalItems = dashboardData.totalItems || 0
      stats.pendingItems = dashboardData.pendingItems || 0
      stats.totalMatches = dashboardData.totalMatches || 0
      stats.claimedItems = dashboardData.claimedItems || 0
      stats.claimRate = dashboardData.claimRate || 0
    }

    const pendingResult = await itemStore.fetchPendingItems()
    if (Array.isArray(pendingResult)) {
      pendingItems.value = pendingResult.map(item => ({
        id: item.id,
        title: item.title,
        category: item.category,
        type: item.type,
        createdAt: item.createdAt
      }))
    }

    const completionResult = await itemStore.fetchCompletionRequests()
    if (Array.isArray(completionResult)) {
      completionRequests.value = completionResult.slice(0, 5).map(request => ({
        id: request.id,
        itemId: request.itemId,
        reason: request.reason || '无',
        targetStatusText: request.targetStatus === 'FOUND_BACK' ? '已找到' : '已归还'
      }))
    }

    const identityResult = await userStore.fetchPendingIdentityVerifications()
    if (Array.isArray(identityResult)) {
      pendingIdentityRequests.value = identityResult.slice(0, 5).map(request => ({
        id: request.id,
        username: request.username || `用户#${request.userId}`,
        realName: request.realName,
        idCard: request.idCard,
        createdAt: request.createdAt
      }))
    }

    const matchesResult = await itemStore.fetchMatches()
    if (matchesResult?.records) {
      recentMatches.value = matchesResult.records.slice(0, 5).map(match => ({
        score: match.score ? Math.round(match.score * 100) : 0,
        lostItemTitle: match.lostItemTitle || '寻物启示',
        foundItemTitle: match.foundItemTitle || '失物招领',
        status: match.status
      }))
    }
  } catch (error) {
    console.error('获取数据失败:', error)
    showError(error?.message || '获取数据失败')
  }
}

onMounted(() => {
  updateTime()
  timer = setInterval(updateTime, 1000)
  fetchData()
})

onUnmounted(() => {
  if (timer) clearInterval(timer)
})
</script>

<style scoped>
.admin-dashboard {
  padding: 20px;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.dashboard-header h2 {
  font-size: 24px;
  margin: 0;
}

.current-time {
  font-size: 14px;
  color: #909399;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 16px;
  margin-bottom: 20px;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.users-icon {
  background: #e6f7ff;
  color: #1890ff;
}

.items-icon {
  background: #f6ffed;
  color: #52c41a;
}

.pending-icon {
  background: #fff7e6;
  color: #fa8c16;
}

.match-icon {
  background: #f9f0ff;
  color: #722ed1;
}

.claimed-icon {
  background: #e6fffb;
  color: #13c2c2;
}

.rate-icon {
  background: #fff1f0;
  color: #f5222d;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  margin: 0 0 4px 0;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin: 0;
}

.dashboard-content {
  display: flex;
  gap: 20px;
}

.left-panel {
  flex: 2;
}

.right-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.empty-tip {
  text-align: center;
  padding: 40px;
  color: #999;
}

.quick-actions-bar {
  margin-bottom: 20px;
}

.quick-actions-card {
  padding: 0;
}

.quick-actions {
  display: flex;
  gap: 12px;
  padding: 16px;
  justify-content: space-around;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  min-width: 120px;
  justify-content: center;
}

.score-high {
  color: #67c23a;
  font-weight: bold;
}

.score-medium {
  color: #e6a23c;
  font-weight: bold;
}

.score-low {
  color: #f56c6c;
  font-weight: bold;
}
</style>
