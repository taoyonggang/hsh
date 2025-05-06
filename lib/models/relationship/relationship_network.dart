class RelationshipNetwork {
  final String networkType; // 'real' or 'virtual'
  final List<NetworkNode> nodes;
  final List<NetworkConnection> connections;

  RelationshipNetwork({
    required this.networkType,
    required this.nodes,
    required this.connections,
  });

  factory RelationshipNetwork.fromJson(Map<String, dynamic> json) {
    return RelationshipNetwork(
      networkType: json['networkType'],
      nodes:
          (json['nodes'] as List)
              .map((node) => NetworkNode.fromJson(node))
              .toList(),
      connections:
          (json['connections'] as List)
              .map((connection) => NetworkConnection.fromJson(connection))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'networkType': networkType,
      'nodes': nodes.map((node) => node.toJson()).toList(),
      'connections':
          connections.map((connection) => connection.toJson()).toList(),
    };
  }
}

class NetworkNode {
  final String id;
  final String name;
  final String
  relationshipType; // 'family', 'friend', 'colleague', 'partner', 'self', 'other'
  final String? avatarUrl;
  final bool isMapped;
  final String? mappedUserId;
  final Map<String, dynamic>? attributes;

  NetworkNode({
    required this.id,
    required this.name,
    required this.relationshipType,
    this.avatarUrl,
    this.isMapped = false,
    this.mappedUserId,
    this.attributes,
  });

  factory NetworkNode.fromJson(Map<String, dynamic> json) {
    return NetworkNode(
      id: json['id'],
      name: json['name'],
      relationshipType: json['relationshipType'],
      avatarUrl: json['avatarUrl'],
      isMapped: json['isMapped'] ?? false,
      mappedUserId: json['mappedUserId'],
      attributes: json['attributes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationshipType': relationshipType,
      'avatarUrl': avatarUrl,
      'isMapped': isMapped,
      'mappedUserId': mappedUserId,
      'attributes': attributes,
    };
  }
}

class NetworkConnection {
  final String sourceId;
  final String targetId;
  final String relationshipType;
  final double strength;

  NetworkConnection({
    required this.sourceId,
    required this.targetId,
    required this.relationshipType,
    required this.strength,
  });

  factory NetworkConnection.fromJson(Map<String, dynamic> json) {
    return NetworkConnection(
      sourceId: json['sourceId'],
      targetId: json['targetId'],
      relationshipType: json['relationshipType'],
      strength:
          json['strength'] is int
              ? (json['strength'] as int).toDouble()
              : json['strength'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceId': sourceId,
      'targetId': targetId,
      'relationshipType': relationshipType,
      'strength': strength,
    };
  }
}
