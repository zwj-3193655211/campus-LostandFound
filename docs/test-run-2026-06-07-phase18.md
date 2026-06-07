# 校园失物招领平台 - 第十八轮 端到端验收报告

> 测试日期: 2026-06-07
> 测试环境: Windows 11 / JDK 21.0.8 / MySQL 8.4.5 / Redis 7 / Node 23.9 / Maven 3.9.11
> 测试范围: ① 管理员物品审核接口 ② 邮箱验证码注册前端 ③ 数据库脏数据清理
> 关联 phase: 第十八轮 (沿用 16 轮续号,与 docs/sql/phase17_email_unique.sql 配套)

---

## 0. 本轮工作总览

| 类别 | 任务 | 状态 |
|---|---|---|
| 缺陷修复 | PUT /api/admin/items/{id}/review 接口缺失(原 Swagger 中声称有但未实现,导致物品永远卡 PENDING) | ✅ 已补 |
| 缺陷修复 | 前端 verifyItem 调旧的 /approve 与 /reject 端点(均不存在) | ✅ 已改为 /review |
| 缺陷修复 | 邮箱查重失效(只防新增、不清历史脏数据) | ✅ 已清库 |
| 新增功能 | 邮箱验证码注册后端 + 前端 UI(开关可切 ON/OFF) | ✅ 已上线 |
| 工具 | ItemServiceImplTest 单元测试(6 用例) | ✅ 已补 |
| 文档 | docs/功能与API.md 修正(POST→PUT) | ✅ 已修 |
| 文档 | docs/testing-and-quality.md 基线 49→64 | ✅ 已更新 |

---

## 1. 启动环境

| 组件 | 路径 | 状态 |
|------|------|------|
| JDK | D:/JDK/jdk_21 | ✅ 21.0.8 LTS |
| MySQL | C:/Program Files/MySQL/MySQL Server 8.4 | ✅ 8.4.5, 监听 3306 |
| Redis | D:/Redis/redis-server.exe | ✅ 7.x, 监听 6379 |
| Maven | D:/apache-maven-3.9.11 | ✅ 3.9.11 |
| Node | D:/tools/node/node-v23.9.0-win-x64 | ✅ 23.9.0 |

数据库 campus_lostfound 经脏数据清理后,当前活跃账号 7 个,物品 6 条 demo,
字段 users.email_active 虚拟生成列已加唯一索引 uk_users_email_active。

---

## 2. 后端变更明细

### 2.1 新增文件

| 文件 | 字节 | 作用 |
|---|---|---|
| common/dto/request/ItemReviewRequest.java | 538 | 审核请求体 {approved, reason} |
| modules/item/controller/AdminItemReviewController.java | 3,294 | 管理员审核接口控制器 |
| test/.../ItemServiceImplTest.java | 7,861 | 6 个审核单元测试 |

### 2.2 修改文件

| 文件 | 变更 | 影响 |
|---|---|---|
| modules/item/service/ItemService.java | +3 方法接口 | 编译期约束 |
| modules/item/service/impl/ItemServiceImpl.java | +3 方法实现 + 修 count | 状态机门禁 + 并发安全 + 分页一致 |
| frontend/src/stores/user.js | +sendRegisterCode | 验证码注册前端联通 |
| frontend/src/stores/item.js | verifyItem 改用 /review | AdminDashboard 通过/拒绝按钮联通 |
| frontend/src/components/RegisterModal.vue | 重写:加验证码 UI + 60s 倒计时 | 上线即用 |
| docs/功能与API.md | 修正 POST→PUT,新增 2.6/2.7 节 | API 文档与实现一致 |
| docs/testing-and-quality.md | 基线 49→64 | 测试覆盖率与现实一致 |
| docs/sql/phase17_email_unique.sql | 升级为可重复执行的清理+约束一体化脚本 | 已有,可重复执行 |

---

## 3. 关键 API 端点(全部 200 实测)

### 3.1 管理员物品审核(本轮新增)

| 接口 | 方法 | 说明 | 权限 |
|---|---|---|---|
| GET /api/admin/items/pending | GET | 列出全部待审核物品 | ADMIN |
| GET /api/admin/items?status=...&page=1&pageSize=20 | GET | 分页查物品 | ADMIN |
| PUT /api/admin/items/{id}/review | PUT | 审核物品 body {approved, reason} | ADMIN |

审核请求:
```json
{ "approved": false, "reason": "信息不够详细" }
```

审核响应:
```json
{
  "code": 200,
  "message": "审核拒绝",
  "data": { "id": 30, "status": "REJECTED" }
}
```

