<template>
  <div id="app">
    <el-container direction="vertical" class="app-container">
      <Header />
      <el-main>
        <router-view />
      </el-main>
      <Footer />
    </el-container>
  </div>
</template>

<script setup>
import Header from './components/Header.vue'
import Footer from './components/Footer.vue'
</script>

<style scoped></style>
