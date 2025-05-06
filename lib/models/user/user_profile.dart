class UserProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? coverImageUrl;
  final bool isSocialMember;
  final DateTime? membershipExpiry;
  final int partnerCount;
  final int activityCount;
  final int relationshipCount;
  final Map<String, dynamic>? additionalInfo;

  UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.coverImageUrl,
    this.isSocialMember = false,
    this.membershipExpiry,
    this.partnerCount = 0,
    this.activityCount = 0,
    this.relationshipCount = 0,
    this.additionalInfo,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      coverImageUrl: json['coverImageUrl'],
      isSocialMember: json['isSocialMember'] ?? false,
      membershipExpiry:
          json['membershipExpiry'] != null
              ? DateTime.parse(json['membershipExpiry'])
              : null,
      partnerCount: json['partnerCount'] ?? 0,
      activityCount: json['activityCount'] ?? 0,
      relationshipCount: json['relationshipCount'] ?? 0,
      additionalInfo: json['additionalInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'coverImageUrl': coverImageUrl,
      'isSocialMember': isSocialMember,
      'membershipExpiry': membershipExpiry?.toIso8601String(),
      'partnerCount': partnerCount,
      'activityCount': activityCount,
      'relationshipCount': relationshipCount,
      'additionalInfo': additionalInfo,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? coverImageUrl,
    bool? isSocialMember,
    DateTime? membershipExpiry,
    int? partnerCount,
    int? activityCount,
    int? relationshipCount,
    Map<String, dynamic>? additionalInfo,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isSocialMember: isSocialMember ?? this.isSocialMember,
      membershipExpiry: membershipExpiry ?? this.membershipExpiry,
      partnerCount: partnerCount ?? this.partnerCount,
      activityCount: activityCount ?? this.activityCount,
      relationshipCount: relationshipCount ?? this.relationshipCount,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
