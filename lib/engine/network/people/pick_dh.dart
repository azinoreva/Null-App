// module name: check_dh_drops
import 'package:dio/dio.dart';

import '../main_server_client.dart';

/// A single pending dh key drop found in the caller's inbox.
class DhDrop {
  /// The user id of whoever dropped this key.
  final String senderId;

  /// The recipient's public dh key, encrypted with the sender's public dh
  /// key.
  final String dhEncKey;

  /// The nonce used to encrypt [dhEncKey].
  final String dhEncNonce;

  /// The server id the sender dropped from (relevant in multi-server
  /// setups).
  final String serverId;

  const DhDrop({
    required this.senderId,
    required this.dhEncKey,
    required this.dhEncNonce,
    required this.serverId,
  });

  factory DhDrop.fromJson(Map<String, dynamic> json) {
    return DhDrop(
      senderId: json['sender_id'] as String,
      dhEncKey: json['dh_enc_key'] as String,
      dhEncNonce: json['dh_enc_nonce'] as String,
      serverId: json['server_id'] as String,
    );
  }
}

class CheckDhDropsService {
  Dio get _dio => MainServerClient.dio;

  const CheckDhDropsService();

  /// Fetches any dh keys left in the caller's inbox.
  ///
  /// This atomically fetches and clears the inbox server-side, so each
  /// [DhDrop] is delivered exactly once — call this once on app open
  /// (alongside checking contacts) rather than polling.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by MainServerClient's interceptors.
  Future<List<DhDrop>> checkDhDrops() async {
    final response = await _dio.post(
      '/api/connections/check_dh_drops',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final drops = data['dh_drops'] as List<dynamic>;

    return drops
        .map((e) => DhDrop.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}