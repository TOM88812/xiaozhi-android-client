/// Canonical Tailscale endpoints for 乌班图1 / 乌班图2.
///
/// Live MagicDNS today (do not cross):
/// - 乌班图1 id=`ubantu` → host `ubantu-1` / IP `100.82.110.10`
/// - 乌班图2 id=`ubantu-2` → host `ubantu` / IP `100.75.237.112`
///
/// Prefer stable Tailscale IP as the default; MagicDNS is fallback only.
class UbantuBridgeEndpoints {
  static const tailscaleDomain = 'tailbe27c4.ts.net';
  static const hermesPort = 8765;
  static const qoderPort = 8770;

  static const one = UbantuMachine(
    id: 'ubantu',
    displayName: '乌班图1',
    magicDnsHost: 'ubantu-1',
    ip: '100.82.110.10',
  );

  static const two = UbantuMachine(
    id: 'ubantu-2',
    displayName: '乌班图2',
    magicDnsHost: 'ubantu',
    ip: '100.75.237.112',
  );

  static const all = [one, two];

  static UbantuMachine? byId(String id) {
    for (final machine in all) {
      if (machine.id == id) return machine;
    }
    return null;
  }

  static String normalize(String endpoint) {
    var url = endpoint.trim();
    if (url.startsWith('ws://')) {
      url = url.replaceFirst('ws://', 'http://');
    } else if (url.startsWith('wss://')) {
      url = url.replaceFirst('wss://', 'https://');
    } else if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  static String preferred(UbantuMachine machine, int port) =>
      'http://${machine.ip}:$port';

  static String magicDns(UbantuMachine machine, int port) =>
      'http://${machine.magicDnsHost}.$tailscaleDomain:$port';

  /// IP first, then this machine's MagicDNS — never the sibling's hosts.
  static List<String> candidates(UbantuMachine machine, int port) {
    final ip = preferred(machine, port);
    final dns = magicDns(machine, port);
    return [ip, dns];
  }

  static bool belongsTo(String endpoint, UbantuMachine machine, int port) {
    final primary = normalize(endpoint);
    return primary == preferred(machine, port) ||
        primary == magicDns(machine, port);
  }

  /// Rewrite saved preset endpoints to the stable IP for this machine.
  /// Returns null when [machineId] is not an ubantu preset, or already correct.
  static String? correctedEndpoint({
    required String machineId,
    required String endpoint,
    required int port,
  }) {
    final machine = byId(machineId);
    if (machine == null) return null;
    final canonical = preferred(machine, port);
    if (normalize(endpoint) == canonical) return null;
    // Cross-wired MagicDNS/IP, stale DNS-only, or any drift → pin to IP.
    return canonical;
  }
}

class UbantuMachine {
  const UbantuMachine({
    required this.id,
    required this.displayName,
    required this.magicDnsHost,
    required this.ip,
  });

  final String id;
  final String displayName;
  final String magicDnsHost;
  final String ip;
}
