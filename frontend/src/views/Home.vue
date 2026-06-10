<template>
  <div class="home-page">
    <div class="hero-section">
      <div class="hero-bg-decoration">
        <div class="bg-blob blob-1"></div>
        <div class="bg-blob blob-2"></div>
        <div class="bg-blob blob-3"></div>
        <div class="bg-grid"></div>
      </div>
      
      <div class="hero-content">
        <div class="hero-badge animate-fade-in-up">校园失物招领平台</div>
        <h1 class="hero-title animate-fade-in-up" style="animation-delay: 0.1s">
          {{ siteConfig.name }}
        </h1>
        <p class="hero-subtitle animate-fade-in-up" style="animation-delay: 0.2s">
          {{ siteConfig.slogan }}
        </p>
        <div class="hero-search animate-fade-in-up" style="animation-delay: 0.3s">
          <el-input 
            v-model="searchKeyword" 
            placeholder="搜索物品名称、描述..." 
            class="search-input"
            @keyup.enter="handleSearch"
          >
            <template #append>
              <el-button @click="handleSearch" type="primary" class="search-btn">
                <el-icon><Search /></el-icon>
                <span>搜索</span>
              </el-button>
            </template>
          </el-input>
        </div>
      </div>

      <div class="hero-stats animate-fade-in-up" style="animation-delay: 0.4s">
        <div class="stat-item">
          <div class="stat-icon found-icon">
            <el-icon :size="24"><CircleCheck /></el-icon>
          </div>
          <div class="stat-content">
            <el-statistic title="已帮助找回" :value="stats.found" :suffix="'件'" />
          </div>
        </div>
        <div class="stat-divider"></div>
        <div class="stat-item">
          <div class="stat-icon total-icon">
            <el-icon :size="24"><Box /></el-icon>
          </div>
          <div class="stat-content">
            <el-statistic title="物品总数" :value="stats.total" :suffix="'件'" />
          </div>
        </div>
        <div class="stat-divider"></div>
        <div class="stat-item">
          <div class="stat-icon match-icon">
            <el-icon :size="24"><Trophy /></el-icon>
          </div>
          <div class="stat-content">
            <el-statistic title="匹配成功" :value="stats.matched" :suffix="'次'" />
          </div>
        </div>
      </div>
    </div>

    <div class="feature-section">
      <div class="section-header">
        <div class="section-title-wrapper">
          <el-icon :size="24" class="section-icon"><Star /></el-icon>
          <h2 class="section-title">平台特色</h2>
        </div>
        <p class="section-desc">智能匹配，高效找回</p>
      </div>
      <div class="feature-cards">
        <div 
          class="feature-card" 
          v-for="(feature, index) in features" 
          :key="feature.title" 
          :style="{ animationDelay: `${index * 0.15}s` }"
        >
          <div :class="['feature-icon', feature.iconClass]">
            <el-icon :size="40"><component :is="feature.icon" /></el-icon>
          </div>
          <h3>{{ feature.title }}</h3>
          <p>{{ feature.description }}</p>
          <div class="feature-glow"></div>
        </div>
      </div>
    </div>

    <div class="category-section">
      <div class="section-header">
        <div class="section-title-wrapper">
          <el-icon :size="24" class="section-icon"><Grid /></el-icon>
          <h2 class="section-title">物品分类</h2>
        </div>
        <p class="section-desc">快速筛选</p>
      </div>
      <div class="category-grid">
        <div 
          v-for="cat in categories" 
          :key="cat.value" 
          class="category-item"
          @click="handleCategoryClick(cat.value)"
        >
          <div :class="['category-icon', cat.iconClass]">
            <el-icon :size="32"><component :is="cat.icon" /></el-icon>
          </div>
          <span>{{ cat.label }}</span>
          <div class="category-count">{{ cat.count }}</div>
          <div class="category-ripple"></div>
        </div>
      </div>
    </div>

    <div class="recent-section">
      <div class="section-header">
        <div class="section-title-wrapper">
          <el-icon :size="24" class="section-icon"><Clock /></el-icon>
          <h2 class="section-title">最新发布</h2>
          <span class="time-badge">最近一周</span>
        </div>
        <el-button @click="goToItems" type="text" class="view-more-btn">
          查看更多
          <el-icon><ArrowRight /></el-icon>
        </el-button>
      </div>
      <div class="recent-items">
        <div class="items-grid">
          <div 
            v-for="(item, index) in recentItems" 
            :key="item.id" 
            class="item-card-wrapper" 
            :style="{ animationDelay: `${index * 0.15}s` }"
          >
            <ItemCard :item="item" />
          </div>
        </div>
        <div v-if="recentItems.length === 0" class="empty-state">
          <el-icon :size="64" class="empty-icon"><Box /></el-icon>
          <p>暂无物品信息</p>
        </div>
        <div class="pagination-wrapper">
          <el-pagination
            v-model:current-page="currentPage"
            :page-size="pageSize"
            :total="total"
            layout="prev, pager, next"
            @current-change="handlePageChange"
            background
          />
        </div>
      </div>
    </div>

    <div class="guide-section">
      <div class="section-header">
        <div class="section-title-wrapper">
          <el-icon :size="24" class="section-icon"><Compass /></el-icon>
          <h2 class="section-title">使用指南</h2>
        </div>
        <p class="section-desc">简单四步，轻松找回</p>
      </div>
      <div class="guide-container">
        <div class="guide-steps">
          <div class="guide-step" v-for="(step, index) in guideSteps" :key="step.number">
            <div class="step-number">{{ step.number }}</div>
            <div class="step-content">
              <h3>{{ step.title }}</h3>
              <p>{{ step.description }}</p>
            </div>
          </div>
        </div>
        <div class="guide-flow">
          <div class="flow-line">
            <div class="flow-dots">
              <div v-for="n in 3" :key="n" class="flow-dot"></div>
            </div>
          </div>
          <el-icon :size="24" class="flow-arrow"><ArrowRight /></el-icon>
        </div>
      </div>
    </div>

    <div class="cta-section">
      <div class="cta-content">
        <h2>开始您的寻物之旅</h2>
        <p>发布失物信息，让智能匹配帮您找到答案</p>
        <div class="cta-buttons">
          <el-button @click="goToPublish" type="primary" size="large">
            <el-icon><Plus /></el-icon>
            发布信息
          </el-button>
          <el-button @click="goToItems" size="large">
            <el-icon><Search /></el-icon>
            浏览物品
          </el-button>
        </div>
      </div>
      <div class="cta-decoration">
        <div class="cta-blob"></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, markRaw } from 'vue'