设计要点:
- 并发安全:UPDATE items SET status=? WHERE id=? AND status='PENDING',影响行数=0 表示已被其他管理员审核
- 状态机门禁:仅 PENDING 物品可被审核,重复审核返回 400
- 拒绝原因必填:reason 字段在 approved=false 时必填,空白 → 400
- 副作用:通过 → 自动触发 MatchingService.match(itemId);拒绝/通过 → 调用 NotificationService.notifyVerificationResult(...),通知异常不影响主流程
- 分页一致性:adminListByStatus 用手动 subList 分页,绕开 MyBatis-Plus 软删除 + selectPage count 查询的 count=0 坑

### 3.2 邮箱验证码(本轮新增 + 改进)

| 接口 | 方法 | 说明 | 权限 |
|---|---|---|---|
| POST /api/auth/send-register-code | POST | 发送注册验证码 | 公开 |
| POST /api/auth/register | POST | 注册(可带 code) | 公开 |

发送验证码响应:
- 成功:{code:200, message:验证码已发送,请查收邮箱, data:"true"}
- 冷却:{code:200, message:验证码发送过于频繁,请稍后再试, data:"false"} (HTTP 仍 200,前端用 data 判定)

Redis Key 设计:
- auth:email-code:register:{email} → 6 位数字,5 分钟 TTL
- auth:email-cooldown:register:{email} → 60 秒 TTL(冷却)
- auth:email-lock:register:{email} → 5 次错误后 10 分钟锁定

开关控制(环境变量,默认 OFF):
- APP_AUTH_EMAIL_VERIFICATION_REQUIRED=true 时强制校验(生产)
- 默认 OFF → code 可选,带错码会放行(测试环境)

---

## 4. 端到端 E2E 测试用例

### 4.1 管理员物品审核 12 用例(全部通过)

| # | 场景 | 期望 | 实际 |
|---|------|------|------|
| T1 | 普通用户 GET /api/admin/items/pending | 403 | 403 ✅ |
| T2 | superadmin GET 待审核列表 | 200 + 2 条 PENDING | 200,items #27 #30 ✅ |
| T3 | 拒绝审核但不带 reason | 400 拒绝原因不能为空 | 400 ✅ |
| T4 | 拒绝审核带 reason | 200, status=REJECTED | 200 ✅ |
| T5 | 重复审核已 REJECTED 物品 | 400 仅待审核物品可被审核 | 400 ✅ |
| T6 | 审核通过 | 200, status=APPROVED, 触发匹配,通知 +1 | 全部生效 ✅ |
| T7 | GET /api/admin/items?status=APPROVED 分页 | 200, total=6 records=5 | 200 ✅ |
| T8 | Swagger 列出 /api/admin/items/{id}/review | 存在 | ✅ |
| T9 | campusadmin 也能审核 | 200 | 200 ✅ |
| T10 | 完整 E2E:发布→审核→通知 | user_qq 收到审核通过通知 | ✅ |
| T11 | 单元测试 6 用例 | 全部通过 | 6/6 ✅ |
| T12 | mvn test 整体 | 通过 | 64/64(2 跳过)✅ |

### 4.2 邮箱验证码注册 OFF 模式 11 用例(全部通过)

OFF 模式:code 字段可选,带错码会放行(测试环境用)

| # | 场景 | 期望 | 实际 |
|---|------|------|------|
| F1 | 发送验证码 | 200, data=true | ✅ |
| F2 | 立即重发 → 冷却 | 200, data=false | ✅ |
| F3 | 从 Redis 取出 6 位数字 | 是 | ✅ |
| F4 | 带正确 code 注册 | 200 | ✅ |
| F5 | 新用户登录 | 200 | ✅ |
| F6 | 不带 code 注册(OFF 模式允许) | 200 | ✅ |
| F7 | 错误 code 注册 | 200(放行,符合 OFF 设计) | ✅ |
| F8 | 重复邮箱注册 | 400 邮箱已被注册 | ✅ |
| F9 | 大写邮箱 → 归一化注册 | 200 | ✅ |
| F10 | 同邮箱(小写)被拒 | 400 | ✅ |
| F11 | 验证码过期(Redis 删 code) | 200(放行,符合 OFF) | ✅ |

### 4.3 邮箱验证码注册 ON 模式 7 用例(全部通过)

ON 模式:APP_AUTH_EMAIL_VERIFICATION_REQUIRED=true 强制校验(生产用)

| # | 场景 | 期望 | 实际 |
|---|------|------|------|
| G1 | ON 模式不带 code | 400 请先发送并填写邮箱验证码 | ✅ |
| G2 | ON 模式带错误 code | 400 验证码已过期或未发送 | ✅ |
| G3 | ON 模式 send + 正确 code | 200 | ✅ |
| G4 | ON 模式复用已用 code | 400 | ✅ |
| G5 | ON 模式 第一个邮箱注册 | 200 | ✅ |
| G6 | ON 模式 重复邮箱 | 400 邮箱已被注册 | ✅ |
| G7 | ON 模式 重复邮箱+已用 code | 400 邮箱已被注册 | ✅ |

