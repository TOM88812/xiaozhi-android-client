import 'dart:convert';

class CollectionRunEvent {
  const CollectionRunEvent({
    required this.level,
    required this.message,
    required this.createdAt,
    this.createdAtLocal,
    this.utcTimestamp = false,
  });

  final String level;
  final String message;

  /// Admin 原始时间串（格式因来源而异，见 [CollectionRunLogTime]）。
  final String createdAt;
  final DateTime? createdAtLocal;

  /// ``events`` 条目为 UTC 墙钟；``log_rows`` / ``worker_log_rows`` 为 Mac 本地墙钟。
  final bool utcTimestamp;

  String get displayCreatedAt =>
      CollectionRunLogTime.formatDisplay(createdAtLocal, fallback: createdAt);

  DateTime get sortTime {
    if (createdAtLocal != null) return createdAtLocal!;
    final parsed =
        utcTimestamp
            ? CollectionRunLogTime.parseAdminUtcWallClock(createdAt)
            : CollectionRunLogTime.parseAdminWallClock(createdAt);
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  factory CollectionRunEvent.fromJson(
    Map<String, dynamic> json, {
    bool defaultUtcTimestamp = true,
  }) {
    final createdAt =
        json['created_at']?.toString().trim() ??
        json['ts']?.toString().trim() ??
        '';
    final message = json['message']?.toString().trim() ?? '';
    // Explicit flag wins; otherwise callers choose Admin events (UTC) vs hub log_tail (local wall).
    final utc =
        json.containsKey('utc_timestamp')
            ? json['utc_timestamp'] == true
            : defaultUtcTimestamp;
    if (message.isNotEmpty) {
      return CollectionRunEvent(
        level: json['level']?.toString().trim().toLowerCase() ?? 'info',
        message: message,
        createdAt: createdAt,
        createdAtLocal:
            utc
                ? CollectionRunLogTime.parseAdminUtcWallClock(createdAt)
                : CollectionRunLogTime.parseAdminWallClock(createdAt),
        utcTimestamp: utc,
      );
    }
    return CollectionRunEvent.fromLogRow(json);
  }

  factory CollectionRunEvent.fromLogRow(Map<String, dynamic> json) {
    final phase = json['phase']?.toString().trim().toLowerCase() ?? '';
    final event = json['event']?.toString().trim().toLowerCase() ?? '';
    final title = json['title']?.toString().trim() ?? '';
    final sourceId = json['source_id']?.toString().trim() ?? '';
    final hostname = json['hostname']?.toString().trim() ?? '';
    final error =
        json['error']?.toString().trim() ??
        json['failure_reason']?.toString().trim() ??
        '';
    final createdAt =
        json['ts']?.toString().trim() ??
        json['created_at']?.toString().trim() ??
        '';
    final failed = phase == 'failed' || json['ok'] == false;
    final phaseLabel = switch (phase) {
      'success' => '成功',
      'failed' => '失败',
      'running' => '进行中',
      'deferred_proxy' => '转代理',
      _ =>
        event == 'item_done'
            ? (failed ? '失败' : '完成')
            : (event == 'start_item' ? '进行中' : ''),
    };
    final parts = [
      if (phaseLabel.isNotEmpty) phaseLabel,
      if (sourceId.isNotEmpty) sourceId,
      if (hostname.isNotEmpty) hostname,
      if (title.isNotEmpty) title,
      if (error.isNotEmpty) error,
    ];
    return CollectionRunEvent(
      level: failed ? 'error' : 'info',
      message: parts.join(' · '),
      createdAt: createdAt,
      createdAtLocal: CollectionRunLogTime.parseAdminWallClock(createdAt),
    );
  }

  bool get isVisible => message.isNotEmpty;

  Map<String, dynamic> toCacheJson() => {
    'level': level,
    'message': message,
    'created_at': createdAt,
    'utc_timestamp': utcTimestamp,
  };

  factory CollectionRunEvent.fromCacheJson(Map<String, dynamic> json) {
    final createdAt =
        json['created_at']?.toString().trim() ??
        json['ts']?.toString().trim() ??
        '';
    final utc = json['utc_timestamp'] == true;
    return CollectionRunEvent(
      level: json['level']?.toString().trim().toLowerCase() ?? 'info',
      message: json['message']?.toString().trim() ?? '',
      createdAt: createdAt,
      createdAtLocal:
          utc
              ? CollectionRunLogTime.parseAdminUtcWallClock(createdAt)
              : CollectionRunLogTime.parseAdminWallClock(createdAt),
      utcTimestamp: utc,
    );
  }
}

/// Admin 日志时间有两种墙钟格式：
/// - ``log_rows`` / ``worker_log_rows`` 的 ``ts``：Mac mini 本地（Asia/Shanghai）
/// - ``events`` 的 ``created_at``：SQLite / 守护进程 UTC 墙钟，需转本地展示
class CollectionRunLogTime {
  CollectionRunLogTime._();

