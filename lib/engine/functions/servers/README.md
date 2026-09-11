# `lib/engine/functions/servers` — Server-Management Functions

| File | Purpose |
|---|---|
| `serverfxn.dart` | Server CRUD + remote refresh:
  - `createServer(...)` — picks a visually distinct `colour` via `pickDistinctColour`, then inserts the row with all server configuration fields.
  - `updateServerFields(...)` — partial update of any field except the ID.
  - `deleteServerById(...)` — remove a server.
  - `refreshServers(...)` — fetch the remote server directory (`ServerDirectoryService`) and **update** rows that already exist locally; never auto-creates unknown servers. |
| `server_colour.dart` | `pickDistinctColour(usedColours)` — generates 256 bright, evenly spaced HSL colours (golden-ratio hue distribution) and returns the first unused one; if all are taken, picks the colour with the greatest minimum Euclidean RGB distance to the used set. Also `_hslToRgbInt()` and `_colourDistance()` helpers. |

These sit on top of `lib/engine/network/servers/` for anything that talks to
an actual server, and the `ServersDao` for local persistence.