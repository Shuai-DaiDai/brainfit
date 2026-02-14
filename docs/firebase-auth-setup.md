# Firebase Authentication 设置步骤

## 第一步：进入 Firebase Console
1. 访问 https://console.firebase.google.com/
2. 选择项目 **brainfit-app**

## 第二步：找到 Authentication
在左侧导航栏中找到并点击 **Authentication**
（如果没有看到，点击展开 "Build" 菜单，里面会有 Authentication）

```
左侧导航栏结构：
Project Overview
├─ Project settings
Analytics
├─ Dashboard
├─ Events
Build  ← 点击展开
├─ Authentication  ← 在这里！
├─ Firestore Database
├─ Storage
├─ Functions
Release & Monitor
├─ Crashlytics
```

## 第三步：进入登录方法
1. 点击 **Authentication** 后
2. 顶部会出现几个标签页：
   - **Users**（用户）
   - **Sign-in method**（登录方法） ← 点击这个！
   - **Templates**（模板）
   - **Usage**（使用情况）

## 第四步：启用登录方法
1. 在 **Sign-in method** 标签页
2. 找到 **Sign-in providers** 部分
3. 点击 **Email/Password**（电子邮件/密码）
4. 在弹出的对话框中：
   - 将开关切换到 **启用**
   - 可选：启用「电子邮件链接（无密码登录）」
   - 点击 **保存**

## 第五步：验证
启用后，Email/Password 应该显示为「已启用」

---

## 截图说明

### 主界面左侧导航
```
🔥 brainfit-app

📊 分析
  └─ 总览
  
🛠️ 构建  ▼
  ├─ 🔐 身份验证  ← 点击这里
  ├─ 💾 Firestore Database
  ├─ 📦 Storage
  └─ ⚡ Functions
  
📱 发布和监控
  └─ 💥 Crashlytics
```

### Authentication 页面标签
```
┌─────────────────────────────────────────┐
│  🔐 Authentication                      │
├─────────────────────────────────────────┤
│  [Users]  [Sign-in method]  [Templates] │
│            ↑                            │
│      点击这个标签                        │
└─────────────────────────────────────────┘
```

### 登录方法列表
```
Sign-in providers
─────────────────────────────────────────
☑️ Google          已启用    配置
☐ Email/Password  已停用    配置 ← 点击配置
☐ Apple           已停用    配置
☐ Phone           已停用    配置
```

---

## 快速检查清单

- [ ] 访问 https://console.firebase.google.com/
- [ ] 选择 brainfit-app 项目
- [ ] 左侧菜单找到「构建」→「身份验证」
- [ ] 点击顶部「登录方法」标签
- [ ] 找到「电子邮件/密码」
- [ ] 点击「配置」→ 启用 → 保存

---

## 常见问题

**Q: 找不到 Authentication？**
A: 点击左侧「构建」(Build) 展开子菜单，Authentication 在里面

**Q: 点击后是空白页面？**
A: 等待几秒钟加载，或刷新页面

**Q: 提示需要先设置？**
A: 点击「开始使用」或「设置登录方法」按钮

---

*配置完成后，BrainFit 就可以进行用户注册了！*