  static final _wallClock = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})(?::(\d{2}))?',
  );

  /// ``log_rows`` / ``worker_log_rows`` 的 ``ts``（Mac mini 本地墙钟，原样展示）。
  static DateTime? parseAdminWallClock(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    if (value.endsWith('Z') || RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(value)) {
      final parsed = DateTime.tryParse(value);
      if (parsed == null) return null;
      return parsed.isUtc ? parsed.toLocal() : parsed;
    }
    final match = _wallClock.firstMatch(value);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
      int.parse(match.group(6) ?? '0'),
    );
  }

  /// ``events`` 的 ``created_at``（UTC 墙钟 ``YYYY-MM-DD HH:MM:SS``，转本地）。
  static DateTime? parseAdminUtcWallClock(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    if (value.endsWith('Z') || RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(value)) {
      final parsed = DateTime.tryParse(value);
      if (parsed == null) return null;
      return parsed.isUtc ? parsed.toLocal() : parsed.toLocal();
    }
    final match = _wallClock.firstMatch(value);
    if (match == null) return null;
    return DateTime.utc(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
      int.parse(match.group(6) ?? '0'),
    ).toLocal();
  }

  static String formatDisplay(DateTime? local, {required String fallback}) {
    if (local == null) return fallback;
    final y = local.year.toString().padLeft(4, '0');
    final mo = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    final s = local.second.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi:$s';
  }
}

class CollectionRunParamRow {
  const CollectionRunParamRow({required this.label, required this.value});

  final String label;
  final String value;
}

/// 将 status JSON 的 `params` / 顶层展示字段转成页头「任务参数」行。
class CollectionRunLogParamDisplay {
  CollectionRunLogParamDisplay._();

  static const helperKeys = <String>[
    'started_at_display',
    'finished_at_display',
    'site_range_label',
    'use_ai_label',
    'continuous_label',
    'max_sample_pages',
    'base_run_id',
    'max_site_workers',
  ];

  static const _exactLabels = <String, String>{
    'concurrency': '并发数',
    'workers': '并发数',
    'max_site_workers': '并发数',
    'started_at': '起始时间',
    'started_at_display': '起始时间',
    'start_time': '起始时间',
    'start_at': '起始时间',
    'finished_at': '结束时间',
    'finished_at_display': '结束时间',
    'end_time': '结束时间',
    'end_at': '结束时间',
    'sleep': '采集间隔',
    'interval': '采集间隔',
    'continuous': '持续采集',
    'continuous_label': '持续采集',
    'use_ai': '使用 AI',
    'use_ai_label': '使用 AI',
    'max_sample_pages': '最大采样页',
    'site_id': '站点 ID',
    'base_run_id': '基准任务',
    'site_range': '站点范围',
    'site_range_label': '站点范围',
  };

  static List<CollectionRunParamRow> rows({
    required Map<String, dynamic> params,
    Map<String, dynamic> extras = const {},
  }) {
    final out = <CollectionRunParamRow>[];
    final seenKeys = <String>{};
    final labelIndex = <String, int>{};

    void add(String key, Object? value, {bool prefer = false}) {
      final formatted = formatValue(value);
      if (formatted.isEmpty) return;
      final normalized = key.trim().toLowerCase();
      if (normalized.isEmpty || seenKeys.contains(normalized)) return;
      final label = labelFor(key);
      final existing = labelIndex[label];
      if (existing != null) {
        if (prefer && out[existing].value != formatted) {
          out[existing] = CollectionRunParamRow(label: label, value: formatted);
        }
        seenKeys.add(normalized);
        return;
      }
      seenKeys.add(normalized);
      labelIndex[label] = out.length;
      out.add(CollectionRunParamRow(label: label, value: formatted));
    }

    for (final entry in params.entries) {
      add(entry.key, entry.value);
    }
    for (final entry in extras.entries) {
      if (params.keys.any(
        (key) => key.trim().toLowerCase() == entry.key.trim().toLowerCase(),
      )) {
        continue;
      }
      final extraKey = entry.key.trim().toLowerCase();
      add(
        entry.key,
        entry.value,
        prefer: extraKey.endsWith('_display') || extraKey.endsWith('_label'),
      );
    }
    return out;
  }

