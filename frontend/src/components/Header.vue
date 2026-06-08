<template>
  <el-header class="header" :class="{ 'header-scrolled': isScrolled }">
    <div class="header-content">
      <div class="logo" @click="goHome">
        <div class="logo-icon">
          <el-icon :size="26"><Cherry /></el-icon>
        </div>
        <div class="logo-texts">
          <span class="logo-text">校园失物招领</span>
          <span class="logo-subtitle">Lost & Found</span>
        </div>
        <div class="logo-glow"></div>
      </div>

      <el-menu :default-active="activeMenu" mode="horizontal" class="nav-menu" router>
        <el-menu-item index="/">
          <el-icon :size="18"><House /></el-icon>
          <span>首页</span>
          <div class="menu-item-glow"></div>
        </el-menu-item>
        <el-menu-item index="/items">
          <el-icon :size="18"><Tickets /></el-icon>
          <span>物品列表</span>
          <div class="menu-item-glow"></div>
        </el-menu-item>
      </el-menu>
      
      <el-button 
        class="publish-btn" 
        @click="handlePublishClick"
        type="primary"
        size="small"
      >
        <el-icon :size="16"><Plus /></el-icon>
        <span>发布信息</span>
      </el-button>

      <div class="header-right">
        <div class="search-box">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索物品名称、描述..."
            class="search-input"
            @keyup.enter="handleSearch"
          />
          <el-button @click="handleSearch" class="search-btn">
            <el-icon :size="16"><Search /></el-icon>
          </el-button>
        </div>

        <div class="user-actions">
          <el-button
            v-if="!userStore.user"
            @click="showLogin = true"
            type="primary"
            size="small"
            class="login-btn"
          >
            <el-icon :size="14"><User /></el-icon>
            登录
          </el-button>
          <el-button
            v-if="!userStore.user"
            @click="showRegister = true"
            size="small"
            class="register-btn"
          >
            <el-icon :size="14"><Plus /></el-icon>
            注册
          </el-button>

          <el-dropdown v-else class="user-dropdown">
            <span class="user-info">
              <div class="user-avatar">
                <el-icon :size="20"><User /></el-icon>
                <div class="avatar-ring"></div>
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
              <div class="bell-pulse" v-if="notificationStore.unreadCount > 0"></div>
            </div>
          </el-badge>
        </div>
      </div>
    </div>

    <div class="header-bottom-line"></div>

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
import { computed, ref, onMounted, onUnmounted, watch } from 'vue'
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
const isScrolled = ref(false)

const activeMenu = computed(() => router.currentRoute.value.path)
const isAdmin = computed(() => userStore.isAdmin)

const handleScroll = () => {
  isScrolled.value = window.scrollY > 20
}

const goHome = () => {
  router.push('/')
}

const handlePublishClick = () => {
  if (!userStore.user) {
    showLogin.value = true
  } else {
    router.push('/publish')
  }
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
  try {
    await notificationStore.fetchNotifications()
    const redirect = route.query.redirect
    if (typeof redirect === 'string' && redirect) {
      await router.push(redirect)
    }
  } catch (e) {
    console.error('[Header] 登录后操作失败:', e)
  }
}

onMounted(async () => {
  if (userStore.user) {
    await notificationStore.fetchNotifications()
  }
  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
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
  z-index: 100;
  background: rgba(255, 255, 255, 0.92);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border-bottom: 1px solid rgba(15, 23, 42, 0.04);
  padding: 0 24px;
  line-height: 70px;
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
}

.header-scrolled {
  background: rgba(255, 255, 255, 0.98);
  box-shadow: 0 4px 30px rgba(15, 23, 42, 0.08);
  border-bottom: 1px solid rgba(99, 102, 241, 0.08);
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
  gap: 14px;
  color: var(--app-text);
  transition: transform 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
}

.logo:hover {
  transform: scale(1.02);
}

.logo-icon {
  width: 44px;
  height: 44px;
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #a855f7 100%);
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  box-shadow: 0 6px 20px rgba(99, 102, 241, 0.35);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.logo-icon::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.15), transparent);
  transform: rotate(45deg);
  transition: all 0.6s ease;
}

.logo:hover .logo-icon::before {
  left: 100%;
}

.logo-icon:hover {
  box-shadow: 0 8px 30px rgba(99, 102, 241, 0.5), 0 0 40px rgba(99, 102, 241, 0.2);
  transform: scale(1.08);
}

