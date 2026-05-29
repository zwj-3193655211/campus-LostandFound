<template>
  <div class="home-page">
    <div class="hero-section">
      <div class="hero-content">
        <h1 class="hero-title">{{ siteConfig.name }}</h1>
        <p class="hero-subtitle">{{ siteConfig.slogan }}</p>
        <div class="hero-search">
          <el-input 
            v-model="searchKeyword" 
            placeholder="搜索物品名称、描述..." 
            class="search-input"
            @keyup.enter="handleSearch"
          >
            <template #append>
              <el-button @click="handleSearch" type="primary" size="large">
                <el-icon><Search /></el-icon>
                搜索
              </el-button>
            </template>
          </el-input>
        </div>
      </div>
      <div class="hero-stats">
        <div class="stat-item">
          <el-statistic title="已帮助找回" :value="stats.found" />
        </div>
        <div class="stat-item">
          <el-statistic title="物品总数" :value="stats.total" />
        </div>
        <div class="stat-item">
          <el-statistic title="匹配成功" :value="stats.matched" />
        </div>
      </div>
    </div>

    <div class="feature-section">
      <h2 class="section-title">平台特色</h2>
      <div class="feature-cards">
        <el-card class="feature-card">
          <div class="feature-icon match-icon">
            <el-icon :size="40"><CircleCheck /></el-icon>
          </div>
          <h3>智能匹配</h3>
          <p>基于多维度特征的智能匹配算法，自动为您找到可能相关的失物信息</p>
        </el-card>
        <el-card class="feature-card">
          <div class="feature-icon verify-icon">
            <el-icon :size="40"><Check /></el-icon>
          </div>
          <h3>身份核验</h3>
          <p>支持用户补充真实姓名和身份证号，为证件类物品核验与扩展匹配预留能力</p>
        </el-card>
        <el-card class="feature-card">
          <div class="feature-icon notify-icon">
            <el-icon :size="40"><Bell /></el-icon>
          </div>
          <h3>实时通知</h3>
          <p>匹配成功时即时通知，不错过任何找回机会</p>
        </el-card>
      </div>
    </div>

    <div class="category-section">
      <h2 class="section-title">物品分类</h2>
      <div class="category-grid">
        <div 
          v-for="cat in categories" 
          :key="cat.value" 
          class="category-item"
          @click="handleCategoryClick(cat.value)"
        >
          <div class="category-icon">
            <el-icon :size="28"><component :is="cat.icon" /></el-icon>
          </div>
          <span>{{ cat.label }}</span>
        </div>
      </div>
    </div>

    <div class="recent-section">
      <div class="section-header">
        <h2 class="section-title">最新发布</h2>
        <el-button @click="goToItems" type="text">查看更多</el-button>
      </div>
      <div class="recent-items">
        <el-row :gutter="20">
          <el-col v-for="item in recentItems" :key="item.id" :span="8">
            <ItemCard :item="item" />
          </el-col>
        </el-row>
      </div>
    </div>

    <div class="guide-section">
      <h2 class="section-title">使用指南</h2>
      <div class="guide-steps">
        <div class="guide-step">
          <div class="step-number">1</div>
          <div class="step-content">
            <h3>注册登录</h3>
            <p>注册账号并完善资料，可按需进行实名认证</p>
          </div>
        </div>
        <div class="guide-arrow">
          <el-icon :size="24"><ArrowRight /></el-icon>
        </div>
        <div class="guide-step">
          <div class="step-number">2</div>
          <div class="step-content">
            <h3>发布信息</h3>
            <p>填写详细的物品信息和联系方式</p>
          </div>
        </div>
        <div class="guide-arrow">
          <el-icon :size="24"><ArrowRight /></el-icon>
        </div>
        <div class="guide-step">
          <div class="step-number">3</div>
          <div class="step-content">
            <h3>智能匹配</h3>
            <p>系统自动匹配相关物品信息</p>
          </div>
        </div>
        <div class="guide-arrow">
          <el-icon :size="24"><ArrowRight /></el-icon>
        </div>
        <div class="guide-step">
          <div class="step-number">4</div>
          <div class="step-content">
            <h3>联系认领</h3>
            <p>通过平台联系对方完成认领</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Search, CircleCheck, Check, Bell, ArrowRight, Iphone, CreditCard, Notebook, Suitcase, Pear, EditPen, Box } from '@element-plus/icons-vue'
