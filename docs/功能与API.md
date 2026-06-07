# 功能与API

## 1. 功能模块

### 1.1 用户角色

| 角色 | 说明 |
|------|------|
| SUPER_ADMIN | 超级管理员，拥有全部权限 |
| CAMPUS_ADMIN | 校园管理员，管理指定范围 |
| USER | 普通用户，使用基本功能 |

### 1.2 功能清单

#### 用户认证模块
| 功能 | 描述 |
|------|------|
| 用户注册 | 注册账号 |
| 用户登录 | 账号密码登录 |
| 找回密码 | 通过邮箱找回 |
| 实名认证 | 身份证号认证（用于证件匹配） |

#### 物品管理模块
| 功能 | 描述 |
|------|------|
| 发布寻物启示 | 填写物品信息，发布丢失信息 |
| 发布失物招领 | 填写物品信息，发布招领信息 |
| 物品列表查询 | 分页查询，支持筛选 |
| 物品详情查看 | 查看物品详细信息 |
| 物品编辑/删除 | 修改或删除待审核物品 |

#### 智能匹配模块
| 功能 | 描述 |
|------|------|
| 自动匹配 | 系统自动匹配 LOST 与 FOUND 物品 |
| 匹配推荐 | 向用户推荐匹配度高的物品 |
| 匹配确认/拒绝 | 用户确认或拒绝匹配结果 |

#### 通知模块
| 功能 | 描述 |
|------|------|
| 站内通知 | 系统消息推送 |
| 邮件通知 | 重要消息邮件提醒 |
| 通知设置 | 设置通知偏好 |

#### 管理后台
| 功能 | 描述 |
|------|------|
| 用户管理 | 查看、禁用、启用用户 |
| 物品审核 | 审核发布的物品 |
| 位置管理 | 管理校园位置 |
| 数据统计 | 查看统计报表 |

---

## 2. API 接口

### 2.1 认证接口

| 接口 | 方法 | 说明 | 权限 |
|------|------|------|------|
| `/api/auth/send-register-code` | POST | 发送注册验证码(60s 冷却) | 公开 |
| `/api/auth/register` | POST | 用户注册(`code` 字段 ON 模式必填) | 公开 |
| `/api/auth/login` | POST | 用户登录 | 公开 |
| `/api/auth/refresh` | POST | 刷新Token | 已登录 |

