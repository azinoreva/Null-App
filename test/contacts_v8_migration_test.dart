import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:null_app/engine/database/app_database.dart';

/// Rewinds the `contacts` table to the schema-version-7 layout (single
/// `server_id` + nullable `main_server_id`, values written as bare ids),
/// reopens the database, and checks that the v7 -> v8 upgrade renames the
/// column to `servers`, drops `main_server_id`, and that [ServersConverter]
/// still reads the legacy bare id as a one-element list.
void main() {
  test('contacts v7 -> v8 upgrade keeps legacy single-server rows readable',
      () async {
    final dir = await Directory.systemTemp.createTemp('null_app_migration');
    addTearDown(() => dir.delete(recursive: true));
    final path = '${dir.path}${Platform.pathSeparator}test.db';

    // 1. Fresh database: current schema, user_version 8.
    final fresh = AppDatabase(NativeDatabase(File(path)));
    await fresh.customSelect('SELECT 1').get();
    await fresh.close();

    // 2. Put `contacts` back the way it looked at version 7.
    final rewind = AppDatabase(NativeDatabase(File(path)));
    await rewind.customStatement(
      'ALTER TABLE contacts RENAME COLUMN servers TO server_id',
    );
    await rewind.customStatement(
      'ALTER TABLE contacts ADD COLUMN main_server_id TEXT',
    );
    await rewind.customStatement(
      "INSERT INTO contacts "
      "(contact_id, connection_status, server_id, main_server_id, "
      "created_at, updated_at) "
      "VALUES ('c1', 1, 'server_1', 'server_2', 1, 1)",
    );
    await rewind.customStatement('PRAGMA user_version = 7');
    await rewind.close();

    // 3. Reopening runs onUpgrade(7, 8).
    final upgraded = AppDatabase(NativeDatabase(File(path)));
    final rows = await upgraded.customSelect('SELECT * FROM contacts').get();
    expect(rows, hasLength(1));
    expect(rows.single.data.keys, contains('servers'));
    expect(rows.single.data.keys, isNot(contains('main_server_id')));
    expect(rows.single.data.keys, isNot(contains('server_id')));

    final contact = await upgraded.contactsDao.getContactById('c1');
    expect(contact, isNotNull);
    expect(contact!.servers, ['server_1']);
    await upgraded.close();
  });
}
