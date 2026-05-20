import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../services/xiaozhi_websocket_manager.dart';
import '../utils/device_util.dart';
import '../utils/audio_util.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// 小智服务事件类型
enum XiaozhiServiceEventType {
  connected,
  disconnected,
  textMessage,
  audioData,
  error,
  voiceCallStart,
  voiceCallEnd,
  userMessage,
}

/// 小智服务事件
class XiaozhiServiceEvent {
  final XiaozhiServiceEventType type;
  final dynamic data;

  XiaozhiServiceEvent(this.type, this.data);
}

/// 小智服务监听器
typedef XiaozhiServiceListener = void Function(XiaozhiServiceEvent event);

/// 消息监听器
typedef MessageListener = void Function(dynamic message);

/// 小智服务
class XiaozhiService {
  static const String TAG = "XiaozhiService";
  static const String DEFAULT_SERVER = "wss://api.tenclass.net/xiaozhi/v1/";

  // 单例实例
  static XiaozhiService? _instance;

  final String websocketUrl;
  final String macAddress;
  final String token;
  String? _sessionId; // 会话ID将由服务器提供

  XiaozhiWebSocketManager? _webSocketManager;
  bool _isConnected = false;
  bool _isMuted = false;
  final List<XiaozhiServiceListener> _listeners = [];
  StreamSubscription? _audioStreamSubscription;
  bool _isVoiceCallActive = false;
  WebSocketChannel? _ws;
  bool _hasStartedCall = false;
  MessageListener? _messageListener;

  /// 工厂构造函数，实现单例模式
  factory XiaozhiService({
    required String websocketUrl,
    required String macAddress,
    required String token,
    String? sessionId,
  }) {
    _instance ??= XiaozhiService._internal(
      websocketUrl: websocketUrl,
      macAddress: macAddress,
      token: token,
      sessionId: sessionId,
    );
    return _instance!;
  }

  /// 内部构造函数
  XiaozhiService._internal({
    required this.websocketUrl,
    required this.macAddress,
    required this.token,
    String? sessionId,
  }) {
    _sessionId = sessionId;
    _init();
  }

  /// 获取实例
  static XiaozhiService? get instance => _instance;

  /// 切换到语音通话模式
  Future<void> switchToVoiceCallMode() async {
    // 如果已经在语音通话模式，直接返回
    if (_isVoiceCallActive) return;

    try {
      print('$TAG: 正在切换到语音通话模式');

      // 简化初始化流程，确保干净状态
      await AudioUtil.stopPlaying();
      await AudioUtil.initRecorder();
      await AudioUtil.initPlayer();

      _isVoiceCallActive = true;
      print('$TAG: 已切换到语音通话模式');
    } catch (e) {
      print('$TAG: 切换到语音通话模式失败: $e');
      rethrow;
    }
  }

  /// 切换到普通聊天模式
  Future<void> switchToChatMode() async {
    // 如果已经在普通聊天模式，直接返回
    if (!_isVoiceCallActive) return;

    try {
      print('$TAG: 正在切换到普通聊天模式');

      // 停止语音通话相关的活动
      await stopListeningCall();

      // 确保播放器停止
      await AudioUtil.stopPlaying();

      _isVoiceCallActive = false;
      print('$TAG: 已切换到普通聊天模式');
    } catch (e) {
      print('$TAG: 切换到普通聊天模式失败: $e');
      _isVoiceCallActive = false;
    }
  }

  /// 初始化
  Future<void> _init() async {
    // 使用配置中的MAC地址作为设备ID
    print('$TAG: 初始化完成，使用MAC地址作为设备ID: $macAddress');

    // 初始化WebSocket管理器，启用 token
    _webSocketManager = XiaozhiWebSocketManager(
      deviceId: macAddress,
      enableToken: true,
    );

    // 添加WebSocket事件监听
    _webSocketManager!.addListener(_onWebSocketEvent);

    // 初始化音频工具
    await AudioUtil.initRecorder();
    await AudioUtil.initPlayer();
  }

  /// 设置消息监听器
  void setMessageListener(MessageListener listener) {
    _messageListener = listener;
  }

