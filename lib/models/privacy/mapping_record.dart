import '../../models/user/user_brief.dart';

class MappingRecord {
  final String id;
  final UserBrief mapper; // 映射者
  final bool isApproved;
  final DateTime createdDate;
  final DateTime? approvalDate;
  final String virtualUserName; // 虚拟用户名称
  final Map<String, dynamic>? mappingMetadata;

  MappingRecord({
    required this.id,
    required this.mapper,
    this.isApproved = false,
    required this.createdDate,
    this.approvalDate,
    required this.virtualUserName,
    this.mappingMetadata,
  });

  factory MappingRecord.fromJson(Map<String, dynamic> json) {
    return MappingRecord(
      id: json['id'],
      mapper: UserBrief.fromJson(json['mapper']),
      isApproved: json['isApproved'] ?? false,
      createdDate: DateTime.parse(json['createdDate']),
      approvalDate:
          json['approvalDate'] != null
              ? DateTime.parse(json['approvalDate'])
              : null,
      virtualUserName: json['virtualUserName'],
      mappingMetadata: json['mappingMetadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mapper': mapper.toJson(),
      'isApproved': isApproved,
      'createdDate': createdDate.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'virtualUserName': virtualUserName,
      'mappingMetadata': mappingMetadata,
    };
  }
}
