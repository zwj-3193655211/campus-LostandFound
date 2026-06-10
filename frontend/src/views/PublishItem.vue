<template>
  <div class="publish-page app-page">
    <div class="page-header-wrapper">
      <div class="app-page-header">
        <BackButton show-text />
        <div class="header-icon">
          <el-icon :size="40"><EditPen /></el-icon>
        </div>
        <div>
          <h2 class="app-page-title">{{ isEditMode ? '编辑' : '发布' }}{{ isLost ? '寻物' : '招领' }}信息</h2>
          <p class="app-page-subtitle">填写详细信息，帮助更快找到失主或失物</p>
        </div>
      </div>
    </div>

    <div class="publish-card">
      <div class="type-switch-wrapper">
        <div class="switch-label">物品类型</div>
        <el-switch 
          v-model="isLost" 
          active-text="寻物" 
          inactive-text="招领"
          @change="handleTypeChange"
          class="type-switch"
        />
      </div>

      <el-form :model="form" :rules="rules" ref="formRef" class="publish-form" label-position="top" label-width="0">
        <div class="form-section">
          <div class="section-title">基本信息</div>
          
          <el-form-item prop="title" class="form-item">
            <label class="form-label">物品名称</label>
            <div class="input-wrapper">
              <el-icon class="input-icon"><PriceTag /></el-icon>
              <el-input v-model="form.title" placeholder="请输入物品名称" class="form-input" />
            </div>
          </el-form-item>

          <el-form-item prop="category" class="form-item">
            <label class="form-label">物品类别</label>
            <div class="input-wrapper">
              <el-icon class="input-icon"><Briefcase /></el-icon>
              <el-select v-model="form.category" placeholder="请选择类别" class="form-select">
                <el-option 
                  v-for="cat in itemStore.categories" 
                  :key="cat.value" 
                  :label="cat.label" 
                  :value="cat.value" 
                />
              </el-select>
            </div>
          </el-form-item>
        </div>

        <div class="form-section">
          <div class="section-title">详细描述</div>
          
          <el-form-item prop="description" class="form-item">
            <label class="form-label">物品描述</label>
            <div class="input-wrapper">
              <el-icon class="input-icon"><Document /></el-icon>
              <el-input 
                v-model="form.description" 
                type="textarea" 
                :rows="4" 
                placeholder="请详细描述物品特征，如颜色、品牌、型号、特殊标记等"
                class="form-textarea"
              />
            </div>
          </el-form-item>

          <el-form-item prop="brand" class="form-item">
            <label class="form-label">品牌型号</label>
            <div class="input-wrapper">
              <el-icon class="input-icon"><CreditCard /></el-icon>
              <el-input v-model="form.brand" placeholder="如：iPhone 15 Pro" class="form-input" />
            </div>
          </el-form-item>

          <el-form-item prop="color" class="form-item">
            <label class="form-label">物品颜色</label>
            <div class="input-wrapper">
              <el-icon class="input-icon"><Brush /></el-icon>
              <el-input v-model="form.color" placeholder="如：黑色、白色、红色" class="form-input" />
            </div>
          </el-form-item>

          <el-form-item prop="serialNumber" class="form-item">
            <label class="form-label">序列号</label>
            <div class="input-wrapper">
              <el-icon class="input-icon"><Key /></el-icon>
              <el-input v-model="form.serialNumber" placeholder="如有序列号请填写" class="form-input" />
            </div>
            <div v-if="form.category === '证件'" class="field-tip">
              <el-icon class="tip-icon"><Notification /></el-icon>
              如为身份证、校园卡等证件，请尽量填写证件号；身份证招领在审核通过后会优先尝试匹配已实名失主。
            </div>
          </el-form-item>
        </div>

        <div class="form-section">
          <div class="section-title">位置信息</div>
          
          <el-form-item prop="location" class="form-item">
            <label class="form-label">所在位置</label>
            <div class="input-wrapper">
              <el-icon class="input-icon"><Location /></el-icon>
              <el-input v-model="form.location" placeholder="请输入详细位置，如：图书馆三楼A区" class="form-input" />
            </div>
          </el-form-item>

          <el-form-item prop="time" class="form-item">
            <label class="form-label">{{ isLost ? '丢失时间' : '发现时间' }}</label>
            <div class="input-wrapper">
              <el-date-picker 
                v-model="form.time" 
                type="datetime" 
                placeholder="选择时间"
                format="YYYY-MM-DD HH:mm:ss"
                value-format="YYYY-MM-DD HH:mm:ss"
                :disabled-date="disableFutureDate"
                :disabled-hours="disabledFutureHours"
                :disabled-minutes="disabledFutureMinutes"
                :disabled-seconds="disabledFutureSeconds"
                :prefix-icon="Clock"
                class="form-datepicker"
              />
            </div>
          </el-form-item>
        </div>

        <div class="form-section">
          <div class="section-title">联系信息</div>
          
          <el-form-item prop="contactInfo" class="form-item">
            <label class="form-label">联系方式</label>
            <div class="input-wrapper">
              <el-icon class="input-icon"><Message /></el-icon>
              <el-input v-model="form.contactInfo" placeholder="请填写手机号或微信号" class="form-input" />
            </div>
          </el-form-item>
        </div>

        <div class="form-section">
          <div class="section-title">图片上传</div>
          
          <el-form-item class="form-item upload-section">
            <el-upload
              list-type="picture-card"
              :file-list="uploadFiles"
              :http-request="handleCustomUpload"
              :on-remove="handleRemove"
              :limit="6"
              class="uploader"
            >
              <div class="upload-add-btn">
                <el-icon :size="28"><Plus /></el-icon>
                <span>添加图片</span>
              </div>
            </el-upload>
          </el-form-item>
        </div>

        <div class="form-actions">
          <el-button type="primary" @click="handleSubmit" :loading="loading" class="submit-btn">
            <el-icon><Promotion /></el-icon>
            {{ loading ? (isEditMode ? '保存中...' : '发布中...') : (isEditMode ? '保存修改' : '发布信息') }}
          </el-button>
          <el-button @click="handleReset" class="reset-btn">
            <el-icon><Refresh /></el-icon>
            {{ isEditMode ? '恢复原始值' : '重置' }}
          </el-button>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Plus, EditPen, PriceTag, Briefcase, Document, CreditCard, Brush, Key, Location, Clock, Message, Notification, InfoFilled, Promotion, Refresh } from '@element-plus/icons-vue'