  /// 添加事件监听器
  void addListener(XiaozhiServiceListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  /// 移除事件监听器
  void removeListener(XiaozhiServiceListener listener) {
    _listeners.remove(listener);
  }

  /// 分发事件到所有监听器
  void _dispatchEvent(XiaozhiServiceEvent event) {
    for (var listener in _listeners) {
      listener(event);
    }
  }

  /// 连接到小智服务
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      print('$TAG: 开始连接服务器...');

      // 创建WebSocket管理器
      _webSocketManager = XiaozhiWebSocketManager(
        deviceId: macAddress,
        enableToken: true,
      );

      // 添加WebSocket事件监听
      _webSocketManager!.addListener(_onWebSocketEvent);

      // 连接WebSocket
      await _webSocketManager!.connect(websocketUrl, token);
    } catch (e) {
      print('$TAG: 连接失败: $e');
      _dispatchEvent(
        XiaozhiServiceEvent(XiaozhiServiceEventType.error, '连接小智服务失败: $e'),
      );
    }
  }

  /// 断开小智服务连接
  Future<void> disconnect() async {
    if (!_isConnected || _webSocketManager == null) return;

    try {
      // 取消音频流订阅
      await _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;

      // 停止音频录制
      if (AudioUtil.isRecording) {
        await AudioUtil.stopRecording();
      }

      // 断开WebSocket连接
      await _webSocketManager!.disconnect();
      _webSocketManager = null;
      _isConnected = false;
    } catch (e) {
      print('$TAG: 断开连接失败: $e');
    }
  }

  /// 发送文本消息
  Future<String> sendTextMessage(String message) async {
    if (!_isConnected && _webSocketManager == null) {
      await connect();
    }

    try {
      // 创建一个Completer来等待响应
      final completer = Completer<String>();
      bool hasResponse = false;

      print('$TAG: 开始发送文本消息: $message');

      // 添加消息监听器，监听所有可能的回复
      void onceListener(XiaozhiServiceEvent event) {
        if (event.type == XiaozhiServiceEventType.textMessage) {
          // 忽略echo消息（即我们发送的消息）
          if (event.data == message) {
            print('$TAG: 忽略echo消息: ${event.data}');
            return;
          }

          print('$TAG: 收到服务器响应: ${event.data}');
          if (!completer.isCompleted) {
            hasResponse = true;
            completer.complete(event.data as String);
            removeListener(onceListener);
          }
        } else if (event.type == XiaozhiServiceEventType.error &&
            !completer.isCompleted) {
          print('$TAG: 收到错误响应: ${event.data}');
          completer.completeError(event.data.toString());
          removeListener(onceListener);
        }
      }

      // 先添加监听器，确保不会错过任何消息
      addListener(onceListener);

      // 发送文本请求
      print('$TAG: 发送文本请求: $message');
      _webSocketManager!.sendTextRequest(message);

      // 设置超时，15秒比10秒更宽松一些
      final timeoutTimer = Timer(const Duration(seconds: 15), () {
        if (!completer.isCompleted) {
          print('$TAG: 请求超时，15秒内没有收到响应');
          completer.completeError('请求超时');
          removeListener(onceListener);
        }
      });

      // 等待响应
      try {
        final result = await completer.future;
        // 取消超时定时器
        timeoutTimer.cancel();
        return result;
      } catch (e) {
        // 取消超时定时器
        timeoutTimer.cancel();
        rethrow;
      }
    } catch (e) {
      print('$TAG: 发送消息失败: $e');
      rethrow;
    }
  }

  /// 连接语音通话
  Future<void> connectVoiceCall() async {
    try {
      // 简化流程，确保权限和音频准备就绪
      if (Platform.isIOS || Platform.isAndroid) {
        final status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          print('$TAG: 麦克风权限被拒绝');
          _dispatchEvent(
            XiaozhiServiceEvent(XiaozhiServiceEventType.error, '麦克风权限被拒绝'),
          );
          return;
        }
      }

      // 初始化音频系统
      await AudioUtil.stopPlaying();
      await AudioUtil.initRecorder();
      await AudioUtil.initPlayer();

      print('$TAG: 正在连接 $websocketUrl');
      print('$TAG: 设备ID: $macAddress');
      print('$TAG: Token启用: true');
      print('$TAG: 使用Token: $token');

      // 使用 WebSocketManager 连接
      _webSocketManager = XiaozhiWebSocketManager(
        deviceId: macAddress,
        enableToken: true,
      );
      _webSocketManager!.addListener(_onWebSocketEvent);
      await _webSocketManager!.connect(websocketUrl, token);
    } catch (e) {
      print('$TAG: 连接失败: $e');
      rethrow;
    }
  }

  /// 结束语音通话
  Future<void> disconnectVoiceCall() async {
    if (_webSocketManager == null) return;

    try {
      // 停止音频录制
      if (AudioUtil.isRecording) {
        await AudioUtil.stopRecording();
      }

      // 停止音频播放
      await AudioUtil.stopPlaying();

      // 取消音频流订阅
      await _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;

      // 直接断开连接
      await disconnect();
    } catch (e) {
      // 忽略断开连接时的错误
      print('$TAG: 结束语音通话时发生错误: $e');
    }
  }

  /// 开始说话
  Future<void> startSpeaking() async {
    try {
      final message = {'type': 'speak', 'state': 'start', 'mode': 'auto'};
      _webSocketManager?.sendMessage(jsonEncode(message));
      print('$TAG: 已发送开始说话消息');
    } catch (e) {
      print('$TAG: 开始说话失败: $e');
    }
  }

  /// 停止说话
  Future<void> stopSpeaking() async {
    try {
      final message = {'type': 'speak', 'state': 'stop', 'mode': 'auto'};
      _webSocketManager?.sendMessage(jsonEncode(message));
      print('$TAG: 已发送停止说话消息');
    } catch (e) {
      print('$TAG: 停止说话失败: $e');
    }
  }

  /// 发送listen消息
  void _sendListenMessage() async {
    try {
      final listenMessage = {
        'type': 'listen',
        'session_id': _sessionId,
        'state': 'start',
        'mode': 'auto',
      };
      _webSocketManager?.sendMessage(jsonEncode(listenMessage));
      print('$TAG: 已发送listen消息');

      // 开始录音
      _isVoiceCallActive = true;
      await AudioUtil.startRecording();
    } catch (e) {
      print('$TAG: 发送listen消息失败: $e');
      _dispatchEvent(
        XiaozhiServiceEvent(XiaozhiServiceEventType.error, '发送listen消息失败: $e'),
      );
    }
  }

  /// 开始听说（语音通话模式）
  Future<void> startListeningCall() async {
    try {
      // 确保已经有会话ID
      if (_sessionId == null) {
        print('$TAG: 没有会话ID，无法开始监听，等待会话ID初始化...');
        // 等待短暂时间，然后重新检查会话ID
        await Future.delayed(const Duration(milliseconds: 500));
        if (_sessionId == null) {
          print('$TAG: 会话ID仍然为空，放弃开始监听');
          throw Exception('会话ID为空，无法开始录音');
        }
      }

      print('$TAG: 使用会话ID开始录音: $_sessionId');

      // 请求麦克风权限
      if (Platform.isIOS) {
        final micStatus = await Permission.microphone.status;
        if (micStatus != PermissionStatus.granted) {
          final result = await Permission.microphone.request();
          if (result != PermissionStatus.granted) {
            print('$TAG: 麦克风权限被拒绝');
            _dispatchEvent(
              XiaozhiServiceEvent(XiaozhiServiceEventType.error, '麦克风权限被拒绝'),
            );
            return;
          }
        }

        // 确保音频会话已初始化
        await AudioUtil.initRecorder();
      } else {
        // Android权限请求
        final status = await Permission.microphone.request();
        if (status.isDenied) {
          print('$TAG: 麦克风权限被拒绝');
          _dispatchEvent(
            XiaozhiServiceEvent(XiaozhiServiceEventType.error, '麦克风权限被拒绝'),
          );
          return;
        }
      }

      // 开始录音
      await AudioUtil.startRecording();

      // 设置音频流订阅
      _audioStreamSubscription = AudioUtil.audioStream.listen((opusData) {
        // 发送音频数据
        _webSocketManager?.sendBinaryMessage(opusData);
      });

      // 发送开始监听命令
      final message = {
        'session_id': _sessionId,
        'type': 'listen',
        'state': 'start',
        'mode': 'auto',
      };
      _webSocketManager?.sendMessage(jsonEncode(message));
      print('$TAG: 已发送开始监听消息 (语音通话模式)');
    } catch (e) {
      print('$TAG: 开始监听失败: $e');
      throw Exception('开始语音输入失败: $e');
    }
  }

  /// 停止听说（语音通话模式）
  Future<void> stopListeningCall() async {
    try {
      // 取消音频流订阅
      await _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;

      // 停止录音
      await AudioUtil.stopRecording();

      // 发送停止监听命令
      if (_sessionId != null && _webSocketManager != null) {
        final message = {
          'session_id': _sessionId,
          'type': 'listen',
          'state': 'stop',
          'mode': 'auto',
        };
        _webSocketManager?.sendMessage(jsonEncode(message));
        print('$TAG: 已发送停止监听消息 (语音通话模式)');
      }
    } catch (e) {
      print('$TAG: 停止监听失败: $e');
    }
  }

  /// 取消发送（上滑取消）
  Future<void> abortListening() async {
    try {
      // 取消音频流订阅
      await _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;

      // 停止录音
      await AudioUtil.stopRecording();

      // 发送中止命令
      if (_sessionId != null && _webSocketManager != null) {
        final message = {'session_id': _sessionId, 'type': 'abort'};
        _webSocketManager?.sendMessage(jsonEncode(message));
        print('$TAG: 已发送中止消息');
      }
    } catch (e) {
      print('$TAG: 中止监听失败: $e');
    }
  }

  /// 切换静音状态
  void toggleMute() {
    _isMuted = !_isMuted;

    if (_webSocketManager == null || !_webSocketManager!.isConnected) return;

    try {
      final request = {'type': _isMuted ? 'voice_mute' : 'voice_unmute'};

      _webSocketManager!.sendMessage(jsonEncode(request));
    } catch (e) {
      print('$TAG: 切换静音状态失败: $e');
    }
  }

  /// 处理WebSocket事件
  void _onWebSocketEvent(XiaozhiEvent event) {
    switch (event.type) {
      case XiaozhiEventType.connected:
        _isConnected = true;
        _dispatchEvent(
          XiaozhiServiceEvent(XiaozhiServiceEventType.connected, null),
        );
        break;

      case XiaozhiEventType.disconnected:
        _isConnected = false;
        _dispatchEvent(
          XiaozhiServiceEvent(XiaozhiServiceEventType.disconnected, null),
        );
        break;

      case XiaozhiEventType.message:
        _handleTextMessage(event.data as String);
        break;

      case XiaozhiEventType.binaryMessage:
        // 处理二进制音频数据 - 简化直接播放
        final audioData = event.data as List<int>;
        AudioUtil.playOpusData(Uint8List.fromList(audioData));
        break;

      case XiaozhiEventType.error:
        _dispatchEvent(
          XiaozhiServiceEvent(XiaozhiServiceEventType.error, event.data),
        );
        break;
    }
  }

  /// 处理WebSocket消息
  void _handleWebSocketMessage(dynamic message) {
    try {
      if (message is String) {
        _handleTextMessage(message);
      } else if (message is List<int>) {
        AudioUtil.playOpusData(Uint8List.fromList(message));
      }
    } catch (e) {
      print('$TAG: 处理消息失败: $e');
    }
  }

  /// 处理文本消息
  void _handleTextMessage(String message) {
    print('$TAG: 收到文本消息: $message');
    try {
      final Map<String, dynamic> jsonData = json.decode(message);
      final String type = jsonData['type'] ?? '';

      // 确保首先调用消息监听器
      if (_messageListener != null) {
        _messageListener!(jsonData);
      }

      // 更新会话ID（服务器在hello消息中会提供新的会话ID）
      if (jsonData['session_id'] != null) {
        _sessionId = jsonData['session_id'];
        print('$TAG: 更新会话ID: $_sessionId');
      }

      // 根据消息类型分发事件
      switch (type) {
        case 'hello':
          // 处理服务器的hello响应
          if (_isVoiceCallActive && !_hasStartedCall) {
            _hasStartedCall = true;
            // 发送自动说话模式消息
            startSpeaking();
          }
          break;

        case 'start':
          // 收到start响应后，如果是语音通话模式，开始录音
          if (_isVoiceCallActive) {
            _sendListenMessage();
          }
          break;

        case 'tts':
          // TTS消息处理
          final String state = jsonData['state'] ?? '';
          final String text = jsonData['text'] ?? '';

          if (state == 'sentence_start' && text.isNotEmpty) {
            print('$TAG: 收到TTS句子: $text');
            _dispatchEvent(
              XiaozhiServiceEvent(XiaozhiServiceEventType.textMessage, text),
            );
          }
          break;

        case 'stt':
          // 处理语音识别结果
          final String text = jsonData['text'] ?? '';
          if (text.isNotEmpty) {
            print('$TAG: 收到语音识别结果: $text');
            // 先分发用户消息事件
            _dispatchEvent(
              XiaozhiServiceEvent(XiaozhiServiceEventType.userMessage, text),
            );
          }
          break;

        case 'emotion':
          // 处理表情消息
          final String emotion = jsonData['emotion'] ?? '';
          if (emotion.isNotEmpty) {
            print('$TAG: 收到表情消息: $emotion');
            _dispatchEvent(
              XiaozhiServiceEvent(
                XiaozhiServiceEventType.textMessage,
                '表情: $emotion',
              ),
            );
          }
          break;

        default:
          // 对于其他类型的消息，直接忽略
          print('$TAG: 收到未知类型消息: $type, 原始数据: $message');
      }
    } catch (e) {
      print('$TAG: 解析消息失败: $e, 原始消息: $message');
    }
  }

  /// 开始通话
  void _startCall() {
    try {
      // 发送开始通话消息
      final startMessage = {
        'type': 'start',
        'mode': 'auto',
        'audio_params': {
          'format': 'opus',
          'sample_rate': 16000,
          'channels': 1,
          'frame_duration': 60,
        },
      };
      _webSocketManager?.sendMessage(jsonEncode(startMessage));
      print('$TAG: 已发送开始通话消息');
    } catch (e) {
      print('$TAG: 开始通话失败: $e');
    }
  }

  /// 中断音频播放
  Future<void> stopPlayback() async {
    try {
      print('$TAG: 正在停止音频播放');

      // 简单直接地停止播放
      await AudioUtil.stopPlaying();

      print('$TAG: 音频播放已停止');
    } catch (e) {
      print('$TAG: 停止音频播放失败: $e');
    }
  }

  /// 判断是否已连接
  bool get isConnected =>
      _isConnected &&
      _webSocketManager != null &&
      _webSocketManager!.isConnected;

  /// 判断是否静音
  bool get isMuted => _isMuted;

  /// 判断语音通话是否活跃
  bool get isVoiceCallActive => _isVoiceCallActive;

  /// 释放资源
  Future<void> dispose() async {
    await disconnect();
    await AudioUtil.dispose();
    _listeners.clear();
    print('$TAG: 资源已释放');
  }

  /// 开始监听（按住说话模式）
  Future<void> startListening({String mode = 'manual'}) async {
    if (!_isConnected || _webSocketManager == null) {
      await connect();
    }

    try {
      // 确保已经有会话ID
      if (_sessionId == null) {
        print('$TAG: 没有会话ID，无法开始监听');
        return;
      }

      // 开始录音
      await AudioUtil.startRecording();

      // 发送开始监听命令
      final message = {
        'session_id': _sessionId,
        'type': 'listen',
        'state': 'start',
        'mode': mode,
      };
      _webSocketManager?.sendMessage(jsonEncode(message));
      print('$TAG: 已发送开始监听消息 (按住说话)');

      // 设置音频流订阅
      _audioStreamSubscription = AudioUtil.audioStream.listen((opusData) {
        // 发送音频数据
        _webSocketManager?.sendBinaryMessage(opusData);
      });
    } catch (e) {
      print('$TAG: 开始监听失败: $e');
      throw Exception('开始语音输入失败: $e');
    }
  }

  /// 停止监听（按住说话模式）
  Future<void> stopListening() async {
    try {
      // 取消音频流订阅
      await _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;

      // 停止录音
      await AudioUtil.stopRecording();

      // 发送停止监听命令
      if (_sessionId != null && _webSocketManager != null) {
        final message = {
          'session_id': _sessionId,
          'type': 'listen',
          'state': 'stop',
        };
        _webSocketManager?.sendMessage(jsonEncode(message));
        print('$TAG: 已发送停止监听消息');
      }
    } catch (e) {
      print('$TAG: 停止监听失败: $e');
    }
  }

  /// 发送中断消息
  Future<void> sendAbortMessage() async {
    try {
      if (_webSocketManager != null && _isConnected && _sessionId != null) {
        final abortMessage = {
          'session_id': _sessionId,
          'type': 'abort',
          'reason': 'wake_word_detected',
        };
        _webSocketManager?.sendMessage(jsonEncode(abortMessage));
        print('$TAG: 发送中断消息: $abortMessage');

        // 如果当前正在录音，短暂停顿后继续
        if (_isSpeaking) {
          await stopListeningCall();
          await Future.delayed(const Duration(milliseconds: 500));
          await startListeningCall();
        }
      }
    } catch (e) {
      print('$TAG: 发送中断消息失败: $e');
    }
  }

  /// 判断是否正在说话
  bool get _isSpeaking => _audioStreamSubscription != null;
}
