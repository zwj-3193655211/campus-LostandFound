<template>
  <el-dialog title="用户注册" :model-value="true" @close="$emit('close')" width="440px" append-to-body>
    <el-form :model="form" :rules="rules" ref="formRef" label-width="92px">
      <el-form-item label="用户名" prop="username">
        <el-input v-model="form.username" placeholder="请输入用户名(3-20位)" />
      </el-form-item>
      <el-form-item label="密码" prop="password">
        <el-input v-model="form.password" type="password" placeholder="请输入密码(至少6位)" show-password />
      </el-form-item>
      <el-form-item label="确认密码" prop="confirmPassword">
        <el-input v-model="form.confirmPassword" type="password" placeholder="请确认密码" show-password />
      </el-form-item>
      <el-form-item label="邮箱" prop="email">
        <el-input v-model="form.email" placeholder="请输入真实邮箱,用于接收验证码" @blur="onEmailBlur" />
      </el-form-item>
      <el-form-item label="验证码" prop="code">
        <div class="code-row">
          <el-input v-model="form.code" placeholder="6位数字" maxlength="6" style="flex: 1" />
          <el-button
            type="primary"
            :disabled="sendingCode || cooldown > 0"
            :loading="sendingCode"
            @click="handleSendCode"
            class="code-btn">
            {{ cooldown > 0 ? `${cooldown}s 后重试` : (sentBefore ? '重新发送' : '发送验证码') }}
          </el-button>
        </div>
        <div class="code-hint" v-if="sentBefore && cooldown === 0">
          验证码 5 分钟内有效,未收到请检查垃圾箱
        </div>
      </el-form-item>
      <el-form-item label="学号/工号" prop="studentId">
        <el-input v-model="form.studentId" placeholder="请输入学号或工号" />
      </el-form-item>
      <el-form-item label="手机号" prop="phone">
        <el-input v-model="form.phone" placeholder="请输入手机号(选填)" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleRegister" :loading="loading" style="width: 100%">
          {{ loading ? '注册中...' : '注册' }}
        </el-button>
      </el-form-item>
      <div class="form-footer">
        <span class="link" @click="handleOpenLogin">已有账号?立即登录</span>
      </div>
    </el-form>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, onUnmounted } from 'vue'
import { useUserStore } from '../stores/user'
import { showError, showSuccess } from '../utils/message'

const emit = defineEmits(['close', 'open-login'])
const userStore = useUserStore()

const formRef = ref(null)
const loading = ref(false)
const sendingCode = ref(false)
const cooldown = ref(0)
const sentBefore = ref(false)
let timerHandle = null

const form = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  email: '',
  code: '',
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
  code: [
    {
      validator: validateCode,
      trigger: 'blur'
    }
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

function validateCode(rule, value, callback) {
  // 验证码总是可选的(后端默认 OFF 模式不强制要求),但如果后端配置 ON,则强制校验
  // 简单的本地长度校验给个引导,真正校验在后端做
  if (value && !/^\d{6}$/.test(value)) {
    callback(new Error('验证码为 6 位数字'))
  } else {
    callback()
  }
}

function onEmailBlur() {
  // 如果用户改了邮箱,清空验证码
  // (不强制要求;原值保留,只是不显示已发送提示)
  sentBefore.value = false
}

async function handleSendCode() {
  if (!form.email) {
    showError('请先填写邮箱')
    return
  }
  // 简单格式校验
  if (!/^[\w.+-]+@[\w-]+(\.[\w-]+)+$/.test(form.email)) {
    showError('邮箱格式不正确')
    return
  }
  sendingCode.value = true
  try {
    const res = await userStore.sendRegisterCode(form.email)
    if (res?.code === 200) {
      showSuccess(res.message || '验证码已发送,请查收邮箱')
      sentBefore.value = true
      startCooldown(60)
    } else {
      showError(res?.message || '发送失败,请稍后再试')
    }
  } catch (error) {
    console.error('发送验证码失败:', error)
    showError(error?.response?.data?.message || error?.message || '发送失败')
  } finally {
    sendingCode.value = false
  }
}

function startCooldown(seconds) {
  cooldown.value = seconds
  if (timerHandle) clearInterval(timerHandle)
  timerHandle = setInterval(() => {
    cooldown.value -= 1
    if (cooldown.value <= 0) {
      clearInterval(timerHandle)
      timerHandle = null
      cooldown.value = 0
    }
  }, 1000)
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
      code: form.code || undefined,  // 空字符串会让后端校验失败;undefined 则不带
      studentId: form.studentId,
      phone: form.phone
    })
    showSuccess('注册成功!请登录')
    emit('close')
    emit('open-login')
  } catch (error) {
    console.error('注册失败:', error)
    showError(error?.response?.data?.message || error?.message || '注册失败,请稍后重试')
  } finally {
    loading.value = false
  }
}

const handleOpenLogin = () => {
  emit('close')
  emit('open-login')
}

onUnmounted(() => {
  if (timerHandle) clearInterval(timerHandle)
})
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

.code-row {
  display: flex;
  gap: 8px;
  align-items: center;
  width: 100%;
}

.code-btn {
  flex-shrink: 0;
  width: 130px;
}

.code-hint {
  font-size: 12px;
  color: var(--app-text-muted, #909399);
  margin-top: 4px;
  line-height: 1.4;
}
</style>
