import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../controllers/health_controller.dart';
import '../../../models/health/health_models.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  _OverviewTabState createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  final HealthController _controller = HealthController();
  bool _isLoading = true;

  UserHealthProfile? _userProfile;
  BodyMetrics? _latestBodyMetrics;
  List<HealthGoal>? _healthGoals;
  HealthAnalysis? _healthAnalysis;
  List<LifestyleRecord>? _recentLifestyleRecords;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      _userProfile = await _controller.loadUserProfile();
      _latestBodyMetrics = _controller.getLatestBodyMetrics();
      _healthGoals = await _controller.loadHealthGoals();
      _healthAnalysis = await _controller.loadHealthAnalysis();
      _recentLifestyleRecords = await _controller.loadLifestyleRecords();
    } catch (e) {
      print('Error loading health data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHealthHeader(),
          SizedBox(height: 20),
          _buildHealthScoreCard(),
          SizedBox(height: 20),
          _buildBodyMetricsCard(),
          SizedBox(height: 20),
          _buildHealthGoalsCard(),
          SizedBox(height: 20),
          _buildRecentActivitiesCard(),
          SizedBox(height: 20),
          _buildPremiumAdCard(),
        ],
      ),
    );
  }

  // 用户健康档案标题
  Widget _buildUserHealthHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              child: Text(
                _userProfile?.name.substring(0, 1) ?? 'U',
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userProfile?.name ?? '用户',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${_userProfile?.gender ?? '未知'} • ${_userProfile?.age ?? 0}岁 • ${_userProfile?.bloodType ?? '未知'}型血',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _userProfile?.isPremiumMember ?? false ? '精准健康会员' : '普通用户',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          _userProfile?.isPremiumMember ?? false
                              ? Colors.amber
                              : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {},
              tooltip: '编辑个人资料',
            ),
          ],
        ),
      ),
    );
  }

  // 健康评分卡片
  Widget _buildHealthScoreCard() {
    final healthScore = _healthAnalysis?.healthScore ?? 0;
    final healthStatus = _healthAnalysis?.overallStatus ?? '暂无分析数据';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '健康评分',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: HealthScorePainter(healthScore),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$healthScore',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _getHealthScoreColor(healthScore),
                            ),
                          ),
                          Text('总评分', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        healthStatus,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '最近更新: ${_healthAnalysis?.analysisDate ?? '未知'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 身体指标卡片
  Widget _buildBodyMetricsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  '身体指标',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '更新: ${_latestBodyMetrics?.recordDate ?? '未记录'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_latestBodyMetrics == null)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('暂无身体指标记录', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      '身高',
                      '${_latestBodyMetrics!.height.toStringAsFixed(1)}cm',
                      Icons.height,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      '体重',
                      '${_latestBodyMetrics!.weight.toStringAsFixed(1)}kg',
                      Icons.fitness_center,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      'BMI',
                      _latestBodyMetrics!.bmi.toStringAsFixed(1),
                      Icons.accessibility_new,
                      subtitle: _controller.getBMIStatus(
                        _latestBodyMetrics!.bmi,
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

  // 指标项
  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon, {
    String? subtitle,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        if (subtitle != null) ...[
          SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  // 健康目标卡片
  Widget _buildHealthGoalsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '健康目标',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (_healthGoals == null || _healthGoals!.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('暂无健康目标', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _healthGoals!.length > 2 ? 2 : _healthGoals!.length,
                itemBuilder: (context, index) {
                  final goal = _healthGoals![index];
                  return _buildGoalItem(goal);
                },
              ),
          ],
        ),
      ),
    );
  }

  // 目标项
  Widget _buildGoalItem(HealthGoal goal) {
    Color statusColor;

    switch (goal.status) {
      case '进行中':
        statusColor = Colors.blue;
        break;
      case '已完成':
        statusColor = Colors.green;
        break;
      case '已放弃':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(goal.description, style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: goal.progress / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
          SizedBox(height: 4),
          Text(
            '进度: ${goal.progress.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // 最近活动卡片
  Widget _buildRecentActivitiesCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最近活动',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (_recentLifestyleRecords == null ||
                _recentLifestyleRecords!.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('暂无活动记录', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount:
                    _recentLifestyleRecords!.length > 1
                        ? 1
                        : _recentLifestyleRecords!.length,
                itemBuilder: (context, index) {
                  final record = _recentLifestyleRecords![index];
                  return _buildActivityItem(record);
                },
              ),
          ],
        ),
      ),
    );
  }

  // 活动项
  Widget _buildActivityItem(LifestyleRecord record) {
    // 计算综合评分
    int score = _controller.calculateLifestyleScore(record);
    Color scoreColor = _getHealthScoreColor(score);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withOpacity(0.1),
              border: Border.all(color: scoreColor, width: 2),
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '日期: ${record.recordDate}',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4),
                Text(
                  '睡眠: ${record.sleep.sleepDurationMinutes ~/ 60}小时${record.sleep.sleepDurationMinutes % 60}分钟 (${record.sleep.sleepQualityRating}分)',
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 2),
                if (record.exercises.isNotEmpty)
                  Text(
                    '运动: ${record.exercises.map((e) => e.exerciseType).join(', ')}',
                    style: TextStyle(fontSize: 13),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 会员广告卡片
  Widget _buildPremiumAdCard() {
    if (_userProfile?.isPremiumMember ?? false) {
      return Container(); // 会员无需显示广告
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Colors.amber.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  '精准健康套餐',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '升级至精准健康套餐，享受全面的健康检测、个性化健康报告和定制方案',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                minimumSize: Size(double.infinity, 40),
              ),
              child: Text('立即升级 · ¥999'),
            ),
          ],
        ),
      ),
    );
  }

  // 获取健康评分颜色
  Color _getHealthScoreColor(int score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.lightGreen;
    if (score >= 60) return Colors.amber;
    return Colors.red;
  }
}

// 健康分数绘制器
class HealthScorePainter extends CustomPainter {
  final int score;

  HealthScorePainter(this.score);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 背景圆环
    final bgPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10;

    // 分数圆环
    final scorePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round;

    if (score >= 85) {
      scorePaint.color = Colors.green;
    } else if (score >= 70) {
      scorePaint.color = Colors.lightGreen;
    } else if (score >= 60) {
      scorePaint.color = Colors.amber;
    } else {
      scorePaint.color = Colors.red;
    }

    // 绘制背景圆环
    canvas.drawCircle(center, radius - 5, bgPaint);

    // 绘制分数圆环
    final sweepAngle = 2 * math.pi * score / 100;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      -math.pi / 2,
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