import { useItemStore } from '../stores/item'
import ItemCard from '../components/ItemCard.vue'
import { siteConfig } from '../config/site'

const router = useRouter()
const itemStore = useItemStore()

const searchKeyword = ref('')
const recentItems = ref([])

const stats = ref({
  found: 0,
  total: 0,
  matched: 0
})

const categories = [
  { value: '电子产品', label: '电子产品', icon: Iphone },
  { value: '证件', label: '证件', icon: CreditCard },
  { value: '书籍', label: '书籍', icon: Notebook },
  { value: '衣物', label: '衣物', icon: Suitcase },
  { value: '饰品', label: '饰品', icon: Pear },
  { value: '文具', label: '文具', icon: EditPen },
  { value: '其他', label: '其他', icon: Box }
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

onMounted(async () => {
  const [statsResult, itemsResult] = await Promise.allSettled([
    itemStore.fetchPublicOverview(),
    itemStore.fetchItems({ size: 3 })
  ])

  if (statsResult.status === 'fulfilled') {
    stats.value = {
      found: statsResult.value?.found || 0,
      total: statsResult.value?.total || 0,
      matched: statsResult.value?.matched || 0
    }
  }

  if (itemsResult.status === 'fulfilled') {
    recentItems.value = itemsResult.value?.records || []
  }
})
</script>

<style scoped>
.home-page {
  min-height: 100vh;
}

.hero-section {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 64px 40px;
  text-align: center;
  color: #fff;
  border-radius: var(--app-radius);
  box-shadow: var(--app-shadow);
}

.hero-title {
  font-size: 48px;
  margin-bottom: 16px;
}

.hero-subtitle {
  font-size: 20px;
  margin-bottom: 32px;
  opacity: 0.9;
}

.hero-search {
  max-width: 600px;
  margin: 0 auto;
}

.search-input {
  height: 48px;
  font-size: 16px;
}

.hero-stats {
  display: flex;
  justify-content: center;
  gap: 56px;
  margin-top: 40px;
  flex-wrap: wrap;
}

.stat-item {
  background: rgba(255, 255, 255, 0.16);
  border: 1px solid rgba(255, 255, 255, 0.24);
  padding: 18px 26px;
  border-radius: 16px;
  backdrop-filter: blur(10px);
}

.section-title {
  font-size: 24px;
  text-align: center;
  margin-bottom: 24px;
}

.feature-section {
  padding: 44px 10px 18px;
}

.feature-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.feature-card {
  text-align: center;
  padding: 24px;
  border-radius: var(--app-radius);
  border: 1px solid var(--app-border);
}

.feature-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px;
}

.match-icon {
  background: #f9f0ff;
  color: #722ed1;
}

.verify-icon {
  background: #e6f7ff;
  color: #1890ff;
}

.notify-icon {
  background: #f6ffed;
  color: #52c41a;
}

.feature-card h3 {
  margin-bottom: 8px;
}

.feature-card p {
  color: #606266;
  line-height: 1.6;
}

.category-section {
  padding: 34px 10px;
}

.category-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 14px;
}

.category-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  background: var(--app-surface);
  border-radius: var(--app-radius);
  border: 1px solid var(--app-border);
  cursor: pointer;
  transition: all 0.3s;
}

.category-item:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.category-icon {
  font-size: 32px;
  margin-bottom: 8px;
}

.category-item span {
  font-size: 14px;
}

.recent-section {
  padding: 34px 10px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.recent-items {
  margin-top: 20px;
}

.guide-section {
  padding: 34px 10px;
}

.guide-steps {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
}

.guide-step {
  display: flex;
  align-items: center;
  gap: 12px;
  background: var(--app-surface);
  border: 1px solid var(--app-border);
  padding: 16px 24px;
  border-radius: var(--app-radius);
}

.step-number {
  width: 36px;
  height: 36px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.step-content h3 {
  margin: 0 0 4px 0;
  font-size: 14px;
}

.step-content p {
  margin: 0;
  font-size: 12px;
  color: #606266;
}

.guide-arrow {
  color: #ccc;
}
</style>