import { useRouter } from 'vue-router'
import { 
  Search, Star, Grid, Clock, 
  Compass, ArrowRight, Iphone, CreditCard, Notebook, Suitcase, 
  Pear, EditPen, Box, CircleCheck, Check, Bell, User, Trophy
} from '@element-plus/icons-vue'
import { useItemStore } from '../stores/item'
import ItemCard from '../components/ItemCard.vue'
import { siteConfig } from '../config/site'

const router = useRouter()
const itemStore = useItemStore()

const searchKeyword = ref('')
const recentItems = ref([])
const currentPage = ref(1)
const pageSize = ref(9)
const total = ref(0)

const stats = ref({
  found: 0,
  total: 0,
  matched: 0
})

const features = [
  {
    title: '智能匹配',
    description: '基于多维度特征的智能匹配算法，自动为您找到可能相关的失物信息',
    icon: markRaw(CircleCheck),
    iconClass: 'match-icon'
  },
  {
    title: '身份核验',
    description: '支持用户补充真实姓名和身份证号，为证件类物品核验提供保障',
    icon: markRaw(Check),
    iconClass: 'verify-icon'
  },
  {
    title: '实时通知',
    description: '匹配成功时即时通知，不错过任何找回机会',
    icon: markRaw(Bell),
    iconClass: 'notify-icon'
  },
  {
    title: '安全保障',
    description: '严格的身份认证机制，确保物品归还给真正的失主',
    icon: markRaw(User),
    iconClass: 'safety-icon'
  }
]

