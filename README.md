# 校园失物招领平台

基于 Spring Boot + Vue 3 的校园失物招领系统，支持寻物启示和失物招领的智能匹配。

## 功能特性

### 用户端
- 用户注册和登录
- 发布寻物启示/失物招领
- 关键词搜索和筛选
- 智能匹配推荐
- 实名认证
- 消息通知

### 管理端
- 用户管理
- 物品审核
- 数据统计
- 身份认证管理

## 技术栈

### 后端
- Spring Boot 3.2
- MyBatis-Plus
- Spring Security + JWT
- MySQL

### 前端
- Vue 3 + Composition API
- Pinia 状态管理
- Element Plus UI
- Axios

## 快速开始

### 后端启动
```bash
cd backend
mvn spring-boot:run
```

### 前端启动
```bash
cd frontend
npm install
npm run dev
```

### 测试账号
| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | admin123 | 超级管理员 |

## API 文档
启动后访问: http://localhost:8081/swagger-ui.html
