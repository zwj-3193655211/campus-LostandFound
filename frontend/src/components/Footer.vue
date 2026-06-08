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
  background: linear-gradient(180deg, #0f172a 0%, #1e293b 50%, #1e1b4b 100%) !important;
  color: #ffffff;
  padding: 56px 0 32px;
  margin-top: 60px;
  min-height: 280px;
  position: relative;
  overflow: hidden;
}

.footer::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, transparent, rgba(99, 102, 241, 0.5), rgba(139, 92, 246, 0.3), transparent);
}

.footer::after {
  content: '';
  position: absolute;
  top: -200px;
  right: -100px;
  width: 400px;
  height: 400px;
  background: radial-gradient(circle, rgba(99, 102, 241, 0.1) 0%, transparent 60%);
  border-radius: 50%;
}

.footer-content {
  display: flex;
  justify-content: space-around;
  max-width: var(--app-max-width);
  margin: 0 auto;
  padding: 0 24px;
  gap: 32px;
  flex-wrap: wrap;
  position: relative;
  z-index: 1;
}

.footer-section {
  flex: 1;
  min-width: 220px;
  padding: 16px;
  border-radius: 16px;
  transition: all 0.3s ease;
}

.footer-section:hover {
  background: rgba(255, 255, 255, 0.03);
}

.footer-section h3 {
  font-size: 22px;
  margin-bottom: 20px;
  color: #ffffff;
  font-weight: 700;
  letter-spacing: -0.02em;
  background: linear-gradient(135deg, #fff 0%, rgba(255, 255, 255, 0.8) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.footer-section h4 {
  font-size: 15px;
  margin-bottom: 16px;
  color: #f1f5f9;
  font-weight: 600;
  position: relative;
  padding-left: 12px;
}

.footer-section h4::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 3px;
  height: 14px;
  background: linear-gradient(180deg, var(--app-primary) 0%, #8b5cf6 100%);
  border-radius: 2px;
}

.footer-section p {
  color: #94a3b8;
  margin-bottom: 10px;
  font-size: 14px;
  line-height: 1.7;
  transition: color 0.3s ease;
}

.footer-section p:hover {
  color: #cbd5e1;
}

.footer-section ul {
  list-style: none;
  padding: 0;
}

.footer-section li {
  margin-bottom: 10px;
  position: relative;
}

.footer-section a {
  color: #94a3b8;
  text-decoration: none;
  font-size: 14px;
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  display: inline-block;
  padding-left: 8px;
}

.footer-section a::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%) scaleX(0);
  width: 4px;
  height: 4px;
  background: var(--app-primary);
  border-radius: 50%;
  transition: transform 0.3s ease;
}

.footer-section a:hover {
  color: #ffffff;
  padding-left: 16px;
}

.footer-section a:hover::before {
  transform: translateY(-50%) scaleX(1);
}

.footer-bottom {
  text-align: center;
  padding-top: 28px;
  margin-top: 32px;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
  position: relative;
  z-index: 1;
}

.footer-bottom::before {
  content: '';
  position: absolute;
  top: -1px;
  left: 50%;
  transform: translateX(-50%);
  width: 60px;
  height: 2px;
  background: linear-gradient(90deg, var(--app-primary) 0%, #8b5cf6 100%);
  border-radius: 2px;
}

.footer-bottom p {
  color: #64748b;
  font-size: 13px;
  transition: color 0.3s ease;
}

.footer-bottom p:hover {
  color: #94a3b8;
}

@media (max-width: 768px) {
  .footer-content {
    gap: 24px;
    padding: 0 16px;
  }
  
  .footer-section {
    min-width: 100%;
    text-align: center;
  }
  
  .footer-section h4 {
    padding-left: 0;
  }
  
  .footer-section h4::before {
    display: none;
  }
  
  .footer-section a {
    padding-left: 0;
  }
  
  .footer-section a:hover {
    padding-left: 8px;
  }
}
</style>