.logo-glow {
  position: absolute;
  top: 50%;
  left: 20px;
  transform: translateY(-50%);
  width: 80px;
  height: 80px;
  background: radial-gradient(circle, rgba(99, 102, 241, 0.2) 0%, rgba(139, 92, 246, 0.1) 40%, transparent 70%);
  opacity: 0;
  transition: opacity 0.4s ease;
}

.logo:hover .logo-glow {
  opacity: 1;
}

.logo-texts {
  display: flex;
  flex-direction: column;
  line-height: 1.1;
}

.logo-text {
  font-size: 18px;
  font-weight: 800;
  letter-spacing: 0.4px;
  background: linear-gradient(135deg, #0f172a 0%, #475569 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  transition: all 0.3s ease;
}

.logo:hover .logo-text {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.logo-subtitle {
  font-size: 11px;
  color: var(--app-muted);
  letter-spacing: 0.6px;
  transition: color 0.3s ease;
}

.logo:hover .logo-subtitle {
  color: var(--app-primary);
}

.nav-menu {
  flex: 1;
  margin-left: 40px;
  background: transparent;
}

.publish-btn {
  margin-left: 16px;
  margin-right: 24px;
  height: 36px;
  padding: 0 20px;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 500;
  background: linear-gradient(135deg, var(--app-primary) 0%, #8b5cf6 100%);
  border: none;
  box-shadow: 0 4px 15px rgba(99, 102, 241, 0.35);
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
}

.publish-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(99, 102, 241, 0.45);
}

.publish-btn:active {
  transform: translateY(0);
}

.nav-menu .el-menu-item {
  margin: 0 6px;
  padding: 0 22px;
  font-size: 14px;
  font-weight: 500;
  color: #475569;
  border-radius: 12px;
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.nav-menu .el-menu-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.05) 0%, rgba(139, 92, 246, 0.05) 100%);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.nav-menu .el-menu-item:hover {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.1) 0%, rgba(139, 92, 246, 0.1) 100%);
  color: var(--app-primary);
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(99, 102, 241, 0.12);
}

.nav-menu .el-menu-item.is-active {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.15) 0%, rgba(139, 92, 246, 0.15) 100%);
  color: var(--app-primary);
  box-shadow: 0 6px 20px rgba(99, 102, 241, 0.2);
}

.nav-menu .el-menu-item.is-active::after {
  content: '';
  position: absolute;
  bottom: 10px;
  left: 50%;
  transform: translateX(-50%);
  width: 20px;
  height: 3px;
  background: linear-gradient(90deg, var(--app-primary) 0%, #8b5cf6 100%);
  border-radius: 2px;
}

.nav-menu .el-menu-item i {
  transition: transform 0.3s ease;
}

.nav-menu .el-menu-item:hover i {
  transform: scale(1.1);
}

.header-right {
  display: flex;
  align-items: center;
  gap: 22px;
}

.search-box {
  width: 360px;
  height: 48px;
  display: flex;
  align-items: center;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 24px;
  border: 1px solid rgba(15, 23, 42, 0.08);
  box-shadow: 0 2px 12px rgba(15, 23, 42, 0.06);
  overflow: hidden;
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
}

.search-box:hover {
  border-color: rgba(99, 102, 241, 0.2);
  box-shadow: 0 4px 20px rgba(15, 23, 42, 0.1);
}

.search-box:focus-within {
  border-color: rgba(99, 102, 241, 0.4);
  box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.08), 0 6px 24px rgba(99, 102, 241, 0.15);
}

.search-input {
  flex: 1;
  height: 100%;
  background: transparent !important;
  border: none !important;
  outline: none !important;
  padding: 0 20px !important;
  font-size: 14px;
  color: #1e293b;
  box-shadow: none !important;
}

.search-box :deep(.el-input) {
  background: transparent !important;
  border: none !important;
  box-shadow: none !important;
}

.search-box :deep(.el-input__wrapper) {
  background: transparent !important;
  border: none !important;
  box-shadow: none !important;
}

.search-box :deep(.el-input__inner) {
  background: transparent !important;
  border: none !important;
  box-shadow: none !important;
}

.search-input::placeholder {
  color: #94a3b8;
  font-weight: 400;
}

