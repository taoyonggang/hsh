import 'package:flutter/material.dart';
import '../../../models/partner/partner_group.dart';
import '../../../models/partner/partner_activity.dart';
import '../../../screens/partner/activity_detail_screen.dart';

class PartnerCard extends StatelessWidget {
  final PartnerGroup partner;
  final bool isRecommended;
  final VoidCallback onTap;

  const PartnerCard({
    super.key,
    required this.partner,
    this.isRecommended = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 搭子封面照片及信息
            _buildHeader(),

            // 搭子成员
            _buildMembers(context),

            // 活动预览部分 - 新增
            if (partner.upcomingActivities.isNotEmpty)
              _buildActivityPreview(context),

            // 底部按钮行
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // 封面照片
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            image:
                partner.coverImage != null
                    ? DecorationImage(
                      image: NetworkImage(partner.coverImage!),
                      fit: BoxFit.cover,
                    )
                    : null,
            color: partner.coverImage == null ? Colors.green.shade50 : null,
          ),
          child:
              partner.coverImage == null
                  ? Center(
                    child: Icon(
                      Icons.group,
                      size: 48,
                      color: Colors.green[300],
                    ),
                  )
                  : null,
        ),

        // 搭子类型和人数
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.group, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text('${partner.memberCount}人'),
              ],
            ),
          ),
        ),

        // 推荐标签
        if (isRecommended)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    '推荐',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 底部信息栏
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
            child: Text(
              partner.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembers(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            partner.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),
          Row(
            children: [
              // 显示前3个成员头像
              for (
                int i = 0;
                i < (partner.members.length > 3 ? 3 : partner.members.length);
                i++
              )
                Container(
                  margin: EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(partner.members[i].avatarUrl),
                  ),
                ),
              // 如果成员数量超过3个，显示剩余数量
              if (partner.members.length > 3)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '+${partner.members.length - 3}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 新增活动预览部分
  Widget _buildActivityPreview(BuildContext context) {
    final activity = partner.upcomingActivities.first;

    return InkWell(
      onTap: () {
        // 导航到活动详情页
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ActivityDetailScreen(activityData: activity.toJson()),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Text(
                  '即将开始的活动',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            activity.time,
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    '参与',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '创建于 ${partner.createdTime}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          if (partner.unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${partner.unreadCount}条新消息',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
