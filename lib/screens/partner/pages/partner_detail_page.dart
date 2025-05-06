import 'package:flutter/material.dart';
import '../../../models/partner/partner_group.dart';
import '../../../models/partner/partner_activity.dart';
import '../../../controllers/partner_controller.dart';
import '../widgets/member_avatar_grid.dart';
import '../widgets/activity_card.dart';

class PartnerDetailPage extends StatefulWidget {
  final PartnerGroup partner;

  const PartnerDetailPage({super.key, required this.partner});

  @override
  _PartnerDetailPageState createState() => _PartnerDetailPageState();
}

class _PartnerDetailPageState extends State<PartnerDetailPage> {
  final PartnerController _controller = PartnerController();
  bool _isLoading = true;
  late PartnerGroup _partnerDetail;
  List<PartnerActivity> _activities = [];
  bool _isMember = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _partnerDetail = widget.partner;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      _partnerDetail = await _controller.getPartnerGroupDetail(
        _partnerDetail.id,
      );
      _activities = await _controller.getPartnerActivities(_partnerDetail.id);
      _isMember = await _controller.isUserMemberOf(_partnerDetail.id);
      _isAdmin = await _controller.isUserAdminOf(_partnerDetail.id);
    } catch (e) {
      print('加载搭子详情错误: $e');
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
                  _buildSliverAppBar(),
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildPartnerInfo(),
                        SizedBox(height: 24),
                        _buildMembersSection(),
                        SizedBox(height: 24),
                        _buildActivitiesSection(),
                        SizedBox(height: 40),
                      ]),
                    ),
                  ),
                ],
              ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _partnerDetail.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black45,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(_partnerDetail.coverImageUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_isAdmin)
          IconButton(
            icon: Icon(Icons.edit),
            onPressed:
                () => Navigator.pushNamed(
                  context,
                  '/partner/edit',
                  arguments: _partnerDetail,
                ),
          ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'share':
                // 分享搭子
                break;
              case 'report':
                // 举报搭子
                break;
              case 'leave':
                if (_isMember) {
                  _showLeaveDialog();
                }
                break;
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('分享搭子'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'report',
                  child: ListTile(
                    leading: Icon(Icons.flag),
                    title: Text('举报'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (_isMember && !_isAdmin)
                  PopupMenuItem(
                    value: 'leave',
                    child: ListTile(
                      leading: Icon(Icons.exit_to_app, color: Colors.red),
                      title: Text('退出搭子', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
        ),
      ],
    );
  }

  Widget _buildPartnerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _partnerDetail.isPrivate ? Icons.lock : Icons.public,
              size: 16,
              color: Colors.grey[600],
            ),
            SizedBox(width: 4),
            Text(
              _partnerDetail.isPrivate ? '私密搭子' : '公开搭子',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Spacer(),
            Text(
              '创建于 ${_partnerDetail.creationDate}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(_partnerDetail.description, style: TextStyle(fontSize: 15)),
        SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _partnerDetail.tags.map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '搭子成员',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_isMember)
              TextButton.icon(
                icon: Icon(Icons.people),
                label: Text('查看全部'),
                onPressed:
                    () => Navigator.pushNamed(
                      context,
                      '/partner/members',
                      arguments: _partnerDetail,
                    ),
              ),
          ],
        ),
        SizedBox(height: 16),
        MemberAvatarGrid(
          members: _partnerDetail.members,
          maxDisplayCount: 8,
          onTap: (member) {
            // 查看成员详情
            Navigator.pushNamed(context, '/user/profile', arguments: member);
          },
        ),
      ],
    );
  }

  Widget _buildActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '搭子活动',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_isMember)
              TextButton.icon(
                icon: Icon(Icons.event),
                label: Text('全部活动'),
                onPressed:
                    () => Navigator.pushNamed(
                      context,
                      '/partner/activities',
                      arguments: _partnerDetail,
                    ),
              ),
          ],
        ),
        SizedBox(height: 16),
        _activities.isEmpty
            ? _buildEmptyActivities()
            : Column(
              children:
                  _activities.map((activity) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: ActivityCard(
                        activity: activity,
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              '/activity/detail',
                              arguments: activity,
                            ),
                      ),
                    );
                  }).toList(),
            ),
      ],
    );
  }

  Widget _buildEmptyActivities() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Image.asset('assets/images/empty_activities.png', height: 120),
          SizedBox(height: 16),
          Text(
            '暂无活动',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            _isMember ? '创建一个活动，邀请搭子一起参与吧' : '加入搭子，参与精彩活动',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          if (_isMember) ...[
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('创建活动'),
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    '/activity/create',
                    arguments: _partnerDetail,
                  ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_isMember) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.chat),
                  label: Text('搭子聊天'),
                  onPressed:
                      () => Navigator.pushNamed(
                        context,
                        '/partner/chat',
                        arguments: _partnerDetail,
                      ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('发起活动'),
                  onPressed:
                      () => Navigator.pushNamed(
                        context,
                        '/activity/create',
                        arguments: _partnerDetail,
                      ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _showJoinDialog,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text('申请加入'),
          ),
        ),
      );
    }
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? message;

        return AlertDialog(
          title: Text('申请加入${_partnerDetail.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_partnerDetail.requiresApproval) ...[
                Text('请输入申请理由，管理员审核后会通知你'),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: '我想加入是因为...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) => message = value,
                ),
              ] else
                {Text('确定要加入该搭子吗？')},
            ],
          ),
          actions: [
            TextButton(
              child: Text('取消'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('确定'),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final success = await _controller.joinPartnerGroup(
                    _partnerDetail.id,
                    message: message,
                  );

                  if (success) {
                    if (_partnerDetail.requiresApproval) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('申请已提交，等待审核')));
                    } else {
                      setState(() {
                        _isMember = true;
                      });
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('已成功加入搭子')));
                    }
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('加入失败，请稍后重试')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showLeaveDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('退出搭子'),
          content: Text('确定要退出"${_partnerDetail.name}"吗？退出后将不再接收搭子的消息和活动通知。'),
          actions: [
            TextButton(
              child: Text('取消'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final success = await _controller.leavePartnerGroup(
                    _partnerDetail.id,
                  );

                  if (success) {
                    setState(() {
                      _isMember = false;
                    });
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('已退出搭子')));
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('操作失败，请稍后重试')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
                }
              },
              child: Text('确定退出'),
            ),
          ],
        );
      },
    );
  }
}
