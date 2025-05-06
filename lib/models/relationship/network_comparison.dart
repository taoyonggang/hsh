class NetworkComparison {
  final Map<String, dynamic> statistics;
  final Map<String, dynamic>? comparisionData;

  NetworkComparison({required this.statistics, this.comparisionData});

  factory NetworkComparison.fromJson(Map<String, dynamic> json) {
    return NetworkComparison(
      statistics: json['statistics'],
      comparisionData: json['comparisionData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'statistics': statistics, 'comparisionData': comparisionData};
  }
}
