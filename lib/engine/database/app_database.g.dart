// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

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

class $ServersTable extends Servers with TableInfo<$ServersTable, Server> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUrlMeta = const VerificationMeta(
    'serverUrl',
  );
  @override
  late final GeneratedColumn<String> serverUrl = GeneratedColumn<String>(
    'server_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaUrlMeta = const VerificationMeta(
    'mediaUrl',
  );
  @override
  late final GeneratedColumn<String> mediaUrl = GeneratedColumn<String>(
    'media_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaSizeLimitMeta = const VerificationMeta(
    'mediaSizeLimit',
  );
  @override
  late final GeneratedColumn<int> mediaSizeLimit = GeneratedColumn<int>(
    'media_size_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100000),
  );
  static const VerificationMeta _mediaLastResetMeta = const VerificationMeta(
    'mediaLastReset',
  );
  @override
  late final GeneratedColumn<DateTime> mediaLastReset =
      GeneratedColumn<DateTime>(
        'media_last_reset',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _totalMediaSentMeta = const VerificationMeta(
    'totalMediaSent',
  );
  @override
  late final GeneratedColumn<int> totalMediaSent = GeneratedColumn<int>(
    'total_media_sent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverNameMeta = const VerificationMeta(
    'serverName',
  );
  @override
  late final GeneratedColumn<String> serverName = GeneratedColumn<String>(
    'server_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTimerMeta = const VerificationMeta(
    'mediaTimer',
  );
  @override
  late final GeneratedColumn<int> mediaTimer = GeneratedColumn<int>(
    'media_timer',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(86400),
  );
  static const VerificationMeta _maxPayloadMeta = const VerificationMeta(
    'maxPayload',
  );
  @override
  late final GeneratedColumn<int> maxPayload = GeneratedColumn<int>(
    'max_payload',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _capabilitiesMeta = const VerificationMeta(
    'capabilities',
  );
  @override
  late final GeneratedColumn<int> capabilities = GeneratedColumn<int>(
    'capabilities',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    serverId,
    serverUrl,
    mediaUrl,
    mediaSizeLimit,
    mediaLastReset,
    totalMediaSent,
    serverName,
    mediaTimer,
    maxPayload,
    capabilities,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'servers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Server> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('server_url')) {
      context.handle(
        _serverUrlMeta,
        serverUrl.isAcceptableOrUnknown(data['server_url']!, _serverUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_serverUrlMeta);
    }
    if (data.containsKey('media_url')) {
      context.handle(
        _mediaUrlMeta,
        mediaUrl.isAcceptableOrUnknown(data['media_url']!, _mediaUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaUrlMeta);
    }
    if (data.containsKey('media_size_limit')) {
      context.handle(
        _mediaSizeLimitMeta,
        mediaSizeLimit.isAcceptableOrUnknown(
          data['media_size_limit']!,
          _mediaSizeLimitMeta,
        ),
      );
    }
    if (data.containsKey('media_last_reset')) {
      context.handle(
        _mediaLastResetMeta,
        mediaLastReset.isAcceptableOrUnknown(
          data['media_last_reset']!,
          _mediaLastResetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaLastResetMeta);
    }
    if (data.containsKey('total_media_sent')) {
      context.handle(
        _totalMediaSentMeta,
        totalMediaSent.isAcceptableOrUnknown(
          data['total_media_sent']!,
          _totalMediaSentMeta,
        ),
      );
    }
    if (data.containsKey('server_name')) {
      context.handle(
        _serverNameMeta,
        serverName.isAcceptableOrUnknown(data['server_name']!, _serverNameMeta),
      );
    } else if (isInserting) {
      context.missing(_serverNameMeta);
    }
    if (data.containsKey('media_timer')) {
      context.handle(
        _mediaTimerMeta,
        mediaTimer.isAcceptableOrUnknown(data['media_timer']!, _mediaTimerMeta),
      );
    }
    if (data.containsKey('max_payload')) {
      context.handle(
        _maxPayloadMeta,
        maxPayload.isAcceptableOrUnknown(data['max_payload']!, _maxPayloadMeta),
      );
    }
    if (data.containsKey('capabilities')) {
      context.handle(
        _capabilitiesMeta,
        capabilities.isAcceptableOrUnknown(
          data['capabilities']!,
          _capabilitiesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serverId};
  @override
  Server map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Server(
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
      serverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_url'],
      )!,
      mediaUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_url'],
      )!,
      mediaSizeLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_size_limit'],
      )!,
      mediaLastReset: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}media_last_reset'],
      )!,
      totalMediaSent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_media_sent'],
      )!,
      serverName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_name'],
      )!,
      mediaTimer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_timer'],
      )!,
      maxPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_payload'],
      )!,
      capabilities: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capabilities'],
      )!,
    );
  }

  @override
  $ServersTable createAlias(String alias) {
    return $ServersTable(attachedDatabase, alias);
  }
}

