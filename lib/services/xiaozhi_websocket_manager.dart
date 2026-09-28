import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
// 尝试导入io.dart，但在web平台会抛出异常
import 'package:web_socket_channel/io.dart'
    if (dart.library.html) 'package:web_socket_channel/html.dart';

/// 小智WebSocket事件类型
enum XiaozhiEventType { connected, disconnected, message, error, binaryMessage }

/// 小智WebSocket事件
class XiaozhiEvent {
  final XiaozhiEventType type;
  final dynamic data;

  XiaozhiEvent({required this.type, this.data});
}

/// 小智WebSocket监听器接口
typedef XiaozhiWebSocketListener = void Function(XiaozhiEvent event);

/// 小智WebSocket管理器
class XiaozhiWebSocketManager {
  static const String TAG = "XiaozhiWebSocket";
  static const int RECONNECT_DELAY = 3000; // 3秒后重连

  WebSocketChannel? _channel;
  String? _serverUrl;
  String? _deviceId;
  String? _token;
  bool _enableToken;

  final List<XiaozhiWebSocketListener> _listeners = [];
  bool _isReconnecting = false;
  Timer? _reconnectTimer;
  StreamSubscription? _streamSubscription;

  /// 构造函数
  XiaozhiWebSocketManager({required String deviceId, bool enableToken = false})
    : _deviceId = deviceId,
      _enableToken = enableToken;

