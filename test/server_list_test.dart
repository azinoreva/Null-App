import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:null_app/utils/server_list.dart';
import 'package:null_app/utils/server_model.dart';

ServerConfig _server(String id) => ServerConfig(
      serverId: id,
      serverName: id,
      serverUrl: 'https://$id.example.com',
      serverType: ServerType.public,
      maxPayload: 4000,
      colour: '',
      about: '',
      annotated: false,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServerListService normal list cap', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('fills to 8, then refuses further normal joins', () async {
      final service = ServerListService();
      await service.init();

      expect(service.canJoinExtraServers, isFalse);
      for (var i = 0; i < ServerListService.maxServers; i++) {
        await service.addServer(_server('server_$i'));
      }

      expect(service.servers, hasLength(ServerListService.maxServers));
      expect(service.canJoinExtraServers, isTrue);
      await expectLater(
        service.addServer(_server('server_overflow')),
        throwsA(isA<ServerListException>()),
      );
      expect(service.servers, hasLength(ServerListService.maxServers));
    });

    test('extra list stays locked until the normal list is full', () async {
      final service = ServerListService();
      await service.init();

      await expectLater(
        service.addExtraServer(_server('server_extra')),
        throwsA(isA<ServerListException>()),
      );

      for (var i = 0; i < ServerListService.maxServers; i++) {
        await service.addServer(_server('server_$i'));
      }
      await service.addExtraServer(_server('server_extra'));
      expect(service.extraServers.map((s) => s.serverId), ['server_extra']);
    });

    test('readServerIds returns the normal list ids, extras excluded',
        () async {
      final service = ServerListService();
      await service.init();
      for (var i = 0; i < ServerListService.maxServers; i++) {
        await service.addServer(_server('server_$i'));
      }
      await service.addExtraServer(_server('server_extra'));

      expect(await ServerListService.readServerIds(), hasLength(8));
      expect(await ServerListService.readServerIds(), isNot(contains('server_extra')));
    });

    test('a server id may not live in both lists', () async {
      final service = ServerListService();
      await service.init();
      await service.addServer(_server('server_0'));
      await expectLater(
        service.addServer(_server('server_0')),
        throwsA(isA<ServerListException>()),
      );
    });

    test('lookup resolves servers from either list', () async {
      final service = ServerListService();
      await service.init();
      for (var i = 0; i < ServerListService.maxServers; i++) {
        await service.addServer(_server('server_$i'));
      }
      await service.addExtraServer(_server('server_extra'));

      expect((await ServerListService.lookup('server_0'))?.serverId, 'server_0');
      expect(
        (await ServerListService.lookup('server_extra'))?.serverId,
        'server_extra',
      );
      expect(await ServerListService.lookup('server_missing'), isNull);
    });
  });
}
