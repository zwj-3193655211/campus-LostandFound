<template>
  <div class="admin-locations-page">
    <div class="page-header">
      <h2>位置管理</h2>
      <el-button type="primary" @click="openCreateDialog">新增位置</el-button>
    </div>

    <el-card>
      <el-table :data="locations" border v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="位置名称" />
        <el-table-column prop="building" label="所属建筑" />
        <el-table-column prop="floor" label="楼层" width="100" />
        <el-table-column prop="description" label="描述" />
        <el-table-column label="操作" width="180">
          <template #default="scope">
            <el-button size="small" type="primary" @click="openEditDialog(scope.row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(scope.row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="showDialog" :title="dialogMode === 'create' ? '新增位置' : '编辑位置'" width="420px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="位置名称">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="所属建筑">
          <el-input v-model="form.building" />
        </el-form-item>
        <el-form-item label="楼层">
          <el-input-number v-model="form.floor" :min="-5" :max="50" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { useItemStore } from '../stores/item'
import { confirmAction, showError, showSuccess } from '../utils/message'

const itemStore = useItemStore()
const locations = ref([])
const loading = ref(false)
const showDialog = ref(false)
const dialogMode = ref('create')

const form = reactive({
  id: null,
  name: '',
  building: '',
  floor: 1,
  description: ''
})

const resetForm = () => {
  form.id = null
  form.name = ''
  form.building = ''
  form.floor = 1
  form.description = ''
}

const fetchLocations = async () => {
  loading.value = true
  try {
    const data = await itemStore.fetchLocations()
    locations.value = data || []
  } catch (error) {
    console.error('获取位置失败:', error)
    showError(error?.message || error || '获取位置失败')
  } finally {
    loading.value = false
  }
}

const openCreateDialog = () => {
  dialogMode.value = 'create'
  resetForm()
  showDialog.value = true
}

const openEditDialog = (location) => {
  dialogMode.value = 'edit'
  form.id = location.id
  form.name = location.name
  form.building = location.building
  form.floor = location.floor
  form.description = location.description || ''
  showDialog.value = true
}

const handleSave = async () => {
  try {
    const payload = {
      name: form.name,
      building: form.building,
      floor: form.floor,
      description: form.description
    }

    if (dialogMode.value === 'create') {
      await itemStore.createLocation(payload)
      showSuccess('新增成功')
    } else {
      await itemStore.updateLocation(form.id, payload)
      showSuccess('更新成功')
    }

    showDialog.value = false
    await fetchLocations()
  } catch (error) {
    console.error('保存位置失败:', error)
    showError(error?.message || error || '保存位置失败')
  }
}

const handleDelete = async (id) => {
  try {
    await confirmAction('确定删除该位置吗？')
  } catch {
    return
  }

  try {
    await itemStore.deleteLocation(id)
    await fetchLocations()
    showSuccess('删除成功')
  } catch (error) {
    console.error('删除位置失败:', error)
    showError(error?.message || error || '删除位置失败')
  }
}

onMounted(fetchLocations)
</script>

<style scoped>
.admin-locations-page {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  font-size: 24px;
}
</style>
