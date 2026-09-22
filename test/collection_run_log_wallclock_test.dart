import 'package:flutter_test/flutter_test.dart';
import 'package:ai_assistant/models/collection_run_log.dart';

void main() {
  test('hub log_tail keeps Shanghai wall clock display (no +8h)', () {
    final snapshot = CollectionRunLogSnapshot.fromJson({
      'ok': true,
      'status': 'running',
      'log_tail': [
        {
          'level': 'info',
          'message': 'success outcome',
          'created_at': '2026-09-03 18:51:27',
        },
      ],
    });

    expect(snapshot.events, hasLength(1));
    expect(snapshot.events.first.utcTimestamp, isFalse);
    expect(snapshot.events.first.displayCreatedAt, '2026-09-03 18:51:27');
  });

  test('Admin events still parse as UTC wall clock', () {
    final snapshot = CollectionRunLogSnapshot.fromJson({
      'ok': true,
      'status': 'running',
      'events': [
        {
          'level': 'info',
          'message': 'admin event',
          'created_at': '2026-09-03 10:51:27',
        },
      ],
    });

    expect(snapshot.events, hasLength(1));
    expect(snapshot.events.first.utcTimestamp, isTrue);
    final local = CollectionRunLogTime.parseAdminUtcWallClock(
      '2026-09-03 10:51:27',
    );
    expect(
      snapshot.events.first.displayCreatedAt,
      CollectionRunLogTime.formatDisplay(local, fallback: ''),
    );
  });
}
