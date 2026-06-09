# 扫描发现

## 项目结构
- 根目录包含 `backend`、`frontend`、`docs`，为典型前后端分离项目。
- 后端目前暴露的结构偏少，尚未看到完整的 `controller`、`service`、`entity`、`mapper` 目录，需要继续确认是否被省略或位于其他路径。
- 文档目录包含 `docs/sql/complete_init.sql` 与 `docs/project-design.md`，应作为数据库和设计基线。

## 待核查主题
- 权限角色定义与 Spring Security 配置是否一致。
- JWT 生成、解析、鉴权过滤器与前端 token 持久化是否一致。
- 数据初始化逻辑、数据库修复逻辑与 SQL 脚本是否冲突。
- 前端登录弹窗、状态管理、axios 拦截器、路由守卫是否配套。

## 已确认问题
- `WebSecurityConfig` 将 `/api/db/**` 公开，`DbFixController` 提供清空表、重建角色和修表接口，存在高危权限设计错误。
- `/api/admin/**` 仅允许 `SUPER_ADMIN`，但前端将 `CAMPUS_ADMIN` 也视为管理员，导致前后端权限口径不一致。
- `JwtAuthenticationFilter` 未限制 access token，且权限取自 token 中的 `role`，不是数据库当前角色。
- 前端 `axios` 封装返回的是统一响应体，但多个 store 仍按 `response.data` 取值，登录和列表数据解析错误。
- `App.vue` 保留了与 store 冲突的旧登录流程，调用了不存在的 `setUser`、`clearUser` 方法。
- 后端 `AuthService.register()` 未设置 `createdAt` / `updatedAt`，当前 `mvn test` 会触发 `created_at cannot be null`。
- `AuthServiceTest` 依赖固定账号 `admin` 且断言 `accessToken`，与当前真实初始化和返回结构不完全一致。
- `DataInitializer`、`DbFixController.fullInit()` 与 `docs/sql/complete_init.sql` 维护了三套不同的初始化数据，已确认需要收敛为一套 SQL 基线。

## 需求确认
- 管理后台允许 `SUPER_ADMIN` 与 `CAMPUS_ADMIN` 访问，但后续可按功能细分权限。
- `/api/db/**` 保留，但必须加鉴权并限制为 `SUPER_ADMIN`。
- 初始化逻辑需要整合成一套，最终沉淀为 SQL 脚本，方便其他人复刻项目。
- 第一轮修复范围尽量覆盖安全、登录、测试及主要不一致问题。
- 用户管理保留“改角色 + 删除”能力，但仅 `SUPER_ADMIN` 可执行；`CAMPUS_ADMIN` 仅查看和启用/禁用普通用户。

## 第二轮修复结果
- 已为匹配确认/拒绝补充资源归属校验，普通用户只能操作自己相关的匹配记录。
- 已将普通用户匹配列表限制为本人相关记录，管理员仍可查看全量匹配。
- 已为匹配记录补充关联物品标题和类别字段，前端不再依赖额外拉取全站物品来拼装标题。
- 已修复 `/api/items/my` 的真实按用户过滤逻辑，前端“我的物品”改为调用专用接口。
- 已实现 `/api/admin/users` 后台用户管理真实接口，支持分页查询、编辑、改角色、启用/禁用、删除。
- 已按确认规则收口后台用户管理权限：`SUPER_ADMIN` 可编辑/改角色/删除，`CAMPUS_ADMIN` 仅可启用或禁用普通用户。
- 已对后台用户列表和个人资料相关返回做密码字段脱敏，避免把加密密码回传前端。

## 第三轮修复结果
- 已将 `DailyStatistics.statDate` 从 `String` 改为 `LocalDate`，与数据库 `DATE` 类型对齐。
- 已完善每日统计落库逻辑，除失物/招领数量外，补充了当日匹配成功数和认领数。
- 已实现热门位置统计，按 `locations` 表中的真实地点聚合物品数量。
- 已补齐通知中心真实接口：通知列表、未读数量、单条已读、全部已读。
- 前端通知 store 已改为同时拉取通知分页数据和真实未读数量，顶部铃铛与通知弹窗链路已可闭环。

