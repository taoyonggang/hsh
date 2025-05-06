import 'relationship_network.dart';

class VirtualUser {
  final String id;
  final String name;
  final String relationshipType;
  final String? avatarUrl;
  final bool isMapped;
  final String? mappedUserId;
  final List<String> tags;
  final Map<String, dynamic>? attributes;

  VirtualUser({
    required this.id,
    required this.name,
    required this.relationshipType,
    this.avatarUrl,
    this.isMapped = false,
    this.mappedUserId,
    this.tags = const [],
    this.attributes,
  });

  factory VirtualUser.fromJson(Map<String, dynamic> json) {
    return VirtualUser(
      id: json['id'],
      name: json['name'],
      relationshipType: json['relationshipType'],
      avatarUrl: json['avatarUrl'],
      isMapped: json['isMapped'] ?? false,
      mappedUserId: json['mappedUserId'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
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
      'tags': tags,
      'attributes': attributes,
    };
  }

  // 从NetworkNode转换为VirtualUser
  factory VirtualUser.fromNetworkNode(NetworkNode node) {
    return VirtualUser(
      id: node.id,
      name: node.name,
      relationshipType: node.relationshipType,
      avatarUrl: node.avatarUrl,
      isMapped: node.isMapped,
      mappedUserId: node.mappedUserId,
      tags:
          node.attributes != null && node.attributes!['tags'] != null
              ? List<String>.from(node.attributes!['tags'])
              : [],
      attributes: node.attributes,
    );
  }

  // 转换为NetworkNode
  NetworkNode toNetworkNode() {
    return NetworkNode(
      id: id,
      name: name,
      relationshipType: relationshipType,
      avatarUrl: avatarUrl,
      isMapped: isMapped,
      mappedUserId: mappedUserId,
      attributes: {...?attributes, 'tags': tags},
    );
  }
}
