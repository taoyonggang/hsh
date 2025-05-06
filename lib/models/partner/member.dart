class Member {
  final String id;
  final String name;
  final String avatarUrl;
  final String role; // admin, member
  final DateTime joinDate;

  Member({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.role,
    required this.joinDate,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      role: json['role'] ?? 'member',
      joinDate:
          json.containsKey('joinDate')
              ? DateTime.parse(json['joinDate'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role,
      'joinDate': joinDate.toIso8601String(),
    };
  }
}
