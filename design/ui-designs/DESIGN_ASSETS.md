# BrainFit UI 设计资产

> 基于《BrainFit UI Design Prompt》生成的完整设计系统

---

## 📱 生成的设计稿

| 序号 | 页面 | 文件名 | 尺寸 | 用途 |
|------|------|--------|------|------|
| 01 | **首页 Dashboard** | `01_dashboard.png` | 9:16, 2K | 用户主入口，显示脑力年龄、Streak、推荐练习 |
| 02 | **脑力年龄测试结果** | `02_brain_age_result.png` | 9:16, 2K | 恐惧驱动转化页，显示年龄对比和雷达图 |
| 03 | **呼吸引导界面** | `03_breathing.png` | 9:16, 2K | 共振呼吸练习，极简沉浸式设计 |
| 04 | **神经网络地图** | `04_neural_network.png` | 9:16, 2K | 用户成长可视化，点亮脑区 |
| 05 | **脑力竞技场 (Dual N-back)** | `05_dual_nback.png` | 9:16, 2K | 太空主题游戏界面 |
| 06 | **脑力周报** | `06_weekly_report.png` | 9:16, 2K | 数据报告，趋势图表 |

---

## 🎨 设计系统规范

### 颜色系统

```dart
// 核心品牌色
const Color primaryCoral = Color(0xFFE94560);     // 活力红 - CTA、警醒
const Color primaryTeal = Color(0xFF2A9D8F);      // 生机青 - 积极、修复
const Color primaryAmber = Color(0xFFF4A261);     // 暖琥珀 - 奖励、成就

// 背景色
const Color bgDark = Color(0xFF0A0E1A);           // 深色主背景（默认）
const Color bgCard = Color(0xFF1F2937);           // 卡片背景

// 辅助色
const Color accentBlue = Color(0xFF0F3460);       // 深海蓝 - 科学、信任
const Color textPrimary = Color(0xFFFFFFFF);      // 主文字
const Color textSecondary = Color(0xFFE5E7EB);    // 次要文字
const Color textMuted = Color(0xFF6B7280);        // 弱化文字

// 功能色
const Color breathingInhale = Color(0xFF4ECDC4);  // 吸气 - 青色
const Color breathingExhale = Color(0xFF6C5CE7);  // 呼气 - 紫色
const Color streakFlame = Color(0xFFFF6B35);      // 火焰红
```

### 字体规范

```dart
// 中文字体
TextStyle headingLarge = TextStyle(
  fontFamily: 'PingFang SC',
  fontWeight: FontWeight.w600, // Semibold
  fontSize: 24,
);

// 英文/数字字体
TextStyle dataNumber = TextStyle(
  fontFamily: 'SF Mono',
  fontWeight: FontWeight.bold,
  fontSize: 64,
);

// 正文字体
TextStyle bodyText = TextStyle(
  fontFamily: 'PingFang SC',
  fontWeight: FontWeight.w400,
  fontSize: 16,
  height: 1.6,
);
```

### 组件规范

#### 1. 脑力年龄展示卡片
```dart
Container(
  padding: EdgeInsets.all(24),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: primaryCoral.withOpacity(0.2),
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
    ],
  ),
  child: Column(
    children: [
      Text('你的脑力年龄', style: textSecondary),
      Text('32', style: dataNumber.copyWith(fontSize: 72)),
      Text('比实际年龄大4岁', style: TextStyle(color: primaryCoral)),
    ],
  ),
);
```

#### 2. 呼吸引导球
```dart
AnimatedContainer(
  duration: Duration(seconds: 5),
  width: isInhaling ? 280 : 200,
  height: isInhaling ? 280 : 200,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: RadialGradient(
      colors: [
        breathingInhale,
        breathingInhale.withOpacity(0.3),
        Colors.transparent,
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: breathingInhale.withOpacity(0.5),
        blurRadius: 60,
        spreadRadius: 20,
      ),
    ],
  ),
);
```

#### 3. Streak 火焰组件
```dart
Row(
  children: [
    Text('🔥', style: TextStyle(fontSize: 32)),
    SizedBox(width: 12),
    Text('连续健脑 23 天', style: textSecondary),
    Spacer(),
    Text('23', style: dataNumber.copyWith(
      color: streakFlame,
      fontSize: 48,
    )),
  ],
);
```

#### 4. 雷达图 (三维度)
- 顶点1: 注意力广度
- 顶点2: 情绪稳定性  
- 顶点3: 工作记忆
- 薄弱项: 红色短射线
- 优势项: 青色长射线