const categories = ref([
  { value: '电子产品', label: '电子产品', icon: markRaw(Iphone), iconClass: 'cat-electronic', count: 0 },
  { value: '证件', label: '证件', icon: markRaw(CreditCard), iconClass: 'cat-id', count: 0 },
  { value: '书籍', label: '书籍', icon: markRaw(Notebook), iconClass: 'cat-book', count: 0 },
  { value: '衣物', label: '衣物', icon: markRaw(Suitcase), iconClass: 'cat-cloth', count: 0 },
  { value: '饰品', label: '饰品', icon: markRaw(Pear), iconClass: 'cat-jewelry', count: 0 },
  { value: '文具', label: '文具', icon: markRaw(EditPen), iconClass: 'cat-stationery', count: 0 },
  { value: '其他', label: '其他', icon: markRaw(Box), iconClass: 'cat-other', count: 0 }
])

const guideSteps = [
  { number: 1, title: '注册登录', description: '注册账号并完善资料' },
  { number: 2, title: '发布信息', description: '填写详细的物品信息' },
  { number: 3, title: '智能匹配', description: '系统自动匹配相关物品' },
  { number: 4, title: '联系对方', description: '匹配成功后联系对方' }
]

const handleSearch = () => {
  if (searchKeyword.value.trim()) {
    router.push({ path: '/items', query: { keyword: searchKeyword.value } })
  }
}

const handleCategoryClick = (category) => {
  router.push({ path: '/items', query: { category } })
}

const goToItems = () => {
  router.push('/items')
}

const goToPublish = () => {
  router.push('/publish')
}

// 获取最近一周的时间范围
const getRecentWeekRange = () => {
  const endTime = new Date()
  const startTime = new Date()
  startTime.setDate(startTime.getDate() - 7)
  
  // 转换为不带时区的ISO 8601格式（yyyy-MM-ddTHH:mm:ss）
  // 后端LocalDateTime需要这种格式，不能带Z后缀
  const formatDateTime = (date) => {
    const pad = (n) => n.toString().padStart(2, '0')
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
  }
  
  return {
    startTime: formatDateTime(startTime),
    endTime: formatDateTime(endTime)
  }
}

// 加载最新发布物品（最近一周）
const loadRecentItems = async () => {
  try {
    console.log('开始加载最新物品，页码:', currentPage.value, '每页:', pageSize.value)
    
    // 获取最近一周的时间范围
    const timeRange = getRecentWeekRange()
    console.log('时间范围:', timeRange)
    
    const result = await itemStore.fetchItems({
      page: currentPage.value,
      pageSize: pageSize.value,
      startTime: timeRange.startTime,
      endTime: timeRange.endTime
    })
    
    console.log('API返回结果:', JSON.stringify(result))
    
    if (result && result.records) {
      recentItems.value = [...result.records]
      total.value = result.total || 0
      console.log('成功加载', recentItems.value.length, '条物品，总数:', total.value)
    } else {
      recentItems.value = []
      total.value = 0
      console.log('API返回数据格式不正确:', result)
    }
  } catch (error) {
    console.error('加载最新物品失败:', error.message || error)
    recentItems.value = []
    total.value = 0
  }
}

