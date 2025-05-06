import 'package:flutter/material.dart';
import '../../../controllers/messaging_controller.dart';
import '../../../models/messaging/message.dart';
import '../../../models/messaging/notification.dart' as app_notification;

class MessagingCenterScreen extends StatefulWidget {
  const MessagingCenterScreen({super.key});

  @override
  _MessagingCenterScreenState createState() => _MessagingCenterScreenState();
}

class _MessagingCenterScreenState extends State<MessagingCenterScreen>
    with SingleTickerProviderStateMixin {
  final MessagingController _messagingController = MessagingController();
  late TabController _tabController;
  bool _isLoading = true;
  List<MessageThread> _threads = [];
  List<app_notification.Notification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _threads = await _messagingController.getMessageThreads();
      _notifications = await _messagingController.getNotifications();
    } catch (e) {
      print('加载消息数据错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通讯中心'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: '私信'), Tab(text: '通知')],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // 导航到消息设置页面
              Navigator.pushNamed(context, '/messaging/settings');
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [_buildMessagesTab(), _buildNotificationsTab()],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            // 创建新私信
            Navigator.pushNamed(context, '/messaging/new');
          }
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildMessagesTab() {
    if (_threads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              '没有私信',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text('开始与朋友交流吧', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: _threads.length,
        itemBuilder: (context, index) {
          final thread = _threads[index];
          return _buildThreadItem(thread);
        },
      ),
    );
  }

  Widget _buildThreadItem(MessageThread thread) {
    // 确定对话的标题和头像
    String title = thread.title;
    String? avatarUrl;

    if (thread.threadType == 'direct' && thread.participants.length == 2) {
      // 对于一对一私信，显示对方的名字和头像
      final otherUser = thread.participants.firstWhere(
        (p) => p.id != 'taoyonggang', // "taoyonggang"是当前用户的ID
        orElse: () => thread.participants.first,
      );
      title = otherUser.name;
      avatarUrl = otherUser.avatarUrl;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12, left: 8, right: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // 导航到会话详情页
          Navigator.pushNamed(
            context,
            '/messaging/thread',
            arguments: thread.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // 头像
              thread.threadType == 'direct'
                  ? CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null ? Icon(Icons.person) : null,
                  )
                  : CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.green[100],
                    child: Icon(Icons.group, color: Colors.green[700]),
                  ),
              SizedBox(width: 16),
              // 消息内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatDateTime(thread.updatedAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      thread.lastMessage?.content ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // 未读消息数
              if (thread.unreadCount > 0)
                Container(
                  margin: EdgeInsets.only(left: 8),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    thread.unreadCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsTab() {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              '没有通知',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text('您的通知将显示在这里', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(app_notification.Notification notification) {
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case 'activity':
        icon = Icons.event;
        iconColor = Colors.green;
        break;
      case 'membership':
        icon = Icons.card_membership;
        iconColor = Colors.purple;
        break;
      case 'mapping':
        icon = Icons.link;
        iconColor = Colors.blue;
        break;
      case 'authorization':
        icon = Icons.vpn_key;
        iconColor = Colors.orange;
        break;
      case 'system':
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12, left: 8, right: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: notification.isRead ? null : Colors.blue.shade50,
      child: InkWell(
        onTap: () {
          // 处理通知点击，如果有相关链接则导航
          if (notification.data != null &&
              notification.data!['actionUrl'] != null) {
            // 实际应用中应该解析actionUrl并跳转
            print('Navigate to: ${notification.data!['actionUrl']}');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(icon, color: iconColor),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatDateTime(notification.timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      notification.content,
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    if (!notification.isRead) ...[
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              // 标记为已读
                              // 实际应用中应该调用API
                              setState(() {
                                final index = _notifications.indexOf(
                                  notification,
                                );
                                if (index != -1) {
                                  _notifications[index] =
                                      app_notification.Notification(
                                        id: notification.id,
                                        title: notification.title,
                                        content: notification.content,
                                        type: notification.type,
                                        timestamp: notification.timestamp,
                                        isRead: true,
                                        data: notification.data,
                                      );
                                }
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 0,
                              ),
                              minimumSize: Size(0, 30),
                            ),
                            child: Text('标记为已读'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // 假设当前时间是 2025-04-29 23:38:33
    final now = DateTime(2025, 4, 29, 23, 38, 33);

    // 如果是同一天
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return '${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}';
    }

    // 如果是昨天
    final yesterday = now.subtract(Duration(days: 1));
    if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return '昨天 ${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}';
    }

    // 如果是同一年
    if (dateTime.year == now.year) {
      return '${dateTime.month}月${dateTime.day}日';
    }

    // 其他情况
    return '${dateTime.year}/${_padZero(dateTime.month)}/${_padZero(dateTime.day)}';
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}
