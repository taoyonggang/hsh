import 'package:flutter/material.dart';

class PartnerDetailScreen extends StatefulWidget {
  final Map<String, dynamic> partnerData;

  const PartnerDetailScreen({super.key, required this.partnerData});

  @override
  _PartnerDetailScreenState createState() => _PartnerDetailScreenState();
}

class _PartnerDetailScreenState extends State<PartnerDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('搭子详情'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('更多选项')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部信息
            _buildHeader(),

            // 个人资料
            _buildProfileSection(),

            // 兴趣爱好
            _buildInterestsSection(),

            // 动态内容
            _buildContentSection(),

            SizedBox(height: 80), // 底部留白
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // 封面图
        SizedBox(
          height: 200,
          width: double.infinity,
          child:
              widget.partnerData['image'] != null
                  ? Image.network(
                    widget.partnerData['image'],
                    fit: BoxFit.cover,
                  )
                  : Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.image, size: 80, color: Colors.white),
                  ),
        ),

        // 个人信息卡
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(16),
            color: Colors.black.withOpacity(0.5),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      widget.partnerData['avatar'] != null
                          ? NetworkImage(widget.partnerData['avatar'])
                          : null,
                  child:
                      widget.partnerData['avatar'] == null
                          ? Icon(Icons.person)
                          : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.partnerData['user'] ?? '用户',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${widget.partnerData['distance'] ?? 0} km | ${widget.partnerData['age'] ?? 25}岁',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('关注成功')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('关注'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '个人资料',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          _buildInfoItem(
            Icons.work,
            '职业',
            widget.partnerData['profession'] ?? '未填写',
          ),
          _buildInfoItem(
            Icons.school,
            '学历',
            widget.partnerData['education'] ?? '未填写',
          ),
          _buildInfoItem(
            Icons.location_on,
            '位置',
            widget.partnerData['location'] ?? '未填写',
          ),
          _buildInfoItem(
            Icons.favorite,
            '兴趣',
            (widget.partnerData['interests'] as List<dynamic>?)?.join(', ') ??
                '未填写',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
          Text('$label:', style: TextStyle(color: Colors.grey[700])),
          SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    List<String> interests =
        (widget.partnerData['interests'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '兴趣爱好',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                interests.map((interest) {
                  return Chip(
                    label: Text(interest),
                    backgroundColor: Colors.green.withOpacity(0.2),
                    labelStyle: TextStyle(color: Colors.green[800]),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '最新动态',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.partnerData['content'] ?? '这个用户很懒，什么都没有写~',
                    style: TextStyle(fontSize: 16),
                  ),
                  if (widget.partnerData['image'] != null) ...[
                    SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(widget.partnerData['image']),
                    ),
                  ],
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.partnerData['time'] ?? '刚刚',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.red, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '${widget.partnerData['likes'] ?? 0}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.comment, color: Colors.blue, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '${widget.partnerData['comments'] ?? 0}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('私信已发送')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('发送私信'),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('已邀请见面')));
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.green),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('邀请见面'),
            ),
          ),
        ],
      ),
    );
  }
}
