import 'dart:math';

class MatchingProfile {
  final String id;
  final String name;
  final int age;
  final String gender;
  final double distance;
  final String location;
  final List<String> interests;
  final String? avatar;
  final String? coverImage;
  final String? profession;
  final String? education;
  final String? bio;
  final double? matchScore;

  MatchingProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.distance,
    required this.location,
    required this.interests,
    this.avatar,
    this.coverImage,
    this.profession,
    this.education,
    this.bio,
    this.matchScore,
  });

  factory MatchingProfile.fromJson(Map<String, dynamic> json) {
    return MatchingProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 25,
      gender: json['gender'] ?? 'male',
      distance: (json['distance'] ?? 0.0).toDouble(),
      location: json['location'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      avatar: json['avatar'],
      coverImage: json['coverImage'],
      profession: json['profession'],
      education: json['education'],
      bio: json['bio'],
      matchScore:
          (json['matchScore'] ?? (Random().nextDouble() * 0.5 + 0.5))
              .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': name,
      'age': age,
      'gender': gender,
      'distance': distance,
      'location': location,
      'interests': interests,
      'avatar': avatar,
      'image': coverImage,
      'profession': profession,
      'education': education,
      'content': bio,
      'matchScore': matchScore,
      'likes': Random().nextInt(100),
      'comments': Random().nextInt(20),
      'time': '${Random().nextInt(24)}小时前',
    };
  }
}
