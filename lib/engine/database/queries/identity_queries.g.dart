// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_queries.dart';

// ignore_for_file: type=lint
class $IdentityTable extends Identity
    with TableInfo<$IdentityTable, IdentityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdentityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _identityIdMeta = const VerificationMeta(
    'identityId',
  );
  @override
  late final GeneratedColumn<String> identityId = GeneratedColumn<String>(
    'identity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _securityProtocolMeta = const VerificationMeta(
    'securityProtocol',
  );
  @override
  late final GeneratedColumn<int> securityProtocol = GeneratedColumn<int>(
    'security_protocol',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _shamirNumberMeta = const VerificationMeta(
    'shamirNumber',
  );
  @override
  late final GeneratedColumn<int> shamirNumber = GeneratedColumn<int>(
    'shamir_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passportVersionMeta = const VerificationMeta(
    'passportVersion',
  );
  @override
  late final GeneratedColumn<int> passportVersion = GeneratedColumn<int>(
    'passport_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _autoSyncMeta = const VerificationMeta(
    'autoSync',
  );
  @override
  late final GeneratedColumn<int> autoSync = GeneratedColumn<int>(
    'auto_sync',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _allowConnectReqMeta = const VerificationMeta(
    'allowConnectReq',
  );
  @override
  late final GeneratedColumn<int> allowConnectReq = GeneratedColumn<int>(
    'allow_connect_req',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    identityId,
    displayName,
    avatar,
    bio,
    phoneNumber,
    securityProtocol,
    shamirNumber,
    publicKey,
    passportVersion,
    autoSync,
    allowConnectReq,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'identity';
  @override
  VerificationContext validateIntegrity(
    Insertable<IdentityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('identity_id')) {
      context.handle(
        _identityIdMeta,
        identityId.isAcceptableOrUnknown(data['identity_id']!, _identityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_identityIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('security_protocol')) {
      context.handle(
        _securityProtocolMeta,
        securityProtocol.isAcceptableOrUnknown(
          data['security_protocol']!,
          _securityProtocolMeta,
        ),
      );
    }
    if (data.containsKey('shamir_number')) {
      context.handle(
        _shamirNumberMeta,
        shamirNumber.isAcceptableOrUnknown(
          data['shamir_number']!,
          _shamirNumberMeta,
        ),
      );
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    }
    if (data.containsKey('passport_version')) {
      context.handle(
        _passportVersionMeta,
        passportVersion.isAcceptableOrUnknown(
          data['passport_version']!,
          _passportVersionMeta,
        ),
      );
    }
    if (data.containsKey('auto_sync')) {
      context.handle(
        _autoSyncMeta,
        autoSync.isAcceptableOrUnknown(data['auto_sync']!, _autoSyncMeta),
      );
    }
    if (data.containsKey('allow_connect_req')) {
      context.handle(
        _allowConnectReqMeta,
        allowConnectReq.isAcceptableOrUnknown(
          data['allow_connect_req']!,
          _allowConnectReqMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {identityId};
  @override
  IdentityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IdentityData(
      identityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identity_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      securityProtocol: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}security_protocol'],
      )!,
      shamirNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shamir_number'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      ),
      passportVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}passport_version'],
      )!,
      autoSync: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_sync'],
      )!,
      allowConnectReq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}allow_connect_req'],
      )!,
    );
  }

  @override
  $IdentityTable createAlias(String alias) {
    return $IdentityTable(attachedDatabase, alias);
  }
}

