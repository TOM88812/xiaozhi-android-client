import 'package:flutter_test/flutter_test.dart';
import 'package:ai_assistant/utils/bridge_connection_user_errors.dart';

void main() {
  test('vpn jitter tip is short Chinese, not blank', () {
    expect(
      BridgeConnectionUserErrors.interrupted(retried: true),
      contains('Tailscale'),
    );
    expect(
      BridgeConnectionUserErrors.connectTimeout('乌班图1'),
      contains('乌班图1'),
    );
    expect(BridgeConnectionUserErrors.busy(retried: false), contains('正在等待'));
    expect(
      BridgeConnectionUserErrors.looksLikeVpnJitter(
        Exception('Network is unreachable'),
      ),
      isTrue,
    );
    expect(
      BridgeConnectionUserErrors.looksLikeVpnJitter(
        Exception('Connection refused'),
      ),
      isFalse,
    );
  });
}