#### 5. 神经网络节点
```dart
// 解锁节点
Container(
  width: 80,
  height: 80,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: primaryTeal.withOpacity(0.2),
    border: Border.all(
      color: primaryTeal,
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryTeal.withOpacity(0.5),
        blurRadius: 30,
        spreadRadius: 5,
      ),
    ],
  ),
  child: Center(child: Text('前额叶')),
);

// 锁定节点
Container(
  width: 80,
  height: 80,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      color: textMuted,
      width: 2,
      style: BorderStyle.dashed,
    ),
  ),
  child: Center(child: Text('???')),
);
```

---

## 🎬 动效规范

### 1. 呼吸引导动效
```dart
// 吸气: 5秒膨胀 + 变亮
AnimationController(
  duration: Duration(seconds: 5),
  vsync: this,
)..forward();

// 呼气: 5秒收缩 + 变暗
AnimationController(
  duration: Duration(seconds: 5),
  vsync: this,
)..reverse();

// 颜色过渡
ColorTween(
  begin: breathingExhale,
  end: breathingInhale,
).animate(controller);
```

### 2. Streak 火焰动效
- 持续微弱跳动 (呼吸感)
- 断连时熄灭动画 (缩小 + 变灰)

### 3. 神经网络节点点亮
- 新节点: 光芒绽放动画 + 震动反馈
- 连接线: 粒子流动效果

### 4. 页面转场
- 使用 `CupertinoPageRoute` 风格
- 过渡时长: 300-400ms
- 缓动: `Curves.easeInOut`

---

## 📝 文案风格指南

### 教练式语调 (Coach Tone)

| 场景 | 文案示例 |
|------|----------|
| 开始练习 | "准备好了吗？90秒，重启你的大脑。" |
| 完成练习 | "心率下降了14bpm。你的前额叶在感谢你。" |
| 连续打卡 | "连续7天。你的注意力正在发生结构性变化。" |
| 断连提醒 | "你的脑力年龄本周上升了0.4岁。用2分钟挽回它。" |
| 解锁新功能 | "新能力解锁：深度心流训练。你的大脑准备好了。" |

### 文案三原则
1. **用数据说话**: "HRV 提升了 12%" ✅ 而不是 "效果很好"
2. **用因果关系**: "你的海马体神经可塑性正在恢复" ✅ 而不是 "坚持就有效"
3. **用行动而非感受**: "再练 3 次解锁下一个脑区" ✅ 而不是 "感觉好多了吧？"

---

## 🚫 设计禁忌

| 禁止 | 原因 |
|------|------|
| ❌ 莲花、佛像、冥想打坐剪影 | 用户反感"宗教/修行"暗示 |
| ❌ 紫色渐变+星星+月亮"助眠风" | 这不是助眠APP |
| ❌ 卡通人物、扁平插画小人 | 破坏科技感和专业性 |
| ❌ 过多的绿色/大自然元素 | 不是森林浴APP |
| ❌ "保重身体"、"放轻松"佛系文案 | 我们是健身房教练，不是养生老师 |
| ❌ 复杂的设置/选项/自定义页面 | 减少决策负担 |
| ❌ 弹窗广告、打断式推送 | 与"反干扰"理念矛盾 |

---

## 🎯 核心设计原则

> **"如果 Nike Training Club 和 Oura Ring 生了一个孩子，它上了 Duolingo 的瘾，读了一本神经科学教科书——那就是 BrainFit 的界面应该有的样子。"**

### 关键词优先级
```
科技神经感 > 游戏化活力 > 极简克制 > 温暖人文
```

### 三秒法则
用户打开 APP 到开始练习不超过 3 秒（一键直达今日推荐练习）。

### 反短视频节奏
所有动画、过渡、滚动速度都应该比常规 APP 慢 30%。

---

## 📂 文件位置

```
projects/brainfit/design/ui-designs/
├── 01_dashboard.png              # 首页 Dashboard
├── 02_brain_age_result.png       # 脑力年龄测试结果
├── 03_breathing.png              # 呼吸引导界面
├── 04_neural_network.png         # 神经网络地图
├── 05_dual_nback.png             # 脑力竞技场
├── 06_weekly_report.png          # 脑力周报
├── 01_dashboard_prompt.txt       # Prompt 原文
├── ...
└── DESIGN_ASSETS.md              # 本文件
```

---

## 🚀 下一步

1. ✅ 生成 UI 设计稿 (进行中)
2. ⏳ 将设计稿转换为 Flutter 代码
3. ⏳ 实现交互动效
4. ⏳ 开发脑力年龄测试游戏
5. ⏳ 完成呼吸引导功能

---

*Generated by 帅小呆1号 🎩*
*Date: 2026-02-14*
