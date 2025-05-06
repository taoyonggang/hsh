import 'package:flutter/material.dart';

class MembershipSettingsScreen extends StatefulWidget {
  const MembershipSettingsScreen({super.key});

  @override
  _MembershipSettingsScreenState createState() =>
      _MembershipSettingsScreenState();
}

class _MembershipSettingsScreenState extends State<MembershipSettingsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _membershipInfo = {};
  List<Map<String, dynamic>> _membershipPlans = [];

  @override
  void initState() {
    super.initState();
    _loadMembershipInfo();
  }

  Future<void> _loadMembershipInfo() async {
    setState(() => _isLoading = true);
    try {
      // 模拟加载会员信息
      await Future.delayed(Duration(milliseconds: 800));

      _membershipInfo = {
        'isSocialMember': true,
        'isHealthMember': false,
        'socialMemberExpiry': DateTime(2025, 12, 31),
        'healthMemberExpiry': null,
        'autoRenew': true,
        'paymentMethod': '支付宝',
        'lastPayment': DateTime(2025, 1, 1),
        'nextPayment': DateTime(2025, 12, 1),
        'price': 99.0,
      };

      _membershipPlans = [
        {
          'id': 'social_monthly',
          'name': '搭子月度会员',
          'price': 9.9,
          'period': '月',
          'features': ['虚拟关系网络创建', '网络对比分析', '无限消息', '优先客服支持'],
        },
        {
          'id': 'social_yearly',
          'name': '搭子年度会员',
          'price': 99.0,
          'period': '年',
          'features': [
            '虚拟关系网络创建',
            '网络对比分析',
            '无限消息',
            '优先客服支持',
            '会员专属主题',
            '专属徽章',
          ],
          'isBestValue': true,
        },
        {
          'id': 'health_monthly',
          'name': '健康月度会员',
          'price': 19.9,
          'period': '月',
          'features': ['详细健康分析', '个性化健康建议', '运势健康匹配', '专家在线咨询'],
        },
        {
          'id': 'health_yearly',
          'name': '健康年度会员',
          'price': 199.0,
          'period': '年',
          'features': [
            '详细健康分析',
            '个性化健康建议',
            '运势健康匹配',
            '专家在线咨询',
            '年度健康报告',
            '专属健康顾问',
          ],
        },
        {
          'id': 'premium',
          'name': '尊享会员',
          'price': 299.0,
          'period': '年',
          'features': ['包含所有搭子会员特权', '包含所有健康会员特权', '最优先客服支持', 'VIP专属活动邀请'],
          'isPremium': true,
        },
      ];
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载会员信息失败: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _renewMembership() async {
    Navigator.pushNamed(context, '/payments/checkout');
  }

  Future<void> _cancelAutoRenewal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('取消自动续费'),
            content: Text('确定要取消自动续费吗？您的会员资格将在到期后终止。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('返回'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('确定取消'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _membershipInfo['autoRenew'] = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('自动续费已取消')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('会员管理')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMembershipCard(),
                    SizedBox(height: 16),
                    _buildMembershipDetailsSection(),
                    SizedBox(height: 24),
                    _buildMembershipPlansSection(),
                    SizedBox(height: 24),
                    _buildMembershipBenefitsSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildMembershipCard() {
    final isSocialMember = _membershipInfo['isSocialMember'] ?? false;
    final isHealthMember = _membershipInfo['isHealthMember'] ?? false;

    final socialExpiry = _membershipInfo['socialMemberExpiry'];
    final healthExpiry = _membershipInfo['healthMemberExpiry'];

    String expiryText = '';
    if (isSocialMember && isHealthMember) {
      expiryText = '有效期至: ${_formatDate(socialExpiry)}';
    } else if (isSocialMember) {
      expiryText = '搭子会员有效期至: ${_formatDate(socialExpiry)}';
    } else if (isHealthMember) {
      expiryText = '健康会员有效期至: ${_formatDate(healthExpiry)}';
    } else {
      expiryText = '您还不是会员';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: Colors.white, size: 32),
              SizedBox(width: 8),
              Text(
                isSocialMember && isHealthMember
                    ? '尊享会员'
                    : isSocialMember
                    ? '社交会员'
                    : isHealthMember
                    ? '健康会员'
                    : '普通用户',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            expiryText,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '用户: taoyonggang',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          if (isSocialMember || isHealthMember) ...[
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _renewMembership,
                  icon: Icon(Icons.refresh),
                  label: Text('续费'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade700,
                  ),
                ),
                SizedBox(width: 16),
                TextButton.icon(
                  onPressed: _cancelAutoRenewal,
                  icon: Icon(Icons.cancel),
                  label: Text('取消自动续费'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                ),
              ],
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/payments/checkout');
              },
              icon: Icon(Icons.add_circle),
              label: Text('立即开通会员'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green.shade700,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMembershipDetailsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '会员详情',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow(
                    '会员状态',
                    _membershipInfo['isSocialMember'] ? '社交会员 (活跃)' : '未开通',
                  ),
                  Divider(),
                  _buildDetailRow(
                    '自动续费',
                    _membershipInfo['autoRenew'] ? '已开启' : '已关闭',
                  ),
                  Divider(),
                  _buildDetailRow(
                    '付款方式',
                    _membershipInfo['paymentMethod'] ?? '-',
                  ),
                  Divider(),
                  _buildDetailRow(
                    '上次付款',
                    _formatDate(_membershipInfo['lastPayment']),
                  ),
                  Divider(),
                  _buildDetailRow(
                    '下次付款',
                    _formatDate(_membershipInfo['nextPayment']),
                  ),
                  Divider(),
                  _buildDetailRow(
                    '会员费用',
                    '¥${_membershipInfo['price']?.toString() ?? '0.00'}/年',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipPlansSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '会员方案',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _membershipPlans.length,
              itemBuilder: (context, index) {
                return _buildPlanCard(_membershipPlans[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final bool isBestValue = plan['isBestValue'] ?? false;
    final bool isPremium = plan['isPremium'] ?? false;

    return Container(
      width: 220,
      margin: EdgeInsets.only(right: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                isPremium
                    ? Colors.amber
                    : (isBestValue ? Colors.green : Colors.transparent),
            width: isPremium || isBestValue ? 2 : 0,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isPremium ? Colors.amber.shade800 : null,
                    ),
                  ),
                  SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '¥${plan['price']} ',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '/ ${plan['period']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/payments/checkout',
                          arguments: plan['id'],
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isPremium ? Colors.amber : Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text('订阅'),
                    ),
                  ),
                ],
              ),
            ),
            if (isBestValue || isPremium)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPremium ? Colors.amber : Colors.green,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    isPremium ? '尊享特权' : '最优惠',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipBenefitsSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '会员特权',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildBenefitItem(
                    icon: Icons.bubble_chart,
                    title: '创建虚拟关系网络',
                    description: '自由创建和管理您的虚拟社交关系网络',
                  ),
                  Divider(),
                  _buildBenefitItem(
                    icon: Icons.compare_arrows,
                    title: '网络对比分析',
                    description: '分析真实与虚拟网络的差异，发现潜在社交机会',
                  ),
                  Divider(),
                  _buildBenefitItem(
                    icon: Icons.message,
                    title: '无限消息',
                    description: '无限制发送私信和参与群聊',
                  ),
                  Divider(),
                  _buildBenefitItem(
                    icon: Icons.support_agent,
                    title: '优先客服支持',
                    description: '享受专属客服和更快的响应速度',
                  ),
                  Divider(),
                  _buildBenefitItem(
                    icon: Icons.star,
                    title: '专属徽章',
                    description: '在社交网络中展示您的会员身份',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
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
      ),
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return '${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)}';
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}
