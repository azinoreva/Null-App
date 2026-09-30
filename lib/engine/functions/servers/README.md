# `lib/engine/functions/servers` — Server-Management Functions

| File | Purpose |
|---|---|
| `serverfxn.dart` | Server CRUD + remote refresh, all in terms of the backend `ServerInfo`:
  - `createServer(serversDao, server: ServerInfo)` — picks a visually distinct `accentColour` via `pickDistinctColour`, then inserts every field the API returned (the `media` block is flattened into its columns, `categories`/`mediaType` stored as JSON).
  - `updateServerFields(...)` — partial update of any field except the ID. Scalars take the new value; the nullable ones (`categories`, `location`, `media`) take a `Value`, so `Value(null)` clears them.
  - `deleteServerById(...)` — remove a server.
  - `refreshServers(...)` — fetch the remote server directory (`ServerDirectoryService`) and upsert every returned server, writing only the fields that actually differ.
  - `serverInfoFromRow(row)` — rebuild a `ServerInfo` from a stored row, so a value read back out of the database matches one the directory returned. |
| `server_colour.dart` | `pickDistinctColour(usedColours)` — generates 256 bright, evenly spaced HSL colours (golden-ratio hue distribution) and returns the first unused one; if all are taken, picks the colour with the greatest minimum Euclidean RGB distance to the used set. Also `_hslToRgbInt()` and `_colourDistance()` helpers. Fills the local `accentColour` column, not the API's `colour` string. |

These sit on top of `lib/engine/network/servers/` for anything that talks to
an actual server, and the `ServersDao` for local persistence.