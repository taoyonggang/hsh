import 'package:flutter/material.dart';
import '../../api/mock_api_service.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final DateTime currentDate;

  const HomeScreen({
    super.key,
    required this.username,
    required this.currentDate,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MockApiService _apiService = MockApiService();

  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _healthOverview;
  List<dynamic>? _socialFeeds;
  bool _isLoading = true;
  String _formattedDate = '';

  @override
  void initState() {
    super.initState();
    // 格式化当前日期
    _formattedDate =
        '${widget.currentDate.year}年${widget.currentDate.month}月${widget.currentDate.day}日';
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _userProfile = await _apiService.getUserProfile();
      // 更新用户名称为当前登录用户
      if (_userProfile != null) {
        _userProfile!['username'] = widget.username;
      }
      _healthOverview = await _apiService.getHealthOverview();
      _socialFeeds = await _apiService.getSocialFeeds();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('汇升活健康搭子平台'),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_outlined),
            ),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('您有3条新消息')));
            },
          ),
          IconButton(
            icon: Badge(label: Text('2'), child: Icon(Icons.message_outlined)),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('您有2条未读私信')));
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateHeader(),
                      _buildUserHeader(),
                      _buildHealthOverview(),
                      _buildSectionTitle('搭子动态', '查看全部'),
                      _buildSocialFeeds(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        '今日 $_formattedDate',
        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildUserHeader() {
    if (_userProfile == null) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Center(child: Text("加载中...")),
      );
    }

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                _userProfile!['avatar'] != null
                    ? NetworkImage(_userProfile!['avatar'])
                    : null,
            child: _userProfile!['avatar'] == null ? Icon(Icons.person) : null,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '您好，${_userProfile!['username'] ?? "用户"}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  _getMembershipText(),
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '签到',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthOverview() {
    if (_healthOverview == null) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text("加载健康数据中...")),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '健康概览',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          GridView.count(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildHealthCard(
                '步数',
                '${_healthOverview!['steps'] ?? "0"}',
                Icons.directions_walk,
              ),
              _buildHealthCard(
                '卡路里',
                '${_healthOverview!['calories'] ?? "0"}',
                Icons.local_fire_department,
              ),
              _buildHealthCard(
                '心率',
                '${_healthOverview!['heartRate'] ?? "0 bpm"}',
                Icons.favorite,
              ),
              _buildHealthCard(
                '睡眠',
                '${_healthOverview!['sleep'] ?? "0小时"}',
                Icons.bedtime,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            SizedBox(height: 8),
            Text(title),
            SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String action) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () {
              // 导航到搭子标签页
              final MainNavigationScreen? navScreen =
                  context.findAncestorWidgetOfExactType<MainNavigationScreen>();
              if (navScreen != null) {
                final BottomNavigationBar? navBar =
                    context
                            .findAncestorWidgetOfExactType<Scaffold>()
                            ?.bottomNavigationBar
                        as BottomNavigationBar?;
                if (navBar != null) {
                  navBar.onTap!(3); // 搭子标签的索引
                }
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              child: Text(
                action,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialFeeds() {
    if (_socialFeeds == null || _socialFeeds!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text("暂无搭子动态")),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount:
          _socialFeeds!.length > 2 ? 2 : _socialFeeds!.length, // 首页只显示2条动态
      itemBuilder: (context, index) {
        final feed = _socialFeeds![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息行
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          feed['avatar'] != null
                              ? NetworkImage(feed['avatar'])
                              : null,
                      child: feed['avatar'] == null ? Icon(Icons.person) : null,
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feed['user'] ?? "用户",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          feed['time'] ?? "刚刚",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // 内容
                Text(feed['content'] ?? ""),
                if (feed['image'] != null) ...[
                  SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(feed['image']),
                  ),
                ],
                SizedBox(height: 12),
                // 点赞和评论
                Row(
                  children: [
                    _buildSocialAction(
                      Icons.favorite_border,
                      '${feed['likes'] ?? 0}',
                      '点赞',
                    ),
                    SizedBox(width: 16),
                    _buildSocialAction(
                      Icons.comment_outlined,
                      '${feed['comments'] ?? 0}',
                      '评论',
                    ),
                    SizedBox(width: 16),
                    _buildSocialAction(Icons.share_outlined, '分享', '分享'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialAction(IconData icon, String text, String action) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$action成功')));
      },
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  String _getMembershipText() {
    if (_userProfile == null || !_userProfile!.containsKey('membershipInfo')) {
      return '普通用户';
    }

    var membershipInfo = _userProfile!['membershipInfo'];
    if (membershipInfo == null || membershipInfo is! Map) {
      return '普通用户';
    }

    List<String> memberships = [];
    if (membershipInfo['healthMember'] == true) memberships.add('健康会员');
    if (membershipInfo['partnerMember'] == true) memberships.add('搭子会员');
    return memberships.isEmpty ? '普通用户' : memberships.join(' · ');
  }
}
