import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = true;

  // 账号信息
  String _username = '';
  String _email = '';
  String _phone = '';
  String _twoFactorMethod = 'none'; // none, sms, app

  @override
  void initState() {
    super.initState();
    _loadAccountInfo();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadAccountInfo() async {
    setState(() => _isLoading = true);
    try {
      // 模拟加载账号信息
      await Future.delayed(Duration(milliseconds: 800));

      setState(() {
        _username = AuthService().currentUsername;
        _email = 'user@example.com';
        _phone = '138****5678';
        _twoFactorMethod = 'none';

        _emailController.text = _email;
        _phoneController.text = _phone;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载账号信息失败: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('账户管理')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccountInfoSection(),
                    SizedBox(height: 24),
                    _buildSecuritySection(),
                    SizedBox(height: 24),
                    _buildDangerZoneSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildAccountInfoSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '账号信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('用户名'),
              subtitle: Text(_username),
              leading: Icon(Icons.person),
            ),
            ListTile(
              title: Text('电子邮件'),
              subtitle: Text(_email),
              leading: Icon(Icons.email),
              trailing: Icon(Icons.edit),
              onTap: () {
                _showEditEmailDialog();
              },
            ),
            ListTile(
              title: Text('手机号码'),
              subtitle: Text(_phone),
              leading: Icon(Icons.phone),
              trailing: Icon(Icons.edit),
              onTap: () {
                _showEditPhoneDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '安全设置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('修改密码'),
              leading: Icon(Icons.lock),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showChangePasswordDialog();
              },
            ),
            ListTile(
              title: Text('两步验证'),
              subtitle: Text(_getTwoFactorMethodText()),
              leading: Icon(Icons.security),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showTwoFactorDialog();
              },
            ),
            ListTile(
              title: Text('登录历史'),
              leading: Icon(Icons.history),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, '/settings/login-history');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZoneSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '危险操作',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('注销账号'),
              subtitle: Text('永久删除您的账号和所有数据'),
              leading: Icon(Icons.delete_forever, color: Colors.red),
              onTap: () {
                _showDeleteAccountDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getTwoFactorMethodText() {
    switch (_twoFactorMethod) {
      case 'sms':
        return '手机短信验证';
      case 'app':
        return '认证器应用';
      case 'none':
      default:
        return '未启用';
    }
  }

  void _showEditEmailDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('修改电子邮件'),
            content: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '新电子邮件',
                hintText: '请输入新电子邮件',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _email = _emailController.text);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('电子邮件更新成功')));
                },
                child: Text('保存'),
              ),
            ],
          ),
    );
  }

  void _showEditPhoneDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('修改手机号码'),
            content: TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: '新手机号码',
                hintText: '请输入新手机号码',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _phone = _phoneController.text);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('手机号码更新成功')));
                },
                child: Text('保存'),
              ),
            ],
          ),
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('修改密码'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    labelText: '当前密码',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: '新密码',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: '确认新密码',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('密码已更新')));
                },
                child: Text('保存'),
              ),
            ],
          ),
    );
  }

  void _showTwoFactorDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('两步验证'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text('不启用'),
                  value: 'none',
                  groupValue: _twoFactorMethod,
                  onChanged: (value) {
                    setState(() => _twoFactorMethod = value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: Text('手机短信验证'),
                  value: 'sms',
                  groupValue: _twoFactorMethod,
                  onChanged: (value) {
                    setState(() => _twoFactorMethod = value!);
                    Navigator.pop(context);
                    _showSetupSmsDialog();
                  },
                ),
                RadioListTile<String>(
                  title: Text('认证器应用'),
                  value: 'app',
                  groupValue: _twoFactorMethod,
                  onChanged: (value) {
                    setState(() => _twoFactorMethod = value!);
                    Navigator.pop(context);
                    _showSetupAppDialog();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
            ],
          ),
    );
  }

  void _showSetupSmsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('设置手机短信验证'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('我们将向您的手机号发送验证码'),
                SizedBox(height: 16),
                Text('手机号码: $_phone'),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: '验证码',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _twoFactorMethod = 'none');
                },
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('两步验证已启用')));
                },
                child: Text('验证'),
              ),
            ],
          ),
    );
  }

  void _showSetupAppDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('设置认证器应用'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('请使用认证器应用扫描以下二维码'),
                SizedBox(height: 16),
                Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(child: Text('二维码占位图')),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: '验证码',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _twoFactorMethod = 'none');
                },
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('两步验证已启用')));
                },
                child: Text('验证'),
              ),
            ],
          ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('注销账号'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '警告: 注销账号是永久性的操作，所有数据将被永久删除且无法恢复。',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: '输入密码确认',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: '输入"DELETE"确认',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('账号注销申请已提交')));
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('注销账号'),
              ),
            ],
          ),
    );
  }
}
