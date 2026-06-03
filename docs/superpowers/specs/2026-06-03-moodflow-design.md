# MoodFlow 设计文档

> 情绪陪伴 + 情绪记录 + 行动建议 · 治愈系移动 App
> 
> 日期：2026-06-03 | 状态：设计阶段

---

## 一、产品概要

### 1.1 产品定位

MoodFlow 是一款以「情绪陪伴」为核心的移动 App。帮助用户每天选择情绪、获得行动建议、完成记录、打卡，并在日历中查看长期情绪变化。

### 1.2 核心原则

- 温柔、陪伴、接纳 — 不做成任务管理工具
- 极简、柔和、治愈 — 低饱和度、大按钮、圆角卡片
- 不说教、不施压、不负面评价用户
- 所有操作可选，随时可跳过

### 1.3 目标用户

18~35 岁年轻用户：学生、上班族、独居用户、压力较大人群、有记录习惯的人。

---

## 二、技术选型

| 层级 | 选择 | 原因 |
|------|------|------|
| 前端框架 | Flutter | 跨平台、UI 表现优秀、动画自然 |
| 状态管理 | Riverpod | 编译时安全、无 context 依赖 |
| 本地数据库 | Drift (SQLite) | 类型安全、关系查询、迁移成熟 |
| 后端 | Supabase | 云同步、文件存储（可选用） |
| AI | OpenAI API | 用户自填 Key，可选增强功能 |
| 路由 | go_router + StatefulShellRoute | Tab 保持状态，推荐/记录页 push 入栈 |
| 平台 | iOS + Android | 跨平台两套部署 |

### 2.2 数据策略

**本地优先 + 可选云同步**。Drift 始终是唯一数据主源，Supabase 是备份和 AI 能力的开关。用户不登录完全可用，登录后开启自动同步和 AI 功能。

---

## 三、项目目录结构

```
moodflow/
├── lib/
│   ├── main.dart
│   ├── app.dart                          # MaterialApp + 主题 + 路由
│   │
│   ├── core/
│   │   ├── config/                       # 环境变量、常量
│   │   ├── database/                     # Drift 数据库定义
│   │   │   ├── database.dart
│   │   │   ├── tables/                   # 表结构
│   │   │   └── dao/                      # 数据访问层
│   │   ├── theme/                        # 全局主题
│   │   ├── router/                       # GoRouter 路由
│   │   ├── sync/                         # Supabase 同步引擎
│   │   └── utils/
│   │
│   ├── features/
│   │   ├── emotion/                      # 情绪选择
│   │   │   ├── data/                     # Drift DAO 调用
│   │   │   ├── domain/                   # 情绪模型 + 状态
│   │   │   └── presentation/             # 页面 + Widget
│   │   ├── recommend/                    # 行动推荐（三层引擎）
│   │   │   ├── data/
│   │   │   ├── engine/                   # 规则引擎 + 本地学习
│   │   │   └── presentation/
│   │   ├── record/                       # 完成记录（图文音）
│   │   ├── calendar/                     # 情绪日历
│   │   ├── history/                      # 时间线历史
│   │   ├── profile/                      # 设置 + 统计
│   │   └── onboard/                      # 首次引导（昵称 + 性别）
│   │
│   ├── shared/
│   │   └── widgets/                      # 通用组件（圆角卡片等）
│   │
│   └── ai/                               # AI 接口层
│       ├── openai_service.dart
│       ├── recommend_ai.dart
│       ├── diary_ai.dart
│       ├── ai_config_service.dart
│       └── models/
│
├── assets/
│   ├── images/                           # 心情动物插图（AI生成+人工修）
│   └── fonts/
├── test/
└── pubspec.yaml
```

---

## 四、数据库设计

### 4.1 ER 关系

```
users ──1:N──→ mood_records ──1:N──→ diary_entries
  │                  │
  │                  │──1:N──→ activity_logs
  │                  │
  │                  │──1:1──→ daily_checkin
  │
  └──1:N──→ recommendation_prefs
```

### 4.2 表结构

**users**
```
id              TEXT PRIMARY KEY (UUID)
nickname        TEXT
gender          TEXT              # 'male' | 'female'
role            TEXT              # 'puppy' | 'kitty'，根据性别默认
avatar_path     TEXT
created_at      TIMESTAMP
```

