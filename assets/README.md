# `assets` — Static Assets

Bundled assets declared in `pubspec.yaml` under the `flutter: assets:` entry.

| File | Purpose |
|---|---|
| `splash_video.mp4` | The launch animation played by `SplashScreen` (`lib/screens/splash_screen.dart`) while the background colour animates black→white→black. |
| `splash_image.png` | Static splash image (bundled; the splash screen currently plays the video and the image is kept as a fallback/future use). |
| `images/dark_image_trans_icon.png` | The app logo used in **dark mode** — picked by `AppLogoIcon` in `lib/widgets/display/icon.dart`. |
| `images/light_image_trans_icon.png` | The app logo used in **light mode** — same widget, switched on `Theme.brightness`. |

## Adding new assets

Add the file(s) here, then list them in the `flutter: assets:` section of
`pubspec.yaml` and run `flutter pub get`. Referencing an asset that isn't
declared there is a build error.