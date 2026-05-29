import { ElMessage, ElMessageBox } from 'element-plus'

export const showSuccess = (message) => ElMessage.success(message)

export const showError = (message) => ElMessage.error(message)

export const showWarning = (message) => ElMessage.warning(message)

export const showInfo = (message) => ElMessage.info(message)

export const confirmAction = (message, title = '提示', options = {}) => ElMessageBox.confirm(
  message,
  title,
  {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
    ...options
  }
)
