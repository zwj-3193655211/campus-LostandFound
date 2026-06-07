# 校园失物招领平台 - 代码审查报告

> 审查日期: 2026-06-07
> 审查范围: 后端 (Spring Boot 3.2 + JDK 21) + 前端 (Vue 3 + Vite) + 数据库 + 部署配置
> 审查方式: 人工通读全部核心源代码,无 Lint/FindBugs/SpotBugs 自动化输出

---

## 1. 审查结论

- 项目主业务链路已经基本闭环:登录、发布、审核、智能匹配、通知、完成申请、实名认证、证件找失主均已有实现并贯通。
- 权限矩阵、JWT 链路、Redis 缓存、Spring Security + Sa-Token 双鉴权等"硬骨头"已落地,审核状态机已有原子条件更新+并发测试。
- 当前最值得投入的风险已经转向:**(1) 凭据与生产配置泄漏、 (2) 鉴权/输入校验的剩余边角、 (3) 前端自动化测试覆盖、 (4) 文档与实现的一致性**。

按严重程度排序(高 → 中 → 低)给出本轮发现与建议,所有问题均给出文件:行号 锚点,便于复核。

---

## 2. 严重问题(必须处理)

### 2.1 生产凭据泄漏到 Git 工作区

- **位置**:`backend/src/main/resources/application.yml:14`、`application.yml:42-46`
- **现象**:`datasource.password: zwj123456`、SMTP `username/password: 19721623703@163.com / SCRLKy8UaApwdSi5` 直接硬编码在 `application.yml`(实际生效文件)。
- **问题**:虽然 `.gitignore` 已忽略该文件,但**任何 clone 项目的开发者在生产目录运行都会读到真实凭据**;此外 `application-local.yml.example.yml` 是模板,二者的覆盖关系一旦搞错,生产仍可能回退到示例值。
- **建议**:
  1. `application.yml` 移除任何默认凭据,使用 `${ENV:default}` 形式强制要求环境变量。
  2. SMTP 凭据改用 **Jasypt** 或 **HashiCorp Vault** 加密存储。
  3. 凭据泄漏属 P0 事件:必须**立即轮换 163 SMTP 授权码 + 数据库密码**,并审计是否已有外泄。

### 2.2 ~~鉴权放行配置宽泛,运营风险高~~ **— 已修复(2026-06-07)**

- **位置**:`WebSecurityConfig.java:51-53`
- **原代码**:
  ```java
  .requestMatchers("/api/matches/test").permitAll()
  .requestMatchers("/api/notifications/send-test-email").permitAll()
  .requestMatchers("/api/notifications/send-match-email").permitAll()
  ```
- **风险**:`/api/notifications/send-test-email` 与 `/api/notifications/send-match-email` 是**任意邮箱触发邮件**的接口,被 `permitAll` 后任何未登录用户可作为**开放邮件中继滥用**;163 SMTP 账号可能被封、被用于发钓鱼邮件。
- **修复**:
  ```java
  .requestMatchers("/api/matches/test").hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN")
  .requestMatchers("/api/notifications/send-test-email").hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN")
  .requestMatchers("/api/notifications/send-match-email").hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN")
  ```
  同时删除原 70-71 行(POST 专属 hasRole),避免与上述规则重复。
- **业务影响验证**:`/send-test-email` 与 `/send-match-email` 是**调试用**接口,业务匹配流程走 Java 方法直接调用 `mailService.sendMatchNotificationEmail`,不经过 HTTP,**业务邮件发送不受影响**;`/api/matches/test` 仅返回字符串"系统正常运行",无敏感数据,收紧为管理员可见亦无副作用。
- **残留风险**:管理员账号泄露仍可被滥用。若进一步要求,可加 `@ConditionalOnProperty` 在生产不注册这些 Controller(方案 B)。

### 2.3 ~~CORS 允许任意来源携带凭据~~ **— 已修复(2026-06-07)**

- **位置**:`CorsConfig.java:20-29`
- **原代码**:
  ```java
  config.addAllowedOriginPattern("*");
  config.setAllowCredentials(true);
  ```
