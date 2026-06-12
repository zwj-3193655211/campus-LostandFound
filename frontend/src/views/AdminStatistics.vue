<template>
  <div class="admin-statistics-page">
    <div class="page-header">
      <div class="header-content">
        <el-button @click="goBack" class="back-btn">
          <el-icon><ArrowLeft /></el-icon>
          返回
        </el-button>
        <h2>数据统计</h2>
      </div>
    </div>

    <div class="summary-grid">
      <el-card class="summary-card">
        <div class="summary-icon lost-icon">
          <el-icon :size="32"><Search /></el-icon>
        </div>
        <div class="summary-info">
          <div class="summary-title">今日寻物</div>
          <div class="summary-value">{{ todayStats.newLost || 0 }}</div>
        </div>
      </el-card>
      <el-card class="summary-card">
        <div class="summary-icon found-icon">
          <el-icon :size="32"><Briefcase /></el-icon>
        </div>
        <div class="summary-info">
          <div class="summary-title">今日招领</div>
          <div class="summary-value">{{ todayStats.newFound || 0 }}</div>
        </div>
      </el-card>
      <el-card class="summary-card">
        <div class="summary-icon user-icon">
          <el-icon :size="32"><User /></el-icon>
        </div>
        <div class="summary-info">
          <div class="summary-title">总用户数</div>
          <div class="summary-value">{{ dashboard.totalUsers || 0 }}</div>
        </div>
      </el-card>
      <el-card class="summary-card">
        <div class="summary-icon item-icon">
          <el-icon :size="32"><Box /></el-icon>
        </div>
        <div class="summary-info">
          <div class="summary-title">总物品数</div>
          <div class="summary-value">{{ dashboard.totalItems || 0 }}</div>
        </div>
      </el-card>
    </div>

    <div class="charts-grid">
      <el-card>
        <template #header>
          <span class="card-title">物品类别分布</span>
        </template>
        <div class="category-chart">
          <div 
            v-for="(row, index) in categoryRows.slice(0, 5)" 
            :key="row.name" 
            class="chart-bar-item"
          >
            <span class="bar-label">{{ row.name }}</span>
            <div class="bar-container">
              <div 
                class="bar-fill" 
                :style="{ 
                  width: getBarWidth(row.count, categoryRows) + '%',
                  background: getBarColor(index)
                }"
              ></div>
            </div>
            <span class="bar-count">{{ row.count }}</span>
          </div>
        </div>
      </el-card>

      <el-card>
        <template #header>
          <span class="card-title">热门位置排行</span>
        </template>
        <div class="location-chart">
          <div 
            v-for="(row, index) in locationRows.slice(0, 5)" 
            :key="row.name" 
            class="location-item"
          >
            <span class="rank-badge" :class="'rank-' + (index + 1)">{{ index + 1 }}</span>
            <span class="location-name">{{ row.name }}</span>
            <el-progress 
              :percentage="getPercentage(row.count, locationRows)" 
              :stroke-width="12"
              :color="getProgressColor(index)"
              :show-text="false"
              class="location-progress"
            />
            <span class="location-count">{{ row.count }}件</span>
          </div>
        </div>
      </el-card>
    </div>

    <div class="content-grid">
      <el-card>
        <template #header>
          <span class="card-title">详细类别统计</span>
        </template>
        <el-table :data="categoryRows" border>
          <el-table-column prop="name" label="类别" min-width="120" show-overflow-tooltip />
          <el-table-column prop="count" label="数量" width="80" />
          <el-table-column label="占比" min-width="150">
            <template #default="scope">
              <div class="progress-wrapper">
                <el-progress 
                  :percentage="getPercentage(scope.row.count, categoryRows)" 
                  :stroke-width="16"
                  :show-text="true"
                  text-inside
                  class="category-progress"
                />
              </div>
            </template>
          </el-table-column>
        </el-table>
      </el-card>

      <el-card>
        <template #header>
          <span class="card-title">详细位置统计</span>
        </template>
        <el-table :data="locationRows" border>
          <el-table-column prop="name" label="位置" min-width="180" show-overflow-tooltip />
          <el-table-column prop="count" label="数量" width="80" />
          <el-table-column label="占比" min-width="150">
            <template #default="scope">
              <div class="progress-wrapper">
                <el-progress 
                  :percentage="getPercentage(scope.row.count, locationRows)" 
                  :stroke-width="16"
                  :show-text="true"
                  text-inside
                  class="location-progress-table"
                />
              </div>
            </template>
          </el-table-column>
        </el-table>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useItemStore } from '../stores/item'