**mood_records**
```
id              TEXT PRIMARY KEY
user_id         TEXT FK → users
main_mood       TEXT              # 开心/焦虑/难过/疲惫/烦躁/空虚/平静/无聊/兴奋
sub_mood        TEXT?             # 次情绪，可选
intensity       INT               # 1-10
note            TEXT?
synced_at       TIMESTAMP?        # 同步到 Supabase 的时间
updated_at      TIMESTAMP
created_at      TIMESTAMP
```

**activity_logs**
```
id              TEXT PRIMARY KEY
mood_record_id  TEXT FK → mood_records
activity_name   TEXT
category        TEXT              # 放松/快速恢复/社交/自我成长/最低行动
synced_at       TIMESTAMP?
updated_at      TIMESTAMP
completed_at    TIMESTAMP
```

**diary_entries**
```
id              TEXT PRIMARY KEY
mood_record_id  TEXT FK → mood_records
text_content    TEXT?
image_path      TEXT?             # 本地文件路径
audio_path      TEXT?             # 本地文件路径
ai_summary      TEXT?             # AI 生成的一句话日记
synced_at       TIMESTAMP?
updated_at      TIMESTAMP
created_at      TIMESTAMP
```

**daily_checkins**
```
date            TEXT PRIMARY KEY  # YYYY-MM-DD
user_id         TEXT FK → users
mood_count      INT
created_at      TIMESTAMP
```

**recommendation_prefs**
```
id              TEXT PRIMARY KEY
user_id         TEXT FK → users
mood            TEXT
activity_name   TEXT
count           INT DEFAULT 1
is_hidden       BOOL DEFAULT FALSE
is_favorite     BOOL DEFAULT FALSE
updated_at      TIMESTAMP
```

---

## 五、导航与路由

### 5.1 底部 Tab（4 个）

| Tab | 内容 |
|-----|------|
| 🏠 今天 | 情绪选择（首页），选完后 → 推荐页 → 记录页 纵向流转 |
| 📅 日历 | 月/周情绪热力图 |
| 📋 历史 | 时间线 + 搜索 |
| 👤 我的 | 统计 + 设置 + AI + 同步 |

### 5.2 路由树

```
/                              → 首页（情绪选择）
  ├─ /recommend                → 推荐页（push，非 Tab）
  ├─ /record                   → 记录页（push，非 Tab）
  ├─ /calendar                 → 📅 日历 Tab
  ├─ /history                  → 📋 历史 Tab
  │    └─ /history/:id         → 历史详情
  ├─ /profile                  → 👤 我的 Tab
  │    ├─ /settings             → 设置
  │    │    ├─ /settings/api-key → AI 配置（填 OpenAI Key）
  │    │    └─ /settings/cloud   → 云同步配置
  │    └─ /statistics            → 数据统计（周报/月报）
```

### 5.3 核心流程（黄金路径）

```
首页选情绪 → 推荐页选行动 → 完成行动 → 记录页（可选） → 打卡 ✅
                  ↑
           可切换 / 收藏 / 不感兴趣 / 最低行动
```

### 5.4 首次引导

```
欢迎页 → 输入昵称 → 选择性别（男🐶/女🐱） → 进入首页
```

---

## 六、页面设计

### 6.1 首页 — 情绪选择

**布局**：3×3 情绪网格 + 强度滑杆 + CTA 按钮

**情绪 × Emoji × 底色映射**：

