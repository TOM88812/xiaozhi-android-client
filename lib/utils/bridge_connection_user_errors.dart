/// Short Chinese tips for Tailscale/VPN jitter on bridge clients (Hermes :8765, Qoder :8770).
///
/// Merge into MyAPP `hermes_service.dart` / `qoder_service.dart` user-facing paths
/// so chat never looks like "sent with no echo" during connect timeouts or busy.
class BridgeConnectionUserErrors {
  static String refused(String machineLabel) =>
      '连不上$machineLabel：接收器没开，或地址不对。请确认电脑已开接收器。';

  static String interrupted({required bool retried}) => retried
      ? '连接中断，Tailscale/网络抖了一下。已自动重试仍失败，请再发一次。'
      : '连接中断，Tailscale/网络可能在抖动，正在重试。';

  static String connectTimeout(String machineLabel) =>
      '连不上$machineLabel：手机 Tailscale 可能没打开，或 5G 下连云端太慢。请打开 Tailscale 确认能看到这台电脑，再发一次。';

  static String responseTimeout() => '电脑响应超时。接收器可能卡住，或这次任务太久。';

  static String busy({required bool retried}) => retried
      ? '电脑还在处理上一条消息。已自动重试仍忙，请稍后再发一次。'
      : '电脑还在处理上一条消息，正在等待。';

  /// True when the error text looks like VPN/route flap rather than "receiver off".
  static bool looksLikeVpnJitter(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('network is unreachable') ||
        text.contains('no route to host') ||
        text.contains('host is down') ||
        text.contains('network unreachable') ||
        text.contains('connection abort') ||
        text.contains('connection reset') ||
        text.contains('connection closed') ||
        text.contains('broken pipe') ||
        text.contains('software caused connection abort') ||
        text.contains('connection reset by peer');
  }
}
