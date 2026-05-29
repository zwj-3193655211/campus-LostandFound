<template>
  <div class="admin-users-page">
    <div class="page-header">
      <h2>用户管理</h2>
      <div class="header-actions">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索用户名、邮箱、姓名或学号..."
          class="search-input"
          @keyup.enter="handleSearch"
        >
          <template #append>
            <el-button @click="handleSearch" type="primary">
              <el-icon><Search /></el-icon>
            </el-button>
          </template>
        </el-input>
      </div>
    </div>

    <div class="filter-bar">
      <el-select v-model="filterRole" placeholder="筛选角色" clearable>
        <el-option label="全部" value="" />
        <el-option label="超级管理员" value="SUPER_ADMIN" />
        <el-option label="校园管理员" value="CAMPUS_ADMIN" />
        <el-option label="普通用户" value="USER" />
      </el-select>
      <el-select v-model="filterStatus" placeholder="账号状态" clearable>
        <el-option label="全部" value="" />
        <el-option label="正常" value="1" />
        <el-option label="禁用" value="0" />
      </el-select>
      <el-button @click="resetFilters">重置筛选</el-button>
    </div>

    <el-card>
      <el-table :data="users" border v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="studentId" label="学号/工号" />
        <el-table-column prop="phone" label="手机号" />
        <el-table-column prop="realName" label="真实姓名" />
        <el-table-column prop="role" label="角色">
          <template #default="scope">
            <el-tag :type="getRoleTagType(scope.row.role)">
              {{ getRoleText(scope.row.role) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="实名认证">
          <template #default="scope">
            <el-tag :type="getIdentityTagType(scope.row.identityStatus)">
              {{ getIdentityText(scope.row.identityStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="账号状态">
          <template #default="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">
              {{ scope.row.status === 1 ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="注册时间" />
        <el-table-column label="操作" min-width="280">
          <template #default="scope">
            <el-button
              v-if="isSuperAdmin"
              @click="handleEdit(scope.row)"
              type="primary"
              size="small"
            >
              编辑
            </el-button>
            <el-button
              v-if="canChangeRole(scope.row)"
              @click="handleChangeRole(scope.row)"
              type="warning"
              size="small"
            >
              改角色
            </el-button>
            <el-button
              v-if="canToggleStatus(scope.row)"
              @click="handleToggleStatus(scope.row)"
              :type="scope.row.status === 1 ? 'info' : 'success'"
              size="small"
            >
              {{ scope.row.status === 1 ? '禁用' : '启用' }}
            </el-button>
            <el-button
              v-if="canDelete(scope.row)"
              @click="handleDelete(scope.row.id)"
              type="danger"
              size="small"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        :current-page="pagination.current"
        :page-size="pagination.size"
        :total="total"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        layout="total, sizes, prev, pager, next, jumper"
      />
    </el-card>

    <el-dialog v-model="showEdit" title="编辑用户" width="420px">
      <el-form :model="editForm" label-width="100px">
        <el-form-item label="用户名">
          <el-input v-model="editForm.username" disabled />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="editForm.email" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="editForm.phone" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showEdit = false">取消</el-button>
        <el-button type="primary" @click="handleSaveEdit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { Search } from '@element-plus/icons-vue'
import axios from '../utils/axios'
import { useUserStore } from '../stores/user'
import { confirmAction, showError, showSuccess } from '../utils/message'

const userStore = useUserStore()
const searchKeyword = ref('')
const filterRole = ref('')
const filterStatus = ref('')
const users = ref([])
const total = ref(0)
const showEdit = ref(false)
const loading = ref(false)

const pagination = reactive({
  current: 1,
  size: 10
})

const editForm = reactive({
  id: '',
  username: '',
  email: '',
  phone: ''
})

const currentUserId = computed(() => userStore.user?.id)
const currentUserRole = computed(() => userStore.user?.role)
const isSuperAdmin = computed(() => currentUserRole.value === 'SUPER_ADMIN')

const getRoleTagType = (role) => {
  const roleMap = {
    SUPER_ADMIN: 'danger',
    CAMPUS_ADMIN: 'warning',
    USER: 'success'
  }
  return roleMap[role] || 'default'
}

const getRoleText = (role) => {
  const roleMap = {
    SUPER_ADMIN: '超级管理员',
    CAMPUS_ADMIN: '校园管理员',
    USER: '普通用户'
  }
  return roleMap[role] || role
}

const getIdentityText = (status) => {
  const statusMap = {
    VERIFIED: '已实名',
    PENDING: '审核中',
    REJECTED: '未通过',
    UNVERIFIED: '未实名'
  }
  return statusMap[status] || '未实名'
}

const getIdentityTagType = (status) => {
  const typeMap = {
    VERIFIED: 'success',
    PENDING: 'warning',
    REJECTED: 'danger',
    UNVERIFIED: 'info'
  }
  return typeMap[status] || 'info'
}

const canChangeRole = (user) => {
  return isSuperAdmin.value && user.role !== 'SUPER_ADMIN' && user.id !== currentUserId.value
}

const canToggleStatus = (user) => {
  if (isSuperAdmin.value) {
    return user.id !== currentUserId.value
  }
  return currentUserRole.value === 'CAMPUS_ADMIN' && user.role === 'USER'
}

const canDelete = (user) => {
  return isSuperAdmin.value && user.role !== 'SUPER_ADMIN' && user.id !== currentUserId.value
}

const fetchUsers = async () => {
  loading.value = true
  try {
    const result = await axios.get('/admin/users', {
      params: {
        keyword: searchKeyword.value || undefined,
        role: filterRole.value || undefined,
        status: filterStatus.value === '' ? undefined : Number(filterStatus.value),
        page: pagination.current,
        pageSize: pagination.size
      }
    })
    users.value = result?.records || []
    total.value = result?.total || 0
  } catch (error) {
    console.error('获取用户失败:', error)
    showError(error?.message || error || '获取用户失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.current = 1
  fetchUsers()
}

const resetFilters = () => {
  searchKeyword.value = ''
  filterRole.value = ''
  filterStatus.value = ''
  pagination.current = 1
  fetchUsers()
}

const handleSizeChange = (size) => {
  pagination.size = size
  fetchUsers()
}

const handleCurrentChange = (page) => {
  pagination.current = page
  fetchUsers()
}

const handleEdit = (user) => {
  editForm.id = user.id
  editForm.username = user.username
  editForm.email = user.email || ''
  editForm.phone = user.phone || ''
  showEdit.value = true
}

const handleSaveEdit = async () => {
  try {
    await axios.put(`/admin/users/${editForm.id}`, {
      email: editForm.email,
      phone: editForm.phone
    })
    showEdit.value = false
    await fetchUsers()
    showSuccess('修改成功')
  } catch (error) {
    console.error('修改失败:', error)
    showError(error?.message || error || '修改失败')
  }
}

const handleChangeRole = async (user) => {
  const nextRole = user.role === 'USER' ? 'CAMPUS_ADMIN' : 'USER'
  try {
    await confirmAction(`确定将 ${user.username} 的角色调整为${getRoleText(nextRole)}吗？`)
  } catch {
    return
  }

  try {
    await axios.put(`/admin/users/${user.id}/role`, { role: nextRole })
    await fetchUsers()
    showSuccess(`角色已更新为: ${getRoleText(nextRole)}`)
  } catch (error) {
    console.error('角色修改失败:', error)
    showError(error?.message || error || '角色修改失败')
  }
}

const handleToggleStatus = async (user) => {
  const nextStatus = user.status === 1 ? 0 : 1
  const actionText = nextStatus === 1 ? '启用' : '禁用'
  try {
    await confirmAction(`确定要${actionText}用户 ${user.username} 吗？`)
  } catch {
    return
  }

  try {
    await axios.put(`/admin/users/${user.id}/status`, { status: nextStatus })
    await fetchUsers()
    showSuccess(`${actionText}成功`)
  } catch (error) {
    console.error('状态修改失败:', error)
    showError(error?.message || error || '状态修改失败')
  }
}

const handleDelete = async (userId) => {
  try {
    await confirmAction('确定要删除该用户吗？此操作不可恢复。')
  } catch {
    return
  }

  try {
    await axios.delete(`/admin/users/${userId}`)
    await fetchUsers()
    showSuccess('删除成功')
  } catch (error) {
    console.error('删除失败:', error)
    showError(error?.message || error || '删除失败')
  }
}

onMounted(fetchUsers)
</script>

<style scoped>
.admin-users-page {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  font-size: 24px;
  margin: 0;
}

.header-actions {
  width: 340px;
}

.search-input {
  width: 100%;
}

.filter-bar {
  display: flex;
  gap: 16px;
  margin-bottom: 20px;
}

.el-pagination {
  text-align: center;
  margin-top: 20px;
}
</style>
