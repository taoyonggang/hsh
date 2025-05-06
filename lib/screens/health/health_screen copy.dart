import 'package:flutter/material.dart';
import '../../controllers/health_controller.dart';
import '../../models/health/health_models.dart';
import 'dart:math' as math;

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen>
    with SingleTickerProviderStateMixin {
  final HealthController _controller = HealthController();
  late TabController _tabController;
  bool _isLoading = true;

  UserHealthProfile? _userProfile;
  BodyMetrics? _latestBodyMetrics;
  List<HealthGoal>? _healthGoals;
  HealthAnalysis? _healthAnalysis;
  List<LifestyleRecord>? _recentLifestyleRecords;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await _controller.initialize();

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
    return Scaffold(
      appBar: AppBar(
        title: Text('健康管理'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: '健康概览'),
            Tab(text: '数据记录'),
            Tab(text: '健康分析'),
            Tab(text: '健康顾问'),
          ],
        ),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _loadData)],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildDataRecordingTab(),
                  _buildAnalysisTab(),
                  _buildAdvisorTab(),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(),
        tooltip: '添加健康记录',
        child: Icon(Icons.add),
      ),
    );
  }

  // 健康概览标签页
  Widget _buildOverviewTab() {
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
                      SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          _tabController.animateTo(2); // 跳转到健康分析标签页
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 36),
                        ),
                        child: Text('查看详细分析'),
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
            SizedBox(height: 16),
            if (_latestBodyMetrics != null)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      '腰围',
                      '${_latestBodyMetrics!.waistCircumference.toStringAsFixed(1)}cm',
                      Icons.record_voice_over,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      '体脂率',
                      '${_latestBodyMetrics!.bodyFatPercentage.toStringAsFixed(1)}%',
                      Icons.pie_chart,
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _showAddMetricsDialog(),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 36),
              ),
              child: Text('记录身体指标'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '健康目标',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: Text('查看全部')),
              ],
            ),
            SizedBox(height: 8),
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
                itemCount: _healthGoals!.length > 3 ? 3 : _healthGoals!.length,
                itemBuilder: (context, index) {
                  final goal = _healthGoals![index];
                  return _buildGoalItem(goal);
                },
              ),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _showAddGoalDialog(),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 36),
              ),
              child: Text('添加健康目标'),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  goal.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                goal.status,
                style: TextStyle(fontSize: 12, color: statusColor),
              ),
              Spacer(),
              Text(
                '截止: ${goal.targetDate}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(goal.description, style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 6),
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
                    _recentLifestyleRecords!.length > 3
                        ? 3
                        : _recentLifestyleRecords!.length,
                itemBuilder: (context, index) {
                  final record = _recentLifestyleRecords![index];
                  return _buildActivityItem(record);
                },
              ),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _tabController.animateTo(1); // 跳转到数据记录标签页
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 36),
              ),
              child: Text('查看所有记录'),
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
                SizedBox(height: 2),
                Text(
                  '水分摄入: ${record.waterIntake.cups}杯 (${record.waterIntake.totalMl}ml)',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () => _showRecordDetails(record),
          ),
        ],
      ),
    );
  }

  // 会员广告卡片
  Widget _buildPremiumAdCard() {
    if (_controller.isUserPremiumMember()) {
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
            Row(
              children: [
                _buildFeaturePoint('全面健康检测'),
                SizedBox(width: 16),
                _buildFeaturePoint('八字健康解析'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                _buildFeaturePoint('个性化健康方案'),
                SizedBox(width: 16),
                _buildFeaturePoint('专业电子报告'),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showPremiumDialog(),
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

  // 功能点
  Widget _buildFeaturePoint(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 16),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  // 数据记录标签页
  Widget _buildDataRecordingTab() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: '身体指标'),
                Tab(text: '生活习惯'),
                Tab(text: '健康指标'),
                Tab(text: '健康日记'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBodyMetricsRecording(),
                _buildLifestyleRecording(),
                _buildHealthIndicatorsRecording(),
                _buildHealthDiaryRecording(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 身体指标记录
  Widget _buildBodyMetricsRecording() {
    return Center(child: Text('身体指标记录功能正在完善中...'));
  }

  // 生活习惯记录
  Widget _buildLifestyleRecording() {
    return Center(child: Text('生活习惯记录功能正在完善中...'));
  }

  // 健康指标记录
  Widget _buildHealthIndicatorsRecording() {
    return Center(child: Text('健康指标记录功能正在完善中...'));
  }

  // 健康日记记录
  Widget _buildHealthDiaryRecording() {
    return Center(child: Text('健康日记功能正在完善中...'));
  }

  // 健康分析标签页
  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHealthAnalysisHeader(),
          SizedBox(height: 20),
          _buildHealthInsightsCard(),
          SizedBox(height: 20),
          _buildHealthRecommendationsCard(),
          SizedBox(height: 20),
          _buildHealthRisksCard(),
          SizedBox(height: 20),
          if (!_controller.isUserPremiumMember()) _buildAnalysisUpgradeCard(),
        ],
      ),
    );
  }

  // 健康分析头部
  Widget _buildHealthAnalysisHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '健康分析报告',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _healthAnalysis?.overallStatus ?? '暂无分析数据',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '报告日期: ${_healthAnalysis?.analysisDate ?? '未知'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CustomPaint(
                    painter: HealthScorePainter(
                      _healthAnalysis?.healthScore ?? 0,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_healthAnalysis?.healthScore ?? 0}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _getHealthScoreColor(
                                _healthAnalysis?.healthScore ?? 0,
                              ),
                            ),
                          ),
                          Text('总评分', style: TextStyle(fontSize: 10)),
                        ],
                      ),
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

  // 健康洞察卡片
  Widget _buildHealthInsightsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '健康洞察',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (_healthAnalysis == null || _healthAnalysis!.insights.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('暂无健康洞察数据', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _healthAnalysis!.insights.length,
                itemBuilder: (context, index) {
                  final insight = _healthAnalysis!.insights[index];
                  return _buildInsightItem(insight);
                },
              ),
          ],
        ),
      ),
    );
  }

  // 洞察项
  Widget _buildInsightItem(HealthInsight insight) {
    IconData trendIcon;
    Color trendColor;

    switch (insight.trendDirection) {
      case '上升':
        trendIcon = Icons.trending_up;
        trendColor = Colors.green;
        break;
      case '下降':
        trendIcon = Icons.trending_down;
        trendColor = Colors.red;
        break;
      default:
        trendIcon = Icons.trending_flat;
        trendColor = Colors.amber;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  insight.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Spacer(),
              Icon(trendIcon, color: trendColor, size: 16),
              SizedBox(width: 4),
              Text(
                insight.trendDirection,
                style: TextStyle(fontSize: 12, color: trendColor),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(insight.description),
        ],
      ),
    );
  }

  // 健康建议卡片
  Widget _buildHealthRecommendationsCard() {
    List<HealthRecommendation> visibleRecommendations = [];
    List<HealthRecommendation> premiumRecommendations = [];

    if (_healthAnalysis != null &&
        _healthAnalysis!.recommendations.isNotEmpty) {
      for (var rec in _healthAnalysis!.recommendations) {
        if (!rec.isPremiumOnly || _controller.isUserPremiumMember()) {
          visibleRecommendations.add(rec);
        } else {
          premiumRecommendations.add(rec);
        }
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '健康建议',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (visibleRecommendations.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('暂无健康建议', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: visibleRecommendations.length,
                itemBuilder: (context, index) {
                  return _buildRecommendationItem(
                    visibleRecommendations[index],
                  );
                },
              ),

            if (premiumRecommendations.isNotEmpty &&
                !_controller.isUserPremiumMember()) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock, color: Colors.amber, size: 16),
                        SizedBox(width: 8),
                        Text(
                          '专业健康建议',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '升级至精准健康套餐，解锁${premiumRecommendations.length}条专业健康建议',
                      style: TextStyle(fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _showPremiumDialog(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('立即升级'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 健康建议项
  Widget _buildRecommendationItem(HealthRecommendation recommendation) {
    Color urgencyColor;

    switch (recommendation.urgency) {
      case '高':
        urgencyColor = Colors.red;
        break;
      case '中':
        urgencyColor = Colors.orange;
        break;
      default:
        urgencyColor = Colors.green;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: urgencyColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.priority_high, color: urgencyColor, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.category,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4),
                Text(
                  recommendation.recommendation,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 健康风险卡片
  Widget _buildHealthRisksCard() {
    List<HealthRisk> visibleRisks = [];
    List<HealthRisk> premiumRisks = [];

    if (_healthAnalysis != null && _healthAnalysis!.risks.isNotEmpty) {
      for (var risk in _healthAnalysis!.risks) {
        if (!risk.isPremiumOnly || _controller.isUserPremiumMember()) {
          visibleRisks.add(risk);
        } else {
          premiumRisks.add(risk);
        }
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '健康风险预警',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (visibleRisks.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('暂无健康风险预警', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: visibleRisks.length,
                itemBuilder: (context, index) {
                  return _buildRiskItem(visibleRisks[index]);
                },
              ),

            if (premiumRisks.isNotEmpty &&
                !_controller.isUserPremiumMember()) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock, color: Colors.amber, size: 16),
                        SizedBox(width: 8),
                        Text(
                          '深度风险评估',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '升级至精准健康套餐，解锁${premiumRisks.length}个潜在健康风险评估及预防建议',
                      style: TextStyle(fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _showPremiumDialog(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('立即升级'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 健康风险项
  Widget _buildRiskItem(HealthRisk risk) {
    Color severityColor;

    switch (risk.severity) {
      case '高':
        severityColor = Colors.red;
        break;
      case '中':
        severityColor = Colors.orange;
        break;
      default:
        severityColor = Colors.green;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: severityColor, size: 20),
              SizedBox(width: 8),
              Text(
                risk.riskFactor,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${risk.severity}风险',
                  style: TextStyle(
                    fontSize: 12,
                    color: severityColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(risk.description, style: TextStyle(fontSize: 14)),
          SizedBox(height: 8),
          Text(
            '预防建议:',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          SizedBox(height: 4),
          ...risk.preventiveMeasures.map(
            (measure) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• '),
                  Expanded(
                    child: Text(measure, style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 分析升级卡片
  Widget _buildAnalysisUpgradeCard() {
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
            Text('升级至精准健康套餐，获取更全面、更专业的健康分析', style: TextStyle(fontSize: 14)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPremiumFeature('全面身体检测'),
                      SizedBox(height: 8),
                      _buildPremiumFeature('健康风险评估'),
                      SizedBox(height: 8),
                      _buildPremiumFeature('个性化健康方案'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPremiumFeature('八字健康解析'),
                      SizedBox(height: 8),
                      _buildPremiumFeature('专业电子报告'),
                      SizedBox(height: 8),
                      _buildPremiumFeature('生活改善建议'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showPremiumDialog(),
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

  // 高级功能项
  Widget _buildPremiumFeature(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 16),
        SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13))),
      ],
    );
  }

  // 健康顾问标签页
  Widget _buildAdvisorTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdvisorHeader(),
          SizedBox(height: 20),
          _buildAIChatSection(),
          SizedBox(height: 20),
          if (!_controller.isUserPremiumMember()) _buildAdvisorUpgradeCard(),
          SizedBox(height: 20),
          _buildCommonHealthQuestionsCard(),
        ],
      ),
    );
  }

  // 顾问头部
  Widget _buildAdvisorHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.health_and_safety,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '健康AI顾问',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '您的个人健康助手，随时为您解答健康问题',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AI聊天部分
  Widget _buildAIChatSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '咨询健康问题',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBotMessage('您好，我是您的健康AI顾问，有什么我能帮助您的吗？'),
                  SizedBox(height: 16),
                  _buildBotMessage(
                    '您可以询问我关于饮食、运动、睡眠等健康问题，我也可以结合您的八字特点提供阴阳五行平衡建议。',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '输入您的健康问题...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 机器人消息
  Widget _buildBotMessage(String message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.2),
          radius: 16,
          child: Icon(Icons.health_and_safety, size: 16, color: Colors.blue),
        ),
        SizedBox(width: 8),
        Expanded(child: Text(message)),
      ],
    );
  }

  // 顾问升级卡片
  Widget _buildAdvisorUpgradeCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.amber.shade50,
      elevation: 2,
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
                  '升级健康顾问功能',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('升级至精准健康套餐，获取更专业的健康咨询服务', style: TextStyle(fontSize: 14)),
            SizedBox(height: 16),
            _buildPremiumFeature('结合八字的个性化健康建议'),
            SizedBox(height: 8),
            _buildPremiumFeature('健康风险预警及预防指导'),
            SizedBox(height: 8),
            _buildPremiumFeature('个性化饮食、运动方案推荐'),
            SizedBox(height: 8),
            _buildPremiumFeature('阴阳五行平衡生活调理建议'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showPremiumDialog(),
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

  // 常见健康问题卡片
  Widget _buildCommonHealthQuestionsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '常见健康问题',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildQuestionItem('如何改善睡眠质量？'),
            _buildQuestionItem('每天应该喝多少水？'),
            _buildQuestionItem('如何保持健康的心理状态？'),
            _buildQuestionItem('哪些食物有助于增强免疫力？'),
            _buildQuestionItem('如何调节五行平衡？'),
          ],
        ),
      ),
    );
  }

  // 问题项
  Widget _buildQuestionItem(String question) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(Icons.question_answer, color: Colors.blue, size: 18),
            SizedBox(width: 12),
            Expanded(child: Text(question)),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 显示添加记录对话框
  void _showAddRecordDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('添加健康记录'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.monitor_weight),
                  title: Text('记录身体指标'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddMetricsDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.restaurant),
                  title: Text('记录饮食信息'),
                  onTap: () {
                    Navigator.pop(context);
                    // 实现饮食记录对话框
                  },
                ),
                ListTile(
                  leading: Icon(Icons.directions_run),
                  title: Text('记录运动数据'),
                  onTap: () {
                    Navigator.pop(context);
                    // 实现运动记录对话框
                  },
                ),
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('记录健康指标'),
                  onTap: () {
                    Navigator.pop(context);
                    // 实现健康指标记录对话框
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bookmark),
                  title: Text('添加健康日记'),
                  onTap: () {
                    Navigator.pop(context);
                    // 实现健康日记对话框
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
            ],
          ),
    );
  }

  // 显示添加身体指标对话框
  void _showAddMetricsDialog() {
    // 临时控制器
    final heightController = TextEditingController();
    final weightController = TextEditingController();
    final waistController = TextEditingController();
    final bodyFatController = TextEditingController();

    // 如果有最新数据，预填充
    if (_latestBodyMetrics != null) {
      heightController.text = _latestBodyMetrics!.height.toString();
      weightController.text = _latestBodyMetrics!.weight.toString();
      waistController.text = _latestBodyMetrics!.waistCircumference.toString();
      bodyFatController.text = _latestBodyMetrics!.bodyFatPercentage.toString();
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('记录身体指标'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '身高 (cm)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '体重 (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: waistController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '腰围 (cm)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: bodyFatController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '体脂率 (%)',
                      border: OutlineInputBorder(),
                    ),
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
                  // 计算BMI
                  final height = double.tryParse(heightController.text) ?? 0;
                  final weight = double.tryParse(weightController.text) ?? 0;
                  final waist = double.tryParse(waistController.text) ?? 0;
                  final bodyFat = double.tryParse(bodyFatController.text) ?? 0;

                  double bmi = 0;
                  if (height > 0 && weight > 0) {
                    bmi = weight / ((height / 100) * (height / 100));
                  }

                  final metrics = BodyMetrics(
                    height: height,
                    weight: weight,
                    waistCircumference: waist,
                    bodyFatPercentage: bodyFat,
                    bmi: bmi,
                    recordDate: '2025-04-21', // 使用当前日期
                  );

                  _controller.saveBodyMetrics(metrics).then((success) {
                    if (success) {
                      setState(() {
                        _latestBodyMetrics = metrics;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('身体指标记录成功')));
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text('保存'),
              ),
            ],
          ),
    );
  }

  // 添加健康目标对话框
  void _showAddGoalDialog() {
    // 实现添加健康目标对话框
  }

  // 显示生活习惯记录详情
  void _showRecordDetails(LifestyleRecord record) {
    // 实现生活习惯记录详情对话框
  }

  // 显示会员升级对话框
  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('精准健康套餐'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.stars, color: Colors.amber, size: 30),
                ),
                SizedBox(height: 16),
                Text(
                  '¥999',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '全面健康检测 + 个性化报告 + 定制健康方案',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16),
                _buildPremiumFeature('全面身体检测与评估'),
                SizedBox(height: 8),
                _buildPremiumFeature('基于八字的健康分析'),
                SizedBox(height: 8),
                _buildPremiumFeature('个性化健康改善方案'),
                SizedBox(height: 8),
                _buildPremiumFeature('专业电子版健康报告'),
                SizedBox(height: 8),
                _buildPremiumFeature('健康风险预测与防范'),
                SizedBox(height: 8),
                _buildPremiumFeature('阴阳五行平衡健康建议'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('暂不升级'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('购买成功，感谢您的支持！')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: Text('立即购买'),
              ),
            ],
          ),
    );
  }

  // 根据健康分数获取颜色
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
