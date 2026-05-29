import { createRouter, createWebHistory } from 'vue-router'

const Home = () => import('../views/Home.vue')
const ItemList = () => import('../views/ItemList.vue')
const ItemDetail = () => import('../views/ItemDetail.vue')
const PublishItem = () => import('../views/PublishItem.vue')
const MyItems = () => import('../views/MyItems.vue')
const Profile = () => import('../views/Profile.vue')
const MatchList = () => import('../views/MatchList.vue')
const AdminDashboard = () => import('../views/AdminDashboard.vue')
const AdminUsers = () => import('../views/AdminUsers.vue')
const AdminIdentityVerifications = () => import('../views/AdminIdentityVerifications.vue')
const AdminLocations = () => import('../views/AdminLocations.vue')
const AdminStatistics = () => import('../views/AdminStatistics.vue')
const NotFound = () => import('../views/NotFound.vue')

export const routes = [
  { path: '/', component: Home },
  { path: '/items', component: ItemList },
  { path: '/item/:id', component: ItemDetail },
  { path: '/publish', component: PublishItem, meta: { requiresAuth: true } },
  { path: '/my-items', component: MyItems, meta: { requiresAuth: true } },
  { path: '/profile', component: Profile, meta: { requiresAuth: true } },
  { path: '/matches', component: MatchList, meta: { requiresAuth: true } },
  { path: '/admin', component: AdminDashboard, meta: { requiresAuth: true, requiresAdmin: true } },
  { path: '/admin/users', component: AdminUsers, meta: { requiresAuth: true, requiresAdmin: true } },
  { path: '/admin/identity-verifications', component: AdminIdentityVerifications, meta: { requiresAuth: true, requiresAdmin: true } },
  { path: '/admin/locations', component: AdminLocations, meta: { requiresAuth: true, requiresAdmin: true } },
  { path: '/admin/statistics', component: AdminStatistics, meta: { requiresAuth: true, requiresAdmin: true } },
  { path: '/:pathMatch(.*)*', component: NotFound }
]

export function isAdminRole(role) {
  return ['SUPER_ADMIN', 'CAMPUS_ADMIN'].includes(role)
}

export function createAuthGuard() {
  return (to, from, next) => {
    const token = localStorage.getItem('token')
    const storedUser = localStorage.getItem('user')
    let role = null

    if (storedUser) {
      try {
        role = JSON.parse(storedUser)?.role || null
      } catch (error) {
        localStorage.removeItem('user')
      }
    }

    if (to.meta.requiresAuth && !token) {
      next({
        path: '/',
        query: {
          login: '1',
          toast: 'need_login',
          redirect: to.fullPath
        }
      })
      return
    }

    if (to.meta.requiresAdmin && !isAdminRole(role)) {
      next({
        path: '/',
        query: {
          toast: 'need_admin'
        }
      })
      return
    }

    next()
  }
}

export function createAppRouter(history = createWebHistory()) {
  const router = createRouter({
    history,
    routes
  })

  router.beforeEach(createAuthGuard())
  return router
}

const router = createAppRouter()

export default router