import { useItemStore } from '../stores/item'
import { useUserStore } from '../stores/user'
import { showError, showSuccess, showWarning } from '../utils/message'
import BackButton from '../components/BackButton.vue'

const route = useRoute()
const router = useRouter()
const itemStore = useItemStore()
const userStore = useUserStore()

const isLost = ref(true)
const isEditMode = ref(false)
const editingItemId = ref(null)
const loading = ref(false)
const formRef = ref(null)
const uploadFiles = ref([])

const form = reactive({
  title: '',
  category: '',
  description: '',
  location: '',
  time: '',
  brand: '',
  color: '',
  serialNumber: '',
  contactInfo: '',
  imageUrls: []
})

const parseFormDateTime = (value) => {
  if (!value) return null
  if (value instanceof Date) return value

  const [datePart, timePart = '00:00:00'] = String(value).split(' ')
  const [year, month, day] = datePart.split('-').map(Number)
  const [hour = 0, minute = 0, second = 0] = timePart.split(':').map(Number)

  if ([year, month, day, hour, minute, second].some(Number.isNaN)) {
    return null
  }

  return new Date(year, month - 1, day, hour, minute, second)
}

const isSameCalendarDate = (first, second) => {
  return first.getFullYear() === second.getFullYear()
    && first.getMonth() === second.getMonth()
    && first.getDate() === second.getDate()
}

const createNumberRange = (start, end) => {
  if (start > end) {
    return []
  }
  return Array.from({ length: end - start + 1 }, (_, index) => start + index)
}

const getCurrentTime = () => new Date()

const getSelectedTime = () => parseFormDateTime(form.time)

const disableFutureDate = (date) => {
  return date.getTime() > getCurrentTime().getTime()
}

const disabledFutureHours = () => {
  const selectedTime = getSelectedTime()
  const now = getCurrentTime()
  if (!selectedTime || !isSameCalendarDate(selectedTime, now)) {
    return []
  }
  return createNumberRange(now.getHours() + 1, 23)
}

const disabledFutureMinutes = (selectedHour) => {
  const selectedTime = getSelectedTime()
  const now = getCurrentTime()
  if (!selectedTime || !isSameCalendarDate(selectedTime, now) || selectedHour !== now.getHours()) {
    return []
  }
  return createNumberRange(now.getMinutes() + 1, 59)
}

