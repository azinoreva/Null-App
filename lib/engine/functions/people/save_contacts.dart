// module_name: save_contacts

import 'package:drift/drift.dart';
import 'dart:typed_data';
import '../../database/queries/contacts_queries.dart';


Future<void> saveContact(
  ContactsDao contactsDao, {
  required String contactId,
  String? nickname,
  Uint8List? avatar,
  String? bio,
  required String serverId,
  int connectionStatus = 1,  // assumed default: 1 = pending
}) async {
  final now = DateTime.now().millisecondsSinceEpoch;

  final companion = ContactsCompanion.insert(
    contactId: contactId,
    nickname: Value(nickname),
    avatar: Value(avatar),
    bio: Value(bio),
    serverId: serverId,
    connectionStatus: connectionStatus,
    createdAt: now,
    updatedAt: now,
    conversationId: Value(contactId), // conversationId == contact_id
  );

  await contactsDao.db.into(contactsDao.db.contacts).insertOnConflictUpdate(companion);
}