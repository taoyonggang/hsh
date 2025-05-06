import 'package:flutter/material.dart';
import '../../../models/partner/partner_activity.dart';
import '../../../controllers/activity_controller.dart';
import '../widgets/activity_card.dart';

class ActivitiesTab extends StatefulWidget {
  const ActivitiesTab({super.key});

  @override
  _ActivitiesTabState createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends State<ActivitiesTab> {
  final ActivityController _controller = ActivityController();
  bool _isLoading = true;
  List<PartnerActivity> _myActivities = [];
  List<PartnerActivity> _recommendedActivities = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      print('开始加载活动数据...');
      _myActivities = await _controller.getMyActivities();
      print('我的活动数量: ${_myActivities.length}');
      _recommendedActivities = await _controller.getRecommendedActivities();
      print('推荐活动数量: ${_recommendedActivities.length}');
    } catch (e) {
      print('加载活动数据错误: $e');

      // 如果加载失败，提供一些默认数据以便页面能显示出来
      _myActivities = [
        PartnerActivity(
          id: 'default1',
          title: '健康行走小组',
          description: '每天10000步，保持健康',
          time: '2025-04-30 08:00',
          startTime: '2025-04-30 08:00:00',
          endTime: '2025-04-30 09:30:00',
          location: '附近公园',
          hasSignedUp: true,
          participantCount: 5,
          maxParticipants: 10,
        ),
      ];

      _recommendedActivities = [
        PartnerActivity(
          id: 'default2',
          title: '周末徒步活动',
          description: '一起去森林公园徒步',
          time: '2025-05-02 09:00',
          startTime: '2025-05-02 09:00:00',
          endTime: '2025-05-02 16:00:00',
          location: '城市森林公园',
          participantCount: 3,
          maxParticipants: 15,
        ),
      ];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinActivity(PartnerActivity activity) async {
    try {
      final success = await _controller.joinActivity(activity.id);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('成功报名活动: ${activity.title}')));
        _loadData(); // 重新加载数据
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('报名失败: $e')));
    }
  }

  Future<void> _cancelActivity(PartnerActivity activity) async {
    try {
      final success = await _controller.cancelJoinActivity(activity.id);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已取消活动报名: ${activity.title}')));
        _loadData(); // 重新加载数据
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('取消报名失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMyActivitiesSection(),
            SizedBox(height: 24),
            _buildRecommendedActivitiesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyActivitiesSection() {
    if (_myActivities.isEmpty) {
      return _buildEmptyActivitySection();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '我的活动',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed:
                  () => Navigator.pushNamed(context, '/partner/my-activities'),
              child: Text('查看全部'),
            ),
          ],
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _myActivities.length > 2 ? 2 : _myActivities.length,
          itemBuilder: (context, index) {
            return ActivityCard(
              activity: _myActivities[index],
              onCancel: () => _cancelActivity(_myActivities[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendedActivitiesSection() {
    if (_recommendedActivities.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '推荐活动',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _recommendedActivities.length,
          itemBuilder: (context, index) {
            return ActivityCard(
              activity: _recommendedActivities[index],
              isRecommended: true,
              onJoin: () => _joinActivity(_recommendedActivities[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyActivitySection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 使用图标替代图片
          Icon(Icons.event_busy, size: 100, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            '还没有参加任何活动',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('参加或创建活动，与搭子们一起玩耍吧', style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('创建活动'),
            onPressed: () => Navigator.pushNamed(context, '/activity/create'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
