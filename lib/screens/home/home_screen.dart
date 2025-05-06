import 'package:flutter/material.dart';
import '../../api/mock_api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  List<dynamic> _feeds = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSocialFeeds();
  }

  Future<void> _loadSocialFeeds() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 使用mock数据服务来获取社交动态
      final feeds = await MockApiService().getSocialFeeds();

      setState(() {
        _feeds = feeds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '无法加载动态: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final username = authService.currentUsername;
    final isLoggedIn = authService.isLoggedIn;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('汇升活健康搭子平台'),
        actions: [
          if (!isLoggedIn)
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('登录', style: TextStyle(color: Colors.white)),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Text('欢迎, $username', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/men/32.jpg',
                      ),
                      radius: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: AppBottomNavigation(currentIndex: 0),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(_errorMessage),
            SizedBox(height: 24),
            ElevatedButton(onPressed: _loadSocialFeeds, child: Text('重试')),
          ],
        ),
      );
    }

    if (_feeds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feed, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无动态'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSocialFeeds,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _feeds.length,
        itemBuilder: (context, index) {
          final feed = _feeds[index];
          return _buildFeedCard(feed);
        },
      ),
    );
  }

  Widget _buildFeedCard(Map<String, dynamic> feed) {
    // 获取作者信息
    final String authorName = feed['authorName'] ?? '未知用户';
    final String authorAvatar =
        feed['authorAvatar'] ??
        'https://randomuser.me/api/portraits/lego/1.jpg';
    final String content = feed['content'] ?? '无内容';
    final List<dynamic> imageUrls = feed['imageUrls'] ?? [];
    final int likeCount = feed['likeCount'] ?? 0;
    final int commentCount = feed['commentCount'] ?? 0;
    final String timestamp = feed['timestamp'] ?? '';
    final String location = feed['location'] ?? '';

    DateTime? dateTime;
    String timeAgo = '';

    try {
      dateTime = DateTime.parse(timestamp);
      // 当前时间是 2025-05-06 07:26:17
      final now = DateTime.utc(2025, 5, 6, 7, 26, 17);
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        timeAgo = '${difference.inDays}天前';
      } else if (difference.inHours > 0) {
        timeAgo = '${difference.inHours}小时前';
      } else if (difference.inMinutes > 0) {
        timeAgo = '${difference.inMinutes}分钟前';
      } else {
        timeAgo = '刚刚';
      }
    } catch (e) {
      timeAgo = '未知时间';
    }

    // 判断是否是当前登录用户的动态
    final bool isCurrentUserPost = authorName.toLowerCase() == 'taoyonggang';

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isCurrentUserPost
                ? BorderSide(color: Colors.green.shade200, width: 1.5)
                : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(authorAvatar)),
            title: Row(
              children: [
                Text(authorName, style: TextStyle(fontWeight: FontWeight.bold)),
                if (isCurrentUserPost)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.verified_user,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
              ],
            ),
            subtitle: Text(location),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeAgo, style: TextStyle(color: Colors.grey)),
                SizedBox(height: 4),
                if (isCurrentUserPost)
                  Text(
                    '我的动态',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(content),
          ),
          if (imageUrls.isNotEmpty) ...[
            SizedBox(height: 8),
            _buildImageGallery(imageUrls),
          ],
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.thumb_up_outlined, '$likeCount 赞', () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('已点赞')));
                }),
                _buildActionButton(
                  Icons.comment_outlined,
                  '$commentCount 评论',
                  () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('评论功能开发中...')));
                  },
                ),
                _buildActionButton(Icons.share_outlined, '分享', () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('分享功能开发中...')));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<dynamic> imageUrls) {
    if (imageUrls.length == 1) {
      return Container(
        height: 200,
        width: double.infinity,
        child: ClipRRect(child: Image.network(imageUrls[0], fit: BoxFit.cover)),
      );
    }

    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16 : 8,
              right: index == imageUrls.length - 1 ? 16 : 0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrls[index],
                width: 160,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [Icon(icon, size: 18), SizedBox(width: 4), Text(label)],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // 修改这一行，使用正确的枚举类型
      currentIndex: 0,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0: // 首页已经在当前页
            break;
          case 1: // 健康
            Navigator.pushNamed(context, '/health');
            break;
          case 2: // 运势
            Navigator.pushNamed(context, '/fortune');
            break;
          case 3: // 搭子
            Navigator.pushNamed(context, '/partner');
            break;
          case 4: // 我的
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '健康'),
        BottomNavigationBarItem(icon: Icon(Icons.star), label: '运势'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: '搭子'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => _buildCreatePostSheet(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        );
      },
      backgroundColor: Colors.green,
      child: Icon(Icons.add),
      tooltip: '发布动态',
    );
  }

  Widget _buildCreatePostSheet() {
    return Container(
      padding: EdgeInsets.all(16),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '发布动态',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: TextField(
              maxLines: null,
              decoration: InputDecoration(
                hintText: '分享你的健康生活...',
                border: InputBorder.none,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.image, color: Colors.green),
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('添加图片功能开发中...')));
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.tag, color: Colors.green),
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('添加标签功能开发中...')));
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.location_on, color: Colors.green),
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('添加位置功能开发中...')));
                  Navigator.pop(context);
                },
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('动态发布成功！')));
                  // 这里可以添加刷新动态列表的逻辑
                  _loadSocialFeeds();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('发布'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
