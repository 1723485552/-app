# QA 严格自我验收清单 — 网络请求层核心架构落盘

任务：封装通用 `NetworkService` 与统一异常响应处理（轻量级网络请求层）。

---

## 1. 【大厂风格 / 工程规范】
- 纯基础设施层，无 UI，不涉及 Emoji / 8dp 网格等视觉规则（代码层严格遵守项目约定）。
- 全量 `const` 可用处均使用 `const`：`ApiResponse` 双构造为 `const`；`NetworkService._defaultTimeout` 为 `static const`。
- 响应包装与错误兜底逻辑内聚在 `network_service.dart`，无散落硬编码。
- 严格遵循项目既有的「`dart:io` 不进 Web 共享代码」铁律：`network_service.dart` **不 import `dart:io`**，跨平台连接错误用 `http.ClientException`（Web 原生类型）+ 原生 `SocketException` 字符串特征识别，确保 `flutter build web` 不被破坏。

## 2. 【架构拆分 / 单文件行数】
新增文件（均在 `lib/core/network/`）：

| 文件 | 行数 | 上限 | 结论 |
|---|---|---|---|
| `api_response.dart` | 24 | ≤100 | ✅ 通过 |
| `network_service.dart` | 99 | ≤200 | ✅ 通过 |
| `network_provider.dart` | 7 | ≤250 | ✅ 通过 |

- `pubspec.yaml`：新增 `http: ^1.2.0`（`flutter_riverpod: 2.6.1` 已存在）；`flutter pub get` 成功（Changed 1 dependency）。
- Provider 沿用项目既定风格（`card_repository_provider.dart`）：`final Provider<NetworkService> networkServiceProvider = Provider<NetworkService>((ref) => NetworkService());`，业务层 `ref.read(networkServiceProvider)` 直接调用。

## 3. 【全页联动】
- 本任务为底层网络设施，非页面/列表功能，无「搜索/分类全页响应」诉求；其作用是为后续业务请求提供统一 `ApiResponse` 入口，消除各页重复 try-catch。

## 4. 【静态检查】
- `flutter analyze` 结果：**No issues found!（0 Error / 0 Warning / 0 Info）**。
- 修复过程中的两处真实问题均已解决：
  1. `network_service.dart` 误 import `flutter_riverpod`（未使用）→ 已移除；
  2. `const ApiResponse<T>.failure(...)` 触发 `const_with_type_parameters`（Dart 禁止 `const` 构造带类型参数 `T`）→ 去除 `const`（该写法本就不可为 const，`prefer_const_constructors` 不会因此复燃）。

---

## 需求逐条对齐
1. ✅ **基础依赖**：`pubspec.yaml` 含 `http: ^1.2.0` 与 `flutter_riverpod: 2.6.1`。
2. ✅ **统一响应 `ApiResponse<T>`**：`isSuccess / data / errorMessage / statusCode` 四字段；`ApiResponse.success` / `ApiResponse.failure` 双构造（<100 行）。
3. ✅ **核心服务 `NetworkService`**：`baseUrl` + `authToken` 预留字段；
   - 默认 8s `Timeout`；
   - Header 自动注入 `Content-Type: application/json` + 可选 `Bearer <token>`；
   - 状态码拦截：2xx→`success`；401→未授权失败；4xx/5xx→`服务器响应异常: $code`；
   - 断网/超时 `try-catch` 优雅兜底（TimeoutException / ClientException / SocketException 归一并返回 `failure`，不抛异常致崩溃）（<200 行）。
4. ✅ **Riverpod Provider**：`networkServiceProvider` 导出，业务层 `ref.read` 即用。
5. ✅ **静态检查**：单文件 ≤250 行；`flutter analyze` 0/0/0。

## 后续可选
- 业务接入示例：`ref.read(networkServiceProvider).get<Map<String, dynamic>>('/api/xxx')`。
- 如需多 Client 复用/连接池，可后续引入 `http.Client` 字段并在 Provider `onDispose` 关闭（当前顶层 `http.get/post` 已满足轻量诉求）。
- 登录态刷新后直接 `ref.read(networkServiceProvider).authToken = newToken;` 即可全局生效。
