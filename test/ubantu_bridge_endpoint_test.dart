import 'package:flutter_test/flutter_test.dart';
import 'package:ai_assistant/utils/ubantu_bridge_endpoints.dart';

void main() {
  group('UbantuBridgeEndpoints', () {
    test('乌班图1/2 resolve to different stable IPs and MagicDNS names', () {
      expect(UbantuBridgeEndpoints.one.ip, '100.82.110.10');
      expect(UbantuBridgeEndpoints.one.magicDnsHost, 'ubantu-1');
      expect(UbantuBridgeEndpoints.two.ip, '100.75.237.112');
      expect(UbantuBridgeEndpoints.two.magicDnsHost, 'ubantu');
      expect(UbantuBridgeEndpoints.one.ip, isNot(UbantuBridgeEndpoints.two.ip));
      expect(
        UbantuBridgeEndpoints.one.magicDnsHost,
        isNot(UbantuBridgeEndpoints.two.magicDnsHost),
      );
    });

    test('preferred endpoints never cross 1↔2', () {
      expect(
        UbantuBridgeEndpoints.preferred(
          UbantuBridgeEndpoints.one,
          UbantuBridgeEndpoints.qoderPort,
        ),
        'http://100.82.110.10:8770',
      );
      expect(
        UbantuBridgeEndpoints.preferred(
          UbantuBridgeEndpoints.two,
          UbantuBridgeEndpoints.qoderPort,
        ),
        'http://100.75.237.112:8770',
      );
      expect(
        UbantuBridgeEndpoints.preferred(
          UbantuBridgeEndpoints.one,
          UbantuBridgeEndpoints.hermesPort,
        ),
        'http://100.82.110.10:8765',
      );
      expect(
        UbantuBridgeEndpoints.preferred(
          UbantuBridgeEndpoints.two,
          UbantuBridgeEndpoints.hermesPort,
        ),
        'http://100.75.237.112:8765',
      );
    });

    test('candidates stay on the same machine', () {
      final one = UbantuBridgeEndpoints.candidates(
        UbantuBridgeEndpoints.one,
        UbantuBridgeEndpoints.qoderPort,
      );
      final two = UbantuBridgeEndpoints.candidates(
        UbantuBridgeEndpoints.two,
        UbantuBridgeEndpoints.qoderPort,
      );

      expect(one.first, 'http://100.82.110.10:8770');
      expect(one, contains('http://ubantu-1.tailbe27c4.ts.net:8770'));
      expect(one, isNot(contains('http://ubantu.tailbe27c4.ts.net:8770')));
      expect(one, isNot(contains('http://100.75.237.112:8770')));

      expect(two.first, 'http://100.75.237.112:8770');
      expect(two, contains('http://ubantu.tailbe27c4.ts.net:8770'));
      expect(two, isNot(contains('http://ubantu-1.tailbe27c4.ts.net:8770')));
      expect(two, isNot(contains('http://100.82.110.10:8770')));
    });

    test('correctedEndpoint rewrites cross-wired and MagicDNS presets to IP', () {
      expect(
        UbantuBridgeEndpoints.correctedEndpoint(
          machineId: 'ubantu',
          endpoint: 'http://ubantu.tailbe27c4.ts.net:8770',
          port: 8770,
        ),
        'http://100.82.110.10:8770',
      );
      expect(
        UbantuBridgeEndpoints.correctedEndpoint(
          machineId: 'ubantu-2',
          endpoint: 'http://ubantu-1.tailbe27c4.ts.net:8765',
          port: 8765,
        ),
        'http://100.75.237.112:8765',
      );
      expect(
        UbantuBridgeEndpoints.correctedEndpoint(
          machineId: 'ubantu',
          endpoint: 'http://100.82.110.10:8770',
          port: 8770,
        ),
        isNull,
      );
      expect(
        UbantuBridgeEndpoints.correctedEndpoint(
          machineId: 'office-4800',
          endpoint: 'http://100.90.228.28:8765',
          port: 8765,
        ),
        isNull,
      );
    });
  });
}
