import 'dart:convert';
import 'package:flutter/services.dart';
import 'auth_service.dart';

class ApiService {
  // 单例模式
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // 获取当前用户ID
  String getCurrentUserId() {
    return AuthService().currentUserId;
  }

  // 加载用户特定数据
  Future<dynamic> loadUserData(String dataPath) async {
    final userId = getCurrentUserId();
    // 注意这里的路径变更为 users/current_user/
    final path = 'assets/data/users/current_user/$dataPath';

    try {
      // 模拟网络延迟
      await Future.delayed(Duration(milliseconds: 600));

      final String jsonData = await rootBundle.loadString(path);
      return json.decode(jsonData);
    } catch (e) {
      print('加载数据失败: $path, 错误: $e');
      throw Exception('无法加载所需数据');
    }
  }

  // 模拟API的通用请求方法
  Future<Map<String, dynamic>> get(String endpoint) async {
    await Future.delayed(Duration(milliseconds: 800)); // 模拟网络延迟

    try {
      switch (endpoint) {
        case 'user/profile':
          return await loadUserData('profile.json');
        case 'health/overview':
          return await loadUserData('health_overview.json');
        default:
          throw Exception('未知的API端点');
      }
    } catch (e) {
      print('API请求错误: $e');
      throw Exception('API请求失败');
    }
  }

  // 获取列表数据
  Future<List<dynamic>> getList(String endpoint) async {
    await Future.delayed(Duration(milliseconds: 800)); // 模拟网络延迟

    try {
      switch (endpoint) {
        case 'social/feeds':
          return await loadUserData('social_feeds.json');
        default:
          throw Exception('未知的API端点');
      }
    } catch (e) {
      print('API请求错误: $e');
      throw Exception('API请求失败');
    }
  }
}
