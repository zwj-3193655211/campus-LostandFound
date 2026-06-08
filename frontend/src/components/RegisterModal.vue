<template>
  <el-dialog 
    title="用户注册" 
    :model-value="true" 
    @close="$emit('close')" 
    width="460px" 
    append-to-body
    class="register-modal"
  >
    <div class="register-content">
      <div class="register-header">
        <div class="logo-icon">
          <el-icon :size="32"><User /></el-icon>
        </div>
        <h2 class="register-title">创建账号</h2>
        <p class="register-subtitle">加入我们，开启寻物之旅</p>
      </div>
      
      <el-form :model="form" :rules="rules" ref="formRef" class="register-form">
        <el-form-item prop="username" class="form-item">
          <div class="input-wrapper">
            <el-icon class="input-icon"><User /></el-icon>
            <el-input 
              v-model="form.username" 
              placeholder="请输入用户名(3-20位)" 
              class="register-input"
            />
          </div>
        </el-form-item>
        
        <el-form-item prop="password" class="form-item">
          <div class="input-wrapper">
            <el-icon class="input-icon"><Lock /></el-icon>
            <el-input 
              v-model="form.password" 
              type="password" 
              placeholder="请输入密码(至少6位)" 
              show-password 
              class="register-input"
            />
          </div>
        </el-form-item>
        
        <el-form-item prop="confirmPassword" class="form-item">
          <div class="input-wrapper">
            <el-icon class="input-icon"><Lock /></el-icon>
            <el-input 
              v-model="form.confirmPassword" 
              type="password" 
              placeholder="请确认密码" 
              show-password 
              class="register-input"
            />
          </div>
        </el-form-item>
        
        <el-form-item prop="email" class="form-item">
          <div class="input-wrapper">
            <el-icon class="input-icon"><Message /></el-icon>
            <el-input 
              v-model="form.email" 
              placeholder="请输入真实邮箱,用于接收验证码" 
              @blur="onEmailBlur" 
              class="register-input"
            />
          </div>
        </el-form-item>
        
        <el-form-item prop="code" class="form-item code-item">
          <div class="code-row">
            <div class="input-wrapper code-input-wrapper">
              <el-icon class="input-icon"><Key /></el-icon>
              <el-input 
                v-model="form.code" 
                placeholder="6位数字" 
                maxlength="6" 
                class="register-input code-input"
              />
            </div>
            <el-button
              type="primary"
              :disabled="sendingCode || cooldown > 0"
              :loading="sendingCode"
              @click="handleSendCode"
              class="code-btn">
              {{ cooldown > 0 ? `${cooldown}s` : (sentBefore ? '重新发送' : '发送验证码') }}
            </el-button>
          </div>
          <div class="code-hint" v-if="sentBefore && cooldown === 0">
            验证码 5 分钟内有效,未收到请检查垃圾箱
          </div>
        </el-form-item>
        
        <el-form-item prop="studentId" class="form-item">
          <div class="input-wrapper">
            <el-icon class="input-icon"><CreditCard /></el-icon>
            <el-input 
              v-model="form.studentId" 
              placeholder="请输入学号或工号" 
              class="register-input"
            />
          </div>
        </el-form-item>
        
        <el-form-item prop="phone" class="form-item">
          <div class="input-wrapper">
            <el-icon class="input-icon"><Phone /></el-icon>
            <el-input 
              v-model="form.phone" 
              placeholder="请输入手机号(选填)" 
              class="register-input"
            />
          </div>
        </el-form-item>
        
        <el-form-item class="submit-item">
          <el-button type="primary" @click="handleRegister" :loading="loading" class="register-btn">
            {{ loading ? '注册中...' : '注 册' }}
          </el-button>
        </el-form-item>
        
        <div class="form-footer">
          <span>已有账号？</span>
          <span class="link" @click="handleOpenLogin">立即登录</span>
        </div>
      </el-form>
    </div>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, onUnmounted } from 'vue'
