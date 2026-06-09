<template>
  <div class="profile-page app-page">
    <div class="page-header">
      <BackButton show-text />
      <div class="header-title">个人中心</div>
    </div>
    <div class="profile-header">
      <div class="avatar-section">
        <el-avatar :size="110" :icon="User" class="avatar" />
        <h2 class="username">{{ userStore.user?.username }}</h2>
        <el-tag :type="getRoleTagType(userStore.user?.role)">
          {{ getRoleText(userStore.user?.role) }}
        </el-tag>
        <el-tag :type="identityStatusTagType">
          {{ identityStatusText }}
        </el-tag>
      </div>
    </div>

    <el-tabs type="border-card" class="profile-tabs">
      <el-tab-pane label="基本信息">
        <el-form :model="profileForm" label-width="120px" class="profile-form">
          <el-form-item label="用户名">
            <el-input v-model="profileForm.username" disabled />
          </el-form-item>
          <el-form-item label="邮箱">
            <el-input v-model="profileForm.email" />
          </el-form-item>
          <el-form-item label="学号/工号">
            <el-input v-model="profileForm.studentId" disabled />
          </el-form-item>
          <el-form-item label="手机号">
            <el-input v-model="profileForm.phone" />
          </el-form-item>
          <el-form-item label="真实姓名">
            <el-input v-model="profileForm.realName" :disabled="isIdentityPending || isIdentityVerified" />
          </el-form-item>
          <el-form-item label="身份证号">
            <el-input v-model="profileForm.idCard" :disabled="idCardInputDisabled" />
            <span v-if="identityStatus === 'UNVERIFIED'" class="verify-tip">填写后可提交实名认证申请</span>
            <span v-else-if="identityStatus === 'PENDING'" class="verify-tip">实名认证申请审核中，暂不可修改</span>
            <span v-else-if="identityStatus === 'REJECTED'" class="verify-tip verify-tip-danger">上次申请未通过，可修改后重新提交</span>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleSave">保存修改</el-button>
            <el-button v-if="canSubmitIdentity" @click="handleVerify" type="success">
              {{ identityStatus === 'REJECTED' ? '重新提交实名认证' : '提交实名认证' }}
            </el-button>
          </el-form-item>
        </el-form>
      </el-tab-pane>

      <el-tab-pane label="修改密码">
        <el-form :model="passwordForm" :rules="passwordRules" ref="passwordFormRef" label-width="120px" class="profile-form">
          <el-form-item label="原密码" prop="oldPassword">
            <el-input v-model="passwordForm.oldPassword" type="password" />
          </el-form-item>
          <el-form-item label="新密码" prop="newPassword">
            <el-input v-model="passwordForm.newPassword" type="password" />
          </el-form-item>
          <el-form-item label="确认密码" prop="confirmPassword">
            <el-input v-model="passwordForm.confirmPassword" type="password" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleChangePassword">修改密码</el-button>
          </el-form-item>
        </el-form>
      </el-tab-pane>

      <el-tab-pane label="通知设置">
        <el-form :model="notificationSettings" class="profile-form">
          <el-form-item label="站内通知">
            <el-switch
              v-model="notificationSettings.inApp"
              active-text="开启"
              inactive-text="关闭"
              style="--el-switch-on-color: #6366f1; --el-switch-off-color: #d1d5db;"
            />
          </el-form-item>
          <el-form-item label="邮件通知">
            <el-switch
              v-model="notificationSettings.email"
              active-text="开启"
              inactive-text="关闭"
              style="--el-switch-on-color: #6366f1; --el-switch-off-color: #d1d5db;"
            />
          </el-form-item>
          <el-form-item label="匹配提醒">
            <el-switch
              v-model="notificationSettings.match"
              active-text="开启"
              inactive-text="关闭"
              style="--el-switch-on-color: #6366f1; --el-switch-off-color: #d1d5db;"
            />
          </el-form-item>
          <el-form-item label="审核提醒">
            <el-switch
              v-model="notificationSettings.verification"
              active-text="开启"
              inactive-text="关闭"
              style="--el-switch-on-color: #6366f1; --el-switch-off-color: #d1d5db;"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleSaveSettings">保存设置</el-button>
          </el-form-item>
        </el-form>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { User } from '@element-plus/icons-vue'
import { useUserStore } from '../stores/user'
import { showError, showSuccess, showWarning } from '../utils/message'
import BackButton from '../components/BackButton.vue'

const userStore = useUserStore()

const profileForm = reactive({
  username: '',
  email: '',
  studentId: '',
  phone: '',
  realName: '',
  idCard: ''
})

const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const passwordFormRef = ref(null)

const notificationSettings = reactive({
  inApp: true,
  email: true,
  match: true,
  verification: true
})

