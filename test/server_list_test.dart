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

  group('ServerListService.pickSendServers', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> seedMine(List<String> ids) async {
      final service = ServerListService();
      await service.init();
      for (final id in ids) {
        await service.addServer(_server(id));
      }
    }

    test('a shared server is used for both roles', () async {
      await seedMine(['mine_1', 'shared', 'mine_2']);
      final picked =
          await ServerListService.pickSendServers(['contact_a', 'shared']);
      expect(picked.transport, 'shared');
      expect(picked.target, 'shared');
    });

    test('a random shared server wins among several matches', () async {
      await seedMine(['shared_1', 'shared_2', 'mine_1']);
      for (var i = 0; i < 20; i++) {
        final picked =
            await ServerListService.pickSendServers(['shared_1', 'shared_2']);
        expect(picked.transport, picked.target);
        expect(['shared_1', 'shared_2'], contains(picked.transport));
      }
    });

    test('no shared server: target is a contact server, transport ours',
        () async {
      await seedMine(['mine_1', 'mine_2']);
      for (var i = 0; i < 20; i++) {
        final picked = await ServerListService.pickSendServers(
          ['contact_a', 'contact_b'],
        );
        expect(['contact_a', 'contact_b'], contains(picked.target));
        expect(['mine_1', 'mine_2'], contains(picked.transport));
        expect(['mine_1', 'mine_2'], isNot(contains(picked.target)));
      }
    });

    test('empty conversation servers fall back to our own list', () async {
      await seedMine(['mine_1', 'mine_2']);
      final picked = await ServerListService.pickSendServers(const []);
      expect(['mine_1', 'mine_2'], contains(picked.transport));
      expect(['mine_1', 'mine_2'], contains(picked.target));
    });
  });
}