const disabledFutureSeconds = (selectedHour, selectedMinute) => {
  const selectedTime = getSelectedTime()
  const now = getCurrentTime()
  if (!selectedTime
    || !isSameCalendarDate(selectedTime, now)
    || selectedHour !== now.getHours()
    || selectedMinute !== now.getMinutes()) {
    return []
  }
  return createNumberRange(now.getSeconds() + 1, 59)
}

const validatePastOrPresentTime = (_, value, callback) => {
  if (!value) {
    callback()
    return
  }

  const parsedTime = parseFormDateTime(value)
  if (!parsedTime) {
    callback(new Error('时间格式不正确'))
    return
  }

  if (parsedTime.getTime() > getCurrentTime().getTime()) {
    callback(new Error('时间不能晚于当前时间'))
    return
  }

  callback()
}

const rules = {
  title: [
    { required: true, message: '请输入物品名称', trigger: 'blur' },
    { min: 2, max: 50, message: '名称长度在2-50之间', trigger: 'blur' }
  ],
  category: [
    { required: true, message: '请选择物品类别', trigger: 'blur' }
  ],
  description: [
    { required: true, message: '请填写物品描述', trigger: 'blur' },
    { min: 10, message: '描述至少10个字符', trigger: 'blur' }
  ],
  location: [
    { required: true, message: '请输入位置', trigger: 'blur' },
    { min: 2, max: 100, message: '位置长度在2-100之间', trigger: 'blur' }
  ],
  time: [
    { required: true, message: '请选择时间', trigger: 'blur' },
    { validator: validatePastOrPresentTime, trigger: 'change' }
  ],
  contactInfo: [
    { required: true, message: '请填写联系方式', trigger: 'blur' }
  ]
}

const handleTypeChange = () => {
  form.time = ''
}

const syncImageUrls = () => {
  form.imageUrls = uploadFiles.value.map(file => file.url).filter(Boolean)
}

const handleCustomUpload = async (options) => {
  try {
    const result = await itemStore.uploadItemImage(options.file)
    const url = result?.url
    if (!url) {
      throw new Error('图床未返回可访问地址')
    }
    uploadFiles.value = [
      ...uploadFiles.value,
      {
        name: result?.filename || options.file.name,
        url
      }
    ]
    syncImageUrls()
    options.onSuccess?.(result)
    showSuccess('图片上传成功')
  } catch (error) {
    options.onError?.(error)
    showError(error?.message || error || '图片上传失败')
  }
}

const handleRemove = (file, fileList) => {
  uploadFiles.value = fileList.map(current => ({
    name: current.name,
    url: current.url
  }))
  syncImageUrls()
}

const handleSubmit = async () => {
  if (!formRef.value) return
  const valid = await formRef.value.validate()
  if (!valid) return

  if (!userStore.user) {
    showWarning('请先登录')
    return
  }

  loading.value = true
  
  try {
    const itemData = {
      type: isLost.value ? 'LOST' : 'FOUND',
      title: form.title,
      category: form.category,
      description: form.description,
      location: form.location,
      lostTime: isLost.value && form.time ? form.time.replace('T', ' ') : null,
      foundTime: !isLost.value && form.time ? form.time.replace('T', ' ') : null,
      brand: form.brand,
      color: form.color,
      serialNumber: form.serialNumber,
      contactInfo: form.contactInfo,
      images: form.imageUrls || []
    }

    if (isEditMode.value && editingItemId.value) {
      await itemStore.updateItem(editingItemId.value, itemData)
      showSuccess('修改成功')
      router.push('/my-items')
      return
    }

    await itemStore.createItem(itemData)
    showSuccess('发布成功！待审核通过后将展示')
    router.push('/')
  } catch (error) {
    console.error('发布失败:', error)
    showError(error?.message || error || '发布失败，请重试')
  } finally {
    loading.value = false
  }
}

const handleReset = () => {
  form.title = ''
  form.category = ''
  form.description = ''
  form.location = ''
  form.time = ''
  form.brand = ''
  form.color = ''
  form.serialNumber = ''
  form.contactInfo = ''
  form.imageUrls = []
  uploadFiles.value = []
}