// 分页变化处理
const handlePageChange = (page) => {
  currentPage.value = page
  loadRecentItems()
  // 滚动到最新发布区域
  document.querySelector('.recent-section')?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

onMounted(async () => {
  const [statsResult, categoriesResult] = await Promise.allSettled([
    itemStore.fetchPublicOverview(),
    itemStore.fetchPublicCategories()
  ])

  if (statsResult.status === 'fulfilled') {
    stats.value = {
      found: statsResult.value?.resolved || 0,
      total: statsResult.value?.total || 0,
      matched: statsResult.value?.matched || 0
    }
  }

  // 使用分页加载最新物品
  await loadRecentItems()

  if (categoriesResult.status === 'fulfilled') {
    const categoryData = categoriesResult.value || {}
    categories.value.forEach(cat => {
      cat.count = categoryData[cat.label] || 0
    })
  }
})
</script>

<style scoped>
.home-page {
  min-height: 100vh;
  padding: 0 24px;
  max-width: 1400px;
  margin: 0 auto;
}

.hero-section {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 30%, #a855f7 60%, #c084fc 100%);
  padding: 80px 40px;
  border-radius: 32px;
  margin-bottom: 60px;
  box-shadow: 
    0 25px 50px -12px rgba(99, 102, 241, 0.4),
    0 0 100px rgba(99, 102, 241, 0.15);
  position: relative;
  overflow: hidden;
}

.hero-bg-decoration {
  position: absolute;
  inset: 0;
  overflow: hidden;
  pointer-events: none;
}

.bg-blob {
  position: absolute;
  border-radius: 50%;
  opacity: 0.35;
  filter: blur(80px);
}

.blob-1 {
  width: 500px;
  height: 500px;
  background: rgba(255, 255, 255, 0.25);
  top: -150px;
  right: -100px;
  animation: float 8s ease-in-out infinite;
}

.blob-2 {
  width: 350px;
  height: 350px;
  background: rgba(139, 92, 246, 0.35);
  bottom: -80px;
  left: -80px;
  animation: float 6s ease-in-out infinite;
  animation-delay: -2s;
}

.blob-3 {
  width: 300px;
  height: 300px;
  background: rgba(236, 72, 153, 0.25);
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  animation: float 7s ease-in-out infinite;
  animation-delay: -3s;
}

.blob-4 {
  width: 200px;
  height: 200px;
  background: rgba(59, 130, 246, 0.2);
  bottom: 20%;
  right: 20%;
  animation: float 5s ease-in-out infinite;
  animation-delay: -1s;
}

.bg-grid {
  position: absolute;
  inset: 0;
  background-image: 
    linear-gradient(rgba(255, 255, 255, 0.04) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255, 255, 255, 0.04) 1px, transparent 1px);
  background-size: 40px 40px;
}

.bg-radial {
  position: absolute;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 600px;
  height: 600px;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.08) 0%, transparent 60%);
  pointer-events: none;
}

.hero-content {
  position: relative;
  z-index: 1;
  text-align: center;
}

