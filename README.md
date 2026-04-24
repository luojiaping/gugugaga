# 咕咕嘎嘎 🎬

影视播放App，基于 Flutter + Alist

## 功能

- 📁 浏览 Alist 服务器上的文件目录
- 🎬 在线播放视频/音频文件
- 🌙 支持深色/浅色主题切换
- ⚙️ 自定义 Alist 服务器地址
- 🔄 下拉刷新文件列表
- 📱 Material 3 设计风格

## 使用

1. 安装 App
2. 在设置页面填入你的 Alist 服务器地址（如 `https://your-alist-server.com`）
3. 返回首页浏览文件，点击视频/音频文件即可播放

## 构建

```bash
flutter pub get
flutter build apk --release
```

## CI/CD

- **构建验证**: 每次 push 到 main 分支自动触发构建
- **Release 构建**: 推送 `v*` 标签时自动构建并创建 GitHub Release

```bash
git tag v1.0.0
git push origin v1.0.0
```

## 技术栈

- Flutter 3.29.3
- Dart 3.2+
- Gradle 8.10.2
- AGP (via flutter-gradle-plugin)
- Java 17

## License

MIT
