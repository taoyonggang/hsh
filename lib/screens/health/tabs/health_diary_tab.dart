import 'package:flutter/material.dart';
import '../../../controllers/health_controller.dart';
import '../../../models/health/health_models.dart';

class HealthDiaryTab extends StatefulWidget {
  const HealthDiaryTab({super.key});

  @override
  _HealthDiaryTabState createState() => _HealthDiaryTabState();
}

class _HealthDiaryTabState extends State<HealthDiaryTab> {
  final HealthController _controller = HealthController();
  bool _isLoading = true;
  List<HealthDiary>? _healthDiaries;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _healthDiaries = await _controller.loadHealthDiaries();
    } catch (e) {
      print('Error loading health diaries: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_healthDiaries == null || _healthDiaries!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无健康日记', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showAddDiaryDialog(),
              child: Text('写健康日记'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _healthDiaries!.length,
            itemBuilder: (context, index) {
              // 倒序显示，最新的在上面
              final diary = _healthDiaries![_healthDiaries!.length - 1 - index];
              return _buildDiaryCard(diary);
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => _showAddDiaryDialog(),
              tooltip: '写健康日记',
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  // 日记卡片
  Widget _buildDiaryCard(HealthDiary diary) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  diary.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  diary.date,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(diary.content, style: TextStyle(fontSize: 14)),
            if (diary.tags.isNotEmpty) ...[
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    diary.tags
                        .map(
                          (tag) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
            if (diary.imageUrls != null && diary.imageUrls!.isNotEmpty) ...[
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      diary.imageUrls!
                          .map(
                            (url) => Container(
                              margin: EdgeInsets.only(right: 8),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                                image: DecorationImage(
                                  image: NetworkImage(url),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('编辑'),
                  onPressed: () => _showEditDiaryDialog(diary),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  icon: Icon(Icons.delete_outline, size: 16),
                  label: Text('删除'),
                  onPressed: () => _confirmDeleteDiary(diary),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 添加日记对话框
  void _showAddDiaryDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final tagsController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('写健康日记'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: '标题',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: '内容',
                      border: OutlineInputBorder(),
                      hintText: '今天的健康状况...',
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: tagsController,
                    decoration: InputDecoration(
                      labelText: '标签 (用逗号分隔)',
                      border: OutlineInputBorder(),
                      hintText: '例如: 睡眠,压力,运动',
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.photo_camera_outlined),
                      SizedBox(width: 8),
                      Text('添加图片'),
                      Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          // 实际应用中实现图片选择功能
                        },
                        child: Text('选择'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  final now = DateTime(2025, 4, 21);
                  final dateString =
                      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

                  final List<String> tags =
                      tagsController.text
                          .split(',')
                          .map((tag) => tag.trim())
                          .where((tag) => tag.isNotEmpty)
                          .toList();

                  final diary = HealthDiary(
                    date: dateString,
                    title: titleController.text,
                    content: contentController.text,
                    tags: tags,
                    imageUrls: null,
                  );

                  _controller.saveHealthDiary(diary).then((success) {
                    if (success) {
                      _loadData();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('健康日记已保存')));
                    }
                  });
                },
                child: Text('保存'),
              ),
            ],
          ),
    );
  }

  // 编辑日记对话框
  void _showEditDiaryDialog(HealthDiary diary) {
    final titleController = TextEditingController(text: diary.title);
    final contentController = TextEditingController(text: diary.content);
    final tagsController = TextEditingController(text: diary.tags.join(', '));

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('编辑健康日记'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: '标题',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: '内容',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: tagsController,
                    decoration: InputDecoration(
                      labelText: '标签 (用逗号分隔)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (diary.imageUrls != null &&
                      diary.imageUrls!.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      '已添加的图片:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            diary.imageUrls!
                                .map(
                                  (url) => Container(
                                    margin: EdgeInsets.only(right: 8),
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[200],
                                      image: DecorationImage(
                                        image: NetworkImage(url),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  final List<String> tags =
                      tagsController.text
                          .split(',')
                          .map((tag) => tag.trim())
                          .where((tag) => tag.isNotEmpty)
                          .toList();

                  final updatedDiary = HealthDiary(
                    date: diary.date,
                    title: titleController.text,
                    content: contentController.text,
                    tags: tags,
                    imageUrls: diary.imageUrls,
                  );

                  // 实际应用中实现更新日记功能
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('健康日记已更新')));
                  // 刷新数据
                  _loadData();
                },
                child: Text('保存'),
              ),
            ],
          ),
    );
  }

  // 确认删除日记
  void _confirmDeleteDiary(HealthDiary diary) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('删除日记'),
            content: Text('确定要删除这篇健康日记吗？此操作无法恢复。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  // 实际应用中实现删除日记功能
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('健康日记已删除')));
                  // 刷新数据
                  _loadData();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('删除'),
              ),
            ],
          ),
    );
  }
}
