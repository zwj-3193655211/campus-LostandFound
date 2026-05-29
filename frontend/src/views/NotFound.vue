<template>
  <div class="not-found-page">
    <h2>页面不存在</h2>
    <p>你访问的地址不存在或已被移动。</p>
    <el-button type="primary" @click="router.push('/')">返回首页</el-button>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()
</script>

<style scoped>
.not-found-page {
  padding: 80px 20px;
  text-align: center;
}

.not-found-page h2 {
  margin-bottom: 12px;
}

.not-found-page p {
  color: #909399;
  margin-bottom: 20px;
}
</style>
