# 功能与API

## 1. 功能模块

### 1.1 用户角色

| 角色 | 说明 |
|------|------|
| SUPER_ADMIN | 超级管理员，拥有全部权限 |
| CAMPUS_ADMIN | 校园管理员，管理物品审核、统计等 |
| USER | 普通用户，使用基本功能 |

### 1.2 功能清单

#### 用户认证模块
| 功能 | 描述 |
|------|------|
| 用户注册 | 注册账号（可选邮箱验证码） |
| 用户登录 | 账号密码登录 |
| 邮箱验证码 | 注册前发送邮箱验证码（60s冷却） |
| 刷新Token | Token过期自动刷新 |
| 修改密码 | 登录后修改密码 |
| 用户注销 | 退出登录 |

#### 用户中心模块
| 功能 | 描述 |
|------|------|
| 获取个人资料 | 获取当前登录用户信息 |
| 更新个人资料 | 修改邮箱、手机号等 |
| 实名认证 | 提交身份证号进行实名认证 |
| 通知设置 | 配置站内通知/邮件通知开关 |
| 检查登录状态 | 确认当前用户是否登录 |

#### 物品管理模块
| 功能 | 描述 |
|------|------|
| 发布寻物启事 | 填写物品信息，发布丢失信息 |
| 发布失物招领 | 填写物品信息，发布招领信息 |
| 物品列表查询 | 分页查询，支持筛选（类型、类别、关键词、位置） |
| 物品详情查看 | 查看物品详细信息，浏览量+1 |
| 我的物品 | 查看自己发布的物品列表 |
| 物品编辑/删除 | 修改或删除待审核物品 |
| 物品图片上传 | 上传物品图片 |
| 提交完成申请 | 物品找到/归还后申请完成状态 |

#### 智能匹配模块
| 功能 | 描述 |
|------|------|
| 自动匹配 | 系统自动匹配 LOST 与 FOUND 物品 |
| 匹配列表 | 查看物品的匹配结果（按得分排序） |
| 最近匹配 | 查看最近的匹配记录 |
| 匹配确认 | 用户确认匹配成功 |
| 匹配拒绝 | 用户拒绝匹配结果 |
| 手动触发匹配 | 管理员手动触发匹配（调试） |
| 批量匹配 | 管理员批量匹配所有物品 |

#### 通知模块
| 功能 | 描述 |
|------|------|
| 站内通知 | 系统消息推送（匹配、审核、完成等） |
| 通知列表 | 分页查看通知列表 |
| 未读数量 | 获取未读通知数量 |
| 标记已读 | 将单条通知标记为已读 |
| 全部标记已读 | 将所有通知标记为已读 |
| 邮件通知 | 重要消息邮件提醒（匹配通知等） |
| 测试邮件 | 管理员发送测试邮件 |

#### 管理后台
| 功能 | 描述 |
|------|------|
| 用户管理 | 查看、禁用、启用、修改用户角色 |
| 物品审核 | 审核发布的物品（通过/拒绝） |
| 实名认证审核 | 审核用户提交的实名认证申请 |
| 完成申请审核 | 审核物品完成状态申请 |
| 数据统计 | 查看仪表盘、今日统计、时段统计、热门类别 |

---

## 2. API 接口总览

### 2.1 认证接口（公开）

| 接口 | 方法 | 说明 | 权限 |
|------|------|------|------|
| `/api/auth/send-register-code` | POST | 发送注册验证码（60s冷却，检查邮箱已注册） | 公开 |
| `/api/auth/register` | POST | 用户注册（`code` 字段可选，由开关控制） | 公开 |
| `/api/auth/login` | POST | 用户登录 | 公开 |
| `/api/auth/refresh` | POST | 刷新Token | 已登录 |

**发送注册验证码**：
```json
POST /api/auth/send-register-code
Body: { "email": "user@example.com" }

Response: { "code": 200, "message": "验证码已发送,请查收邮箱", "data": "true" }
// 冷却时: { "code": 200, "message": "验证码发送过于频繁,请稍后再试", "data": "false" }
```

**登录请求**：
```json
POST /api/auth/login
Body: { "username": "string", "password": "string" }

Response: {
  "code": 200,
  "data": {
    "token": "Sa-Token JWT",
    "accessToken": "Sa-Token JWT",
    "refreshToken": "refresh token",
    "user": { "id": 1, "username": "string", "email": "string", "role": "USER" }
  }
}
```

**前端使用方式**：后续请求需在 Header 中携带 `Authorization: Bearer <token>`

---

### 2.2 用户接口（需登录）