## 第四轮修复结果
- 已为 `LocationController` 补齐位置新增、编辑、删除接口，并限制写操作仅管理员可访问。
- 已增加位置删除保护：若位置仍被未删除物品引用，则拒绝删除，避免脏数据。
- 已实现前端 `AdminLocations.vue`，支持位置列表、创建、编辑、删除。
- 已补齐后台路由 `/admin/locations` 与 `/admin/statistics`，管理员面板快捷入口已能跳到真实页面。
- 已实现前端 `AdminStatistics.vue`，可查看仪表盘摘要、今日统计、热门类别、热门位置。
- 已为通知弹窗增加点击跳转：匹配通知跳转到匹配列表，审核结果跳转到对应物品详情页。

## 第五轮修复结果
- 已新增 `DataMaskUtils`，并对登录返回、个人资料返回、管理员用户列表返回中的身份证号做脱敏。
- 已为公开物品详情与公开物品列表增加敏感字段裁剪：非本人/非管理员仅看到脱敏后的联系方式和序列号。
- 已收紧物品状态门禁：仅待审核物品允许所有者编辑和删除，避免绕过审核后篡改或删除业务数据。
- 已将前端根组件切换为统一公共壳层，接入真实 `Header` 与 `Footer`，去除旧的重复登录实现。
- 已修复登录弹窗与注册弹窗的相互切换事件，清除无效按钮链路。
- 已补齐前端受保护页面守卫：`/publish`、`/my-items`、`/profile`、`/matches` 现在都要求登录。
- 已为发布页补齐编辑模式，支持从“我的物品”进入后加载原数据并提交更新。
- 已修复发布页联系方式字段与后端 `contactInfo` 参数名不一致的问题。
- 已新增脱敏工具测试与物品状态门禁测试，并收紧 `AuthServiceTest` 的 profile 与异常断言。

## 第六轮修复结果
- 已将后端主配置中的数据库、邮件、JWT 等默认敏感值改为安全占位，避免仓库继续携带真实风格凭据。
- 已新增 `application-test.yml` 与 `H2` 测试依赖，`SpringBootTest` 现在默认走独立测试配置。
- 已将 `AuthServiceTest` 改为 Mockito 单元测试，切断它对真实数据库和基础设施的依赖。
- 已将后台用户管理接口从 `Map` 请求体改为 DTO，并增加角色与状态的参数校验。
- 已为认领审核结果新增独立通知链路，改为通知认领申请人，不再复用物品发布审核通知。
- 已为前端物品列表补齐 URL 查询参数同步，首页搜索、分类跳转、翻页和筛选能与地址栏保持一致。
- 已新增认领审核通知分流测试，验证审核通过时调用的是认领通知链路。

## 当前仍建议继续处理的问题
- 前端仍存在较多 `alert/confirm`，建议统一替换为 Element Plus 的消息提示与确认框。
- 前端打包体积仍偏大，下一轮适合做路由懒加载和 `manualChunks` 分包。
- `CampusLostFoundApplicationTest` 仍然是“上下文可启动”级别的轻测试，可继续补更有业务价值的接口级安全测试。

## 第七轮修复结果
- 已将 `Profile.vue`、`AdminDashboard.vue`、`AdminStatistics.vue`、`ItemDetail.vue`、`MatchList.vue`、`LoginModal.vue`、`RegisterModal.vue` 的 `alert` 统一替换为 `Element Plus` 消息提示。
- 已新增 `showInfo`，并在详情页联系方式提示中统一走消息通知。
- 已将前端路由切换为懒加载，并在 `vite.config.js` 中增加 `manualChunks`，将 `vue`、应用基础依赖、`Element Plus` 依赖拆分到独立 chunk。
- 已新增 `WebSecurityConfigTest`，覆盖公开读取、匿名拒绝、普通用户越权拒绝、校园管理员放行、数据库接口仅超管可访问等权限矩阵。
- 在补权限测试过程中发现真实后端缺陷：多个控制器的 `@RequestParam` 未显式声明参数名，运行时会触发 `IllegalArgumentException`。
- 已修复 `AdminUserController`、`ItemController`、`NotificationController`、`VerificationController` 中相关 `@RequestParam` 声明，消除该类运行时错误。
- 已修复 `ItemDetail.vue` 的图标导入错误，前端构建恢复通过。

