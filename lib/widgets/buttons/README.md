# `lib/widgets/buttons` — Button Components

| File | Purpose |
|---|---|
| `send_button.dart` | `SendButton` — the app's primary CTA: a themed `ElevatedButton` with rounded corners, optional leading/trailing icon (`IconPosition` enum: left/right), and a **locked** state (`isLocked`) that greys it out with `AppColors.disabledGray`. Scales padding from text size; brightens to `activeGreen` on press. Used on Login ("Log In"), Signup ("Sign Up"), the introduction modal ("Send Request"), and the profile modal (Block/Unblock, Ping). |
| `square_button.dart` | `SquareFeatureButton` — a 160×160 bordered tappable card with a circular "halo" icon, a bold title, and an uppercase subtitle. Used on `LoginScreen` for the Face ID and Fingerprint biometric options. |
| `transparent_button.dart` | `TransparentButton` — the inverse variant: an `OutlinedButton` with an 11%-opacity brand-green fill, faint green border, green text/icon, and hover/press overlays. Re-declares its own `IconPosition`. Used on `SignupScreen` ("Accept an invitation instead"). |