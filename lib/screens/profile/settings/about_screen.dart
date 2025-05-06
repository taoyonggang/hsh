import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用当前日期和时间
    final now = DateTime.utc(2025, 4, 30, 1, 0, 8);
    final buildVersion = '1.0.0';
    final buildNumber = '2025042901';

    return Scaffold(
      appBar: AppBar(title: Text('关于我们')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAppHeader(),
            SizedBox(height: 24),
            _buildVersionInfo(buildVersion, buildNumber),
            SizedBox(height: 24),
            _buildFeaturesList(),
            SizedBox(height: 24),
            _buildAboutCompany(),
            SizedBox(height: 24),
            _buildSocialLinks(context),
            SizedBox(height: 32),
            _buildFooter(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      color: Colors.green,
      child: Column(
        children: [
          FlutterLogo(size: 80),
          SizedBox(height: 16),
          Text(
            '汇升活健康搭子平台',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '重新定义社交关系网络',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo(String version, String buildNumber) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('版本', style: TextStyle(color: Colors.grey[600])),
              Text('v$version', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('构建编号', style: TextStyle(color: Colors.grey[600])),
              Text(buildNumber, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '主要功能',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.bubble_chart,
            title: '双网络系统',
            description: '真实社交网络与虚拟社交网络的完美结合',
          ),
          SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.health_and_safety,
            title: '健康管理',
            description: '全面的健康数据监测与分析',
          ),
          SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.trending_up,
            title: '运势预测',
            description: '基于多维数据的个性化运势分析',
          ),
          SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.people,
            title: '搭子匹配',
            description: '精准匹配志同道合的伙伴',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.green),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(description, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutCompany() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '关于公司',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            '汇升活健康科技有限公司成立于2020年，致力于通过创新的技术手段，重新定义人们的社交关系网络，促进人与人之间更健康、更有意义的连接。我们的使命是帮助每个人建立和维护真实且有价值的社交关系，同时关注用户的健康和幸福。',
            style: TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '关注我们',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                icon: Icons.language,
                label: '官网',
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('访问官网')));
                },
              ),
              _buildSocialButton(
                icon: Icons.wechat,
                label: '微信',
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('关注微信公众号')));
                },
              ),
              _buildSocialButton(
                icon: Icons.facebook,
                label: '微博',
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('关注微博')));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.green),
            SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text('© 2025 汇升活健康科技有限公司', style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: Colors.grey[600], height: 1.5),
              children: [
                TextSpan(text: '使用本应用表示您同意我们的'),
                TextSpan(
                  text: '用户协议',
                  style: TextStyle(
                    color: Colors.green,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          // 导航到用户协议页面
                        },
                ),
                TextSpan(text: '和'),
                TextSpan(
                  text: '隐私政策',
                  style: TextStyle(
                    color: Colors.green,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          // 导航到隐私政策页面
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
