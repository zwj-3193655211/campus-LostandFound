<template>
  <el-dialog title="用户登录" :model-value="true" @close="$emit('close')" width="400px" append-to-body>
    <el-form :model="form" :rules="rules" ref="formRef" label-width="80px">
      <el-form-item label="用户名" prop="username">
        <el-input v-model="form.username" placeholder="请输入用户名" />
      </el-form-item>
      <el-form-item label="密码" prop="password">
        <el-input v-model="form.password" type="password" placeholder="请输入密码" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleLogin" :loading="loading" style="width: 100%">
          {{ loading ? '登录中...' : '登录' }}
        </el-button>
      </el-form-item>
      <div class="form-footer">
        <span class="link" @click="handleOpenRegister">还没有账号？立即注册</span>
      </div>
    </el-form>

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
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useUserStore } from '../stores/user'
import { showError, showSuccess } from '../utils/message'

const emit = defineEmits(['close', 'success', 'open-register'])
const userStore = useUserStore()

const formRef = ref(null)
const forgotFormRef = ref(null)
const loading = ref(false)
const forgotLoading = ref(false)
const showForgot = ref(false)

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
  const valid = await formRef.value.validate()
  if (!valid) return

  loading.value = true
  try {
    await userStore.login(form.username, form.password)
    showSuccess('登录成功')
    emit('success')
    emit('close')
  } catch (error) {
    console.error('登录失败:', error)
    showError(error?.message || '登录失败，请稍后重试')
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
.form-footer {
  display: flex;
  justify-content: space-between;
  margin-top: 16px;
}

.link {
  color: var(--app-link);
  cursor: pointer;
  font-size: 14px;
}

.link:hover {
  text-decoration: underline;
}
</style>