| 接口 | 方法 | 说明 | 权限 |
|------|------|------|------|
| `/api/users/profile` | GET | 获取当前用户信息 | 已登录 |
| `/api/users/profile` | PUT | 更新用户信息 | 已登录 |
| `/api/users/verify` | POST | 提交实名认证 | 已登录 |
| `/api/users/change-password` | POST | 修改密码 | 已登录 |
| `/api/users/notification-settings` | PUT | 更新通知设置 | 已登录 |
| `/api/users/logout` | POST | 用户注销 | 已登录 |
| `/api/users/is-login` | GET | 检查登录状态 | 已登录 |

**更新通知设置**：
```json
PUT /api/users/notification-settings
Body: { "notificationInApp": true, "notificationEmail": true, "notificationMatch": true, "notificationVerification": true }
```

---

### 2.3 物品接口

| 接口 | 方法 | 说明 | 权限 |
|------|------|------|------|
| `GET /api/items` | GET | 物品列表（公开查询） | 公开 |
| `GET /api/items/{id}` | GET | 物品详情（浏览量+1） | 公开 |
| `POST /api/items` | POST | 发布物品 | 已登录 |
| `PUT /api/items/{id}` | PUT | 修改物品 | 物品所有者 |
| `DELETE /api/items/{id}` | DELETE | 删除物品 | 物品所有者 |
| `GET /api/items/my` | GET | 我的物品列表 | 已登录 |
| `POST /api/items/{id}/completion-request` | POST | 提交完成申请（找到/归还） | 已登录 |
| `POST /api/uploads/images` | POST | 上传物品图片 | 已登录 |

**查询参数**：
| 参数 | 类型 | 说明 |
|------|------|------|
| type | string | LOST 或 FOUND |
| category | string | 物品类别 |
| keyword | string | 搜索关键词（标题/描述） |
| locationId | long | 位置ID |
| status | string | 物品状态（APPROVED/PENDING等） |
| page | int | 页码，默认1 |
| pageSize | int | 每页数量，默认10 |

**发布物品请求**：
```json
{
  "type": "LOST",
  "category": "电子产品",
  "title": "丢失的手机",
  "description": "详细描述丢失情况",
  "brand": "品牌",
  "color": "颜色",
  "locationId": 1,
  "location": "详细位置描述",
  "lostTime": "2026-05-29T10:00:00",
  "serialNumber": "可选序列号",
  "contactInfo": "联系方式",
  "images": ["url1", "url2"]
}
```

---

### 2.4 位置接口

| 接口 | 方法 | 说明 | 权限 |
|------|------|------|------|
| `GET /api/locations` | GET | 所有位置列表（带 Redis 缓存） | 公开 |
| `GET /api/locations/{id}` | GET | 位置详情 | 公开 |
| `POST /api/locations` | POST | 新增位置 | 管理员 |
| `PUT /api/locations/{id}` | PUT | 修改位置 | 管理员 |
| `DELETE /api/locations/{id}` | DELETE | 删除位置（有关联物品时禁止） | 管理员 |

**说明**：GET 请求对外公开，POST/PUT/DELETE 需 CAMPUS_ADMIN 或 SUPER_ADMIN 角色。

---

### 2.5 匹配接口

| 接口 | 方法 | 说明 | 权限 |
|------|------|------|------|
| `GET /api/matches` | GET | 匹配列表（管理员看全部，用户看自己） | 已登录 |
| `GET /api/matches/recent` | GET | 最近匹配列表 | 已登录 |
| `PUT /api/matches/{id}/confirm` | PUT | 确认匹配 | 物品所有者 |
| `PUT /api/matches/{id}/reject` | PUT | 拒绝匹配（reason必填） | 物品所有者 |
| `POST /api/matches/trigger` | POST | 触发匹配（调试用） | 管理员 |
| `POST /api/matches/batch` | POST | 批量匹配所有物品 | 管理员 |
| `GET /api/matches/test` | GET | 测试端点 | 管理员 |

**拒绝匹配**：
```
PUT /api/matches/{id}/reject?reason=物品不符
```

---

### 2.6 通知接口

| 接口 | 方法 | 说明 | 权限 |
|------|------|------|------|
| `GET /api/notifications` | GET | 通知列表（分页） | 已登录 |
| `GET /api/notifications/unread-count` | GET | 未读通知数量 | 已登录 |
| `POST /api/notifications/{id}/read` | POST | 标记单条通知已读 | 已登录 |
| `POST /api/notifications/read-all` | POST | 全部标记为已读 | 已登录 |
| `POST /api/notifications/send-test-email` | POST | 发送测试邮件 | 管理员 |
| `POST /api/notifications/send-match-email` | POST | 直接发送匹配通知邮件 | 管理员 |

