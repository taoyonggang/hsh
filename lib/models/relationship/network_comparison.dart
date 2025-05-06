class NetworkComparison {
  final Map<String, dynamic> statistics;
  final Map<String, dynamic>? comparisionData;
  final List<MissedConnection> missedConnections;
  final List<StrengthDifference> strengthDifferences;

  NetworkComparison({
    required this.statistics,
    this.comparisionData,
    this.missedConnections = const [],
    this.strengthDifferences = const [],
  });

  factory NetworkComparison.fromJson(Map<String, dynamic> json) {
    return NetworkComparison(
      statistics: json['statistics'],
      comparisionData: json['comparisionData'],
      missedConnections:
          json['missedConnections'] != null
              ? (json['missedConnections'] as List)
                  .map((e) => MissedConnection.fromJson(e))
                  .toList()
              : [],
      strengthDifferences:
          json['strengthDifferences'] != null
              ? (json['strengthDifferences'] as List)
                  .map((e) => StrengthDifference.fromJson(e))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statistics': statistics,
      'comparisionData': comparisionData,
      'missedConnections': missedConnections.map((e) => e.toJson()).toList(),
      'strengthDifferences':
          strengthDifferences.map((e) => e.toJson()).toList(),
    };
  }

  // 为statistics添加扩展getter方便访问
  int get realNodeCount => statistics['realNodeCount'] ?? 0;
  int get realEdgeCount => statistics['realEdgeCount'] ?? 0;
  double get realNetworkDensity => statistics['realNetworkDensity'] ?? 0.0;

  int get virtualNodeCount => statistics['virtualNodeCount'] ?? 0;
  int get virtualEdgeCount => statistics['virtualEdgeCount'] ?? 0;
  double get virtualNetworkDensity =>
      statistics['virtualNetworkDensity'] ?? 0.0;

  int get realOnlyCount => statistics['realOnlyCount'] ?? 0;
  int get virtualOnlyCount => statistics['virtualOnlyCount'] ?? 0;
  int get sharedCount => statistics['sharedCount'] ?? 0;
}

class MissedConnection {
  final String sourceId;
  final String targetId;
  final double confidenceScore;

  MissedConnection({
    required this.sourceId,
    required this.targetId,
    required this.confidenceScore,
  });

  factory MissedConnection.fromJson(Map<String, dynamic> json) {
    return MissedConnection(
      sourceId: json['sourceId'],
      targetId: json['targetId'],
      confidenceScore:
          json['confidenceScore'] is int
              ? (json['confidenceScore'] as int).toDouble()
              : json['confidenceScore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceId': sourceId,
      'targetId': targetId,
      'confidenceScore': confidenceScore,
    };
  }
}

class StrengthDifference {
  final String sourceId;
  final String targetId;
  final double realStrength;
  final double virtualStrength;

  StrengthDifference({
    required this.sourceId,
    required this.targetId,
    required this.realStrength,
    required this.virtualStrength,
  });

  double get difference => (virtualStrength - realStrength).abs();

  factory StrengthDifference.fromJson(Map<String, dynamic> json) {
    return StrengthDifference(
      sourceId: json['sourceId'],
      targetId: json['targetId'],
      realStrength:
          json['realStrength'] is int
              ? (json['realStrength'] as int).toDouble()
              : json['realStrength'],
      virtualStrength:
          json['virtualStrength'] is int
              ? (json['virtualStrength'] as int).toDouble()
              : json['virtualStrength'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceId': sourceId,
      'targetId': targetId,
      'realStrength': realStrength,
      'virtualStrength': virtualStrength,
    };
  }
}
