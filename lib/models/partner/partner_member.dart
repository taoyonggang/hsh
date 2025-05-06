class PartnerMember {
  final String id;
  final String name;
  final String avatarUrl;
  final String? role;
  
  PartnerMember({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.role,
  });
  
  factory PartnerMember.fromJson(Map<String, dynamic> json) {
    return PartnerMember(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      role: json['role'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role,
    };
  }
}