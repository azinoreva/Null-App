# `lib/engine/network/notifications` — Push-Notification Services

| File | Service | Endpoint | Purpose |
|---|---|---|---|
| `push_token.dart` | `PushNotificationService.updateToken` | `POST /api/account/push-notification-token` | Register the device's push token (e.g. FCM). Returns `PushNotificationTokenResponse` with `status`/`message` + `isSuccess` helper. |
| `send_notifications.dart` | `PushNotificationService` (same class name) | `POST /api/account/push-notification-token` (duplicate) and `POST /api/account/send_push_notification` | `updatePushNotificationToken` (same as `push_token.dart`); `sendPushNotification(user_id, type, message)` sends either a `"message"` or `"ping"` notification. |

Note: `PushNotificationTokenResponse` is declared in both files. They will
compile only if the file importing this service doesn't also import
`push_token.dart` (no compile collision currently). Both use the canonical
`PushNotificationType` enum (`message`, `ping`).