class Server extends DataClass implements Insertable<Server> {
  final String serverId;
  final String serverUrl;
  final String mediaUrl;
  final int mediaSizeLimit;
  final DateTime mediaLastReset;
  final int totalMediaSent;
  final String serverName;
  final int mediaTimer;
  final int maxPayload;
  final int capabilities;
  const Server({
    required this.serverId,
    required this.serverUrl,
    required this.mediaUrl,
    required this.mediaSizeLimit,
    required this.mediaLastReset,
    required this.totalMediaSent,
    required this.serverName,
    required this.mediaTimer,
    required this.maxPayload,
    required this.capabilities,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_id'] = Variable<String>(serverId);
    map['server_url'] = Variable<String>(serverUrl);
    map['media_url'] = Variable<String>(mediaUrl);
    map['media_size_limit'] = Variable<int>(mediaSizeLimit);
    map['media_last_reset'] = Variable<DateTime>(mediaLastReset);
    map['total_media_sent'] = Variable<int>(totalMediaSent);
    map['server_name'] = Variable<String>(serverName);
    map['media_timer'] = Variable<int>(mediaTimer);
    map['max_payload'] = Variable<int>(maxPayload);
    map['capabilities'] = Variable<int>(capabilities);
    return map;
  }

  ServersCompanion toCompanion(bool nullToAbsent) {
    return ServersCompanion(
      serverId: Value(serverId),
      serverUrl: Value(serverUrl),
      mediaUrl: Value(mediaUrl),
      mediaSizeLimit: Value(mediaSizeLimit),
      mediaLastReset: Value(mediaLastReset),
      totalMediaSent: Value(totalMediaSent),
      serverName: Value(serverName),
      mediaTimer: Value(mediaTimer),
      maxPayload: Value(maxPayload),
      capabilities: Value(capabilities),
    );
  }

  factory Server.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Server(
      serverId: serializer.fromJson<String>(json['serverId']),
      serverUrl: serializer.fromJson<String>(json['serverUrl']),
      mediaUrl: serializer.fromJson<String>(json['mediaUrl']),
      mediaSizeLimit: serializer.fromJson<int>(json['mediaSizeLimit']),
      mediaLastReset: serializer.fromJson<DateTime>(json['mediaLastReset']),
      totalMediaSent: serializer.fromJson<int>(json['totalMediaSent']),
      serverName: serializer.fromJson<String>(json['serverName']),
      mediaTimer: serializer.fromJson<int>(json['mediaTimer']),
      maxPayload: serializer.fromJson<int>(json['maxPayload']),
      capabilities: serializer.fromJson<int>(json['capabilities']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serverId': serializer.toJson<String>(serverId),
      'serverUrl': serializer.toJson<String>(serverUrl),
      'mediaUrl': serializer.toJson<String>(mediaUrl),
      'mediaSizeLimit': serializer.toJson<int>(mediaSizeLimit),
      'mediaLastReset': serializer.toJson<DateTime>(mediaLastReset),
      'totalMediaSent': serializer.toJson<int>(totalMediaSent),
      'serverName': serializer.toJson<String>(serverName),
      'mediaTimer': serializer.toJson<int>(mediaTimer),
      'maxPayload': serializer.toJson<int>(maxPayload),
      'capabilities': serializer.toJson<int>(capabilities),
    };
  }

  Server copyWith({
    String? serverId,
    String? serverUrl,
    String? mediaUrl,
    int? mediaSizeLimit,
    DateTime? mediaLastReset,
    int? totalMediaSent,
    String? serverName,
    int? mediaTimer,
    int? maxPayload,
    int? capabilities,
  }) => Server(
    serverId: serverId ?? this.serverId,
    serverUrl: serverUrl ?? this.serverUrl,
    mediaUrl: mediaUrl ?? this.mediaUrl,
    mediaSizeLimit: mediaSizeLimit ?? this.mediaSizeLimit,
    mediaLastReset: mediaLastReset ?? this.mediaLastReset,
    totalMediaSent: totalMediaSent ?? this.totalMediaSent,
    serverName: serverName ?? this.serverName,
    mediaTimer: mediaTimer ?? this.mediaTimer,
    maxPayload: maxPayload ?? this.maxPayload,
    capabilities: capabilities ?? this.capabilities,
  );
  Server copyWithCompanion(ServersCompanion data) {
    return Server(
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      serverUrl: data.serverUrl.present ? data.serverUrl.value : this.serverUrl,
      mediaUrl: data.mediaUrl.present ? data.mediaUrl.value : this.mediaUrl,
      mediaSizeLimit: data.mediaSizeLimit.present
          ? data.mediaSizeLimit.value
          : this.mediaSizeLimit,
      mediaLastReset: data.mediaLastReset.present
          ? data.mediaLastReset.value
          : this.mediaLastReset,
      totalMediaSent: data.totalMediaSent.present
          ? data.totalMediaSent.value
          : this.totalMediaSent,
      serverName: data.serverName.present
          ? data.serverName.value
          : this.serverName,
      mediaTimer: data.mediaTimer.present
          ? data.mediaTimer.value
          : this.mediaTimer,
      maxPayload: data.maxPayload.present
          ? data.maxPayload.value
          : this.maxPayload,
      capabilities: data.capabilities.present
          ? data.capabilities.value
          : this.capabilities,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Server(')
          ..write('serverId: $serverId, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('mediaSizeLimit: $mediaSizeLimit, ')
          ..write('mediaLastReset: $mediaLastReset, ')
          ..write('totalMediaSent: $totalMediaSent, ')
          ..write('serverName: $serverName, ')
          ..write('mediaTimer: $mediaTimer, ')
          ..write('maxPayload: $maxPayload, ')
          ..write('capabilities: $capabilities')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    serverId,
    serverUrl,
    mediaUrl,
    mediaSizeLimit,
    mediaLastReset,
    totalMediaSent,
    serverName,
    mediaTimer,
    maxPayload,
    capabilities,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Server &&
          other.serverId == this.serverId &&
          other.serverUrl == this.serverUrl &&
          other.mediaUrl == this.mediaUrl &&
          other.mediaSizeLimit == this.mediaSizeLimit &&
          other.mediaLastReset == this.mediaLastReset &&
          other.totalMediaSent == this.totalMediaSent &&
          other.serverName == this.serverName &&
          other.mediaTimer == this.mediaTimer &&
          other.maxPayload == this.maxPayload &&
          other.capabilities == this.capabilities);
}

class ServersCompanion extends UpdateCompanion<Server> {
  final Value<String> serverId;
  final Value<String> serverUrl;
  final Value<String> mediaUrl;
  final Value<int> mediaSizeLimit;
  final Value<DateTime> mediaLastReset;
  final Value<int> totalMediaSent;
  final Value<String> serverName;
  final Value<int> mediaTimer;
  final Value<int> maxPayload;
  final Value<int> capabilities;
  final Value<int> rowid;
  const ServersCompanion({
    this.serverId = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.mediaSizeLimit = const Value.absent(),
    this.mediaLastReset = const Value.absent(),
    this.totalMediaSent = const Value.absent(),
    this.serverName = const Value.absent(),
    this.mediaTimer = const Value.absent(),
    this.maxPayload = const Value.absent(),
    this.capabilities = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServersCompanion.insert({
    required String serverId,
    required String serverUrl,
    required String mediaUrl,
    this.mediaSizeLimit = const Value.absent(),
    required DateTime mediaLastReset,
    this.totalMediaSent = const Value.absent(),
    required String serverName,
    this.mediaTimer = const Value.absent(),
    this.maxPayload = const Value.absent(),
    this.capabilities = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : serverId = Value(serverId),
       serverUrl = Value(serverUrl),
       mediaUrl = Value(mediaUrl),
       mediaLastReset = Value(mediaLastReset),
       serverName = Value(serverName);
  static Insertable<Server> custom({
    Expression<String>? serverId,
    Expression<String>? serverUrl,
    Expression<String>? mediaUrl,
    Expression<int>? mediaSizeLimit,
    Expression<DateTime>? mediaLastReset,
    Expression<int>? totalMediaSent,
    Expression<String>? serverName,
    Expression<int>? mediaTimer,
    Expression<int>? maxPayload,
    Expression<int>? capabilities,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverId != null) 'server_id': serverId,
      if (serverUrl != null) 'server_url': serverUrl,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (mediaSizeLimit != null) 'media_size_limit': mediaSizeLimit,
      if (mediaLastReset != null) 'media_last_reset': mediaLastReset,
      if (totalMediaSent != null) 'total_media_sent': totalMediaSent,
      if (serverName != null) 'server_name': serverName,
      if (mediaTimer != null) 'media_timer': mediaTimer,
      if (maxPayload != null) 'max_payload': maxPayload,
      if (capabilities != null) 'capabilities': capabilities,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServersCompanion copyWith({
    Value<String>? serverId,
    Value<String>? serverUrl,
    Value<String>? mediaUrl,
    Value<int>? mediaSizeLimit,
    Value<DateTime>? mediaLastReset,
    Value<int>? totalMediaSent,
    Value<String>? serverName,
    Value<int>? mediaTimer,
    Value<int>? maxPayload,
    Value<int>? capabilities,
    Value<int>? rowid,
  }) {
    return ServersCompanion(
      serverId: serverId ?? this.serverId,
      serverUrl: serverUrl ?? this.serverUrl,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaSizeLimit: mediaSizeLimit ?? this.mediaSizeLimit,
      mediaLastReset: mediaLastReset ?? this.mediaLastReset,
      totalMediaSent: totalMediaSent ?? this.totalMediaSent,
      serverName: serverName ?? this.serverName,
      mediaTimer: mediaTimer ?? this.mediaTimer,
      maxPayload: maxPayload ?? this.maxPayload,
      capabilities: capabilities ?? this.capabilities,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (serverUrl.present) {
      map['server_url'] = Variable<String>(serverUrl.value);
    }
    if (mediaUrl.present) {
      map['media_url'] = Variable<String>(mediaUrl.value);
    }
    if (mediaSizeLimit.present) {
      map['media_size_limit'] = Variable<int>(mediaSizeLimit.value);
    }
    if (mediaLastReset.present) {
      map['media_last_reset'] = Variable<DateTime>(mediaLastReset.value);
    }
    if (totalMediaSent.present) {
      map['total_media_sent'] = Variable<int>(totalMediaSent.value);
    }
    if (serverName.present) {
      map['server_name'] = Variable<String>(serverName.value);
    }
    if (mediaTimer.present) {
      map['media_timer'] = Variable<int>(mediaTimer.value);
    }
    if (maxPayload.present) {
      map['max_payload'] = Variable<int>(maxPayload.value);
    }
    if (capabilities.present) {
      map['capabilities'] = Variable<int>(capabilities.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServersCompanion(')
          ..write('serverId: $serverId, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('mediaSizeLimit: $mediaSizeLimit, ')
          ..write('mediaLastReset: $mediaLastReset, ')
          ..write('totalMediaSent: $totalMediaSent, ')
          ..write('serverName: $serverName, ')
          ..write('mediaTimer: $mediaTimer, ')
          ..write('maxPayload: $maxPayload, ')
          ..write('capabilities: $capabilities, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationTypeMeta = const VerificationMeta(
    'conversationType',
  );
  @override
  late final GeneratedColumn<int> conversationType = GeneratedColumn<int>(
    'conversation_type',
    aliasedName,
    false,
    check: () => conversationType.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastMessageIdMeta = const VerificationMeta(
    'lastMessageId',
  );
  @override
  late final GeneratedColumn<String> lastMessageId = GeneratedColumn<String>(
    'last_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageTimeMeta = const VerificationMeta(
    'lastMessageTime',
  );
  @override
  late final GeneratedColumn<int> lastMessageTime = GeneratedColumn<int>(
    'last_message_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mutedMeta = const VerificationMeta('muted');
  @override
  late final GeneratedColumn<int> muted = GeneratedColumn<int>(
    'muted',
    aliasedName,
    false,
    check: () => muted.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<int> pinned = GeneratedColumn<int>(
    'pinned',
    aliasedName,
    false,
    check: () => pinned.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<int> archived = GeneratedColumn<int>(
    'archived',
    aliasedName,
    false,
    check: () => archived.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _draftMeta = const VerificationMeta('draft');
  @override
  late final GeneratedColumn<String> draft = GeneratedColumn<String>(
    'draft',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soundMeta = const VerificationMeta('sound');
  @override
  late final GeneratedColumn<String> sound = GeneratedColumn<String>(
    'sound',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _badgeMeta = const VerificationMeta('badge');
  @override
  late final GeneratedColumn<int> badge = GeneratedColumn<int>(
    'badge',
    aliasedName,
    false,
    check: () => badge.isIn([0, 1, 2]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vibrationMeta = const VerificationMeta(
    'vibration',
  );
  @override
  late final GeneratedColumn<int> vibration = GeneratedColumn<int>(
    'vibration',
    aliasedName,
    false,
    check: () => vibration.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    conversationId,
    conversationType,
    lastMessageId,
    lastMessageTime,
    unreadCount,
    muted,
    pinned,
    archived,
    draft,
    serverId,
    createdAt,
    updatedAt,
    sound,
    badge,
    vibration,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('conversation_type')) {
      context.handle(
        _conversationTypeMeta,
        conversationType.isAcceptableOrUnknown(
          data['conversation_type']!,
          _conversationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationTypeMeta);
    }
    if (data.containsKey('last_message_id')) {
      context.handle(
        _lastMessageIdMeta,
        lastMessageId.isAcceptableOrUnknown(
          data['last_message_id']!,
          _lastMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('last_message_time')) {
      context.handle(
        _lastMessageTimeMeta,
        lastMessageTime.isAcceptableOrUnknown(
          data['last_message_time']!,
          _lastMessageTimeMeta,
        ),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('muted')) {
      context.handle(
        _mutedMeta,
        muted.isAcceptableOrUnknown(data['muted']!, _mutedMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('draft')) {
      context.handle(
        _draftMeta,
        draft.isAcceptableOrUnknown(data['draft']!, _draftMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sound')) {
      context.handle(
        _soundMeta,
        sound.isAcceptableOrUnknown(data['sound']!, _soundMeta),
      );
    }
    if (data.containsKey('badge')) {
      context.handle(
        _badgeMeta,
        badge.isAcceptableOrUnknown(data['badge']!, _badgeMeta),
      );
    }
    if (data.containsKey('vibration')) {
      context.handle(
        _vibrationMeta,
        vibration.isAcceptableOrUnknown(data['vibration']!, _vibrationMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conversationId};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      conversationType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_type'],
      )!,
      lastMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_id'],
      ),
      lastMessageTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_time'],
      ),
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      muted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}muted'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pinned'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archived'],
      )!,
      draft: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}draft'],
      ),
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      sound: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound'],
      ),
      badge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}badge'],
      )!,
      vibration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vibration'],
      )!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final String conversationId;
  final int conversationType;
  final String? lastMessageId;
  final int? lastMessageTime;
  final int unreadCount;
  final int muted;
  final int pinned;
  final int archived;
  final String? draft;
  final String serverId;
  final int createdAt;
  final int updatedAt;
  final String? sound;
  final int badge;
  final int vibration;
  const Conversation({
    required this.conversationId,
    required this.conversationType,
    this.lastMessageId,
    this.lastMessageTime,
    required this.unreadCount,
    required this.muted,
    required this.pinned,
    required this.archived,
    this.draft,
    required this.serverId,
    required this.createdAt,
    required this.updatedAt,
    this.sound,
    required this.badge,
    required this.vibration,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['conversation_id'] = Variable<String>(conversationId);
    map['conversation_type'] = Variable<int>(conversationType);
    if (!nullToAbsent || lastMessageId != null) {
      map['last_message_id'] = Variable<String>(lastMessageId);
    }
    if (!nullToAbsent || lastMessageTime != null) {
      map['last_message_time'] = Variable<int>(lastMessageTime);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    map['muted'] = Variable<int>(muted);
    map['pinned'] = Variable<int>(pinned);
    map['archived'] = Variable<int>(archived);
    if (!nullToAbsent || draft != null) {
      map['draft'] = Variable<String>(draft);
    }
    map['server_id'] = Variable<String>(serverId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || sound != null) {
      map['sound'] = Variable<String>(sound);
    }
    map['badge'] = Variable<int>(badge);
    map['vibration'] = Variable<int>(vibration);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      conversationId: Value(conversationId),
      conversationType: Value(conversationType),
      lastMessageId: lastMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageId),
      lastMessageTime: lastMessageTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageTime),
      unreadCount: Value(unreadCount),
      muted: Value(muted),
      pinned: Value(pinned),
      archived: Value(archived),
      draft: draft == null && nullToAbsent
          ? const Value.absent()
          : Value(draft),
      serverId: Value(serverId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      sound: sound == null && nullToAbsent
          ? const Value.absent()
          : Value(sound),
      badge: Value(badge),
      vibration: Value(vibration),
    );
  }

  factory Conversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      conversationId: serializer.fromJson<String>(json['conversationId']),
      conversationType: serializer.fromJson<int>(json['conversationType']),
      lastMessageId: serializer.fromJson<String?>(json['lastMessageId']),
      lastMessageTime: serializer.fromJson<int?>(json['lastMessageTime']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      muted: serializer.fromJson<int>(json['muted']),
      pinned: serializer.fromJson<int>(json['pinned']),
      archived: serializer.fromJson<int>(json['archived']),
      draft: serializer.fromJson<String?>(json['draft']),
      serverId: serializer.fromJson<String>(json['serverId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      sound: serializer.fromJson<String?>(json['sound']),
      badge: serializer.fromJson<int>(json['badge']),
      vibration: serializer.fromJson<int>(json['vibration']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conversationId': serializer.toJson<String>(conversationId),
      'conversationType': serializer.toJson<int>(conversationType),
      'lastMessageId': serializer.toJson<String?>(lastMessageId),
      'lastMessageTime': serializer.toJson<int?>(lastMessageTime),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'muted': serializer.toJson<int>(muted),
      'pinned': serializer.toJson<int>(pinned),
      'archived': serializer.toJson<int>(archived),
      'draft': serializer.toJson<String?>(draft),
      'serverId': serializer.toJson<String>(serverId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'sound': serializer.toJson<String?>(sound),
      'badge': serializer.toJson<int>(badge),
      'vibration': serializer.toJson<int>(vibration),
    };
  }

  Conversation copyWith({
    String? conversationId,
    int? conversationType,
    Value<String?> lastMessageId = const Value.absent(),
    Value<int?> lastMessageTime = const Value.absent(),
    int? unreadCount,
    int? muted,
    int? pinned,
    int? archived,
    Value<String?> draft = const Value.absent(),
    String? serverId,
    int? createdAt,
    int? updatedAt,
    Value<String?> sound = const Value.absent(),
    int? badge,
    int? vibration,
  }) => Conversation(
    conversationId: conversationId ?? this.conversationId,
    conversationType: conversationType ?? this.conversationType,
    lastMessageId: lastMessageId.present
        ? lastMessageId.value
        : this.lastMessageId,
    lastMessageTime: lastMessageTime.present
        ? lastMessageTime.value
        : this.lastMessageTime,
    unreadCount: unreadCount ?? this.unreadCount,
    muted: muted ?? this.muted,
    pinned: pinned ?? this.pinned,
    archived: archived ?? this.archived,
    draft: draft.present ? draft.value : this.draft,
    serverId: serverId ?? this.serverId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sound: sound.present ? sound.value : this.sound,
    badge: badge ?? this.badge,
    vibration: vibration ?? this.vibration,
  );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      conversationType: data.conversationType.present
          ? data.conversationType.value
          : this.conversationType,
      lastMessageId: data.lastMessageId.present
          ? data.lastMessageId.value
          : this.lastMessageId,
      lastMessageTime: data.lastMessageTime.present
          ? data.lastMessageTime.value
          : this.lastMessageTime,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      muted: data.muted.present ? data.muted.value : this.muted,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      archived: data.archived.present ? data.archived.value : this.archived,
      draft: data.draft.present ? data.draft.value : this.draft,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sound: data.sound.present ? data.sound.value : this.sound,
      badge: data.badge.present ? data.badge.value : this.badge,
      vibration: data.vibration.present ? data.vibration.value : this.vibration,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('conversationId: $conversationId, ')
          ..write('conversationType: $conversationType, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('muted: $muted, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('draft: $draft, ')
          ..write('serverId: $serverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sound: $sound, ')
          ..write('badge: $badge, ')
          ..write('vibration: $vibration')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    conversationId,
    conversationType,
    lastMessageId,
    lastMessageTime,
    unreadCount,
    muted,
    pinned,
    archived,
    draft,
    serverId,
    createdAt,
    updatedAt,
    sound,
    badge,
    vibration,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.conversationId == this.conversationId &&
          other.conversationType == this.conversationType &&
          other.lastMessageId == this.lastMessageId &&
          other.lastMessageTime == this.lastMessageTime &&
          other.unreadCount == this.unreadCount &&
          other.muted == this.muted &&
          other.pinned == this.pinned &&
          other.archived == this.archived &&
          other.draft == this.draft &&
          other.serverId == this.serverId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sound == this.sound &&
          other.badge == this.badge &&
          other.vibration == this.vibration);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<String> conversationId;
  final Value<int> conversationType;
  final Value<String?> lastMessageId;
  final Value<int?> lastMessageTime;
  final Value<int> unreadCount;
  final Value<int> muted;
  final Value<int> pinned;
  final Value<int> archived;
  final Value<String?> draft;
  final Value<String> serverId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String?> sound;
  final Value<int> badge;
  final Value<int> vibration;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.conversationId = const Value.absent(),
    this.conversationType = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.muted = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.draft = const Value.absent(),
    this.serverId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sound = const Value.absent(),
    this.badge = const Value.absent(),
    this.vibration = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String conversationId,
    required int conversationType,
    this.lastMessageId = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.muted = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.draft = const Value.absent(),
    required String serverId,
    required int createdAt,
    required int updatedAt,
    this.sound = const Value.absent(),
    this.badge = const Value.absent(),
    this.vibration = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : conversationId = Value(conversationId),
       conversationType = Value(conversationType),
       serverId = Value(serverId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Conversation> custom({
    Expression<String>? conversationId,
    Expression<int>? conversationType,
    Expression<String>? lastMessageId,
    Expression<int>? lastMessageTime,
    Expression<int>? unreadCount,
    Expression<int>? muted,
    Expression<int>? pinned,
    Expression<int>? archived,
    Expression<String>? draft,
    Expression<String>? serverId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? sound,
    Expression<int>? badge,
    Expression<int>? vibration,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (conversationId != null) 'conversation_id': conversationId,
      if (conversationType != null) 'conversation_type': conversationType,
      if (lastMessageId != null) 'last_message_id': lastMessageId,
      if (lastMessageTime != null) 'last_message_time': lastMessageTime,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (muted != null) 'muted': muted,
      if (pinned != null) 'pinned': pinned,
      if (archived != null) 'archived': archived,
      if (draft != null) 'draft': draft,
      if (serverId != null) 'server_id': serverId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sound != null) 'sound': sound,
      if (badge != null) 'badge': badge,
      if (vibration != null) 'vibration': vibration,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith({
    Value<String>? conversationId,
    Value<int>? conversationType,
    Value<String?>? lastMessageId,
    Value<int?>? lastMessageTime,
    Value<int>? unreadCount,
    Value<int>? muted,
    Value<int>? pinned,
    Value<int>? archived,
    Value<String?>? draft,
    Value<String>? serverId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String?>? sound,
    Value<int>? badge,
    Value<int>? vibration,
    Value<int>? rowid,
  }) {
    return ConversationsCompanion(
      conversationId: conversationId ?? this.conversationId,
      conversationType: conversationType ?? this.conversationType,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      muted: muted ?? this.muted,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      draft: draft ?? this.draft,
      serverId: serverId ?? this.serverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sound: sound ?? this.sound,
      badge: badge ?? this.badge,
      vibration: vibration ?? this.vibration,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (conversationType.present) {
      map['conversation_type'] = Variable<int>(conversationType.value);
    }
    if (lastMessageId.present) {
      map['last_message_id'] = Variable<String>(lastMessageId.value);
    }
    if (lastMessageTime.present) {
      map['last_message_time'] = Variable<int>(lastMessageTime.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (muted.present) {
      map['muted'] = Variable<int>(muted.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<int>(pinned.value);
    }
    if (archived.present) {
      map['archived'] = Variable<int>(archived.value);
    }
    if (draft.present) {
      map['draft'] = Variable<String>(draft.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (sound.present) {
      map['sound'] = Variable<String>(sound.value);
    }
    if (badge.present) {
      map['badge'] = Variable<int>(badge.value);
    }
    if (vibration.present) {
      map['vibration'] = Variable<int>(vibration.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('conversationId: $conversationId, ')
          ..write('conversationType: $conversationType, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('muted: $muted, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('draft: $draft, ')
          ..write('serverId: $serverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sound: $sound, ')
          ..write('badge: $badge, ')
          ..write('vibration: $vibration, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logicalMessageIdMeta = const VerificationMeta(
    'logicalMessageId',
  );
  @override
  late final GeneratedColumn<String> logicalMessageId = GeneratedColumn<String>(
    'logical_message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES conversations (conversation_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderSequenceMeta = const VerificationMeta(
    'senderSequence',
  );
  @override
  late final GeneratedColumn<int> senderSequence = GeneratedColumn<int>(
    'sender_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageOrderMeta = const VerificationMeta(
    'messageOrder',
  );
  @override
  late final GeneratedColumn<int> messageOrder = GeneratedColumn<int>(
    'message_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chainIndexMeta = const VerificationMeta(
    'chainIndex',
  );
  @override
  late final GeneratedColumn<int> chainIndex = GeneratedColumn<int>(
    'chain_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    '_timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ciphertextMeta = const VerificationMeta(
    'ciphertext',
  );
  @override
  late final GeneratedColumn<Uint8List> ciphertext = GeneratedColumn<Uint8List>(
    'ciphertext',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nonceMeta = const VerificationMeta('nonce');
  @override
  late final GeneratedColumn<Uint8List> nonce = GeneratedColumn<Uint8List>(
    'nonce',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageTypeMeta = const VerificationMeta(
    'messageType',
  );
  @override
  late final GeneratedColumn<int> messageType = GeneratedColumn<int>(
    'message_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    '_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _macMeta = const VerificationMeta('mac');
  @override
  late final GeneratedColumn<Uint8List> mac = GeneratedColumn<Uint8List>(
    'mac',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _replyToMeta = const VerificationMeta(
    'replyTo',
  );
  @override
  late final GeneratedColumn<String> replyTo = GeneratedColumn<String>(
    'reply_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _editedMeta = const VerificationMeta('edited');
  @override
  late final GeneratedColumn<int> edited = GeneratedColumn<int>(
    'edited',
    aliasedName,
    false,
    check: () => edited.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _protocolVersionMeta = const VerificationMeta(
    'protocolVersion',
  );
  @override
  late final GeneratedColumn<int> protocolVersion = GeneratedColumn<int>(
    'protocol_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<int> receivedAt = GeneratedColumn<int>(
    'received_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<int> readAt = GeneratedColumn<int>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    messageId,
    logicalMessageId,
    conversationId,
    senderId,
    senderSequence,
    messageOrder,
    chainIndex,
    timestamp,
    ciphertext,
    nonce,
    messageType,
    status,
    mac,
    replyTo,
    edited,
    protocolVersion,
    receivedAt,
    readAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('logical_message_id')) {
      context.handle(
        _logicalMessageIdMeta,
        logicalMessageId.isAcceptableOrUnknown(
          data['logical_message_id']!,
          _logicalMessageIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_logicalMessageIdMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('sender_sequence')) {
      context.handle(
        _senderSequenceMeta,
        senderSequence.isAcceptableOrUnknown(
          data['sender_sequence']!,
          _senderSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_senderSequenceMeta);
    }
    if (data.containsKey('message_order')) {
      context.handle(
        _messageOrderMeta,
        messageOrder.isAcceptableOrUnknown(
          data['message_order']!,
          _messageOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageOrderMeta);
    }
    if (data.containsKey('chain_index')) {
      context.handle(
        _chainIndexMeta,
        chainIndex.isAcceptableOrUnknown(data['chain_index']!, _chainIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_chainIndexMeta);
    }
    if (data.containsKey('_timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['_timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('ciphertext')) {
      context.handle(
        _ciphertextMeta,
        ciphertext.isAcceptableOrUnknown(data['ciphertext']!, _ciphertextMeta),
      );
    } else if (isInserting) {
      context.missing(_ciphertextMeta);
    }
    if (data.containsKey('nonce')) {
      context.handle(
        _nonceMeta,
        nonce.isAcceptableOrUnknown(data['nonce']!, _nonceMeta),
      );
    } else if (isInserting) {
      context.missing(_nonceMeta);
    }
    if (data.containsKey('message_type')) {
      context.handle(
        _messageTypeMeta,
        messageType.isAcceptableOrUnknown(
          data['message_type']!,
          _messageTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageTypeMeta);
    }
    if (data.containsKey('_status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['_status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('mac')) {
      context.handle(
        _macMeta,
        mac.isAcceptableOrUnknown(data['mac']!, _macMeta),
      );
    } else if (isInserting) {
      context.missing(_macMeta);
    }
    if (data.containsKey('reply_to')) {
      context.handle(
        _replyToMeta,
        replyTo.isAcceptableOrUnknown(data['reply_to']!, _replyToMeta),
      );
    }
    if (data.containsKey('edited')) {
      context.handle(
        _editedMeta,
        edited.isAcceptableOrUnknown(data['edited']!, _editedMeta),
      );
    }
    if (data.containsKey('protocol_version')) {
      context.handle(
        _protocolVersionMeta,
        protocolVersion.isAcceptableOrUnknown(
          data['protocol_version']!,
          _protocolVersionMeta,
        ),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      logicalMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logical_message_id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      senderSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sender_sequence'],
      )!,
      messageOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_order'],
      )!,
      chainIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chain_index'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}_timestamp'],
      )!,
      ciphertext: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}ciphertext'],
      )!,
      nonce: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}nonce'],
      )!,
      messageType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}_status'],
      )!,
      mac: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}mac'],
      )!,
      replyTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_to'],
      ),
      edited: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edited'],
      )!,
      protocolVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protocol_version'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received_at'],
      ),
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}read_at'],
      ),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String messageId;
  final String logicalMessageId;
  final String conversationId;
  final String senderId;
  final int senderSequence;
  final int messageOrder;
  final int chainIndex;
  final int timestamp;
  final Uint8List ciphertext;
  final Uint8List nonce;
  final int messageType;
  final int status;
  final Uint8List mac;
  final String? replyTo;
  final int edited;
  final int protocolVersion;
  final int? receivedAt;
  final int? readAt;
  const Message({
    required this.messageId,
    required this.logicalMessageId,
    required this.conversationId,
    required this.senderId,
    required this.senderSequence,
    required this.messageOrder,
    required this.chainIndex,
    required this.timestamp,
    required this.ciphertext,
    required this.nonce,
    required this.messageType,
    required this.status,
    required this.mac,
    this.replyTo,
    required this.edited,
    required this.protocolVersion,
    this.receivedAt,
    this.readAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<String>(messageId);
    map['logical_message_id'] = Variable<String>(logicalMessageId);
    map['conversation_id'] = Variable<String>(conversationId);
    map['sender_id'] = Variable<String>(senderId);
    map['sender_sequence'] = Variable<int>(senderSequence);
    map['message_order'] = Variable<int>(messageOrder);
    map['chain_index'] = Variable<int>(chainIndex);
    map['_timestamp'] = Variable<int>(timestamp);
    map['ciphertext'] = Variable<Uint8List>(ciphertext);
    map['nonce'] = Variable<Uint8List>(nonce);
    map['message_type'] = Variable<int>(messageType);
    map['_status'] = Variable<int>(status);
    map['mac'] = Variable<Uint8List>(mac);
    if (!nullToAbsent || replyTo != null) {
      map['reply_to'] = Variable<String>(replyTo);
    }
    map['edited'] = Variable<int>(edited);
    map['protocol_version'] = Variable<int>(protocolVersion);
    if (!nullToAbsent || receivedAt != null) {
      map['received_at'] = Variable<int>(receivedAt);
    }
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<int>(readAt);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      messageId: Value(messageId),
      logicalMessageId: Value(logicalMessageId),
      conversationId: Value(conversationId),
      senderId: Value(senderId),
      senderSequence: Value(senderSequence),
      messageOrder: Value(messageOrder),
      chainIndex: Value(chainIndex),
      timestamp: Value(timestamp),
      ciphertext: Value(ciphertext),
      nonce: Value(nonce),
      messageType: Value(messageType),
      status: Value(status),
      mac: Value(mac),
      replyTo: replyTo == null && nullToAbsent
          ? const Value.absent()
          : Value(replyTo),
      edited: Value(edited),
      protocolVersion: Value(protocolVersion),
      receivedAt: receivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAt),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      messageId: serializer.fromJson<String>(json['messageId']),
      logicalMessageId: serializer.fromJson<String>(json['logicalMessageId']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      senderSequence: serializer.fromJson<int>(json['senderSequence']),
      messageOrder: serializer.fromJson<int>(json['messageOrder']),
      chainIndex: serializer.fromJson<int>(json['chainIndex']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      ciphertext: serializer.fromJson<Uint8List>(json['ciphertext']),
      nonce: serializer.fromJson<Uint8List>(json['nonce']),
      messageType: serializer.fromJson<int>(json['messageType']),
      status: serializer.fromJson<int>(json['status']),
      mac: serializer.fromJson<Uint8List>(json['mac']),
      replyTo: serializer.fromJson<String?>(json['replyTo']),
      edited: serializer.fromJson<int>(json['edited']),
      protocolVersion: serializer.fromJson<int>(json['protocolVersion']),
      receivedAt: serializer.fromJson<int?>(json['receivedAt']),
      readAt: serializer.fromJson<int?>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<String>(messageId),
      'logicalMessageId': serializer.toJson<String>(logicalMessageId),
      'conversationId': serializer.toJson<String>(conversationId),
      'senderId': serializer.toJson<String>(senderId),
      'senderSequence': serializer.toJson<int>(senderSequence),
      'messageOrder': serializer.toJson<int>(messageOrder),
      'chainIndex': serializer.toJson<int>(chainIndex),
      'timestamp': serializer.toJson<int>(timestamp),
      'ciphertext': serializer.toJson<Uint8List>(ciphertext),
      'nonce': serializer.toJson<Uint8List>(nonce),
      'messageType': serializer.toJson<int>(messageType),
      'status': serializer.toJson<int>(status),
      'mac': serializer.toJson<Uint8List>(mac),
      'replyTo': serializer.toJson<String?>(replyTo),
      'edited': serializer.toJson<int>(edited),
      'protocolVersion': serializer.toJson<int>(protocolVersion),
      'receivedAt': serializer.toJson<int?>(receivedAt),
      'readAt': serializer.toJson<int?>(readAt),
    };
  }

  Message copyWith({
    String? messageId,
    String? logicalMessageId,
    String? conversationId,
    String? senderId,
    int? senderSequence,
    int? messageOrder,
    int? chainIndex,
    int? timestamp,
    Uint8List? ciphertext,
    Uint8List? nonce,
    int? messageType,
    int? status,
    Uint8List? mac,
    Value<String?> replyTo = const Value.absent(),
    int? edited,
    int? protocolVersion,
    Value<int?> receivedAt = const Value.absent(),
    Value<int?> readAt = const Value.absent(),
  }) => Message(
    messageId: messageId ?? this.messageId,
    logicalMessageId: logicalMessageId ?? this.logicalMessageId,
    conversationId: conversationId ?? this.conversationId,
    senderId: senderId ?? this.senderId,
    senderSequence: senderSequence ?? this.senderSequence,
    messageOrder: messageOrder ?? this.messageOrder,
    chainIndex: chainIndex ?? this.chainIndex,
    timestamp: timestamp ?? this.timestamp,
    ciphertext: ciphertext ?? this.ciphertext,
    nonce: nonce ?? this.nonce,
    messageType: messageType ?? this.messageType,
    status: status ?? this.status,
    mac: mac ?? this.mac,
    replyTo: replyTo.present ? replyTo.value : this.replyTo,
    edited: edited ?? this.edited,
    protocolVersion: protocolVersion ?? this.protocolVersion,
    receivedAt: receivedAt.present ? receivedAt.value : this.receivedAt,
    readAt: readAt.present ? readAt.value : this.readAt,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      logicalMessageId: data.logicalMessageId.present
          ? data.logicalMessageId.value
          : this.logicalMessageId,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      senderSequence: data.senderSequence.present
          ? data.senderSequence.value
          : this.senderSequence,
      messageOrder: data.messageOrder.present
          ? data.messageOrder.value
          : this.messageOrder,
      chainIndex: data.chainIndex.present
          ? data.chainIndex.value
          : this.chainIndex,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      ciphertext: data.ciphertext.present
          ? data.ciphertext.value
          : this.ciphertext,
      nonce: data.nonce.present ? data.nonce.value : this.nonce,
      messageType: data.messageType.present
          ? data.messageType.value
          : this.messageType,
      status: data.status.present ? data.status.value : this.status,
      mac: data.mac.present ? data.mac.value : this.mac,
      replyTo: data.replyTo.present ? data.replyTo.value : this.replyTo,
      edited: data.edited.present ? data.edited.value : this.edited,
      protocolVersion: data.protocolVersion.present
          ? data.protocolVersion.value
          : this.protocolVersion,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('messageId: $messageId, ')
          ..write('logicalMessageId: $logicalMessageId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('senderSequence: $senderSequence, ')
          ..write('messageOrder: $messageOrder, ')
          ..write('chainIndex: $chainIndex, ')
          ..write('timestamp: $timestamp, ')
          ..write('ciphertext: $ciphertext, ')
          ..write('nonce: $nonce, ')
          ..write('messageType: $messageType, ')
          ..write('status: $status, ')
          ..write('mac: $mac, ')
          ..write('replyTo: $replyTo, ')
          ..write('edited: $edited, ')
          ..write('protocolVersion: $protocolVersion, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    messageId,
    logicalMessageId,
    conversationId,
    senderId,
    senderSequence,
    messageOrder,
    chainIndex,
    timestamp,
    $driftBlobEquality.hash(ciphertext),
    $driftBlobEquality.hash(nonce),
    messageType,
    status,
    $driftBlobEquality.hash(mac),
    replyTo,
    edited,
    protocolVersion,
    receivedAt,
    readAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.messageId == this.messageId &&
          other.logicalMessageId == this.logicalMessageId &&
          other.conversationId == this.conversationId &&
          other.senderId == this.senderId &&
          other.senderSequence == this.senderSequence &&
          other.messageOrder == this.messageOrder &&
          other.chainIndex == this.chainIndex &&
          other.timestamp == this.timestamp &&
          $driftBlobEquality.equals(other.ciphertext, this.ciphertext) &&
          $driftBlobEquality.equals(other.nonce, this.nonce) &&
          other.messageType == this.messageType &&
          other.status == this.status &&
          $driftBlobEquality.equals(other.mac, this.mac) &&
          other.replyTo == this.replyTo &&
          other.edited == this.edited &&
          other.protocolVersion == this.protocolVersion &&
          other.receivedAt == this.receivedAt &&
          other.readAt == this.readAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> messageId;
  final Value<String> logicalMessageId;
  final Value<String> conversationId;
  final Value<String> senderId;
  final Value<int> senderSequence;
  final Value<int> messageOrder;
  final Value<int> chainIndex;
  final Value<int> timestamp;
  final Value<Uint8List> ciphertext;
  final Value<Uint8List> nonce;
  final Value<int> messageType;
  final Value<int> status;
  final Value<Uint8List> mac;
  final Value<String?> replyTo;
  final Value<int> edited;
  final Value<int> protocolVersion;
  final Value<int?> receivedAt;
  final Value<int?> readAt;
  final Value<int> rowid;
  const MessagesCompanion({
    this.messageId = const Value.absent(),
    this.logicalMessageId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.senderSequence = const Value.absent(),
    this.messageOrder = const Value.absent(),
    this.chainIndex = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.ciphertext = const Value.absent(),
    this.nonce = const Value.absent(),
    this.messageType = const Value.absent(),
    this.status = const Value.absent(),
    this.mac = const Value.absent(),
    this.replyTo = const Value.absent(),
    this.edited = const Value.absent(),
    this.protocolVersion = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String messageId,
    required String logicalMessageId,
    required String conversationId,
    required String senderId,
    required int senderSequence,
    required int messageOrder,
    required int chainIndex,
    required int timestamp,
    required Uint8List ciphertext,
    required Uint8List nonce,
    required int messageType,
    required int status,
    required Uint8List mac,
    this.replyTo = const Value.absent(),
    this.edited = const Value.absent(),
    this.protocolVersion = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : messageId = Value(messageId),
       logicalMessageId = Value(logicalMessageId),
       conversationId = Value(conversationId),
       senderId = Value(senderId),
       senderSequence = Value(senderSequence),
       messageOrder = Value(messageOrder),
       chainIndex = Value(chainIndex),
       timestamp = Value(timestamp),
       ciphertext = Value(ciphertext),
       nonce = Value(nonce),
       messageType = Value(messageType),
       status = Value(status),
       mac = Value(mac);
  static Insertable<Message> custom({
    Expression<String>? messageId,
    Expression<String>? logicalMessageId,
    Expression<String>? conversationId,
    Expression<String>? senderId,
    Expression<int>? senderSequence,
    Expression<int>? messageOrder,
    Expression<int>? chainIndex,
    Expression<int>? timestamp,
    Expression<Uint8List>? ciphertext,
    Expression<Uint8List>? nonce,
    Expression<int>? messageType,
    Expression<int>? status,
    Expression<Uint8List>? mac,
    Expression<String>? replyTo,
    Expression<int>? edited,
    Expression<int>? protocolVersion,
    Expression<int>? receivedAt,
    Expression<int>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (logicalMessageId != null) 'logical_message_id': logicalMessageId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderId != null) 'sender_id': senderId,
      if (senderSequence != null) 'sender_sequence': senderSequence,
      if (messageOrder != null) 'message_order': messageOrder,
      if (chainIndex != null) 'chain_index': chainIndex,
      if (timestamp != null) '_timestamp': timestamp,
      if (ciphertext != null) 'ciphertext': ciphertext,
      if (nonce != null) 'nonce': nonce,
      if (messageType != null) 'message_type': messageType,
      if (status != null) '_status': status,
      if (mac != null) 'mac': mac,
      if (replyTo != null) 'reply_to': replyTo,
      if (edited != null) 'edited': edited,
      if (protocolVersion != null) 'protocol_version': protocolVersion,
      if (receivedAt != null) 'received_at': receivedAt,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? messageId,
    Value<String>? logicalMessageId,
    Value<String>? conversationId,
    Value<String>? senderId,
    Value<int>? senderSequence,
    Value<int>? messageOrder,
    Value<int>? chainIndex,
    Value<int>? timestamp,
    Value<Uint8List>? ciphertext,
    Value<Uint8List>? nonce,
    Value<int>? messageType,
    Value<int>? status,
    Value<Uint8List>? mac,
    Value<String?>? replyTo,
    Value<int>? edited,
    Value<int>? protocolVersion,
    Value<int?>? receivedAt,
    Value<int?>? readAt,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      messageId: messageId ?? this.messageId,
      logicalMessageId: logicalMessageId ?? this.logicalMessageId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderSequence: senderSequence ?? this.senderSequence,
      messageOrder: messageOrder ?? this.messageOrder,
      chainIndex: chainIndex ?? this.chainIndex,
      timestamp: timestamp ?? this.timestamp,
      ciphertext: ciphertext ?? this.ciphertext,
      nonce: nonce ?? this.nonce,
      messageType: messageType ?? this.messageType,
      status: status ?? this.status,
      mac: mac ?? this.mac,
      replyTo: replyTo ?? this.replyTo,
      edited: edited ?? this.edited,
      protocolVersion: protocolVersion ?? this.protocolVersion,
      receivedAt: receivedAt ?? this.receivedAt,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (logicalMessageId.present) {
      map['logical_message_id'] = Variable<String>(logicalMessageId.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (senderSequence.present) {
      map['sender_sequence'] = Variable<int>(senderSequence.value);
    }
    if (messageOrder.present) {
      map['message_order'] = Variable<int>(messageOrder.value);
    }
    if (chainIndex.present) {
      map['chain_index'] = Variable<int>(chainIndex.value);
    }
    if (timestamp.present) {
      map['_timestamp'] = Variable<int>(timestamp.value);
    }
    if (ciphertext.present) {
      map['ciphertext'] = Variable<Uint8List>(ciphertext.value);
    }
    if (nonce.present) {
      map['nonce'] = Variable<Uint8List>(nonce.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<int>(messageType.value);
    }
    if (status.present) {
      map['_status'] = Variable<int>(status.value);
    }
    if (mac.present) {
      map['mac'] = Variable<Uint8List>(mac.value);
    }
    if (replyTo.present) {
      map['reply_to'] = Variable<String>(replyTo.value);
    }
    if (edited.present) {
      map['edited'] = Variable<int>(edited.value);
    }
    if (protocolVersion.present) {
      map['protocol_version'] = Variable<int>(protocolVersion.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<int>(receivedAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<int>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('messageId: $messageId, ')
          ..write('logicalMessageId: $logicalMessageId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('senderSequence: $senderSequence, ')
          ..write('messageOrder: $messageOrder, ')
          ..write('chainIndex: $chainIndex, ')
          ..write('timestamp: $timestamp, ')
          ..write('ciphertext: $ciphertext, ')
          ..write('nonce: $nonce, ')
          ..write('messageType: $messageType, ')
          ..write('status: $status, ')
          ..write('mac: $mac, ')
          ..write('replyTo: $replyTo, ')
          ..write('edited: $edited, ')
          ..write('protocolVersion: $protocolVersion, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
    'contact_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _mutedMeta = const VerificationMeta('muted');
  @override
  late final GeneratedColumn<int> muted = GeneratedColumn<int>(
    'muted',
    aliasedName,
    false,
    check: () => muted.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<int> pinned = GeneratedColumn<int>(
    'pinned',
    aliasedName,
    false,
    check: () => pinned.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isOnlineMeta = const VerificationMeta(
    'isOnline',
  );
  @override
  late final GeneratedColumn<int> isOnline = GeneratedColumn<int>(
    'is_online',
    aliasedName,
    false,
    check: () => isOnline.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  @override
  late final GeneratedColumn<int> lastSeen = GeneratedColumn<int>(
    'last_seen',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _connectionStatusMeta = const VerificationMeta(
    'connectionStatus',
  );
  @override
  late final GeneratedColumn<int> connectionStatus = GeneratedColumn<int>(
    'connection_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ignorePingMeta = const VerificationMeta(
    'ignorePing',
  );
  @override
  late final GeneratedColumn<int> ignorePing = GeneratedColumn<int>(
    'ignore_ping',
    aliasedName,
    false,
    check: () => ignorePing.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES conversations (conversation_id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    contactId,
    nickname,
    avatar,
    bio,
    muted,
    pinned,
    isOnline,
    lastSeen,
    connectionStatus,
    serverId,
    createdAt,
    updatedAt,
    ignorePing,
    conversationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Contact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
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
    if (data.containsKey('muted')) {
      context.handle(
        _mutedMeta,
        muted.isAcceptableOrUnknown(data['muted']!, _mutedMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('is_online')) {
      context.handle(
        _isOnlineMeta,
        isOnline.isAcceptableOrUnknown(data['is_online']!, _isOnlineMeta),
      );
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    }
    if (data.containsKey('connection_status')) {
      context.handle(
        _connectionStatusMeta,
        connectionStatus.isAcceptableOrUnknown(
          data['connection_status']!,
          _connectionStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectionStatusMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('ignore_ping')) {
      context.handle(
        _ignorePingMeta,
        ignorePing.isAcceptableOrUnknown(data['ignore_ping']!, _ignorePingMeta),
      );
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {contactId};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      ),
      muted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}muted'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pinned'],
      )!,
      isOnline: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_online'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen'],
      ),
      connectionStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}connection_status'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      ignorePing: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ignore_ping'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      ),
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  final String contactId;
  final String? nickname;
  final String? avatar;
  final String? bio;
  final int muted;
  final int pinned;
  final int isOnline;
  final int? lastSeen;
  final int connectionStatus;
  final String serverId;
  final int createdAt;
  final int updatedAt;
  final int ignorePing;
  final String? conversationId;
  const Contact({
    required this.contactId,
    this.nickname,
    this.avatar,
    this.bio,
    required this.muted,
    required this.pinned,
    required this.isOnline,
    this.lastSeen,
    required this.connectionStatus,
    required this.serverId,
    required this.createdAt,
    required this.updatedAt,
    required this.ignorePing,
    this.conversationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['contact_id'] = Variable<String>(contactId);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    map['muted'] = Variable<int>(muted);
    map['pinned'] = Variable<int>(pinned);
    map['is_online'] = Variable<int>(isOnline);
    if (!nullToAbsent || lastSeen != null) {
      map['last_seen'] = Variable<int>(lastSeen);
    }
    map['connection_status'] = Variable<int>(connectionStatus);
    map['server_id'] = Variable<String>(serverId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['ignore_ping'] = Variable<int>(ignorePing);
    if (!nullToAbsent || conversationId != null) {
      map['conversation_id'] = Variable<String>(conversationId);
    }
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      contactId: Value(contactId),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      avatar: avatar == null && nullToAbsent
          ? const Value.absent()
          : Value(avatar),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
      muted: Value(muted),
      pinned: Value(pinned),
      isOnline: Value(isOnline),
      lastSeen: lastSeen == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeen),
      connectionStatus: Value(connectionStatus),
      serverId: Value(serverId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      ignorePing: Value(ignorePing),
      conversationId: conversationId == null && nullToAbsent
          ? const Value.absent()
          : Value(conversationId),
    );
  }

  factory Contact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      contactId: serializer.fromJson<String>(json['contactId']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      bio: serializer.fromJson<String?>(json['bio']),
      muted: serializer.fromJson<int>(json['muted']),
      pinned: serializer.fromJson<int>(json['pinned']),
      isOnline: serializer.fromJson<int>(json['isOnline']),
      lastSeen: serializer.fromJson<int?>(json['lastSeen']),
      connectionStatus: serializer.fromJson<int>(json['connectionStatus']),
      serverId: serializer.fromJson<String>(json['serverId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      ignorePing: serializer.fromJson<int>(json['ignorePing']),
      conversationId: serializer.fromJson<String?>(json['conversationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'contactId': serializer.toJson<String>(contactId),
      'nickname': serializer.toJson<String?>(nickname),
      'avatar': serializer.toJson<String?>(avatar),
      'bio': serializer.toJson<String?>(bio),
      'muted': serializer.toJson<int>(muted),
      'pinned': serializer.toJson<int>(pinned),
      'isOnline': serializer.toJson<int>(isOnline),
      'lastSeen': serializer.toJson<int?>(lastSeen),
      'connectionStatus': serializer.toJson<int>(connectionStatus),
      'serverId': serializer.toJson<String>(serverId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'ignorePing': serializer.toJson<int>(ignorePing),
      'conversationId': serializer.toJson<String?>(conversationId),
    };
  }

  Contact copyWith({
    String? contactId,
    Value<String?> nickname = const Value.absent(),
    Value<String?> avatar = const Value.absent(),
    Value<String?> bio = const Value.absent(),
    int? muted,
    int? pinned,
    int? isOnline,
    Value<int?> lastSeen = const Value.absent(),
    int? connectionStatus,
    String? serverId,
    int? createdAt,
    int? updatedAt,
    int? ignorePing,
    Value<String?> conversationId = const Value.absent(),
  }) => Contact(
    contactId: contactId ?? this.contactId,
    nickname: nickname.present ? nickname.value : this.nickname,
    avatar: avatar.present ? avatar.value : this.avatar,
    bio: bio.present ? bio.value : this.bio,
    muted: muted ?? this.muted,
    pinned: pinned ?? this.pinned,
    isOnline: isOnline ?? this.isOnline,
    lastSeen: lastSeen.present ? lastSeen.value : this.lastSeen,
    connectionStatus: connectionStatus ?? this.connectionStatus,
    serverId: serverId ?? this.serverId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    ignorePing: ignorePing ?? this.ignorePing,
    conversationId: conversationId.present
        ? conversationId.value
        : this.conversationId,
  );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      bio: data.bio.present ? data.bio.value : this.bio,
      muted: data.muted.present ? data.muted.value : this.muted,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      isOnline: data.isOnline.present ? data.isOnline.value : this.isOnline,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
      connectionStatus: data.connectionStatus.present
          ? data.connectionStatus.value
          : this.connectionStatus,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      ignorePing: data.ignorePing.present
          ? data.ignorePing.value
          : this.ignorePing,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('contactId: $contactId, ')
          ..write('nickname: $nickname, ')
          ..write('avatar: $avatar, ')
          ..write('bio: $bio, ')
          ..write('muted: $muted, ')
          ..write('pinned: $pinned, ')
          ..write('isOnline: $isOnline, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('connectionStatus: $connectionStatus, ')
          ..write('serverId: $serverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('ignorePing: $ignorePing, ')
          ..write('conversationId: $conversationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    contactId,
    nickname,
    avatar,
    bio,
    muted,
    pinned,
    isOnline,
    lastSeen,
    connectionStatus,
    serverId,
    createdAt,
    updatedAt,
    ignorePing,
    conversationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.contactId == this.contactId &&
          other.nickname == this.nickname &&
          other.avatar == this.avatar &&
          other.bio == this.bio &&
          other.muted == this.muted &&
          other.pinned == this.pinned &&
          other.isOnline == this.isOnline &&
          other.lastSeen == this.lastSeen &&
          other.connectionStatus == this.connectionStatus &&
          other.serverId == this.serverId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.ignorePing == this.ignorePing &&
          other.conversationId == this.conversationId);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<String> contactId;
  final Value<String?> nickname;
  final Value<String?> avatar;
  final Value<String?> bio;
  final Value<int> muted;
  final Value<int> pinned;
  final Value<int> isOnline;
  final Value<int?> lastSeen;
  final Value<int> connectionStatus;
  final Value<String> serverId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> ignorePing;
  final Value<String?> conversationId;
  final Value<int> rowid;
  const ContactsCompanion({
    this.contactId = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avatar = const Value.absent(),
    this.bio = const Value.absent(),
    this.muted = const Value.absent(),
    this.pinned = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.connectionStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.ignorePing = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsCompanion.insert({
    required String contactId,
    this.nickname = const Value.absent(),
    this.avatar = const Value.absent(),
    this.bio = const Value.absent(),
    this.muted = const Value.absent(),
    this.pinned = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.lastSeen = const Value.absent(),
    required int connectionStatus,
    required String serverId,
    required int createdAt,
    required int updatedAt,
    this.ignorePing = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : contactId = Value(contactId),
       connectionStatus = Value(connectionStatus),
       serverId = Value(serverId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Contact> custom({
    Expression<String>? contactId,
    Expression<String>? nickname,
    Expression<String>? avatar,
    Expression<String>? bio,
    Expression<int>? muted,
    Expression<int>? pinned,
    Expression<int>? isOnline,
    Expression<int>? lastSeen,
    Expression<int>? connectionStatus,
    Expression<String>? serverId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? ignorePing,
    Expression<String>? conversationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (contactId != null) 'contact_id': contactId,
      if (nickname != null) 'nickname': nickname,
      if (avatar != null) 'avatar': avatar,
      if (bio != null) 'bio': bio,
      if (muted != null) 'muted': muted,
      if (pinned != null) 'pinned': pinned,
      if (isOnline != null) 'is_online': isOnline,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (connectionStatus != null) 'connection_status': connectionStatus,
      if (serverId != null) 'server_id': serverId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (ignorePing != null) 'ignore_ping': ignorePing,
      if (conversationId != null) 'conversation_id': conversationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsCompanion copyWith({
    Value<String>? contactId,
    Value<String?>? nickname,
    Value<String?>? avatar,
    Value<String?>? bio,
    Value<int>? muted,
    Value<int>? pinned,
    Value<int>? isOnline,
    Value<int?>? lastSeen,
    Value<int>? connectionStatus,
    Value<String>? serverId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? ignorePing,
    Value<String?>? conversationId,
    Value<int>? rowid,
  }) {
    return ContactsCompanion(
      contactId: contactId ?? this.contactId,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      muted: muted ?? this.muted,
      pinned: pinned ?? this.pinned,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      serverId: serverId ?? this.serverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ignorePing: ignorePing ?? this.ignorePing,
      conversationId: conversationId ?? this.conversationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (muted.present) {
      map['muted'] = Variable<int>(muted.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<int>(pinned.value);
    }
    if (isOnline.present) {
      map['is_online'] = Variable<int>(isOnline.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<int>(lastSeen.value);
    }
    if (connectionStatus.present) {
      map['connection_status'] = Variable<int>(connectionStatus.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (ignorePing.present) {
      map['ignore_ping'] = Variable<int>(ignorePing.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('contactId: $contactId, ')
          ..write('nickname: $nickname, ')
          ..write('avatar: $avatar, ')
          ..write('bio: $bio, ')
          ..write('muted: $muted, ')
          ..write('pinned: $pinned, ')
          ..write('isOnline: $isOnline, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('connectionStatus: $connectionStatus, ')
          ..write('serverId: $serverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('ignorePing: $ignorePing, ')
          ..write('conversationId: $conversationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactsNetworkTable extends ContactsNetwork
    with TableInfo<$ContactsNetworkTable, ContactsNetworkData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsNetworkTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _networkIdMeta = const VerificationMeta(
    'networkId',
  );
  @override
  late final GeneratedColumn<String> networkId = GeneratedColumn<String>(
    'network_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _networkNameMeta = const VerificationMeta(
    'networkName',
  );
  @override
  late final GeneratedColumn<String> networkName = GeneratedColumn<String>(
    'network_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    networkId,
    networkName,
    createdAt,
    updatedAt,
    serverId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts_network';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactsNetworkData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('network_id')) {
      context.handle(
        _networkIdMeta,
        networkId.isAcceptableOrUnknown(data['network_id']!, _networkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_networkIdMeta);
    }
    if (data.containsKey('network_name')) {
      context.handle(
        _networkNameMeta,
        networkName.isAcceptableOrUnknown(
          data['network_name']!,
          _networkNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_networkNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {networkId};
  @override
  ContactsNetworkData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactsNetworkData(
      networkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}network_id'],
      )!,
      networkName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}network_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
    );
  }

  @override
  $ContactsNetworkTable createAlias(String alias) {
    return $ContactsNetworkTable(attachedDatabase, alias);
  }
}

class ContactsNetworkData extends DataClass
    implements Insertable<ContactsNetworkData> {
  final String networkId;
  final String networkName;
  final int createdAt;
  final int updatedAt;
  final String serverId;
  const ContactsNetworkData({
    required this.networkId,
    required this.networkName,
    required this.createdAt,
    required this.updatedAt,
    required this.serverId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['network_id'] = Variable<String>(networkId);
    map['network_name'] = Variable<String>(networkName);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['server_id'] = Variable<String>(serverId);
    return map;
  }

  ContactsNetworkCompanion toCompanion(bool nullToAbsent) {
    return ContactsNetworkCompanion(
      networkId: Value(networkId),
      networkName: Value(networkName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverId: Value(serverId),
    );
  }

  factory ContactsNetworkData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactsNetworkData(
      networkId: serializer.fromJson<String>(json['networkId']),
      networkName: serializer.fromJson<String>(json['networkName']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      serverId: serializer.fromJson<String>(json['serverId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'networkId': serializer.toJson<String>(networkId),
      'networkName': serializer.toJson<String>(networkName),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'serverId': serializer.toJson<String>(serverId),
    };
  }

  ContactsNetworkData copyWith({
    String? networkId,
    String? networkName,
    int? createdAt,
    int? updatedAt,
    String? serverId,
  }) => ContactsNetworkData(
    networkId: networkId ?? this.networkId,
    networkName: networkName ?? this.networkName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverId: serverId ?? this.serverId,
  );
  ContactsNetworkData copyWithCompanion(ContactsNetworkCompanion data) {
    return ContactsNetworkData(
      networkId: data.networkId.present ? data.networkId.value : this.networkId,
      networkName: data.networkName.present
          ? data.networkName.value
          : this.networkName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactsNetworkData(')
          ..write('networkId: $networkId, ')
          ..write('networkName: $networkName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverId: $serverId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(networkId, networkName, createdAt, updatedAt, serverId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactsNetworkData &&
          other.networkId == this.networkId &&
          other.networkName == this.networkName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverId == this.serverId);
}

class ContactsNetworkCompanion extends UpdateCompanion<ContactsNetworkData> {
  final Value<String> networkId;
  final Value<String> networkName;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> serverId;
  final Value<int> rowid;
  const ContactsNetworkCompanion({
    this.networkId = const Value.absent(),
    this.networkName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsNetworkCompanion.insert({
    required String networkId,
    required String networkName,
    required int createdAt,
    required int updatedAt,
    required String serverId,
    this.rowid = const Value.absent(),
  }) : networkId = Value(networkId),
       networkName = Value(networkName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       serverId = Value(serverId);
  static Insertable<ContactsNetworkData> custom({
    Expression<String>? networkId,
    Expression<String>? networkName,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? serverId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (networkId != null) 'network_id': networkId,
      if (networkName != null) 'network_name': networkName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverId != null) 'server_id': serverId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsNetworkCompanion copyWith({
    Value<String>? networkId,
    Value<String>? networkName,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? serverId,
    Value<int>? rowid,
  }) {
    return ContactsNetworkCompanion(
      networkId: networkId ?? this.networkId,
      networkName: networkName ?? this.networkName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (networkId.present) {
      map['network_id'] = Variable<String>(networkId.value);
    }
    if (networkName.present) {
      map['network_name'] = Variable<String>(networkName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsNetworkCompanion(')
          ..write('networkId: $networkId, ')
          ..write('networkName: $networkName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverId: $serverId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactNetworkMembersTable extends ContactNetworkMembers
    with TableInfo<$ContactNetworkMembersTable, ContactNetworkMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactNetworkMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _networkIdMeta = const VerificationMeta(
    'networkId',
  );
  @override
  late final GeneratedColumn<String> networkId = GeneratedColumn<String>(
    'network_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contacts_network (network_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
    'contact_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contacts (contact_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [networkId, contactId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_network_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactNetworkMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('network_id')) {
      context.handle(
        _networkIdMeta,
        networkId.isAcceptableOrUnknown(data['network_id']!, _networkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_networkIdMeta);
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {networkId, contactId};
  @override
  ContactNetworkMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactNetworkMember(
      networkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}network_id'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ContactNetworkMembersTable createAlias(String alias) {
    return $ContactNetworkMembersTable(attachedDatabase, alias);
  }
}

class ContactNetworkMember extends DataClass
    implements Insertable<ContactNetworkMember> {
  final String networkId;
  final String contactId;
  final int createdAt;
  const ContactNetworkMember({
    required this.networkId,
    required this.contactId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['network_id'] = Variable<String>(networkId);
    map['contact_id'] = Variable<String>(contactId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ContactNetworkMembersCompanion toCompanion(bool nullToAbsent) {
    return ContactNetworkMembersCompanion(
      networkId: Value(networkId),
      contactId: Value(contactId),
      createdAt: Value(createdAt),
    );
  }

  factory ContactNetworkMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactNetworkMember(
      networkId: serializer.fromJson<String>(json['networkId']),
      contactId: serializer.fromJson<String>(json['contactId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'networkId': serializer.toJson<String>(networkId),
      'contactId': serializer.toJson<String>(contactId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ContactNetworkMember copyWith({
    String? networkId,
    String? contactId,
    int? createdAt,
  }) => ContactNetworkMember(
    networkId: networkId ?? this.networkId,
    contactId: contactId ?? this.contactId,
    createdAt: createdAt ?? this.createdAt,
  );
  ContactNetworkMember copyWithCompanion(ContactNetworkMembersCompanion data) {
    return ContactNetworkMember(
      networkId: data.networkId.present ? data.networkId.value : this.networkId,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactNetworkMember(')
          ..write('networkId: $networkId, ')
          ..write('contactId: $contactId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(networkId, contactId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactNetworkMember &&
          other.networkId == this.networkId &&
          other.contactId == this.contactId &&
          other.createdAt == this.createdAt);
}

class ContactNetworkMembersCompanion
    extends UpdateCompanion<ContactNetworkMember> {
  final Value<String> networkId;
  final Value<String> contactId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ContactNetworkMembersCompanion({
    this.networkId = const Value.absent(),
    this.contactId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactNetworkMembersCompanion.insert({
    required String networkId,
    required String contactId,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : networkId = Value(networkId),
       contactId = Value(contactId),
       createdAt = Value(createdAt);
  static Insertable<ContactNetworkMember> custom({
    Expression<String>? networkId,
    Expression<String>? contactId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (networkId != null) 'network_id': networkId,
      if (contactId != null) 'contact_id': contactId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactNetworkMembersCompanion copyWith({
    Value<String>? networkId,
    Value<String>? contactId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ContactNetworkMembersCompanion(
      networkId: networkId ?? this.networkId,
      contactId: contactId ?? this.contactId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (networkId.present) {
      map['network_id'] = Variable<String>(networkId.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactNetworkMembersCompanion(')
          ..write('networkId: $networkId, ')
          ..write('contactId: $contactId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, Group> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupTypeMeta = const VerificationMeta(
    'groupType',
  );
  @override
  late final GeneratedColumn<int> groupType = GeneratedColumn<int>(
    'group_type',
    aliasedName,
    false,
    check: () => groupType.isIn([0, 1]),
    type: DriftSqlType.int,
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
  static const VerificationMeta _privateKeyMeta = const VerificationMeta(
    'privateKey',
  );
  @override
  late final GeneratedColumn<String> privateKey = GeneratedColumn<String>(
    'private_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupDescMeta = const VerificationMeta(
    'groupDesc',
  );
  @override
  late final GeneratedColumn<String> groupDesc = GeneratedColumn<String>(
    'group_desc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOwnerMeta = const VerificationMeta(
    'isOwner',
  );
  @override
  late final GeneratedColumn<int> isOwner = GeneratedColumn<int>(
    'is_owner',
    aliasedName,
    false,
    check: () => isOwner.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    groupId,
    ownerId,
    groupName,
    groupType,
    avatar,
    privateKey,
    groupDesc,
    createdAt,
    updatedAt,
    isOwner,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<Group> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    } else if (isInserting) {
      context.missing(_groupNameMeta);
    }
    if (data.containsKey('group_type')) {
      context.handle(
        _groupTypeMeta,
        groupType.isAcceptableOrUnknown(data['group_type']!, _groupTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_groupTypeMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    if (data.containsKey('private_key')) {
      context.handle(
        _privateKeyMeta,
        privateKey.isAcceptableOrUnknown(data['private_key']!, _privateKeyMeta),
      );
    }
    if (data.containsKey('group_desc')) {
      context.handle(
        _groupDescMeta,
        groupDesc.isAcceptableOrUnknown(data['group_desc']!, _groupDescMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_owner')) {
      context.handle(
        _isOwnerMeta,
        isOwner.isAcceptableOrUnknown(data['is_owner']!, _isOwnerMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId};
  @override
  Group map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Group(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      )!,
      groupType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_type'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
      privateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}private_key'],
      ),
      groupDesc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_desc'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isOwner: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_owner'],
      )!,
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class Group extends DataClass implements Insertable<Group> {
  final String groupId;
  final String? ownerId;
  final String groupName;
  final int groupType;
  final String? avatar;
  final String? privateKey;
  final String? groupDesc;
  final int createdAt;
  final int updatedAt;
  final int isOwner;
  const Group({
    required this.groupId,
    this.ownerId,
    required this.groupName,
    required this.groupType,
    this.avatar,
    this.privateKey,
    this.groupDesc,
    required this.createdAt,
    required this.updatedAt,
    required this.isOwner,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['group_name'] = Variable<String>(groupName);
    map['group_type'] = Variable<int>(groupType);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    if (!nullToAbsent || privateKey != null) {
      map['private_key'] = Variable<String>(privateKey);
    }
    if (!nullToAbsent || groupDesc != null) {
      map['group_desc'] = Variable<String>(groupDesc);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_owner'] = Variable<int>(isOwner);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      groupId: Value(groupId),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      groupName: Value(groupName),
      groupType: Value(groupType),
      avatar: avatar == null && nullToAbsent
          ? const Value.absent()
          : Value(avatar),
      privateKey: privateKey == null && nullToAbsent
          ? const Value.absent()
          : Value(privateKey),
      groupDesc: groupDesc == null && nullToAbsent
          ? const Value.absent()
          : Value(groupDesc),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isOwner: Value(isOwner),
    );
  }

  factory Group.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Group(
      groupId: serializer.fromJson<String>(json['groupId']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      groupName: serializer.fromJson<String>(json['groupName']),
      groupType: serializer.fromJson<int>(json['groupType']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      privateKey: serializer.fromJson<String?>(json['privateKey']),
      groupDesc: serializer.fromJson<String?>(json['groupDesc']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isOwner: serializer.fromJson<int>(json['isOwner']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'ownerId': serializer.toJson<String?>(ownerId),
      'groupName': serializer.toJson<String>(groupName),
      'groupType': serializer.toJson<int>(groupType),
      'avatar': serializer.toJson<String?>(avatar),
      'privateKey': serializer.toJson<String?>(privateKey),
      'groupDesc': serializer.toJson<String?>(groupDesc),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isOwner': serializer.toJson<int>(isOwner),
    };
  }

  Group copyWith({
    String? groupId,
    Value<String?> ownerId = const Value.absent(),
    String? groupName,
    int? groupType,
    Value<String?> avatar = const Value.absent(),
    Value<String?> privateKey = const Value.absent(),
    Value<String?> groupDesc = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    int? isOwner,
  }) => Group(
    groupId: groupId ?? this.groupId,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    groupName: groupName ?? this.groupName,
    groupType: groupType ?? this.groupType,
    avatar: avatar.present ? avatar.value : this.avatar,
    privateKey: privateKey.present ? privateKey.value : this.privateKey,
    groupDesc: groupDesc.present ? groupDesc.value : this.groupDesc,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isOwner: isOwner ?? this.isOwner,
  );
  Group copyWithCompanion(GroupsCompanion data) {
    return Group(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      groupType: data.groupType.present ? data.groupType.value : this.groupType,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      privateKey: data.privateKey.present
          ? data.privateKey.value
          : this.privateKey,
      groupDesc: data.groupDesc.present ? data.groupDesc.value : this.groupDesc,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isOwner: data.isOwner.present ? data.isOwner.value : this.isOwner,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('groupId: $groupId, ')
          ..write('ownerId: $ownerId, ')
          ..write('groupName: $groupName, ')
          ..write('groupType: $groupType, ')
          ..write('avatar: $avatar, ')
          ..write('privateKey: $privateKey, ')
          ..write('groupDesc: $groupDesc, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isOwner: $isOwner')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    groupId,
    ownerId,
    groupName,
    groupType,
    avatar,
    privateKey,
    groupDesc,
    createdAt,
    updatedAt,
    isOwner,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          other.groupId == this.groupId &&
          other.ownerId == this.ownerId &&
          other.groupName == this.groupName &&
          other.groupType == this.groupType &&
          other.avatar == this.avatar &&
          other.privateKey == this.privateKey &&
          other.groupDesc == this.groupDesc &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isOwner == this.isOwner);
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<String> groupId;
  final Value<String?> ownerId;
  final Value<String> groupName;
  final Value<int> groupType;
  final Value<String?> avatar;
  final Value<String?> privateKey;
  final Value<String?> groupDesc;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> isOwner;
  final Value<int> rowid;
  const GroupsCompanion({
    this.groupId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.groupName = const Value.absent(),
    this.groupType = const Value.absent(),
    this.avatar = const Value.absent(),
    this.privateKey = const Value.absent(),
    this.groupDesc = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isOwner = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    required String groupId,
    this.ownerId = const Value.absent(),
    required String groupName,
    required int groupType,
    this.avatar = const Value.absent(),
    this.privateKey = const Value.absent(),
    this.groupDesc = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.isOwner = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       groupName = Value(groupName),
       groupType = Value(groupType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Group> custom({
    Expression<String>? groupId,
    Expression<String>? ownerId,
    Expression<String>? groupName,
    Expression<int>? groupType,
    Expression<String>? avatar,
    Expression<String>? privateKey,
    Expression<String>? groupDesc,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? isOwner,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (ownerId != null) 'owner_id': ownerId,
      if (groupName != null) 'group_name': groupName,
      if (groupType != null) 'group_type': groupType,
      if (avatar != null) 'avatar': avatar,
      if (privateKey != null) 'private_key': privateKey,
      if (groupDesc != null) 'group_desc': groupDesc,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isOwner != null) 'is_owner': isOwner,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCompanion copyWith({
    Value<String>? groupId,
    Value<String?>? ownerId,
    Value<String>? groupName,
    Value<int>? groupType,
    Value<String?>? avatar,
    Value<String?>? privateKey,
    Value<String?>? groupDesc,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? isOwner,
    Value<int>? rowid,
  }) {
    return GroupsCompanion(
      groupId: groupId ?? this.groupId,
      ownerId: ownerId ?? this.ownerId,
      groupName: groupName ?? this.groupName,
      groupType: groupType ?? this.groupType,
      avatar: avatar ?? this.avatar,
      privateKey: privateKey ?? this.privateKey,
      groupDesc: groupDesc ?? this.groupDesc,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOwner: isOwner ?? this.isOwner,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (groupType.present) {
      map['group_type'] = Variable<int>(groupType.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (privateKey.present) {
      map['private_key'] = Variable<String>(privateKey.value);
    }
    if (groupDesc.present) {
      map['group_desc'] = Variable<String>(groupDesc.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isOwner.present) {
      map['is_owner'] = Variable<int>(isOwner.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('groupId: $groupId, ')
          ..write('ownerId: $ownerId, ')
          ..write('groupName: $groupName, ')
          ..write('groupType: $groupType, ')
          ..write('avatar: $avatar, ')
          ..write('privateKey: $privateKey, ')
          ..write('groupDesc: $groupDesc, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isOwner: $isOwner, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupMembersTable extends GroupMembers
    with TableInfo<$GroupMembersTable, GroupMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (group_id) ON DELETE CASCADE',
    ),
  );
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES identity (identity_id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    '_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<int> joinedAt = GeneratedColumn<int>(
    'joined_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    groupId,
    identityId,
    publicKey,
    bio,
    avatar,
    name,
    joinedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('identity_id')) {
      context.handle(
        _identityIdMeta,
        identityId.isAcceptableOrUnknown(data['identity_id']!, _identityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_identityIdMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    if (data.containsKey('_name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['_name']!, _nameMeta),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, identityId};
  @override
  GroupMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMember(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      identityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identity_id'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      ),
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      ),
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}_name'],
      ),
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}joined_at'],
      ),
    );
  }

  @override
  $GroupMembersTable createAlias(String alias) {
    return $GroupMembersTable(attachedDatabase, alias);
  }
}

class GroupMember extends DataClass implements Insertable<GroupMember> {
  final String groupId;
  final String identityId;
  final String? publicKey;
  final String? bio;
  final String? avatar;
  final String? name;
  final int? joinedAt;
  const GroupMember({
    required this.groupId,
    required this.identityId,
    this.publicKey,
    this.bio,
    this.avatar,
    this.name,
    this.joinedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['identity_id'] = Variable<String>(identityId);
    if (!nullToAbsent || publicKey != null) {
      map['public_key'] = Variable<String>(publicKey);
    }
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    if (!nullToAbsent || name != null) {
      map['_name'] = Variable<String>(name);
    }
    if (!nullToAbsent || joinedAt != null) {
      map['joined_at'] = Variable<int>(joinedAt);
    }
    return map;
  }

  GroupMembersCompanion toCompanion(bool nullToAbsent) {
    return GroupMembersCompanion(
      groupId: Value(groupId),
      identityId: Value(identityId),
      publicKey: publicKey == null && nullToAbsent
          ? const Value.absent()
          : Value(publicKey),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
      avatar: avatar == null && nullToAbsent
          ? const Value.absent()
          : Value(avatar),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      joinedAt: joinedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(joinedAt),
    );
  }

  factory GroupMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMember(
      groupId: serializer.fromJson<String>(json['groupId']),
      identityId: serializer.fromJson<String>(json['identityId']),
      publicKey: serializer.fromJson<String?>(json['publicKey']),
      bio: serializer.fromJson<String?>(json['bio']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      name: serializer.fromJson<String?>(json['name']),
      joinedAt: serializer.fromJson<int?>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'identityId': serializer.toJson<String>(identityId),
      'publicKey': serializer.toJson<String?>(publicKey),
      'bio': serializer.toJson<String?>(bio),
      'avatar': serializer.toJson<String?>(avatar),
      'name': serializer.toJson<String?>(name),
      'joinedAt': serializer.toJson<int?>(joinedAt),
    };
  }

  GroupMember copyWith({
    String? groupId,
    String? identityId,
    Value<String?> publicKey = const Value.absent(),
    Value<String?> bio = const Value.absent(),
    Value<String?> avatar = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<int?> joinedAt = const Value.absent(),
  }) => GroupMember(
    groupId: groupId ?? this.groupId,
    identityId: identityId ?? this.identityId,
    publicKey: publicKey.present ? publicKey.value : this.publicKey,
    bio: bio.present ? bio.value : this.bio,
    avatar: avatar.present ? avatar.value : this.avatar,
    name: name.present ? name.value : this.name,
    joinedAt: joinedAt.present ? joinedAt.value : this.joinedAt,
  );
  GroupMember copyWithCompanion(GroupMembersCompanion data) {
    return GroupMember(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      identityId: data.identityId.present
          ? data.identityId.value
          : this.identityId,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      bio: data.bio.present ? data.bio.value : this.bio,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      name: data.name.present ? data.name.value : this.name,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupMember(')
          ..write('groupId: $groupId, ')
          ..write('identityId: $identityId, ')
          ..write('publicKey: $publicKey, ')
          ..write('bio: $bio, ')
          ..write('avatar: $avatar, ')
          ..write('name: $name, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(groupId, identityId, publicKey, bio, avatar, name, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMember &&
          other.groupId == this.groupId &&
          other.identityId == this.identityId &&
          other.publicKey == this.publicKey &&
          other.bio == this.bio &&
          other.avatar == this.avatar &&
          other.name == this.name &&
          other.joinedAt == this.joinedAt);
}

class GroupMembersCompanion extends UpdateCompanion<GroupMember> {
  final Value<String> groupId;
  final Value<String> identityId;
  final Value<String?> publicKey;
  final Value<String?> bio;
  final Value<String?> avatar;
  final Value<String?> name;
  final Value<int?> joinedAt;
  final Value<int> rowid;
  const GroupMembersCompanion({
    this.groupId = const Value.absent(),
    this.identityId = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.bio = const Value.absent(),
    this.avatar = const Value.absent(),
    this.name = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupMembersCompanion.insert({
    required String groupId,
    required String identityId,
    this.publicKey = const Value.absent(),
    this.bio = const Value.absent(),
    this.avatar = const Value.absent(),
    this.name = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       identityId = Value(identityId);
  static Insertable<GroupMember> custom({
    Expression<String>? groupId,
    Expression<String>? identityId,
    Expression<String>? publicKey,
    Expression<String>? bio,
    Expression<String>? avatar,
    Expression<String>? name,
    Expression<int>? joinedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (identityId != null) 'identity_id': identityId,
      if (publicKey != null) 'public_key': publicKey,
      if (bio != null) 'bio': bio,
      if (avatar != null) 'avatar': avatar,
      if (name != null) '_name': name,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupMembersCompanion copyWith({
    Value<String>? groupId,
    Value<String>? identityId,
    Value<String?>? publicKey,
    Value<String?>? bio,
    Value<String?>? avatar,
    Value<String?>? name,
    Value<int?>? joinedAt,
    Value<int>? rowid,
  }) {
    return GroupMembersCompanion(
      groupId: groupId ?? this.groupId,
      identityId: identityId ?? this.identityId,
      publicKey: publicKey ?? this.publicKey,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      name: name ?? this.name,
      joinedAt: joinedAt ?? this.joinedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (identityId.present) {
      map['identity_id'] = Variable<String>(identityId.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (name.present) {
      map['_name'] = Variable<String>(name.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<int>(joinedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembersCompanion(')
          ..write('groupId: $groupId, ')
          ..write('identityId: $identityId, ')
          ..write('publicKey: $publicKey, ')
          ..write('bio: $bio, ')
          ..write('avatar: $avatar, ')
          ..write('name: $name, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConnectionRequestsTable extends ConnectionRequests
    with TableInfo<$ConnectionRequestsTable, ConnectionRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConnectionRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requesterIdMeta = const VerificationMeta(
    'requesterId',
  );
  @override
  late final GeneratedColumn<String> requesterId = GeneratedColumn<String>(
    'requester_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES identity (identity_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _recipientIdMeta = const VerificationMeta(
    'recipientId',
  );
  @override
  late final GeneratedColumn<String> recipientId = GeneratedColumn<String>(
    'recipient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES identity (identity_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (group_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _introductionMeta = const VerificationMeta(
    'introduction',
  );
  @override
  late final GeneratedColumn<String> introduction = GeneratedColumn<String>(
    'introduction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    '_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acceptedAtMeta = const VerificationMeta(
    'acceptedAt',
  );
  @override
  late final GeneratedColumn<int> acceptedAt = GeneratedColumn<int>(
    'accepted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rejectedAtMeta = const VerificationMeta(
    'rejectedAt',
  );
  @override
  late final GeneratedColumn<int> rejectedAt = GeneratedColumn<int>(
    'rejected_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<int> expiresAt = GeneratedColumn<int>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    requestId,
    requesterId,
    recipientId,
    groupId,
    introduction,
    status,
    createdAt,
    acceptedAt,
    rejectedAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'connection_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConnectionRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('requester_id')) {
      context.handle(
        _requesterIdMeta,
        requesterId.isAcceptableOrUnknown(
          data['requester_id']!,
          _requesterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requesterIdMeta);
    }
    if (data.containsKey('recipient_id')) {
      context.handle(
        _recipientIdMeta,
        recipientId.isAcceptableOrUnknown(
          data['recipient_id']!,
          _recipientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recipientIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('introduction')) {
      context.handle(
        _introductionMeta,
        introduction.isAcceptableOrUnknown(
          data['introduction']!,
          _introductionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_introductionMeta);
    }
    if (data.containsKey('_status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['_status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('accepted_at')) {
      context.handle(
        _acceptedAtMeta,
        acceptedAt.isAcceptableOrUnknown(data['accepted_at']!, _acceptedAtMeta),
      );
    }
    if (data.containsKey('rejected_at')) {
      context.handle(
        _rejectedAtMeta,
        rejectedAt.isAcceptableOrUnknown(data['rejected_at']!, _rejectedAtMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {requestId};
  @override
  ConnectionRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConnectionRequest(
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      requesterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requester_id'],
      )!,
      recipientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipient_id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      introduction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}introduction'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      acceptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accepted_at'],
      ),
      rejectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rejected_at'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at'],
      ),
    );
  }

  @override
  $ConnectionRequestsTable createAlias(String alias) {
    return $ConnectionRequestsTable(attachedDatabase, alias);
  }
}

class ConnectionRequest extends DataClass
    implements Insertable<ConnectionRequest> {
  final String requestId;
  final String requesterId;
  final String recipientId;
  final String groupId;
  final String introduction;
  final int status;
  final int createdAt;
  final int? acceptedAt;
  final int? rejectedAt;
  final int? expiresAt;
  const ConnectionRequest({
    required this.requestId,
    required this.requesterId,
    required this.recipientId,
    required this.groupId,
    required this.introduction,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.rejectedAt,
    this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['request_id'] = Variable<String>(requestId);
    map['requester_id'] = Variable<String>(requesterId);
    map['recipient_id'] = Variable<String>(recipientId);
    map['group_id'] = Variable<String>(groupId);
    map['introduction'] = Variable<String>(introduction);
    map['_status'] = Variable<int>(status);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || acceptedAt != null) {
      map['accepted_at'] = Variable<int>(acceptedAt);
    }
    if (!nullToAbsent || rejectedAt != null) {
      map['rejected_at'] = Variable<int>(rejectedAt);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<int>(expiresAt);
    }
    return map;
  }

  ConnectionRequestsCompanion toCompanion(bool nullToAbsent) {
    return ConnectionRequestsCompanion(
      requestId: Value(requestId),
      requesterId: Value(requesterId),
      recipientId: Value(recipientId),
      groupId: Value(groupId),
      introduction: Value(introduction),
      status: Value(status),
      createdAt: Value(createdAt),
      acceptedAt: acceptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acceptedAt),
      rejectedAt: rejectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectedAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
    );
  }

  factory ConnectionRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConnectionRequest(
      requestId: serializer.fromJson<String>(json['requestId']),
      requesterId: serializer.fromJson<String>(json['requesterId']),
      recipientId: serializer.fromJson<String>(json['recipientId']),
      groupId: serializer.fromJson<String>(json['groupId']),
      introduction: serializer.fromJson<String>(json['introduction']),
      status: serializer.fromJson<int>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      acceptedAt: serializer.fromJson<int?>(json['acceptedAt']),
      rejectedAt: serializer.fromJson<int?>(json['rejectedAt']),
      expiresAt: serializer.fromJson<int?>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'requestId': serializer.toJson<String>(requestId),
      'requesterId': serializer.toJson<String>(requesterId),
      'recipientId': serializer.toJson<String>(recipientId),
      'groupId': serializer.toJson<String>(groupId),
      'introduction': serializer.toJson<String>(introduction),
      'status': serializer.toJson<int>(status),
      'createdAt': serializer.toJson<int>(createdAt),
      'acceptedAt': serializer.toJson<int?>(acceptedAt),
      'rejectedAt': serializer.toJson<int?>(rejectedAt),
      'expiresAt': serializer.toJson<int?>(expiresAt),
    };
  }

  ConnectionRequest copyWith({
    String? requestId,
    String? requesterId,
    String? recipientId,
    String? groupId,
    String? introduction,
    int? status,
    int? createdAt,
    Value<int?> acceptedAt = const Value.absent(),
    Value<int?> rejectedAt = const Value.absent(),
    Value<int?> expiresAt = const Value.absent(),
  }) => ConnectionRequest(
    requestId: requestId ?? this.requestId,
    requesterId: requesterId ?? this.requesterId,
    recipientId: recipientId ?? this.recipientId,
    groupId: groupId ?? this.groupId,
    introduction: introduction ?? this.introduction,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    acceptedAt: acceptedAt.present ? acceptedAt.value : this.acceptedAt,
    rejectedAt: rejectedAt.present ? rejectedAt.value : this.rejectedAt,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
  );
  ConnectionRequest copyWithCompanion(ConnectionRequestsCompanion data) {
    return ConnectionRequest(
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      requesterId: data.requesterId.present
          ? data.requesterId.value
          : this.requesterId,
      recipientId: data.recipientId.present
          ? data.recipientId.value
          : this.recipientId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      introduction: data.introduction.present
          ? data.introduction.value
          : this.introduction,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      acceptedAt: data.acceptedAt.present
          ? data.acceptedAt.value
          : this.acceptedAt,
      rejectedAt: data.rejectedAt.present
          ? data.rejectedAt.value
          : this.rejectedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionRequest(')
          ..write('requestId: $requestId, ')
          ..write('requesterId: $requesterId, ')
          ..write('recipientId: $recipientId, ')
          ..write('groupId: $groupId, ')
          ..write('introduction: $introduction, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('rejectedAt: $rejectedAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    requestId,
    requesterId,
    recipientId,
    groupId,
    introduction,
    status,
    createdAt,
    acceptedAt,
    rejectedAt,
    expiresAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConnectionRequest &&
          other.requestId == this.requestId &&
          other.requesterId == this.requesterId &&
          other.recipientId == this.recipientId &&
          other.groupId == this.groupId &&
          other.introduction == this.introduction &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.acceptedAt == this.acceptedAt &&
          other.rejectedAt == this.rejectedAt &&
          other.expiresAt == this.expiresAt);
}

class ConnectionRequestsCompanion extends UpdateCompanion<ConnectionRequest> {
  final Value<String> requestId;
  final Value<String> requesterId;
  final Value<String> recipientId;
  final Value<String> groupId;
  final Value<String> introduction;
  final Value<int> status;
  final Value<int> createdAt;
  final Value<int?> acceptedAt;
  final Value<int?> rejectedAt;
  final Value<int?> expiresAt;
  final Value<int> rowid;
  const ConnectionRequestsCompanion({
    this.requestId = const Value.absent(),
    this.requesterId = const Value.absent(),
    this.recipientId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.introduction = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.acceptedAt = const Value.absent(),
    this.rejectedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConnectionRequestsCompanion.insert({
    required String requestId,
    required String requesterId,
    required String recipientId,
    required String groupId,
    required String introduction,
    required int status,
    required int createdAt,
    this.acceptedAt = const Value.absent(),
    this.rejectedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : requestId = Value(requestId),
       requesterId = Value(requesterId),
       recipientId = Value(recipientId),
       groupId = Value(groupId),
       introduction = Value(introduction),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<ConnectionRequest> custom({
    Expression<String>? requestId,
    Expression<String>? requesterId,
    Expression<String>? recipientId,
    Expression<String>? groupId,
    Expression<String>? introduction,
    Expression<int>? status,
    Expression<int>? createdAt,
    Expression<int>? acceptedAt,
    Expression<int>? rejectedAt,
    Expression<int>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (requestId != null) 'request_id': requestId,
      if (requesterId != null) 'requester_id': requesterId,
      if (recipientId != null) 'recipient_id': recipientId,
      if (groupId != null) 'group_id': groupId,
      if (introduction != null) 'introduction': introduction,
      if (status != null) '_status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (acceptedAt != null) 'accepted_at': acceptedAt,
      if (rejectedAt != null) 'rejected_at': rejectedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConnectionRequestsCompanion copyWith({
    Value<String>? requestId,
    Value<String>? requesterId,
    Value<String>? recipientId,
    Value<String>? groupId,
    Value<String>? introduction,
    Value<int>? status,
    Value<int>? createdAt,
    Value<int?>? acceptedAt,
    Value<int?>? rejectedAt,
    Value<int?>? expiresAt,
    Value<int>? rowid,
  }) {
    return ConnectionRequestsCompanion(
      requestId: requestId ?? this.requestId,
      requesterId: requesterId ?? this.requesterId,
      recipientId: recipientId ?? this.recipientId,
      groupId: groupId ?? this.groupId,
      introduction: introduction ?? this.introduction,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (requesterId.present) {
      map['requester_id'] = Variable<String>(requesterId.value);
    }
    if (recipientId.present) {
      map['recipient_id'] = Variable<String>(recipientId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (introduction.present) {
      map['introduction'] = Variable<String>(introduction.value);
    }
    if (status.present) {
      map['_status'] = Variable<int>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (acceptedAt.present) {
      map['accepted_at'] = Variable<int>(acceptedAt.value);
    }
    if (rejectedAt.present) {
      map['rejected_at'] = Variable<int>(rejectedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<int>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionRequestsCompanion(')
          ..write('requestId: $requestId, ')
          ..write('requesterId: $requesterId, ')
          ..write('recipientId: $recipientId, ')
          ..write('groupId: $groupId, ')
          ..write('introduction: $introduction, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('rejectedAt: $rejectedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskTypeMeta = const VerificationMeta(
    'taskType',
  );
  @override
  late final GeneratedColumn<int> taskType = GeneratedColumn<int>(
    'task_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskStatusMeta = const VerificationMeta(
    'taskStatus',
  );
  @override
  late final GeneratedColumn<int> taskStatus = GeneratedColumn<int>(
    'task_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskNameMeta = const VerificationMeta(
    'taskName',
  );
  @override
  late final GeneratedColumn<String> taskName = GeneratedColumn<String>(
    'task_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retrys',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES servers (server_id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _taskDataMeta = const VerificationMeta(
    'taskData',
  );
  @override
  late final GeneratedColumn<String> taskData = GeneratedColumn<String>(
    'task_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failureMeta = const VerificationMeta(
    'failure',
  );
  @override
  late final GeneratedColumn<String> failure = GeneratedColumn<String>(
    'failure',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedToStateMeta = const VerificationMeta(
    'syncedToState',
  );
  @override
  late final GeneratedColumn<int> syncedToState = GeneratedColumn<int>(
    'synced_to_state',
    aliasedName,
    false,
    check: () => syncedToState.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncedToServerMeta = const VerificationMeta(
    'syncedToServer',
  );
  @override
  late final GeneratedColumn<int> syncedToServer = GeneratedColumn<int>(
    'synced_to_server',
    aliasedName,
    false,
    check: () => syncedToServer.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncedToClientMeta = const VerificationMeta(
    'syncedToClient',
  );
  @override
  late final GeneratedColumn<int> syncedToClient = GeneratedColumn<int>(
    'synced_to_client',
    aliasedName,
    false,
    check: () => syncedToClient.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncedToDbMeta = const VerificationMeta(
    'syncedToDb',
  );
  @override
  late final GeneratedColumn<int> syncedToDb = GeneratedColumn<int>(
    'synced_to_db',
    aliasedName,
    false,
    check: () => syncedToDb.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<int> completed = GeneratedColumn<int>(
    'completed',
    aliasedName,
    false,
    check: () => completed.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    taskId,
    taskType,
    taskStatus,
    taskName,
    createdAt,
    updatedAt,
    retryCount,
    serverId,
    taskData,
    failure,
    completedAt,
    syncedToState,
    syncedToServer,
    syncedToClient,
    syncedToDb,
    completed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('task_type')) {
      context.handle(
        _taskTypeMeta,
        taskType.isAcceptableOrUnknown(data['task_type']!, _taskTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_taskTypeMeta);
    }
    if (data.containsKey('task_status')) {
      context.handle(
        _taskStatusMeta,
        taskStatus.isAcceptableOrUnknown(data['task_status']!, _taskStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_taskStatusMeta);
    }
    if (data.containsKey('task_name')) {
      context.handle(
        _taskNameMeta,
        taskName.isAcceptableOrUnknown(data['task_name']!, _taskNameMeta),
      );
    } else if (isInserting) {
      context.missing(_taskNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('retrys')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retrys']!, _retryCountMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('task_data')) {
      context.handle(
        _taskDataMeta,
        taskData.isAcceptableOrUnknown(data['task_data']!, _taskDataMeta),
      );
    }
    if (data.containsKey('failure')) {
      context.handle(
        _failureMeta,
        failure.isAcceptableOrUnknown(data['failure']!, _failureMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('synced_to_state')) {
      context.handle(
        _syncedToStateMeta,
        syncedToState.isAcceptableOrUnknown(
          data['synced_to_state']!,
          _syncedToStateMeta,
        ),
      );
    }
    if (data.containsKey('synced_to_server')) {
      context.handle(
        _syncedToServerMeta,
        syncedToServer.isAcceptableOrUnknown(
          data['synced_to_server']!,
          _syncedToServerMeta,
        ),
      );
    }
    if (data.containsKey('synced_to_client')) {
      context.handle(
        _syncedToClientMeta,
        syncedToClient.isAcceptableOrUnknown(
          data['synced_to_client']!,
          _syncedToClientMeta,
        ),
      );
    }
    if (data.containsKey('synced_to_db')) {
      context.handle(
        _syncedToDbMeta,
        syncedToDb.isAcceptableOrUnknown(
          data['synced_to_db']!,
          _syncedToDbMeta,
        ),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      taskType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_type'],
      )!,
      taskStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_status'],
      )!,
      taskName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retrys'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      taskData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_data'],
      ),
      failure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      syncedToState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_to_state'],
      )!,
      syncedToServer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_to_server'],
      )!,
      syncedToClient: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_to_client'],
      )!,
      syncedToDb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_to_db'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String taskId;
  final int taskType;
  final int taskStatus;
  final String taskName;
  final int createdAt;
  final int updatedAt;
  final int retryCount;
  final String? serverId;
  final String? taskData;
  final String? failure;
  final int? completedAt;
  final int syncedToState;
  final int syncedToServer;
  final int syncedToClient;
  final int syncedToDb;
  final int completed;
  const Task({
    required this.taskId,
    required this.taskType,
    required this.taskStatus,
    required this.taskName,
    required this.createdAt,
    required this.updatedAt,
    required this.retryCount,
    this.serverId,
    this.taskData,
    this.failure,
    this.completedAt,
    required this.syncedToState,
    required this.syncedToServer,
    required this.syncedToClient,
    required this.syncedToDb,
    required this.completed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['task_type'] = Variable<int>(taskType);
    map['task_status'] = Variable<int>(taskStatus);
    map['task_name'] = Variable<String>(taskName);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['retrys'] = Variable<int>(retryCount);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || taskData != null) {
      map['task_data'] = Variable<String>(taskData);
    }
    if (!nullToAbsent || failure != null) {
      map['failure'] = Variable<String>(failure);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['synced_to_state'] = Variable<int>(syncedToState);
    map['synced_to_server'] = Variable<int>(syncedToServer);
    map['synced_to_client'] = Variable<int>(syncedToClient);
    map['synced_to_db'] = Variable<int>(syncedToDb);
    map['completed'] = Variable<int>(completed);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      taskId: Value(taskId),
      taskType: Value(taskType),
      taskStatus: Value(taskStatus),
      taskName: Value(taskName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      retryCount: Value(retryCount),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      taskData: taskData == null && nullToAbsent
          ? const Value.absent()
          : Value(taskData),
      failure: failure == null && nullToAbsent
          ? const Value.absent()
          : Value(failure),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      syncedToState: Value(syncedToState),
      syncedToServer: Value(syncedToServer),
      syncedToClient: Value(syncedToClient),
      syncedToDb: Value(syncedToDb),
      completed: Value(completed),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      taskId: serializer.fromJson<String>(json['taskId']),
      taskType: serializer.fromJson<int>(json['taskType']),
      taskStatus: serializer.fromJson<int>(json['taskStatus']),
      taskName: serializer.fromJson<String>(json['taskName']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      taskData: serializer.fromJson<String?>(json['taskData']),
      failure: serializer.fromJson<String?>(json['failure']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      syncedToState: serializer.fromJson<int>(json['syncedToState']),
      syncedToServer: serializer.fromJson<int>(json['syncedToServer']),
      syncedToClient: serializer.fromJson<int>(json['syncedToClient']),
      syncedToDb: serializer.fromJson<int>(json['syncedToDb']),
      completed: serializer.fromJson<int>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'taskType': serializer.toJson<int>(taskType),
      'taskStatus': serializer.toJson<int>(taskStatus),
      'taskName': serializer.toJson<String>(taskName),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'serverId': serializer.toJson<String?>(serverId),
      'taskData': serializer.toJson<String?>(taskData),
      'failure': serializer.toJson<String?>(failure),
      'completedAt': serializer.toJson<int?>(completedAt),
      'syncedToState': serializer.toJson<int>(syncedToState),
      'syncedToServer': serializer.toJson<int>(syncedToServer),
      'syncedToClient': serializer.toJson<int>(syncedToClient),
      'syncedToDb': serializer.toJson<int>(syncedToDb),
      'completed': serializer.toJson<int>(completed),
    };
  }

  Task copyWith({
    String? taskId,
    int? taskType,
    int? taskStatus,
    String? taskName,
    int? createdAt,
    int? updatedAt,
    int? retryCount,
    Value<String?> serverId = const Value.absent(),
    Value<String?> taskData = const Value.absent(),
    Value<String?> failure = const Value.absent(),
    Value<int?> completedAt = const Value.absent(),
    int? syncedToState,
    int? syncedToServer,
    int? syncedToClient,
    int? syncedToDb,
    int? completed,
  }) => Task(
    taskId: taskId ?? this.taskId,
    taskType: taskType ?? this.taskType,
    taskStatus: taskStatus ?? this.taskStatus,
    taskName: taskName ?? this.taskName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    retryCount: retryCount ?? this.retryCount,
    serverId: serverId.present ? serverId.value : this.serverId,
    taskData: taskData.present ? taskData.value : this.taskData,
    failure: failure.present ? failure.value : this.failure,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    syncedToState: syncedToState ?? this.syncedToState,
    syncedToServer: syncedToServer ?? this.syncedToServer,
    syncedToClient: syncedToClient ?? this.syncedToClient,
    syncedToDb: syncedToDb ?? this.syncedToDb,
    completed: completed ?? this.completed,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      taskType: data.taskType.present ? data.taskType.value : this.taskType,
      taskStatus: data.taskStatus.present
          ? data.taskStatus.value
          : this.taskStatus,
      taskName: data.taskName.present ? data.taskName.value : this.taskName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      taskData: data.taskData.present ? data.taskData.value : this.taskData,
      failure: data.failure.present ? data.failure.value : this.failure,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      syncedToState: data.syncedToState.present
          ? data.syncedToState.value
          : this.syncedToState,
      syncedToServer: data.syncedToServer.present
          ? data.syncedToServer.value
          : this.syncedToServer,
      syncedToClient: data.syncedToClient.present
          ? data.syncedToClient.value
          : this.syncedToClient,
      syncedToDb: data.syncedToDb.present
          ? data.syncedToDb.value
          : this.syncedToDb,
      completed: data.completed.present ? data.completed.value : this.completed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('taskId: $taskId, ')
          ..write('taskType: $taskType, ')
          ..write('taskStatus: $taskStatus, ')
          ..write('taskName: $taskName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('serverId: $serverId, ')
          ..write('taskData: $taskData, ')
          ..write('failure: $failure, ')
          ..write('completedAt: $completedAt, ')
          ..write('syncedToState: $syncedToState, ')
          ..write('syncedToServer: $syncedToServer, ')
          ..write('syncedToClient: $syncedToClient, ')
          ..write('syncedToDb: $syncedToDb, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    taskId,
    taskType,
    taskStatus,
    taskName,
    createdAt,
    updatedAt,
    retryCount,
    serverId,
    taskData,
    failure,
    completedAt,
    syncedToState,
    syncedToServer,
    syncedToClient,
    syncedToDb,
    completed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.taskId == this.taskId &&
          other.taskType == this.taskType &&
          other.taskStatus == this.taskStatus &&
          other.taskName == this.taskName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.retryCount == this.retryCount &&
          other.serverId == this.serverId &&
          other.taskData == this.taskData &&
          other.failure == this.failure &&
          other.completedAt == this.completedAt &&
          other.syncedToState == this.syncedToState &&
          other.syncedToServer == this.syncedToServer &&
          other.syncedToClient == this.syncedToClient &&
          other.syncedToDb == this.syncedToDb &&
          other.completed == this.completed);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> taskId;
  final Value<int> taskType;
  final Value<int> taskStatus;
  final Value<String> taskName;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> retryCount;
  final Value<String?> serverId;
  final Value<String?> taskData;
  final Value<String?> failure;
  final Value<int?> completedAt;
  final Value<int> syncedToState;
  final Value<int> syncedToServer;
  final Value<int> syncedToClient;
  final Value<int> syncedToDb;
  final Value<int> completed;
  final Value<int> rowid;
  const TasksCompanion({
    this.taskId = const Value.absent(),
    this.taskType = const Value.absent(),
    this.taskStatus = const Value.absent(),
    this.taskName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.serverId = const Value.absent(),
    this.taskData = const Value.absent(),
    this.failure = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.syncedToState = const Value.absent(),
    this.syncedToServer = const Value.absent(),
    this.syncedToClient = const Value.absent(),
    this.syncedToDb = const Value.absent(),
    this.completed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String taskId,
    required int taskType,
    required int taskStatus,
    required String taskName,
    required int createdAt,
    required int updatedAt,
    this.retryCount = const Value.absent(),
    this.serverId = const Value.absent(),
    this.taskData = const Value.absent(),
    this.failure = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.syncedToState = const Value.absent(),
    this.syncedToServer = const Value.absent(),
    this.syncedToClient = const Value.absent(),
    this.syncedToDb = const Value.absent(),
    this.completed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : taskId = Value(taskId),
       taskType = Value(taskType),
       taskStatus = Value(taskStatus),
       taskName = Value(taskName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Task> custom({
    Expression<String>? taskId,
    Expression<int>? taskType,
    Expression<int>? taskStatus,
    Expression<String>? taskName,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? retryCount,
    Expression<String>? serverId,
    Expression<String>? taskData,
    Expression<String>? failure,
    Expression<int>? completedAt,
    Expression<int>? syncedToState,
    Expression<int>? syncedToServer,
    Expression<int>? syncedToClient,
    Expression<int>? syncedToDb,
    Expression<int>? completed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (taskType != null) 'task_type': taskType,
      if (taskStatus != null) 'task_status': taskStatus,
      if (taskName != null) 'task_name': taskName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (retryCount != null) 'retrys': retryCount,
      if (serverId != null) 'server_id': serverId,
      if (taskData != null) 'task_data': taskData,
      if (failure != null) 'failure': failure,
      if (completedAt != null) 'completed_at': completedAt,
      if (syncedToState != null) 'synced_to_state': syncedToState,
      if (syncedToServer != null) 'synced_to_server': syncedToServer,
      if (syncedToClient != null) 'synced_to_client': syncedToClient,
      if (syncedToDb != null) 'synced_to_db': syncedToDb,
      if (completed != null) 'completed': completed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? taskId,
    Value<int>? taskType,
    Value<int>? taskStatus,
    Value<String>? taskName,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? retryCount,
    Value<String?>? serverId,
    Value<String?>? taskData,
    Value<String?>? failure,
    Value<int?>? completedAt,
    Value<int>? syncedToState,
    Value<int>? syncedToServer,
    Value<int>? syncedToClient,
    Value<int>? syncedToDb,
    Value<int>? completed,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      taskId: taskId ?? this.taskId,
      taskType: taskType ?? this.taskType,
      taskStatus: taskStatus ?? this.taskStatus,
      taskName: taskName ?? this.taskName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      retryCount: retryCount ?? this.retryCount,
      serverId: serverId ?? this.serverId,
      taskData: taskData ?? this.taskData,
      failure: failure ?? this.failure,
      completedAt: completedAt ?? this.completedAt,
      syncedToState: syncedToState ?? this.syncedToState,
      syncedToServer: syncedToServer ?? this.syncedToServer,
      syncedToClient: syncedToClient ?? this.syncedToClient,
      syncedToDb: syncedToDb ?? this.syncedToDb,
      completed: completed ?? this.completed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (taskType.present) {
      map['task_type'] = Variable<int>(taskType.value);
    }
    if (taskStatus.present) {
      map['task_status'] = Variable<int>(taskStatus.value);
    }
    if (taskName.present) {
      map['task_name'] = Variable<String>(taskName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (retryCount.present) {
      map['retrys'] = Variable<int>(retryCount.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (taskData.present) {
      map['task_data'] = Variable<String>(taskData.value);
    }
    if (failure.present) {
      map['failure'] = Variable<String>(failure.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (syncedToState.present) {
      map['synced_to_state'] = Variable<int>(syncedToState.value);
    }
    if (syncedToServer.present) {
      map['synced_to_server'] = Variable<int>(syncedToServer.value);
    }
    if (syncedToClient.present) {
      map['synced_to_client'] = Variable<int>(syncedToClient.value);
    }
    if (syncedToDb.present) {
      map['synced_to_db'] = Variable<int>(syncedToDb.value);
    }
    if (completed.present) {
      map['completed'] = Variable<int>(completed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('taskId: $taskId, ')
          ..write('taskType: $taskType, ')
          ..write('taskStatus: $taskStatus, ')
          ..write('taskName: $taskName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('serverId: $serverId, ')
          ..write('taskData: $taskData, ')
          ..write('failure: $failure, ')
          ..write('completedAt: $completedAt, ')
          ..write('syncedToState: $syncedToState, ')
          ..write('syncedToServer: $syncedToServer, ')
          ..write('syncedToClient: $syncedToClient, ')
          ..write('syncedToDb: $syncedToDb, ')
          ..write('completed: $completed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShamirsSecretTable extends ShamirsSecret
    with TableInfo<$ShamirsSecretTable, ShamirsSecretData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShamirsSecretTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES identity (identity_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _secretShareMeta = const VerificationMeta(
    'secretShare',
  );
  @override
  late final GeneratedColumn<String> secretShare = GeneratedColumn<String>(
    'secret_share',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settingsPayloadMeta = const VerificationMeta(
    'settingsPayload',
  );
  @override
  late final GeneratedColumn<Uint8List> settingsPayload =
      GeneratedColumn<Uint8List>(
        'settings_payload',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _passwordBlobMeta = const VerificationMeta(
    'passwordBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> passwordBlob =
      GeneratedColumn<Uint8List>(
        'password_blob',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    identityId,
    secretShare,
    updatedAt,
    settingsPayload,
    passwordBlob,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shamirs_secret';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShamirsSecretData> instance, {
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
    if (data.containsKey('secret_share')) {
      context.handle(
        _secretShareMeta,
        secretShare.isAcceptableOrUnknown(
          data['secret_share']!,
          _secretShareMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_secretShareMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('settings_payload')) {
      context.handle(
        _settingsPayloadMeta,
        settingsPayload.isAcceptableOrUnknown(
          data['settings_payload']!,
          _settingsPayloadMeta,
        ),
      );
    }
    if (data.containsKey('password_blob')) {
      context.handle(
        _passwordBlobMeta,
        passwordBlob.isAcceptableOrUnknown(
          data['password_blob']!,
          _passwordBlobMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordBlobMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {identityId};
  @override
  ShamirsSecretData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShamirsSecretData(
      identityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identity_id'],
      )!,
      secretShare: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secret_share'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      settingsPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}settings_payload'],
      ),
      passwordBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}password_blob'],
      )!,
    );
  }

  @override
  $ShamirsSecretTable createAlias(String alias) {
    return $ShamirsSecretTable(attachedDatabase, alias);
  }
}

class ShamirsSecretData extends DataClass
    implements Insertable<ShamirsSecretData> {
  final String identityId;
  final String secretShare;
  final int updatedAt;
  final Uint8List? settingsPayload;
  final Uint8List passwordBlob;
  const ShamirsSecretData({
    required this.identityId,
    required this.secretShare,
    required this.updatedAt,
    this.settingsPayload,
    required this.passwordBlob,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['identity_id'] = Variable<String>(identityId);
    map['secret_share'] = Variable<String>(secretShare);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || settingsPayload != null) {
      map['settings_payload'] = Variable<Uint8List>(settingsPayload);
    }
    map['password_blob'] = Variable<Uint8List>(passwordBlob);
    return map;
  }

  ShamirsSecretCompanion toCompanion(bool nullToAbsent) {
    return ShamirsSecretCompanion(
      identityId: Value(identityId),
      secretShare: Value(secretShare),
      updatedAt: Value(updatedAt),
      settingsPayload: settingsPayload == null && nullToAbsent
          ? const Value.absent()
          : Value(settingsPayload),
      passwordBlob: Value(passwordBlob),
    );
  }

  factory ShamirsSecretData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShamirsSecretData(
      identityId: serializer.fromJson<String>(json['identityId']),
      secretShare: serializer.fromJson<String>(json['secretShare']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      settingsPayload: serializer.fromJson<Uint8List?>(json['settingsPayload']),
      passwordBlob: serializer.fromJson<Uint8List>(json['passwordBlob']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'identityId': serializer.toJson<String>(identityId),
      'secretShare': serializer.toJson<String>(secretShare),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'settingsPayload': serializer.toJson<Uint8List?>(settingsPayload),
      'passwordBlob': serializer.toJson<Uint8List>(passwordBlob),
    };
  }

  ShamirsSecretData copyWith({
    String? identityId,
    String? secretShare,
    int? updatedAt,
    Value<Uint8List?> settingsPayload = const Value.absent(),
    Uint8List? passwordBlob,
  }) => ShamirsSecretData(
    identityId: identityId ?? this.identityId,
    secretShare: secretShare ?? this.secretShare,
    updatedAt: updatedAt ?? this.updatedAt,
    settingsPayload: settingsPayload.present
        ? settingsPayload.value
        : this.settingsPayload,
    passwordBlob: passwordBlob ?? this.passwordBlob,
  );
  ShamirsSecretData copyWithCompanion(ShamirsSecretCompanion data) {
    return ShamirsSecretData(
      identityId: data.identityId.present
          ? data.identityId.value
          : this.identityId,
      secretShare: data.secretShare.present
          ? data.secretShare.value
          : this.secretShare,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      settingsPayload: data.settingsPayload.present
          ? data.settingsPayload.value
          : this.settingsPayload,
      passwordBlob: data.passwordBlob.present
          ? data.passwordBlob.value
          : this.passwordBlob,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShamirsSecretData(')
          ..write('identityId: $identityId, ')
          ..write('secretShare: $secretShare, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('settingsPayload: $settingsPayload, ')
          ..write('passwordBlob: $passwordBlob')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    identityId,
    secretShare,
    updatedAt,
    $driftBlobEquality.hash(settingsPayload),
    $driftBlobEquality.hash(passwordBlob),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShamirsSecretData &&
          other.identityId == this.identityId &&
          other.secretShare == this.secretShare &&
          other.updatedAt == this.updatedAt &&
          $driftBlobEquality.equals(
            other.settingsPayload,
            this.settingsPayload,
          ) &&
          $driftBlobEquality.equals(other.passwordBlob, this.passwordBlob));
}

class ShamirsSecretCompanion extends UpdateCompanion<ShamirsSecretData> {
  final Value<String> identityId;
  final Value<String> secretShare;
  final Value<int> updatedAt;
  final Value<Uint8List?> settingsPayload;
  final Value<Uint8List> passwordBlob;
  final Value<int> rowid;
  const ShamirsSecretCompanion({
    this.identityId = const Value.absent(),
    this.secretShare = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.settingsPayload = const Value.absent(),
    this.passwordBlob = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShamirsSecretCompanion.insert({
    required String identityId,
    required String secretShare,
    required int updatedAt,
    this.settingsPayload = const Value.absent(),
    required Uint8List passwordBlob,
    this.rowid = const Value.absent(),
  }) : identityId = Value(identityId),
       secretShare = Value(secretShare),
       updatedAt = Value(updatedAt),
       passwordBlob = Value(passwordBlob);
  static Insertable<ShamirsSecretData> custom({
    Expression<String>? identityId,
    Expression<String>? secretShare,
    Expression<int>? updatedAt,
    Expression<Uint8List>? settingsPayload,
    Expression<Uint8List>? passwordBlob,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (identityId != null) 'identity_id': identityId,
      if (secretShare != null) 'secret_share': secretShare,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (settingsPayload != null) 'settings_payload': settingsPayload,
      if (passwordBlob != null) 'password_blob': passwordBlob,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShamirsSecretCompanion copyWith({
    Value<String>? identityId,
    Value<String>? secretShare,
    Value<int>? updatedAt,
    Value<Uint8List?>? settingsPayload,
    Value<Uint8List>? passwordBlob,
    Value<int>? rowid,
  }) {
    return ShamirsSecretCompanion(
      identityId: identityId ?? this.identityId,
      secretShare: secretShare ?? this.secretShare,
      updatedAt: updatedAt ?? this.updatedAt,
      settingsPayload: settingsPayload ?? this.settingsPayload,
      passwordBlob: passwordBlob ?? this.passwordBlob,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (identityId.present) {
      map['identity_id'] = Variable<String>(identityId.value);
    }
    if (secretShare.present) {
      map['secret_share'] = Variable<String>(secretShare.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (settingsPayload.present) {
      map['settings_payload'] = Variable<Uint8List>(settingsPayload.value);
    }
    if (passwordBlob.present) {
      map['password_blob'] = Variable<Uint8List>(passwordBlob.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShamirsSecretCompanion(')
          ..write('identityId: $identityId, ')
          ..write('secretShare: $secretShare, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('settingsPayload: $settingsPayload, ')
          ..write('passwordBlob: $passwordBlob, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SecretShareTable extends SecretShare
    with TableInfo<$SecretShareTable, SecretShareData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SecretShareTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES identity (identity_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lastSharedMeta = const VerificationMeta(
    'lastShared',
  );
  @override
  late final GeneratedColumn<int> lastShared = GeneratedColumn<int>(
    'last_shared',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordVersionSharedMeta =
      const VerificationMeta('passwordVersionShared');
  @override
  late final GeneratedColumn<int> passwordVersionShared = GeneratedColumn<int>(
    'password_version_shared',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settingsVersionSharedMeta =
      const VerificationMeta('settingsVersionShared');
  @override
  late final GeneratedColumn<int> settingsVersionShared = GeneratedColumn<int>(
    'settings_version_shared',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    identityId,
    lastShared,
    passwordVersionShared,
    settingsVersionShared,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'secret_share';
  @override
  VerificationContext validateIntegrity(
    Insertable<SecretShareData> instance, {
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
    if (data.containsKey('last_shared')) {
      context.handle(
        _lastSharedMeta,
        lastShared.isAcceptableOrUnknown(data['last_shared']!, _lastSharedMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSharedMeta);
    }
    if (data.containsKey('password_version_shared')) {
      context.handle(
        _passwordVersionSharedMeta,
        passwordVersionShared.isAcceptableOrUnknown(
          data['password_version_shared']!,
          _passwordVersionSharedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordVersionSharedMeta);
    }
    if (data.containsKey('settings_version_shared')) {
      context.handle(
        _settingsVersionSharedMeta,
        settingsVersionShared.isAcceptableOrUnknown(
          data['settings_version_shared']!,
          _settingsVersionSharedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settingsVersionSharedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {identityId};
  @override
  SecretShareData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SecretShareData(
      identityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identity_id'],
      )!,
      lastShared: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_shared'],
      )!,
      passwordVersionShared: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}password_version_shared'],
      )!,
      settingsVersionShared: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}settings_version_shared'],
      )!,
    );
  }

  @override
  $SecretShareTable createAlias(String alias) {
    return $SecretShareTable(attachedDatabase, alias);
  }
}

class SecretShareData extends DataClass implements Insertable<SecretShareData> {
  final String identityId;
  final int lastShared;
  final int passwordVersionShared;
  final int settingsVersionShared;
  const SecretShareData({
    required this.identityId,
    required this.lastShared,
    required this.passwordVersionShared,
    required this.settingsVersionShared,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['identity_id'] = Variable<String>(identityId);
    map['last_shared'] = Variable<int>(lastShared);
    map['password_version_shared'] = Variable<int>(passwordVersionShared);
    map['settings_version_shared'] = Variable<int>(settingsVersionShared);
    return map;
  }

  SecretShareCompanion toCompanion(bool nullToAbsent) {
    return SecretShareCompanion(
      identityId: Value(identityId),
      lastShared: Value(lastShared),
      passwordVersionShared: Value(passwordVersionShared),
      settingsVersionShared: Value(settingsVersionShared),
    );
  }

  factory SecretShareData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SecretShareData(
      identityId: serializer.fromJson<String>(json['identityId']),
      lastShared: serializer.fromJson<int>(json['lastShared']),
      passwordVersionShared: serializer.fromJson<int>(
        json['passwordVersionShared'],
      ),
      settingsVersionShared: serializer.fromJson<int>(
        json['settingsVersionShared'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'identityId': serializer.toJson<String>(identityId),
      'lastShared': serializer.toJson<int>(lastShared),
      'passwordVersionShared': serializer.toJson<int>(passwordVersionShared),
      'settingsVersionShared': serializer.toJson<int>(settingsVersionShared),
    };
  }

  SecretShareData copyWith({
    String? identityId,
    int? lastShared,
    int? passwordVersionShared,
    int? settingsVersionShared,
  }) => SecretShareData(
    identityId: identityId ?? this.identityId,
    lastShared: lastShared ?? this.lastShared,
    passwordVersionShared: passwordVersionShared ?? this.passwordVersionShared,
    settingsVersionShared: settingsVersionShared ?? this.settingsVersionShared,
  );
  SecretShareData copyWithCompanion(SecretShareCompanion data) {
    return SecretShareData(
      identityId: data.identityId.present
          ? data.identityId.value
          : this.identityId,
      lastShared: data.lastShared.present
          ? data.lastShared.value
          : this.lastShared,
      passwordVersionShared: data.passwordVersionShared.present
          ? data.passwordVersionShared.value
          : this.passwordVersionShared,
      settingsVersionShared: data.settingsVersionShared.present
          ? data.settingsVersionShared.value
          : this.settingsVersionShared,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SecretShareData(')
          ..write('identityId: $identityId, ')
          ..write('lastShared: $lastShared, ')
          ..write('passwordVersionShared: $passwordVersionShared, ')
          ..write('settingsVersionShared: $settingsVersionShared')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    identityId,
    lastShared,
    passwordVersionShared,
    settingsVersionShared,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SecretShareData &&
          other.identityId == this.identityId &&
          other.lastShared == this.lastShared &&
          other.passwordVersionShared == this.passwordVersionShared &&
          other.settingsVersionShared == this.settingsVersionShared);
}

class SecretShareCompanion extends UpdateCompanion<SecretShareData> {
  final Value<String> identityId;
  final Value<int> lastShared;
  final Value<int> passwordVersionShared;
  final Value<int> settingsVersionShared;
  final Value<int> rowid;
  const SecretShareCompanion({
    this.identityId = const Value.absent(),
    this.lastShared = const Value.absent(),
    this.passwordVersionShared = const Value.absent(),
    this.settingsVersionShared = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SecretShareCompanion.insert({
    required String identityId,
    required int lastShared,
    required int passwordVersionShared,
    required int settingsVersionShared,
    this.rowid = const Value.absent(),
  }) : identityId = Value(identityId),
       lastShared = Value(lastShared),
       passwordVersionShared = Value(passwordVersionShared),
       settingsVersionShared = Value(settingsVersionShared);
  static Insertable<SecretShareData> custom({
    Expression<String>? identityId,
    Expression<int>? lastShared,
    Expression<int>? passwordVersionShared,
    Expression<int>? settingsVersionShared,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (identityId != null) 'identity_id': identityId,
      if (lastShared != null) 'last_shared': lastShared,
      if (passwordVersionShared != null)
        'password_version_shared': passwordVersionShared,
      if (settingsVersionShared != null)
        'settings_version_shared': settingsVersionShared,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SecretShareCompanion copyWith({
    Value<String>? identityId,
    Value<int>? lastShared,
    Value<int>? passwordVersionShared,
    Value<int>? settingsVersionShared,
    Value<int>? rowid,
  }) {
    return SecretShareCompanion(
      identityId: identityId ?? this.identityId,
      lastShared: lastShared ?? this.lastShared,
      passwordVersionShared:
          passwordVersionShared ?? this.passwordVersionShared,
      settingsVersionShared:
          settingsVersionShared ?? this.settingsVersionShared,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (identityId.present) {
      map['identity_id'] = Variable<String>(identityId.value);
    }
    if (lastShared.present) {
      map['last_shared'] = Variable<int>(lastShared.value);
    }
    if (passwordVersionShared.present) {
      map['password_version_shared'] = Variable<int>(
        passwordVersionShared.value,
      );
    }
    if (settingsVersionShared.present) {
      map['settings_version_shared'] = Variable<int>(
        settingsVersionShared.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SecretShareCompanion(')
          ..write('identityId: $identityId, ')
          ..write('lastShared: $lastShared, ')
          ..write('passwordVersionShared: $passwordVersionShared, ')
          ..write('settingsVersionShared: $settingsVersionShared, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationTypeMeta = const VerificationMeta(
    'conversationType',
  );
  @override
  late final GeneratedColumn<int> conversationType = GeneratedColumn<int>(
    'conversation_type',
    aliasedName,
    false,
    check: () => conversationType.isIn([0, 1, 2]),
    type: DriftSqlType.int,
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
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastReadMessageIdMeta = const VerificationMeta(
    'lastReadMessageId',
  );
  @override
  late final GeneratedColumn<String> lastReadMessageId =
      GeneratedColumn<String>(
        'last_read_message_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastReadMessageMeta = const VerificationMeta(
    'lastReadMessage',
  );
  @override
  late final GeneratedColumn<String> lastReadMessage = GeneratedColumn<String>(
    'last_read_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageIdMeta = const VerificationMeta(
    'lastMessageId',
  );
  @override
  late final GeneratedColumn<String> lastMessageId = GeneratedColumn<String>(
    'last_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageMeta = const VerificationMeta(
    'lastMessage',
  );
  @override
  late final GeneratedColumn<String> lastMessage = GeneratedColumn<String>(
    'last_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<int> pinned = GeneratedColumn<int>(
    'pinned',
    aliasedName,
    false,
    check: () => pinned.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pinnedPositionMeta = const VerificationMeta(
    'pinnedPosition',
  );
  @override
  late final GeneratedColumn<int> pinnedPosition = GeneratedColumn<int>(
    'pinned_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colourMeta = const VerificationMeta('colour');
  @override
  late final GeneratedColumn<String> colour = GeneratedColumn<String>(
    'colour',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mutedMeta = const VerificationMeta('muted');
  @override
  late final GeneratedColumn<int> muted = GeneratedColumn<int>(
    'muted',
    aliasedName,
    false,
    check: () => muted.isIn([0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mentionsMeta = const VerificationMeta(
    'mentions',
  );
  @override
  late final GeneratedColumn<int> mentions = GeneratedColumn<int>(
    'mentions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    conversationId,
    conversationType,
    displayName,
    avatar,
    unreadCount,
    lastReadMessageId,
    lastReadMessage,
    lastMessageId,
    lastMessage,
    pinned,
    pinnedPosition,
    updatedAt,
    colour,
    muted,
    mentions,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('conversation_type')) {
      context.handle(
        _conversationTypeMeta,
        conversationType.isAcceptableOrUnknown(
          data['conversation_type']!,
          _conversationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationTypeMeta);
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
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('last_read_message_id')) {
      context.handle(
        _lastReadMessageIdMeta,
        lastReadMessageId.isAcceptableOrUnknown(
          data['last_read_message_id']!,
          _lastReadMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('last_read_message')) {
      context.handle(
        _lastReadMessageMeta,
        lastReadMessage.isAcceptableOrUnknown(
          data['last_read_message']!,
          _lastReadMessageMeta,
        ),
      );
    }
    if (data.containsKey('last_message_id')) {
      context.handle(
        _lastMessageIdMeta,
        lastMessageId.isAcceptableOrUnknown(
          data['last_message_id']!,
          _lastMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('last_message')) {
      context.handle(
        _lastMessageMeta,
        lastMessage.isAcceptableOrUnknown(
          data['last_message']!,
          _lastMessageMeta,
        ),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('pinned_position')) {
      context.handle(
        _pinnedPositionMeta,
        pinnedPosition.isAcceptableOrUnknown(
          data['pinned_position']!,
          _pinnedPositionMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('colour')) {
      context.handle(
        _colourMeta,
        colour.isAcceptableOrUnknown(data['colour']!, _colourMeta),
      );
    } else if (isInserting) {
      context.missing(_colourMeta);
    }
    if (data.containsKey('muted')) {
      context.handle(
        _mutedMeta,
        muted.isAcceptableOrUnknown(data['muted']!, _mutedMeta),
      );
    }
    if (data.containsKey('mentions')) {
      context.handle(
        _mentionsMeta,
        mentions.isAcceptableOrUnknown(data['mentions']!, _mentionsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conversationId};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      conversationType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_type'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      lastReadMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_read_message_id'],
      ),
      lastReadMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_read_message'],
      ),
      lastMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_id'],
      ),
      lastMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message'],
      ),
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pinned'],
      )!,
      pinnedPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pinned_position'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      colour: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colour'],
      )!,
      muted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}muted'],
      )!,
      mentions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mentions'],
      )!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String conversationId;
  final int conversationType;
  final String displayName;
  final String? avatar;
  final int unreadCount;
  final String? lastReadMessageId;
  final String? lastReadMessage;
  final String? lastMessageId;
  final String? lastMessage;
  final int pinned;
  final int? pinnedPosition;
  final int updatedAt;
  final String colour;
  final int muted;
  final int mentions;
  const SyncStateData({
    required this.conversationId,
    required this.conversationType,
    required this.displayName,
    this.avatar,
    required this.unreadCount,
    this.lastReadMessageId,
    this.lastReadMessage,
    this.lastMessageId,
    this.lastMessage,
    required this.pinned,
    this.pinnedPosition,
    required this.updatedAt,
    required this.colour,
    required this.muted,
    required this.mentions,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['conversation_id'] = Variable<String>(conversationId);
    map['conversation_type'] = Variable<int>(conversationType);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    if (!nullToAbsent || lastReadMessageId != null) {
      map['last_read_message_id'] = Variable<String>(lastReadMessageId);
    }
    if (!nullToAbsent || lastReadMessage != null) {
      map['last_read_message'] = Variable<String>(lastReadMessage);
    }
    if (!nullToAbsent || lastMessageId != null) {
      map['last_message_id'] = Variable<String>(lastMessageId);
    }
    if (!nullToAbsent || lastMessage != null) {
      map['last_message'] = Variable<String>(lastMessage);
    }
    map['pinned'] = Variable<int>(pinned);
    if (!nullToAbsent || pinnedPosition != null) {
      map['pinned_position'] = Variable<int>(pinnedPosition);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    map['colour'] = Variable<String>(colour);
    map['muted'] = Variable<int>(muted);
    map['mentions'] = Variable<int>(mentions);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      conversationId: Value(conversationId),
      conversationType: Value(conversationType),
      displayName: Value(displayName),
      avatar: avatar == null && nullToAbsent
          ? const Value.absent()
          : Value(avatar),
      unreadCount: Value(unreadCount),
      lastReadMessageId: lastReadMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadMessageId),
      lastReadMessage: lastReadMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadMessage),
      lastMessageId: lastMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageId),
      lastMessage: lastMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessage),
      pinned: Value(pinned),
      pinnedPosition: pinnedPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(pinnedPosition),
      updatedAt: Value(updatedAt),
      colour: Value(colour),
      muted: Value(muted),
      mentions: Value(mentions),
    );
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      conversationId: serializer.fromJson<String>(json['conversationId']),
      conversationType: serializer.fromJson<int>(json['conversationType']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      lastReadMessageId: serializer.fromJson<String?>(
        json['lastReadMessageId'],
      ),
      lastReadMessage: serializer.fromJson<String?>(json['lastReadMessage']),
      lastMessageId: serializer.fromJson<String?>(json['lastMessageId']),
      lastMessage: serializer.fromJson<String?>(json['lastMessage']),
      pinned: serializer.fromJson<int>(json['pinned']),
      pinnedPosition: serializer.fromJson<int?>(json['pinnedPosition']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      colour: serializer.fromJson<String>(json['colour']),
      muted: serializer.fromJson<int>(json['muted']),
      mentions: serializer.fromJson<int>(json['mentions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conversationId': serializer.toJson<String>(conversationId),
      'conversationType': serializer.toJson<int>(conversationType),
      'displayName': serializer.toJson<String>(displayName),
      'avatar': serializer.toJson<String?>(avatar),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'lastReadMessageId': serializer.toJson<String?>(lastReadMessageId),
      'lastReadMessage': serializer.toJson<String?>(lastReadMessage),
      'lastMessageId': serializer.toJson<String?>(lastMessageId),
      'lastMessage': serializer.toJson<String?>(lastMessage),
      'pinned': serializer.toJson<int>(pinned),
      'pinnedPosition': serializer.toJson<int?>(pinnedPosition),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'colour': serializer.toJson<String>(colour),
      'muted': serializer.toJson<int>(muted),
      'mentions': serializer.toJson<int>(mentions),
    };
  }

  SyncStateData copyWith({
    String? conversationId,
    int? conversationType,
    String? displayName,
    Value<String?> avatar = const Value.absent(),
    int? unreadCount,
    Value<String?> lastReadMessageId = const Value.absent(),
    Value<String?> lastReadMessage = const Value.absent(),
    Value<String?> lastMessageId = const Value.absent(),
    Value<String?> lastMessage = const Value.absent(),
    int? pinned,
    Value<int?> pinnedPosition = const Value.absent(),
    int? updatedAt,
    String? colour,
    int? muted,
    int? mentions,
  }) => SyncStateData(
    conversationId: conversationId ?? this.conversationId,
    conversationType: conversationType ?? this.conversationType,
    displayName: displayName ?? this.displayName,
    avatar: avatar.present ? avatar.value : this.avatar,
    unreadCount: unreadCount ?? this.unreadCount,
    lastReadMessageId: lastReadMessageId.present
        ? lastReadMessageId.value
        : this.lastReadMessageId,
    lastReadMessage: lastReadMessage.present
        ? lastReadMessage.value
        : this.lastReadMessage,
    lastMessageId: lastMessageId.present
        ? lastMessageId.value
        : this.lastMessageId,
    lastMessage: lastMessage.present ? lastMessage.value : this.lastMessage,
    pinned: pinned ?? this.pinned,
    pinnedPosition: pinnedPosition.present
        ? pinnedPosition.value
        : this.pinnedPosition,
    updatedAt: updatedAt ?? this.updatedAt,
    colour: colour ?? this.colour,
    muted: muted ?? this.muted,
    mentions: mentions ?? this.mentions,
  );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      conversationType: data.conversationType.present
          ? data.conversationType.value
          : this.conversationType,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      lastReadMessageId: data.lastReadMessageId.present
          ? data.lastReadMessageId.value
          : this.lastReadMessageId,
      lastReadMessage: data.lastReadMessage.present
          ? data.lastReadMessage.value
          : this.lastReadMessage,
      lastMessageId: data.lastMessageId.present
          ? data.lastMessageId.value
          : this.lastMessageId,
      lastMessage: data.lastMessage.present
          ? data.lastMessage.value
          : this.lastMessage,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      pinnedPosition: data.pinnedPosition.present
          ? data.pinnedPosition.value
          : this.pinnedPosition,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      colour: data.colour.present ? data.colour.value : this.colour,
      muted: data.muted.present ? data.muted.value : this.muted,
      mentions: data.mentions.present ? data.mentions.value : this.mentions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('conversationId: $conversationId, ')
          ..write('conversationType: $conversationType, ')
          ..write('displayName: $displayName, ')
          ..write('avatar: $avatar, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('lastReadMessageId: $lastReadMessageId, ')
          ..write('lastReadMessage: $lastReadMessage, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('pinned: $pinned, ')
          ..write('pinnedPosition: $pinnedPosition, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('colour: $colour, ')
          ..write('muted: $muted, ')
          ..write('mentions: $mentions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    conversationId,
    conversationType,
    displayName,
    avatar,
    unreadCount,
    lastReadMessageId,
    lastReadMessage,
    lastMessageId,
    lastMessage,
    pinned,
    pinnedPosition,
    updatedAt,
    colour,
    muted,
    mentions,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.conversationId == this.conversationId &&
          other.conversationType == this.conversationType &&
          other.displayName == this.displayName &&
          other.avatar == this.avatar &&
          other.unreadCount == this.unreadCount &&
          other.lastReadMessageId == this.lastReadMessageId &&
          other.lastReadMessage == this.lastReadMessage &&
          other.lastMessageId == this.lastMessageId &&
          other.lastMessage == this.lastMessage &&
          other.pinned == this.pinned &&
          other.pinnedPosition == this.pinnedPosition &&
          other.updatedAt == this.updatedAt &&
          other.colour == this.colour &&
          other.muted == this.muted &&
          other.mentions == this.mentions);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> conversationId;
  final Value<int> conversationType;
  final Value<String> displayName;
  final Value<String?> avatar;
  final Value<int> unreadCount;
  final Value<String?> lastReadMessageId;
  final Value<String?> lastReadMessage;
  final Value<String?> lastMessageId;
  final Value<String?> lastMessage;
  final Value<int> pinned;
  final Value<int?> pinnedPosition;
  final Value<int> updatedAt;
  final Value<String> colour;
  final Value<int> muted;
  final Value<int> mentions;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.conversationId = const Value.absent(),
    this.conversationType = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatar = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.lastReadMessageId = const Value.absent(),
    this.lastReadMessage = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.pinned = const Value.absent(),
    this.pinnedPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.colour = const Value.absent(),
    this.muted = const Value.absent(),
    this.mentions = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String conversationId,
    required int conversationType,
    required String displayName,
    this.avatar = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.lastReadMessageId = const Value.absent(),
    this.lastReadMessage = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.pinned = const Value.absent(),
    this.pinnedPosition = const Value.absent(),
    required int updatedAt,
    required String colour,
    this.muted = const Value.absent(),
    this.mentions = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : conversationId = Value(conversationId),
       conversationType = Value(conversationType),
       displayName = Value(displayName),
       updatedAt = Value(updatedAt),
       colour = Value(colour);
  static Insertable<SyncStateData> custom({
    Expression<String>? conversationId,
    Expression<int>? conversationType,
    Expression<String>? displayName,
    Expression<String>? avatar,
    Expression<int>? unreadCount,
    Expression<String>? lastReadMessageId,
    Expression<String>? lastReadMessage,
    Expression<String>? lastMessageId,
    Expression<String>? lastMessage,
    Expression<int>? pinned,
    Expression<int>? pinnedPosition,
    Expression<int>? updatedAt,
    Expression<String>? colour,
    Expression<int>? muted,
    Expression<int>? mentions,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (conversationId != null) 'conversation_id': conversationId,
      if (conversationType != null) 'conversation_type': conversationType,
      if (displayName != null) 'display_name': displayName,
      if (avatar != null) 'avatar': avatar,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (lastReadMessageId != null) 'last_read_message_id': lastReadMessageId,
      if (lastReadMessage != null) 'last_read_message': lastReadMessage,
      if (lastMessageId != null) 'last_message_id': lastMessageId,
      if (lastMessage != null) 'last_message': lastMessage,
      if (pinned != null) 'pinned': pinned,
      if (pinnedPosition != null) 'pinned_position': pinnedPosition,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (colour != null) 'colour': colour,
      if (muted != null) 'muted': muted,
      if (mentions != null) 'mentions': mentions,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? conversationId,
    Value<int>? conversationType,
    Value<String>? displayName,
    Value<String?>? avatar,
    Value<int>? unreadCount,
    Value<String?>? lastReadMessageId,
    Value<String?>? lastReadMessage,
    Value<String?>? lastMessageId,
    Value<String?>? lastMessage,
    Value<int>? pinned,
    Value<int?>? pinnedPosition,
    Value<int>? updatedAt,
    Value<String>? colour,
    Value<int>? muted,
    Value<int>? mentions,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      conversationId: conversationId ?? this.conversationId,
      conversationType: conversationType ?? this.conversationType,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      unreadCount: unreadCount ?? this.unreadCount,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      lastReadMessage: lastReadMessage ?? this.lastReadMessage,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessage: lastMessage ?? this.lastMessage,
      pinned: pinned ?? this.pinned,
      pinnedPosition: pinnedPosition ?? this.pinnedPosition,
      updatedAt: updatedAt ?? this.updatedAt,
      colour: colour ?? this.colour,
      muted: muted ?? this.muted,
      mentions: mentions ?? this.mentions,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (conversationType.present) {
      map['conversation_type'] = Variable<int>(conversationType.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (lastReadMessageId.present) {
      map['last_read_message_id'] = Variable<String>(lastReadMessageId.value);
    }
    if (lastReadMessage.present) {
      map['last_read_message'] = Variable<String>(lastReadMessage.value);
    }
    if (lastMessageId.present) {
      map['last_message_id'] = Variable<String>(lastMessageId.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<String>(lastMessage.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<int>(pinned.value);
    }
    if (pinnedPosition.present) {
      map['pinned_position'] = Variable<int>(pinnedPosition.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (colour.present) {
      map['colour'] = Variable<String>(colour.value);
    }
    if (muted.present) {
      map['muted'] = Variable<int>(muted.value);
    }
    if (mentions.present) {
      map['mentions'] = Variable<int>(mentions.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('conversationId: $conversationId, ')
          ..write('conversationType: $conversationType, ')
          ..write('displayName: $displayName, ')
          ..write('avatar: $avatar, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('lastReadMessageId: $lastReadMessageId, ')
          ..write('lastReadMessage: $lastReadMessage, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('pinned: $pinned, ')
          ..write('pinnedPosition: $pinnedPosition, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('colour: $colour, ')
          ..write('muted: $muted, ')
          ..write('mentions: $mentions, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $IdentityTable identity = $IdentityTable(this);
  late final $ServersTable servers = $ServersTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $ContactsNetworkTable contactsNetwork = $ContactsNetworkTable(
    this,
  );
  late final $ContactNetworkMembersTable contactNetworkMembers =
      $ContactNetworkMembersTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $GroupMembersTable groupMembers = $GroupMembersTable(this);
  late final $ConnectionRequestsTable connectionRequests =
      $ConnectionRequestsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $ShamirsSecretTable shamirsSecret = $ShamirsSecretTable(this);
  late final $SecretShareTable secretShare = $SecretShareTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final IdentityDao identityDao = IdentityDao(this as AppDatabase);
  late final ServersDao serversDao = ServersDao(this as dynamic /* = invalid*/);
  late final ConversationsDao conversationsDao = ConversationsDao(
    this as dynamic /* = invalid*/,
  );
  late final MessagesDao messagesDao = MessagesDao(
    this as dynamic /* = invalid*/,
  );
  late final ContactsDao contactsDao = ContactsDao(
    this as dynamic /* = invalid*/,
  );
  late final ContactsNetworkDao contactsNetworkDao = ContactsNetworkDao(
    this as dynamic /* = invalid*/,
  );
  late final ContactNetworkMembersDao contactNetworkMembersDao =
      ContactNetworkMembersDao(this as dynamic /* = invalid*/);
  late final GroupsDao groupsDao = GroupsDao(this as dynamic /* = invalid*/);
  late final GroupMembersDao groupMembersDao = GroupMembersDao(
    this as dynamic /* = invalid*/,
  );
  late final ConnectionRequestsDao connectionRequestsDao =
      ConnectionRequestsDao(this as dynamic /* = invalid*/);
  late final TasksDao tasksDao = TasksDao(this as dynamic /* = invalid*/);
  late final ShamirsSecretDao shamirsSecretDao = ShamirsSecretDao(
    this as dynamic /* = invalid*/,
  );
  late final SecretShareDao secretShareDao = SecretShareDao(
    this as dynamic /* = invalid*/,
  );
  late final SyncStateDao syncStateDao = SyncStateDao(
    this as dynamic /* = invalid*/,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    identity,
    servers,
    conversations,
    messages,
    contacts,
    contactsNetwork,
    contactNetworkMembers,
    groups,
    groupMembers,
    connectionRequests,
    tasks,
    shamirsSecret,
    secretShare,
    syncState,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'conversations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('messages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'conversations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contacts', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'contacts_network',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contact_network_members', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'contacts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contact_network_members', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_members', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'identity',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_members', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'identity',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('connection_requests', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'identity',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('connection_requests', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('connection_requests', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'servers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tasks', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'identity',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shamirs_secret', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'identity',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('secret_share', kind: UpdateKind.delete)],
    ),
  ]);
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

final class $$IdentityTableReferences
    extends BaseReferences<_$AppDatabase, $IdentityTable, IdentityData> {
  $$IdentityTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
  _groupMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupMembers,
    aliasName: 'identity__identity_id__group_members__identity_id',
  );

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager($_db, $_db.groupMembers)
        .filter(
          (f) => f.identityId.identityId.sqlEquals(
            $_itemColumn<String>('identity_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ShamirsSecretTable, List<ShamirsSecretData>>
  _shamirsSecretRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shamirsSecret,
    aliasName: 'identity__identity_id__shamirs_secret__identity_id',
  );

  $$ShamirsSecretTableProcessedTableManager get shamirsSecretRefs {
    final manager = $$ShamirsSecretTableTableManager($_db, $_db.shamirsSecret)
        .filter(
          (f) => f.identityId.identityId.sqlEquals(
            $_itemColumn<String>('identity_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_shamirsSecretRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SecretShareTable, List<SecretShareData>>
  _secretShareRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.secretShare,
    aliasName: 'identity__identity_id__secret_share__identity_id',
  );

  $$SecretShareTableProcessedTableManager get secretShareRefs {
    final manager = $$SecretShareTableTableManager($_db, $_db.secretShare)
        .filter(
          (f) => f.identityId.identityId.sqlEquals(
            $_itemColumn<String>('identity_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_secretShareRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  Expression<bool> groupMembersRefs(
    Expression<bool> Function($$GroupMembersTableFilterComposer f) f,
  ) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableFilterComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> shamirsSecretRefs(
    Expression<bool> Function($$ShamirsSecretTableFilterComposer f) f,
  ) {
    final $$ShamirsSecretTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.shamirsSecret,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShamirsSecretTableFilterComposer(
            $db: $db,
            $table: $db.shamirsSecret,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> secretShareRefs(
    Expression<bool> Function($$SecretShareTableFilterComposer f) f,
  ) {
    final $$SecretShareTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.secretShare,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SecretShareTableFilterComposer(
            $db: $db,
            $table: $db.secretShare,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  Expression<T> groupMembersRefs<T extends Object>(
    Expression<T> Function($$GroupMembersTableAnnotationComposer a) f,
  ) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> shamirsSecretRefs<T extends Object>(
    Expression<T> Function($$ShamirsSecretTableAnnotationComposer a) f,
  ) {
    final $$ShamirsSecretTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.shamirsSecret,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShamirsSecretTableAnnotationComposer(
            $db: $db,
            $table: $db.shamirsSecret,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> secretShareRefs<T extends Object>(
    Expression<T> Function($$SecretShareTableAnnotationComposer a) f,
  ) {
    final $$SecretShareTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.secretShare,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SecretShareTableAnnotationComposer(
            $db: $db,
            $table: $db.secretShare,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (IdentityData, $$IdentityTableReferences),
          IdentityData,
          PrefetchHooks Function({
            bool groupMembersRefs,
            bool shamirsSecretRefs,
            bool secretShareRefs,
          })
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
              .map(
                (e) => (
                  e.readTable(table),
                  $$IdentityTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                groupMembersRefs = false,
                shamirsSecretRefs = false,
                secretShareRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (groupMembersRefs) db.groupMembers,
                    if (shamirsSecretRefs) db.shamirsSecret,
                    if (secretShareRefs) db.secretShare,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (groupMembersRefs)
                        await $_getPrefetchedData<
                          IdentityData,
                          $IdentityTable,
                          GroupMember
                        >(
                          currentTable: table,
                          referencedTable: $$IdentityTableReferences
                              ._groupMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IdentityTableReferences(
                                db,
                                table,
                                p0,
                              ).groupMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.identityId == item.identityId,
                              ),
                          typedResults: items,
                        ),
                      if (shamirsSecretRefs)
                        await $_getPrefetchedData<
                          IdentityData,
                          $IdentityTable,
                          ShamirsSecretData
                        >(
                          currentTable: table,
                          referencedTable: $$IdentityTableReferences
                              ._shamirsSecretRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IdentityTableReferences(
                                db,
                                table,
                                p0,
                              ).shamirsSecretRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.identityId == item.identityId,
                              ),
                          typedResults: items,
                        ),
                      if (secretShareRefs)
                        await $_getPrefetchedData<
                          IdentityData,
                          $IdentityTable,
                          SecretShareData
                        >(
                          currentTable: table,
                          referencedTable: $$IdentityTableReferences
                              ._secretShareRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IdentityTableReferences(
                                db,
                                table,
                                p0,
                              ).secretShareRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.identityId == item.identityId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
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
      (IdentityData, $$IdentityTableReferences),
      IdentityData,
      PrefetchHooks Function({
        bool groupMembersRefs,
        bool shamirsSecretRefs,
        bool secretShareRefs,
      })
    >;
typedef $$ServersTableCreateCompanionBuilder = ServersCompanion Function({
  required String serverId,
  required String serverUrl,
  required String mediaUrl,
  Value<int> mediaSizeLimit,
  required DateTime mediaLastReset,
  Value<int> totalMediaSent,
  required String serverName,
  Value<int> mediaTimer,
  Value<int> maxPayload,
  Value<int> capabilities,
  Value<int> rowid,
});
typedef $$ServersTableUpdateCompanionBuilder = ServersCompanion Function({
  Value<String> serverId,
  Value<String> serverUrl,
  Value<String> mediaUrl,
  Value<int> mediaSizeLimit,
  Value<DateTime> mediaLastReset,
  Value<int> totalMediaSent,
  Value<String> serverName,
  Value<int> mediaTimer,
  Value<int> maxPayload,
  Value<int> capabilities,
  Value<int> rowid,
});

final class $$ServersTableReferences
    extends BaseReferences<_$AppDatabase, $ServersTable, Server> {
  $$ServersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: 'servers__server_id__tasks__server_id',
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager($_db, $_db.tasks).filter(
      (f) => f.serverId.serverId.sqlEquals($_itemColumn<String>('server_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ServersTableFilterComposer
    extends Composer<_$AppDatabase, $ServersTable> {
  $$ServersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverUrl => $composableBuilder(
    column: $table.serverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaUrl => $composableBuilder(
    column: $table.mediaUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mediaSizeLimit => $composableBuilder(
    column: $table.mediaSizeLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get mediaLastReset => $composableBuilder(
    column: $table.mediaLastReset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMediaSent => $composableBuilder(
    column: $table.totalMediaSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverName => $composableBuilder(
    column: $table.serverName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mediaTimer => $composableBuilder(
    column: $table.mediaTimer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxPayload => $composableBuilder(
    column: $table.maxPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capabilities => $composableBuilder(
    column: $table.capabilities,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serverId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.serverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServersTableOrderingComposer
    extends Composer<_$AppDatabase, $ServersTable> {
  $$ServersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverUrl => $composableBuilder(
    column: $table.serverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaUrl => $composableBuilder(
    column: $table.mediaUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaSizeLimit => $composableBuilder(
    column: $table.mediaSizeLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get mediaLastReset => $composableBuilder(
    column: $table.mediaLastReset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMediaSent => $composableBuilder(
    column: $table.totalMediaSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverName => $composableBuilder(
    column: $table.serverName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaTimer => $composableBuilder(
    column: $table.mediaTimer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxPayload => $composableBuilder(
    column: $table.maxPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capabilities => $composableBuilder(
    column: $table.capabilities,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServersTable> {
  $$ServersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get serverUrl =>
      $composableBuilder(column: $table.serverUrl, builder: (column) => column);

  GeneratedColumn<String> get mediaUrl =>
      $composableBuilder(column: $table.mediaUrl, builder: (column) => column);

  GeneratedColumn<int> get mediaSizeLimit => $composableBuilder(
    column: $table.mediaSizeLimit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get mediaLastReset => $composableBuilder(
    column: $table.mediaLastReset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalMediaSent => $composableBuilder(
    column: $table.totalMediaSent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverName => $composableBuilder(
    column: $table.serverName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mediaTimer => $composableBuilder(
    column: $table.mediaTimer,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxPayload => $composableBuilder(
    column: $table.maxPayload,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capabilities => $composableBuilder(
    column: $table.capabilities,
    builder: (column) => column,
  );

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serverId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.serverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServersTable,
          Server,
          $$ServersTableFilterComposer,
          $$ServersTableOrderingComposer,
          $$ServersTableAnnotationComposer,
          $$ServersTableCreateCompanionBuilder,
          $$ServersTableUpdateCompanionBuilder,
          (Server, $$ServersTableReferences),
          Server,
          PrefetchHooks Function({bool tasksRefs})
        > {
  $$ServersTableTableManager(_$AppDatabase db, $ServersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> serverId = const Value.absent(),
                Value<String> serverUrl = const Value.absent(),
                Value<String> mediaUrl = const Value.absent(),
                Value<int> mediaSizeLimit = const Value.absent(),
                Value<DateTime> mediaLastReset = const Value.absent(),
                Value<int> totalMediaSent = const Value.absent(),
                Value<String> serverName = const Value.absent(),
                Value<int> mediaTimer = const Value.absent(),
                Value<int> maxPayload = const Value.absent(),
                Value<int> capabilities = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServersCompanion(
                serverId: serverId,
                serverUrl: serverUrl,
                mediaUrl: mediaUrl,
                mediaSizeLimit: mediaSizeLimit,
                mediaLastReset: mediaLastReset,
                totalMediaSent: totalMediaSent,
                serverName: serverName,
                mediaTimer: mediaTimer,
                maxPayload: maxPayload,
                capabilities: capabilities,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String serverId,
                required String serverUrl,
                required String mediaUrl,
                Value<int> mediaSizeLimit = const Value.absent(),
                required DateTime mediaLastReset,
                Value<int> totalMediaSent = const Value.absent(),
                required String serverName,
                Value<int> mediaTimer = const Value.absent(),
                Value<int> maxPayload = const Value.absent(),
                Value<int> capabilities = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServersCompanion.insert(
                serverId: serverId,
                serverUrl: serverUrl,
                mediaUrl: mediaUrl,
                mediaSizeLimit: mediaSizeLimit,
                mediaLastReset: mediaLastReset,
                totalMediaSent: totalMediaSent,
                serverName: serverName,
                mediaTimer: mediaTimer,
                maxPayload: maxPayload,
                capabilities: capabilities,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ServersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksRefs) db.tasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<Server, $ServersTable, Task>(
                      currentTable: table,
                      referencedTable: $$ServersTableReferences._tasksRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$ServersTableReferences(db, table, p0).tasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.serverId == item.serverId,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ServersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServersTable,
      Server,
      $$ServersTableFilterComposer,
      $$ServersTableOrderingComposer,
      $$ServersTableAnnotationComposer,
      $$ServersTableCreateCompanionBuilder,
      $$ServersTableUpdateCompanionBuilder,
      (Server, $$ServersTableReferences),
      Server,
      PrefetchHooks Function({bool tasksRefs})
    >;
typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      required String conversationId,
      required int conversationType,
      Value<String?> lastMessageId,
      Value<int?> lastMessageTime,
      Value<int> unreadCount,
      Value<int> muted,
      Value<int> pinned,
      Value<int> archived,
      Value<String?> draft,
      required String serverId,
      required int createdAt,
      required int updatedAt,
      Value<String?> sound,
      Value<int> badge,
      Value<int> vibration,
      Value<int> rowid,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<String> conversationId,
      Value<int> conversationType,
      Value<String?> lastMessageId,
      Value<int?> lastMessageTime,
      Value<int> unreadCount,
      Value<int> muted,
      Value<int> pinned,
      Value<int> archived,
      Value<String?> draft,
      Value<String> serverId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String?> sound,
      Value<int> badge,
      Value<int> vibration,
      Value<int> rowid,
    });

final class $$ConversationsTableReferences
    extends BaseReferences<_$AppDatabase, $ConversationsTable, Conversation> {
  $$ConversationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: 'conversations__conversation_id__messages__conversation_id',
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager($_db, $_db.messages).filter(
      (f) => f.conversationId.conversationId.sqlEquals(
        $_itemColumn<String>('conversation_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ContactsTable, List<Contact>> _contactsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.contacts,
    aliasName: 'conversations__conversation_id__contacts__conversation_id',
  );

  $$ContactsTableProcessedTableManager get contactsRefs {
    final manager = $$ContactsTableTableManager($_db, $_db.contacts).filter(
      (f) => f.conversationId.conversationId.sqlEquals(
        $_itemColumn<String>('conversation_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_contactsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conversationType => $composableBuilder(
    column: $table.conversationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageTime => $composableBuilder(
    column: $table.lastMessageTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get draft => $composableBuilder(
    column: $table.draft,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get badge => $composableBuilder(
    column: $table.badge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vibration => $composableBuilder(
    column: $table.vibration,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> contactsRefs(
    Expression<bool> Function($$ContactsTableFilterComposer f) f,
  ) {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableFilterComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conversationType => $composableBuilder(
    column: $table.conversationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageTime => $composableBuilder(
    column: $table.lastMessageTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get draft => $composableBuilder(
    column: $table.draft,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get badge => $composableBuilder(
    column: $table.badge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vibration => $composableBuilder(
    column: $table.vibration,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get conversationType => $composableBuilder(
    column: $table.conversationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessageTime => $composableBuilder(
    column: $table.lastMessageTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get muted =>
      $composableBuilder(column: $table.muted, builder: (column) => column);

  GeneratedColumn<int> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<int> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<String> get draft =>
      $composableBuilder(column: $table.draft, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get sound =>
      $composableBuilder(column: $table.sound, builder: (column) => column);

  GeneratedColumn<int> get badge =>
      $composableBuilder(column: $table.badge, builder: (column) => column);

  GeneratedColumn<int> get vibration =>
      $composableBuilder(column: $table.vibration, builder: (column) => column);

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> contactsRefs<T extends Object>(
    Expression<T> Function($$ContactsTableAnnotationComposer a) f,
  ) {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationsTable,
          Conversation,
          $$ConversationsTableFilterComposer,
          $$ConversationsTableOrderingComposer,
          $$ConversationsTableAnnotationComposer,
          $$ConversationsTableCreateCompanionBuilder,
          $$ConversationsTableUpdateCompanionBuilder,
          (Conversation, $$ConversationsTableReferences),
          Conversation,
          PrefetchHooks Function({bool messagesRefs, bool contactsRefs})
        > {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> conversationId = const Value.absent(),
                Value<int> conversationType = const Value.absent(),
                Value<String?> lastMessageId = const Value.absent(),
                Value<int?> lastMessageTime = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<int> muted = const Value.absent(),
                Value<int> pinned = const Value.absent(),
                Value<int> archived = const Value.absent(),
                Value<String?> draft = const Value.absent(),
                Value<String> serverId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String?> sound = const Value.absent(),
                Value<int> badge = const Value.absent(),
                Value<int> vibration = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion(
                conversationId: conversationId,
                conversationType: conversationType,
                lastMessageId: lastMessageId,
                lastMessageTime: lastMessageTime,
                unreadCount: unreadCount,
                muted: muted,
                pinned: pinned,
                archived: archived,
                draft: draft,
                serverId: serverId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sound: sound,
                badge: badge,
                vibration: vibration,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String conversationId,
                required int conversationType,
                Value<String?> lastMessageId = const Value.absent(),
                Value<int?> lastMessageTime = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<int> muted = const Value.absent(),
                Value<int> pinned = const Value.absent(),
                Value<int> archived = const Value.absent(),
                Value<String?> draft = const Value.absent(),
                required String serverId,
                required int createdAt,
                required int updatedAt,
                Value<String?> sound = const Value.absent(),
                Value<int> badge = const Value.absent(),
                Value<int> vibration = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion.insert(
                conversationId: conversationId,
                conversationType: conversationType,
                lastMessageId: lastMessageId,
                lastMessageTime: lastMessageTime,
                unreadCount: unreadCount,
                muted: muted,
                pinned: pinned,
                archived: archived,
                draft: draft,
                serverId: serverId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sound: sound,
                badge: badge,
                vibration: vibration,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConversationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({messagesRefs = false, contactsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (messagesRefs) db.messages,
                    if (contactsRefs) db.contacts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (messagesRefs)
                        await $_getPrefetchedData<
                          Conversation,
                          $ConversationsTable,
                          Message
                        >(
                          currentTable: table,
                          referencedTable: $$ConversationsTableReferences
                              ._messagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConversationsTableReferences(
                                db,
                                table,
                                p0,
                              ).messagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.conversationId == item.conversationId,
                              ),
                          typedResults: items,
                        ),
                      if (contactsRefs)
                        await $_getPrefetchedData<
                          Conversation,
                          $ConversationsTable,
                          Contact
                        >(
                          currentTable: table,
                          referencedTable: $$ConversationsTableReferences
                              ._contactsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConversationsTableReferences(
                                db,
                                table,
                                p0,
                              ).contactsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.conversationId == item.conversationId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationsTable,
      Conversation,
      $$ConversationsTableFilterComposer,
      $$ConversationsTableOrderingComposer,
      $$ConversationsTableAnnotationComposer,
      $$ConversationsTableCreateCompanionBuilder,
      $$ConversationsTableUpdateCompanionBuilder,
      (Conversation, $$ConversationsTableReferences),
      Conversation,
      PrefetchHooks Function({bool messagesRefs, bool contactsRefs})
    >;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String messageId,
  required String logicalMessageId,
  required String conversationId,
  required String senderId,
  required int senderSequence,
  required int messageOrder,
  required int chainIndex,
  required int timestamp,
  required Uint8List ciphertext,
  required Uint8List nonce,
  required int messageType,
  required int status,
  required Uint8List mac,
  Value<String?> replyTo,
  Value<int> edited,
  Value<int> protocolVersion,
  Value<int?> receivedAt,
  Value<int?> readAt,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> messageId,
  Value<String> logicalMessageId,
  Value<String> conversationId,
  Value<String> senderId,
  Value<int> senderSequence,
  Value<int> messageOrder,
  Value<int> chainIndex,
  Value<int> timestamp,
  Value<Uint8List> ciphertext,
  Value<Uint8List> nonce,
  Value<int> messageType,
  Value<int> status,
  Value<Uint8List> mac,
  Value<String?> replyTo,
  Value<int> edited,
  Value<int> protocolVersion,
  Value<int?> receivedAt,
  Value<int?> readAt,
  Value<int> rowid,
});

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConversationsTable _conversationIdTable(_$AppDatabase db) => db
      .conversations
      .createAlias('messages__conversation_id__conversations__conversation_id');

  $$ConversationsTableProcessedTableManager get conversationId {
    final $_column = $_itemColumn<String>('conversation_id')!;

    final manager = $$ConversationsTableTableManager(
      $_db,
      $_db.conversations,
    ).filter((f) => f.conversationId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logicalMessageId => $composableBuilder(
    column: $table.logicalMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get senderSequence => $composableBuilder(
    column: $table.senderSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get messageOrder => $composableBuilder(
    column: $table.messageOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chainIndex => $composableBuilder(
    column: $table.chainIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get ciphertext => $composableBuilder(
    column: $table.ciphertext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get nonce => $composableBuilder(
    column: $table.nonce,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get mac => $composableBuilder(
    column: $table.mac,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyTo => $composableBuilder(
    column: $table.replyTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get edited => $composableBuilder(
    column: $table.edited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logicalMessageId => $composableBuilder(
    column: $table.logicalMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get senderSequence => $composableBuilder(
    column: $table.senderSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get messageOrder => $composableBuilder(
    column: $table.messageOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chainIndex => $composableBuilder(
    column: $table.chainIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get ciphertext => $composableBuilder(
    column: $table.ciphertext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get nonce => $composableBuilder(
    column: $table.nonce,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get mac => $composableBuilder(
    column: $table.mac,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyTo => $composableBuilder(
    column: $table.replyTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get edited => $composableBuilder(
    column: $table.edited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableOrderingComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get logicalMessageId => $composableBuilder(
    column: $table.logicalMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<int> get senderSequence => $composableBuilder(
    column: $table.senderSequence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get messageOrder => $composableBuilder(
    column: $table.messageOrder,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chainIndex => $composableBuilder(
    column: $table.chainIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<Uint8List> get ciphertext => $composableBuilder(
    column: $table.ciphertext,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get nonce =>
      $composableBuilder(column: $table.nonce, builder: (column) => column);

  GeneratedColumn<int> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<Uint8List> get mac =>
      $composableBuilder(column: $table.mac, builder: (column) => column);

  GeneratedColumn<String> get replyTo =>
      $composableBuilder(column: $table.replyTo, builder: (column) => column);

  GeneratedColumn<int> get edited =>
      $composableBuilder(column: $table.edited, builder: (column) => column);

  GeneratedColumn<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  $$ConversationsTableAnnotationComposer get conversationId {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, $$MessagesTableReferences),
          Message,
          PrefetchHooks Function({bool conversationId})
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> messageId = const Value.absent(),
                Value<String> logicalMessageId = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<int> senderSequence = const Value.absent(),
                Value<int> messageOrder = const Value.absent(),
                Value<int> chainIndex = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<Uint8List> ciphertext = const Value.absent(),
                Value<Uint8List> nonce = const Value.absent(),
                Value<int> messageType = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<Uint8List> mac = const Value.absent(),
                Value<String?> replyTo = const Value.absent(),
                Value<int> edited = const Value.absent(),
                Value<int> protocolVersion = const Value.absent(),
                Value<int?> receivedAt = const Value.absent(),
                Value<int?> readAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                messageId: messageId,
                logicalMessageId: logicalMessageId,
                conversationId: conversationId,
                senderId: senderId,
                senderSequence: senderSequence,
                messageOrder: messageOrder,
                chainIndex: chainIndex,
                timestamp: timestamp,
                ciphertext: ciphertext,
                nonce: nonce,
                messageType: messageType,
                status: status,
                mac: mac,
                replyTo: replyTo,
                edited: edited,
                protocolVersion: protocolVersion,
                receivedAt: receivedAt,
                readAt: readAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String messageId,
                required String logicalMessageId,
                required String conversationId,
                required String senderId,
                required int senderSequence,
                required int messageOrder,
                required int chainIndex,
                required int timestamp,
                required Uint8List ciphertext,
                required Uint8List nonce,
                required int messageType,
                required int status,
                required Uint8List mac,
                Value<String?> replyTo = const Value.absent(),
                Value<int> edited = const Value.absent(),
                Value<int> protocolVersion = const Value.absent(),
                Value<int?> receivedAt = const Value.absent(),
                Value<int?> readAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                messageId: messageId,
                logicalMessageId: logicalMessageId,
                conversationId: conversationId,
                senderId: senderId,
                senderSequence: senderSequence,
                messageOrder: messageOrder,
                chainIndex: chainIndex,
                timestamp: timestamp,
                ciphertext: ciphertext,
                nonce: nonce,
                messageType: messageType,
                status: status,
                mac: mac,
                replyTo: replyTo,
                edited: edited,
                protocolVersion: protocolVersion,
                receivedAt: receivedAt,
                readAt: readAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (conversationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.conversationId,
                        referencedTable: $$MessagesTableReferences
                            ._conversationIdTable(db),
                        referencedColumn: $$MessagesTableReferences
                            ._conversationIdTable(db)
                            .conversationId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, $$MessagesTableReferences),
      Message,
      PrefetchHooks Function({bool conversationId})
    >;
typedef $$ContactsTableCreateCompanionBuilder = ContactsCompanion Function({
  required String contactId,
  Value<String?> nickname,
  Value<String?> avatar,
  Value<String?> bio,
  Value<int> muted,
  Value<int> pinned,
  Value<int> isOnline,
  Value<int?> lastSeen,
  required int connectionStatus,
  required String serverId,
  required int createdAt,
  required int updatedAt,
  Value<int> ignorePing,
  Value<String?> conversationId,
  Value<int> rowid,
});
typedef $$ContactsTableUpdateCompanionBuilder = ContactsCompanion Function({
  Value<String> contactId,
  Value<String?> nickname,
  Value<String?> avatar,
  Value<String?> bio,
  Value<int> muted,
  Value<int> pinned,
  Value<int> isOnline,
  Value<int?> lastSeen,
  Value<int> connectionStatus,
  Value<String> serverId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> ignorePing,
  Value<String?> conversationId,
  Value<int> rowid,
});

final class $$ContactsTableReferences
    extends BaseReferences<_$AppDatabase, $ContactsTable, Contact> {
  $$ContactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConversationsTable _conversationIdTable(_$AppDatabase db) => db
      .conversations
      .createAlias('contacts__conversation_id__conversations__conversation_id');

  $$ConversationsTableProcessedTableManager? get conversationId {
    final $_column = $_itemColumn<String>('conversation_id');
    if ($_column == null) return null;
    final manager = $$ConversationsTableTableManager(
      $_db,
      $_db.conversations,
    ).filter((f) => f.conversationId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ContactNetworkMembersTable,
    List<ContactNetworkMember>
  >
  _contactNetworkMembersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.contactNetworkMembers,
        aliasName: 'contacts__contact_id__contact_network_members__contact_id',
      );

  $$ContactNetworkMembersTableProcessedTableManager
  get contactNetworkMembersRefs {
    final manager =
        $$ContactNetworkMembersTableTableManager(
          $_db,
          $_db.contactNetworkMembers,
        ).filter(
          (f) => f.contactId.contactId.sqlEquals(
            $_itemColumn<String>('contact_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _contactNetworkMembersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
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

  ColumnFilters<int> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get connectionStatus => $composableBuilder(
    column: $table.connectionStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ignorePing => $composableBuilder(
    column: $table.ignorePing,
    builder: (column) => ColumnFilters(column),
  );

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> contactNetworkMembersRefs(
    Expression<bool> Function($$ContactNetworkMembersTableFilterComposer f) f,
  ) {
    final $$ContactNetworkMembersTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.contactId,
          referencedTable: $db.contactNetworkMembers,
          getReferencedColumn: (t) => t.contactId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ContactNetworkMembersTableFilterComposer(
                $db: $db,
                $table: $db.contactNetworkMembers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
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

  ColumnOrderings<int> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get connectionStatus => $composableBuilder(
    column: $table.connectionStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ignorePing => $composableBuilder(
    column: $table.ignorePing,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableOrderingComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<int> get muted =>
      $composableBuilder(column: $table.muted, builder: (column) => column);

  GeneratedColumn<int> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<int> get isOnline =>
      $composableBuilder(column: $table.isOnline, builder: (column) => column);

  GeneratedColumn<int> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  GeneratedColumn<int> get connectionStatus => $composableBuilder(
    column: $table.connectionStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get ignorePing => $composableBuilder(
    column: $table.ignorePing,
    builder: (column) => column,
  );

  $$ConversationsTableAnnotationComposer get conversationId {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> contactNetworkMembersRefs<T extends Object>(
    Expression<T> Function($$ContactNetworkMembersTableAnnotationComposer a) f,
  ) {
    final $$ContactNetworkMembersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.contactId,
          referencedTable: $db.contactNetworkMembers,
          getReferencedColumn: (t) => t.contactId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ContactNetworkMembersTableAnnotationComposer(
                $db: $db,
                $table: $db.contactNetworkMembers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactsTable,
          Contact,
          $$ContactsTableFilterComposer,
          $$ContactsTableOrderingComposer,
          $$ContactsTableAnnotationComposer,
          $$ContactsTableCreateCompanionBuilder,
          $$ContactsTableUpdateCompanionBuilder,
          (Contact, $$ContactsTableReferences),
          Contact,
          PrefetchHooks Function({
            bool conversationId,
            bool contactNetworkMembersRefs,
          })
        > {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> contactId = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<int> muted = const Value.absent(),
                Value<int> pinned = const Value.absent(),
                Value<int> isOnline = const Value.absent(),
                Value<int?> lastSeen = const Value.absent(),
                Value<int> connectionStatus = const Value.absent(),
                Value<String> serverId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> ignorePing = const Value.absent(),
                Value<String?> conversationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion(
                contactId: contactId,
                nickname: nickname,
                avatar: avatar,
                bio: bio,
                muted: muted,
                pinned: pinned,
                isOnline: isOnline,
                lastSeen: lastSeen,
                connectionStatus: connectionStatus,
                serverId: serverId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                ignorePing: ignorePing,
                conversationId: conversationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String contactId,
                Value<String?> nickname = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<int> muted = const Value.absent(),
                Value<int> pinned = const Value.absent(),
                Value<int> isOnline = const Value.absent(),
                Value<int?> lastSeen = const Value.absent(),
                required int connectionStatus,
                required String serverId,
                required int createdAt,
                required int updatedAt,
                Value<int> ignorePing = const Value.absent(),
                Value<String?> conversationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion.insert(
                contactId: contactId,
                nickname: nickname,
                avatar: avatar,
                bio: bio,
                muted: muted,
                pinned: pinned,
                isOnline: isOnline,
                lastSeen: lastSeen,
                connectionStatus: connectionStatus,
                serverId: serverId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                ignorePing: ignorePing,
                conversationId: conversationId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContactsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({conversationId = false, contactNetworkMembersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (contactNetworkMembersRefs) db.contactNetworkMembers,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (conversationId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.conversationId,
                            referencedTable: $$ContactsTableReferences
                                ._conversationIdTable(db),
                            referencedColumn: $$ContactsTableReferences
                                ._conversationIdTable(db)
                                .conversationId,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (contactNetworkMembersRefs)
                        await $_getPrefetchedData<
                          Contact,
                          $ContactsTable,
                          ContactNetworkMember
                        >(
                          currentTable: table,
                          referencedTable: $$ContactsTableReferences
                              ._contactNetworkMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContactsTableReferences(
                                db,
                                table,
                                p0,
                              ).contactNetworkMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contactId == item.contactId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactsTable,
      Contact,
      $$ContactsTableFilterComposer,
      $$ContactsTableOrderingComposer,
      $$ContactsTableAnnotationComposer,
      $$ContactsTableCreateCompanionBuilder,
      $$ContactsTableUpdateCompanionBuilder,
      (Contact, $$ContactsTableReferences),
      Contact,
      PrefetchHooks Function({
        bool conversationId,
        bool contactNetworkMembersRefs,
      })
    >;
typedef $$ContactsNetworkTableCreateCompanionBuilder =
    ContactsNetworkCompanion Function({
      required String networkId,
      required String networkName,
      required int createdAt,
      required int updatedAt,
      required String serverId,
      Value<int> rowid,
    });
typedef $$ContactsNetworkTableUpdateCompanionBuilder =
    ContactsNetworkCompanion Function({
      Value<String> networkId,
      Value<String> networkName,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> serverId,
      Value<int> rowid,
    });

final class $$ContactsNetworkTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ContactsNetworkTable,
          ContactsNetworkData
        > {
  $$ContactsNetworkTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ContactNetworkMembersTable,
    List<ContactNetworkMember>
  >
  _contactNetworkMembersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.contactNetworkMembers,
        aliasName:
            'contacts_network__network_id__contact_network_members__network_id',
      );

  $$ContactNetworkMembersTableProcessedTableManager
  get contactNetworkMembersRefs {
    final manager =
        $$ContactNetworkMembersTableTableManager(
          $_db,
          $_db.contactNetworkMembers,
        ).filter(
          (f) => f.networkId.networkId.sqlEquals(
            $_itemColumn<String>('network_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _contactNetworkMembersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContactsNetworkTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsNetworkTable> {
  $$ContactsNetworkTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get networkId => $composableBuilder(
    column: $table.networkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get networkName => $composableBuilder(
    column: $table.networkName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> contactNetworkMembersRefs(
    Expression<bool> Function($$ContactNetworkMembersTableFilterComposer f) f,
  ) {
    final $$ContactNetworkMembersTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.networkId,
          referencedTable: $db.contactNetworkMembers,
          getReferencedColumn: (t) => t.networkId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ContactNetworkMembersTableFilterComposer(
                $db: $db,
                $table: $db.contactNetworkMembers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ContactsNetworkTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsNetworkTable> {
  $$ContactsNetworkTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get networkId => $composableBuilder(
    column: $table.networkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get networkName => $composableBuilder(
    column: $table.networkName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactsNetworkTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsNetworkTable> {
  $$ContactsNetworkTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get networkId =>
      $composableBuilder(column: $table.networkId, builder: (column) => column);

  GeneratedColumn<String> get networkName => $composableBuilder(
    column: $table.networkName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  Expression<T> contactNetworkMembersRefs<T extends Object>(
    Expression<T> Function($$ContactNetworkMembersTableAnnotationComposer a) f,
  ) {
    final $$ContactNetworkMembersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.networkId,
          referencedTable: $db.contactNetworkMembers,
          getReferencedColumn: (t) => t.networkId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ContactNetworkMembersTableAnnotationComposer(
                $db: $db,
                $table: $db.contactNetworkMembers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ContactsNetworkTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactsNetworkTable,
          ContactsNetworkData,
          $$ContactsNetworkTableFilterComposer,
          $$ContactsNetworkTableOrderingComposer,
          $$ContactsNetworkTableAnnotationComposer,
          $$ContactsNetworkTableCreateCompanionBuilder,
          $$ContactsNetworkTableUpdateCompanionBuilder,
          (ContactsNetworkData, $$ContactsNetworkTableReferences),
          ContactsNetworkData,
          PrefetchHooks Function({bool contactNetworkMembersRefs})
        > {
  $$ContactsNetworkTableTableManager(
    _$AppDatabase db,
    $ContactsNetworkTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsNetworkTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsNetworkTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsNetworkTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> networkId = const Value.absent(),
                Value<String> networkName = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> serverId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactsNetworkCompanion(
                networkId: networkId,
                networkName: networkName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverId: serverId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String networkId,
                required String networkName,
                required int createdAt,
                required int updatedAt,
                required String serverId,
                Value<int> rowid = const Value.absent(),
              }) => ContactsNetworkCompanion.insert(
                networkId: networkId,
                networkName: networkName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverId: serverId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContactsNetworkTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contactNetworkMembersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (contactNetworkMembersRefs) db.contactNetworkMembers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (contactNetworkMembersRefs)
                    await $_getPrefetchedData<
                      ContactsNetworkData,
                      $ContactsNetworkTable,
                      ContactNetworkMember
                    >(
                      currentTable: table,
                      referencedTable: $$ContactsNetworkTableReferences
                          ._contactNetworkMembersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ContactsNetworkTableReferences(
                            db,
                            table,
                            p0,
                          ).contactNetworkMembersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.networkId == item.networkId,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ContactsNetworkTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactsNetworkTable,
      ContactsNetworkData,
      $$ContactsNetworkTableFilterComposer,
      $$ContactsNetworkTableOrderingComposer,
      $$ContactsNetworkTableAnnotationComposer,
      $$ContactsNetworkTableCreateCompanionBuilder,
      $$ContactsNetworkTableUpdateCompanionBuilder,
      (ContactsNetworkData, $$ContactsNetworkTableReferences),
      ContactsNetworkData,
      PrefetchHooks Function({bool contactNetworkMembersRefs})
    >;
typedef $$ContactNetworkMembersTableCreateCompanionBuilder =
    ContactNetworkMembersCompanion Function({
      required String networkId,
      required String contactId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$ContactNetworkMembersTableUpdateCompanionBuilder =
    ContactNetworkMembersCompanion Function({
      Value<String> networkId,
      Value<String> contactId,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$ContactNetworkMembersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ContactNetworkMembersTable,
          ContactNetworkMember
        > {
  $$ContactNetworkMembersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ContactsNetworkTable _networkIdTable(_$AppDatabase db) =>
      db.contactsNetwork.createAlias(
        'contact_network_members__network_id__contacts_network__network_id',
      );

  $$ContactsNetworkTableProcessedTableManager get networkId {
    final $_column = $_itemColumn<String>('network_id')!;

    final manager = $$ContactsNetworkTableTableManager(
      $_db,
      $_db.contactsNetwork,
    ).filter((f) => f.networkId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_networkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ContactsTable _contactIdTable(_$AppDatabase db) => db.contacts
      .createAlias('contact_network_members__contact_id__contacts__contact_id');

  $$ContactsTableProcessedTableManager get contactId {
    final $_column = $_itemColumn<String>('contact_id')!;

    final manager = $$ContactsTableTableManager(
      $_db,
      $_db.contacts,
    ).filter((f) => f.contactId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ContactNetworkMembersTableFilterComposer
    extends Composer<_$AppDatabase, $ContactNetworkMembersTable> {
  $$ContactNetworkMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ContactsNetworkTableFilterComposer get networkId {
    final $$ContactsNetworkTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.networkId,
      referencedTable: $db.contactsNetwork,
      getReferencedColumn: (t) => t.networkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsNetworkTableFilterComposer(
            $db: $db,
            $table: $db.contactsNetwork,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableFilterComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactNetworkMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactNetworkMembersTable> {
  $$ContactNetworkMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContactsNetworkTableOrderingComposer get networkId {
    final $$ContactsNetworkTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.networkId,
      referencedTable: $db.contactsNetwork,
      getReferencedColumn: (t) => t.networkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsNetworkTableOrderingComposer(
            $db: $db,
            $table: $db.contactsNetwork,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableOrderingComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactNetworkMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactNetworkMembersTable> {
  $$ContactNetworkMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ContactsNetworkTableAnnotationComposer get networkId {
    final $$ContactsNetworkTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.networkId,
      referencedTable: $db.contactsNetwork,
      getReferencedColumn: (t) => t.networkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsNetworkTableAnnotationComposer(
            $db: $db,
            $table: $db.contactsNetwork,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContactsTableAnnotationComposer get contactId {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactNetworkMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactNetworkMembersTable,
          ContactNetworkMember,
          $$ContactNetworkMembersTableFilterComposer,
          $$ContactNetworkMembersTableOrderingComposer,
          $$ContactNetworkMembersTableAnnotationComposer,
          $$ContactNetworkMembersTableCreateCompanionBuilder,
          $$ContactNetworkMembersTableUpdateCompanionBuilder,
          (ContactNetworkMember, $$ContactNetworkMembersTableReferences),
          ContactNetworkMember,
          PrefetchHooks Function({bool networkId, bool contactId})
        > {
  $$ContactNetworkMembersTableTableManager(
    _$AppDatabase db,
    $ContactNetworkMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactNetworkMembersTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ContactNetworkMembersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ContactNetworkMembersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> networkId = const Value.absent(),
                Value<String> contactId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactNetworkMembersCompanion(
                networkId: networkId,
                contactId: contactId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String networkId,
                required String contactId,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ContactNetworkMembersCompanion.insert(
                networkId: networkId,
                contactId: contactId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContactNetworkMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({networkId = false, contactId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (networkId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.networkId,
                        referencedTable: $$ContactNetworkMembersTableReferences
                            ._networkIdTable(db),
                        referencedColumn: $$ContactNetworkMembersTableReferences
                            ._networkIdTable(db)
                            .networkId,
                      ) as T;
                    }
                    if (contactId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.contactId,
                        referencedTable: $$ContactNetworkMembersTableReferences
                            ._contactIdTable(db),
                        referencedColumn: $$ContactNetworkMembersTableReferences
                            ._contactIdTable(db)
                            .contactId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ContactNetworkMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactNetworkMembersTable,
      ContactNetworkMember,
      $$ContactNetworkMembersTableFilterComposer,
      $$ContactNetworkMembersTableOrderingComposer,
      $$ContactNetworkMembersTableAnnotationComposer,
      $$ContactNetworkMembersTableCreateCompanionBuilder,
      $$ContactNetworkMembersTableUpdateCompanionBuilder,
      (ContactNetworkMember, $$ContactNetworkMembersTableReferences),
      ContactNetworkMember,
      PrefetchHooks Function({bool networkId, bool contactId})
    >;
typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  required String groupId,
  Value<String?> ownerId,
  required String groupName,
  required int groupType,
  Value<String?> avatar,
  Value<String?> privateKey,
  Value<String?> groupDesc,
  required int createdAt,
  required int updatedAt,
  Value<int> isOwner,
  Value<int> rowid,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<String> groupId,
  Value<String?> ownerId,
  Value<String> groupName,
  Value<int> groupType,
  Value<String?> avatar,
  Value<String?> privateKey,
  Value<String?> groupDesc,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> isOwner,
  Value<int> rowid,
});

final class $$GroupsTableReferences
    extends BaseReferences<_$AppDatabase, $GroupsTable, Group> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
  _groupMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupMembers,
    aliasName: 'groups__group_id__group_members__group_id',
  );

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager($_db, $_db.groupMembers)
        .filter(
          (f) => f.groupId.groupId.sqlEquals($_itemColumn<String>('group_id')!),
        );

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConnectionRequestsTable, List<ConnectionRequest>>
  _connectionRequestsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.connectionRequests,
        aliasName: 'groups__group_id__connection_requests__group_id',
      );

  $$ConnectionRequestsTableProcessedTableManager get connectionRequestsRefs {
    final manager =
        $$ConnectionRequestsTableTableManager(
          $_db,
          $_db.connectionRequests,
        ).filter(
          (f) => f.groupId.groupId.sqlEquals($_itemColumn<String>('group_id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _connectionRequestsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get groupType => $composableBuilder(
    column: $table.groupType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privateKey => $composableBuilder(
    column: $table.privateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupDesc => $composableBuilder(
    column: $table.groupDesc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isOwner => $composableBuilder(
    column: $table.isOwner,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> groupMembersRefs(
    Expression<bool> Function($$GroupMembersTableFilterComposer f) f,
  ) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableFilterComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> connectionRequestsRefs(
    Expression<bool> Function($$ConnectionRequestsTableFilterComposer f) f,
  ) {
    final $$ConnectionRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.connectionRequests,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionRequestsTableFilterComposer(
            $db: $db,
            $table: $db.connectionRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get groupType => $composableBuilder(
    column: $table.groupType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privateKey => $composableBuilder(
    column: $table.privateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupDesc => $composableBuilder(
    column: $table.groupDesc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isOwner => $composableBuilder(
    column: $table.isOwner,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<int> get groupType =>
      $composableBuilder(column: $table.groupType, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get privateKey => $composableBuilder(
    column: $table.privateKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get groupDesc =>
      $composableBuilder(column: $table.groupDesc, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get isOwner =>
      $composableBuilder(column: $table.isOwner, builder: (column) => column);

  Expression<T> groupMembersRefs<T extends Object>(
    Expression<T> Function($$GroupMembersTableAnnotationComposer a) f,
  ) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> connectionRequestsRefs<T extends Object>(
    Expression<T> Function($$ConnectionRequestsTableAnnotationComposer a) f,
  ) {
    final $$ConnectionRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.groupId,
          referencedTable: $db.connectionRequests,
          getReferencedColumn: (t) => t.groupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ConnectionRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.connectionRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupsTable,
          Group,
          $$GroupsTableFilterComposer,
          $$GroupsTableOrderingComposer,
          $$GroupsTableAnnotationComposer,
          $$GroupsTableCreateCompanionBuilder,
          $$GroupsTableUpdateCompanionBuilder,
          (Group, $$GroupsTableReferences),
          Group,
          PrefetchHooks Function({
            bool groupMembersRefs,
            bool connectionRequestsRefs,
          })
        > {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> groupId = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String> groupName = const Value.absent(),
                Value<int> groupType = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String?> privateKey = const Value.absent(),
                Value<String?> groupDesc = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> isOwner = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion(
                groupId: groupId,
                ownerId: ownerId,
                groupName: groupName,
                groupType: groupType,
                avatar: avatar,
                privateKey: privateKey,
                groupDesc: groupDesc,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isOwner: isOwner,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String groupId,
                Value<String?> ownerId = const Value.absent(),
                required String groupName,
                required int groupType,
                Value<String?> avatar = const Value.absent(),
                Value<String?> privateKey = const Value.absent(),
                Value<String?> groupDesc = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> isOwner = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion.insert(
                groupId: groupId,
                ownerId: ownerId,
                groupName: groupName,
                groupType: groupType,
                avatar: avatar,
                privateKey: privateKey,
                groupDesc: groupDesc,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isOwner: isOwner,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GroupsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({groupMembersRefs = false, connectionRequestsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (groupMembersRefs) db.groupMembers,
                    if (connectionRequestsRefs) db.connectionRequests,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (groupMembersRefs)
                        await $_getPrefetchedData<
                          Group,
                          $GroupsTable,
                          GroupMember
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._groupMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).groupMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.groupId,
                              ),
                          typedResults: items,
                        ),
                      if (connectionRequestsRefs)
                        await $_getPrefetchedData<
                          Group,
                          $GroupsTable,
                          ConnectionRequest
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._connectionRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).connectionRequestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.groupId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupsTable,
      Group,
      $$GroupsTableFilterComposer,
      $$GroupsTableOrderingComposer,
      $$GroupsTableAnnotationComposer,
      $$GroupsTableCreateCompanionBuilder,
      $$GroupsTableUpdateCompanionBuilder,
      (Group, $$GroupsTableReferences),
      Group,
      PrefetchHooks Function({
        bool groupMembersRefs,
        bool connectionRequestsRefs,
      })
    >;
typedef $$GroupMembersTableCreateCompanionBuilder =
    GroupMembersCompanion Function({
      required String groupId,
      required String identityId,
      Value<String?> publicKey,
      Value<String?> bio,
      Value<String?> avatar,
      Value<String?> name,
      Value<int?> joinedAt,
      Value<int> rowid,
    });
typedef $$GroupMembersTableUpdateCompanionBuilder =
    GroupMembersCompanion Function({
      Value<String> groupId,
      Value<String> identityId,
      Value<String?> publicKey,
      Value<String?> bio,
      Value<String?> avatar,
      Value<String?> name,
      Value<int?> joinedAt,
      Value<int> rowid,
    });

final class $$GroupMembersTableReferences
    extends BaseReferences<_$AppDatabase, $GroupMembersTable, GroupMember> {
  $$GroupMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$AppDatabase db) =>
      db.groups.createAlias('group_members__group_id__groups__group_id');

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.groupId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $IdentityTable _identityIdTable(_$AppDatabase db) => db.identity
      .createAlias('group_members__identity_id__identity__identity_id');

  $$IdentityTableProcessedTableManager get identityId {
    final $_column = $_itemColumn<String>('identity_id')!;

    final manager = $$IdentityTableTableManager(
      $_db,
      $_db.identity,
    ).filter((f) => f.identityId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_identityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroupMembersTableFilterComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IdentityTableFilterComposer get identityId {
    final $$IdentityTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.identity,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityTableFilterComposer(
            $db: $db,
            $table: $db.identity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IdentityTableOrderingComposer get identityId {
    final $$IdentityTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.identity,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityTableOrderingComposer(
            $db: $db,
            $table: $db.identity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IdentityTableAnnotationComposer get identityId {
    final $$IdentityTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.identity,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityTableAnnotationComposer(
            $db: $db,
            $table: $db.identity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupMembersTable,
          GroupMember,
          $$GroupMembersTableFilterComposer,
          $$GroupMembersTableOrderingComposer,
          $$GroupMembersTableAnnotationComposer,
          $$GroupMembersTableCreateCompanionBuilder,
          $$GroupMembersTableUpdateCompanionBuilder,
          (GroupMember, $$GroupMembersTableReferences),
          GroupMember,
          PrefetchHooks Function({bool groupId, bool identityId})
        > {
  $$GroupMembersTableTableManager(_$AppDatabase db, $GroupMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> groupId = const Value.absent(),
                Value<String> identityId = const Value.absent(),
                Value<String?> publicKey = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int?> joinedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupMembersCompanion(
                groupId: groupId,
                identityId: identityId,
                publicKey: publicKey,
                bio: bio,
                avatar: avatar,
                name: name,
                joinedAt: joinedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String groupId,
                required String identityId,
                Value<String?> publicKey = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int?> joinedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupMembersCompanion.insert(
                groupId: groupId,
                identityId: identityId,
                publicKey: publicKey,
                bio: bio,
                avatar: avatar,
                name: name,
                joinedAt: joinedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GroupMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false, identityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (groupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.groupId,
                        referencedTable: $$GroupMembersTableReferences
                            ._groupIdTable(db),
                        referencedColumn: $$GroupMembersTableReferences
                            ._groupIdTable(db)
                            .groupId,
                      ) as T;
                    }
                    if (identityId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.identityId,
                        referencedTable: $$GroupMembersTableReferences
                            ._identityIdTable(db),
                        referencedColumn: $$GroupMembersTableReferences
                            ._identityIdTable(db)
                            .identityId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GroupMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupMembersTable,
      GroupMember,
      $$GroupMembersTableFilterComposer,
      $$GroupMembersTableOrderingComposer,
      $$GroupMembersTableAnnotationComposer,
      $$GroupMembersTableCreateCompanionBuilder,
      $$GroupMembersTableUpdateCompanionBuilder,
      (GroupMember, $$GroupMembersTableReferences),
      GroupMember,
      PrefetchHooks Function({bool groupId, bool identityId})
    >;
typedef $$ConnectionRequestsTableCreateCompanionBuilder =
    ConnectionRequestsCompanion Function({
      required String requestId,
      required String requesterId,
      required String recipientId,
      required String groupId,
      required String introduction,
      required int status,
      required int createdAt,
      Value<int?> acceptedAt,
      Value<int?> rejectedAt,
      Value<int?> expiresAt,
      Value<int> rowid,
    });
typedef $$ConnectionRequestsTableUpdateCompanionBuilder =
    ConnectionRequestsCompanion Function({
      Value<String> requestId,
      Value<String> requesterId,
      Value<String> recipientId,
      Value<String> groupId,
      Value<String> introduction,
      Value<int> status,
      Value<int> createdAt,
      Value<int?> acceptedAt,
      Value<int?> rejectedAt,
      Value<int?> expiresAt,
      Value<int> rowid,
    });

final class $$ConnectionRequestsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ConnectionRequestsTable,
          ConnectionRequest
        > {
  $$ConnectionRequestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IdentityTable _requesterIdTable(_$AppDatabase db) => db.identity
      .createAlias('connection_requests__requester_id__identity__identity_id');

  $$IdentityTableProcessedTableManager get requesterId {
    final $_column = $_itemColumn<String>('requester_id')!;

    final manager = $$IdentityTableTableManager(
      $_db,
      $_db.identity,
    ).filter((f) => f.identityId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_requesterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $IdentityTable _recipientIdTable(_$AppDatabase db) => db.identity
      .createAlias('connection_requests__recipient_id__identity__identity_id');

  $$IdentityTableProcessedTableManager get recipientId {
    final $_column = $_itemColumn<String>('recipient_id')!;

    final manager = $$IdentityTableTableManager(
      $_db,
      $_db.identity,
    ).filter((f) => f.identityId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GroupsTable _groupIdTable(_$AppDatabase db) =>
      db.groups.createAlias('connection_requests__group_id__groups__group_id');

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.groupId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConnectionRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $ConnectionRequestsTable> {
  $$ConnectionRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get introduction => $composableBuilder(
    column: $table.introduction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rejectedAt => $composableBuilder(
    column: $table.rejectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  $$IdentityTableFilterComposer get requesterId {
    final $$IdentityTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.requesterId,
      referencedTable: $db.identity,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityTableFilterComposer(
            $db: $db,
            $table: $db.identity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IdentityTableFilterComposer get recipientId {
    final $$IdentityTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipientId,
      referencedTable: $db.identity,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityTableFilterComposer(
            $db: $db,
            $table: $db.identity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConnectionRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConnectionRequestsTable> {
  $$ConnectionRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get introduction => $composableBuilder(
    column: $table.introduction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rejectedAt => $composableBuilder(
    column: $table.rejectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$IdentityTableOrderingComposer get requesterId {
    final $$IdentityTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.requesterId,
      referencedTable: $db.identity,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityTableOrderingComposer(
            $db: $db,
            $table: $db.identity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IdentityTableOrderingComposer get recipientId {
    final $$IdentityTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipientId,
      referencedTable: $db.identity,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityTableOrderingComposer(
            $db: $db,
            $table: $db.identity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConnectionRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConnectionRequestsTable> {
  $$ConnectionRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get introduction => $composableBuilder(
    column: $table.introduction,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rejectedAt => $composableBuilder(
    column: $table.rejectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  $$IdentityTableAnnotationComposer get requesterId {
    final $$IdentityTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.requesterId,
      referencedTable: $db.identity,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityTableAnnotationComposer(
            $db: $db,
            $table: $db.identity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IdentityTableAnnotationComposer get recipientId {
    final $$IdentityTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipientId,
      referencedTable: $db.identity,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityTableAnnotationComposer(
            $db: $db,
            $table: $db.identity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConnectionRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConnectionRequestsTable,
          ConnectionRequest,
          $$ConnectionRequestsTableFilterComposer,
          $$ConnectionRequestsTableOrderingComposer,
          $$ConnectionRequestsTableAnnotationComposer,
          $$ConnectionRequestsTableCreateCompanionBuilder,
          $$ConnectionRequestsTableUpdateCompanionBuilder,
          (ConnectionRequest, $$ConnectionRequestsTableReferences),
          ConnectionRequest,
          PrefetchHooks Function({
            bool requesterId,
            bool recipientId,
            bool groupId,
          })
        > {
  $$ConnectionRequestsTableTableManager(
    _$AppDatabase db,
    $ConnectionRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConnectionRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConnectionRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConnectionRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> requestId = const Value.absent(),
                Value<String> requesterId = const Value.absent(),
                Value<String> recipientId = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> introduction = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> acceptedAt = const Value.absent(),
                Value<int?> rejectedAt = const Value.absent(),
                Value<int?> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConnectionRequestsCompanion(
                requestId: requestId,
                requesterId: requesterId,
                recipientId: recipientId,
                groupId: groupId,
                introduction: introduction,
                status: status,
                createdAt: createdAt,
                acceptedAt: acceptedAt,
                rejectedAt: rejectedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String requestId,
                required String requesterId,
                required String recipientId,
                required String groupId,
                required String introduction,
                required int status,
                required int createdAt,
                Value<int?> acceptedAt = const Value.absent(),
                Value<int?> rejectedAt = const Value.absent(),
                Value<int?> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConnectionRequestsCompanion.insert(
                requestId: requestId,
                requesterId: requesterId,
                recipientId: recipientId,
                groupId: groupId,
                introduction: introduction,
                status: status,
                createdAt: createdAt,
                acceptedAt: acceptedAt,
                rejectedAt: rejectedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConnectionRequestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({requesterId = false, recipientId = false, groupId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (requesterId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.requesterId,
                            referencedTable: $$ConnectionRequestsTableReferences
                                ._requesterIdTable(db),
                            referencedColumn:
                                $$ConnectionRequestsTableReferences
                                    ._requesterIdTable(db)
                                    .identityId,
                          ) as T;
                        }
                        if (recipientId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.recipientId,
                            referencedTable: $$ConnectionRequestsTableReferences
                                ._recipientIdTable(db),
                            referencedColumn:
                                $$ConnectionRequestsTableReferences
                                    ._recipientIdTable(db)
                                    .identityId,
                          ) as T;
                        }
                        if (groupId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable: $$ConnectionRequestsTableReferences
                                ._groupIdTable(db),
                            referencedColumn:
                                $$ConnectionRequestsTableReferences
                                    ._groupIdTable(db)
                                    .groupId,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ConnectionRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConnectionRequestsTable,
      ConnectionRequest,
      $$ConnectionRequestsTableFilterComposer,
      $$ConnectionRequestsTableOrderingComposer,
      $$ConnectionRequestsTableAnnotationComposer,
      $$ConnectionRequestsTableCreateCompanionBuilder,
      $$ConnectionRequestsTableUpdateCompanionBuilder,
      (ConnectionRequest, $$ConnectionRequestsTableReferences),
      ConnectionRequest,
      PrefetchHooks Function({bool requesterId, bool recipientId, bool groupId})
    >;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String taskId,
  required int taskType,
  required int taskStatus,
  required String taskName,
  required int createdAt,
  required int updatedAt,
  Value<int> retryCount,
  Value<String?> serverId,
  Value<String?> taskData,
  Value<String?> failure,
  Value<int?> completedAt,
  Value<int> syncedToState,
  Value<int> syncedToServer,
  Value<int> syncedToClient,
  Value<int> syncedToDb,
  Value<int> completed,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> taskId,
  Value<int> taskType,
  Value<int> taskStatus,
  Value<String> taskName,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> retryCount,
  Value<String?> serverId,
  Value<String?> taskData,
  Value<String?> failure,
  Value<int?> completedAt,
  Value<int> syncedToState,
  Value<int> syncedToServer,
  Value<int> syncedToClient,
  Value<int> syncedToDb,
  Value<int> completed,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ServersTable _serverIdTable(_$AppDatabase db) =>
      db.servers.createAlias('tasks__server_id__servers__server_id');

  $$ServersTableProcessedTableManager? get serverId {
    final $_column = $_itemColumn<String>('server_id');
    if ($_column == null) return null;
    final manager = $$ServersTableTableManager(
      $_db,
      $_db.servers,
    ).filter((f) => f.serverId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_serverIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskStatus => $composableBuilder(
    column: $table.taskStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskName => $composableBuilder(
    column: $table.taskName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskData => $composableBuilder(
    column: $table.taskData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failure => $composableBuilder(
    column: $table.failure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedToState => $composableBuilder(
    column: $table.syncedToState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedToServer => $composableBuilder(
    column: $table.syncedToServer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedToClient => $composableBuilder(
    column: $table.syncedToClient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedToDb => $composableBuilder(
    column: $table.syncedToDb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  $$ServersTableFilterComposer get serverId {
    final $$ServersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serverId,
      referencedTable: $db.servers,
      getReferencedColumn: (t) => t.serverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServersTableFilterComposer(
            $db: $db,
            $table: $db.servers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskStatus => $composableBuilder(
    column: $table.taskStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskName => $composableBuilder(
    column: $table.taskName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskData => $composableBuilder(
    column: $table.taskData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failure => $composableBuilder(
    column: $table.failure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedToState => $composableBuilder(
    column: $table.syncedToState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedToServer => $composableBuilder(
    column: $table.syncedToServer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedToClient => $composableBuilder(
    column: $table.syncedToClient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedToDb => $composableBuilder(
    column: $table.syncedToDb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  $$ServersTableOrderingComposer get serverId {
    final $$ServersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serverId,
      referencedTable: $db.servers,
      getReferencedColumn: (t) => t.serverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServersTableOrderingComposer(
            $db: $db,
            $table: $db.servers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<int> get taskType =>
      $composableBuilder(column: $table.taskType, builder: (column) => column);

  GeneratedColumn<int> get taskStatus => $composableBuilder(
    column: $table.taskStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taskName =>
      $composableBuilder(column: $table.taskName, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taskData =>
      $composableBuilder(column: $table.taskData, builder: (column) => column);

  GeneratedColumn<String> get failure =>
      $composableBuilder(column: $table.failure, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncedToState => $composableBuilder(
    column: $table.syncedToState,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncedToServer => $composableBuilder(
    column: $table.syncedToServer,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncedToClient => $composableBuilder(
    column: $table.syncedToClient,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncedToDb => $composableBuilder(
    column: $table.syncedToDb,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  $$ServersTableAnnotationComposer get serverId {
    final $$ServersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serverId,
      referencedTable: $db.servers,
      getReferencedColumn: (t) => t.serverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServersTableAnnotationComposer(
            $db: $db,
            $table: $db.servers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool serverId})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> taskId = const Value.absent(),
                Value<int> taskType = const Value.absent(),
                Value<int> taskStatus = const Value.absent(),
                Value<String> taskName = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String?> taskData = const Value.absent(),
                Value<String?> failure = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> syncedToState = const Value.absent(),
                Value<int> syncedToServer = const Value.absent(),
                Value<int> syncedToClient = const Value.absent(),
                Value<int> syncedToDb = const Value.absent(),
                Value<int> completed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                taskId: taskId,
                taskType: taskType,
                taskStatus: taskStatus,
                taskName: taskName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                retryCount: retryCount,
                serverId: serverId,
                taskData: taskData,
                failure: failure,
                completedAt: completedAt,
                syncedToState: syncedToState,
                syncedToServer: syncedToServer,
                syncedToClient: syncedToClient,
                syncedToDb: syncedToDb,
                completed: completed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String taskId,
                required int taskType,
                required int taskStatus,
                required String taskName,
                required int createdAt,
                required int updatedAt,
                Value<int> retryCount = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String?> taskData = const Value.absent(),
                Value<String?> failure = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> syncedToState = const Value.absent(),
                Value<int> syncedToServer = const Value.absent(),
                Value<int> syncedToClient = const Value.absent(),
                Value<int> syncedToDb = const Value.absent(),
                Value<int> completed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                taskId: taskId,
                taskType: taskType,
                taskStatus: taskStatus,
                taskName: taskName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                retryCount: retryCount,
                serverId: serverId,
                taskData: taskData,
                failure: failure,
                completedAt: completedAt,
                syncedToState: syncedToState,
                syncedToServer: syncedToServer,
                syncedToClient: syncedToClient,
                syncedToDb: syncedToDb,
                completed: completed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TasksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({serverId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (serverId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.serverId,
                        referencedTable: $$TasksTableReferences._serverIdTable(
                          db,
                        ),
                        referencedColumn: $$TasksTableReferences
                            ._serverIdTable(db)
                            .serverId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool serverId})
    >;
typedef $$ShamirsSecretTableCreateCompanionBuilder =
    ShamirsSecretCompanion Function({
      required String identityId,
      required String secretShare,
      required int updatedAt,
      Value<Uint8List?> settingsPayload,
      required Uint8List passwordBlob,
      Value<int> rowid,
    });
typedef $$ShamirsSecretTableUpdateCompanionBuilder =
    ShamirsSecretCompanion Function({
      Value<String> identityId,
      Value<String> secretShare,
      Value<int> updatedAt,
      Value<Uint8List?> settingsPayload,
      Value<Uint8List> passwordBlob,
      Value<int> rowid,
    });

final class $$ShamirsSecretTableReferences
    extends
        BaseReferences<_$AppDatabase, $ShamirsSecretTable, ShamirsSecretData> {
  $$ShamirsSecretTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IdentityTable _identityIdTable(_$AppDatabase db) => db.identity
      .createAlias('shamirs_secret__identity_id__identity__identity_id');

  $$IdentityTableProcessedTableManager get identityId {
    final $_column = $_itemColumn<String>('identity_id')!;

    final manager = $$IdentityTableTableManager(
      $_db,
      $_db.identity,
    ).filter((f) => f.identityId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_identityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShamirsSecretTableFilterComposer
    extends Composer<_$AppDatabase, $ShamirsSecretTable> {
  $$ShamirsSecretTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get secretShare => $composableBuilder(
    column: $table.secretShare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get settingsPayload => $composableBuilder(
    column: $table.settingsPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get passwordBlob => $composableBuilder(
    column: $table.passwordBlob,
    builder: (column) => ColumnFilters(column),
  );

  $$IdentityTableFilterComposer get identityId {
    final $$IdentityTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.identity,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityTableFilterComposer(
            $db: $db,
            $table: $db.identity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShamirsSecretTableOrderingComposer
    extends Composer<_$AppDatabase, $ShamirsSecretTable> {
  $$ShamirsSecretTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get secretShare => $composableBuilder(
    column: $table.secretShare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get settingsPayload => $composableBuilder(
    column: $table.settingsPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get passwordBlob => $composableBuilder(
    column: $table.passwordBlob,
    builder: (column) => ColumnOrderings(column),
  );

  $$IdentityTableOrderingComposer get identityId {
    final $$IdentityTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.identity,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityTableOrderingComposer(
            $db: $db,
            $table: $db.identity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShamirsSecretTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShamirsSecretTable> {
  $$ShamirsSecretTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get secretShare => $composableBuilder(
    column: $table.secretShare,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<Uint8List> get settingsPayload => $composableBuilder(
    column: $table.settingsPayload,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get passwordBlob => $composableBuilder(
    column: $table.passwordBlob,
    builder: (column) => column,
  );

  $$IdentityTableAnnotationComposer get identityId {
    final $$IdentityTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.identity,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityTableAnnotationComposer(
            $db: $db,
            $table: $db.identity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShamirsSecretTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShamirsSecretTable,
          ShamirsSecretData,
          $$ShamirsSecretTableFilterComposer,
          $$ShamirsSecretTableOrderingComposer,
          $$ShamirsSecretTableAnnotationComposer,
          $$ShamirsSecretTableCreateCompanionBuilder,
          $$ShamirsSecretTableUpdateCompanionBuilder,
          (ShamirsSecretData, $$ShamirsSecretTableReferences),
          ShamirsSecretData,
          PrefetchHooks Function({bool identityId})
        > {
  $$ShamirsSecretTableTableManager(_$AppDatabase db, $ShamirsSecretTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShamirsSecretTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShamirsSecretTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShamirsSecretTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> identityId = const Value.absent(),
                Value<String> secretShare = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<Uint8List?> settingsPayload = const Value.absent(),
                Value<Uint8List> passwordBlob = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShamirsSecretCompanion(
                identityId: identityId,
                secretShare: secretShare,
                updatedAt: updatedAt,
                settingsPayload: settingsPayload,
                passwordBlob: passwordBlob,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String identityId,
                required String secretShare,
                required int updatedAt,
                Value<Uint8List?> settingsPayload = const Value.absent(),
                required Uint8List passwordBlob,
                Value<int> rowid = const Value.absent(),
              }) => ShamirsSecretCompanion.insert(
                identityId: identityId,
                secretShare: secretShare,
                updatedAt: updatedAt,
                settingsPayload: settingsPayload,
                passwordBlob: passwordBlob,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShamirsSecretTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({identityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (identityId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.identityId,
                        referencedTable: $$ShamirsSecretTableReferences
                            ._identityIdTable(db),
                        referencedColumn: $$ShamirsSecretTableReferences
                            ._identityIdTable(db)
                            .identityId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ShamirsSecretTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShamirsSecretTable,
      ShamirsSecretData,
      $$ShamirsSecretTableFilterComposer,
      $$ShamirsSecretTableOrderingComposer,
      $$ShamirsSecretTableAnnotationComposer,
      $$ShamirsSecretTableCreateCompanionBuilder,
      $$ShamirsSecretTableUpdateCompanionBuilder,
      (ShamirsSecretData, $$ShamirsSecretTableReferences),
      ShamirsSecretData,
      PrefetchHooks Function({bool identityId})
    >;
typedef $$SecretShareTableCreateCompanionBuilder =
    SecretShareCompanion Function({
      required String identityId,
      required int lastShared,
      required int passwordVersionShared,
      required int settingsVersionShared,
      Value<int> rowid,
    });
typedef $$SecretShareTableUpdateCompanionBuilder =
    SecretShareCompanion Function({
      Value<String> identityId,
      Value<int> lastShared,
      Value<int> passwordVersionShared,
      Value<int> settingsVersionShared,
      Value<int> rowid,
    });

final class $$SecretShareTableReferences
    extends BaseReferences<_$AppDatabase, $SecretShareTable, SecretShareData> {
  $$SecretShareTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $IdentityTable _identityIdTable(_$AppDatabase db) => db.identity
      .createAlias('secret_share__identity_id__identity__identity_id');

  $$IdentityTableProcessedTableManager get identityId {
    final $_column = $_itemColumn<String>('identity_id')!;

    final manager = $$IdentityTableTableManager(
      $_db,
      $_db.identity,
    ).filter((f) => f.identityId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_identityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SecretShareTableFilterComposer
    extends Composer<_$AppDatabase, $SecretShareTable> {
  $$SecretShareTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get lastShared => $composableBuilder(
    column: $table.lastShared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passwordVersionShared => $composableBuilder(
    column: $table.passwordVersionShared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get settingsVersionShared => $composableBuilder(
    column: $table.settingsVersionShared,
    builder: (column) => ColumnFilters(column),
  );

  $$IdentityTableFilterComposer get identityId {
    final $$IdentityTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.identity,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityTableFilterComposer(
            $db: $db,
            $table: $db.identity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SecretShareTableOrderingComposer
    extends Composer<_$AppDatabase, $SecretShareTable> {
  $$SecretShareTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get lastShared => $composableBuilder(
    column: $table.lastShared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passwordVersionShared => $composableBuilder(
    column: $table.passwordVersionShared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get settingsVersionShared => $composableBuilder(
    column: $table.settingsVersionShared,
    builder: (column) => ColumnOrderings(column),
  );

  $$IdentityTableOrderingComposer get identityId {
    final $$IdentityTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.identity,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityTableOrderingComposer(
            $db: $db,
            $table: $db.identity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SecretShareTableAnnotationComposer
    extends Composer<_$AppDatabase, $SecretShareTable> {
  $$SecretShareTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get lastShared => $composableBuilder(
    column: $table.lastShared,
    builder: (column) => column,
  );

  GeneratedColumn<int> get passwordVersionShared => $composableBuilder(
    column: $table.passwordVersionShared,
    builder: (column) => column,
  );

  GeneratedColumn<int> get settingsVersionShared => $composableBuilder(
    column: $table.settingsVersionShared,
    builder: (column) => column,
  );

  $$IdentityTableAnnotationComposer get identityId {
    final $$IdentityTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.identity,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IdentityTableAnnotationComposer(
            $db: $db,
            $table: $db.identity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SecretShareTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SecretShareTable,
          SecretShareData,
          $$SecretShareTableFilterComposer,
          $$SecretShareTableOrderingComposer,
          $$SecretShareTableAnnotationComposer,
          $$SecretShareTableCreateCompanionBuilder,
          $$SecretShareTableUpdateCompanionBuilder,
          (SecretShareData, $$SecretShareTableReferences),
          SecretShareData,
          PrefetchHooks Function({bool identityId})
        > {
  $$SecretShareTableTableManager(_$AppDatabase db, $SecretShareTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SecretShareTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SecretShareTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SecretShareTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> identityId = const Value.absent(),
                Value<int> lastShared = const Value.absent(),
                Value<int> passwordVersionShared = const Value.absent(),
                Value<int> settingsVersionShared = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SecretShareCompanion(
                identityId: identityId,
                lastShared: lastShared,
                passwordVersionShared: passwordVersionShared,
                settingsVersionShared: settingsVersionShared,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String identityId,
                required int lastShared,
                required int passwordVersionShared,
                required int settingsVersionShared,
                Value<int> rowid = const Value.absent(),
              }) => SecretShareCompanion.insert(
                identityId: identityId,
                lastShared: lastShared,
                passwordVersionShared: passwordVersionShared,
                settingsVersionShared: settingsVersionShared,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SecretShareTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({identityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (identityId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.identityId,
                        referencedTable: $$SecretShareTableReferences
                            ._identityIdTable(db),
                        referencedColumn: $$SecretShareTableReferences
                            ._identityIdTable(db)
                            .identityId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SecretShareTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SecretShareTable,
      SecretShareData,
      $$SecretShareTableFilterComposer,
      $$SecretShareTableOrderingComposer,
      $$SecretShareTableAnnotationComposer,
      $$SecretShareTableCreateCompanionBuilder,
      $$SecretShareTableUpdateCompanionBuilder,
      (SecretShareData, $$SecretShareTableReferences),
      SecretShareData,
      PrefetchHooks Function({bool identityId})
    >;
typedef $$SyncStateTableCreateCompanionBuilder = SyncStateCompanion Function({
  required String conversationId,
  required int conversationType,
  required String displayName,
  Value<String?> avatar,
  Value<int> unreadCount,
  Value<String?> lastReadMessageId,
  Value<String?> lastReadMessage,
  Value<String?> lastMessageId,
  Value<String?> lastMessage,
  Value<int> pinned,
  Value<int?> pinnedPosition,
  required int updatedAt,
  required String colour,
  Value<int> muted,
  Value<int> mentions,
  Value<int> rowid,
});
typedef $$SyncStateTableUpdateCompanionBuilder = SyncStateCompanion Function({
  Value<String> conversationId,
  Value<int> conversationType,
  Value<String> displayName,
  Value<String?> avatar,
  Value<int> unreadCount,
  Value<String?> lastReadMessageId,
  Value<String?> lastReadMessage,
  Value<String?> lastMessageId,
  Value<String?> lastMessage,
  Value<int> pinned,
  Value<int?> pinnedPosition,
  Value<int> updatedAt,
  Value<String> colour,
  Value<int> muted,
  Value<int> mentions,
  Value<int> rowid,
});

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conversationType => $composableBuilder(
    column: $table.conversationType,
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

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastReadMessageId => $composableBuilder(
    column: $table.lastReadMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastReadMessage => $composableBuilder(
    column: $table.lastReadMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pinnedPosition => $composableBuilder(
    column: $table.pinnedPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colour => $composableBuilder(
    column: $table.colour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mentions => $composableBuilder(
    column: $table.mentions,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conversationType => $composableBuilder(
    column: $table.conversationType,
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

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastReadMessageId => $composableBuilder(
    column: $table.lastReadMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastReadMessage => $composableBuilder(
    column: $table.lastReadMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pinnedPosition => $composableBuilder(
    column: $table.pinnedPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colour => $composableBuilder(
    column: $table.colour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mentions => $composableBuilder(
    column: $table.mentions,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get conversationType => $composableBuilder(
    column: $table.conversationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastReadMessageId => $composableBuilder(
    column: $table.lastReadMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastReadMessage => $composableBuilder(
    column: $table.lastReadMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<int> get pinnedPosition => $composableBuilder(
    column: $table.pinnedPosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get colour =>
      $composableBuilder(column: $table.colour, builder: (column) => column);

  GeneratedColumn<int> get muted =>
      $composableBuilder(column: $table.muted, builder: (column) => column);

  GeneratedColumn<int> get mentions =>
      $composableBuilder(column: $table.mentions, builder: (column) => column);
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateData,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateData,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
          ),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> conversationId = const Value.absent(),
                Value<int> conversationType = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<String?> lastReadMessageId = const Value.absent(),
                Value<String?> lastReadMessage = const Value.absent(),
                Value<String?> lastMessageId = const Value.absent(),
                Value<String?> lastMessage = const Value.absent(),
                Value<int> pinned = const Value.absent(),
                Value<int?> pinnedPosition = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> colour = const Value.absent(),
                Value<int> muted = const Value.absent(),
                Value<int> mentions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                conversationId: conversationId,
                conversationType: conversationType,
                displayName: displayName,
                avatar: avatar,
                unreadCount: unreadCount,
                lastReadMessageId: lastReadMessageId,
                lastReadMessage: lastReadMessage,
                lastMessageId: lastMessageId,
                lastMessage: lastMessage,
                pinned: pinned,
                pinnedPosition: pinnedPosition,
                updatedAt: updatedAt,
                colour: colour,
                muted: muted,
                mentions: mentions,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String conversationId,
                required int conversationType,
                required String displayName,
                Value<String?> avatar = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<String?> lastReadMessageId = const Value.absent(),
                Value<String?> lastReadMessage = const Value.absent(),
                Value<String?> lastMessageId = const Value.absent(),
                Value<String?> lastMessage = const Value.absent(),
                Value<int> pinned = const Value.absent(),
                Value<int?> pinnedPosition = const Value.absent(),
                required int updatedAt,
                required String colour,
                Value<int> muted = const Value.absent(),
                Value<int> mentions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                conversationId: conversationId,
                conversationType: conversationType,
                displayName: displayName,
                avatar: avatar,
                unreadCount: unreadCount,
                lastReadMessageId: lastReadMessageId,
                lastReadMessage: lastReadMessage,
                lastMessageId: lastMessageId,
                lastMessage: lastMessage,
                pinned: pinned,
                pinnedPosition: pinnedPosition,
                updatedAt: updatedAt,
                colour: colour,
                muted: muted,
                mentions: mentions,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateData,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateData,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
      ),
      SyncStateData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$IdentityTableTableManager get identity =>
      $$IdentityTableTableManager(_db, _db.identity);
  $$ServersTableTableManager get servers =>
      $$ServersTableTableManager(_db, _db.servers);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$ContactsNetworkTableTableManager get contactsNetwork =>
      $$ContactsNetworkTableTableManager(_db, _db.contactsNetwork);
  $$ContactNetworkMembersTableTableManager get contactNetworkMembers =>
      $$ContactNetworkMembersTableTableManager(_db, _db.contactNetworkMembers);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$GroupMembersTableTableManager get groupMembers =>
      $$GroupMembersTableTableManager(_db, _db.groupMembers);
  $$ConnectionRequestsTableTableManager get connectionRequests =>
      $$ConnectionRequestsTableTableManager(_db, _db.connectionRequests);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$ShamirsSecretTableTableManager get shamirsSecret =>
      $$ShamirsSecretTableTableManager(_db, _db.shamirsSecret);
  $$SecretShareTableTableManager get secretShare =>
      $$SecretShareTableTableManager(_db, _db.secretShare);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
}
