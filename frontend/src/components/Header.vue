<template>
  <el-header class="header">
    <div class="header-content">
      <div class="logo" @click="goHome">
        <div class="logo-icon">
          <el-icon :size="24"><Cherry /></el-icon>
        </div>
        <div class="logo-texts">
          <span class="logo-text">校园失物招领</span>
          <span class="logo-subtitle">Lost & Found</span>
        </div>
      </div>

      <el-menu :default-active="activeMenu" mode="horizontal" class="nav-menu" router>
        <el-menu-item index="/">
          <el-icon :size="18"><House /></el-icon>
          <span>首页</span>
        </el-menu-item>
        <el-menu-item index="/items">
          <el-icon :size="18"><Tickets /></el-icon>
          <span>物品列表</span>
        </el-menu-item>
        <el-menu-item index="/publish">
          <el-icon :size="18"><Plus /></el-icon>
          <span>发布信息</span>
        </el-menu-item>
      </el-menu>

      <div class="header-right">
        <div class="search-box">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索物品..."
            class="search-input"
            @keyup.enter="handleSearch"
          >
            <template #prepend>
              <el-icon :size="16"><Search /></el-icon>
            </template>
            <template #append>
              <el-button @click="handleSearch" type="primary" size="small" class="search-btn">
                <el-icon :size="14"><Search /></el-icon>
              </el-button>
            </template>
          </el-input>
        </div>

        <div class="user-actions">
          <el-button
            v-if="!userStore.user"
            @click="showLogin = true"
            type="primary"
            size="small"
            class="login-btn"
          >
            登录
          </el-button>
          <el-button
            v-if="!userStore.user"
            @click="showRegister = true"
            size="small"
            class="register-btn"
          >
            注册
          </el-button>

          <el-dropdown v-else class="user-dropdown">
            <span class="user-info">
              <div class="user-avatar">
                <el-icon :size="20"><User /></el-icon>
              </div>
              <span class="user-name">{{ userStore.user.username }}</span>
              <el-icon :size="14" class="arrow-icon"><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="goProfile">
                  <el-icon><User /></el-icon>
                  个人中心
                </el-dropdown-item>
                <el-dropdown-item @click="goMyItems">
                  <el-icon><Box /></el-icon>
                  我的物品
                </el-dropdown-item>
                <el-dropdown-item @click="goMatches">
                  <el-icon><Ticket /></el-icon>
                  匹配列表
                </el-dropdown-item>
                <el-dropdown-item v-if="isAdmin" @click="goAdmin">
                  <el-icon><Setting /></el-icon>
                  管理后台
                </el-dropdown-item>
                <el-dropdown-item divided @click="handleLogout">
                  <el-icon><Back /></el-icon>
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>

        <div class="notification-bell" v-if="userStore.user" @click="openNotifications">
          <el-badge :value="notificationStore.unreadCount" :hidden="notificationStore.unreadCount === 0" class="notification-badge">
            <div class="bell-btn">
              <el-icon :size="18"><Bell /></el-icon>
            </div>
          </el-badge>
        </div>
      </div>
    </div>

    <LoginModal
      v-if="showLogin"
      @close="showLogin = false"
      @success="handleLoginSuccess"
      @open-register="openRegister"
    />
    <RegisterModal
      v-if="showRegister"
      @close="showRegister = false"
      @open-login="openLogin"
    />
    <NotificationModal v-model="showNotifications" />
  </el-header>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { User, ArrowDown, House, Tickets, Plus, Bell, Cherry, Search, Box, Ticket, Setting, Back } from '@element-plus/icons-vue'
import { useUserStore } from '../stores/user'
import { useNotificationStore } from '../stores/notification'
import LoginModal from './LoginModal.vue'
import RegisterModal from './RegisterModal.vue'
import NotificationModal from './NotificationModal.vue'
import { showWarning } from '../utils/message'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const notificationStore = useNotificationStore()
const searchKeyword = ref('')
const showLogin = ref(false)
const showRegister = ref(false)
const showNotifications = ref(false)

const activeMenu = computed(() => router.currentRoute.value.path)
const isAdmin = computed(() => userStore.isAdmin)

const goHome = () => {
  router.push('/')
}

const handleSearch = () => {
  if (searchKeyword.value.trim()) {
    router.push({ path: '/items', query: { keyword: searchKeyword.value } })
  }
}

const goProfile = () => {
  router.push('/profile')
}

const goMyItems = () => {
  router.push('/my-items')
}

const goMatches = () => {
  router.push('/matches')
}

const goAdmin = () => {
  router.push('/admin')
}

const handleLogout = async () => {
  await userStore.logout()
  router.push('/')
}

const openRegister = () => {
  showLogin.value = false
  showRegister.value = true
}

const openLogin = () => {
  showRegister.value = false
  showLogin.value = true
}

const openNotifications = () => {
  showNotifications.value = true
}

const handleLoginSuccess = async () => {
  await notificationStore.fetchNotifications()
  const redirect = route.query.redirect
  if (typeof redirect === 'string' && redirect) {
    await router.push(redirect)
  }
}

onMounted(async () => {
  if (userStore.user) {
    await notificationStore.fetchNotifications()
  }
})