const passwordRules = {
  oldPassword: [
    { required: true, message: '请输入原密码', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { validator: (rule, value, callback) => {
      if (value !== passwordForm.newPassword) {
        callback(new Error('两次输入的密码不一致'))
      } else {
        callback()
      }
    }, trigger: 'blur' }
  ]
}

const identityStatus = computed(() => {
  return userStore.user?.identityStatus || (userStore.user?.idCard ? 'VERIFIED' : 'UNVERIFIED')
})

const isIdentityVerified = computed(() => identityStatus.value === 'VERIFIED')
const isIdentityPending = computed(() => identityStatus.value === 'PENDING')
const canSubmitIdentity = computed(() => !isIdentityVerified.value && !isIdentityPending.value)
const idCardInputDisabled = computed(() => isIdentityVerified.value || isIdentityPending.value)

const identityStatusText = computed(() => {
  const textMap = {
    UNVERIFIED: '未实名',
    PENDING: '实名审核中',
    VERIFIED: '已实名',
    REJECTED: '实名未通过'
  }
  return textMap[identityStatus.value] || '未实名'
})

const identityStatusTagType = computed(() => {
  const typeMap = {
    UNVERIFIED: 'info',
    PENDING: 'warning',
    VERIFIED: 'success',
    REJECTED: 'danger'
  }
  return typeMap[identityStatus.value] || 'info'
})

const getRoleTagType = (role) => {
  const roleMap = {
    'SUPER_ADMIN': 'danger',
    'CAMPUS_ADMIN': 'warning',
    'USER': 'success'
  }
  return roleMap[role] || 'default'
}

const getRoleText = (role) => {
  const roleMap = {
    'SUPER_ADMIN': '超级管理员',
    'CAMPUS_ADMIN': '校园管理员',
    'USER': '普通用户'
  }
  return roleMap[role] || role
}

const handleSave = async () => {
  try {
    await userStore.updateProfile(profileForm)
    showSuccess('保存成功')
  } catch (error) {
    console.error('保存失败:', error)
    showError(error?.message || '保存失败')
  }
}

const handleVerify = async () => {
  if (!profileForm.realName || !profileForm.idCard) {
    showWarning('请填写真实姓名和身份证号')
    return
  }
  try {
    await userStore.verifyIdentity(profileForm.realName, profileForm.idCard)
    syncProfileForm()
    showSuccess('实名认证申请已提交，请等待管理员审核')
  } catch (error) {
    console.error('认证失败:', error)
    showError(error?.message || '实名认证申请提交失败')
  }
}

const handleChangePassword = async () => {
  if (!passwordFormRef.value) return
  const valid = await passwordFormRef.value.validate()
  if (!valid) return

  try {
    await userStore.changePassword(passwordForm.oldPassword, passwordForm.newPassword)
    showSuccess('密码修改成功')
    passwordForm.oldPassword = ''
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''
  } catch (error) {
    console.error('修改失败:', error)
    showError(error?.message || '密码修改失败')
  }
}

const handleSaveSettings = async () => {
  try {
    await userStore.updateNotificationSettings(notificationSettings)
    showSuccess('设置保存成功')
  } catch (error) {
    console.error('保存失败:', error)
    showError(error?.message || '设置保存失败')
  }
}

const syncProfileForm = () => {
  const user = userStore.user
  if (user) {
    profileForm.username = user.username
    profileForm.email = user.email
    profileForm.studentId = user.studentId
    profileForm.phone = user.phone
    profileForm.realName = user.realName || ''
    profileForm.idCard = identityStatus.value === 'VERIFIED' || identityStatus.value === 'PENDING'
      ? (user.idCard || '')
      : ''

    notificationSettings.inApp = user.notificationInApp === 1 || user.notificationInApp === true
    notificationSettings.email = user.notificationEmail === 1 || user.notificationEmail === true
    notificationSettings.match = user.notificationMatch === 1 || user.notificationMatch === true
    notificationSettings.verification = user.notificationVerification === 1 || user.notificationVerification === true
  }
}

onMounted(() => {
  syncProfileForm()
})
</script>

<style scoped>
.profile-page {
  margin: 0 auto;
  max-width: var(--app-max-width-narrow);
}

.profile-header {
  text-align: center;
  padding: var(--app-space-10);
  background: var(--app-hero-gradient);
  border-radius: var(--app-radius);
  color: #fff;
  box-shadow: var(--app-shadow);
}

.avatar-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}

.avatar {
  background: rgba(255, 255, 255, 0.2);
}

.username {
  margin: 0;
  font-size: 24px;
}

.profile-tabs {
  margin-top: 0;
}

.profile-form {
  padding: var(--app-space-6);
}

.verify-tip {
  margin-left: 8px;
  color: var(--app-link);
  font-size: 12px;
}

.verify-tip-danger {
  color: var(--app-danger);
}
</style>
