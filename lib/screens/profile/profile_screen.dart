import 'package:flutter/material.dart';
import '../../models/user/user_profile.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/auth_controller.dart';
import 'social_network/social_network_screen.dart';
import 'social_network/virtual_network_screen.dart';
import 'messaging/messaging_center_screen.dart';
import 'privacy/privacy_settings_screen.dart';
import 'social_network/network_analysis_screen.dart';
import 'settings/settings_screen.dart';
import '../../widgets/app_bottom_navigation.dart'; // 添加导入底部导航栏组件

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController _userController = UserController();
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      _userProfile = await _userController.getUserProfile();
    } catch (e) {
      print('加载用户资料出错: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(child: _buildUserHeader()),
                  SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(child: _buildDoubleNetworkSection()),
                  SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(child: _buildCommunicationSection()),
                  SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(child: _buildPrivacySection()),
                  SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(child: _buildGeneralSettingsSection()),
                  SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(child: _buildLogoutButton()),
                  SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 4,
      ), // 添加底部导航栏，索引4对应"我的"选项
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      title: Text('个人中心'),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications_outlined),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
      ],
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage:
                    _userProfile?.avatarUrl != null
                        ? NetworkImage(_userProfile!.avatarUrl!)
                        : null,
                child:
                    _userProfile?.avatarUrl == null
                        ? Icon(Icons.person, size: 36)
                        : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _userProfile?.name ?? '用户',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Text(
                            '社交会员',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '会员有效期至: 2025-12-31',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStat('搭子', _userProfile?.partnerCount ?? 0),
                        SizedBox(width: 16),
                        _buildStat('活动', _userProfile?.activityCount ?? 0),
                        SizedBox(width: 16),
                        _buildStat('关系', _userProfile?.relationshipCount ?? 0),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.grey),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile/edit');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildDoubleNetworkSection() {
    return _buildSection(
      title: '双网络系统',
      icon: Icons.verified_user,
      color: Colors.indigo,
      items: [
        _buildMenuItem(
          icon: Icons.people,
          title: '真实关系网络',
          subtitle: '查看平台视角的用户关系网络',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SocialNetworkScreen()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.bubble_chart,
          title: '虚拟关系网络',
          subtitle: '管理您创建的个人关系网络',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VirtualNetworkScreen()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.compare_arrows,
          title: '网络对比分析',
          subtitle: '分析真实网络与虚拟网络的差异',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NetworkAnalysisScreen()),
            );
          },
          isPremium: true,
        ),
      ],
    );
  }

  Widget _buildCommunicationSection() {
    return _buildSection(
      title: '通讯中心',
      icon: Icons.chat,
      color: Colors.blue,
      items: [
        _buildMenuItem(
          icon: Icons.mail_outline,
          title: '私信',
          subtitle: '查看和管理个人私信',
          onTap: () {
            Navigator.pushNamed(context, '/messaging/direct');
          },
          badge: '3',
        ),
        _buildMenuItem(
          icon: Icons.group,
          title: '群组消息',
          subtitle: '查看和管理群组消息',
          onTap: () {
            Navigator.pushNamed(context, '/messaging/groups');
          },
        ),
        _buildMenuItem(
          icon: Icons.notifications,
          title: '系统通知',
          subtitle: '活动提醒、会员状态等系统通知',
          onTap: () {
            Navigator.pushNamed(context, '/notifications');
          },
          badge: '5',
        ),
        _buildMenuItem(
          icon: Icons.dashboard_customize,
          title: '通讯中心',
          subtitle: '管理所有通讯设置和数据',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MessagingCenterScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSection(
      title: '隐私与数据',
      icon: Icons.shield,
      color: Colors.deepPurple,
      items: [
        _buildMenuItem(
          icon: Icons.visibility,
          title: '隐私设置',
          subtitle: '控制个人信息的可见范围',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PrivacySettingsScreen()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.vpn_key,
          title: '数据授权管理',
          subtitle: '查看和管理数据授权记录',
          onTap: () {
            Navigator.pushNamed(context, '/privacy/authorizations');
          },
        ),
        _buildMenuItem(
          icon: Icons.link,
          title: '被映射管理',
          subtitle: '查看和管理您被映射的记录',
          onTap: () {
            Navigator.pushNamed(context, '/privacy/mappings');
          },
          badge: '新',
          badgeColor: Colors.orange,
        ),
        _buildMenuItem(
          icon: Icons.data_usage,
          title: '数据导出',
          subtitle: '导出您的个人数据',
          onTap: () {
            Navigator.pushNamed(context, '/privacy/data-export');
          },
        ),
      ],
    );
  }

  Widget _buildGeneralSettingsSection() {
    return _buildSection(
      title: '通用设置',
      icon: Icons.settings,
      color: Colors.blueGrey,
      items: [
        _buildMenuItem(
          icon: Icons.account_circle,
          title: '账户管理',
          subtitle: '管理您的账户信息和安全设置',
          onTap: () {
            Navigator.pushNamed(context, '/settings/account');
          },
        ),
        _buildMenuItem(
          icon: Icons.card_membership,
          title: '会员管理',
          subtitle: '管理会员订阅和查看特权',
          onTap: () {
            Navigator.pushNamed(context, '/settings/membership');
          },
        ),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: '帮助与反馈',
          subtitle: '获取帮助或提交反馈',
          onTap: () {
            Navigator.pushNamed(context, '/settings/help');
          },
        ),
        _buildMenuItem(
          icon: Icons.info_outline,
          title: '关于我们',
          subtitle: '了解应用信息和使用条款',
          onTap: () {
            Navigator.pushNamed(context, '/settings/about');
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> items,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPremium = false,
    String? badge,
    Color badgeColor = Colors.red,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700]),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isPremium) ...[
                        SizedBox(width: 8),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                      ],
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton(
        onPressed: () {
          _showLogoutConfirmation();
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          '退出登录',
          style: TextStyle(color: Colors.grey[700], fontSize: 16),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('退出登录'),
            content: Text('确定要退出当前账号吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // 实际应用中这里会调用登出方法
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('确定'),
              ),
            ],
          ),
    );
  }
}