const fillForm = (item) => {
  if (!item) return
  isLost.value = item.type === 'LOST'
  form.title = item.title || ''
  form.category = item.category || ''
  form.description = item.description || ''
  form.location = item.location || ''
  form.time = item.type === 'LOST' ? item.lostTime : item.foundTime
  form.brand = item.brand || ''
  form.color = item.color || ''
  form.serialNumber = item.serialNumber || ''
  form.contactInfo = item.contactInfo || ''
  form.imageUrls = item.images || []
  uploadFiles.value = form.imageUrls.map((url, index) => ({
    name: `image-${index + 1}`,
    url
  }))
}

onMounted(async () => {
  const editId = route.query.id
  if (!editId) {
    return
  }

  isEditMode.value = true
  editingItemId.value = Number(editId)
  try {
    const item = await itemStore.fetchItem(editingItemId.value)
    fillForm(item)
  } catch (error) {
    console.error('加载待编辑物品失败:', error)
    showError(error?.message || error || '加载待编辑物品失败')
    router.push('/my-items')
  }
})
</script>

<style scoped>
.publish-page {
  margin: 0 auto;
  max-width: 700px;
}

.page-header-wrapper {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  border-radius: 24px;
  padding: 32px;
  margin-bottom: 24px;
  box-shadow: 0 10px 40px rgba(99, 102, 241, 0.3);
}

.app-page-header {
  display: flex;
  align-items: center;
  gap: 20px;
}

.header-icon {
  width: 56px;
  height: 56px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  backdrop-filter: blur(10px);
}

.app-page-title {
  font-size: 28px;
  font-weight: 700;
  color: #fff;
  margin: 0 0 8px 0;
}

.app-page-subtitle {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.85);
  margin: 0;
}

.publish-card {
  background: #fff;
  border-radius: 24px;
  border: 1px solid rgba(15, 23, 42, 0.06);
  box-shadow: 0 4px 24px rgba(15, 23, 42, 0.04);
  overflow: hidden;
}

.type-switch-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  padding: 24px;
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.04) 0%, rgba(139, 92, 246, 0.04) 100%);
  border-bottom: 1px solid rgba(15, 23, 42, 0.06);
}

.switch-label {
  font-size: 15px;
  font-weight: 600;
  color: #334155;
}

.type-switch {
  --el-switch-on-color: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  --el-switch-off-color: #ec4899;
  --el-switch-on-text-color: #fff;
  --el-switch-off-text-color: #fff;
  font-weight: 600;
}

.publish-form {
  padding: 24px;
}

.form-section {
  margin-bottom: 28px;
}

.section-title {
  font-size: 16px;
  font-weight: 700;
  color: #1e293b;
  margin-bottom: 20px;
  padding-left: 12px;
  border-left: 4px solid var(--app-primary);
}

.form-item {
  margin-bottom: 32px !important;
}

.form-item :deep(.el-form-item__content) {
  margin-left: 0 !important;
  padding-left: 0;
  margin-top: 16px;
}

.form-item :deep(.el-form-item__label) {
  display: none;
}

.form-label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  color: #475569;
  padding-left: 12px;
  margin: 0;
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

.form-input {
  width: 100% !important;
}

.form-input :deep(.el-input) {
  width: 100%;
}

.form-input :deep(.el-input__wrapper) {
  width: 100%;
  height: 46px;
  padding-left: 48px;
  border-radius: 12px;
  border: 1px solid rgba(15, 23, 42, 0.12);
  background: #fff;
  box-sizing: border-box;
}

.form-input :deep(.el-input__inner) {
  padding-left: 0;
}

.form-select {
  width: 100% !important;
}

.form-select :deep(.el-select) {
  width: 100%;
}

.form-select :deep(.el-select__wrapper) {
  width: 100%;
  height: 46px;
  padding-left: 48px;
  border-radius: 12px;
  border: 1px solid rgba(15, 23, 42, 0.12);
  background: #fff;
  box-sizing: border-box;
}

.form-select :deep(.el-select__inner) {
  padding-left: 0;
}

.form-textarea {
  width: 100% !important;
  box-sizing: border-box;
}

.form-textarea :deep(.el-textarea__inner) {
  width: 100%;
  padding: 12px 16px 12px 48px;
  min-height: 100px;
  border-radius: 12px;
  font-size: 15px;
  border: 1px solid rgba(15, 23, 42, 0.12);
  background: #fff;
  transition: all 0.3s ease;
  box-sizing: border-box;
}

