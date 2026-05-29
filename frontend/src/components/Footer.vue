<template>
  <el-footer class="footer">
    <div class="footer-content">
      <div class="footer-section">
        <h3>{{ siteConfig.name }}</h3>
        <p>{{ siteConfig.description }}</p>
        <p>{{ siteConfig.slogan }}</p>
      </div>

      <div class="footer-section">
        <h4>快速链接</h4>
        <ul>
          <li v-for="link in siteConfig.quickLinks" :key="link.href">
            <a :href="link.href">{{ link.label }}</a>
          </li>
        </ul>
      </div>

      <div class="footer-section">
        <h4>联系方式</h4>
        <p>邮箱: {{ siteConfig.contact.email }}</p>
        <p>电话: {{ siteConfig.contact.phone }}</p>
        <p>地址: {{ siteConfig.contact.address }}</p>
      </div>

      <div class="footer-section">
        <h4>服务时间</h4>
        <p v-for="time in siteConfig.serviceHours" :key="time">{{ time }}</p>
      </div>
    </div>

    <div class="footer-bottom">
      <p>© {{ currentYear }} {{ siteConfig.name }} 版权所有</p>
    </div>
  </el-footer>
</template>

<script setup>
import { siteConfig } from '../config/site'

const currentYear = new Date().getFullYear()
</script>

<style scoped>
.footer {
  background-color: var(--app-footer-bg);
  color: var(--app-footer-text);
  padding: 40px 0;
  margin-top: 40px;
}

.footer-content {
  display: flex;
  justify-content: space-around;
  max-width: var(--app-max-width);
  margin: 0 auto;
  padding: 0 20px;
  gap: 28px;
  flex-wrap: wrap;
}

.footer-section {
  flex: 1;
  min-width: 200px;
}

.footer-section h3 {
  font-size: 18px;
  margin-bottom: 16px;
  color: var(--app-footer-text);
}

.footer-section h4 {
  font-size: 16px;
  margin-bottom: 12px;
  color: var(--app-footer-text);
}

.footer-section p {
  color: var(--app-footer-muted);
  margin-bottom: 8px;
  font-size: 14px;
}

.footer-section ul {
  list-style: none;
  padding: 0;
}

.footer-section li {
  margin-bottom: 8px;
}

.footer-section a {
  color: var(--app-footer-muted);
  text-decoration: none;
  font-size: 14px;
}

.footer-section a:hover {
  color: var(--app-footer-text);
}

.footer-bottom {
  text-align: center;
  padding-top: 20px;
  margin-top: 20px;
  border-top: 1px solid var(--app-footer-border);
}

.footer-bottom p {
  color: var(--app-footer-muted);
  font-size: 13px;
}
</style>
