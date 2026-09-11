# `lib/engine/image_handling` — Image Utilities

Helpers for processing images into blobs suitable for SQLite storage or
API calls.

| File | Purpose |
|---|---|
| `dicebear.dart` | `DicebearService` — fetches an avatar PNG from the Dicebear HTTP API (`api.dicebear.com/7.x/avataaars/png`) keyed by a `seed` string, with optional `size` and `backgroundColor` query params. Returns an `AvatarData` (raw bytes + precomputed base64 string). Throws on non-200. |
| `shrink_image.dart` | `ContactImageCompressor.processImage(...)` — compresses an image (from a file path or `File`) to a SQLite-ready blob: decodes, resizes to 96×96 px (cubic), encodes to **WebP**, and steps quality down from 85 until the result fits a strict byte budget (default 4 KB). Returns a `CompressedImageResult` with the raw `blobBytes` and an optional base64 string. Returns `null` on invalid input or when the budget cannot be met. |
| `string_to_blob.dart` | `base64ToBlob(...)` — single helper: strips a `data:image/webp;base64,...` prefix (if present) and decodes the base64 to a `Uint8List` for BLOB storage. Returns `null` on empty/invalid input. |

## Where these are used

- `DicebearService` — generating default avatars for contacts or groups.
- `ContactImageCompressor` — shrinking an avatar before writing to the
  `contacts.avatar` BLOB column.
- `base64ToBlob` — restoring bytes from a base64 string before database
  inserts (e.g. received avatar in identity card JSON).