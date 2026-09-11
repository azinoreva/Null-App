# `lib/widgets` — Reusable UI Components

Building blocks shared across all screens. Everything reads the app theme via
`Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark` for
dark/light mode support.

## Files / subfolders

| Path | Purpose |
|---|---|
| `app_theme.dart` | **Central theming.** `AppColors` (static brand/UI colours: greens, backgrounds, chat-bubble colours, slates, alert red, disabled grey), `AppTextType` enum + `AppTypography` (responsive font sizes and families: Roboto titles, Inter body), and `AppColorScheme` — a `ThemeExtension<AppColorScheme>` exposing themeable colours (`primaryGreen`, `background`, `border`, `haloRing`, chat bubble colours, `buttonContentColor`, `textInputColor`) with `light`/`dark` instances, `copyWith`, and `lerp`. |
| [`buttons/`](buttons/README.md) | `SendButton` (primary CTA, with locked state), `SquareFeatureButton` (biometric cards), `TransparentButton` (secondary outlined variant). |
| [`chats/`](chats/README.md) | `ChatBubbleComponent` + the `ChatMessageItem` model family and markdown-ish `RichMessageText`; `ChatInput` composer with @mentions and reply preview. |
| [`display/`](display/README.md) | App logo, adaptive desktop/mobile navigation, conversation-list row, contact card, and the floating contact action menu. |
| [`inputs/`](inputs/README.md) | `CustomInputField` and `CustomDropdownField` — the themed text/dropdown inputs. |

## Convention

New reusable widgets should:
- depend only on theme colours via `AppColorScheme` (never hard-code colours
  except where `AppColors.*` is the design intent),
- accept data and callbacks from the parent (these components are generally
  **stateless** display/composer components — the state lives in
  `lib/state/providers.dart`),
- follow the naming style above (`*Component`, `*Item`, `Custom*Field`).