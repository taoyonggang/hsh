import 'package:flutter/material.dart';
import '../../api/mock_api_service.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with SingleTickerProviderStateMixin {
  final MockApiService _apiService = MockApiService();
  bool _isLoading = true;
  List<dynamic>? _socialFeeds;
  List<dynamic>? _socialGroups;
  List<dynamic>? _socialActivities;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _socialFeeds = await _apiService.getSocialFeeds();
      _socialGroups = await _apiService.getSocialGroups();
      _socialActivities = await _apiService.getSocialActivities();
    } catch (e) {
      print('Error loading social data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('社交圈'),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _loadData)],
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: '动态'), Tab(text: '社群'), Tab(text: '活动')],
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildFeedsTab(),
                  _buildGroupsTab(),
                  _buildActivitiesTab(),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // 根据当前标签创建帖子、群组或活动
          int currentTab = _tabController.index;
          String action =
              currentTab == 0
                  ? "动态"
                  : currentTab == 1
                  ? "社群"
                  : "活动";
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('创建新$action')));
        },
      ),
    );
  }

  Widget _buildFeedsTab() {
    if (_socialFeeds == null || _socialFeeds!.isEmpty) {
      return Center(child: Text('暂无社交动态'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _socialFeeds!.length,
      itemBuilder: (context, index) {
        final feed = _socialFeeds![index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(backgroundImage: NetworkImage(feed['avatar'])),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feed['user'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          feed['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(feed['content']),
              ),
              if (feed['image'] != null) ...[
                SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(feed['image']),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      Icons.thumb_up_outlined,
                      '${feed['likes']}',
                      '点赞',
                    ),
                    _buildActionButton(
                      Icons.comment_outlined,
                      '${feed['comments']}',
                      '评论',
                    ),
                    _buildActionButton(Icons.share_outlined, '分享', '分享'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String text, String action) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$action 点击')));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[700]),
            SizedBox(width: 4),
            Text(text, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsTab() {
    if (_socialGroups == null || _socialGroups!.isEmpty) {
      return Center(child: Text('暂无社群'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _socialGroups!.length,
      itemBuilder: (context, index) {
        final group = _socialGroups![index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  group['coverUrl'],
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      group['description'],
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildGroupStat(
                          Icons.people,
                          '${group['memberCount']}',
                          '成员',
                        ),
                        SizedBox(width: 24),
                        _buildGroupStat(
                          Icons.event,
                          '${group['activityCount']}',
                          '活动',
                        ),
                        Spacer(),
                        Text(
                          '最近活跃: ${group['lastActive']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          icon: Icon(Icons.info_outline),
                          label: Text('了解更多'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('查看${group['name']}详情')),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.people),
                          label: Text('加入社群'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('加入${group['name']}')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColor),
        SizedBox(width: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildActivitiesTab() {
    if (_socialActivities == null || _socialActivities!.isEmpty) {
      return Center(child: Text('暂无活动'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _socialActivities!.length,
      itemBuilder: (context, index) {
        final activity = _socialActivities![index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      activity['coverUrl'],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _formatActivityDate(activity['startTime']),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[700],
                        ),
                        SizedBox(width: 4),
                        Text(
                          activity['location'],
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[700],
                        ),
                        SizedBox(width: 4),
                        Text(
                          _formatActivityTime(activity['startTime']),
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      activity['description'],
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildAttendeeStatus(
                          activity['participantCount'],
                          activity['maxParticipants'],
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('参加${activity['title']}')),
                            );
                          },
                          child: Text('参加活动'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatActivityDate(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
    } catch (e) {
      return '待定';
    }
  }

  String _formatActivityTime(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      String period = dateTime.hour >= 12 ? '下午' : '上午';
      int hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      hour = hour == 0 ? 12 : hour;
      String minute = dateTime.minute.toString().padLeft(2, '0');
      return '$period $hour:$minute';
    } catch (e) {
      return '待定';
    }
  }

  Widget _buildAttendeeStatus(int current, int max) {
    double percentage = current / max;
    Color statusColor =
        percentage > 0.8
            ? Colors.red
            : percentage > 0.5
            ? Colors.orange
            : Colors.green;

    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              strokeWidth: 6,
            ),
            Text(
              '$current/$max',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        SizedBox(width: 12),
        Text(
          percentage >= 1.0
              ? '已满'
              : percentage > 0.8
              ? '即将满员'
              : percentage > 0.5
              ? '正在招募'
              : '招募中',
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
