<template>
  <div class="item-list-page app-page">
    <div class="search-panel app-surface">
      <el-row :gutter="20">
        <el-col :span="8">
          <el-input 
            v-model="searchKeyword" 
            placeholder="搜索名称、描述、品牌、颜色、序列号或位置..." 
            class="search-input"
            @keyup.enter="handleSearch"
          >
            <template #append>
              <el-button @click="handleSearch" type="primary">
                <el-icon><Search /></el-icon>
              </el-button>
            </template>
          </el-input>
        </el-col>
        
        <el-col :span="4">
          <el-select v-model="filters.type" placeholder="选择类型" clearable>
            <el-option label="寻物" value="LOST" />
            <el-option label="招领" value="FOUND" />
          </el-select>
        </el-col>
        
        <el-col :span="4">
          <el-select v-model="filters.category" placeholder="选择类别" clearable>
            <el-option 
              v-for="cat in itemStore.categories" 
              :key="cat.value" 
              :label="cat.label" 
              :value="cat.value" 
            />
          </el-select>
        </el-col>
        
        <el-col :span="4">
          <el-select v-model="filters.locationId" placeholder="选择位置" clearable>
            <el-option 
              v-for="loc in itemStore.locations" 
              :key="loc.id" 
              :label="loc.name" 
              :value="loc.id" 
            />
          </el-select>
        </el-col>
        
        <el-col :span="4">
          <el-button @click="resetFilters" type="default">重置筛选</el-button>
        </el-col>
      </el-row>
      <div class="stats-row">
        <el-statistic title="物品总数" :value="total" />
        <el-statistic title="寻物数量" :value="lostCount" />
        <el-statistic title="招领数量" :value="foundCount" />
      </div>
    </div>

    <div class="item-grid">
      <el-row v-if="items.length > 0" :gutter="20">
        <el-col v-for="item in items" :key="item.id" :span="8">
          <ItemCard :item="item" />
        </el-col>
      </el-row>
      <el-empty v-else :description="emptyText" />
    </div>

    <el-pagination 
      v-if="total > 0"
      :current-page="pagination.current" 
      :page-size="pagination.size" 
      :total="total"
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
      layout="total, sizes, prev, pager, next, jumper"
    />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Search } from '@element-plus/icons-vue'
import { useItemStore } from '../stores/item'
import ItemCard from '../components/ItemCard.vue'
import { showError } from '../utils/message'

const route = useRoute()
const router = useRouter()
const itemStore = useItemStore()

const searchKeyword = ref('')
const items = ref([])
const total = ref(0)
const emptyText = ref('暂无物品')

const filters = reactive({
  type: '',
  category: '',
  locationId: ''
})

const pagination = reactive({
  current: 1,
  size: 9
})

const lostCount = computed(() => {
  return items.value.filter(i => i.type === 'LOST').length
})

const foundCount = computed(() => {
  return items.value.filter(i => i.type === 'FOUND').length
})

const syncQueryToRoute = async () => {
  const query = {
    keyword: searchKeyword.value || undefined,
    type: filters.type || undefined,
    category: filters.category || undefined,
    locationId: filters.locationId || undefined,
    page: pagination.current > 1 ? String(pagination.current) : undefined,
    pageSize: pagination.size !== 9 ? String(pagination.size) : undefined
  }

  await router.replace({ path: '/items', query })
}

const applyRouteQuery = () => {
  searchKeyword.value = route.query.keyword || ''
  filters.type = route.query.type || ''
  filters.category = route.query.category || ''
  filters.locationId = route.query.locationId ? Number(route.query.locationId) : ''
  pagination.current = route.query.page ? Number(route.query.page) : 1
  pagination.size = route.query.pageSize ? Number(route.query.pageSize) : 9
}

const handleSearch = async () => {
  pagination.current = 1
  await syncQueryToRoute()
}

const resetFilters = async () => {
  searchKeyword.value = ''
  filters.type = ''
  filters.category = ''
  filters.locationId = ''
  pagination.current = 1
  pagination.size = 9
  await syncQueryToRoute()
}

const handleSizeChange = async (size) => {
  pagination.size = size
  await syncQueryToRoute()
}

const handleCurrentChange = async (page) => {
  pagination.current = page
  await syncQueryToRoute()
}

const fetchItems = async () => {
  const params = {
    page: pagination.current,
    size: pagination.size,
    keyword: searchKeyword.value || undefined,
    type: filters.type || undefined,
    category: filters.category || undefined,
    locationId: filters.locationId || undefined
  }
  
  try {
    const result = await itemStore.fetchItems(params)
    items.value = result?.records || []
    total.value = result?.total || 0
    emptyText.value = '暂无物品'
  } catch (error) {
    items.value = []
    total.value = 0
    emptyText.value = '物品加载失败'
    showError(typeof error === 'string' ? error : (error?.message || '物品加载失败'))
  }
}

onMounted(async () => {
  try {
    await itemStore.fetchLocations()
  } catch (error) {
    showError(typeof error === 'string' ? error : (error?.message || '位置加载失败'))
  }
  applyRouteQuery()
  await fetchItems()
})

watch(
  () => route.query,
  async () => {
    applyRouteQuery()
    await fetchItems()
  }
)
</script>

<style scoped>
.item-list-page {
  padding: 0;
}

.search-panel {
  padding: 18px;
}

.search-input {
  width: 100%;
}

.stats-row {
  display: flex;
  gap: 36px;
  margin-top: 14px;
  padding-top: 14px;
  border-top: 1px solid var(--app-border);
}

.item-grid {
  margin-bottom: 0;
}

.el-pagination {
  text-align: center;
}
</style>
