# `lib/screens/modals` — Modal / Dialog Components

Reusable dialogs and bottom sheets used by the screens.

| File | Purpose |
|---|---|
| `otp_modal.dart` | `OtpComponent` — a 6-digit OTP verification dialog. Auto-focuses the first box, auto-advances between fields, has a 120-second resend countdown (turns red when expired), validates a full 6 digits, and submits via `onSubmit(code) → Future<bool>` (true closes). `onResend()` may throw, surfaced as a snackbar. Used by `SignupScreen` after the server sends a code. |
| `add_friend.dart` | `IntroductionModal` — "Write an introduction" bottom sheet for sending a friend request: a 5-line message field with a live word counter (cap 150 words), an "Also add to my contacts list" checkbox, and Cancel / "Send Request" (`SendButton`, locked while empty). Save/persist is currently a TODO stub. |
| `profile_modal.dart` | `ProfileModal` — user profile dialog: avatar with online dot, editable nickname (inline edit, auto-saves on focus loss), status text, bio, server info, and Block/Unblock + Ping `SendButton`s. All data is passed in; save/block/mute actions are stub TODOs awaiting backend wiring. |