<template>
  <div class="publish-page app-page">
    <div class="app-page-header">
      <div>
        <div class="app-page-title">
          <el-icon class="page-icon"><EditPen /></el-icon>
          <h2>{{ isEditMode ? '编辑' : '发布' }}{{ isLost ? '寻物' : '招领' }}信息</h2>
        </div>
        <p class="app-page-subtitle">填写详细信息，帮助更快找到失主或失物</p>
      </div>
    </div>

    <div class="publish-card app-surface app-panel">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="120px">
        <el-form-item label="物品类型" prop="type">
          <el-switch 
            v-model="isLost" 
            active-text="寻物" 
            inactive-text="招领"
            @change="handleTypeChange"
          />
        </el-form-item>

        <el-form-item label="物品名称" prop="title">
          <el-input v-model="form.title" placeholder="请输入物品名称" />
        </el-form-item>

        <el-form-item label="物品类别" prop="category">
          <el-select v-model="form.category" placeholder="请选择类别">
            <el-option 
              v-for="cat in itemStore.categories" 
              :key="cat.value" 
              :label="cat.label" 
              :value="cat.value" 
            />
          </el-select>
        </el-form-item>

        <el-form-item label="物品描述" prop="description">
          <el-input 
            v-model="form.description" 
            type="textarea" 
            :rows="4" 
            placeholder="请详细描述物品特征，如颜色、品牌、型号、特殊标记等"
          />
        </el-form-item>

        <el-form-item label="所在位置" prop="location">
          <el-input v-model="form.location" placeholder="请输入详细位置，如：图书馆三楼A区" />
        </el-form-item>

        <el-form-item :label="isLost ? '丢失时间' : '发现时间'" prop="time">
          <el-date-picker 
            v-model="form.time" 
            type="datetime" 
            placeholder="选择时间"
            format="yyyy-MM-dd HH:mm:ss"
            value-format="yyyy-MM-dd HH:mm:ss"
          />
        </el-form-item>

        <el-form-item label="品牌型号" prop="brand">
          <el-input v-model="form.brand" placeholder="如：iPhone 15 Pro" />
        </el-form-item>

        <el-form-item label="物品颜色" prop="color">
          <el-input v-model="form.color" placeholder="如：黑色、白色、红色" />
        </el-form-item>

        <el-form-item label="序列号" prop="serialNumber">
          <el-input v-model="form.serialNumber" placeholder="如有序列号请填写" />
          <div v-if="form.category === '证件'" class="field-tip">
            如为身份证、校园卡等证件，请尽量填写证件号；身份证招领在审核通过后会优先尝试匹配已实名失主。
          </div>
        </el-form-item>

        <el-form-item label="联系方式" prop="contactInfo">
          <el-input v-model="form.contactInfo" placeholder="请填写手机号或微信号" />
        </el-form-item>

        <el-form-item label="上传图片">
          <el-upload
            list-type="picture-card"
            :file-list="uploadFiles"
            :http-request="handleCustomUpload"
            :on-remove="handleRemove"
            :limit="6"
          >
            <el-icon><Plus /></el-icon>
          </el-upload>
          <div class="upload-tip">图片上传到图床，默认使用 R2 存储；最多 6 张。</div>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSubmit" :loading="loading">
            {{ loading ? (isEditMode ? '保存中...' : '发布中...') : (isEditMode ? '保存修改' : '发布信息') }}
          </el-button>
          <el-button @click="handleReset">{{ isEditMode ? '恢复原始值' : '重置' }}</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Plus, EditPen } from '@element-plus/icons-vue'
import { useItemStore } from '../stores/item'
import { useUserStore } from '../stores/user'
import { showError, showSuccess, showWarning } from '../utils/message'

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
    { required: true, message: '请选择时间', trigger: 'blur' }
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
      lostTime: isLost.value ? form.time : null,
      foundTime: isLost.value ? null : form.time,
      brand: form.brand,
      color: form.color,
      serialNumber: form.serialNumber,
      contactInfo: form.contactInfo,
      images: form.imageUrls
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
  max-width: var(--app-max-width-narrow);
}

.page-icon {
  color: var(--app-primary);
}

.publish-card {
  overflow: hidden;
}

.field-tip {
  margin-top: 6px;
  line-height: 1.5;
  color: var(--app-muted);
  font-size: 12px;
}

.upload-tip {
  color: var(--app-muted);
  font-size: 12px;
  padding: 10px 12px;
  background: var(--app-gray-50);
  border: 1px solid var(--app-border);
  border-radius: var(--app-radius-sm);
}

.el-upload--picture-card {
  width: 120px;
  height: 120px;
}
</style>