## 当前仍建议继续处理的问题
- `ui-vendor` 产物仍超过 `500 kB`，虽然已完成懒加载和手动分包，但 `Element Plus` 仍是主要体积来源，后续可考虑按需引入或更细颗粒拆包。
- 可继续把权限测试从 `WebMvcTest` 扩展到更贴近真实 JWT 链路的接口集成测试。

## 第八轮修复结果
- 已新增 [`JwtSecurityIntegrationTest`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/test/java/com/campus/lostfound/security/JwtSecurityIntegrationTest.java)，使用真实 `JwtUtils` 生成签名 token，并通过完整 Spring Security 过滤器链验证受保护接口访问。
- 已覆盖 `access token` 访问用户资料成功、`refresh token` 不能作为登录态访问受保护接口、数据库角色降级后旧管理员 token 失效、数据库角色升级后旧普通用户 token 获取管理员权限、禁用用户即使持有有效 token 也不能访问接口。
- 该测试进一步验证了当前 JWT 过滤器的两个关键设计：只接受 `access token`，且权限以数据库当前角色为准，而非信任 token 中的旧 `role`。

## 当前仍建议继续处理的问题
- `ui-vendor` 产物仍超过 `500 kB`，虽然已完成懒加载和手动分包，但 `Element Plus` 仍是主要体积来源，后续可考虑按需引入或更细颗粒拆包。
- `CampusLostFoundApplicationTest` 仍然是“上下文可启动”级别的轻测试，后续可继续替换为更贴近业务链路的接口级或服务级回归测试。

## 第九轮修复结果
- 已按新确认需求收敛状态设计：物品主状态不再把“已匹配”作为最终状态保存，而是改为高分匹配派生标签；阈值固定为 `80%`。
- 已将后端搜索从仅 `title/description` 扩展为 `title/description/brand/color/serial_number/location`，并修复列表页“改路由后又手动重复 fetch”导致的一次操作两次请求问题。
- 已补真实待审核物品接口 `/api/admin/items/pending`，前端管理员控制台已改为使用真实管理接口，不再混用公开 `/items?status=PENDING`。
- 已修复物品审核通过时未真正触发匹配的问题，管理员审核通过后会立即调用匹配服务。
- 已修复物品审核拒绝状态错误：后端不再将审核拒绝落成 `CLOSED`，改为独立状态 `REJECTED`。
- 已新增物品完成状态申请表 `item_completion_requests`，用户可对已高分匹配的物品提交“寻物已找到 / 招领已归还”申请，审核员通过后才更新最终状态。
- 已新增用户完成申请接口与管理员审核接口，并在前端 `MyItems` / `ItemDetail` / `AdminDashboard` 中补齐提交、展示和审核交互。
- 已补认领申请入口 `/api/items/{id}/claim`，详情页不再只弹联系方式，而是允许登录用户提交认领说明。
- 已修复通知类型与数据库枚举不一致的问题：通知类型已纳入 `CLAIM_REVIEW_RESULT`、`COMPLETION_REVIEW_RESULT`，避免运行时写库失败。
- 已打通图片链路：后端新增本地文件存储上传接口 `/api/uploads/images`，图片保存到 `./uploads/yyyy/MM/` 目录；发布页支持真实上传，物品创建/编辑会持久化到 `item_images`，列表卡片与详情页可展示图片。
- 已为无图片的示例数据增加前端占位图展示，避免示例物品普遍落到“暂无图片”或外链失效。

## 当前仍建议继续处理的问题
- 前端虽然已接入图床上传，但当前只走“上传后保存图片 URL”的最小链路，尚未接入图床元数据查询、AI 描述回填和上传失败重试。
- `notifications` 与 `items` 的新枚举已写入 SQL 基线和运行时修表逻辑，但如果线上库长期未执行基线初始化，仍建议额外提供一次显式迁移脚本。
- `ui-vendor` 产物仍明显偏大，后续可继续做 Element Plus 按需拆分。