  /// 添加事件监听器
  void addListener(XiaozhiWebSocketListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  /// 移除事件监听器
  void removeListener(XiaozhiWebSocketListener listener) {
    _listeners.remove(listener);
  }

  /// 分发事件到所有监听器
  void _dispatchEvent(XiaozhiEvent event) {
    for (var listener in _listeners) {
      listener(event);
    }
  }

  /// 连接到WebSocket服务器
  Future<void> connect(String url, String token) async {
    if (url.isEmpty) {
      _dispatchEvent(
        XiaozhiEvent(type: XiaozhiEventType.error, data: "WebSocket地址不能为空"),
      );
      return;
    }

    // 保存连接参数
    _serverUrl = url;
    _token = token;

    // 如果已连接，先断开
    if (_channel != null) {
      await disconnect();
    }

    try {
      // 创建WebSocket连接
      Uri uri = Uri.parse(url);

      print('$TAG: 正在连接 $url');
      print('$TAG: 设备ID: $_deviceId');
      print('$TAG: Token启用: $_enableToken');

      if (_enableToken) {
        print('$TAG: 使用Token: $token');
      }

      // 尝试使用headers (这在非Web平台上有效)
      try {
        // 创建headers
        Map<String, dynamic> headers = {
          'device-id': _deviceId ?? '',
          'client-id': _deviceId ?? '',
          'protocol-version': '1',
        };

        // 添加Authorization头
        if (token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
          print('$TAG: 添加Authorization头: Bearer $token');
        } else {
          headers['Authorization'] = 'Bearer test-token';
        }

        // 使用IOWebSocketChannel并传递headers
        _channel = IOWebSocketChannel.connect(uri, headers: headers);

        print('$TAG: 使用headers方式连接WebSocket成功');
      } catch (e) {
        // 如果不支持IOWebSocketChannel（web平台），则回退到使用基本连接
        print('$TAG: 不支持使用headers方式，回退到基本连接: $e');

        // 创建基本连接
        _channel = WebSocketChannel.connect(uri);

        // 在连接成功后作为第一条消息发送认证信息
        Timer(Duration(milliseconds: 100), () {
          if (_channel != null && isConnected) {
            // 发送认证信息作为第一条消息
            String authMessage = 'Authorization: Bearer ${token.isNotEmpty ? token : "test-token"}';
            _channel!.sink.add(authMessage);
            print('$TAG: 发送认证消息: $authMessage');

            String deviceIdMessage = 'Device-ID: $_deviceId';
            _channel!.sink.add(deviceIdMessage);
            print('$TAG: 发送设备ID消息: $deviceIdMessage');
          }
        });
      }

      // 监听WebSocket事件
      _streamSubscription = _channel!.stream.listen(
        _onMessage,
        onDone: _onDisconnected,
        onError: _onError,
        cancelOnError: false,
      );

      // 连接成功后发送Hello消息
      _dispatchEvent(
        XiaozhiEvent(type: XiaozhiEventType.connected, data: null),
      );

      // 在发送认证信息之后发送Hello消息
      Timer(Duration(milliseconds: 200), () {
        _sendHelloMessage();
      });

      print('$TAG: 已连接到 $uri');
    } catch (e) {
      print('$TAG: 连接失败: $e');
      _dispatchEvent(
        XiaozhiEvent(type: XiaozhiEventType.error, data: "创建WebSocket失败: $e"),
      );
    }
  }

  /// 断开WebSocket连接
  Future<void> disconnect() async {
    // 取消重连
    _reconnectTimer?.cancel();
    _isReconnecting = false;

    // 取消订阅
    await _streamSubscription?.cancel();
    _streamSubscription = null;

    // 关闭连接
    if (_channel != null) {
      await _channel!.sink.close(status.normalClosure);
      _channel = null;
      print('$TAG: 连接已断开');
    }
  }

  /// 发送Hello消息
  void _sendHelloMessage() {
    final hello = {
      "type": "hello",
      "version": 1,
      "transport": "websocket",
      "audio_params": {
        "format": "opus",
        "sample_rate": 16000,
        "channels": 1,
        "frame_duration": 60,
      },
    };

    sendMessage(jsonEncode(hello));
  }

  /// 发送文本消息
  void sendMessage(String message) {
    if (_channel != null && isConnected) {
      _channel!.sink.add(message);
    } else {
      print('$TAG: 发送失败，连接未建立');
    }
  }

  /// 发送二进制数据
  void sendBinaryMessage(List<int> data) {
    if (_channel != null && isConnected) {
      // 调试：打印前20个字节的十六进制表示
      if (data.length > 0) {
        String hexData = '';
        for (int i = 0; i < data.length && i < 20; i++) {
          hexData += '${data[i].toRadixString(16).padLeft(2, '0')} ';
        }
      }

      try {
        _channel!.sink.add(data);
      } catch (e) {
        print('$TAG: 二进制数据发送失败: $e');
      }
    } else {
      print('$TAG: 发送失败，连接未建立');
    }
  }

  /// 发送文本请求
  void sendTextRequest(String text) {
    if (!isConnected) {
      print('$TAG: 发送失败，连接未建立');
      return;
    }

    try {
      // 构造消息格式，与Java实现保持一致
      final jsonMessage = {
        "type": "listen",
        "state": "detect",
        "text": text,
        "source": "text",
      };

      print('$TAG: 发送文本请求: ${jsonEncode(jsonMessage)}');
      sendMessage(jsonEncode(jsonMessage));
    } catch (e) {
      print('$TAG: 发送文本请求失败: $e');
    }
  }

  /// 处理收到的消息
  void _onMessage(dynamic message) {
    if (message is String) {
      // 文本消息
      print('$TAG: 收到消息: $message');
      _dispatchEvent(
        XiaozhiEvent(type: XiaozhiEventType.message, data: message),
      );
    } else if (message is List<int>) {
      // 二进制消息
      _dispatchEvent(
        XiaozhiEvent(type: XiaozhiEventType.binaryMessage, data: message),
      );
    }
  }

  /// 处理断开连接事件
  void _onDisconnected() {
    print('$TAG: 连接已断开');
    _dispatchEvent(
      XiaozhiEvent(type: XiaozhiEventType.disconnected, data: null),
    );

    // 尝试自动重连
    if (!_isReconnecting && _serverUrl != null && _token != null) {
      _isReconnecting = true;
      _reconnectTimer = Timer(
        const Duration(milliseconds: RECONNECT_DELAY),
        () {
          _isReconnecting = false;
          if (_serverUrl != null && _token != null) {
            connect(_serverUrl!, _token!);
          }
        },
      );
    }
  }

  /// 处理错误事件
  void _onError(error) {
    print('$TAG: 错误: $error');
    _dispatchEvent(
      XiaozhiEvent(type: XiaozhiEventType.error, data: error.toString()),
    );
  }

  /// 判断是否已连接
  bool get isConnected {
    return _channel != null && _streamSubscription != null;
  }
}