| 情绪 | 小狗版 (♂ 天蓝底 #e8f4fd) | 小猫版 (♀ 粉底 #ffe8f0) |
|------|--------------------------|-------------------------|
| 开心 | 开心小狗摇尾巴 | 开心小猫眯眼 |
| 焦虑 | 焦虑小狗耷耳朵 | 焦虑小猫炸毛 |
| 难过 | 难过小狗趴着 | 难过小猫垂尾 |
| 疲惫 | 疲惫小狗打哈欠 | 疲惫小猫瘫倒 |
| 烦躁 | 烦躁小狗皱眉 | 烦躁小猫甩尾 |
| 空虚 | 空虚小狗发呆 | 空虚小猫望窗外 |
| 平静 | 平静小狗闭眼 | 平静小猫呼噜 |
| 无聊 | 无聊小狗玩骨头 | 无聊小猫玩毛线 |
| 兴奋 | 兴奋小狗扑跳 | 兴奋小猫竖尾 |

**表情方案**：AI 生成（Midjourney/DALL·E）+ 设计师统一调色 → SVG/Lottie 动画

**交互细节**：
- 选中情绪：表情放大 1.2x + 底部柔和光晕
- 次情绪：可选，以小圆点形式出现在主情绪旁
- 强度滑杆：1-10，三级提示（轻微/中等/强烈），不标注精确数字
- CTA：「看看可以做什么 →」（非「下一步」）
- 顶部显示当天日期和连续打卡天数

### 6.2 推荐页

**布局**：居中单卡片 + 操作区

**内容**：
- 顶部显示当前情绪标签（如「😰 焦虑 · 强度 5」）
- 一句温柔引导（如「试着做些小事，让情绪慢慢降落」）
- 主卡片：行动图标 + 名称 + 简短说明
- 按钮：换个试试（横向滑动切换）+ 开始行动
- 底部：收藏 / 不感兴趣 / 最低行动模式

**交互**：
- 切换推荐使用横向滑动动画
- 最低行动模式——当用户连动都不想动时，推荐「深呼吸 10 秒」「喝一口水」「打开窗户」
- 不同类别的行动用不同图标和底色（放松=绿叶、快速恢复=水滴、社交=气泡、成长=书本）

### 6.3 记录页

**布局**：上下文提示 + 三项可选输入 + 完成/跳过

**内容**：
- 顶部：显示刚完成的行动（如「🌿 已完成：深呼吸」）
- 鼓励文案：「做得很好 ✨ 想记录一下现在的感受吗？」
- 照片区：拍照 / 相册选取
- 文本区：自由输入（placeholder「写几句……（可选）」）
- 语音区：录制按钮（最长 60 秒）
- 「完成记录」按钮
- 「跳过，直接打卡」灰色文字按钮（不强求记录）

### 6.4 日历页

**布局**：月/周切换 + 日历网格 + 当天详情

**内容**：
- 月份切换（左右箭头）
- 月/周视图切换 toggle
- 7 列日历网格，每天显示情绪底色
- 当天有记录的日期底部有情绪颜色小圆点
- 点击某天展开底部卡片，显示情绪、行动、打卡状态
- 底部情绪颜色图例

**情绪日历颜色**：
- 开心：黄色 #f9d56e
- 焦虑：橙色 #e88a5e
- 难过：蓝色 #5c8eb8
- 疲惫：灰色 #9e968e
- 烦躁：棕橙色 #c08068
- 空虚：浅灰 #b5b0a8
- 平静：绿色 #7aaa6e
- 无聊：土色 #a8a498
- 兴奋：粉色 #e87080

### 6.5 历史页

**布局**：搜索栏 + 时间线

**内容**：
- 顶部搜索栏（按情绪、按日期）
- 左侧时间线（竖线 + 情绪颜色圆点）
- 每条：时间戳 + 情绪 emoji + 情绪名 + 强度 + 完成的行动
- 点击跳转详情页
- 下拉加载更多

### 6.6 我的页面

**布局**：个人信息卡片 + 统计数 + 设置列表

**内容**：
- 头像 + 昵称 + 动物角色 + 陪伴天数
- 三格统计：连续天数 / 总记录 / 常驻情绪
- 菜单列表：
  - 📊 数据统计（周报/月报：高频情绪、趋势、最长连续、最常行动）
  - 🔑 AI 设置（填 OpenAI API Key、模型选择）
  - ☁️ 云同步（Supabase 登录/连接状态）
  - 🎨 切换角色（小狗 ↔ 小猫，随时可改）
  - ⚙️ 通用设置（提醒、暗色模式、关于）

---

## 七、三层推荐引擎

### L1 规则映射（0ms，总是触发）

预定义 JSON 映射表，`mood → [activity1, activity2, ...]`：

```json
{
  "焦虑": [
    {"name": "深呼吸", "category": "放松", "desc": "吸气4秒，呼气6秒，重复5次"},
    {"name": "散步", "category": "放松", "desc": "在附近走10分钟"},
    {"name": "听音乐", "category": "放松", "desc": "放一首你喜欢的歌"}
  ],
  "疲惫": [
    {"name": "喝一杯水", "category": "快速恢复", "desc": "慢慢地喝完一整杯"},
    {"name": "拉伸", "category": "快速恢复", "desc": "站起来伸个懒腰"},
    {"name": "打开窗户", "category": "快速恢复", "desc": "呼吸一下新鲜空气"}
  ]
}
```

四大分类：放松 / 快速恢复 / 社交 / 自我成长

### L2 本地学习（~5ms，历史 ≥ 5 条）

基于 Drift `recommendation_prefs` 表加权：

```
权重 = 该情绪下该活动被选次数 × 0.6
     + 是否被收藏 × 0.3
     - 是否被屏蔽 × 10（直接过滤）
     + 时间衰减（7 天前 × 0.8，30 天前 × 0.5）
```

### L3 AI 增强（~2s，需 API Key）

用户设置 API Key 后启用。L1+L2 秒出结果，AI 在后台并行调用，返回后在推荐列表末尾追加「✨ AI 个性化推荐」。

---

## 八、AI 层设计

### 8.1 架构

```
lib/ai/
├── ai_provider.dart           # AI 状态 Provider
├── ai_config_service.dart     # API Key 读写（加密存储）
├── openai_service.dart        # OpenAI API 封装
├── recommend_ai.dart          # AI 推荐增强
├── diary_ai.dart              # AI 日记生成
└── models/
```

### 8.2 功能

| 阶段 | 功能 | 依赖 |
|------|------|------|
| 第一阶段 | AI 日记生成 + AI 情绪推荐 | API Key |
| 第二阶段 | AI 情绪分析 + 个性化推荐 | API Key + 历史数据 |
| 第三阶段 | 情绪趋势预测 | API Key + 足够历史 |

### 8.3 安全

- API Key 存储在本地安全存储（flutter_secure_storage）
- Key 仅用于直接调用 OpenAI API，不经任何中转服务器
- 用户随时可在设置中删除 Key

---

## 九、云同步架构

### 9.1 模型

本地 Drift 始终是主数据源。Supabase 是备份 + 多设备同步的可选增强。

### 9.2 同步引擎

```
lib/core/sync/
├── sync_engine.dart        # 协调器
├── sync_queue.dart         # 变更队列
├── supabase_client.dart    # Supabase 封装
└── sync_state.dart         # 同步状态
```

### 9.3 规则

- 所有操作先写 Drift，同步异步后置
- 本地表增加 `synced_at` 字段追踪同步状态
- 冲突：Last-write-wins，以 `updated_at` 为准
- 默认仅 WiFi 下同步（可配置）
- 同步失败不影响本地功能，下次重试

### 9.4 触发时机

- App 进入前台
- 完成一条记录后
- 每 15 分钟定时（WiFi 下）
- 手动下拉刷新

---

## 十、全局主题

### 10.1 色彩体系

| 用途 | 色值 |
|------|------|
| 主背景 | #faf8f5（暖白） |
| 卡片背景 | #ffffff |
| 主文字 | #5c4a3a（暖棕） |
| 次要文字 | #a89888 / #b8a99a |
| 主按钮 | #c8a080（暖杏） |
| 分隔线 | #e8e0d8 |
| 男生主打 | #e8f4fd（天蓝） |
| 女生主打 | #ffe8f0（粉色） |

### 10.2 圆角规范

- 大卡片：16-20px
- 按钮：14-16px
- 情绪圆底：50%（圆形）
- 输入框：12-14px

### 10.3 动画

- 页面切换：淡入淡出 200ms
- 推荐切换：横向滑动 300ms
- 打卡成功：弹性缩放 + 粒子特效
- 情绪选中：缩放 1.2x + 阴影出现 150ms

---

## 十一、MVP 范围

### 必须完成

- [ ] 情绪选择（主情绪 + 次情绪 + 强度）
- [ ] 行动推荐（L1 规则 + 切换/收藏/屏蔽/最低行动）
- [ ] 完成记录（图片 + 文字 + 语音）
- [ ] 每日打卡
- [ ] 情绪日历（月视图 + 颜色热力图）
- [ ] 历史记录（时间线 + 搜索）
- [ ] 首次引导（昵称 + 性别/动物角色）

### 第二阶段

- [ ] L2 本地学习算法
- [ ] AI 日记生成（用户自填 Key）
- [ ] L3 AI 增强推荐
- [ ] 云同步（Supabase）

### 第三阶段

- [ ] 数据统计（周报/月报）
- [ ] AI 情绪分析
- [ ] 提醒通知
- [ ] 暗色模式

---

## 十二、关键依赖包

```yaml
# pubspec.yaml 核心依赖
dependencies:
  flutter_riverpod           # 状态管理
  riverpod_annotation
  drift                      # 本地数据库
  sqlite3_flutter_libs
  go_router                  # 路由
  supabase_flutter           # 云同步（可选）
  http                       # OpenAI API 调用
  flutter_secure_storage     # API Key 安全存储
  image_picker               # 照片选取
  record                     # 语音录制
  intl                       # 日期格式化
  lottie                     # 动画
```