### 4.4 数据库脏数据清理

迁移前:19 用户 / 多个重复邮箱(test@test.com × 6、login-NNN × 6、其他临时账号)

迁移后(7 个活跃账号,7 个不同邮箱,0 重复):
```
superadmin    superadmin@campus.edu
campusadmin   campusadmin@campus.edu
testuser      testuser@campus.edu
zhangsan      zhangsan@campus.edu
lisi          lisi@campus.edu
user_ncu      8008123240@email.ncu.edu.cn
user_qq       3193655211@qq.com
```

脚本 docs/sql/phase17_email_unique.sql 可重复执行(二次执行 exit 0,所有防护 skip 正确)。

---

## 5. 自动化测试基线

| 项 | 旧 | 新 | 变化 |
|---|---|---|---|
| 后端测试数 | 49 | 64 | +15(+6 ItemServiceImplTest) |
| 后端测试文件 | 12 | 13 | +1 |
| 跳过数 | 1 | 2 | +1(testLogin 因 Sa-Token 需 WebContext) |
| 前端测试数 | 6 | 6 | 持平 |
| mvn test 退出码 | 0 | 0 | 持平 |
| npm run build 退出码 | 0 | 0 | 持平 |

```
[INFO] Tests run: 64, Failures: 0, Errors: 0, Skipped: 2
```

---

## 6. 关键文件清单

### 6.1 后端(新增/修改)
- backend/src/main/java/com/campus/lostfound/common/dto/request/ItemReviewRequest.java
- backend/src/main/java/com/campus/lostfound/modules/item/service/ItemService.java
- backend/src/main/java/com/campus/lostfound/modules/item/service/impl/ItemServiceImpl.java
- backend/src/main/java/com/campus/lostfound/modules/item/controller/AdminItemReviewController.java
- backend/src/test/java/com/campus/lostfound/modules/item/service/impl/ItemServiceImplTest.java
- backend/src/main/java/com/campus/lostfound/modules/system/service/EmailVerificationService.java(已存在)
- backend/src/main/java/com/campus/lostfound/modules/system/service/impl/EmailVerificationServiceImpl.java(已存在)

### 6.2 前端(新增/修改)
- frontend/src/stores/user.js
- frontend/src/stores/item.js
- frontend/src/components/RegisterModal.vue

### 6.3 文档(本轮更新)
- docs/功能与API.md — 修正 POST→PUT + 新增 2.6/2.7 节
- docs/testing-and-quality.md — 基线 49→64
- docs/test-run-2026-06-07-phase18.md — 本文件

---

## 7. 结论与上线 checklist

- ✅ PUT /api/admin/items/{id}/review 真实接口已上线(此前 Swagger 列出但实际不存在,导致物品永远卡 PENDING)
- ✅ 前端 AdminDashboard.vue 通过/拒绝按钮联通真实接口(此前调不存在的 /approve 与 /reject)
- ✅ 邮箱验证码注册 UI 完整接入,后端 ON/OFF 开关可控
- ✅ 数据库脏数据已清,UNIQUE 约束已加,邮箱查重应用层+DB 层双重防护
- ✅ mvn test 64/64 通过(2 跳过为已知 WebContext 限制),无回退
- ✅ E2E 测试矩阵完整覆盖 OFF 模式(11/11) + ON 模式(7/7) + 审核链路(12/12)

上线前必做:
1. 设置 APP_AUTH_EMAIL_VERIFICATION_REQUIRED=true 启用强校验
2. 清理测试账号:user_qq、user_ncu、testuser(若不想保留)
3. 删除 data.sql 中用虚假邮箱注册的种子用户,只保留 superadmin/campusadmin/testuser
4. 跑 docs/sql/phase17_email_unique.sql 加 UNIQUE 约束(已加,但生产库重跑更安全)
5. 配 SMTP:application.yml 的 spring.mail.* 用真实 QQ/163/企业邮账号
6. 浏览器实测注册 UI 走通一遍,确认 60s 倒计时和 5min 有效提示文案

已知遗留:
- 前端自动化测试仍只覆盖守卫/拦截器,登录弹窗、管理员页面、注册弹窗等关键交互未补 UI 测试
- MyBatis-Plus 软删除 + selectPage count 查询的 count=0 坑已用手动 subList 规避,但框架级修复(自定义 PaginationInnerInterceptor)未做