import { showError } from '../utils/message'
import { ArrowLeft, Search, Briefcase, User, Box } from '@element-plus/icons-vue'

const router = useRouter()
const itemStore = useItemStore()
const dashboard = ref({})
const todayStats = ref({})
const categoryRows = ref([])
const locationRows = ref([])

const goBack = () => {
  router.push('/admin')
}

const convertMapToRows = (data) => {
  return Object.entries(data || {})
    .map(([name, count]) => ({ name, count }))
    .sort((a, b) => b.count - a.count) // 按数量降序排序
}

const getBarWidth = (count, rows) => {
  const max = Math.max(...rows.map(r => r.count))
  return max > 0 ? (count / max) * 100 : 0
}

const getBarColor = (index) => {
  const colors = ['#1890ff', '#52c41a', '#faad14', '#f5222d', '#722ed1']
  return colors[index % colors.length]
}

const getProgressColor = (index) => {
  const colors = ['#1890ff', '#52c41a', '#faad14', '#f5222d', '#722ed1']
  return colors[index % colors.length]
}

const getPercentage = (count, rows) => {
  const total = rows.reduce((sum, r) => sum + r.count, 0)
  return total > 0 ? Math.round((count / total) * 100) : 0
}

const fetchData = async () => {
  try {
    dashboard.value = await itemStore.fetchDashboardStats()
    todayStats.value = await itemStore.fetchTodayStats()
    categoryRows.value = convertMapToRows(await itemStore.fetchCategoryStats())
    locationRows.value = convertMapToRows(await itemStore.fetchLocationStats())
  } catch (error) {
    console.error('获取统计数据失败:', error)
    showError(error?.message || '获取统计数据失败')
  }
}

onMounted(fetchData)
</script>

<style scoped>
.admin-statistics-page {
  padding: 20px;
}

.page-header {
  margin-bottom: 20px;
}

.header-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.back-btn {
  padding: 8px 16px;
  font-size: 14px;
}

.page-header h2 {
  margin: 0;
  font-size: 24px;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 20px;
}

.summary-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
}

.summary-icon {
  width: 50px;
  height: 50px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.lost-icon {
  background: #e6f7ff;
  color: #1890ff;
}

.found-icon {
  background: #f6ffed;
  color: #52c41a;
}

.user-icon {
  background: #fff7e6;
  color: #fa8c16;
}

.item-icon {
  background: #f9f0ff;
  color: #722ed1;
}

.summary-info {
  flex: 1;
}

.summary-title {
  color: #909399;
  margin-bottom: 8px;
  font-size: 14px;
}

.summary-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
}

.charts-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.card-title {
  font-weight: 600;
}

.category-chart {
  padding: 16px 20px;
}

.chart-bar-item {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.bar-label {
  min-width: 80px;
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 14px;
  color: #606266;
}

.bar-container {
  flex: 1;
  height: 24px;
  background: #f5f7fa;
  border-radius: 12px;
  overflow: hidden;
}

.bar-fill {
  height: 100%;
  border-radius: 12px;
  transition: width 0.3s ease;
}

.bar-count {
  min-width: 30px;
  text-align: right;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.location-chart {
  padding: 16px 20px;
}

.location-item {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.location-item:last-child {
  margin-bottom: 0;
}

.rank-badge {
  min-width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: bold;
  color: #fff;
  background: #909399;
}

.rank-1 {
  background: #f5222d;
}

.rank-2 {
  background: #fa8c16;
}

.rank-3 {
  background: #faad14;
}

.location-name {
  flex: 1;
  min-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 14px;
  color: #606266;
}

.location-progress {
  width: 120px;
  flex-shrink: 0;
}

.location-count {
  min-width: 40px;
  text-align: right;
  font-size: 14px;
  color: #303133;
}

.content-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.progress-wrapper {
  padding: 4px 0;
}

.category-progress :deep(.el-progress__text) {
  font-size: 13px !important;
  font-weight: 600 !important;
  color: #fff !important;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

.location-progress-table :deep(.el-progress__text) {
  font-size: 13px !important;
  font-weight: 600 !important;
  color: #fff !important;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}
</style>