---

### 2.6 管理接口（管理员/SUPER_ADMIN）

#### 用户管理 `/api/admin/users`

| 接口 | 方法 | 说明 |
|------|------|------|
| `GET /api/admin/users` | GET | 用户列表（keyword/role/status/verified 筛选，分页） |
| `PUT /api/admin/users/{id}` | PUT | 修改用户邮箱/手机号 |
| `PUT /api/admin/users/{id}/role` | PUT | 修改用户角色 |
| `PUT /api/admin/users/{id}/status` | PUT | 禁用/启用用户 |
| `DELETE /api/admin/users/{id}` | DELETE | 删除用户（逻辑删除） |

#### 物品审核 `/api/admin/items`

| 接口 | 方法 | 说明 |
|------|------|------|
| `GET /api/admin/items/pending` | GET | 待审核物品列表 |
| `GET /api/admin/items` | GET | 分页查询（status 过滤） |
| `PUT /api/admin/items/{id}/review` | PUT | 审核物品 |

**审核请求**:
```json
{ "approved": true, "reason": "拒绝原因（拒绝时必填）" }
```

#### 实名认证审核 `/api/admin/identity-verifications`

| 接口 | 方法 | 说明 |
|------|------|------|
| `GET /api/admin/identity-verifications` | GET | 待审核实名申请列表 |
| `GET /api/admin/identity-verifications/history` | GET | 审核历史记录 |
| `PUT /api/admin/identity-verifications/{id}/review` | PUT | 审核实名认证 |

**审核**:
```
PUT /api/admin/identity-verifications/{id}/review?approved=true&reason=资料完整
```

#### 完成申请审核 `/api/admin/completion-requests`

| 接口 | 方法 | 说明 |
|------|------|------|
| `GET /api/admin/completion-requests` | GET | 待审核完成申请列表 |
| `PUT /api/admin/completion-requests/{id}/review` | PUT | 审核完成申请 |

#### 统计接口 `/api/admin/statistics`

| 接口 | 方法 | 说明 |
|------|------|------|
| `GET /api/admin/statistics/dashboard` | GET | 仪表盘统计数据 |
| `GET /api/admin/statistics/today` | GET | 今日统计 |
| `GET /api/admin/statistics/period?startDate=xxx&endDate=xxx` | GET | 时间段统计 |
| `GET /api/admin/statistics/categories` | GET | 热门类别统计 |
| `GET /api/admin/statistics/locations` | GET | 热门位置统计 |

#### 公开统计接口 `/api/statistics`（无需登录）

| 接口 | 方法 | 说明 |
|------|------|------|
| `GET /api/statistics/overview` | GET | 首页概览统计（总物品数、匹配数等） |
| `GET /api/statistics/categories` | GET | 类别分布统计 |

---

## 3. 统一响应格式

所有接口统一返回格式：
```json
{
  "code": 200,           // 200成功，其他为错误码
  "message": "成功",     // 提示信息
  "data": { ... }        // 返回数据（可能是对象、数组或null）
}
```

**错误响应**：
```json
{
  "code": 401,
  "message": "未登录或登录已过期"
}
```

**常见HTTP状态码**：
- 400 - 参数错误/业务异常
- 401 - 未登录/Token无效
- 403 - 无权限访问
- 404 - 资源不存在
- 500 - 服务器内部错误

---

## 4. 物品状态流转

```
PENDING → APPROVED（审核通过）   → FOUND_BACK（寻物找到，通过完成申请）
                            ↘     → RETURNED（招领归还，通过完成申请）
                            ↘     → EXPIRED（已过期）
                            ↘     → CLOSED（管理员关闭）
        → REJECTED（审核拒绝）
```

---

## 5. 匹配状态流转

```
PENDING → CONFIRMED（确认匹配）
       → REJECTED（拒绝匹配）
```

---

## 6. 注意事项

1. **物品审核**：发布后需管理员审核才能公开展示
2. **匹配通知**：高匹配度结果会自动发送站内通知+邮件通知
3. **敏感信息**：身份证号、联系方式在返回时会脱敏处理
4. **图文验证码开关**：邮箱验证码验证由环境变量控制（默认关闭，测试环境可跳过）
5. **Token传递**：所有需登录接口必须在 HTTP Header 中携带 `Authorization: Bearer <token>`
6. **Sa-Token认证**：系统使用 Sa-Token + Spring Security 桥接，通过 JWT Token 进行身份验证
7. **角色鉴权**：普通用户仅能操作自己的物品/数据，管理员可操作所有数据
