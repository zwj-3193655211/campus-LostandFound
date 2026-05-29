<template>
  <div class="admin-identity-page">
    <div class="page-header">
      <h2>实名认证审核</h2>
      <el-button type="primary" @click="fetchData">刷新</el-button>
    </div>

    <el-tabs v-model="activeTab">
      <el-tab-pane label="待审核申请" name="pending">
        <el-card>
          <div v-if="pendingRequests.length === 0" class="empty-tip">暂无待审核实名认证</div>
          <el-table v-else :data="pendingRequests" border v-loading="loading">
            <el-table-column prop="username" label="用户名" />
            <el-table-column prop="realName" label="真实姓名" />
            <el-table-column prop="idCard" label="身份证号" show-overflow-tooltip />
            <el-table-column prop="createdAt" label="申请时间">
              <template #default="scope">
                {{ formatDate(scope.row.createdAt) }}
              </template>
            </el-table-column>
            <el-table-column label="操作" width="200">
              <template #default="scope">
                <el-button @click="handleReview(scope.row.id, true)" type="success" size="small">通过</el-button>
                <el-button @click="handleReview(scope.row.id, false)" type="danger" size="small">拒绝</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>

      <el-tab-pane label="审核历史" name="history">
        <el-card>
          <div v-if="historyRequests.length === 0" class="empty-tip">暂无实名认证申请历史</div>
          <el-table v-else :data="historyRequests" border v-loading="loading">
            <el-table-column prop="username" label="用户名" />
            <el-table-column prop="realName" label="真实姓名" />
            <el-table-column prop="idCard" label="身份证号" show-overflow-tooltip />
            <el-table-column label="状态" width="110">
              <template #default="scope">
                <el-tag :type="getStatusType(scope.row.status)">
                  {{ getStatusText(scope.row.status) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createdAt" label="申请时间">
              <template #default="scope">
                {{ formatDate(scope.row.createdAt) }}
              </template>
            </el-table-column>
            <el-table-column prop="reviewedAt" label="审核时间">
              <template #default="scope">
                {{ formatDate(scope.row.reviewedAt) || '未审核' }}
              </template>
            </el-table-column>
            <el-table-column prop="reviewerName" label="审核人" />
            <el-table-column prop="reviewReason" label="审核原因" show-overflow-tooltip>
              <template #default="scope">
                {{ scope.row.reviewReason || (scope.row.status === 'VERIFIED' ? '审核通过' : '无' ) }}
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { ElMessageBox } from 'element-plus'
import { useUserStore } from '../stores/user'
import { formatDate } from '../utils/format'
import { showError, showSuccess } from '../utils/message'

const userStore = useUserStore()
const activeTab = ref('pending')
const loading = ref(false)
const pendingRequests = ref([])
const historyRequests = ref([])

const getStatusText = (status) => {
  const statusMap = {
    PENDING: '待审核',
    VERIFIED: '已通过',
    REJECTED: '已拒绝'
  }
  return statusMap[status] || status
}

const getStatusType = (status) => {
  const typeMap = {
    PENDING: 'warning',
    VERIFIED: 'success',
    REJECTED: 'danger'
  }
  return typeMap[status] || 'info'
}

const fetchData = async () => {
  loading.value = true
  try {
    const [pending, history] = await Promise.all([
      userStore.fetchPendingIdentityVerifications(),
      userStore.fetchIdentityVerificationHistory()
    ])
    pendingRequests.value = pending || []
    historyRequests.value = history || []
  } catch (error) {
    console.error('获取实名认证申请失败:', error)
    showError(error?.message || '获取实名认证申请失败')
  } finally {
    loading.value = false
  }
}

const handleReview = async (requestId, approved) => {
  let reason = ''
  if (!approved) {
    try {
      const result = await ElMessageBox.prompt('请填写拒绝原因', '实名认证审核', {
        confirmButtonText: '提交',
        cancelButtonText: '取消',
        inputPlaceholder: '例如：信息不完整、证件号格式有误'
      })
      reason = result.value || '管理员审核未通过'
    } catch {
      return
    }
  }

  try {
    await userStore.reviewIdentityVerification(requestId, approved, reason)
    await fetchData()
    showSuccess(approved ? '实名认证审核通过' : '实名认证审核已拒绝')
  } catch (error) {
    console.error('审核实名认证失败:', error)
    showError(error?.message || '审核实名认证失败')
  }
}

onMounted(fetchData)
</script>

<style scoped>
.admin-identity-page {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  font-size: 24px;
}

.empty-tip {
  text-align: center;
  padding: 40px;
  color: #999;
}
</style>