class IdentityData extends DataClass implements Insertable<IdentityData> {
  final String identityId;
  final String displayName;
  final String? avatar;
  final String? bio;
  final String? phoneNumber;
  final int securityProtocol;
  final int shamirNumber;
  final String? publicKey;
  final int passportVersion;
  final int autoSync;
  final int allowConnectReq;
  const IdentityData({
    required this.identityId,
    required this.displayName,
    this.avatar,
    this.bio,
    this.phoneNumber,
    required this.securityProtocol,
    required this.shamirNumber,
    this.publicKey,
    required this.passportVersion,
    required this.autoSync,
    required this.allowConnectReq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['identity_id'] = Variable<String>(identityId);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    map['security_protocol'] = Variable<int>(securityProtocol);
    map['shamir_number'] = Variable<int>(shamirNumber);
    if (!nullToAbsent || publicKey != null) {
      map['public_key'] = Variable<String>(publicKey);
    }
    map['passport_version'] = Variable<int>(passportVersion);
    map['auto_sync'] = Variable<int>(autoSync);
    map['allow_connect_req'] = Variable<int>(allowConnectReq);
    return map;
  }

  IdentityCompanion toCompanion(bool nullToAbsent) {
    return IdentityCompanion(
      identityId: Value(identityId),
      displayName: Value(displayName),
      avatar: avatar == null && nullToAbsent
          ? const Value.absent()
          : Value(avatar),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      securityProtocol: Value(securityProtocol),
      shamirNumber: Value(shamirNumber),
      publicKey: publicKey == null && nullToAbsent
          ? const Value.absent()
          : Value(publicKey),
      passportVersion: Value(passportVersion),
      autoSync: Value(autoSync),
      allowConnectReq: Value(allowConnectReq),
    );
  }

  factory IdentityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IdentityData(
      identityId: serializer.fromJson<String>(json['identityId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      bio: serializer.fromJson<String?>(json['bio']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      securityProtocol: serializer.fromJson<int>(json['securityProtocol']),
      shamirNumber: serializer.fromJson<int>(json['shamirNumber']),
      publicKey: serializer.fromJson<String?>(json['publicKey']),
      passportVersion: serializer.fromJson<int>(json['passportVersion']),
      autoSync: serializer.fromJson<int>(json['autoSync']),
      allowConnectReq: serializer.fromJson<int>(json['allowConnectReq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'identityId': serializer.toJson<String>(identityId),
      'displayName': serializer.toJson<String>(displayName),
      'avatar': serializer.toJson<String?>(avatar),
      'bio': serializer.toJson<String?>(bio),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'securityProtocol': serializer.toJson<int>(securityProtocol),
      'shamirNumber': serializer.toJson<int>(shamirNumber),
      'publicKey': serializer.toJson<String?>(publicKey),
      'passportVersion': serializer.toJson<int>(passportVersion),
      'autoSync': serializer.toJson<int>(autoSync),
      'allowConnectReq': serializer.toJson<int>(allowConnectReq),
    };
  }

  IdentityData copyWith({
    String? identityId,
    String? displayName,
    Value<String?> avatar = const Value.absent(),
    Value<String?> bio = const Value.absent(),
    Value<String?> phoneNumber = const Value.absent(),
    int? securityProtocol,
    int? shamirNumber,
    Value<String?> publicKey = const Value.absent(),
    int? passportVersion,
    int? autoSync,
    int? allowConnectReq,
  }) => IdentityData(
    identityId: identityId ?? this.identityId,
    displayName: displayName ?? this.displayName,
    avatar: avatar.present ? avatar.value : this.avatar,
    bio: bio.present ? bio.value : this.bio,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    securityProtocol: securityProtocol ?? this.securityProtocol,
    shamirNumber: shamirNumber ?? this.shamirNumber,
    publicKey: publicKey.present ? publicKey.value : this.publicKey,
    passportVersion: passportVersion ?? this.passportVersion,
    autoSync: autoSync ?? this.autoSync,
    allowConnectReq: allowConnectReq ?? this.allowConnectReq,
  );
  IdentityData copyWithCompanion(IdentityCompanion data) {
    return IdentityData(
      identityId: data.identityId.present
          ? data.identityId.value
          : this.identityId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      bio: data.bio.present ? data.bio.value : this.bio,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      securityProtocol: data.securityProtocol.present
          ? data.securityProtocol.value
          : this.securityProtocol,
      shamirNumber: data.shamirNumber.present
          ? data.shamirNumber.value
          : this.shamirNumber,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      passportVersion: data.passportVersion.present
          ? data.passportVersion.value
          : this.passportVersion,
      autoSync: data.autoSync.present ? data.autoSync.value : this.autoSync,
      allowConnectReq: data.allowConnectReq.present
          ? data.allowConnectReq.value
          : this.allowConnectReq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IdentityData(')
          ..write('identityId: $identityId, ')
          ..write('displayName: $displayName, ')
          ..write('avatar: $avatar, ')
          ..write('bio: $bio, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('securityProtocol: $securityProtocol, ')
          ..write('shamirNumber: $shamirNumber, ')
          ..write('publicKey: $publicKey, ')
          ..write('passportVersion: $passportVersion, ')
          ..write('autoSync: $autoSync, ')
          ..write('allowConnectReq: $allowConnectReq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    identityId,
    displayName,
    avatar,
    bio,
    phoneNumber,
    securityProtocol,
    shamirNumber,
    publicKey,
    passportVersion,
    autoSync,
    allowConnectReq,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IdentityData &&
          other.identityId == this.identityId &&
          other.displayName == this.displayName &&
          other.avatar == this.avatar &&
          other.bio == this.bio &&
          other.phoneNumber == this.phoneNumber &&
          other.securityProtocol == this.securityProtocol &&
          other.shamirNumber == this.shamirNumber &&
          other.publicKey == this.publicKey &&
          other.passportVersion == this.passportVersion &&
          other.autoSync == this.autoSync &&
          other.allowConnectReq == this.allowConnectReq);
}

class IdentityCompanion extends UpdateCompanion<IdentityData> {
  final Value<String> identityId;
  final Value<String> displayName;
  final Value<String?> avatar;
  final Value<String?> bio;
  final Value<String?> phoneNumber;
  final Value<int> securityProtocol;
  final Value<int> shamirNumber;
  final Value<String?> publicKey;
  final Value<int> passportVersion;
  final Value<int> autoSync;
  final Value<int> allowConnectReq;
  final Value<int> rowid;
  const IdentityCompanion({
    this.identityId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatar = const Value.absent(),
    this.bio = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.securityProtocol = const Value.absent(),
    this.shamirNumber = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.passportVersion = const Value.absent(),
    this.autoSync = const Value.absent(),
    this.allowConnectReq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IdentityCompanion.insert({
    required String identityId,
    required String displayName,
    this.avatar = const Value.absent(),
    this.bio = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.securityProtocol = const Value.absent(),
    this.shamirNumber = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.passportVersion = const Value.absent(),
    this.autoSync = const Value.absent(),
    this.allowConnectReq = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : identityId = Value(identityId),
       displayName = Value(displayName);
  static Insertable<IdentityData> custom({
    Expression<String>? identityId,
    Expression<String>? displayName,
    Expression<String>? avatar,
    Expression<String>? bio,
    Expression<String>? phoneNumber,
    Expression<int>? securityProtocol,
    Expression<int>? shamirNumber,
    Expression<String>? publicKey,
    Expression<int>? passportVersion,
    Expression<int>? autoSync,
    Expression<int>? allowConnectReq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (identityId != null) 'identity_id': identityId,
      if (displayName != null) 'display_name': displayName,
      if (avatar != null) 'avatar': avatar,
      if (bio != null) 'bio': bio,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (securityProtocol != null) 'security_protocol': securityProtocol,
      if (shamirNumber != null) 'shamir_number': shamirNumber,
      if (publicKey != null) 'public_key': publicKey,
      if (passportVersion != null) 'passport_version': passportVersion,
      if (autoSync != null) 'auto_sync': autoSync,
      if (allowConnectReq != null) 'allow_connect_req': allowConnectReq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IdentityCompanion copyWith({
    Value<String>? identityId,
    Value<String>? displayName,
    Value<String?>? avatar,
    Value<String?>? bio,
    Value<String?>? phoneNumber,
    Value<int>? securityProtocol,
    Value<int>? shamirNumber,
    Value<String?>? publicKey,
    Value<int>? passportVersion,
    Value<int>? autoSync,
    Value<int>? allowConnectReq,
    Value<int>? rowid,
  }) {
    return IdentityCompanion(
      identityId: identityId ?? this.identityId,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      securityProtocol: securityProtocol ?? this.securityProtocol,
      shamirNumber: shamirNumber ?? this.shamirNumber,
      publicKey: publicKey ?? this.publicKey,
      passportVersion: passportVersion ?? this.passportVersion,
      autoSync: autoSync ?? this.autoSync,
      allowConnectReq: allowConnectReq ?? this.allowConnectReq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (identityId.present) {
      map['identity_id'] = Variable<String>(identityId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (securityProtocol.present) {
      map['security_protocol'] = Variable<int>(securityProtocol.value);
    }
    if (shamirNumber.present) {
      map['shamir_number'] = Variable<int>(shamirNumber.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (passportVersion.present) {
      map['passport_version'] = Variable<int>(passportVersion.value);
    }
    if (autoSync.present) {
      map['auto_sync'] = Variable<int>(autoSync.value);
    }
    if (allowConnectReq.present) {
      map['allow_connect_req'] = Variable<int>(allowConnectReq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentityCompanion(')
          ..write('identityId: $identityId, ')
          ..write('displayName: $displayName, ')
          ..write('avatar: $avatar, ')
          ..write('bio: $bio, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('securityProtocol: $securityProtocol, ')
          ..write('shamirNumber: $shamirNumber, ')
          ..write('publicKey: $publicKey, ')
          ..write('passportVersion: $passportVersion, ')
          ..write('autoSync: $autoSync, ')
          ..write('allowConnectReq: $allowConnectReq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $IdentityTable identity = $IdentityTable(this);
  late final IdentityDao identityDao = IdentityDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [identity];
}

typedef $$IdentityTableCreateCompanionBuilder = IdentityCompanion Function({
  required String identityId,
  required String displayName,
  Value<String?> avatar,
  Value<String?> bio,
  Value<String?> phoneNumber,
  Value<int> securityProtocol,
  Value<int> shamirNumber,
  Value<String?> publicKey,
  Value<int> passportVersion,
  Value<int> autoSync,
  Value<int> allowConnectReq,
  Value<int> rowid,
});
typedef $$IdentityTableUpdateCompanionBuilder = IdentityCompanion Function({
  Value<String> identityId,
  Value<String> displayName,
  Value<String?> avatar,
  Value<String?> bio,
  Value<String?> phoneNumber,
  Value<int> securityProtocol,
  Value<int> shamirNumber,
  Value<String?> publicKey,
  Value<int> passportVersion,
  Value<int> autoSync,
  Value<int> allowConnectReq,
  Value<int> rowid,
});

class $$IdentityTableFilterComposer
    extends Composer<_$AppDatabase, $IdentityTable> {
  $$IdentityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get identityId => $composableBuilder(
    column: $table.identityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get securityProtocol => $composableBuilder(
    column: $table.securityProtocol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shamirNumber => $composableBuilder(
    column: $table.shamirNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passportVersion => $composableBuilder(
    column: $table.passportVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoSync => $composableBuilder(
    column: $table.autoSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get allowConnectReq => $composableBuilder(
    column: $table.allowConnectReq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IdentityTableOrderingComposer
    extends Composer<_$AppDatabase, $IdentityTable> {
  $$IdentityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get identityId => $composableBuilder(
    column: $table.identityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get securityProtocol => $composableBuilder(
    column: $table.securityProtocol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shamirNumber => $composableBuilder(
    column: $table.shamirNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passportVersion => $composableBuilder(
    column: $table.passportVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoSync => $composableBuilder(
    column: $table.autoSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get allowConnectReq => $composableBuilder(
    column: $table.allowConnectReq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IdentityTableAnnotationComposer
    extends Composer<_$AppDatabase, $IdentityTable> {
  $$IdentityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get identityId => $composableBuilder(
    column: $table.identityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get securityProtocol => $composableBuilder(
    column: $table.securityProtocol,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shamirNumber => $composableBuilder(
    column: $table.shamirNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<int> get passportVersion => $composableBuilder(
    column: $table.passportVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get autoSync =>
      $composableBuilder(column: $table.autoSync, builder: (column) => column);

  GeneratedColumn<int> get allowConnectReq => $composableBuilder(
    column: $table.allowConnectReq,
    builder: (column) => column,
  );
}

class $$IdentityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IdentityTable,
          IdentityData,
          $$IdentityTableFilterComposer,
          $$IdentityTableOrderingComposer,
          $$IdentityTableAnnotationComposer,
          $$IdentityTableCreateCompanionBuilder,
          $$IdentityTableUpdateCompanionBuilder,
          (
            IdentityData,
            BaseReferences<_$AppDatabase, $IdentityTable, IdentityData>,
          ),
          IdentityData,
          PrefetchHooks Function()
        > {
  $$IdentityTableTableManager(_$AppDatabase db, $IdentityTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdentityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdentityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdentityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> identityId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<int> securityProtocol = const Value.absent(),
                Value<int> shamirNumber = const Value.absent(),
                Value<String?> publicKey = const Value.absent(),
                Value<int> passportVersion = const Value.absent(),
                Value<int> autoSync = const Value.absent(),
                Value<int> allowConnectReq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdentityCompanion(
                identityId: identityId,
                displayName: displayName,
                avatar: avatar,
                bio: bio,
                phoneNumber: phoneNumber,
                securityProtocol: securityProtocol,
                shamirNumber: shamirNumber,
                publicKey: publicKey,
                passportVersion: passportVersion,
                autoSync: autoSync,
                allowConnectReq: allowConnectReq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String identityId,
                required String displayName,
                Value<String?> avatar = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<int> securityProtocol = const Value.absent(),
                Value<int> shamirNumber = const Value.absent(),
                Value<String?> publicKey = const Value.absent(),
                Value<int> passportVersion = const Value.absent(),
                Value<int> autoSync = const Value.absent(),
                Value<int> allowConnectReq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdentityCompanion.insert(
                identityId: identityId,
                displayName: displayName,
                avatar: avatar,
                bio: bio,
                phoneNumber: phoneNumber,
                securityProtocol: securityProtocol,
                shamirNumber: shamirNumber,
                publicKey: publicKey,
                passportVersion: passportVersion,
                autoSync: autoSync,
                allowConnectReq: allowConnectReq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IdentityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IdentityTable,
      IdentityData,
      $$IdentityTableFilterComposer,
      $$IdentityTableOrderingComposer,
      $$IdentityTableAnnotationComposer,
      $$IdentityTableCreateCompanionBuilder,
      $$IdentityTableUpdateCompanionBuilder,
      (
        IdentityData,
        BaseReferences<_$AppDatabase, $IdentityTable, IdentityData>,
      ),
      IdentityData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$IdentityTableTableManager get identity =>
      $$IdentityTableTableManager(_db, _db.identity);
}

mixin _$IdentityDaoMixin on DatabaseAccessor<AppDatabase> {
  $IdentityTable get identity => attachedDatabase.identity;
  IdentityDaoManager get managers => IdentityDaoManager(this);
}

class IdentityDaoManager {
  final _$IdentityDaoMixin _db;
  IdentityDaoManager(this._db);
  $$IdentityTableTableManager get identity =>
      $$IdentityTableTableManager(_db.attachedDatabase, _db.identity);
}
