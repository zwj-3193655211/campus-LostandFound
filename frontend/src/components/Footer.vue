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
  background: #1e293b !important;
  background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%) !important;
  color: #ffffff;
  padding: 40px 0;
  margin-top: 40px;
  min-height: 260px;
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
  color: #ffffff;
  font-weight: 600;
}

.footer-section h4 {
  font-size: 16px;
  margin-bottom: 12px;
  color: #f1f5f9;
  font-weight: 600;
}

.footer-section p {
  color: #cbd5e1;
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
  color: #cbd5e1;
  text-decoration: none;
  font-size: 14px;
}

.footer-section a:hover {
  color: #ffffff;
}

.footer-bottom {
  text-align: center;
  padding-top: 20px;
  margin-top: 20px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.footer-bottom p {
  color: #94a3b8;
  font-size: 13px;
}
</style>
