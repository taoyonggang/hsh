import 'partner_member.dart';
import 'partner_activity.dart';

class PartnerGroup {
  final String id;
  final String name;
  final String description;
  final String? coverImage;
  final List<PartnerMember> members;
  final int memberCount;
  final String createdTime;
  final int unreadCount;
  final List<PartnerActivity> upcomingActivities;

  PartnerGroup({
    required this.id,
    required this.name,
    required this.description,
    this.coverImage,
    required this.members,
    required this.memberCount,
    required this.createdTime,
    this.unreadCount = 0,
    this.upcomingActivities = const [],
  });

  factory PartnerGroup.fromJson(Map<String, dynamic> json) {
    return PartnerGroup(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      coverImage: json['coverImage'],
      members:
          (json['members'] as List)
              .map((member) => PartnerMember.fromJson(member))
              .toList(),
      memberCount: json['memberCount'] ?? json['members'].length,
      createdTime: json['createdTime'],
      unreadCount: json['unreadCount'] ?? 0,
      upcomingActivities:
          json['upcomingActivities'] != null
              ? (json['upcomingActivities'] as List)
                  .map((activity) => PartnerActivity.fromJson(activity))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImage': coverImage,
      'members': members.map((member) => member.toJson()).toList(),
      'memberCount': memberCount,
      'createdTime': createdTime,
      'unreadCount': unreadCount,
      'upcomingActivities':
          upcomingActivities.map((activity) => activity.toJson()).toList(),
    };
  }
}
