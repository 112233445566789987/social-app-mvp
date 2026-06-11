# 社交圈 - Social App MVP

跨平台社交 App，使用 Flutter 构建，支持 iOS / Android / Web。

## 🏗 技术栈

| 层级 | 技术 |
|------|------|
| 框架 | Flutter 3.x + Dart 3.x |
| 状态管理 | flutter_bloc 8.x |
| 路由 | go_router 14.x |
| 本地存储 | shared_preferences |
| HTTP | http + web_socket_channel |
| 图片缓存 | cached_network_image |
| 时间格式化 | timeago |

## 📁 项目结构

```
lib/
├── main.dart                         # 入口
├── core/
│   ├── router/app_router.dart        # 路由配置 (GoRouter)
│   └── theme/app_theme.dart          # 主题配置
└── features/
    ├── auth/                         # 登录 / 注册
    ├── home/                         # 主页面 + 底部导航
    ├── moments/                      # 朋友圈动态
    ├── matching/                     # 匹配（类似 Tinder）
    ├── chat/                         # 聊天列表 + 私聊
    └── profile/                      # 个人资料
```

## 🚀 快速开始

### 环境要求

- Flutter SDK 3.24+
- Dart 3.4+
- Android Studio / Xcode（对应平台）

### 安装步骤

**1. 安装 Flutter SDK（Windows）**

如果你在中国大陆，建议使用镜像：

```powershell
# 设置 Flutter 镜像
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"

# 下载 Flutter SDK
curl.exe -L -o flutter.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.0_stable.zip

# 解压到 D:\flutter
Expand-Archive flutter.zip -DestinationPath D:\flutter

# 添加到 PATH
$env:Path += ";D:\flutter\bin"
flutter doctor
```

**2. 安装依赖**

```bash
cd social_app_mvp
flutter pub get
```

**3. 运行**

```bash
# Android（模拟器或真机）
flutter run -d android

# iOS（需要 Mac）
flutter run -d ios
```

## 📱 功能模块

### 🔐 认证 (Auth)
- 邮箱登录 / 注册
- 持久化登录态（SharedPreferences）
- 退出登录

### 📰 朋友圈 (Moments)
- 动态列表（下拉刷新）
- 点赞 / 评论
- 发布动态（文字 + 图片）
- 头像 + 昵称 + 相对时间

### 💕 匹配 (Matching)
- 左右滑动卡片（喜欢 / 跳过）
- 超级喜欢
- 用户资料卡（头像 / 年龄 / 距离 / 个人简介 / 标签）
- 模拟匹配成功提示

### 💬 聊天 (Chat)
- 聊天会话列表（未读数、在线状态）
- 私聊界面（气泡样式、消息状态：发送中/已发送/已读）
- 发送文字消息

### 👤 个人资料 (Profile)
- 个人信息展示
- 统计数据（关注/粉丝/获赞）
- 功能菜单（相册/收藏/历史/设置）
- 退出登录

## 🔧 构建脚本

### Android

```bash
# 调试 APK
flutter build apk --debug

# 发布 APK（release 需要签名）
flutter build apk --release
```

APK 输出路径: `build/app/outputs/flutter-apk/`

### iOS（仅 macOS）

```bash
# 模拟器
flutter build ios --simulator --no-codesign

# 真机/打包（需要签名证书）
flutter build ios --release
```

## ⚠️ 注意事项

1. **网络问题**：在中国大陆请配置 Flutter 镜像（见上方安装步骤）
2. **iOS 构建**：必须在 macOS + Xcode 环境下进行
3. **API 替换**：当前使用模拟数据（`_mockSessions`、`_mockMoments` 等），生产环境需替换为真实 API 调用
4. **权限配置**：Android 需在 `android/app/src/main/AndroidManifest.xml` 配置网络、相机、相册权限

## 📦 常用命令

```bash
flutter pub get              # 安装依赖
flutter pub upgrade          # 升级依赖
flutter analyze              # 代码分析
flutter test                 # 运行测试
flutter doctor              # 环境诊断
```