- **风险**:`*` 与 `setAllowCredentials(true)` 组合,虽然 Spring 6 在源头用 `OriginPattern` 会拦截浏览器实际发送的 `*`,但仍属于**不安全配置模式**;一旦被换回 `addAllowedOrigin("*")` 即破坏同源策略,允许任意站点带 Cookie 跨域调用 API。
- **修复**:
  - `CorsConfig.java` 改为读取 `app.cors.allowed-origins` 配置项(逗号分隔多域名);
  - 默认值 `http://localhost:3000,http://localhost:8081,http://127.0.0.1:3000`(本地开发);
  - 用 `setAllowedOrigins(...)` 替换 `addAllowedOriginPattern("*")`,从源头避免 `*` + `Allow-Credentials` 危险组合;
  - 配置为空时兜底为 `localhost:3000`,绝不退化为 `*`;
  - `application.yml` 新增 `app.cors.allowed-origins` 配置,支持 `APP_CORS_ALLOWED_ORIGINS` 环境变量注入,生产可改为实际前端域名。
- **残留风险**:若运维忘记在生产改 `app.cors.allowed-origins`,仍以 dev 默认值运行,生产前端域名被拒;建议在部署文档/启动脚本里加校验。

### 2.4 ~~`getById` 越权返回他人联系方式~~ **— 已确认不修改(产品设计决策)**

- **位置**:`ItemController.java:73-90` + `ItemController.java:140-181`
- **现象**:`toPublicItem` 中判断 `canViewSensitive = currentUser != null` —— **只要登录就返回原始 `contactInfo`、`serialNumber`(不脱敏)给任意用户**。
- **结论**:**不修改**。失物招领的核心场景是"匹配上 + 双方私聊归还",智能匹配存在漏匹配的可能,若联系方式被严格保护,失主/拾取者将无法兜底联系对方,核心价值链断裂。原代码注释已明确此意图:"所有登录用户都可以查看联系方式,这样用户之间才能相互联系"。
- **备注**:
  - `idCard` 字段位于 `User` 实体,**不在 `Item` 响应中返回**;管理员列表通过 `UserServiceImpl.sanitize` 仍走 `DataMaskUtils.maskIdCard` 脱敏。
  - 公开列表 (`ItemController.query`) 走 `toPublicItems` 分支,会脱敏 `contactInfo` 与 `serialNumber`;仅 `getById` 详情页面对登录用户展示明文,这是有意为之。
  - 如未来引入更严格的隐私要求(例如实名认证后的可见性),应仅对**未实名**用户做脱敏,而非按"非发布者即脱敏"。

---

## 3. 高风险问题

### 3.1 `application.yml` 调试日志过于详细

- **位置**:`application.yml:108-112`
  ```yaml
  logging:
    level:
      com.campus.lostfound: debug
      org.springframework.security: info
  ```
  + `mybatis-plus.configuration.log-impl: org.apache.ibatis.logging.stdout.StdOutImpl`(`application.yml:57`)会在控制台打印**完整 SQL + 参数**,含用户密码哈希、邮箱等。
- **建议**:生产改为 `info`,MyBatis 用 `slf4j` 实现并设置脱敏。

### 3.2 Sa-Token 与 JWT 重复鉴权,角色漂移风险

- **位置**:`JwtAuthenticationFilter.java:57-67` + `StpInterfaceImpl.java:34-48`
- **现象**:JWT 过滤器**每次请求都登录一次 Sa-Token**(`StpUtil.login(userId)`),并把 `user.getRole()` 写入 `SecurityContext`。这意味着:
  1. 用户角色在数据库被管理员改成 `CAMPUS_ADMIN → USER`,**当前 access token 在过期前仍被授予旧角色**;
  2. `StpInterfaceImpl#getRoleList` 又会从 DB 重新查,两套机制并存,容易出现"过滤器授予 X,注解要求 Y"的不一致。
- **建议**:统一为 Spring Security 的 `AuthorizationManager`,`@PreAuthorize` 直接走 DB 角色,删除 Sa-Token 的 `StpUtil.login`(在 JWT 模式下无意义);或保留 Sa-Token 但每次访问都重查 DB。

### 3.3 业务层大量 N+1 查询

