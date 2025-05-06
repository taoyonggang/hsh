import 'package:flutter/material.dart';

class ActivityDetailScreen extends StatefulWidget {
  final Map<String, dynamic> activityData;

  const ActivityDetailScreen({super.key, required this.activityData});

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  bool _isJoined = false;

  @override
  void initState() {
    super.initState();
    _isJoined = widget.activityData['hasSignedUp'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('活动详情')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.green.withOpacity(0.2),
              child:
                  widget.activityData['coverImageUrl'] != null
                      ? Image.network(
                        widget.activityData['coverImageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.event,
                              size: 80,
                              color: Colors.green,
                            ),
                          );
                        },
                      )
                      : Center(
                        child: Icon(Icons.event, size: 80, color: Colors.green),
                      ),
            ),

            // 活动信息
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 活动标题
                  Text(
                    widget.activityData['title'] ?? '活动详情',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  // 活动时间
                  _buildInfoRow(
                    Icons.access_time,
                    '活动时间',
                    widget.activityData['time'] ?? '未设置',
                  ),
                  SizedBox(height: 12),

                  // 活动地点
                  _buildInfoRow(
                    Icons.location_on,
                    '活动地点',
                    widget.activityData['location'] ?? '未设置',
                  ),
                  SizedBox(height: 12),

                  // 参与人数
                  _buildInfoRow(
                    Icons.people,
                    '参与人数',
                    '${widget.activityData['participantCount'] ?? 0}/${widget.activityData['maxParticipants'] ?? 10} 人',
                  ),

                  Divider(height: 32),

                  // 活动描述
                  Text(
                    '活动详情',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.activityData['description'] ?? '暂无详情',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),

                  // 标签
                  if (widget.activityData['tags'] != null) ...[
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          (widget.activityData['tags'] as List)
                              .map(
                                (tag) => Chip(
                                  label: Text(tag.toString()),
                                  backgroundColor: Colors.grey[200],
                                ),
                              )
                              .toList(),
                    ),
                  ],

                  SizedBox(height: 80), // 底部留白
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
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
          onPressed: () {
            setState(() {
              _isJoined = !_isJoined;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_isJoined ? '报名成功' : '已取消报名')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isJoined ? Colors.grey[400] : Colors.green,
            minimumSize: Size(double.infinity, 48),
          ),
          child: Text(
            _isJoined ? '取消报名' : '立即报名',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
