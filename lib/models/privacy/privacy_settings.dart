class PrivacySettings {
  final VisibilitySettings basicInfo;
  final VisibilitySettings sensitiveInfo;
  final VisibilitySettings socialInfo;
  final AuthorizationSettings dataAuthorization;
  final MappingSettings mappingSettings;

  PrivacySettings({
    required this.basicInfo,
    required this.sensitiveInfo,
    required this.socialInfo,
    required this.dataAuthorization,
    required this.mappingSettings,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      basicInfo: VisibilitySettings.fromJson(json['basicInfo']),
      sensitiveInfo: VisibilitySettings.fromJson(json['sensitiveInfo']),
      socialInfo: VisibilitySettings.fromJson(json['socialInfo']),
      dataAuthorization: AuthorizationSettings.fromJson(
        json['dataAuthorization'],
      ),
      mappingSettings: MappingSettings.fromJson(json['mappingSettings']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basicInfo': basicInfo.toJson(),
      'sensitiveInfo': sensitiveInfo.toJson(),
      'socialInfo': socialInfo.toJson(),
      'dataAuthorization': dataAuthorization.toJson(),
      'mappingSettings': mappingSettings.toJson(),
    };
  }

  PrivacySettings copyWith({
    VisibilitySettings? basicInfo,
    VisibilitySettings? sensitiveInfo,
    VisibilitySettings? socialInfo,
    AuthorizationSettings? dataAuthorization,
    MappingSettings? mappingSettings,
  }) {
    return PrivacySettings(
      basicInfo: basicInfo ?? this.basicInfo,
      sensitiveInfo: sensitiveInfo ?? this.sensitiveInfo,
      socialInfo: socialInfo ?? this.socialInfo,
      dataAuthorization: dataAuthorization ?? this.dataAuthorization,
      mappingSettings: mappingSettings ?? this.mappingSettings,
    );
  }
}

class VisibilitySettings {
  final String visibility; // 'public', 'friends', 'selected', 'private'
  final bool allowMapping;
  final List<String>? selectedUserIds;

  VisibilitySettings({
    required this.visibility,
    this.allowMapping = true,
    this.selectedUserIds,
  });

  factory VisibilitySettings.fromJson(Map<String, dynamic> json) {
    return VisibilitySettings(
      visibility: json['visibility'],
      allowMapping: json['allowMapping'] ?? true,
      selectedUserIds:
          json['selectedUserIds'] != null
              ? List<String>.from(json['selectedUserIds'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visibility': visibility,
      'allowMapping': allowMapping,
      'selectedUserIds': selectedUserIds,
    };
  }

  VisibilitySettings copyWith({
    String? visibility,
    bool? allowMapping,
    List<String>? selectedUserIds,
  }) {
    return VisibilitySettings(
      visibility: visibility ?? this.visibility,
      allowMapping: allowMapping ?? this.allowMapping,
      selectedUserIds: selectedUserIds ?? this.selectedUserIds,
    );
  }
}

class AuthorizationSettings {
  final bool autoApproveBasicData;
  final bool autoApproveSensitiveData;
  final bool notifyOnDataAccess;

  AuthorizationSettings({
    this.autoApproveBasicData = false,
    this.autoApproveSensitiveData = false,
    this.notifyOnDataAccess = true,
  });

  factory AuthorizationSettings.fromJson(Map<String, dynamic> json) {
    return AuthorizationSettings(
      autoApproveBasicData: json['autoApproveBasicData'] ?? false,
      autoApproveSensitiveData: json['autoApproveSensitiveData'] ?? false,
      notifyOnDataAccess: json['notifyOnDataAccess'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoApproveBasicData': autoApproveBasicData,
      'autoApproveSensitiveData': autoApproveSensitiveData,
      'notifyOnDataAccess': notifyOnDataAccess,
    };
  }

  AuthorizationSettings copyWith({
    bool? autoApproveBasicData,
    bool? autoApproveSensitiveData,
    bool? notifyOnDataAccess,
  }) {
    return AuthorizationSettings(
      autoApproveBasicData: autoApproveBasicData ?? this.autoApproveBasicData,
      autoApproveSensitiveData:
          autoApproveSensitiveData ?? this.autoApproveSensitiveData,
      notifyOnDataAccess: notifyOnDataAccess ?? this.notifyOnDataAccess,
    );
  }
}

class MappingSettings {
  final bool allowMappingByAnyone;
  final bool notifyOnMapping;
  final List<String>? blockedUserIds;

  MappingSettings({
    this.allowMappingByAnyone = false,
    this.notifyOnMapping = true,
    this.blockedUserIds,
  });

  factory MappingSettings.fromJson(Map<String, dynamic> json) {
    return MappingSettings(
      allowMappingByAnyone: json['allowMappingByAnyone'] ?? false,
      notifyOnMapping: json['notifyOnMapping'] ?? true,
      blockedUserIds:
          json['blockedUserIds'] != null
              ? List<String>.from(json['blockedUserIds'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowMappingByAnyone': allowMappingByAnyone,
      'notifyOnMapping': notifyOnMapping,
      'blockedUserIds': blockedUserIds,
    };
  }

  MappingSettings copyWith({
    bool? allowMappingByAnyone,
    bool? notifyOnMapping,
    List<String>? blockedUserIds,
  }) {
    return MappingSettings(
      allowMappingByAnyone: allowMappingByAnyone ?? this.allowMappingByAnyone,
      notifyOnMapping: notifyOnMapping ?? this.notifyOnMapping,
      blockedUserIds: blockedUserIds ?? this.blockedUserIds,
    );
  }
}