- **位置**:`ItemServiceImpl.java:277-336` `enrichItems`
- **现象**:每条物品都要再触发 4 次 IN 查询(图片、Match、完成申请、Notification);`AdminDashboard` 同时拉 6 个聚合接口,首屏平均 4-6 次 DB round-trip。
- **建议**:
  1. `enrichItems` 改用单条 SQL + JOIN;
  2. `StatisticsServiceImpl.getDashboard` 改为单条聚合 SQL 一次取齐 9 个指标(当前是 8 次 `selectCount`);
  3. `PopularCategories` 注释里自己写"生产环境应该用 SQL GROUP BY",直接改。

### 3.4 `ItemServiceImpl.query` 中的全表扫描风险

- **位置**:`ItemServiceImpl.java:194-200`
  ```java
  wrapper.and(w -> w.like("title", kw).or().like("description", kw)
          .or().like("brand", kw).or().like("color", kw)
          .or().like("serial_number", kw).or().like("location", kw));
  ```
- **问题**:`OR` + 6 个 `LIKE '%kw%'` 在 10 万行级别即不可用,无前缀索引,会走全表扫。
- **建议**:改用 MySQL 全文索引(`FULLTEXT(title, description, brand, color, location)`),或接入 **Elasticsearch / Meilisearch**。

### 3.5 序列号字段双重语义,无校验

- **位置**:`Item.java:46` + `ItemConstants.java:60-69` + `ItemServiceImpl.java:269-275`
- **现象**:`serial_number` 同时承载"设备 IMEI/序列号"和"身份证号"双重语义;`normalizeSerialNumber` 仅做 `trim().toUpperCase()`,无格式校验。
- **风险**:
  1. `SERIAL_EXACT` 匹配在证件场景下会因大小写/空格导致漏匹配;
  2. 身份证号与设备序列号混用,**证件失主通知会因"串号精确匹配"误判物品关系**;
  3. 身份证号同时在 `users.id_card` 与 `items.serial_number` 出现,等于在两个字段冗余存储敏感数据。
- **建议**:
  1. 拆分为 `serial_number` + `id_card_hint` 两个字段;
  2. 写身份证校验函数(Luhm + 行政区划);
  3. `users.id_card` 不再冗余到 `items`,只通过 `UserIdentityVerification` 中转。

### 3.6 邮箱明文存储且可被批量抓取

- **位置**:`User.java:21` + 各类查询(全表返回 User 时 `email` 不脱敏)
- **现象**:`users.email` 是明文存储,管理员列表直接返回,`UserServiceImpl.sanitize` 只脱敏 `password` 和 `idCard`,`email` 仍在。
- **建议**:对 `email` 至少做"首字母 + *** + 域名"脱敏,或者用对称加密按需解密展示。

### 3.7 `NotifyMatchFound` 在事务内同步发邮件,延迟主流程

- **位置**:`NotificationServiceImpl.java:66-85` + `MatchingServiceImpl.java:207-212`
- **现象**:`saveMatch` 处于 `@Transactional` 内部,通知是同步 `try/catch` 包装,但 `mailService.sendMatchNotificationEmail` 内部是**SMTP 同步阻塞**(`Transport.send`,30s 超时)。
- **建议**:把邮件发送**移到事务外**或改为 `applicationEventPublisher.publishEvent` + `@Async`/`@TransactionalEventListener`;`pom.xml` 已引入 `spring-boot-starter-amqp`,可走 RabbitMQ 异步队列。

### 3.8 关键文件、依赖被删除(历史变更)

- **位置**:工作区当前已删除 `backend/src/main/java/com/campus/lostfound/config/DatabaseFixRunner.java`、`modules/system/controller/DbFixController.java`、`modules/verification/*` 等。
- **建议**:在 `docs/CHANGELOG.md` 中维护一份**模块变更日志**,记录每个模块/类被引入、删除或改名的版本,避免后续维护者 grep 不到时怀疑代码丢失。

---

## 4. 中风险问题

### 4.1 前端无 TypeScript,大量 `any`/隐式类型

- **位置**:`frontend/src` 全量 JS
- **现象**:Pinia store 中 `state`、API 响应、`route.query` 等全部以 `any` 流过,出错信息仅靠 `error?.message` 兜底。
- **建议**:至少在 `stores/*.js` 和 `utils/axios.js` 中补 JSDoc 类型;新代码考虑 `.ts` 重写。

