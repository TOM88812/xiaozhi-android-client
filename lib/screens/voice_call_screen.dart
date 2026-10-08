import 'package:flutter/material.dart' hide Text;
import 'package:ai_assistant/l10n/localized_text.dart';
import 'package:ai_assistant/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ai_assistant/models/conversation.dart';
import 'package:ai_assistant/models/message.dart';
import 'package:ai_assistant/models/xiaozhi_config.dart';
import 'package:ai_assistant/providers/conversation_provider.dart';
import 'package:ai_assistant/services/xiaozhi_service.dart';
import 'dart:async';
import 'dart:io';

class VoiceCallScreen extends StatefulWidget {
  final Conversation conversation;
  final XiaozhiConfig xiaozhiConfig;

  const VoiceCallScreen({
    super.key,
    required this.conversation,
    required this.xiaozhiConfig,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen>
    with SingleTickerProviderStateMixin {
  late XiaozhiService _xiaozhiService;
  bool _isConnected = false;
  bool _isSpeaking = false;
  String _statusText = '正在连接...';
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  bool _serverReady = false;

  late AnimationController _animationController;
  final List<double> _audioLevels = List.filled(30, 0.05);
  Timer? _audioVisualizerTimer;

  @override
  void initState() {
    super.initState();

    // 设置状态栏为透明并使图标为白色
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    // 在帧绘制后再次设置系统UI样式，避免被覆盖
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      );
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // 获取XiaozhiService实例
    _xiaozhiService = XiaozhiService(
      websocketUrl: widget.xiaozhiConfig.websocketUrl,
      macAddress: widget.xiaozhiConfig.macAddress,
      token: widget.xiaozhiConfig.token,
      sessionId: widget.conversation.id,
    );

    // 设置消息监听器
    _xiaozhiService.setMessageListener(_handleServerMessage);

    // 连接并切换到语音通话模式
    _connectToVoiceService();
    _startAudioVisualizer();
  }

  void _handleServerMessage(dynamic message) {
    // 处理服务器发来的消息
    if (message is Map<String, dynamic> && message['type'] == 'hello') {
      print('收到服务器hello消息: $message');
      setState(() {
        _serverReady = true;
      });

      // 服务器准备好后延迟短暂时间再自动开始录音
      // 这样可以确保会话ID已经被正确设置
      if (_isConnected && !_isSpeaking) {
        // 延迟1秒，确保服务端和客户端都已准备就绪
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted && _isConnected && !_isSpeaking) {
            print('准备开始录音...');
            _startSpeaking();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    // 切换回普通聊天模式
    _xiaozhiService.switchToChatMode();
    _callTimer?.cancel();
    _audioVisualizerTimer?.cancel();
    _animationController.dispose();

    // 确保停止所有音频播放
    _xiaozhiService.stopPlayback();

    super.dispose();
  }

  void _connectToVoiceService() async {
    setState(() {
      _statusText = '正在准备...';
    });

    try {
      // 切换到语音通话模式
      await _xiaozhiService.switchToVoiceCallMode();

      setState(() {
        _statusText = '已连接';
        _isConnected = true;
      });

      // 显示连接成功的提示
      if (mounted) {
        _showCustomSnackbar(
          message: '已进入语音通话模式',
          icon: Icons.check_circle,
          iconColor: Colors.greenAccent,
        );
      }

      _startCallTimer();

      // 添加会话消息
      Provider.of<ConversationProvider>(context, listen: false).addMessage(
        conversationId: widget.conversation.id,
        role: MessageRole.assistant,
        content: '语音通话已开始',
      );

      // 直接开始录音
      _startSpeaking();
    } catch (e) {
      setState(() {
        _statusText = '准备失败';
        _isConnected = false;
      });
      print('准备失败: $e');

      if (mounted) {
        _showCustomSnackbar(
          message: '进入语音通话模式失败: $e',
          icon: Icons.error_outline,
          iconColor: Colors.redAccent,
        );
      }
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration = Duration(seconds: timer.tick);
      });
    });
  }

  void _startAudioVisualizer() {
    _audioVisualizerTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (_isConnected) {
        setState(() {
          // Simulate audio levels
          for (int i = 0; i < _audioLevels.length - 1; i++) {
            _audioLevels[i] = _audioLevels[i + 1];
          }

          if (_isSpeaking) {
            _audioLevels[_audioLevels.length - 1] =
                0.05 + (0.6 * (0.5 + 0.5 * _animationController.value));
          } else {
            _audioLevels[_audioLevels.length - 1] =
                0.05 + (0.1 * (0.5 + 0.5 * _animationController.value));
          }
        });
      }
    });
  }

  // 开始录音
  void _startSpeaking() {
    if (!_isSpeaking) {
      setState(() {
        _isSpeaking = true;
      });

      try {
        // 开始录音并订阅音频流
        _xiaozhiService
            .startListeningCall()
            .then((_) {
              if (mounted) {
                _showCustomSnackbar(
                  message: '正在录音...',
                  icon: Icons.mic,
                  iconColor: Colors.greenAccent,
                );
              }
            })
            .catchError((e) {
              print('开始录音失败: $e');
              // 如果失败，恢复状态
              if (mounted) {
                setState(() {
                  _isSpeaking = false;
                });

                _showCustomSnackbar(
                  message: '开始录音失败: $e',
                  icon: Icons.error,
                  iconColor: Colors.redAccent,
                );
              }
            });
      } catch (e) {
        print('开始录音失败: $e');
        // 如果失败，恢复状态
        setState(() {
          _isSpeaking = false;
        });

        if (mounted) {
          _showCustomSnackbar(
            message: '开始录音失败: $e',
            icon: Icons.error,
            iconColor: Colors.redAccent,
          );
        }
      }
    }
  }

  // 发送打断消息
  void _sendAbortMessage() {
    // 发送打断消息
    _xiaozhiService.sendAbortMessage();

    if (mounted) {
      _showCustomSnackbar(
        message: '已发送打断信号',
        icon: Icons.pan_tool,
        iconColor: Colors.orangeAccent,
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // 确保状态栏设置正确
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        leading: Container(
          margin: const EdgeInsets.only(left: 8, top: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () {
              // 返回前停止播放
              _xiaozhiService.stopPlayback();
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 渐变背景
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.primary.withOpacity(0.6),
                ],
              ),
            ),
          ),

          // 水波纹背景
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/wave_pattern.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 主要内容
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 圆形头像
                Hero(
                  tag: 'avatar_${widget.conversation.id}',
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.9),
                          Theme.of(context).colorScheme.primaryContainer,
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 名称显示
                Text(
                  widget.conversation.title,
                  localize: false,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // 状态显示 - 使用拟物化样式
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _isConnected
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          _isConnected
                              ? Colors.green.withOpacity(0.6)
                              : Colors.red.withOpacity(0.6),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            _isConnected
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isConnected ? Icons.check_circle : Icons.error_outline,
                        color: _isConnected ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isSpeaking
                            ? '${context.tr(_statusText)} (${context.tr("正在录音")})'
                            : context.tr(_statusText),
                        style: TextStyle(
                          color: _isConnected ? Colors.green : Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 通话时长
                Text(
                  '通话时长: ${_formatDuration(_callDuration)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                // 音频可视化
                _buildAudioVisualizer(),
                const SizedBox(height: 60),

                // 通话控制按钮
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildEndCallButton(),
                      const SizedBox(width: 40),
                      _buildControlButton(
                        icon: Icons.pan_tool, // 改为手掌图标表示打断
                        color: Colors.white,
                        backgroundColor: Colors.orange,
                        onPressed: _sendAbortMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioVisualizer() {
    return Container(
      width: 240,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          _audioLevels.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            curve: Curves.easeInOut,
            width: 4,
            height: 80 * _audioLevels[index],
            decoration: BoxDecoration(
              color: _getBarColor(index, _audioLevels[index]),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBarColor(int index, double level) {
    if (_isSpeaking) {
      // 渐变从蓝色到绿色
      double position = index / _audioLevels.length;
      return Color.lerp(
        Colors.blue.shade400,
        Colors.green.shade400,
        position,
      )!.withOpacity(0.7 + 0.3 * level);
    } else {
      // 非说话状态时使用柔和的蓝色
      return Colors.blue.shade200.withOpacity(0.3 + 0.4 * level);
    }
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    double size = 56,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(child: Icon(icon, color: color, size: size * 0.45)),
        ),
      ),
    );
  }

  Widget _buildEndCallButton() {
    return GestureDetector(
      onTap: () async {
        // 先发送打断消息
        await _xiaozhiService.sendAbortMessage();
        // 然后返回上一级页面
        Navigator.pop(context);
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade400.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.call_end_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  // 显示自定义Snackbar
  void _showCustomSnackbar({
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black87,
      duration: const Duration(seconds: 3),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 120,
        left: 16,
        right: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