import { User, Lock, Message, Key, CreditCard, Phone } from '@element-plus/icons-vue'
import { useUserStore } from '../stores/user'
import { showError, showSuccess, showWarning } from '../utils/message'

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
  // 防重复提交
  if (sendingCode.value || cooldown.value > 0) {
    return
  }
  
  sendingCode.value = true
  try {
    // axios拦截器已提取 payload.data，所以返回值是 "true" 或 "false" 字符串
    const result = await userStore.sendRegisterCode(form.email)
    if (result === 'true' || result === true) {
      // 发送成功
      showSuccess('验证码已发送,请查收邮箱')
      sentBefore.value = true
      startCooldown(60)
    } else {
      // 冷却中或其他情况
      showWarning('发送过于频繁，请60秒后再试')
      startCooldown(60)
    }
  } catch (error) {
    console.error('发送验证码失败:', error)
    const errMsg = error?.response?.data?.message || error?.message || error || '发送失败'
    // 如果是冷却中，显示警告而非错误
    if (String(errMsg).includes('冷却') || String(errMsg).includes('频繁')) {
      showWarning(String(errMsg))
      startCooldown(60)
    } else {
      showError(String(errMsg))
    }
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
:global(.register-modal.el-dialog) {
  border-radius: 24px !important;
  overflow: hidden;
  box-shadow: 0 25px 60px rgba(99, 102, 241, 0.25);
}

:global(.register-modal .el-dialog__header) {
  background: #ffffff !important;
  background-image: none !important;
  background-color: #ffffff !important;
  padding: 16px 24px 0 24px !important;
  border-bottom: none !important;
  box-shadow: none !important;
}

:global(.register-modal .el-dialog__title) {
  display: none;
}

:global(.register-modal .el-dialog__headerbtn) {
  background: #ffffff !important;
}

:global(.register-modal .el-dialog__close) {
  color: #64748b;
  font-size: 18px;
}

:global(.register-modal .el-dialog__close:hover) {
  color: #1e293b;
  background: rgba(15, 23, 42, 0.05);
}

:global(.register-modal .el-dialog__body) {
  padding: 0 !important;
}

.register-content {
  padding: 24px 32px 32px 32px;
}

.register-header {
  text-align: center;
  margin-bottom: 32px;
}

.logo-icon {
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%);
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  margin: 0 auto 20px;
  box-shadow: 0 8px 25px rgba(139, 92, 246, 0.35);
}

.register-title {
  font-size: 28px;
  font-weight: 700;
  color: #1e293b;
  margin: 0 0 8px 0;
}

.register-subtitle {
  font-size: 14px;
  color: #64748b;
  margin: 0;
}

.register-form {
  margin-top: 8px;
}

.form-item {
  margin-bottom: 18px;
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

.register-input {
  width: 100%;
}

.register-input :deep(.el-input__wrapper) {
  height: 48px;
  padding-left: 48px;
  border-radius: 12px;
  font-size: 15px;
  border: 1.5px solid rgba(15, 23, 42, 0.1);
  background: rgba(15, 23, 42, 0.02);
  transition: all 0.3s ease;
  box-sizing: border-box;
  box-shadow: none;
}

.register-input :deep(.el-input__inner) {
  padding-left: 0;
}

.register-input:hover :deep(.el-input__wrapper) {
  border-color: rgba(139, 92, 246, 0.3);
  background: rgba(15, 23, 42, 0.04);
  box-shadow: none;
}

.register-input :deep(.el-input__wrapper.is-focus) {
  border-color: #8b5cf6;
  box-shadow: 0 0 0 4px rgba(139, 92, 246, 0.1) !important;
  background: #fff;
}

.code-item {
  margin-bottom: 18px;
}

.code-row {
  display: flex;
  gap: 12px;
  align-items: center;
  width: 100%;
}

.code-input-wrapper {
  flex: 1;
}

.code-input {
  width: 100%;
}

.code-btn {
  flex-shrink: 0;
  width: 140px;
  height: 48px;
  border-radius: 12px;
  font-size: 14px;
  font-weight: 500;
  background: linear-gradient(135deg, #8b5cf6 0%, #a855f7 100%);
  border: none;
  box-shadow: 0 4px 15px rgba(139, 92, 246, 0.3);
  transition: all 0.3s ease;
}

.code-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(139, 92, 246, 0.4);
}

.code-btn:disabled {
  background: #cbd5e1;
  box-shadow: none;
}

.code-hint {
  font-size: 12px;
  color: #94a3b8;
  margin-top: 8px;
  line-height: 1.4;
}

.submit-item {
  margin-bottom: 24px !important;
}

.register-btn {
  width: 100%;
  height: 52px;
  border-radius: 14px;
  font-size: 16px;
  font-weight: 600;
  background: linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%);
  border: none;
  box-shadow: 0 6px 20px rgba(139, 92, 246, 0.4);
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
}

.register-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 30px rgba(139, 92, 246, 0.5);
}

.register-btn:active:not(:disabled) {
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
  color: #8b5cf6;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
}

.link:hover {
  color: #7c3aed;
  text-decoration: none;
}
</style>
