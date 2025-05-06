import '../models/messaging/message.dart';
import '../models/messaging/notification.dart' as app_notification;
import 'base_controller.dart';

class MessagingController extends BaseController {
  // 单例模式
  static final MessagingController _instance = MessagingController._internal();
  factory MessagingController() => _instance;
  MessagingController._internal();

  Future<List<MessageThread>> getMessageThreads() async {
    try {
      final threadsData = await loadUserData('messages/threads.json');
      return (threadsData as List)
          .map((data) => MessageThread.fromJson(data))
          .toList();
    } catch (e) {
      print('获取消息会话列表错误: $e');
      throw Exception('获取消息会话列表失败');
    }
  }

  Future<List<Message>> getMessages(String threadId) async {
    try {
      final messagesData = await loadUserData('messages/$threadId.json');
      return (messagesData as List)
          .map((data) => Message.fromJson(data))
          .toList();
    } catch (e) {
      // 如果没有找到特定会话的JSON文件，返回空列表
      print('获取消息列表错误: $e');
      return [];
    }
  }

  Future<List<app_notification.Notification>> getNotifications() async {
    try {
      final notificationsData = await loadUserData('notifications.json');
      return (notificationsData as List)
          .map((data) => app_notification.Notification.fromJson(data))
          .toList();
    } catch (e) {
      print('获取通知列表错误: $e');
      throw Exception('获取通知列表失败');
    }
  }

  Future<void> sendMessage(String threadId, String content) async {
    try {
      // 模拟API请求延迟
      await Future.delayed(Duration(milliseconds: 1000));

      // 在实际应用中，这里应该调用API发送消息
      print('发送消息到会话 $threadId: $content');

      // 成功返回
      return;
    } catch (e) {
      print('发送消息错误: $e');
      throw Exception('发送消息失败');
    }
  }

  Future<void> markThreadAsRead(String threadId) async {
    try {
      // 模拟API请求延迟
      await Future.delayed(Duration(milliseconds: 500));

      // 在实际应用中，这里应该调用API标记会话为已读
      print('标记会话为已读: $threadId');

      // 成功返回
      return;
    } catch (e) {
      print('标记会话为已读错误: $e');
      throw Exception('标记会话为已读失败');
    }
  }
}
