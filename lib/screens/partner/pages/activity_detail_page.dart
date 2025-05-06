import 'package:flutter/material.dart';
import '../../../models/partner/partner_activity.dart';
import '../../../controllers/activity_controller.dart';
import '../widgets/member_avatar_grid.dart';

class ActivityDetailPage extends StatefulWidget {
  final PartnerActivity activity;

  const ActivityDetailPage({super.key, required this.activity});

  @override
  _ActivityDetailPageState createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  final ActivityController _controller = ActivityController();
  bool _isLoading = true;
  late PartnerActivity _activityDetail;
  bool _hasSignedUp = false;
  bool _isCreator = false;

  @override
  void initState() {
    super.initState();
    _activityDetail = widget.activity;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      _activityDetail = await _controller.getActivityDetail(_activityDetail.id);
      _hasSignedUp = await _controller.hasUserSignedUp(_activityDetail.id);
      _isCreator = await _controller.isUserCreatorOf(_activityDetail.id);
    } catch (e) {
      print('加载活动详情错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPast = DateTime.parse(
      _activityDetail.endTime,
    ).isBefore(DateTime.now());

    return Scaffold(
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : CustomScrollView(
                slivers: [
                  _buildSliverAppBar(isPast),
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildActivityHeader(),
                        SizedBox(height: 16),
                        _buildActivityInfo(),
                        SizedBox(height: 16),
                        _buildActivityDescription(),
                        SizedBox(height: 24),
                        _buildParticipantsSection(),
                        SizedBox(height: 40),
                      ]),
                    ),
                  ),
                ],
              ),
      bottomNavigationBar: _buildBottomBar(isPast),
    );
  }

  Widget _buildSliverAppBar(bool isPast) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _activityDetail.title,
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
            Image.network(_activityDetail.coverImageUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            if (isPast)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      '活动已结束',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (_isCreator)
          IconButton(
            icon: Icon(Icons.edit),
            onPressed:
                () => Navigator.pushNamed(
                  context,
                  '/activity/edit',
                  arguments: _activityDetail,
                ),
          ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'share':
                // 分享活动
                break;
              case 'report':
                // 举报活动
                break;
              case 'cancel':
                if (_hasSignedUp && !isPast) {
                  _showCancelDialog();
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
                    title: Text('分享活动'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'report',
                  child: ListTile(
                    leading: Icon(Icons.flag),
                    title: Text('举报活动'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (_hasSignedUp && !isPast && !_isCreator)
                  PopupMenuItem(
                    value: 'cancel',
                    child: ListTile(
                      leading: Icon(Icons.cancel, color: Colors.red),
                      title: Text('取消报名', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
        ),
      ],
    );
  }

  Widget _buildActivityHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.grey[100],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    _activityDetail.organizer.avatarUrl,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _activityDetail.organizer.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '活动发起人',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                Spacer(),
                OutlinedButton(
                  onPressed:
                      () => Navigator.pushNamed(
                        context,
                        '/partner/detail',
                        arguments: _activityDetail.partnerGroup,
                      ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(_activityDetail.partnerGroup.name),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.grey[100],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.access_time,
              title: '活动时间',
              content:
                  '${_formatDateTime(_activityDetail.startTime)} - ${_formatDateTime(_activityDetail.endTime)}',
            ),
            Divider(height: 24),
            _buildInfoRow(
              icon:
                  _activityDetail.isOnline ? Icons.videocam : Icons.location_on,
              title: '活动地点',
              content: _activityDetail.location,
              isLocation: !_activityDetail.isOnline,
            ),
            Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    icon: Icons.people,
                    title: '参与人数',
                    content:
                        '${_activityDetail.participantCount}/${_activityDetail.maxParticipants}',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoColumn(
                    icon: Icons.monetization_on,
                    title: '活动费用',
                    content:
                        _activityDetail.fee > 0
                            ? '¥${_activityDetail.fee.toStringAsFixed(2)}'
                            : '免费',
                    contentColor:
                        _activityDetail.fee > 0
                            ? Colors.orange[700]
                            : Colors.green,
                  ),
                ),
              ],
            ),
            if (_activityDetail.isSignUpRequired)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(height: 24),
                  _buildInfoRow(
                    icon: Icons.event_available,
                    title: '报名截止',
                    content: _formatDateTime(_activityDetail.signUpDeadline),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    bool isLocation = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(content, style: TextStyle(fontSize: 16)),
              if (isLocation)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.map, size: 16),
                    label: Text('查看地图'),
                    onPressed: () {
                      // 打开地图
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required String title,
    required String content,
    Color? contentColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        SizedBox(height: 8),
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: contentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityDescription() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '活动介绍',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              _activityDetail.description,
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _activityDetail.tags.map((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
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
        ),
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '参与人员',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_activityDetail.participants.length > 8)
                  TextButton(
                    onPressed:
                        () => Navigator.pushNamed(
                          context,
                          '/activity/participants',
                          arguments: _activityDetail,
                        ),
                    child: Text('查看全部'),
                  ),
              ],
            ),
            SizedBox(height: 16),
            MemberAvatarGrid(
              members: _activityDetail.participants,
              maxDisplayCount: 8,
              onTap: (member) {
                Navigator.pushNamed(
                  context,
                  '/user/profile',
                  arguments: member,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isPast) {
    if (isPast) {
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
                  icon: Icon(Icons.message),
                  label: Text('活动评论'),
                  onPressed:
                      () => Navigator.pushNamed(
                        context,
                        '/activity/comments',
                        arguments: _activityDetail,
                      ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child:
                    _hasSignedUp
                        ? ElevatedButton.icon(
                          icon: Icon(Icons.rate_review),
                          label: Text('发布回顾'),
                          onPressed:
                              () => Navigator.pushNamed(
                                context,
                                '/activity/review/create',
                                arguments: _activityDetail,
                              ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        )
                        : OutlinedButton.icon(
                          icon: Icon(Icons.remove_red_eye),
                          label: Text('查看回顾'),
                          onPressed:
                              () => Navigator.pushNamed(
                                context,
                                '/activity/reviews',
                                arguments: _activityDetail,
                              ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
              ),
            ],
          ),
        ),
      );
    } else if (_hasSignedUp) {
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '已报名',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Spacer(),
              OutlinedButton.icon(
                icon: Icon(Icons.message),
                label: Text('活动群聊'),
                onPressed:
                    () => Navigator.pushNamed(
                      context,
                      '/activity/chat',
                      arguments: _activityDetail,
                    ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (_activityDetail.isFull) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            onPressed: null,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: Text('名额已满'),
          ),
        ),
      );
    } else {
      final bool isSignUpDeadlinePassed =
          _activityDetail.isSignUpRequired &&
          DateTime.parse(
            _activityDetail.signUpDeadline,
          ).isBefore(DateTime.now());

      return SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            onPressed: isSignUpDeadlinePassed ? null : _showSignUpDialog,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: Text(isSignUpDeadlinePassed ? '报名已截止' : '立即报名'),
          ),
        ),
      );
    }
  }

  String _formatDateTime(String isoDateTime) {
    final dateTime = DateTime.parse(isoDateTime);
    final now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return '今天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateTime.year == now.year) {
      return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showSignUpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? contactInfo;

        return AlertDialog(
          title: Text('报名活动'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_activityDetail.fee > 0)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    '活动费用: ¥${_activityDetail.fee.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              Text('请留下您的联系方式，方便活动组织者联系您'),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: '手机号码或其他联系方式',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => contactInfo = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('取消'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('确认报名'),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final success = await _controller.signUpActivity(
                    _activityDetail.id,
                    contactInfo: contactInfo,
                  );

                  if (success) {
                    setState(() {
                      _hasSignedUp = true;
                      _activityDetail = _activityDetail.copyWith(
                        participantCount: _activityDetail.participantCount + 1,
                      );
                    });
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('报名成功')));
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('报名失败，请稍后重试')));
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

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('取消报名'),
          content: Text('确定要取消该活动的报名吗？'),
          actions: [
            TextButton(
              child: Text('不了'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final success = await _controller.cancelSignUp(
                    _activityDetail.id,
                  );

                  if (success) {
                    setState(() {
                      _hasSignedUp = false;
                      _activityDetail = _activityDetail.copyWith(
                        participantCount: _activityDetail.participantCount - 1,
                      );
                    });
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('已取消报名')));
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
              child: Text('确定取消'),
            ),
          ],
        );
      },
    );
  }
}
