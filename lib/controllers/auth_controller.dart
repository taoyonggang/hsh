class AuthController {
  bool _isLoggedIn = true;
  
  bool get isLoggedIn => _isLoggedIn;
  
  Future<bool> login(String username, String password) async {
    try {
      // 模拟API请求延迟
      await Future.delayed(Duration(milliseconds: 1000));
      
      // 实际应用中，这里会向服务器发送登录请求
      if (username.isNotEmpty && password.isNotEmpty) {
        _isLoggedIn = true;
        return true;
      }
      return false;
    } catch (e) {
      print('登录错误: $e');
      return false;
    }
  }
  
  Future<bool> logout() async {
    try {
      // 模拟API请求延迟
      await Future.delayed(Duration(milliseconds: 500));
      
      // 实际应用中，这里会向服务器发送登出请求
      _isLoggedIn = false;
      return true;
    } catch (e) {
      print('登出错误: $e');
      return false;
    }
  }
  
  Future<bool> register(String username, String password, String email) async {
    try {
      // 模拟API请求延迟
      await Future.delayed(Duration(milliseconds: 1500));
      
      // 实际应用中，这里会向服务器发送注册请求
      if (username.isNotEmpty && password.isNotEmpty && email.isNotEmpty) {
        _isLoggedIn = true;
        return true;
      }
      return false;
    } catch (e) {
      print('注册错误: $e');
      return false;
    }
  }
}