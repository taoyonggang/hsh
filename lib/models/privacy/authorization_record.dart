import '../../models/user/user_brief.dart';

class AuthorizationRecord {
  final String id;
  final UserBrief requestor; // 请求者
  final String status; // 'pending', 'approved', 'denied', 'revoked'
  final DateTime requestDate;
  final DateTime? responseDate;
  final DateTime? expiryDate;
  final List<String> dataTypes;
  final String purpose;

  AuthorizationRecord({
    required this.id,
    required this.requestor,
    required this.status,
    required this.requestDate,
    this.responseDate,
    this.expiryDate,
    required this.dataTypes,
    required this.purpose,
  });

  factory AuthorizationRecord.fromJson(Map<String, dynamic> json) {
    return AuthorizationRecord(
      id: json['id'],
      requestor: UserBrief.fromJson(json['requestor']),
      status: json['status'],
      requestDate: DateTime.parse(json['requestDate']),
      responseDate:
          json['responseDate'] != null
              ? DateTime.parse(json['responseDate'])
              : null,
      expiryDate:
          json['expiryDate'] != null
              ? DateTime.parse(json['expiryDate'])
              : null,
      dataTypes: List<String>.from(json['dataTypes']),
      purpose: json['purpose'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestor': requestor.toJson(),
      'status': status,
      'requestDate': requestDate.toIso8601String(),
      'responseDate': responseDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'dataTypes': dataTypes,
      'purpose': purpose,
    };
  }
}
