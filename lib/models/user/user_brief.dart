class UserBrief {
  final String id;
  final String name;
  final String? avatarUrl;

  UserBrief({required this.id, required this.name, this.avatarUrl});

  factory UserBrief.fromJson(Map<String, dynamic> json) {
    return UserBrief(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'avatarUrl': avatarUrl};
  }
}