.form-input:hover {
  border-color: rgba(99, 102, 241, 0.3);
}

.form-input:focus {
  border-color: var(--app-primary);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.08);
  outline: none;
}

.form-select:hover :deep(.el-select__wrapper) {
  border-color: rgba(99, 102, 241, 0.3);
}

.form-select:focus :deep(.el-select__wrapper) {
  border-color: var(--app-primary);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.08);
}

.form-textarea:hover {
  border-color: rgba(99, 102, 241, 0.3);
}

.form-textarea:focus {
  border-color: var(--app-primary);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.08);
  outline: none;
}

.form-datepicker {
  width: 100% !important;
}

.form-datepicker :deep(.el-input__wrapper) {
  width: 100%;
  height: 46px;
  border-radius: 12px;
  border: 1px solid rgba(15, 23, 42, 0.12);
  background: #fff;
  box-sizing: border-box;
  box-shadow: none;
}

.form-datepicker :deep(.el-input__inner) {
  height: 44px;
}

.form-datepicker :deep(.el-input__prefix) {
  color: #94a3b8;
  font-size: 16px;
}

.form-datepicker:hover :deep(.el-input__wrapper) {
  border-color: rgba(99, 102, 241, 0.3);
  box-shadow: none;
}

.form-datepicker:focus :deep(.el-input__wrapper),
.form-datepicker :deep(.el-input__wrapper.is-focus) {
  border-color: var(--app-primary);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.08);
}

.field-tip {
  margin-top: 10px;
  padding: 12px 16px;
  background: linear-gradient(135deg, rgba(251, 191, 36, 0.1) 0%, rgba(251, 191, 36, 0.05) 100%);
  border-radius: 10px;
  font-size: 13px;
  color: #92400e;
  display: flex;
  align-items: flex-start;
  gap: 8px;
}

.tip-icon {
  flex-shrink: 0;
  margin-top: 1px;
}

.upload-section {
  margin-bottom: 0 !important;
}

.uploader :deep(.el-upload--picture-card) {
  width: 130px;
  height: 130px;
  border-radius: 16px;
  border: 2px dashed rgba(15, 23, 42, 0.15);
  background: rgba(15, 23, 42, 0.02);
  transition: all 0.35s ease;
}

.uploader :deep(.el-upload--picture-card:hover) {
  border-color: var(--app-primary);
  background: rgba(99, 102, 241, 0.05);
  transform: scale(1.05);
}

.upload-add-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  color: #94a3b8;
}

.upload-add-btn span {
  font-size: 13px;
}

.upload-tip {
  margin-top: 16px;
  padding: 14px 16px;
  background: rgba(59, 130, 246, 0.06);
  border-radius: 12px;
  font-size: 13px;
  color: #1e40af;
  display: flex;
  align-items: center;
  gap: 8px;
}

.form-actions {
  display: flex;
  justify-content: center;
  gap: 20px;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid rgba(15, 23, 42, 0.06);
}

.submit-btn {
  padding: 16px 48px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 16px;
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  border: none;
  box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
}

.submit-btn:hover:not(:disabled) {
  transform: translateY(-3px);
  box-shadow: 0 12px 35px rgba(99, 102, 241, 0.5);
}

.reset-btn {
  padding: 16px 36px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 16px;
  background: rgba(15, 23, 42, 0.04);
  border: 2px solid rgba(15, 23, 42, 0.1);
  color: #475569;
  transition: all 0.3s ease;
}

.reset-btn:hover {
  background: rgba(15, 23, 42, 0.08);
  border-color: rgba(99, 102, 241, 0.2);
}

@media (max-width: 600px) {
  .page-header-wrapper {
    padding: 24px;
  }
  
  .app-page-title {
    font-size: 24px;
  }
  
  .header-icon {
    width: 48px;
    height: 48px;
  }
  
  .publish-card {
    border-radius: 16px;
  }
  
  .type-switch-wrapper {
    padding: 16px;
  }
  
  .publish-form {
    padding: 16px;
  }
  
  .submit-btn,
  .reset-btn {
    padding: 12px 24px;
    font-size: 14px;
  }
  
  .uploader :deep(.el-upload--picture-card) {
    width: 100px;
    height: 100px;
  }
}
</style>
