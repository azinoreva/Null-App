# `lib/engine/network/updates` — Updates / Social Feed Network Services

| File | Service(s) | Endpoint(s) | Purpose |
|---|---|---|---|
| `check_updates.dart` | `UpdatesService.getUpdates` | `POST /api/get_updates` | Fetch a page of updates. Sends `before`/`limit` plus exactly one optional filter (`category`, `hashtags`, or `user_ids`). Returns `List<Update>`. Also defines the shared `Update` and `UpdateMedia` models used everywhere in this subfolder. |
| `updates.dart` | `UpdatesActionsService` | `POST /api/updates`, `POST /api/check_update_progress`, `POST /api/mark_update_read` | Create an update, check progress (views/likes/follows/dislikes), and record like/follow/dislike/unfollow after a view. |
| `comments.dart` | `CommentsService` | `POST /api/comment_to_post`, `POST /api/comment_to_comment`, `POST /api/check_comments` | Post a top-level comment, reply to an existing comment (with `at_user` and `reply_to`), or list all comments for an update (`update_id` as query param). Returns `Comment` objects with an `isReply` flag. |

All requests run through `ApiClient` with automatic auth and refresh.