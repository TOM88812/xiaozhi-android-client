import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ai_assistant/models/message.dart';
import 'package:provider/provider.dart';
import 'package:ai_assistant/providers/conversation_provider.dart';
import 'package:ai_assistant/models/conversation.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isThinking;
  final ConversationType? conversationType;

  const MessageBubble({
    super.key,
    required this.message,
    this.isThinking = false,
    this.conversationType,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final isSystem = message.role == MessageRole.system;

    // 系统消息使用不同的展示方式
    if (isSystem) {
      return _buildSystemMessage(context);
    }

    // 使用更高效的布局
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(context),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      message.isImage
                          ? const EdgeInsets.all(4)
                          : const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF4B5563) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        !isUser
                            ? Border.all(color: Colors.grey.shade200)
                            : null,
                  ),
                  // 检查是否为图片消息
                  child:
                      isThinking
                          ? _buildThinkingIndicator(context)
                          : message.isImage
                          ? _buildImageContent(context)
                          : Text(
                            message.content,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 15,
                              // 添加高性能的文本渲染选项
                              height: 1.3,
                              leadingDistribution: TextLeadingDistribution.even,
                            ),
                          ),
                ),
                const SizedBox(height: 4),
                if (message.timestamp != null)
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isUser) const SizedBox(width: 32, height: 32),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (message.role == MessageRole.user) {
      return const SizedBox(width: 32, height: 32);
    }

    final isDify = conversationType == ConversationType.dify;
    final isMinimax = conversationType == ConversationType.minimax;

    return CircleAvatar(
      radius: 16,
      backgroundColor:
          isMinimax
              ? Colors.teal.shade400
              : isDify
                  ? Colors.blue.shade400
                  : Colors.grey.shade700,
      child: Icon(
        isMinimax
            ? Icons.auto_awesome
            : isDify
                ? Icons.chat_bubble_outline
                : Icons.mic,
        size: isMinimax ? 16 : isDify ? 16 : 18,
        color: Colors.white,
      ),
    );
  }

  Widget _buildThinkingIndicator(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPulsatingDot(context, 0),
        _buildPulsatingDot(context, 1),
        _buildPulsatingDot(context, 2),
      ],
    );
  }

  Widget _buildPulsatingDot(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: _ThinkingDot(index: index, color: Colors.grey.shade600),
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  // 构建系统消息
  Widget _buildSystemMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.content,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  // 构建图片内容
  Widget _buildImageContent(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    // 检查是否有本地图片路径
    if (message.imageLocalPath != null && message.imageLocalPath!.isNotEmpty) {
      final imageFile = File(message.imageLocalPath!);
      if (!imageFile.existsSync()) {
        return _buildImagePlaceholder(isUser, "图片已被删除");
      }

      return Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              imageFile,
              width: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('图片加载失败: $error');
                return _buildImagePlaceholder(isUser, "图片加载失败");
              },
            ),
          ),
          if (message.content.isNotEmpty &&
              !message.content.startsWith("[图片上传中"))
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      );
    }

    return _buildImagePlaceholder(isUser, message.content);
  }

  Widget _buildImagePlaceholder(bool isUser, String message) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: isUser ? Colors.grey.shade700 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              color: isUser ? Colors.white70 : Colors.black45,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isUser ? Colors.white70 : Colors.black45,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThinkingDot extends StatefulWidget {
  final int index;
  final Color color;

  const _ThinkingDot({required this.index, required this.color});

  @override
  State<_ThinkingDot> createState() => _ThinkingDotState();
}

class _ThinkingDotState extends State<_ThinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    // 为每个点添加延迟，使动画不同步
    Future.delayed(Duration(milliseconds: 150 * widget.index), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            sin((_controller.value * 2 * pi) + (widget.index * 1.0)) * 4,
          ),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
