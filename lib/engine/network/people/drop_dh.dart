// module name: dh_drop
import 'package:dio/dio.dart';

import '../main_server_client.dart';

class DhDropService {
  Dio get _dio => MainServerClient.dio;

  const DhDropService();

  /// Drops a dh key for [recipientId]'s inbox.
  ///
  /// This is a one-way, fire-and-forget operation: there is no ack payload
  /// beyond success/failure, and no expiry — the drop is deleted the moment
  /// the recipient fetches it via [CheckDhDropsService.checkDhDrops].
  ///
  /// [dhEncKey] is the recipient's public dh key, encrypted with the
  /// sender's public dh key. [dhEncNonce] is the nonce used for that
  /// encryption.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by MainServerClient's interceptors.
  Future<void> dhDrop({
    required String recipientId,
    required String dhEncKey,
    required String dhEncNonce,
  }) async {
    await _dio.post(
      '/api/dh-drop',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'recipient_id': recipientId,
        'dh_enc_key': dhEncKey,
        'dh_enc_nonce': dhEncNonce,
      },
    );
  }
}