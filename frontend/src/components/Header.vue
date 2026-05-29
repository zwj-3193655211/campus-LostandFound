<template>
  <el-header class="header">
    <div class="header-content">
      <div class="logo" @click="goHome">
        <img class="logo-mark" src="/logo.svg" alt="校园失物招领平台" />
        <div class="logo-texts">
          <span class="logo-text">校园失物招领</span>
          <span class="logo-subtitle">Lost & Found</span>
        </div>
      </div>

      <el-menu :default-active="activeMenu" mode="horizontal" class="nav-menu" router>
        <el-menu-item index="/">
          <el-icon><House /></el-icon>
          <span>首页</span>
        </el-menu-item>
        <el-menu-item index="/items">
          <el-icon><Tickets /></el-icon>
          <span>物品列表</span>
        </el-menu-item>
        <el-menu-item index="/publish">
          <el-icon><Plus /></el-icon>
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
            <template #append>
              <el-button @click="handleSearch" type="primary" size="small">
                <el-icon><Search /></el-icon>
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
          >
            登录
          </el-button>
          <el-button
            v-if="!userStore.user"
            @click="showRegister = true"
            size="small"
          >
            注册
          </el-button>

          <el-dropdown v-else class="user-dropdown">
            <span class="user-info">
              <el-icon class="user-icon"><User /></el-icon>
              <span>{{ userStore.user.username }}</span>
              <el-icon class="arrow-icon"><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="goProfile">个人中心</el-dropdown-item>
                <el-dropdown-item @click="goMyItems">我的物品</el-dropdown-item>
                <el-dropdown-item @click="goMatches">匹配列表</el-dropdown-item>
                <el-dropdown-item v-if="isAdmin" @click="goAdmin">管理后台</el-dropdown-item>
                <el-dropdown-item divided @click="handleLogout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>

        <div class="notification-bell" v-if="userStore.user">
          <el-badge :value="notificationStore.unreadCount" :hidden="notificationStore.unreadCount === 0">
            <el-button @click="showNotifications = true" size="small" circle>
              <el-icon><Bell /></el-icon>
            </el-button>
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
    <NotificationModal v-if="showNotifications" @close="showNotifications = false" />
  </el-header>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { User, ArrowDown, House, Tickets, Plus, Bell } from '@element-plus/icons-vue'
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
    if (query?.login === '1') {
      showLogin.value = true
      const { login, ...rest } = query
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
  z-index: 50;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(14px);
  border-bottom: 1px solid var(--app-border);
  padding: 0 20px;
  line-height: 64px;
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
  gap: 10px;
  color: var(--app-text);
}

.logo-mark {
  width: 34px;
  height: 34px;
  border-radius: 10px;
  box-shadow: 0 10px 20px rgba(15, 23, 42, 0.12);
}

.logo-texts {
  display: flex;
  flex-direction: column;
  line-height: 1.1;
}

.logo-text {
  font-size: 16px;
  font-weight: 800;
  letter-spacing: 0.2px;
}

.logo-subtitle {
  font-size: 12px;
  color: var(--app-muted);
}

.nav-menu {
  flex: 1;
  margin-left: 24px;
  background: transparent;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.search-box {
  width: 320px;
}

.search-input {
  width: 100%;
}

.user-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 4px 12px;
  border-radius: 12px;
  border: 1px solid transparent;
  transition: all 0.2s ease;
}

.user-info:hover {
  background: rgba(79, 70, 229, 0.06);
  border-color: rgba(79, 70, 229, 0.18);
}

.user-icon {
  font-size: 18px;
}

.arrow-icon {
  font-size: 12px;
}

.notification-bell {
  margin-left: 8px;
}
</style>
