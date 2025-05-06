import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user/user_roles.dart';

class UserSession {
  final String userId;
  final String username;
  final UserRole role;
  final List<UserRole> subscriptions; // 用户可能同时拥有多种会员
  final DateTime loginTime;
  final DateTime? membershipExpiry;

  UserSession({
    required this.userId,
    required this.username,
    required this.role,
    this.subscriptions = const [],
    required this.loginTime,
    this.membershipExpiry,
  });

  bool get isLoggedIn => role != UserRole.guest;
  bool get isFullUser => role != UserRole.guest;
  bool get isPartnerMember => subscriptions.contains(UserRole.partnerMember);
  bool get isSocialMember => subscriptions.contains(UserRole.socialMember);
  bool get isHealthMember => subscriptions.contains(UserRole.healthMember);

  // 判断是否有某个权限
  bool hasRole(UserRole checkRole) {
    if (role == checkRole) return true;
    return subscriptions.contains(checkRole);
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'role': role.index,
      'subscriptions': subscriptions.map((r) => r.index).toList(),
      'loginTime': loginTime.millisecondsSinceEpoch,
      'membershipExpiry': membershipExpiry?.millisecondsSinceEpoch,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['userId'],
      username: json['username'],
      role: UserRole.values[json['role']],
      subscriptions:
          (json['subscriptions'] as List?)
              ?.map((i) => UserRole.values[i])
              ?.toList() ??
          [],
      loginTime: DateTime.fromMillisecondsSinceEpoch(json['loginTime']),
      membershipExpiry:
          json['membershipExpiry'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['membershipExpiry'])
              : null,
    );
  }

  // 访客会话
  static UserSession guest() {
    return UserSession(
      userId: 'guest',
      username: '访客',
      role: UserRole.guest,
      loginTime: DateTime.now(),
    );
  }
}

class AuthService extends ChangeNotifier {
  // 单例模式
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // 当前用户会话
  UserSession _currentSession = UserSession.guest();

  // 测试账号数据 - 根据分层设计
  final Map<String, Map<String, dynamic>> _users = {
    'taoyonggang': {
      'password': '123456',
      'userId': 'user123',
      'role': UserRole.user,
      'subscriptions': [
        UserRole.partnerMember,
        UserRole.socialMember,
        UserRole.healthMember,
      ],
      'membershipExpiry': DateTime(2026, 5, 6),
    },
    'user': {
      'password': 'user123',
      'userId': 'user456',
      'role': UserRole.user,
      'subscriptions': [],
    },
    'partner': {
      'password': 'partner123',
      'userId': 'user789',
      'role': UserRole.user,
      'subscriptions': [UserRole.partnerMember],
      'membershipExpiry': DateTime(2025, 12, 31),
    },
    'social': {
      'password': 'social123',
      'userId': 'user101',
      'role': UserRole.user,
      'subscriptions': [UserRole.socialMember],
      'membershipExpiry': DateTime(2025, 12, 31),
    },
    'health': {
      'password': 'health123',
      'userId': 'user202',
      'role': UserRole.user,
      'subscriptions': [UserRole.healthMember],
      'membershipExpiry': DateTime(2025, 12, 31),
    },
    'guest': {
      'password': 'guest123',
      'userId': 'guest303',
      'role': UserRole.guest,
      'subscriptions': [],
    },
  };

  // 当前会话访问器
  UserSession get currentSession => _currentSession;
  String get currentUserId => _currentSession.userId;
  String get currentUsername => _currentSession.username;
  UserRole get currentRole => _currentSession.role;
  bool get isLoggedIn => _currentSession.isLoggedIn;
  bool get isFullUser => _currentSession.isFullUser;
  bool get isPartnerMember => _currentSession.isPartnerMember;
  bool get isSocialMember => _currentSession.isSocialMember;
  bool get isHealthMember => _currentSession.isHealthMember;

  // 检查特定权限
  bool hasRole(UserRole role) => _currentSession.hasRole(role);

  // 初始化（从持久化存储恢复会话）
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString('userSession');

      if (sessionData != null) {
        try {
          final Map<String, dynamic> json = Map<String, dynamic>.from(
            jsonDecode(sessionData),
          );
          _currentSession = UserSession.fromJson(json);
          notifyListeners();

          print('已恢复会话: ${_currentSession.username} (${_currentSession.role})');
        } catch (e) {
          print('恢复会话失败: $e');
          await logout();
        }
      } else {
        // 开发模式：自动登录为taoyonggang
        await login('taoyonggang', '123456');
        print('开发模式：自动登录为taoyonggang');
      }
    } catch (e) {
      print('初始化认证服务错误: $e');
    }
  }

  // 登录方法
  Future<bool> login(String username, String password) async {
    // 检查用户名和密码
    if (!_users.containsKey(username) ||
        _users[username]!['password'] != password) {
      return false;
    }

    final userData = _users[username]!;

    // 创建新会话
    _currentSession = UserSession(
      userId: userData['userId'],
      username: username,
      role: userData['role'],
      subscriptions: userData['subscriptions'] ?? [],
      loginTime: DateTime.now(),
      membershipExpiry: userData['membershipExpiry'],
    );

    // 持久化会话
    await _saveSession();

    // 通知监听者（用于UI更新）
    notifyListeners();

    print('登录成功: $username (${_currentSession.role})');
    return true;
  }

  // 退出登录
  Future<void> logout() async {
    _currentSession = UserSession.guest();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userSession');

    notifyListeners();
    print('已退出登录');
  }

  // 保存会话到持久化存储
  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = jsonEncode(_currentSession.toJson());
    await prefs.setString('userSession', sessionData);
  }
}
