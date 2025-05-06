import 'package:flutter/material.dart';
import '../../../app/routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: ListView(
        children: [
          _buildSection(
            context,
            title: '账号管理',
            icon: Icons.person,
            items: [
              SettingItem(
                title: '账号与安全',
                icon: Icons.security,
                route: Routes.accountSettings,
              ),
              SettingItem(
                title: '会员管理',
                icon: Icons.card_membership,
                route: Routes.membershipSettings,
              ),
            ],
          ),
          _buildSection(
            context,
            title: '隐私与数据',
            icon: Icons.shield,
            items: [
              SettingItem(
                title: '隐私设置',
                icon: Icons.privacy_tip,
                route: Routes.privacySettings,
              ),
              SettingItem(
                title: '数据授权管理',
                icon: Icons.verified_user,
                route: Routes.authorizations,
              ),
              SettingItem(
                title: '被映射管理',
                icon: Icons.link,
                route: Routes.mappings,
              ),
              SettingItem(
                title: '屏蔽用户',
                icon: Icons.block,
                route: Routes.blockedUsers,
              ),
              SettingItem(
                title: '导出个人数据',
                icon: Icons.download,
                route: Routes.dataExport,
              ),
            ],
          ),
          _buildSection(
            context,
            title: '消息设置',
            icon: Icons.message,
            items: [
              SettingItem(
                title: '消息通知设置',
                icon: Icons.notifications,
                route: Routes.messageSettings,
              ),
            ],
          ),
          _buildSection(
            context,
            title: '关于',
            icon: Icons.info,
            items: [
              SettingItem(title: '帮助与反馈', icon: Icons.help, route: Routes.help),
              SettingItem(
                title: '关于我们',
                icon: Icons.info_outline,
                route: Routes.about,
              ),
              SettingItem(
                title: '用户协议',
                icon: Icons.description,
                route: Routes.terms,
              ),
              SettingItem(
                title: '隐私政策',
                icon: Icons.policy,
                route: Routes.privacyPolicy,
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                _showLogoutDialog(context);
              },
              child: Text('退出登录'),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<SettingItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            children: [
              Icon(icon, color: Colors.green),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(items.length * 2 - 1, (index) {
              if (index.isOdd) {
                return Divider(height: 1, indent: 70);
              }
              final itemIndex = index ~/ 2;
              return _buildSettingItem(context, items[itemIndex]);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(BuildContext context, SettingItem item) {
    return ListTile(
      leading: Icon(item.icon, color: Colors.grey[600]),
      title: Text(item.title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        if (item.route != null) {
          Navigator.pushNamed(context, item.route!);
        }
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('退出登录'),
            content: Text('确定要退出登录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // 退出登录逻辑
                  Navigator.pushReplacementNamed(context, Routes.login);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('确定'),
              ),
            ],
          ),
    );
  }
}

class SettingItem {
  final String title;
  final IconData icon;
  final String? route;
  final VoidCallback? onTap;

  SettingItem({
    required this.title,
    required this.icon,
    this.route,
    this.onTap,
  });
}