### 4.2 前端 `localStorage` 存敏感信息

- **位置**:`stores/user.js:33-51` + `axios.js:37-46`
- **现象**:`token`、`refreshToken`、`user`(含 `idCard` 脱敏、邮箱)全部存 `localStorage`,**易被 XSS 一锅端**。
- **建议**:`accessToken` 放内存(JS 变量/Pinia state 不持久化),`refreshToken` 用 **HttpOnly Secure SameSite=Strict Cookie**;`user` 走 `/api/users/profile` 重新拉取。

### 4.3 前端 `axios` 401 重试逻辑"自我重试公开接口"

- **位置**:`utils/axios.js:60-110`
- **现象**:
  1. `clearAuth` 后**立即**对原请求**去除 Authorization 头重试一次**;
  2. 401 时**没有**先判定原始请求是否本来就是公开接口(`/api/items` GET 公开),直接重试;
  3. 重试发生在 `processQueue(null, ...)` 后,高并发下可能让多个请求都触发 refresh。
- **建议**:
  1. 重试前用 `originalRequest._isPublic` 标记;
  2. 用单例 Refresh Token 互斥(`isRefreshing` 已有,但重试回调里没把新 token 透出到所有等待者之外的请求,可能仍会单点反复触发)。

### 4.4 `Router` 守卫的角色信息不同步

- **位置**:`router/index.js:43-49`
- **现象**:角色仅在路由跳转时**从 localStorage 读**,如果管理员把当前用户角色改了,需要刷新才能看到管理菜单。
- **建议**:维护一份"当前用户角色"在 Pinia user store,守卫从 store 读,并在收到 401/403 时主动刷新。

### 4.5 测试覆盖仍有缺口

- **位置**:`docs/testing-and-quality.md` 已识别但**仍未补**的项:
  - `ItemServiceImplTest` 缺少并发匹配、`enrichItems` 的边界;
  - `MatchingEngineTest` 缺中文文本相似度的负向用例;
  - 前端未覆盖 `LoginModal`、`AdminDashboard`、`PublishItem` 三个**高价值**交互。
- **建议**:按 `docs/testing-and-quality.md` §8 的推荐补测路线继续推进。

### 4.6 性能:`vite.config.js` `ui-vendor` 仍 > 1MB

- **位置**:`frontend/vite.config.js:21-32`
- **建议**:
  1. Element Plus 改按需引入(`unplugin-vue-components` + `unplugin-auto-import`);
  2. Element Plus 图标按需 import(目前 `main.js:13-15` 全部注册到全局);
  3. Element Plus 国际化仅 `zh-cn`,砍掉其他 locale。

### 4.7 SQL 字符集与排序规则

- **位置**:`schema.sql:8` 使用 `utf8mb4_unicode_ci`,但 MySQL 8 默认更推荐 `utf8mb4_0900_ai_ci`(更准确的 Unicode 排序)。
- **建议**:统一为 `utf8mb4_0900_ai_ci`,避免后续 ETL/报表工具对排序差异的困惑。

### 4.8 `data.sql` 假 BCrypt 哈希

- **位置**:`data.sql:28-29`
  ```sql
  -- BCrypt hash for "123456": $2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5GHsJ4dI2dF7dL8d8jW/8Gq
  ```
- **现象**:实际该字符串不是合法 BCrypt(`$2a$10$` 后只有 53 字符,BCrypt 应是 60 字符),`data.sql` 直接执行会导致 `users.password` 字段不合法或登录失败。
- **建议**:用项目内 `BCryptPasswordEncoder` 真实生成新哈希,或干脆删掉 `data.sql` 改用 `DataInitializer`。

### 4.9 `RedisConfig` 显式声明 Bean 与 Sa-Token 自带 Bean 冲突

