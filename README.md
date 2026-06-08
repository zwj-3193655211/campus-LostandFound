# 校园失物招领平台

基于 Spring Boot + Vue 3 的校园失物招领智能匹配系统，支持寻物启示和失物招领的智能匹配。

## 功能特性

### 用户端
- 用户注册和登录（支持邮箱验证）
- 发布寻物启示/失物招领（支持图片上传）
- 关键词搜索和分类筛选
- 智能匹配推荐（支持串号精确匹配）
- 实名认证
- 站内通知和邮件提醒
- 个人中心管理

### 管理端
- 用户管理（启用/禁用账号）
- 物品审核（发布前审核机制）
- 位置区域管理
- 实名认证审核
- 完成申请审核
- 数据统计看板

## 技术栈

### 后端
- Spring Boot 3.2 + JDK 21
- MyBatis-Plus 3.5
- Sa-Token + Spring Security + JWT
- MySQL 8.0
- Redis（Token 存储和缓存）
- JavaMail（163 SMTP 邮件通知）

### 前端
- Vue 3 + Composition API + TypeScript
- Vite 5（构建工具）
- Pinia 状态管理
- Vue Router 4
- Element Plus UI
- Axios（HTTP 客户端）

## 项目结构

```
校园失物招领平台/
├── backend/                    # 后端 Spring Boot 项目
│   └── src/main/java/com/campus/lostfound/
│       ├── common/            # 公共模块（常量、结果、异常、工具）
│       ├── config/            # 配置模块（CORS、Redis、MyBatis、Sa-Token、邮件等）
│       ├── security/          # 安全模块（认证过滤器、权限配置）
│       ├── user/              # 用户模块（登录注册、个人中心、邮箱验证）
│       ├── item/              # 物品模块（CRUD、审核、图片上传）
│       ├── match/             # 匹配模块（智能匹配引擎、评分算法）
│       ├── notification/      # 通知模块（站内通知、邮件发送）
│       ├── statistics/        # 统计模块（公开统计、管理统计）
│       └── system/            # 系统模块（管理员功能）
├── frontend/                   # 前端 Vue 3 项目
│   └── src/
│       ├── views/             # 页面视图（13个页面）
│       ├── components/        # 通用组件
│       ├── stores/           # Pinia 状态管理
│       ├── router/           # 路由配置
│       └── utils/            # 工具函数
├── docs/                      # 项目文档
│   ├── sql/                   # 数据库脚本
│   └── 项目图表.md            # 架构图、时序图、状态机
└── README.md
```

## 快速开始

### 环境要求
- JDK 21+
- Node.js 18+
- MySQL 8.0+
- Redis 6+

### 后端启动

1. 配置数据库连接（修改 `application.yml`）
2. 确保 MySQL 和 Redis 服务运行中
3. 执行数据库脚本：
   ```bash
   # 创建数据库和表结构
   mysql -u root -p < docs/sql/schema.sql

   # 初始化测试数据
   mysql -u root -p < docs/sql/data.sql
   ```
4. 启动后端：
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

### 访问地址

| 服务 | 地址 |
|------|------|
| 前端首页 | http://localhost:5173 |
| 后端 API | http://localhost:18090 |
| API 文档 | http://localhost:18090/swagger-ui.html |

### 测试账号

| 用户名 | 密码 | 邮箱 | 角色 |
|--------|------|------|------|
| superadmin | 123456 | superadmin@campus.edu | 超级管理员 |
| campusadmin | 123456 | campusadmin@campus.edu | 校园管理员 |
| testuser | 123456 | testuser@campus.edu | 普通用户 |
| zhangsan | 123456 | zhangsan@campus.edu | 普通用户 |
| lisi | 123456 | lisi@campus.edu | 普通用户 |

## API 接口

### 认证接口
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/auth/login | 用户登录 |
| POST | /api/auth/register | 用户注册 |
| POST | /api/auth/logout | 退出登录 |
| POST | /api/auth/refresh | 刷新 Token |

### 物品接口
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/items | 获取物品列表 |
| GET | /api/items/{id} | 获取物品详情 |
| POST | /api/items | 发布物品 |
| PUT | /api/items/{id} | 更新物品 |
| DELETE | /api/items/{id} | 删除物品 |
| POST | /api/admin/items/{id}/review | 审核物品 |

### 匹配接口
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/matches | 获取匹配列表 |
| POST | /api/matches/{id}/confirm | 确认匹配 |
| POST | /api/matches/{id}/reject | 拒绝匹配 |

### 通知接口
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/notifications | 获取通知列表 |
| PUT | /api/notifications/{id}/read | 标记已读 |

## 智能匹配算法

系统支持两种匹配模式：

1. **串号精确匹配**：通过证件号、序列号等唯一标识进行精确匹配
2. **加权相似度匹配**：基于多维度加权评分：
   - 文本描述相似度 (35%)
   - 物品类别 (25%)
   - 位置距离 (15%)
   - 品牌型号 (10%)
   - 时间接近度 (10%)
   - 颜色外观 (5%)

## 配置说明

主要配置文件位于 `backend/src/main/resources/`：

| 文件 | 说明 |
|------|------|
| application.yml | 主配置文件 |
| application-dev.yml | 开发环境配置 |
| application-prod.yml | 生产环境配置 |

关键配置项：
- `server.port`: 后端服务端口（默认 18090）
- `spring.datasource.url`: MySQL 连接地址
- `spring.redis.*`: Redis 连接配置
- `spring.mail.*`: 邮件服务配置
- `sa-token.*`: Sa-Token 和 JWT 配置

## 开发指南

### 前端开发
```bash
# 安装依赖
npm install

# 开发模式（热重载）
npm run dev

# 类型检查
npm run type-check

# 构建生产版本
npm run build
```

### 后端开发
```bash
# 编译打包
mvn clean package

# 运行测试
mvn test

# 跳过测试打包
mvn clean package -DskipTests
```

## 相关文档

- [项目图表](./docs/项目图表.md) - 包含架构图、时序图、状态机等 UML 图表
- [数据库脚本](./docs/sql/) - 包含建表脚本和初始化数据

## License

MIT License
