//module name: servers

import 'package:drift/drift.dart';

/// Drift table definition for the `Servers` table.
/// Stores information about messaging servers that the user can connect to.
///
/// The column set mirrors the backend `Server` payload (see `ServerInfo` /
/// `ServerConfig`) one-for-one. Drift has no nested objects, so the two list
/// valued fields of the API - `categories` and the media block's
/// `media_type` - are stored as JSON text; everything else maps to a scalar
/// column of the same name.
///
/// `accentColour` is local-only bookkeeping: the 0xRRGGBB value
/// `pickDistinctColour` uses to tell servers apart in the UI. It is not part
/// of the API payload (which supplies `colour` as a string) and is never
/// overwritten by a directory refresh.
class Servers extends Table {
  /// --- Mirrors of the API payload ---
  TextColumn get serverId => text()();
  TextColumn get serverName => text()();
  TextColumn get serverUrl => text()();
  TextColumn get serverType => text().withDefault(const Constant('public'))();
  IntColumn get maxPayload => integer().withDefault(const Constant(5))();
  TextColumn get colour => text().withDefault(const Constant(''))();
  TextColumn get about => text().withDefault(const Constant(''))();
  TextColumn get categories => text().nullable()();
  BoolColumn get annotated => boolean().withDefault(const Constant(false))();
  BoolColumn get disabled => boolean().withDefault(const Constant(false))();
  TextColumn get location => text().nullable()();

  /// Flattened form of the API's `media` object.
  TextColumn get mediaUrl => text().nullable()();
  IntColumn get mediaSize => integer().nullable()();
  IntColumn get mediaTimer => integer().nullable()();
  TextColumn get mediaType => text().nullable()();

  /// --- Local-only bookkeeping (not part of the API payload) ---
  DateTimeColumn get mediaLastReset => dateTime()();
  IntColumn get totalMediaSent => integer().withDefault(const Constant(0))();
  IntColumn get accentColour => integer().withDefault(const Constant(65280))();

  @override
  Set<Column> get primaryKey => {serverId};
}
