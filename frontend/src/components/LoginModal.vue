<template>
  <div class="login-modal-wrapper">
    <el-dialog 
      title="用户登录" 
      :model-value="true" 
      @close="$emit('close')" 
      width="420px" 
      append-to-body
      class="login-modal"
    >
    <div class="login-content">
      <div class="login-header">
        <div class="logo-icon">
          <el-icon :size="32"><Cherry /></el-icon>
        </div>
        <h2 class="login-title">欢迎回来</h2>
        <p class="login-subtitle">登录您的账号，继续寻物之旅</p>
      </div>
      
      <el-form :model="form" :rules="rules" ref="formRef" class="login-form">
        <el-form-item prop="username" class="form-item">
          <div class="input-wrapper">
            <el-icon class="input-icon"><User /></el-icon>
            <el-input 
              v-model="form.username" 
              placeholder="请输入用户名" 
              class="login-input"
            />
          </div>
        </el-form-item>
        <el-form-item prop="password" class="form-item">
          <div class="input-wrapper">
            <el-icon class="input-icon"><Lock /></el-icon>
            <el-input 
              v-model="form.password" 
              type="password" 
              placeholder="请输入密码" 
              class="login-input"
            />
          </div>
        </el-form-item>
        <div class="form-options">
          <el-checkbox v-model="rememberMe" class="remember-checkbox">记住我</el-checkbox>
          <span class="forgot-link" @click="showForgot = true">忘记密码？</span>
        </div>
        <el-form-item class="submit-item">
          <el-button type="primary" @click="handleLogin" :loading="loading" class="login-btn">
            {{ loading ? '登录中...' : '登 录' }}
          </el-button>
        </el-form-item>
        <div class="form-footer">
          <span>还没有账号？</span>
          <span class="link" @click="handleOpenRegister">立即注册</span>
        </div>
      </el-form>
    </div>

    <el-dialog title="忘记密码" :model-value="showForgot" @close="showForgot = false" width="400px" append-to-body>
      <el-form :model="forgotForm" :rules="forgotRules" ref="forgotFormRef" label-width="80px">
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="forgotForm.email" placeholder="请输入注册邮箱" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleForgot" :loading="forgotLoading" style="width: 100%">
            {{ forgotLoading ? '发送中...' : '发送验证码' }}
          </el-button>
        </el-form-item>
      </el-form>
    </el-dialog>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { Cherry, User, Lock } from '@element-plus/icons-vue'
import { useUserStore } from '../stores/user'
import { showError, showSuccess } from '../utils/message'

const emit = defineEmits(['close', 'success', 'open-register'])
const userStore = useUserStore()

const formRef = ref(null)
const forgotFormRef = ref(null)
const loading = ref(false)
const forgotLoading = ref(false)
const showForgot = ref(false)
const rememberMe = ref(false)

const form = reactive({
  username: '',
  password: ''
})

const forgotForm = reactive({
  email: ''
})

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ]
}

const forgotRules = {
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  if (!formRef.value) return
  if (loading.value) return  // 防重复提交
  const valid = await formRef.value.validate()
  if (!valid) return

  loading.value = true
  try {
    const data = await userStore.login(form.username, form.password)
    console.log('[LoginModal] 登录成功，token存在:', !!data?.token, 'user存在:', !!data?.user)
    showSuccess('登录成功')
    emit('success')
    emit('close')
  } catch (error) {
    console.error('[LoginModal] 登录失败:', error)
    const msg = error?.message || error?.msg || (typeof error === 'string' ? error : '')
    showError(msg || '登录失败，请稍后重试')
  } finally {
    loading.value = false
  }
}

const handleForgot = async () => {
  if (!forgotFormRef.value) return
  const valid = await forgotFormRef.value.validate()
  if (!valid) return

  forgotLoading.value = true
  try {
    await userStore.forgotPassword(forgotForm.email)
    showSuccess('验证码已发送到您的邮箱')
    showForgot.value = false
  } catch (error) {
    console.error('发送失败:', error)
    showError(error?.message || '发送失败，请稍后重试')
  } finally {
    forgotLoading.value = false
  }
}