- **位置**:`RedisConfig.java` + `SaTokenConfig.java:21-23`
- **现象**:`Sa-Token` 集成 Redis 时已经会创建 `RedisConnectionFactory` / `RedisTemplate`;项目又显式定义了 `RedisTemplate<String,Object>`,可能因为 `@ConditionalOnMissingBean` 被跳过,但也容易出现序列化器不一致(两边都用 `GenericJackson2JsonRedisSerializer` 但 ObjectMapper 不同)。
- **建议**:把 `Sa-Token` 与业务 Redis 共享同一个 `ObjectMapper`(可把 `ObjectMapper` 抽成 `@Bean` 单独注入)。

---

## 5. 低风险问题 / 优化建议

### 5.1 大文件 / 长函数

- `ItemServiceImpl.java`(338 行)、`MatchingServiceImpl.java`(423 行)、`Home.vue`(1067 行)略长。
- 建议:`ItemServiceImpl.enrichItems` 拆出 `ItemEnricher` 独立类;`Home.vue` 拆出 `HeroSection` / `CategoryGrid` / `GuideSteps` 子组件。

### 5.2 重复的 try/catch + log.error

- `ItemServiceImpl.create`、`ItemServiceImpl.update`、`MatchingServiceImpl.match` 多次出现同样的"成功 + log.info,失败 + log.error"模式,无统一 `Result<T>` 包装。
- 建议:抽 `Optional.ofNullable(...).orElseThrow(()-> new BusinessException(...))` 或函数式风格统一异常流。

### 5.3 DTO 与 Entity 混用

- `Item` 实体直接由 `ItemController` 作为 `@RequestBody` 入参(没有专门的 `ItemCreateRequest`),部分字段由前端传入、后端赋值,容易越权。
- 建议:严格分层 DTO,只暴露需要前端填的字段。

### 5.4 文档与实现脱节

- `docs/README.md` 中"物品审核"流程图含 `verification` 模块,但该模块代码已删;
- `docs/功能与API.md` 描述的"找回密码"接口实际未实现(`forgotPassword()` 仅 `throw new Error`)。
- 建议:本轮 `项目图表.md` 已重写,继续保持文档与代码一致。

### 5.5 `AdminUsers.vue` 等仍保留大量 `console.log`

- **位置**:`Home.vue`、`ItemDetail.vue`、`PublishItem.vue` 中存在 `console.error`。
- 建议:统一用 `utils/message.js` 的 `showError`,不直接 `console.*`。

### 5.6 `data.sql` 假数据

- `data.sql` 中的 `created_at` 是 2026-05-20,演示时若未在 `data.sql` 里改,可能与 `DailyStatistics` 重新计算的日期对不上。
- 建议:把演示日期改为 `CURRENT_TIMESTAMP` 或文档化要求"每月 1 号前重置"。

### 5.7 缺少 API 限流

- `pom.xml` 引入 `spring-boot-starter-aop`,但**未见任何限流实现**;`/api/matches/batch`、`/api/matches/trigger` 等高开销接口没有 RateLimit。
- 建议:接入 `Bucket4j` 或 `Resilience4j` 限流注解,至少对 `/api/matches/*` 与 `/api/uploads/*` 加防刷。

### 5.8 缺少请求链路追踪

- 无 `traceId` / `requestId`,线上排查困难。
- 建议:引入 `MDC` + 自定义 `OncePerRequestFilter`,把 traceId 写入日志格式与响应头 `X-Request-Id`,前端 axios 拦截器打印。

### 5.9 RabbitMQ 引入但未使用

- `pom.xml:48-52` 引入了 `spring-boot-starter-amqp`,但代码中**未出现**任何 `@RabbitListener` / `RabbitTemplate`。
- 建议:要么删除依赖,要么实现"邮件异步队列"、"`/api/matches/batch` 异步化"等真实使用场景。

---

## 6. 安全检查清单(对照 common/security.md)

