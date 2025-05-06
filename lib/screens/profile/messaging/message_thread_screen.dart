import 'package:flutter/material.dart';
import '../../../controllers/messaging_controller.dart';
import '../../../models/messaging/message.dart';
import '../../../services/auth_service.dart';
import '../../../models/user/user_brief.dart';
import 'dart:math' as math;

class MessageThreadScreen extends StatefulWidget {
  final String threadId;

  const MessageThreadScreen({super.key, required this.threadId});

  @override
  _MessageThreadScreenState createState() => _MessageThreadScreenState();
}

class _MessageThreadScreenState extends State<MessageThreadScreen> {
  final MessagingController _messagingController = MessagingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isSending = false;
  MessageThread? _thread;
  List<Message> _messages = [];
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService().currentUserId;
    _loadData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 加载会话详情
      final threads = await _messagingController.getMessageThreads();
      _thread = threads.firstWhere(
        (t) => t.id == widget.threadId,
        orElse: () => threads.first, // 默认使用第一个会话
      );

      // 加载消息记录
      _messages = await _messagingController.getMessages(widget.threadId);

      // 标记会话为已读
      await _messagingController.markThreadAsRead(widget.threadId);

      // 滚动到底部
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载消息失败: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await _messagingController.sendMessage(widget.threadId, text);

      // 模拟添加新消息
      final newMessage = Message(
        id: 'msg${math.Random().nextInt(1000)}',
        threadId: widget.threadId,
        sender: UserBrief(
          id: _currentUserId,
          name: AuthService().currentUsername,
          avatarUrl: "https://randomuser.me/api/portraits/men/32.jpg",
        ),
        content: text,
        timestamp: DateTime.utc(2025, 4, 30, 0, 37, 21), // 当前时间
        messageType: 'text',
        isRead: true,
      );

      setState(() {
        _messages.add(newMessage);
      });

      // 滚动到底部
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('发送消息失败: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _thread != null ? Text(_thread!.title) : Text('消息'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              // 显示会话详情
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child:
                        _messages.isEmpty
                            ? _buildEmptyMessages()
                            : _buildMessagesList(),
                  ),
                  _buildMessageInput(),
                ],
              ),
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            '没有消息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text('开始发送消息吧', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isCurrentUser = message.sender.id == _currentUserId;

        // 计算是否需要显示时间
        bool showTime =
            index == 0 ||
            _shouldShowTime(_messages[index - 1].timestamp, message.timestamp);

        return Column(
          children: [
            if (showTime) _buildTimeDivider(message.timestamp),
            _buildMessageItem(message, isCurrentUser),
          ],
        );
      },
    );
  }

  bool _shouldShowTime(DateTime previous, DateTime current) {
    return current.difference(previous).inMinutes > 15;
  }

  Widget _buildTimeDivider(DateTime time) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider()),
          SizedBox(width: 8),
          Text(
            _formatMessageTime(time),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          SizedBox(width: 8),
          Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message message, bool isCurrentUser) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: EdgeInsets.only(
          bottom: 16,
          right: isCurrentUser ? 0 : 40,
          left: isCurrentUser ? 40 : 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isCurrentUser) ...[
              CircleAvatar(
                backgroundImage:
                    message.sender.avatarUrl != null
                        ? NetworkImage(message.sender.avatarUrl!)
                        : null,
                radius: 16,
                child:
                    message.sender.avatarUrl == null
                        ? Icon(Icons.person, size: 12)
                        : null,
              ),
              SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isCurrentUser
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomLeft:
                        isCurrentUser
                            ? Radius.circular(16)
                            : Radius.circular(4),
                    bottomRight:
                        isCurrentUser
                            ? Radius.circular(4)
                            : Radius.circular(16),
                  ),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color:
                        isCurrentUser ? Colors.green.shade900 : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: () {
                // 显示更多功能菜单
              },
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: '输入消息...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.send,
                color:
                    _messageController.text.trim().isEmpty
                        ? Colors.grey
                        : Colors.green,
              ),
              onPressed:
                  _messageController.text.trim().isEmpty || _isSending
                      ? null
                      : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    // 当前日期为 2025-04-30 00:46:20 UTC
    final now = DateTime.utc(2025, 4, 30, 0, 46, 20);
    final today = DateTime.utc(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime.utc(time.year, time.month, time.day);

    if (messageDate == today) {
      return '今天 ${_padZero(time.hour)}:${_padZero(time.minute)}';
    } else if (messageDate == yesterday) {
      return '昨天 ${_padZero(time.hour)}:${_padZero(time.minute)}';
    } else if (now.difference(time).inDays < 7) {
      return '${_getDayOfWeek(time.weekday)} ${_padZero(time.hour)}:${_padZero(time.minute)}';
    } else {
      return '${time.year}-${_padZero(time.month)}-${_padZero(time.day)} ${_padZero(time.hour)}:${_padZero(time.minute)}';
    }
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return '星期一';
      case 2:
        return '星期二';
      case 3:
        return '星期三';
      case 4:
        return '星期四';
      case 5:
        return '星期五';
      case 6:
        return '星期六';
      case 7:
        return '星期日';
      default:
        return '';
    }
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}
