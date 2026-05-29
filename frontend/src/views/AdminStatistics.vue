<template>
  <div class="admin-statistics-page">
    <div class="page-header">
      <h2>数据统计</h2>
    </div>

    <div class="summary-grid">
      <el-card class="summary-card">
        <div class="summary-title">今日寻物</div>
        <div class="summary-value">{{ todayStats.newLost || 0 }}</div>
      </el-card>
      <el-card class="summary-card">
        <div class="summary-title">今日招领</div>
        <div class="summary-value">{{ todayStats.newFound || 0 }}</div>
      </el-card>
      <el-card class="summary-card">
        <div class="summary-title">总用户数</div>
        <div class="summary-value">{{ dashboard.totalUsers || 0 }}</div>
      </el-card>
      <el-card class="summary-card">
        <div class="summary-title">总物品数</div>
        <div class="summary-value">{{ dashboard.totalItems || 0 }}</div>
      </el-card>
    </div>

    <div class="content-grid">
      <el-card>
        <template #header>热门类别</template>
        <el-table :data="categoryRows" border>
          <el-table-column prop="name" label="类别" />
          <el-table-column prop="count" label="数量" />
        </el-table>
      </el-card>

      <el-card>
        <template #header>热门位置</template>
        <el-table :data="locationRows" border>
          <el-table-column prop="name" label="位置" />
          <el-table-column prop="count" label="数量" />
        </el-table>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useItemStore } from '../stores/item'
import { showError } from '../utils/message'

const itemStore = useItemStore()
const dashboard = ref({})
const todayStats = ref({})
const categoryRows = ref([])
const locationRows = ref([])

const convertMapToRows = (data) => {
  return Object.entries(data || {}).map(([name, count]) => ({ name, count }))
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
  text-align: center;
}

.summary-title {
  color: #909399;
  margin-bottom: 8px;
}

.summary-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
}

.content-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}
</style>
