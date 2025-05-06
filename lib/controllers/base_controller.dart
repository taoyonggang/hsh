import 'dart:convert';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

abstract class BaseController {
  // 获取当前用户ID
  String getCurrentUserId() {
    return AuthService().currentUserId;
  }

  // 加载用户特定数据
  Future<dynamic> loadUserData(String dataPath) async {
    // 注意路径变更为 users/current_user/
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
}
