# Feishu Calendar API Gotchas

## 1) Attendee payload format
Use:
```json
{"attendees":[{"type":"user","user_id":"5ae1d4a7"}]}
```
Avoid legacy fields (`attendee_id`, `attendee_id_type`) in this workflow.

## 2) User token required for primary calendar writes
- Tenant token may fail with `191002 no calendar access_role`.
- Use OAuth user token for create/update/delete events in user's primary calendar.

## 3) Token expiry is frequent
- `user_access_token` often expires in ~2h.
- Implement refresh-token flow (`offline_access`) to avoid repeated manual authorization.

## 4) Pagination is mandatory
- `events` list can truncate busy blocks if page 1 only is read.
- Always iterate `has_more/page_token`.

## 5) Permission-limited subscriptions
- For `show_only_free_busy` calendars, details may be hidden.
- Prioritize free/busy interpretation over title/details.

## 6) Verification pattern
After write operations:
1. `GET event?need_attendee=true`
2. `GET attendees list`
3. Compare with requested attendees