## 第十轮修复结果
- 已新增显式迁移脚本 [`phase9_migration.sql`](file:///d:/SpringProjectReport/校园失物招领平台/docs/sql/phase9_migration.sql)，用于将旧版数据库平滑升级到“新状态枚举 + 新通知类型 + 完成申请表”版本。
- 已将迁移脚本改为兼容旧 MySQL 库的写法，避免 `ADD COLUMN IF NOT EXISTS` 在当前环境下报语法错误。
- 已重构 [`一键启动.bat`](file:///d:/SpringProjectReport/校园失物招领平台/一键启动.bat)，不再把复杂的 `DB_URL` 和 `java -jar` 命令嵌进单条 `start ... cmd /k` 字符串中，而是改为：
- 先检测环境并执行数据库初始化/迁移；
- 再调用独立的 [`启动后端.bat`](file:///d:/SpringProjectReport/校园失物招领平台/启动后端.bat) 和 [`启动前端.bat`](file:///d:/SpringProjectReport/校园失物招领平台/启动前端.bat)。
- 已修复一键启动导致前端页面空白、接口请求 `ECONNREFUSED` 的根因：此前后端子窗口启动命令过于脆弱，后端未真正监听 `8081`，前端能开但接口全失败。
- 已补充 README 启动说明与迁移说明，文档已和当前脚本行为一致。

## 第十轮验证结果
- 使用当前环境验证：
- MySQL `8.4`、Java `21`、Maven `3.9`、Node `23` 环境检查通过。
- 执行一键启动脚本可完成数据库迁移、后端构建、前端依赖检查与启动命令下发。
- 分别执行 [`启动后端.bat`](file:///d:/SpringProjectReport/校园失物招领平台/启动后端.bat) 与 [`启动前端.bat`](file:///d:/SpringProjectReport/校园失物招领平台/启动前端.bat) 后，`http://localhost:8081/swagger-ui.html` 返回 `200`，`http://localhost:3000` 返回 `200`。

## 第十一轮代码审查与文档结果
- 已重新执行真实验证：`backend` 的 `mvn test` 通过、`mvn -DskipTests package` 通过，`frontend` 的 `npm run build` 通过。
- 已定位并修复测试回归：`WebSecurityConfigTest` 因新增 `UserIdentityVerificationRepository` 后缺少 `@MockBean` 导致上下文加载失败，现已恢复为绿。
- 本轮代码审查确认的最高风险点仍为 [`DbFixController`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/main/java/com/campus/lostfound/modules/system/controller/DbFixController.java)：接口具备清表、改表、重建账号等破坏性能力，且异常时仍返回成功响应。
- 图片上传链路仍缺 MIME/后缀/大小/远端异常 等安全测试与防护，建议作为下一轮 P0。
- 前端当前仍无自动化测试框架；质量保障主要依赖后端测试、前端构建和浏览器人工回归。
- 已新增实现文档：
- [`docs/architecture-overview.md`](file:///d:/SpringProjectReport/校园失物招领平台/docs/architecture-overview.md)
- [`docs/database-design.md`](file:///d:/SpringProjectReport/校园失物招领平台/docs/database-design.md)
- [`docs/testing-and-quality.md`](file:///d:/SpringProjectReport/校园失物招领平台/docs/testing-and-quality.md)
- [`docs/code-review-report.md`](file:///d:/SpringProjectReport/校园失物招领平台/docs/code-review-report.md)

## 第十二轮安全收口结果
- 已将 [`DbFixController`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/main/java/com/campus/lostfound/modules/system/controller/DbFixController.java) 改为仅在 `app.db-fix-enabled=true` 时注册，默认生产配置下不会装配该高危控制器。
- 已修复条件装配键名错误：原实现写成 `app.db-fix.enabled`，导致测试环境即使配置开启也不会注册控制器；现已改为 `prefix = "app", name = "db-fix-enabled"`。
- 已为 `DbFixController` 增补失败分支测试：数据库修表异常时不再伪装成成功，而是返回 `ApiResponse.error(...)`。
- 已新增 [`HttpClientConfig.java`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/main/java/com/campus/lostfound/config/HttpClientConfig.java)，统一提供带超时的 `RestTemplate`，并让上传服务可注入、可测试。
- 已新增 [`LocalImageUploadServiceImpl.java`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/main/java/com/campus/lostfound/modules/item/service/impl/LocalImageUploadServiceImpl.java)，实现本地文件存储，支持 10MB 限制、MIME/扩展名白名单、日期子目录管理。
- 已删除旧的远程图床服务实现，移除对外部图床的依赖。
- 本轮真实回归结果：`mvn "-Dtest=WebSecurityConfigTest,ImageUploadServiceImplTest" test` 通过，`mvn test` 通过，`mvn -DskipTests package` 通过。
- 当前最高优先级风险已从“高危入口默认暴露、上传校验缺失”下降为“审核状态机测试不足”和“前端自动化测试缺失”。

## 第十三轮测试补强结果
- 已新增 [`DbFixControllerConditionalTest`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/test/java/com/campus/lostfound/modules/system/controller/DbFixControllerConditionalTest.java)，验证 `app.db-fix-enabled` 默认关闭时不注册控制器，显式开启时才注册。
- 已扩展 [`VerificationServiceImplTest`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/test/java/com/campus/lostfound/modules/verification/service/VerificationServiceImplTest.java)，覆盖重复审核拦截与通知发送失败不影响主流程。
- 已新增 [`ItemCompletionRequestServiceImplTest`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/test/java/com/campus/lostfound/modules/item/service/ItemCompletionRequestServiceImplTest.java)，覆盖完成申请审核通过、审核拒绝、已处理申请不可重复审核三类关键状态流。
- 本轮针对性回归结果：`mvn "-Dtest=DbFixControllerConditionalTest,VerificationServiceImplTest,ItemCompletionRequestServiceImplTest" test` 通过。
- 本轮全量回归结果：`mvn test` 通过，当前后端测试基线提升到 38 个测试、11 个测试文件；`mvn -DskipTests package` 通过。
- 当前剩余高优先级风险进一步收敛为：审核接口的 Web 层参数校验/并发测试，以及前端自动化测试基线仍未建立。

## 第十四轮 Web 校验收口结果
- 已扩展 [`WebSecurityConfigTest`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/test/java/com/campus/lostfound/security/config/WebSecurityConfigTest.java)，将 [`VerificationController`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/main/java/com/campus/lostfound/modules/verification/controller/VerificationController.java) 与 [`AdminCompletionRequestController`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/main/java/com/campus/lostfound/modules/item/controller/AdminCompletionRequestController.java) 纳入真实安全过滤链测试。
- 已为审核接口补 Web 层参数校验：拒绝物品、拒绝认领审核、拒绝完成申请时，空白原因会返回 `400` 和“拒绝原因不能为空”。
- 已为全局异常处理补 `MethodArgumentTypeMismatchException` 与 `MissingServletRequestParameterException` 的 `400` 映射，非法 `approved` 参数不再落成 `500`。
- 在修复过程中再次发现旧缺陷：新增控制器中的 `@PathVariable` 未显式命名会触发 `IllegalArgumentException`；现已补齐 `@PathVariable("id")`。
- 本轮真实回归结果：`mvn "-Dtest=WebSecurityConfigTest" test` 通过，`mvn test` 通过，`mvn -DskipTests package` 通过。
- 当前后端测试基线提升到 42 个测试、11 个测试文件；剩余高优先级风险进一步收敛为审核并发场景与前端自动化测试缺失。

## 第十五轮并发防护收口结果
- 已将 [`VerificationServiceImpl`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/main/java/com/campus/lostfound/modules/verification/service/impl/VerificationServiceImpl.java) 的审核更新改为按 `verificationId + status=PENDING` 条件原子更新，避免两个审核请求同时通过“先查后改”的窗口。
- 已将 [`ItemCompletionRequestServiceImpl`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/main/java/com/campus/lostfound/modules/item/service/impl/ItemCompletionRequestServiceImpl.java) 的完成申请审核改为按 `requestId + status=PENDING` 条件原子更新；通过后还会按 `itemId + status=APPROVED` 条件更新物品状态，防止关联物品已被其他流程改写。
- 已扩展 [`VerificationServiceImplTest`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/test/java/com/campus/lostfound/modules/verification/service/VerificationServiceImplTest.java) 与 [`ItemCompletionRequestServiceImplTest`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/test/java/com/campus/lostfound/modules/item/service/ItemCompletionRequestServiceImplTest.java)，覆盖并发二次审核拦截、关联物品状态漂移保护。
- 已扩展 [`WebSecurityConfigTest`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/test/java/com/campus/lostfound/security/config/WebSecurityConfigTest.java)，补审核接口缺失 `approved` 参数返回 `400` 的 Web 层测试。
- 本轮针对性回归结果：`mvn "-Dtest=WebSecurityConfigTest,VerificationServiceImplTest,ItemCompletionRequestServiceImplTest" test` 通过。
- 本轮全量回归结果：`mvn test` 通过，当前后端测试基线提升到 47 个测试、11 个测试文件；`mvn -DskipTests package` 通过。
- 当前剩余最高优先级风险已进一步收敛为：数据库级真实并发集成测试和前端自动化测试基线仍未建立。

## 第十六轮数据库级并发测试结果
- 已新增 [`ReviewConcurrencyIntegrationTest`](file:///d:/SpringProjectReport/校园失物招领平台/backend/src/test/java/com/campus/lostfound/modules/review/ReviewConcurrencyIntegrationTest.java)，使用真实 `SpringBootTest`、真实事务、真实 repository 和双线程并发，验证同一条认领审核/完成申请只能有一个事务成功提交。
- 该测试类会在 H2 中动态创建最小业务表并清理测试数据，避免受外部 MySQL 环境和 demo 数据初始化影响。
- 并发测试日志已验证两个连接会同时读取同一条待审核记录，但最终只有一个 `UPDATE ... WHERE status='PENDING'` 成功，另一个事务因影响行数为 `0` 被转为业务异常。
- 本轮针对性回归结果：`mvn "-Dtest=ReviewConcurrencyIntegrationTest" test` 通过。
- 本轮全量回归结果：`mvn test` 通过，当前后端测试基线提升到 49 个测试、12 个测试文件；`mvn -DskipTests package` 通过。
- 当前剩余最高优先级风险已进一步收敛为：审核链路缺参组合/边界状态覆盖仍可扩展，以及前端自动化测试基线尚未建立。

## 第十七轮前端测试基线结果
- 已引入 Vitest：新增 `npm test` 脚本，并在 `vite.config.js` 中启用测试配置。
- 已对 `router` 与 `axios` 做小幅可测试性改造：
  - [`router/index.js`](file:///d:/SpringProjectReport/校园失物招领平台/frontend/src/router/index.js) 导出 `createAuthGuard`，便于单测验证“未登录跳转”和“管理员门禁”。
  - [`utils/axios.js`](file:///d:/SpringProjectReport/校园失物招领平台/frontend/src/utils/axios.js) 导出 `createApiClient`，便于单测注入 `onUnauthorized` 验证 `401` 清理逻辑。
- 已新增前端测试：
  - [`router-guards.test.js`](file:///d:/SpringProjectReport/校园失物招领平台/frontend/src/router/router-guards.test.js)：覆盖未登录跳转、非管理员门禁、管理员放行、非法 user JSON 处理。
  - [`axios-401.test.js`](file:///d:/SpringProjectReport/校园失物招领平台/frontend/src/utils/axios-401.test.js)：覆盖 `401` 调用清理钩子与非 `401` 不触发清理。
- 本轮验证结果：`frontend` 执行 `npm test` 通过（6 个测试，2 个测试文件），`npm run build` 通过（仍有大包体积告警但不阻塞）。

## 智能匹配算法升级（2026-05-28）
- 现状：匹配仅使用“类别/地点ID/品牌/颜色/时间/串号”做硬编码加权，未利用标题/描述等文本信息，区分度不足且在数据量增大时会产生过多候选比较。
- 变更：新增文本相似度（title/description/location 文本），时间相似度改为指数衰减，并加入“串号冲突惩罚”以降低明显不匹配的高分误报；单次匹配引入候选约束并只保存 TopK 高分结果。
- 影响：匹配更可解释且更贴近用户描述信息，误匹配率下降；同时避免一次审核触发全表两两比较导致的性能风险。

## 移除悬赏金设计（2026-05-28）
- 结论：产品层不再提供“悬赏金额”独立字段；用户如需表达感谢/酬谢，可在描述中自愿填写。
- 实现：前端移除输入与展示；后端 API 入参/实体/出参移除 reward；SQL 基线移除 `items.reward` 并提供显式迁移脚本用于旧库升级。
