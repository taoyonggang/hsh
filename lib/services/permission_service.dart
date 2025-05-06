import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user/user_roles.dart';

class PermissionService {
  // 单例模式
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // 定义各页面所需的权限
  final Map<String, List<UserRole>> _routePermissions = {
    '/': [
      UserRole.guest,
      UserRole.user,
      UserRole.partnerMember,
      UserRole.socialMember,
      UserRole.healthMember,
    ],
    '/home': [
      UserRole.guest,
      UserRole.user,
      UserRole.partnerMember,
      UserRole.socialMember,
      UserRole.healthMember,
    ],
    '/login': [
      UserRole.guest,
      UserRole.user,
      UserRole.partnerMember,
      UserRole.socialMember,
      UserRole.healthMember,
    ],
    '/register': [
      UserRole.guest,
      UserRole.user,
      UserRole.partnerMember,
      UserRole.socialMember,
      UserRole.healthMember,
    ],
    '/forgot-password': [
      UserRole.guest,
      UserRole.user,
      UserRole.partnerMember,
      UserRole.socialMember,
      UserRole.healthMember,
    ],

    // 用户权限以上页面
    '/profile': [
      UserRole.user,
      UserRole.partnerMember,
      UserRole.socialMember,
      UserRole.healthMember,
    ],
    '/profile/edit': [
      UserRole.user,
      UserRole.partnerMember,
      UserRole.socialMember,
      UserRole.healthMember,
    ],
    '/health/basic': [
      UserRole.user,
      UserRole.partnerMember,
      UserRole.socialMember,
      UserRole.healthMember,
    ],
    '/fortune/basic': [
      UserRole.user,
      UserRole.partnerMember,
      UserRole.socialMember,
      UserRole.healthMember,
    ],
    '/settings': [
      UserRole.user,
      UserRole.partnerMember,
      UserRole.socialMember,
      UserRole.healthMember,
    ],
    '/health/data': [
      UserRole.user,
      UserRole.partnerMember,
      UserRole.socialMember,
      UserRole.healthMember,
    ],
    '/health': [
      UserRole.user,
      UserRole.partnerMember,
      UserRole.socialMember,
      UserRole.healthMember,
    ],
    '/fortune': [
      UserRole.user,
      UserRole.partnerMember,
      UserRole.socialMember,
      UserRole.healthMember,
    ],
    '/partner': [
      UserRole.user,
      UserRole.partnerMember,
      UserRole.socialMember,
      UserRole.healthMember,
    ],

    // 搭子会员权限页面
    '/communities/manage': [UserRole.partnerMember],
    '/activities/create': [UserRole.partnerMember],
    '/activities/priority': [UserRole.partnerMember],
    '/partner/activity/create': [UserRole.partnerMember],

    // 社交会员权限页面
    '/social/virtual-network': [UserRole.socialMember],
    '/social/network-analysis': [UserRole.socialMember],
    '/social/relationship-analysis': [UserRole.socialMember],
    '/network/virtual': [UserRole.socialMember],
    '/network/compare': [UserRole.socialMember],
    '/network/add-virtual-user': [UserRole.socialMember],

    // 健康会员权限页面
    '/health/advanced': [UserRole.healthMember],
    '/health/reports': [UserRole.healthMember],
    '/health/consultation': [UserRole.healthMember],
    '/health/report': [UserRole.healthMember],
  };

  // 功能权限配额
  final Map<String, Map<UserRole, int>> _featureQuotas = {
    'healthAnalysis': {
      UserRole.user: 1,
      UserRole.partnerMember: 1,
      UserRole.socialMember: 1,
      UserRole.healthMember: 100,
    },
    'socialAnalysis': {
      UserRole.user: 1,
      UserRole.partnerMember: 1,
      UserRole.socialMember: 100,
      UserRole.healthMember: 1,
    },
    'fortuneAnalysis': {
      UserRole.user: 1,
      UserRole.partnerMember: 1,
      UserRole.socialMember: 100,
      UserRole.healthMember: 1,
    },
    'communityCreate': {
      UserRole.user: 1,
      UserRole.partnerMember: 100,
      UserRole.socialMember: 1,
      UserRole.healthMember: 1,
    },
    'communityMemberLimit': {
      UserRole.user: 50,
      UserRole.partnerMember: 500,
      UserRole.socialMember: 50,
      UserRole.healthMember: 50,
    },
    'healthAdviceLength': {
      UserRole.user: 500,
      UserRole.partnerMember: 500,
      UserRole.socialMember: 500,
      UserRole.healthMember: -1, // 无限制
    },
  };

  // 检查用户是否有权限访问指定路由
  bool canAccessRoute(String route) {
    final authService = AuthService();

    // 如果权限表中没定义，默认需要登录用户权限
    if (!_routePermissions.containsKey(route)) {
      return authService.isFullUser;
    }

    final allowedRoles = _routePermissions[route]!;

    // 检查用户角色是否在允许列表中
    if (allowedRoles.contains(authService.currentRole)) {
      return true;
    }

    // 检查用户订阅权限
    for (var role in allowedRoles) {
      if (authService.hasRole(role)) {
        return true;
      }
    }

    return false;
  }

  // 获取特定功能的配额
  int getQuota(String featureKey) {
    final authService = AuthService();

    // 如果功能不存在配额表中
    if (!_featureQuotas.containsKey(featureKey)) {
      return 0;
    }

    final quotaMap = _featureQuotas[featureKey]!;

    // 优先检查订阅会员的权限配额
    if (authService.isHealthMember &&
        quotaMap.containsKey(UserRole.healthMember)) {
      return quotaMap[UserRole.healthMember]!;
    }

    if (authService.isSocialMember &&
        quotaMap.containsKey(UserRole.socialMember)) {
      return quotaMap[UserRole.socialMember]!;
    }

    if (authService.isPartnerMember &&
        quotaMap.containsKey(UserRole.partnerMember)) {
      return quotaMap[UserRole.partnerMember]!;
    }

    // 最后检查基本用户权限
    if (authService.isFullUser && quotaMap.containsKey(UserRole.user)) {
      return quotaMap[UserRole.user]!;
    }

    return 0;
  }

  // 检查是否有权限
  bool hasFeaturePermission(String featureKey) {
    return getQuota(featureKey) != 0;
  }
}
