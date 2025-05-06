import '../../models/user/user_brief.dart';

class MessageThread {
  final String id;
  final String threadType; // 'direct' or 'group'
  final String title;
  final List<UserBrief> participants;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  MessageThread({
    required this.id,
    required this.threadType,
    required this.title,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    return MessageThread(
      id: json['id'],
      threadType: json['threadType'],
      title: json['title'],
      participants:
          (json['participants'] as List)
              .map((p) => UserBrief.fromJson(p))
              .toList(),
      lastMessage:
          json['lastMessage'] != null
              ? Message.fromJson(json['lastMessage'])
              : null,
      unreadCount: json['unreadCount'] ?? 0,
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'threadType': threadType,
      'title': title,
      'participants': participants.map((p) => p.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Message {
  final String id;
  final String threadId;
  final UserBrief sender;
  final String content;
  final DateTime timestamp;
  final String messageType; // 'text', 'image', 'video', 'location', etc.
  final bool isRead;
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.threadId,
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.messageType,
    this.isRead = false,
    this.metadata,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      threadId: json['threadId'],
      sender: UserBrief.fromJson(json['sender']),
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      messageType: json['messageType'],
      isRead: json['isRead'] ?? false,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'threadId': threadId,
      'sender': sender.toJson(),
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'messageType': messageType,
      'isRead': isRead,
      'metadata': metadata,
    };
  }
}