  static String labelFor(String key) {
    final raw = key.trim();
    if (raw.isEmpty) return raw;
    final lower = raw.toLowerCase();
    final exact = _exactLabels[lower];
    if (exact != null) return exact;
    if (lower.endsWith('_workers') ||
        lower.endsWith('_concurrency') ||
        lower == 'worker_count' ||
        lower.contains('concurrency')) {
      return '并发数';
    }
    if (RegExp(r'^(sleep|interval)(_|$)').hasMatch(lower) ||
        lower.endsWith('_sleep') ||
        lower.endsWith('_interval')) {
      return '采集间隔';
    }
    return raw;
  }

  static String formatValue(Object? value) {
    if (value == null) return '';
    if (value is bool) return value ? '是' : '否';
    if (value is String) return value.trim();
    if (value is num) return value.toString();
    if (value is List) {
      if (value.isEmpty) return '';
      return value.map(formatValue).where((item) => item.isNotEmpty).join('、');
    }
    if (value is Map) {
      if (value.isEmpty) return '';
      try {
        return jsonEncode(value);
      } catch (_) {
        return value.toString();
      }
    }
    return value.toString().trim();
  }

  static Map<String, dynamic> parseParams(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        return parseParams(jsonDecode(raw));
      } catch (_) {
        return const {};
      }
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(
        raw.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    if (raw is List) {
      final out = <String, dynamic>{};
      for (final item in raw.whereType<Map>()) {
        final label = item['label']?.toString().trim() ?? '';
        if (label.isEmpty) continue;
        out[label] = item['value'];
      }
      return out;
    }
    return const {};
  }

  static Map<String, dynamic> extrasFromStatus(Map<String, dynamic> json) {
    final extras = <String, dynamic>{};
    for (final key in helperKeys) {
      if (json.containsKey(key) && json[key] != null) {
        extras[key] = json[key];
      }
    }
    return extras;
  }
}

class CollectionRunLogSnapshot {
  const CollectionRunLogSnapshot({
    required this.ok,
    required this.status,
    required this.lastMessage,
    required this.progressText,
    required this.refreshMs,
    required this.events,
    this.runId = '',
    this.params = const {},
    this.displayFields = const {},
  });

  final bool ok;
  final String status;
  final String lastMessage;
  final String progressText;
  final int refreshMs;
  final List<CollectionRunEvent> events;
  final String runId;
  final Map<String, dynamic> params;
  final Map<String, dynamic> displayFields;

  bool get hasEvents => events.isNotEmpty;

  List<CollectionRunParamRow> get displayParamRows =>
      CollectionRunLogParamDisplay.rows(params: params, extras: displayFields);

  CollectionRunLogSnapshot copyWith({
    bool? ok,
    String? status,
    String? lastMessage,
    String? progressText,
    int? refreshMs,
    List<CollectionRunEvent>? events,
    String? runId,
    Map<String, dynamic>? params,
    Map<String, dynamic>? displayFields,
  }) {
    return CollectionRunLogSnapshot(
      ok: ok ?? this.ok,
      status: status ?? this.status,
      lastMessage: lastMessage ?? this.lastMessage,
      progressText: progressText ?? this.progressText,
      refreshMs: refreshMs ?? this.refreshMs,
      events: events ?? this.events,
      runId: runId ?? this.runId,
      params: params ?? this.params,
      displayFields: displayFields ?? this.displayFields,
    );
  }

  Map<String, dynamic> toCacheJson() => {
    'ok': ok,
    'status': status,
    'last_message': lastMessage,
    'progress_text': progressText,
    'refresh_ms': refreshMs,
    'run_id': runId,
    'params': params,
    'display_fields': displayFields,
    'events': events.map((event) => event.toCacheJson()).toList(),
  };

