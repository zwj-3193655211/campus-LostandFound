<template>
  <el-button 
    :class="['back-button', { 'back-button-with-text': showText }]"
    @click="handleBack"
    :type="type"
    :size="size"
  >
    <el-icon><ArrowLeft /></el-icon>
    <span v-if="showText" class="back-text">{{ text }}</span>
  </el-button>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { ArrowLeft } from '@element-plus/icons-vue'

const router = useRouter()

defineProps({
  showText: {
    type: Boolean,
    default: false
  },
  text: {
    type: String,
    default: '返回'
  },
  type: {
    type: String,
    default: 'default'
  },
  size: {
    type: String,
    default: 'small'
  }
})

const handleBack = () => {
  router.back()
}
</script>

<style scoped>
.back-button {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  transition: all 0.25s ease;
}

.back-button:hover {
  transform: translateX(-4px);
}

.back-button-with-text {
  border-radius: 8px;
  padding: 0 12px;
}

.back-text {
  font-size: 14px;
}
</style>