.search-btn {
  width: 48px;
  height: 100%;
  background: linear-gradient(135deg, var(--app-primary) 0%, #8b5cf6 100%);
  border: none;
  border-radius: 0 24px 24px 0;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  cursor: pointer;
  transition: all 0.3s ease;
}

.search-btn:hover {
  background: linear-gradient(135deg, var(--app-primary-dark) 0%, #7c3aed 100%);
  transform: scale(1.02);
}

.search-btn:active {
  transform: scale(0.98);
}

.search-btn:active {
  transform: translateY(0);
}

.user-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.login-btn {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  border: none;
  padding: 0 24px;
  font-weight: 600;
  border-radius: 12px;
  box-shadow: 0 4px 18px rgba(99, 102, 241, 0.35);
  display: flex;
  align-items: center;
  gap: 6px;
}

.login-btn:hover {
  background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
  transform: translateY(-2px);
  box-shadow: 0 6px 25px rgba(99, 102, 241, 0.45);
}

.register-btn {
  border: 1.5px solid rgba(99, 102, 241, 0.25);
  color: var(--app-primary);
  padding: 0 24px;
  font-weight: 600;
  border-radius: 12px;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: all 0.28s cubic-bezier(0.4, 0, 0.2, 1);
}

.register-btn:hover {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.06) 0%, rgba(139, 92, 246, 0.06) 100%);
  border-color: var(--app-primary);
  transform: translateY(-1px);
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  padding: 8px 16px;
  border-radius: 16px;
  border: 1px solid transparent;
  transition: all 0.28s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
}

.user-info:hover {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.06) 0%, rgba(139, 92, 246, 0.06) 100%);
  border-color: rgba(99, 102, 241, 0.18);
}

.user-avatar {
  width: 38px;
  height: 38px;
  background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--app-primary);
  position: relative;
}

.avatar-ring {
  position: absolute;
  inset: -2px;
  border-radius: 14px;
  border: 2px solid transparent;
  background: linear-gradient(135deg, var(--app-primary) 0%, #8b5cf6 100%) border-box;
  -webkit-mask: linear-gradient(#fff 0 0) padding-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.user-info:hover .avatar-ring {
  opacity: 1;
}

.user-name {
  font-size: 14px;
  font-weight: 600;
  color: #1e293b;
}

.arrow-icon {
  color: #94a3b8;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.user-info:hover .arrow-icon {
  color: var(--app-primary);
  transform: rotate(180deg);
}

.notification-bell {
  margin-left: 6px;
  cursor: pointer;
}

.notification-badge {
  --el-badge-bg-color: #ef4444;
  --el-badge-font-size: 11px;
  cursor: pointer;
}

.notification-badge :deep(.el-badge__content) {
  pointer-events: none;
  animation: badgePulse 2s ease-in-out infinite;
}

@keyframes badgePulse {
  0%, 100% {
    box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.4);
  }
  50% {
    box-shadow: 0 0 0 6px rgba(239, 68, 68, 0);
  }
}

.bell-btn {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  background: rgba(15, 23, 42, 0.03);
  border: 1px solid rgba(15, 23, 42, 0.06);
  transition: all 0.28s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: var(--app-text);
  position: relative;
}

.bell-btn:hover {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.08) 0%, rgba(139, 92, 246, 0.08) 100%);
  border-color: rgba(99, 102, 241, 0.2);
  transform: translateY(-2px);
}

.bell-pulse {
  position: absolute;
  inset: -4px;
  border-radius: 16px;
  background: rgba(239, 68, 68, 0.3);
  animation: bellRing 1.5s ease-out infinite;
}

@keyframes bellRing {
  0% {
    transform: scale(1);
    opacity: 0.8;
  }
  100% {
    transform: scale(1.5);
    opacity: 0;
  }
}

.header-bottom-line {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, transparent, rgba(99, 102, 241, 0.15), transparent);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.header-scrolled .header-bottom-line {
  opacity: 1;
}

@media (max-width: 900px) {
  .search-box {
    display: none;
  }

  .nav-menu {
    margin-left: 20px;
  }

  .nav-menu .el-menu-item {
    padding: 0 16px;
  }
}

@media (max-width: 600px) {
  .header {
    padding: 0 16px;
    line-height: 64px;
  }

  .logo-text {
    font-size: 16px;
  }

  .logo-subtitle {
    display: none;
  }

  .nav-menu {
    display: none;
  }

  .user-info {
    padding: 6px 12px;
  }

  .user-name {
    display: none;
  }

  .user-avatar {
    width: 34px;
    height: 34px;
  }
}
</style>