watch(
  () => route.query,
  async (query) => {
    if (query?.toast === 'need_login') {
      showWarning('请先登录后再发布信息')
      showLogin.value = true
      const { toast, login, ...rest } = query
      await router.replace({ path: route.path, query: rest })
      return
    }
    if (query?.toast === 'need_admin') {
      showWarning('需要管理员权限')
      const { toast, ...rest } = query
      await router.replace({ path: route.path, query: rest })
    }
  },
  { immediate: true }
)
</script>

<style scoped>
.header {
  position: sticky;
  top: 0;
  z-index: 10;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(15, 23, 42, 0.06);
  padding: 0 24px;
  line-height: 68px;
  transition: all 0.3s ease;
}

.header.scrolled {
  box-shadow: 0 4px 20px rgba(15, 23, 42, 0.08);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: var(--app-max-width);
  margin: 0 auto;
}

.logo {
  display: flex;
  align-items: center;
  cursor: pointer;
  gap: 12px;
  color: var(--app-text);
  transition: transform 0.2s ease;
}

.logo:hover {
  transform: scale(1.02);
}

.logo-icon {
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3);
}

.logo-texts {
  display: flex;
  flex-direction: column;
  line-height: 1.1;
}

.logo-text {
  font-size: 17px;
  font-weight: 800;
  letter-spacing: 0.3px;
  background: linear-gradient(135deg, #1e293b 0%, #475569 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.logo-subtitle {
  font-size: 11px;
  color: var(--app-muted);
  letter-spacing: 0.5px;
}

.nav-menu {
  flex: 1;
  margin-left: 32px;
  background: transparent;
}

.nav-menu .el-menu-item {
  margin: 0 8px;
  padding: 0 20px;
  font-size: 14px;
  font-weight: 500;
  color: #475569;
  border-radius: 10px;
  transition: all 0.25s ease;
}

.nav-menu .el-menu-item:hover {
  background: rgba(99, 102, 241, 0.08);
  color: var(--app-primary);
}

.nav-menu .el-menu-item.is-active {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.1) 0%, rgba(139, 92, 246, 0.1) 100%);
  color: var(--app-primary);
}

.header-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.search-box {
  width: 280px;
  transition: all 0.3s ease;
}

.search-input {
  width: 100%;
  height: 40px;
  border-radius: 10px;
  background: rgba(15, 23, 42, 0.04);
  border: 1px solid rgba(15, 23, 42, 0.08);
  transition: all 0.25s ease;
}

.search-input:focus {
  background: #fff;
  border-color: rgba(99, 102, 241, 0.3);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.08);
}

.search-btn {
  background: var(--app-primary);
  border-radius: 0 10px 10px 0;
  padding: 0 16px;
}

.search-btn:hover {
  background: var(--app-primary-dark);
}

.user-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.login-btn {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  border: none;
  padding: 0 20px;
  font-weight: 500;
  border-radius: 10px;
  box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3);
}

.login-btn:hover {
  background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
  transform: translateY(-1px);
}

.register-btn {
  border: 1px solid rgba(99, 102, 241, 0.3);
  color: var(--app-primary);
  padding: 0 20px;
  font-weight: 500;
  border-radius: 10px;
}

.register-btn:hover {
  background: rgba(99, 102, 241, 0.08);
  border-color: var(--app-primary);
}

.user-info {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  padding: 6px 14px;
  border-radius: 14px;
  border: 1px solid transparent;
  transition: all 0.25s ease;
}

.user-info:hover {
  background: rgba(99, 102, 241, 0.06);
  border-color: rgba(99, 102, 241, 0.18);
}

.user-avatar {
  width: 34px;
  height: 34px;
  background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--app-primary);
}

.user-name {
  font-size: 14px;
  font-weight: 500;
  color: #1e293b;
}

.arrow-icon {
  color: #94a3b8;
  transition: transform 0.25s ease;
}

.user-info:hover .arrow-icon {
  transform: rotate(180deg);
}

.notification-bell {
  margin-left: 4px;
  cursor: pointer;
}

.notification-badge {
  --el-badge-bg-color: #ef4444;
  cursor: pointer;
}

.notification-badge :deep(.el-badge__content) {
  pointer-events: none;
}

.bell-btn {
  width: 38px;
  height: 38px;
  border-radius: 11px;
  background: rgba(15, 23, 42, 0.04);
  border: 1px solid rgba(15, 23, 42, 0.08);
  transition: all 0.25s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: var(--app-text);
}

.bell-btn:hover {
  background: rgba(99, 102, 241, 0.08);
  border-color: rgba(99, 102, 241, 0.2);
}

@media (max-width: 900px) {
  .search-box {
    display: none;
  }

  .nav-menu {
    margin-left: 16px;
  }

  .nav-menu .el-menu-item {
    padding: 0 14px;
  }
}

@media (max-width: 600px) {
  .header {
    padding: 0 16px;
    line-height: 60px;
  }

  .logo-text {
    font-size: 15px;
  }

  .logo-subtitle {
    display: none;
  }

  .nav-menu {
    display: none;
  }

  .user-info {
    padding: 4px 10px;
  }

  .user-name {
    display: none;
  }
}
</style>
