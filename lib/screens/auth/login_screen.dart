import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user/user_roles.dart';
import 'package:intl/intl.dart';

class LoginScreen extends StatefulWidget {
  final bool redirectAfterLogin;
  final String? redirectRoute;

  const LoginScreen({
    Key? key,
    this.redirectAfterLogin = true,
    this.redirectRoute,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  // 当前时间：2025-05-06 07:17:51
  final DateTime _now = DateTime.utc(2025, 5, 6, 7, 17, 51);

  @override
  void initState() {
    super.initState();
    // 开发便利：预填充登录信息
    _usernameController.text = 'taoyonggang';
    _passwordController.text = '123456';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();

      final success = await authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (success) {
        if (widget.redirectAfterLogin) {
          if (widget.redirectRoute != null) {
            Navigator.of(context).pushReplacementNamed(widget.redirectRoute!);
          } else {
            Navigator.of(context).pushReplacementNamed('/');
          }
        } else {
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() {
          _errorMessage = '用户名或密码错误';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '登录失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登录')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            _buildHeader(),
            SizedBox(height: 32),
            _buildLoginForm(),
            if (_errorMessage != null) ...[
              SizedBox(height: 16),
              _buildErrorMessage(),
            ],
            SizedBox(height: 24),
            _buildLoginButton(),
            SizedBox(height: 16),
            _buildOtherOptions(),
            SizedBox(height: 40),
            _buildTestAccountsInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.health_and_safety, size: 72, color: Colors.green),
        SizedBox(height: 16),
        Text(
          '汇升活健康搭子平台',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          '现在时间: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_now)} UTC',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: '用户名',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入用户名';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: '密码',
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            obscureText: !_isPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入密码';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child:
          _isLoading
              ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Text('登录', style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildOtherOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('微信登录功能开发中...')));
          },
          child: Row(
            children: [
              Icon(Icons.wechat, color: Colors.green),
              SizedBox(width: 8),
              Text('微信登录', style: TextStyle(color: Colors.green)),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          child: Text('注册新账号'),
        ),
      ],
    );
  }

  Widget _buildTestAccountsInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('测试账号信息:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _buildTestAccount('taoyonggang', '全功能管理员 (全部会员)'),
          _buildTestAccount('user', '正式用户'),
          _buildTestAccount('partner', '搭子会员'),
          _buildTestAccount('social', '社交会员'),
          _buildTestAccount('health', '健康会员'),
          _buildTestAccount('guest', '访客用户'),
          SizedBox(height: 8),
          Text(
            '所有账号密码: 用户名+123 (例如: user123)\ntaoyonggang密码: 123456',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildTestAccount(String username, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(username, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Text('- $description', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