> 验证码注册端点的请求/响应/Redis Key/开关等完整说明见 [§2.7 邮箱验证码接口](#27-邮箱验证码接口)。

**登录请求**：
```json
{
  "username": "string",
  "password": "string"
}
```

**登录响应**：
```json
{
  "code": 200,
  "data": {
    "token": "JWT Token",
    "accessToken": "JWT Token",
    "refreshToken": "刷新令牌",
    "user": {
      "id": 1,
      "username": "string",
      "email": "string",
      "role": "USER"
    }
  }
}
```

### 2.2 物品接口

| 接口 | 方法 | 说明 | 权限 |
|------|------|------|------|
| `GET /api/items` | GET | 物品列表 | 公开 |
| `GET /api/items/{id}` | GET | 物品详情 | 公开 |
| `POST /api/items` | POST | 发布物品 | 已登录 |
| `PUT /api/items/{id}` | PUT | 修改物品 | 物品所有者 |
| `DELETE /api/items/{id}` | DELETE | 删除物品 | 物品所有者 |
| `GET /api/items/my` | GET | 我的物品 | 已登录 |

**发布物品请求**：
```json
{
  "type": "LOST/FOUND",
  "category": "电子产品",
  "title": "标题",
  "description": "详细描述",
  "brand": "品牌",
  "color": "颜色",
  "location": "位置",
  "lostTime": "2026-05-29T10:00:00",
  "images": ["url1", "url2"]
}
```

**搜索参数**：
| 参数 | 类型 | 说明 |
|------|------|------|
| type | string | LOST 或 FOUND |
| category | string | 物品类别 |
| keyword | string | 搜索关键词 |
| locationId | long | 位置ID |
| page | int | 页码 |
| pageSize | int | 每页数量 |

### 2.3 匹配接口

| 接口 | 方法 | 说明 | 权限 |
|------|------|------|------|
| `GET /api/matches` | GET | 匹配列表 | 已登录 |
| `POST /api/matches/{id}/confirm` | POST | 确认匹配 | 物品所有者 |
| `POST /api/matches/{id}/reject` | POST | 拒绝匹配 | 物品所有者 |

### 2.4 通知接口

| 接口 | 方法 | 说明 | 权限 |
|------|------|------|------|
| `GET /api/notifications` | GET | 通知列表 | 已登录 |
| `GET /api/notifications/unread-count` | GET | 未读数量 | 已登录 |
| `POST /api/notifications/{id}/read` | POST | 标记已读 | 已登录 |

### 2.5 管理接口

| 接口 | 方法 | 说明 | 权限 |
|------|------|------|------|
| `GET /api/admin/users` | GET | 用户列表 | ADMIN |
| `PUT /api/admin/users/{id}/status` | PUT | 禁用/启用用户 | ADMIN |
| `GET /api/admin/items/pending` | GET | 待审核物品 | ADMIN |
| `PUT /api/admin/items/{id}/review` | PUT | 审核物品(approved+reason) | ADMIN |
| `GET /api/admin/statistics` | GET | 统计数据 | ADMIN |
| `POST /api/admin/users/{id}/role` | POST | 修改用户角色 | SUPER_ADMIN |

### 2.6 管理员物品审核接口

| 接口 | 方法 | 说明 | 权限 |
|------|------|------|------|
| `GET /api/admin/items/pending` | GET | 列出全部待审核物品 | ADMIN |
| `GET /api/admin/items` | GET | 分页查物品(支持 `status` 过滤) | ADMIN |
| `PUT /api/admin/items/{id}/review` | PUT | 审核物品,body `{approved, reason}` | ADMIN |

**审核请求**:
```json
{
  "approved": true,
  "reason": "拒绝时必填,不超过 500 字"
}
```

**审核行为**:
- `approved=true` → 状态置 `APPROVED`,自动触发匹配,向发布者发"审核通过"站内通知+邮件
- `approved=false` → 状态置 `REJECTED`,必填 `reason`,向发布者发"审核拒绝"通知(带原因)
- 状态机门禁:仅 `PENDING` 物品可被审核;重复审核返回 400
- 并发安全:按 `id+status=PENDING` 条件原子更新,双管理员同时审核仅一人成功

### 2.7 邮箱验证码接口

| 接口 | 方法 | 说明 | 权限 |
|------|------|------|------|
| `POST /api/auth/send-register-code` | POST | 发送注册验证码(60s 冷却) | 公开 |
| `POST /api/auth/register` | POST | 注册(可带 `code` 字段) | 公开 |

**发送验证码请求**:
```json
{ "email": "user@example.com" }
```

**发送验证码响应**:
```json
{ "code": 200, "message": "验证码已发送,请查收邮箱", "data": "true" }
```

- `data="true"` 表示已发送;`data="false"` 表示冷却中(消息:"验证码发送过于频繁,请稍后再试")
- 验证码 5 分钟 TTL,Redis key:`auth:email-code:register:{email}`
- 冷却 60 秒,Redis key:`auth:email-cooldown:register:{email}`
- 5 次错误锁定 10 分钟(Redis key:`auth:email-lock:register:{email}`)

**注册请求(可选 `code`)**:
```json
{
  "username": "zhangsan",
  "password": "123456",
  "email": "zhangsan@example.com",
  "code": "123456",
  "studentId": "2024001",
  "phone": "13800000000"
}
```

**开关控制**(环境变量,默认 OFF):
- `APP_AUTH_EMAIL_VERIFICATION_REQUIRED=*** 时强制校验验证码(上线生产)
- 默认 OFF 时 `code` 字段可选,带错码会放行(测试环境)

### 2.8 位置接口

| 接口 | 方法 | 说明 | 权限 |
|------|------|------|------|
| `GET /api/locations` | GET | 位置列表 | 公开 |
| `POST /api/locations` | POST | 添加位置 | ADMIN |
| `PUT /api/locations/{id}` | PUT | 修改位置 | ADMIN |
| `DELETE /api/locations/{id}` | DELETE | 删除位置 | ADMIN |

---

## 3. 物品状态流转

```
PENDING → APPROVED（审核通过）
PENDING → REJECTED（审核拒绝）
APPROVED → FOUND_BACK（寻物已找到）
APPROVED → RETURNED（招领已归还）
APPROVED → EXPIRED（已过期）
APPROVED → CLOSED（已关闭）
```

## 4. 匹配状态流转

```
PENDING → CONFIRMED（确认匹配）
PENDING → REJECTED（拒绝匹配）
```

---

## 5. 注意事项

1. **实名认证**：可选能力，不阻塞普通操作
2. **物品审核**：发布后需管理员审核才能显示
3. **匹配通知**：高匹配度结果会自动发送邮件通知
4. **敏感信息**：身份证号等在返回时会脱敏处理
