import '../models/user/user_profile.dart';
import 'base_controller.dart';

class UserController extends BaseController {
  // 单例模式
  static final UserController _instance = UserController._internal();
  factory UserController() => _instance;
  UserController._internal();

  Future<UserProfile> getUserProfile() async {
    try {
      final userData = await loadUserData('profile.json');
      return UserProfile.fromJson(userData);
    } catch (e) {
      print('获取用户资料错误: $e');
      throw Exception('获取用户资料失败');
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      // 模拟API请求延迟
      await Future.delayed(Duration(milliseconds: 1000));

      // 在实际应用中，这里应该调用API保存数据
      print('更新用户资料: ${profile.toJson()}');

      // 成功返回
      return;
    } catch (e) {
      print('更新用户资料错误: $e');
      throw Exception('更新用户资料失败');
    }
  }
}
