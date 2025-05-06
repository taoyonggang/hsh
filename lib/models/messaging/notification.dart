class Notification {
  final String id;
  final String title;
  final String content;
  final String
  type; // 'activity', 'membership', 'mapping', 'authorization', 'system'
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  Notification({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }
}