.hero-badge {
  display: inline-block;
  background: rgba(255, 255, 255, 0.18);
  backdrop-filter: blur(16px);
  padding: 10px 24px;
  border-radius: 24px;
  font-size: 13px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.95);
  margin-bottom: 20px;
  border: 1px solid rgba(255, 255, 255, 0.25);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.hero-title {
  font-size: 60px;
  font-weight: 800;
  color: #fff;
  margin-bottom: 24px;
  letter-spacing: -0.02em;
  text-shadow: 
    0 8px 30px rgba(0, 0, 0, 0.2),
    0 0 60px rgba(255, 255, 255, 0.1);
  background: linear-gradient(135deg, #fff 0%, rgba(255, 255, 255, 0.9) 50%, rgba(255, 255, 255, 0.8) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero-subtitle {
  font-size: 24px;
  color: rgba(255, 255, 255, 0.92);
  margin-bottom: 48px;
  font-weight: 400;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.hero-search {
  max-width: 700px;
  margin: 0 auto;
}

.search-input {
  font-size: 16px;
  border-radius: 16px !important;
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 15px 50px rgba(0, 0, 0, 0.18);
  transition: all 0.3s ease;
}

/* 让输入主体高度为 56px */
.search-input :deep(.el-input__wrapper) {
  height: 56px;
  box-shadow: none;
  border-radius: 16px 0 0 16px;
}

/* append 容器撑满高度 */
.search-input :deep(.el-input-group__append) {
  padding: 0;
  background: transparent;
  border: none;
  border-radius: 0 16px 16px 0;
  overflow: hidden;
  display: flex;
  align-items: stretch;
}

/* 按钮撑满 append */
.search-input :deep(.el-input-group__append .el-button) {
  height: 100%;
  margin: 0;
  border-radius: 0 16px 16px 0;
  padding: 0 36px;
  font-weight: 600;
  font-size: 16px;
  background: linear-gradient(135deg, #ec4899 0%, #f43f5e 100%);
  border: none;
  box-shadow: none;
  color: #fff;
}

.search-input:focus-within {
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.25);
  border-color: rgba(99, 102, 241, 0.4);
}

.search-btn:hover,
.search-input :deep(.el-input-group__append .el-button:hover) {
  background: linear-gradient(135deg, #db2777 0%, #e11d48 100%) !important;
  box-shadow: none !important;
}

.hero-stats {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 24px;
  margin-top: 56px;
  position: relative;
  z-index: 1;
  flex-wrap: wrap;
}

.stat-item {
  background: rgba(255, 255, 255, 0.12);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  padding: 24px 36px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  gap: 18px;
  min-width: 160px;
  transition: all 0.3s ease;
}

.stat-item:hover {
  transform: translateY(-4px);
  background: rgba(255, 255, 255, 0.18);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
}

.stat-icon {
  width: 52px;
  height: 52px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.found-icon {
  background: rgba(34, 197, 94, 0.25);
  color: #22c55e;
}

.total-icon {
  background: rgba(59, 130, 246, 0.25);
  color: #3b82f6;
}

.match-icon {
  background: rgba(251, 191, 36, 0.25);
  color: #fbbf24;
}

.stat-divider {
  width: 1px;
  height: 50px;
  background: rgba(255, 255, 255, 0.2);
  display: none;
}

.stat-content {
  min-width: 100px;
}

@media (min-width: 768px) {
  .stat-divider {
    display: block;
  }
}

.feature-section {
  margin-bottom: 50px;
}

.section-header {
  text-align: center;
  margin-bottom: 40px;
}

.section-title-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  margin-bottom: 10px;
}

.time-badge {
  font-size: 12px;
  padding: 4px 10px;
  background: linear-gradient(135deg, var(--app-primary) 0%, #8b5cf6 100%);
  color: #ffffff;
  border-radius: 20px;
  font-weight: 500;
}

.section-icon {
  color: var(--app-primary);
}

.section-title {
  font-size: 32px;
  font-weight: 700;
  margin: 0;
  background: linear-gradient(135deg, #1e293b 0%, #475569 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.section-desc {
  color: #64748b;
  font-size: 15px;
  margin: 0;
}

.feature-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 28px;
}

.feature-card {
  background: #fff;
  padding: 44px 32px;
  border-radius: 28px;
  text-align: center;
  border: 1px solid rgba(15, 23, 42, 0.06);
  box-shadow: 
    0 4px 20px rgba(15, 23, 42, 0.04),
    0 1px 3px rgba(15, 23, 42, 0.06);
  transition: all 0.45s cubic-bezier(0.4, 0, 0.2, 1);
  animation: fadeInUp 0.6s ease-out forwards;
  opacity: 0;
  position: relative;
  overflow: hidden;
}

.feature-card:hover {
  transform: translateY(-12px) scale(1.02);
  box-shadow: 
    0 25px 50px rgba(15, 23, 42, 0.14),
    0 8px 20px rgba(99, 102, 241, 0.1);
  border-color: rgba(99, 102, 241, 0.25);
}

.feature-icon {
  width: 100px;
  height: 100px;
  border-radius: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 28px;
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
}

.feature-icon::before {
  content: '';
  position: absolute;
  inset: -4px;
  border-radius: 32px;
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.1) 0%, rgba(139, 92, 246, 0.1) 100%);
  opacity: 0;
  transition: opacity 0.35s ease;
}

.feature-card:hover .feature-icon {
  transform: scale(1.12);
}

.feature-card:hover .feature-icon::before {
  opacity: 1;
}

.feature-glow {
  position: absolute;
  bottom: -40px;
  left: 50%;
  transform: translateX(-50%);
  width: 120px;
  height: 120px;
  border-radius: 50%;
  opacity: 0;
  transition: all 0.4s ease;
}

.feature-card:hover .feature-glow {
  opacity: 0.3;
}

.match-icon {
  background: linear-gradient(135deg, #f9f0ff 0%, #ede9fe 100%);
  color: #8b5cf6;
}

.match-icon + .feature-glow {
  background: radial-gradient(circle, #8b5cf6 0%, transparent 70%);
}

.verify-icon {
  background: linear-gradient(135deg, #e0f2fe 0%, #bae6fd 100%);
  color: #0ea5e9;
}

.verify-icon + .feature-glow {
  background: radial-gradient(circle, #0ea5e9 0%, transparent 70%);
}

.notify-icon {
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
  color: #22c55e;
}

.notify-icon + .feature-glow {
  background: radial-gradient(circle, #22c55e 0%, transparent 70%);
}

.safety-icon {
  background: linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%);
  color: #f97316;
}

.safety-icon + .feature-glow {
  background: radial-gradient(circle, #f97316 0%, transparent 70%);
}

.feature-card h3 {
  margin: 0 0 14px 0;
  font-size: 20px;
  font-weight: 600;
  color: #1e293b;
}

.feature-card p {
  margin: 0;
  color: #64748b;
  font-size: 14px;
  line-height: 1.8;
}

.category-section {
  margin-bottom: 50px;
}

.category-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 20px;
}

.category-item {
  background: #fff;
  padding: 28px 16px;
  border-radius: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  border: 1px solid rgba(15, 23, 42, 0.06);
  cursor: pointer;
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.category-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, transparent, var(--app-primary), transparent);
  opacity: 0;
  transition: opacity 0.3s;
}

.category-item:hover::before {
  opacity: 1;
}

.category-item:hover {
  transform: translateY(-6px);
  box-shadow: 0 16px 40px rgba(15, 23, 42, 0.1);
  border-color: rgba(99, 102, 241, 0.2);
}

.category-icon {
  width: 64px;
  height: 64px;
  border-radius: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 14px;
  transition: transform 0.3s ease;
}

.category-item:hover .category-icon {
  transform: scale(1.1);
}

.cat-electronic {
  background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%);
  color: #6366f1;
}

.cat-id {
  background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
  color: #f59e0b;
}

.cat-book {
  background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
  color: #10b981;
}

.cat-cloth {
  background: linear-gradient(135deg, #fce7f3 0%, #fbcfe8 100%);
  color: #ec4899;
}

.cat-jewelry {
  background: linear-gradient(135deg, #ede9fe 0%, #ddd6fe 100%);
  color: #8b5cf6;
}

.cat-stationery {
  background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
  color: #3b82f6;
}

.cat-other {
  background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%);
  color: #64748b;
}

.category-item span {
  font-size: 16px;
  font-weight: 600;
  color: #1e293b;
}

.category-count {
  font-size: 13px;
  color: #94a3b8;
  margin-top: 6px;
}

.category-ripple {
  position: absolute;
  inset: 0;
  background: radial-gradient(circle at center, rgba(99, 102, 241, 0.05) 0%, transparent 70%);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.category-item:hover .category-ripple {
  opacity: 1;
}

.recent-section {
  margin-bottom: 50px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
}

.view-more-btn {
  color: var(--app-primary);
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 8px;
}

.view-more-btn:hover {
  color: var(--app-primary-dark);
  transform: translateX(4px);
}

.recent-items {
  margin-top: 8px;
}

.items-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 24px;
}

.item-card-wrapper {
  animation: fadeInUp 0.5s ease-out forwards;
  opacity: 0;
}

.empty-state {
  text-align: center;
  padding: 80px 20px;
}

.empty-icon {
  color: #cbd5e1;
  margin-bottom: 20px;
}

.empty-state p {
  color: #94a3b8;
  font-size: 15px;
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 32px;
  padding-top: 24px;
}

.pagination-wrapper :deep(.el-pagination) {
  --el-pagination-button-bg-color: #fff;
  --el-pagination-hover-color: var(--app-primary);
}

.guide-section {
  margin-bottom: 50px;
}

.guide-container {
  position: relative;
}

.guide-steps {
  display: flex;
  align-items: stretch;
  justify-content: center;
  gap: 20px;
  flex-wrap: wrap;
  position: relative;
  z-index: 1;
}

.guide-step {
  background: #fff;
  border-radius: 20px;
  padding: 24px 32px;
  display: flex;
  align-items: center;
  gap: 20px;
  border: 1px solid rgba(15, 23, 42, 0.06);
  box-shadow: 0 4px 20px rgba(15, 23, 42, 0.04);
  transition: all 0.3s ease;
  min-width: 200px;
}

.guide-step:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 30px rgba(15, 23, 42, 0.08);
  border-color: rgba(99, 102, 241, 0.15);
}

.step-number {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  color: #fff;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 18px;
  flex-shrink: 0;
  box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3);
}

.step-content h3 {
  margin: 0 0 6px 0;
  font-size: 16px;
  font-weight: 600;
  color: #1e293b;
}

.step-content p {
  margin: 0;
  font-size: 13px;
  color: #64748b;
}

.guide-flow {
  display: none;
}

.cta-section {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  padding: 56px 40px;
  border-radius: 28px;
  margin-bottom: 50px;
  position: relative;
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(99, 102, 241, 0.35);
}

.cta-decoration {
  position: absolute;
  inset: 0;
  overflow: hidden;
  pointer-events: none;
}

.cta-blob {
  position: absolute;
  width: 300px;
  height: 300px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  filter: blur(60px);
  top: -100px;
  right: -100px;
}

.cta-content {
  position: relative;
  z-index: 1;
  text-align: center;
}

.cta-content h2 {
  font-size: 36px;
  font-weight: 700;
  color: #fff;
  margin: 0 0 16px 0;
}

.cta-content p {
  font-size: 18px;
  color: rgba(255, 255, 255, 0.9);
  margin: 0 0 32px 0;
}

.cta-buttons {
  display: flex;
  justify-content: center;
  gap: 16px;
  flex-wrap: wrap;
}

.cta-buttons .el-button {
  padding: 14px 32px;
  font-weight: 600;
  font-size: 15px;
}

/* 发布信息按钮：白底紫字 */
.cta-buttons :deep(.el-button--primary) {
  background: #fff !important;
  color: #6366f1 !important;
  border: none !important;
  box-shadow: 0 8px 25px rgba(255, 255, 255, 0.3);
}

.cta-buttons :deep(.el-button--primary:hover) {
  background: #f0f0ff !important;
  color: #4f46e5 !important;
  transform: translateY(-2px);
  box-shadow: 0 12px 35px rgba(255, 255, 255, 0.4);
}

/* 浏览物品按钮：透明底白字白边框 */
.cta-buttons :deep(.el-button--default) {
  background: rgba(255, 255, 255, 0.15) !important;
  color: #fff !important;
  border: 1.5px solid rgba(255, 255, 255, 0.6) !important;
}

.cta-buttons :deep(.el-button--default:hover) {
  background: rgba(255, 255, 255, 0.28) !important;
  color: #fff !important;
  border-color: rgba(255, 255, 255, 0.85) !important;
}

@media (max-width: 768px) {
  .hero-section {
    padding: 50px 20px;
    border-radius: 20px;
  }

  .hero-title {
    font-size: 40px;
  }

  .hero-subtitle {
    font-size: 18px;
  }

  .hero-stats {
    gap: 16px;
    margin-top: 40px;
  }

  .stat-item {
    min-width: 130px;
    padding: 20px 24px;
  }

  .feature-card {
    padding: 32px 20px;
  }

  .feature-icon {
    width: 80px;
    height: 80px;
  }

  .guide-steps {
    flex-direction: column;
  }

  .guide-step {
    min-width: auto;
  }

  .section-title {
    font-size: 26px;
  }

  .cta-content h2 {
    font-size: 28px;
  }

  .cta-content p {
    font-size: 16px;
  }
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes float {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-20px);
  }
}
</style>
