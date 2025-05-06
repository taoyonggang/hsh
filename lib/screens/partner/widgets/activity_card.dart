import 'package:flutter/material.dart';
import '../../../models/partner/partner_activity.dart';
import '../activity_detail_screen.dart';

class ActivityCard extends StatelessWidget {
  final PartnerActivity activity;
  final VoidCallback? onTap;
  final bool showActions;
  final bool showJoinButton;
  final bool isRecommended;
  final Function? onJoin;
  final Function? onCancel;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.showActions = true,
    this.showJoinButton = true,
    this.isRecommended = false,
    this.onJoin,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:
            onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ActivityDetailScreen(activityData: activity.toJson()),
                ),
              );
            },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 活动头部与封面
            Stack(
              children: [
                // 封面图
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child:
                      activity.coverImageUrl != null
                          ? Image.network(
                            activity.coverImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.event,
                                  size: 48,
                                  color: Colors.green,
                                ),
                              );
                            },
                          )
                          : Center(
                            child: Icon(
                              Icons.event,
                              size: 48,
                              color: Colors.green,
                            ),
                          ),
                ),

                // 推荐标签
                if (isRecommended)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '推荐',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 活动状态标签
                if (activity.hasSignedUp)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '已报名',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // 活动内容
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 活动标题
                  Text(
                    activity.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),

                  // 活动时间
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 6),
                      Text(
                        activity.time,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),

                  // 活动地点
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          activity.location,
                          style: TextStyle(color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // 活动参与人数
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 6),
                      Text(
                        '${activity.participantCount}/${activity.maxParticipants} 人参与',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),

                  // 操作按钮
                  if (showActions) ...[
                    SizedBox(height: 16),
                    activity.hasSignedUp
                        ? OutlinedButton(
                          onPressed:
                              onCancel != null ? () => onCancel!() : null,
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 40),
                          ),
                          child: Text('取消报名'),
                        )
                        : ElevatedButton(
                          onPressed: onJoin != null ? () => onJoin!() : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: Size(double.infinity, 40),
                          ),
                          child: Text('立即报名'),
                        ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