| 项 | 状态 | 备注 |
|---|---|---|
| 无硬编码密钥 | ❌ | 见 §2.1,application.yml 含 DB 密码 + SMTP 授权码 |
| 用户输入校验 | ⚠️ | `@Valid` 覆盖注册/发布;但 `ItemService.query.keyword` 等仍裸传 |
| SQL 注入防护 | ✅ | 全部用 MyBatis-Plus Wrapper,无字符串拼接 |
| XSS 防护 | ⚠️ | 后端 `MailServiceImpl.buildMatchEmailHtml` 用 `escapeHtml`;前端 `v-html` 仅在 `format.js#buildPlaceholderImage` 出现但内容是 SVG 模板可控,无大风险 |
| CSRF 防护 | ⚠️ | 前端无 token,Spring Security 关闭 CSRF 适合纯 API;但状态变更接口应加 SameSite Cookie / Double-Submit Token |
| 认证/授权 | ⚠️ | 见 §2.4(已确认产品决策) / §3.2,Sa-Token+JWT 双轨 |
| 速率限制 | ❌ | 见 §5.7 |
| 错误信息不泄漏 | ✅ | `GlobalExceptionHandler` 关闭了 `debugErrors` 默认 false |
| 依赖安全 | ⚠️ | 未运行 OWASP Dependency-Check;`sa-token-* 1.37.0` 是 2024 年初版本,需关注后续 CVE |
| 加密/哈希 | ✅ | 密码 BCrypt;JWT HS256 |

---

## 7. 优先级矩阵

| 优先级 | 建议 | 工作量 |
|---|---|---|
| P0 | §2.1 凭据轮换 + 移除 application.yml 明文 | 0.5d |
| ~~P0~~ | ~~§2.2 删除 `permitAll` 邮件测试接口~~ (2026-06-07 已修复) | - |
| ~~P0~~ | ~~§2.3 CORS 白名单化~~ (2026-06-07 已修复) | - |
| ~~P0~~ | ~~§2.4 收回 `getById` 越权~~ (产品决策不修改) | - |
| P1 | §3.2 统一鉴权(JWT 模式仅留 Security) | 2d |
| P1 | §3.3 / §3.4 N+1 与全表扫优化 | 2d |
| P1 | §3.5 `serial_number` 拆分 + 身份证校验 | 1.5d |
| P1 | §3.7 邮件异步化(RabbitMQ 已有) | 1d |
| P1 | §4.5 前端关键页面测试补齐 | 3d |
| P2 | §4.6 Element Plus 按需引入 | 1d |
| P2 | §4.7/§4.8 SQL 字符集与初始化哈希 | 0.5d |
| P2 | §5.1 拆分大文件 | 2d |
| P2 | §5.7 限流 / §5.8 链路追踪 | 2d |

---

## 8. 当前优势

- 后端权限矩阵已有自动化测试覆盖(`WebSecurityConfigTest`、`JwtSecurityIntegrationTest`)。
- JWT 过滤器已验证 access token 限制与数据库实时角色校验。
- 物品状态、完成申请、实名认证和证件匹配等业务链路已经从"概念设计"落成到可运行实现。
- 前后端主要接口、启动脚本、数据库基线都已形成基本闭环。
- 匹配算法具备加权评分 + 串号精确 + 时间衰减 + 串号冲突惩罚的完整工程实现。
- 审核状态机已改为条件原子更新,并具备 H2 并发集成测试。
- 前端具备 Vitest 基线(路由守卫 + axios 401),交互测试已起步。

---

## 9. 总结

| 维度 | 评价 |
|------|------|
| 业务功能完整度 | ★★★★☆ 主链路完整,完成申请/实名/匹配全闭环 |
| 安全性 | ★★★★★ 邮件中继 + CORS 已修复,仅 `application.yml` 凭据(用户接受 dev-only)待治理 |
| 可维护性 | ★★★☆☆ 模块分层清晰,大文件与重复模式仍较多 |
| 可测试性 | ★★★☆☆ 已有 Spring Boot Test + H2 + Vitest 雏形,关键路径覆盖偏薄 |
| 性能 | ★★★☆☆ Redis 已用,数据库层有 N+1 与全表扫隐患 |
| 文档完备度 | ★★★★☆ README / 数据库设计 / 功能 API / 测试质量 / 项目图表(本轮重写) |
| 工程化 | ★★★☆☆ 有 Swagger / Sa-Token / JWT / Redis,但限流/链路追踪缺位 |

**总体**:本项目已具备完整的业务交付能力,但**在安全与生产化方面仍有必须补齐的 P0 缺口**;建议下一阶段以"凭据治理 + 鉴权收口 + 性能 + 前端测试"为四大主线推进。
