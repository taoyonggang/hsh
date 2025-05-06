import 'package:flutter/material.dart';
import '../../../controllers/messaging_controller.dart';
import '../../../models/messaging/notification.dart' as app_notification;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final MessagingController _messagingController = MessagingController();
  bool _isLoading = true;
  List<app_notification.Notification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      _notifications = await _messagingController.getNotifications();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载通知失败: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = _notifications[index];
        _notifications[index] = app_notification.Notification(
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通知'),
        actions: [
          if (!_isLoading && _notifications.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'markAllRead') {
                  setState(() {
                    _notifications =
                        _notifications
                            .map(
                              (n) => app_notification.Notification(
                                id: n.id,
                                title: n.title,
                                content: n.content,
                                type: n.type,
                                timestamp: n.timestamp,
                                isRead: true,
                                data: n.data,
                              ),
                            )
                            .toList();
                  });

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('已全部标记为已读')));
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(value: 'markAllRead', child: Text('全部标记为已读')),
                  ],
            ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationsList(),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationItem(_notifications[index]);
      },
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
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }

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
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _markAsRead(notification.id),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 0,
                            ),
                            minimumSize: Size(0, 30),
                          ),
                          child: Text('标记为已读'),
                        ),
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
    // 当前日期为 2025-04-30 00:46:20 UTC
    final now = DateTime.utc(2025, 4, 30, 0, 46, 20);

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
