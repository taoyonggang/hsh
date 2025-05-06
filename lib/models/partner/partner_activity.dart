import '../user/user_brief.dart';

class PartnerActivity {
  final String id;
  final String title;
  final String description;
  final String time;
  final String startTime;
  final String endTime;
  final String location;
  final int participants;
  final String? image;
  final String? coverImageUrl;
  final String? type;
  final List<String>? tags;
  final bool isOnline;
  final double fee;
  final int participantCount;
  final int maxParticipants;
  final bool isSignUpRequired;
  final bool hasSignedUp;
  final bool isFull;
  final List<UserBrief> participantsList;

  PartnerActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.location,
    this.startTime = '',
    this.endTime = '',
    this.participants = 0,
    this.image,
    this.coverImageUrl,
    this.type,
    this.tags,
    this.isOnline = false,
    this.fee = 0.0,
    this.participantCount = 0,
    this.maxParticipants = 10,
    this.isSignUpRequired = true,
    this.hasSignedUp = false,
    this.isFull = false,
    this.participantsList = const [],
  });

  factory PartnerActivity.fromJson(Map<String, dynamic> json) {
    return PartnerActivity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      time: json['time'] ?? '',
      startTime: json['startTime'] ?? json['time'] ?? '',
      endTime: json['endTime'] ?? '',
      location: json['location'] ?? '',
      participants: json['participants'] ?? 0,
      image: json['image'],
      coverImageUrl: json['coverImageUrl'] ?? json['image'],
      type: json['type'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isOnline: json['isOnline'] ?? false,
      fee: (json['fee'] ?? 0.0).toDouble(),
      participantCount: json['participantCount'] ?? json['participants'] ?? 0,
      maxParticipants: json['maxParticipants'] ?? 10,
      isSignUpRequired: json['isSignUpRequired'] ?? true,
      hasSignedUp: json['hasSignedUp'] ?? false,
      isFull: json['isFull'] ?? false,
      participantsList:
          json['participantsList'] != null
              ? List<UserBrief>.from(
                json['participantsList'].map((x) => UserBrief.fromJson(x)),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'participants': participants,
      'image': image,
      'coverImageUrl': coverImageUrl,
      'type': type,
      'tags': tags,
      'isOnline': isOnline,
      'fee': fee,
      'participantCount': participantCount,
      'maxParticipants': maxParticipants,
      'isSignUpRequired': isSignUpRequired,
      'hasSignedUp': hasSignedUp,
      'isFull': isFull,
      'participantsList': participantsList.map((x) => x.toJson()).toList(),
    };
  }

  PartnerActivity copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    String? startTime,
    String? endTime,
    String? location,
    int? participants,
    String? image,
    String? coverImageUrl,
    String? type,
    List<String>? tags,
    bool? isOnline,
    double? fee,
    int? participantCount,
    int? maxParticipants,
    bool? isSignUpRequired,
    bool? hasSignedUp,
    bool? isFull,
    List<UserBrief>? participantsList,
  }) {
    return PartnerActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      participants: participants ?? this.participants,
      image: image ?? this.image,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      isOnline: isOnline ?? this.isOnline,
      fee: fee ?? this.fee,
      participantCount: participantCount ?? this.participantCount,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      isSignUpRequired: isSignUpRequired ?? this.isSignUpRequired,
      hasSignedUp: hasSignedUp ?? this.hasSignedUp,
      isFull: isFull ?? this.isFull,
      participantsList: participantsList ?? this.participantsList,
    );
  }
}