const handleOpenRegister = () => {
  emit('close')
  emit('open-register')
}
</script>

<style scoped>
:global(.login-modal.el-dialog) {
  background: #fff !important;
  border-radius: 24px !important;
  overflow: hidden;
  box-shadow: 0 25px 60px rgba(99, 102, 241, 0.25);
}

:global(.login-modal .el-dialog__header) {
  padding: 16px 24px 0 24px !important;
  background: #ffffff !important;
  background-image: none !important;
  background-color: #ffffff !important;
  border-bottom: none !important;
  box-shadow: none !important;
}

:global(.login-modal .el-dialog__body) {
  padding: 0 !important;
}

:global(.login-modal .el-dialog__title) {
  display: block;
  font-size: 16px;
  font-weight: 600;
  color: #1e293b;
  background: #ffffff !important;
  padding: 0;
  margin: 0;
}

:global(.login-modal .el-dialog__headerbtn) {
  background: #ffffff !important;
  border-radius: 50%;
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
}

:global(.login-modal .el-dialog__close) {
  color: #64748b;
  font-size: 18px;
  line-height: 1;
  background: transparent;
}

:global(.login-modal .el-dialog__close:hover) {
  color: #1e293b;
  background: rgba(15, 23, 42, 0.05);
}

.login-content {
  padding: 32px;
}

.login-header {
  text-align: center;
  margin-bottom: 32px;
}

.logo-icon {
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  margin: 0 auto 20px;
  box-shadow: 0 8px 25px rgba(99, 102, 241, 0.35);
}

.login-title {
  font-size: 28px;
  font-weight: 700;
  color: #1e293b;
  margin: 0 0 8px 0;
}

.login-subtitle {
  font-size: 14px;
  color: #64748b;
  margin: 0;
}

.login-form {
  margin-top: 8px;
}

.form-item {
  margin-bottom: 20px;
  display: flex;
  justify-content: center;
}

.input-wrapper {
  position: relative;
  width: 100%;
}

.input-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  color: #94a3b8;
  font-size: 18px;
  z-index: 1;
}

.login-input {
  width: 100%;
}

.login-input :deep(.el-input) {
  width: 100%;
}

.login-input :deep(.el-input__wrapper) {
  width: 100%;
  height: 50px;
  padding-left: 48px;
  border-radius: 14px;
  font-size: 15px;
  border: 1.5px solid rgba(15, 23, 42, 0.1);
  background: rgba(15, 23, 42, 0.02);
  transition: all 0.3s ease;
  box-sizing: border-box;
}

.login-input :deep(.el-input__inner) {
  padding-left: 0;
}

.login-input:hover :deep(.el-input__wrapper) {
  border-color: rgba(99, 102, 241, 0.3);
  background: rgba(15, 23, 42, 0.04);
}

.login-input:focus :deep(.el-input__wrapper) {
  border-color: var(--app-primary);
  box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.1);
  background: #fff;
}

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.remember-checkbox {
  font-size: 13px;
  color: #64748b;
}

.forgot-link {
  font-size: 13px;
  color: var(--app-primary);
  cursor: pointer;
  transition: color 0.3s ease;
}

.forgot-link:hover {
  color: var(--app-primary-dark);
}

.submit-item {
  margin-bottom: 24px !important;
}

.login-btn {
  width: 100%;
  height: 52px;
  border-radius: 14px;
  font-size: 16px;
  font-weight: 600;
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  border: none;
  box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
}

.login-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 30px rgba(99, 102, 241, 0.5);
  background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
}

.login-btn:active:not(:disabled) {
  transform: translateY(0);
}

.form-footer {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #64748b;
}

.link {
  color: var(--app-primary);
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
}

.link:hover {
  color: var(--app-primary-dark);
  text-decoration: none;
}
</style>
