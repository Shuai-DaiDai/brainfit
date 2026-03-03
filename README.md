# Skills 使用说明（给老爷）

本目录包含可复用的 Skill 资产。

## 新增 Skill：`feishu-calendar-assistant`

位置：`skills/feishu-calendar-assistant/`

用途：
- 多人忙闲交集查询（含分页防漏）
- 飞书建会与参与人写入
- OAuth 回调与 token 管理
- 测试会邀清理

---

## 老爷需要完成的任务（一次性）

### 1) 申请并通过飞书权限
至少需要：
- `calendar:calendar`
- `calendar:calendar.event:create`
- `calendar:calendar.event:update`
- `calendar:calendar.event:read`
- `contact:user.employee_id:readonly`

可选（用于长期免频繁授权）：
- `offline_access`

### 2) 完成一次 OAuth 授权
用于初始化 user token（和可选 refresh token）。

### 3) （可选）开通 `offline_access`
若要“后续尽量不再手点授权”，必须审批 `offline_access`。

---

## 日常操作步骤

### A. 启动 OAuth 回调服务
```bash
python3 skills/feishu-calendar-assistant/scripts/feishu-oauth-callback.py
```

健康检查：
```bash
curl http://127.0.0.1:8787/health
```

### B. 用授权码初始化 token
```bash
python3 skills/feishu-calendar-assistant/scripts/feishu-token-manager.py exchange --code <CODE>
```

### C. 获取可用 access_token（会自动刷新）
```bash
python3 skills/feishu-calendar-assistant/scripts/feishu-token-manager.py get
```

### D. 查询两人交集空闲（示例）
```bash
python3 skills/feishu-calendar-assistant/scripts/feishu-freebusy-overlap.py \
  --token "<ACCESS_TOKEN>" \
  --calendar-a "<CALENDAR_ID_A>" \
  --calendar-b "<CALENDAR_ID_B>" \
  --date 2026-03-04 \
  --start 16:00 \
  --end 23:59 \
  --min-minutes 60
```

---

## 关键注意事项

1. 创建会议写参与人时，使用：
```json
"attendees": [
  {"type":"user","user_id":"..."}
]
```
不要再用 `attendee_id/attendee_id_type`。

2. 忙闲查询必须处理分页（`has_more/page_token`），否则会漏事件。

3. 每次写入后都要回读验证：
- `GET event?need_attendee=true`
- `GET attendees list`

4. token 约 2 小时过期；若未开 `offline_access`，仍可能需要重新授权。

---

## 打包产物

本目录会生成：
- `skills/feishu-calendar-assistant.skill`

用于后续安装/分发。