  factory CollectionRunLogSnapshot.fromCacheJson(Map<String, dynamic> json) {
    final eventsRaw = json['events'];
    final events = <CollectionRunEvent>[];
    if (eventsRaw is List) {
      events.addAll(
        eventsRaw
            .whereType<Map>()
            .map(
              (row) => CollectionRunEvent.fromCacheJson(
                Map<String, dynamic>.from(row),
              ),
            )
            .where((event) => event.isVisible),
      );
    }
    return CollectionRunLogSnapshot(
      ok: json['ok'] != false,
      status: json['status']?.toString().trim().toLowerCase() ?? '',
      lastMessage: json['last_message']?.toString().trim() ?? '',
      progressText: json['progress_text']?.toString().trim() ?? '',
      refreshMs: _refreshMs(json['refresh_ms']),
      events: CollectionRunLogTail.takeLatest(events),
      runId: json['run_id']?.toString().trim() ?? '',
      params: CollectionRunLogParamDisplay.parseParams(json['params']),
      displayFields: CollectionRunLogParamDisplay.parseParams(
        json['display_fields'],
      ),
    );
  }

  factory CollectionRunLogSnapshot.fromJson(Map<String, dynamic> json) {
    final events = _collectEvents(json);
    events.sort((a, b) => b.sortTime.compareTo(a.sortTime));

    return CollectionRunLogSnapshot(
      ok: json['ok'] == true,
      status: json['status']?.toString().trim().toLowerCase() ?? '',
      lastMessage:
          json['last_message']?.toString().trim().isNotEmpty == true
              ? json['last_message'].toString().trim()
              : (json['message']?.toString().trim() ?? ''),
      progressText: _progressText(json),
      refreshMs: _refreshMs(json['refresh_ms']),
      events: events,
      runId: json['run_id']?.toString().trim() ?? '',
      params: CollectionRunLogParamDisplay.parseParams(json['params']),
      displayFields: CollectionRunLogParamDisplay.extrasFromStatus(json),
    );
  }

  static List<CollectionRunEvent> _collectEvents(Map<String, dynamic> json) {
    final events = <CollectionRunEvent>[];

    void addMessageRows(Object? raw, {required bool defaultUtcTimestamp}) {
      if (raw is! List) return;
      for (final row in raw.whereType<Map>()) {
        events.add(
          CollectionRunEvent.fromJson(
            Map<String, dynamic>.from(row),
            defaultUtcTimestamp: defaultUtcTimestamp,
          ),
        );
      }
    }

    // Admin ``events`` are UTC wall clocks; hub ``log_tail`` is Asia/Shanghai wall.
    // Keep legacy preference: if ``events`` is present, do not also ingest ``log_tail``.
    if (json['events'] is List) {
      addMessageRows(json['events'], defaultUtcTimestamp: true);
    } else {
      addMessageRows(json['log_tail'], defaultUtcTimestamp: false);
    }

    final logRows = json['log_rows'];
    if (logRows is List) {
      for (final row in logRows.whereType<Map>()) {
        events.add(
          CollectionRunEvent.fromLogRow(Map<String, dynamic>.from(row)),
        );
      }
    }
    final workerLogRows = json['worker_log_rows'];
    if (workerLogRows is Map) {
      for (final value in workerLogRows.values) {
        if (value is! List) continue;
        for (final row in value.whereType<Map>()) {
          events.add(
            CollectionRunEvent.fromLogRow(Map<String, dynamic>.from(row)),
          );
        }
      }
    }
    return events.where((event) => event.isVisible).toList();
  }

  static int _refreshMs(Object? raw) {
    final value = int.tryParse(raw?.toString() ?? '');
    if (value == null || value < 1000) return 3000;
    return value;
  }

  static String _progressText(Map<String, dynamic> json) {
    final progress = json['progress'];
    if (progress is Map) {
      final text = progress['text']?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    final processed = json['processed_count'] ?? json['completed_targets'];
    final success = json['success_count'];
    final failure = json['failure_count'];
    if (processed != null) {
      final parts = <String>['已处理 $processed'];
      if (success != null) parts.add('成功 $success');
      if (failure != null) parts.add('失败 $failure');
      return parts.join(' · ');
    }
    final lastMessage = json['last_message']?.toString().trim() ?? '';
    if (lastMessage.isNotEmpty) return lastMessage;
    return '';
  }
}

/// 单次拉取后的客户端上限：事件已按时间新→旧排序，取前 [maxEvents] 条。
class CollectionRunLogTail {
  CollectionRunLogTail._();

  static const maxEvents = 100;

  static List<CollectionRunEvent> takeLatest(
    List<CollectionRunEvent> events, {
    int limit = maxEvents,
  }) {
    final cap = limit < 1 ? maxEvents : limit;
    if (events.length <= cap) return List<CollectionRunEvent>.of(events);
    return events.take(cap).toList();
  }
}
