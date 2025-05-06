import 'package:flutter/material.dart';
import '../../../controllers/health_controller.dart';
import '../../../models/health/health_models.dart';

class LifestyleTab extends StatefulWidget {
  const LifestyleTab({super.key});

  @override
  _LifestyleTabState createState() => _LifestyleTabState();
}

class _LifestyleTabState extends State<LifestyleTab> {
  final HealthController _controller = HealthController();
  bool _isLoading = true;
  List<LifestyleRecord>? _lifestyleRecords;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _lifestyleRecords = await _controller.loadLifestyleRecords();
    } catch (e) {
      print('Error loading lifestyle records: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_lifestyleRecords == null || _lifestyleRecords!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无生活习惯记录', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showAddRecordDialog(),
              child: Text('开始记录'),
            ),
          ],
        ),
      );
    }

    // 获取最新记录
    final latestRecord = _lifestyleRecords!.last;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '今日记录',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        latestRecord.recordDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    '睡眠：${latestRecord.sleep.bedTime} - ${latestRecord.sleep.wakeUpTime}',
                  ),
                  Text('睡眠质量：${latestRecord.sleep.sleepQualityRating}/5'),
                  SizedBox(height: 8),
                  Text('运动记录：${latestRecord.exercises.length}条'),
                  SizedBox(height: 8),
                  Text('膳食记录：${latestRecord.meals.length}条'),
                  SizedBox(height: 8),
                  Text(
                    '饮水量：${latestRecord.waterIntake.cups}杯 (${latestRecord.waterIntake.totalMl}ml)',
                  ),
                  SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _showAddRecordDialog(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 36),
                    ),
                    child: Text('添加记录'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '历史记录',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _lifestyleRecords!.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      // 倒序显示，最新的在上面
                      final record =
                          _lifestyleRecords![_lifestyleRecords!.length -
                              1 -
                              index];
                      return ListTile(
                        title: Text(record.recordDate),
                        subtitle: Text(
                          '睡眠: ${record.sleep.sleepDurationMinutes ~/ 60}小时${record.sleep.sleepDurationMinutes % 60}分钟 | 饮水: ${record.waterIntake.cups}杯',
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => _showRecordDetail(record),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRecordDialog() {
    // 简化实现，实际应用中可能会更复杂
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('生活习惯记录功能正在完善中...')));
  }

  void _showRecordDetail(LifestyleRecord record) {
    // 简化实现，实际应用中可能会更复杂
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('记录详情功能正在完善中...')));
  }
}
