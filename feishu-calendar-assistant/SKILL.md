---
name: feishu-calendar-assistant
description: Feishu calendar scheduling assistant for multi-person free/busy lookup and reliable event creation with attendees. Use when user asks to find overlapping availability, schedule meetings, or debug Feishu calendar API behavior (OAuth, attendee writes, pagination, cleanup).
---

# Feishu Calendar Assistant

Use this skill to run a full Feishu scheduling workflow with minimal manual re-authorization.

## Core workflow

1. **Get a valid user token**
   - Prefer stored token manager:
     - `python3 scripts/feishu-token-manager.py get`
   - If missing/expired without refresh token:
     - ask user to authorize and provide code
     - `python3 scripts/feishu-token-manager.py exchange --code <CODE>`

2. **Find target calendars**
   - List subscribed calendars:
     - `GET /calendar/v4/calendars?...`
   - Match by display name (`summary`) and use `calendar_id`.

3. **Compute overlap availability**
   - Query each calendar’s events in the requested window.
   - **Always paginate** (`has_more/page_token`) to avoid missing busy blocks.
   - Merge busy intervals, invert to free windows, then intersect across participants.

4. **Create meeting**
   - Create event on organizer calendar.
   - For attendees, use this structure (critical):
   ```json
   "attendees": [
     {"type": "user", "user_id": "..."},
     {"type": "user", "user_id": "..."}
   ]
   ```
   - Do not use `attendee_id/attendee_id_type` in this workflow.

5. **Verify immediately**
   - Read back event with `need_attendee=true`.
   - Read attendees list endpoint.
   - If mismatch, report precisely and propose remediation.

6. **Cleanup test events** (if requested)
   - List candidate events by title/time window.
   - Keep newest confirmed target, delete test duplicates.

## Commands in this skill

- Token manager: `scripts/feishu-token-manager.py`
- OAuth callback server: `scripts/feishu-oauth-callback.py`
- Free/busy overlap helper: `scripts/feishu-freebusy-overlap.py`

## Gotchas (must follow)

- Use **user token** for primary calendar writes.
- Token is short-lived (~2h). Refresh early.
- Missing pagination causes false free windows.
- In `free_busy_reader/show_only_free_busy` scenarios, event detail may be limited.
- Validate results against user-observed calendar if discrepancy appears.

## References

- API pitfalls and known issues: `references/api-gotchas.md`
- Reusable workflow prompts: `references/workflow-templates.md`
