import 'package:flutter/material.dart' hide Text;
import 'package:ai_assistant/l10n/localized_text.dart';
import 'package:ai_assistant/providers/config_provider.dart';
import 'package:ai_assistant/services/dify_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  TestScreenState createState() => TestScreenState();
}

class TestScreenState extends State<TestScreen> {
  final _logs = <String>[];
  bool _isTesting = false;
  final ScrollController _scrollController = ScrollController();
  static const String _conversationMapKey = 'dify_conversation_map';

  void _addLog(String log) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $log');
      // 限制日志行数
      if (_logs.length > 100) {
        _logs.removeRange(0, _logs.length - 100);
      }
    });

    // 滚动到底部
    Future.delayed(const Duration(milliseconds: 10), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _testConsistentSession() async {
    final config = Provider.of<ConfigProvider>(context, listen: false);

    if (config.difyConfig == null) {
      _addLog('错误: Dify API配置未设置!');
      return;
    }

    setState(() {
      _isTesting = true;
      _logs.clear();
    });

    _addLog('开始测试会话一致性...');

    try {
      // 创建一个测试会话ID
      final sessionId = const Uuid().v4();
      _addLog('使用会话ID: $sessionId');

      final difyService = await DifyService.create(
        apiKey: config.difyConfig!.apiKey,
        apiUrl: config.difyConfig!.apiUrl,
      );

      // 发送第一条消息
      _addLog('发送第一条消息');
      final response1 = await difyService.sendMessage(
        '这是测试消息1',
        sessionId: sessionId,
      );
      _addLog(
        '收到回复: ${response1.substring(0, math.min(20, response1.length))}...',
      );
      await _printCurrentSessions();

      // 等待一秒
      await Future.delayed(const Duration(seconds: 1));

      // 发送第二条消息
      _addLog('发送第二条消息');
      final response2 = await difyService.sendMessage(
        '这是测试消息2',
        sessionId: sessionId,
      );
      _addLog(
        '收到回复: ${response2.substring(0, math.min(20, response2.length))}...',
      );
      await _printCurrentSessions();

      // 等待一秒
      await Future.delayed(const Duration(seconds: 1));

      // 发送第三条消息
      _addLog('发送第三条消息');
      final response3 = await difyService.sendMessage(
        '这是测试消息3',
        sessionId: sessionId,
      );
      _addLog(
        '收到回复: ${response3.substring(0, math.min(20, response3.length))}...',
      );

      // 打印结果
      await _printCurrentSessions();

      _addLog('测试完成');
    } catch (e) {
      _addLog('测试失败: $e');
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _testResetSession() async {
    final config = Provider.of<ConfigProvider>(context, listen: false);

    if (config.difyConfig == null) {
      _addLog('错误: Dify API配置未设置!');
      return;
    }

    setState(() {
      _isTesting = true;
      _logs.clear();
    });

    _addLog('开始测试会话重置...');

    try {
      // 创建一个测试会话ID
      final sessionId = const Uuid().v4();
      _addLog('使用会话ID: $sessionId');

      final difyService = await DifyService.create(
        apiKey: config.difyConfig!.apiKey,
        apiUrl: config.difyConfig!.apiUrl,
      );

      // 先发送一条消息
      _addLog('发送重置前消息');
      final response1 = await difyService.sendMessage(
        '这是重置前的消息',
        sessionId: sessionId,
      );
      _addLog(
        '收到回复: ${response1.substring(0, math.min(20, response1.length))}...',
      );

      // 打印当前会话ID
      await _printCurrentSessions();

      // 重置会话
      _addLog('重置会话');
      await difyService.clearConversation(sessionId);

      // 打印重置后的会话ID
      await _printCurrentSessions();

      // 发送重置后的消息
      _addLog('发送重置后消息');
      final response2 = await difyService.sendMessage(
        '这是重置后的消息',
        sessionId: sessionId,
      );
      _addLog(
        '收到回复: ${response2.substring(0, math.min(20, response2.length))}...',
      );

      // 打印最终会话ID
      await _printCurrentSessions();

      _addLog('测试完成');
    } catch (e) {
      _addLog('测试失败: $e');
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _printStoredSessions() async {
    setState(() {
      _isTesting = true;
      _logs.clear();
    });

    _addLog('获取存储的会话ID...');

    try {
      await _printCurrentSessions();
      _addLog('完成');
    } catch (e) {
      _addLog('失败: $e');
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _printCurrentSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final mapJson = prefs.getString(_conversationMapKey);
    if (mapJson == null || mapJson.isEmpty) {
      _addLog('没有存储的会话ID');
      return;
    }

    final Map<String, dynamic> loadedMap = jsonDecode(mapJson);
    _addLog('存储的会话ID:');
    loadedMap.forEach((sessionId, conversationId) {
      _addLog('- 会话: $sessionId => 对话ID: $conversationId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dify会话ID测试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed:
                _logs.isEmpty ? null : () => setState(() => _logs.clear()),
            tooltip: '清除日志',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testConsistentSession,
                    child: const Text('测试会话一致性'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testResetSession,
                    child: const Text('测试会话重置'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _printStoredSessions,
                    child: const Text('查看存储的会话'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(child: _buildLogView()),
        ],
      ),
    );
  }

  Widget _buildLogView() {
    if (_logs.isEmpty) {
      return const Center(child: Text('没有日志，运行测试以查看结果。'));
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _logs.length,
            itemBuilder: (context, index) {
              return Text(
                _logs[index],
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: _getLogColor(_logs[index]),
                ),
              );
            },
          ),
        ),
        if (_isTesting)
          const Positioned.fill(
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Color _getLogColor(String log) {
    if (log.contains('错误') || log.contains('失败')) {
      return Colors.red;
    } else if (log.contains('完成') || log.contains('成功')) {
      return Colors.green;
    } else if (log.contains('会话') || log.contains('对话ID')) {
      return Colors.blue;
    } else {
      return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    }
  }
}
