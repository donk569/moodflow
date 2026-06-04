# 🌸 MoodFlow — 你的情绪陪伴日记

MoodFlow 是一款温柔、治愈的情绪记录与陪伴 App。记录每日心情，获得个性化行动建议，让每一天都被温柔对待。

## ✨ 主要功能

- 🎯 **情绪记录** — 9 种情绪 + 强度滑块，精准捕捉当下感受
- 🧠 **AI 行动建议** — DeepSeek / OpenAI 驱动的个性化推荐，帮你找到出口
- 📅 **日历视图** — 可视化回顾每月情绪轨迹
- 📊 **数据统计** — 周报 / 月报，了解情绪规律
- 📝 **心情日记** — 文字 + 照片（最多 4 张）+ 语音，多种方式记录
- 🔍 **历史搜索** — 按日期、情绪关键字搜索，支持批量管理
- ⏰ **每日提醒** — 自定义时间推送，不错过每一次记录
- 🌙 **深色 / 浅色模式** — 适配你的视觉偏好
- 🖼️ **自定义背景** — 设置个人背景图，可调透明度
- ☁️ **云同步** — Supabase 备份，数据不丢失
- 📤 **CSV 导出** — 一键导出数据到下载文件夹
- 🐶🐱 **陪伴角色** — 选择小狗或小猫模式，个性化体验

## 📸 预览

> 以下区域留给你添加 App 截图（建议 4-6 张主要页面）
>
> ![首页](screenshots/home.png)
> ![推荐](screenshots/recommend.png)
> ![历史](screenshots/history.png)
> ![我的](screenshots/profile.png)

## 🔧 技术栈

| 领域 | 技术 |
|------|------|
| 框架 | Flutter 3.38+ / Dart 3.10+ |
| 状态管理 | Riverpod |
| 本地数据库 | Drift (SQLite) |
| 路由 | GoRouter |
| AI | DeepSeek / OpenAI API |
| 云存储 | Supabase (可选) |
| 通知 | flutter_local_notifications |

## 📦 下载

### 正式版

从 [GitHub Releases](https://github.com/donk569/moodflow/releases) 下载最新 APK

### 开发版

```bash
git clone https://github.com/donk569/moodflow.git
cd moodflow
flutter pub get
flutter run
```

## 🏗️ 构建

```bash
# 构建 Release APK
flutter build apk --release

# APK 输出路径
# build/app/outputs/flutter-apk/app-release.apk
```

## 📄 开源协议

MIT License

---

<sub>Made with ❤️ by 小胡</sub>
