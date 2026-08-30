import 'package:drift/drift.dart';
import '../database/queries/identity_queries.dart';

Future<void> saveProfile(
  IdentityDao identityDao, {
  String? displayName,
  String? bio,
  String? avatar,
}) async {
  final companion = IdentityCompanion(
    displayName: displayName != null ? Value(displayName) : const Value.absent(),
    bio: bio != null ? Value(bio) : const Value.absent(),
    avatar: avatar != null ? Value(avatar) : const Value.absent(),
  );

  await identityDao.updateIdentityFields(companion);
}