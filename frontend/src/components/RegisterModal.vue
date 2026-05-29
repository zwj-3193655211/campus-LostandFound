<template>
  <el-dialog title="用户注册" :model-value="true" @close="$emit('close')" width="400px" append-to-body>
    <el-form :model="form" :rules="rules" ref="formRef" label-width="80px">
      <el-form-item label="用户名" prop="username">
        <el-input v-model="form.username" placeholder="请输入用户名" />
      </el-form-item>
      <el-form-item label="密码" prop="password">
        <el-input v-model="form.password" type="password" placeholder="请输入密码" />
      </el-form-item>
      <el-form-item label="确认密码" prop="confirmPassword">
        <el-input v-model="form.confirmPassword" type="password" placeholder="请确认密码" />
      </el-form-item>
      <el-form-item label="邮箱" prop="email">
        <el-input v-model="form.email" placeholder="请输入邮箱" />
      </el-form-item>
      <el-form-item label="学号/工号" prop="studentId">
        <el-input v-model="form.studentId" placeholder="请输入学号或工号" />
      </el-form-item>
      <el-form-item label="手机号" prop="phone">
        <el-input v-model="form.phone" placeholder="请输入手机号" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleRegister" :loading="loading" style="width: 100%">
          {{ loading ? '注册中...' : '注册' }}
        </el-button>
      </el-form-item>
      <div class="form-footer">
        <span class="link" @click="handleOpenLogin">已有账号？立即登录</span>
      </div>
    </el-form>
  </el-dialog>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useUserStore } from '../stores/user'
import { showError, showSuccess } from '../utils/message'

const emit = defineEmits(['close', 'open-login'])
const userStore = useUserStore()

const formRef = ref(null)
const loading = ref(false)

const form = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  email: '',
  studentId: '',
  phone: ''
})

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度在3-20位之间', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  studentId: [
    { required: true, message: '请输入学号或工号', trigger: 'blur' }
  ]
}

function validateConfirmPassword(rule, value, callback) {
  if (value !== form.password) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const handleRegister = async () => {
  if (!formRef.value) return
  const valid = await formRef.value.validate()
  if (!valid) return

  loading.value = true
  try {
    await userStore.register({
      username: form.username,
      password: form.password,
      email: form.email,
      studentId: form.studentId,
      phone: form.phone
    })
    showSuccess('注册成功！请登录')
    emit('close')
    emit('open-login')
  } catch (error) {
    console.error('注册失败:', error)
    showError(error?.message || '注册失败，请稍后重试')
  } finally {
    loading.value = false
  }
}

const handleOpenLogin = () => {
  emit('close')
  emit('open-login')
}
</script>

<style scoped>
.form-footer {
  margin-top: 16px;
  text-align: center;
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
