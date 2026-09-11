# `lib/screens` — App Screens (UI Layer)

The user-facing screens. Handlers not yet wired to the engine are stubs (see
per-file notes). All screens are wrapped where needed by
`AdaptiveNavigationShell` (see `lib/widgets/display/navigation.dart`) for
desktop side-nav vs. mobile bottom-nav.

| File | Purpose |
|---|---|
| `splash_screen.dart` | `SplashScreen` — plays `assets/splash_video.mp4` while the background animates black→white→black; after 10s it sets `is_launched` in prefs and `pushReplacement` to the destination (the decision screen). |
| `login_screen.dart` | `LoginScreen` — narrow centered login form: logo + "Welcome" header, password field (with "Forgot Password" link), "Log In" `SendButton`, biometric "ALTERNATIVE ACCESS" section (Face ID / Fingerprint `SquareFeatureButton`s) on mobile, and a privacy banner. **Handlers are currently stubs.** |
| `signup_screen.dart` | `SignupScreen` — country-code dropdown + phone + password; drives the real registration flow: `UserRegistrationService().preprocess(...)` → OTP modal → `registerNewUser(...)` on the local DB → writes `has_signed_up` / `is_logged_in` → navigates to `ChatScreen`. Handles `ServerErrorException` / `DioException` with snackbars. |
| `chat_screen.dart` | `ChatScreen` — the **conversation list** ("Chats" tab). Watches `syncStatesProvider`, renders each conversation via `ConversationListItem`, search bar, "Mark all read", and a desktop two-pane layout. Tapping a row pushes `Chatting`. |
| `chatting.dart` | `Chatting` — the **conversation detail** screen (1:1 or group). Header (back, avatar + status dot, name, status label, icons), message list of `ChatBubbleComponent`s (auto-scrolls to bottom), and a `ChatInput` composer. Draft is persisted to `sync_state.draft` via `SyncStateDao.updateDraft`. `onSendMessage` is currently a no-op stub. |
| `contacts_screen.dart` | `ContactsScreen` (tab wrapper) + `ContactsListScreen` (reusable navbar-independent list UI): title, search field, dashed "Add New Contact" button, alphabetically sectioned contact list. `ContactData` parses the `"Name - Title"` convention. Fed a stub/empty contact list; `onAddContact` is a TODO. |
| `settings_screen.dart` | **Empty placeholder** (0 lines). Reserved for a future Settings screen; referenced by `NavigationTab.settings`. |

## Subfolders

| Folder | Purpose |
|---|---|
| [`modals/`](modals/README.md) | OTP dialog, friend-request introduction sheet, and the user profile dialog. |
| `sync_state/` | **Empty directory** — placeholder for future sync-state UI (the root README mentions this as a planned section). |

## Navigation flow

```
main.dart → SplashScreen (first run only) → DecisionScreen
              ├─ is_logged_in  → ChatScreen
              ├─ !has_signed_up → SignupScreen
              └─ else          → LoginScreen
ChatScreen ⇄ ContactsScreen (tabs). Chatting is pushed from ChatScreen.
```

## Status of real wiring

- **Wired:** signup (real OTP + registration), splash launch flag, chat list
  rendering from `SyncState`, message history + drafts in `Chatting`.
- **Stubs / TODO:** login, biometrics, forgot password, sending a message
  (`onSendMessage`), adding contacts, saving profiles, blocking/muting/pinging
  (`ProfileModal`), contact-menu actions, and the entire Settings screen.