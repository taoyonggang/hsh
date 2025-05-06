import 'package:flutter/material.dart';
import '../../controllers/health_controller.dart';
import '../../models/health/health_models.dart';

// 健康记录标签页
class HealthRecordsTab extends StatelessWidget {
  final HealthController controller;

  const HealthRecordsTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        controller.loadHealthOverview(),
        controller.loadHealthRecords(),
        controller.loadHealthAdvisor(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final healthOverview = snapshot.data![0] as HealthOverview;
        final healthRecords = snapshot.data![1] as List<HealthRecord>;
        final healthAdvisor = snapshot.data![2] as HealthAdvisor;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HealthScoreCard(healthOverview: healthOverview),
                SizedBox(height: 20),
                RecordCategoriesSection(),
                SizedBox(height: 20),
                DailyRecordCard(dailyTasks: healthAdvisor.dailyTasks),
                SizedBox(height: 20),
                RecentRecordsSection(records: healthRecords),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 健康评分卡片
class HealthScoreCard extends StatelessWidget {
  final HealthOverview healthOverview;

  const HealthScoreCard({super.key, required this.healthOverview});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${healthOverview.healthScore}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    '健康评分',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      healthOverview.weeklyChange > 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color:
                          healthOverview.weeklyChange > 0
                              ? Colors.green
                              : Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '较上周${healthOverview.weeklyChange > 0 ? '提升' : '下降'}${healthOverview.weeklyChange.abs()}分',
                      style: TextStyle(
                        color:
                            healthOverview.weeklyChange > 0
                                ? Colors.green
                                : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  healthOverview.summary,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildScoreIndicator(
                      '体质',
                      healthOverview.scoreDetails['physical'] ?? 0,
                      Colors.blue,
                    ),
                    _buildScoreIndicator(
                      '能量',
                      healthOverview.scoreDetails['energy'] ?? 0,
                      Colors.orange,
                    ),
                    _buildScoreIndicator(
                      '心态',
                      healthOverview.scoreDetails['mental'] ?? 0,
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreIndicator(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          '$score',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

// 记录分类部分
class RecordCategoriesSection extends StatelessWidget {
  const RecordCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> categories = [
      {
        'icon': Icons.straighten,
        'name': '身体指标',
        'color': Colors.blue,
        'type': 'physical',
      },
      {
        'icon': Icons.restaurant,
        'name': '生活习惯',
        'color': Colors.green,
        'type': 'lifestyle',
      },
      {
        'icon': Icons.favorite,
        'name': '健康指标',
        'color': Colors.red,
        'type': 'health',
      },
      {
        'icon': Icons.edit_note,
        'name': '健康日记',
        'color': Colors.purple,
        'type': 'diary',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '记录分类',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              categories.map((category) {
                return InkWell(
                  onTap:
                      () => _showCategoryRecordDialog(
                        context,
                        category['name'],
                        category['type'],
                      ),
                  child: SizedBox(
                    width: 80,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: category['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            category['icon'],
                            color: category['color'],
                            size: 28,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          category['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  void _showCategoryRecordDialog(
    BuildContext context,
    String name,
    String type,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('$name记录'),
            content: Text('此处将显示$name的记录表单'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text('保存'),
              ),
            ],
          ),
    );
  }
}

// 每日记录卡片
class DailyRecordCard extends StatelessWidget {
  final List<DailyHealthTask> dailyTasks;

  const DailyRecordCard({super.key, required this.dailyTasks});

  @override
  Widget build(BuildContext context) {
    final completedTasks = dailyTasks.where((task) => task.completed).length;

    return Card(
      elevation: 2,
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
                  '今日记录',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '已完成 $completedTasks/${dailyTasks.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            ...dailyTasks.map((task) => _buildDailyTaskItem(context, task)),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTaskItem(BuildContext context, DailyHealthTask task) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              task.getIcon(),
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              task.name,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          task.completed
              ? Row(
                children: [
                  Text(
                    task.current ?? task.target,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              )
              : OutlinedButton(
                onPressed: () => _showQuickRecordDialog(context, task),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  minimumSize: Size(80, 32),
                ),
                child: Text('记录'),
              ),
        ],
      ),
    );
  }

  void _showQuickRecordDialog(BuildContext context, DailyHealthTask task) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('记录${task.name}'),
            content: Text(
              '此处将显示${task.name}的记录表单，单位: ${task.unit}，目标: ${task.target}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text('保存'),
              ),
            ],
          ),
    );
  }
}

// 最近记录部分
class RecentRecordsSection extends StatelessWidget {
  final List<HealthRecord> records;

  const RecentRecordsSection({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近记录',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // 查看所有记录
              },
              child: Text('查看全部'),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...List.generate(
          records.length > 3 ? 3 : records.length,
          (index) => HealthRecordCard(record: records[index]),
        ),
      ],
    );
  }
}

// 健康记录卡片
class HealthRecordCard extends StatelessWidget {
  final HealthRecord record;

  const HealthRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      record.type == 'physical'
                          ? Icons.straighten
                          : record.type == 'lifestyle'
                          ? Icons.restaurant
                          : record.type == 'health'
                          ? Icons.favorite
                          : Icons.edit_note,
                      size: 18,
                      color:
                          record.type == 'physical'
                              ? Colors.blue
                              : record.type == 'lifestyle'
                              ? Colors.green
                              : record.type == 'health'
                              ? Colors.red
                              : Colors.purple,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _getRecordTypeName(record.type),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  record.date,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (record.metrics != null && record.metrics!.isNotEmpty) ...[
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  for (var entry in record.metrics!.entries)
                    _buildMetricItem(
                      _formatMetricName(entry.key),
                      '${entry.value}',
                    ),
                ],
              ),
            ],
            if (record.notes != null) ...[
              SizedBox(height: 12),
              Text('备注:', style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text(record.notes!, style: TextStyle(color: Colors.grey[800])),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _getRecordTypeName(String type) {
    Map<String, String> typeMap = {
      'physical': '身体指标',
      'lifestyle': '生活习惯',
      'health': '健康指标',
      'diary': '健康日记',
    };

    return typeMap[type] ?? '记录';
  }

  String _formatMetricName(String name) {
    Map<String, String> nameMap = {
      'weight': '体重',
      'height': '身高',
      'bmi': 'BMI',
      'waist': '腰围',
      'bodyFat': '体脂率',
      'steps': '步数',
      'sleep': '睡眠',
      'calories': '卡路里',
      'water': '饮水量',
      'bloodPressure': '血压',
      'bloodSugar': '血糖',
      'heartRate': '心率',
      'temperature': '体温',
    };

    return nameMap[name] ?? name;
  }
}

// 健康报告标签页
class HealthReportsTab extends StatelessWidget {
  final HealthController controller;

  const HealthReportsTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        controller.loadHealthReports(),
        controller.loadHealthRisks(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final healthReports = snapshot.data![0] as List<HealthReport>;
        final healthRisks = snapshot.data![1] as List<HealthRisk>;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HealthTrendsCard(),
              SizedBox(height: 20),
              HealthRisksCard(risks: healthRisks),
              SizedBox(height: 20),
              Text(
                '健康报告列表',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              ...healthReports.map(
                (report) => ReportCard(
                  report: report,
                  isPremiumMember: controller.isUserPremiumMember(),
                ),
              ),
              SizedBox(height: 20),
              if (controller.isUserPremiumMember()) PremiumReportButton(),
            ],
          ),
        );
      },
    );
  }
}

// 健康趋势卡片
class HealthTrendsCard extends StatelessWidget {
  const HealthTrendsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '健康趋势分析',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 180,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text('这里将显示健康趋势图表')),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTrendMetric('体重', '↓1.2kg', Colors.green),
                _buildTrendMetric('血压', '↑5/3', Colors.orange),
                _buildTrendMetric('睡眠', '↑0.5h', Colors.green),
                _buildTrendMetric('步数', '↓1304', Colors.red),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '您的睡眠质量近两周有所改善，但血压略有升高，建议控制饮食盐分，保持规律作息。',
                      style: TextStyle(color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendMetric(String label, String change, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          change,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

// 健康风险卡片
class HealthRisksCard extends StatelessWidget {
  final List<HealthRisk> risks;

  const HealthRisksCard({super.key, required this.risks});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  '健康风险预警',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...risks.map((risk) => _buildRiskItem(context, risk)),
            SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assessment),
                  SizedBox(width: 8),
                  Text('生成完整风险评估报告'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskItem(BuildContext context, HealthRisk risk) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: risk.getSeverityColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: risk.getSeverityColor().withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 12, color: risk.getSeverityColor()),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(risk.title, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  risk.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showRiskSuggestions(context, risk),
            style: TextButton.styleFrom(
              minimumSize: Size(0, 32),
              padding: EdgeInsets.symmetric(horizontal: 12),
              foregroundColor: risk.getSeverityColor(),
            ),
            child: Text('查看建议'),
          ),
        ],
      ),
    );
  }

  void _showRiskSuggestions(BuildContext context, HealthRisk risk) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: risk.getSeverityColor(),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '应对${risk.title}的建议',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ...risk.suggestions
                    .map(
                      (suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check,
                              color: risk.getSeverityColor(),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(child: Text(suggestion)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: risk.getSeverityColor(),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('了解了'),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

// 报告卡片
class ReportCard extends StatelessWidget {
  final HealthReport report;
  final bool isPremiumMember;

  const ReportCard({
    super.key,
    required this.report,
    required this.isPremiumMember,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (report.isPremium && !isPremiumMember) {
            // 提示升级会员
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('此报告需要会员权限查看')));
          } else {
            // 查看报告
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('查看${report.title}')));
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getReportColor(report.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getReportIcon(report.type),
                  color: _getReportColor(report.type),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      report.date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              report.isPremium && !isPremiumMember
                  ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: 14, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          '会员',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                  : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getReportIcon(String type) {
    Map<String, IconData> iconMap = {
      'general': Icons.assessment,
      'physical': Icons.straighten,
      'lifestyle': Icons.restaurant,
      'health': Icons.favorite,
      'risk': Icons.warning_amber_rounded,
    };

    return iconMap[type] ?? Icons.description;
  }

  Color _getReportColor(String type) {
    Map<String, Color> colorMap = {
      'general': Colors.blue,
      'physical': Colors.green,
      'lifestyle': Colors.purple,
      'health': Colors.red,
      'risk': Colors.orange,
    };

    return colorMap[type] ?? Colors.grey;
  }
}

// 高级报告按钮
class PremiumReportButton extends StatelessWidget {
  const PremiumReportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics),
          SizedBox(width: 8),
          Text('生成专业健康评估报告'),
        ],
      ),
    );
  }
}

// 健康AI顾问标签页
class HealthAdvisorTab extends StatefulWidget {
  final HealthController controller;

  const HealthAdvisorTab({super.key, required this.controller});

  @override
  _HealthAdvisorTabState createState() => _HealthAdvisorTabState();
}

class _HealthAdvisorTabState extends State<HealthAdvisorTab> {
  final TextEditingController _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HealthAdvisor>(
      future: widget.controller.loadHealthAdvisor(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final healthAdvisor = snapshot.data!;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AIAdvisorHeader(),
              SizedBox(height: 20),
              if (healthAdvisor.consultations.isNotEmpty)
                ConsultationHistory(consultations: healthAdvisor.consultations),
              SizedBox(height: 20),
              ConsultationInput(
                controller: _questionController,
                onSubmit: _submitQuestion,
              ),
              SizedBox(height: 20),
              HealthSuggestionsCard(suggestions: healthAdvisor.suggestions),
              SizedBox(height: 20),
              widget.controller.isUserPremiumMember()
                  ? PremiumAdvisorFeatures()
                  : PremiumAdvisorPromotion(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitQuestion() async {
    if (_questionController.text.isEmpty) return;

    final question = _questionController.text;
    _questionController.clear();

    // 提交咨询
    await widget.controller.submitConsultation(question);

    // 刷新界面
    setState(() {});
  }
}

// AI顾问头部
class AIAdvisorHeader extends StatelessWidget {
  const AIAdvisorHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.health_and_safety,
                size: 32,
                color: Colors.blue,
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
                    '您好，我是您的健康AI顾问，有什么健康问题需要咨询吗？',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '今日状态: 良好   |   当前时间: 2025-04-19 12:34',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// AI咨询历史
class ConsultationHistory extends StatelessWidget {
  final List<HealthConsultation> consultations;

  const ConsultationHistory({super.key, required this.consultations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近咨询',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        ...consultations.map(
          (consultation) => ConsultationItem(consultation: consultation),
        ),
      ],
    );
  }
}

// AI咨询项
class ConsultationItem extends StatelessWidget {
  final HealthConsultation consultation;

  const ConsultationItem({super.key, required this.consultation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 用户问题
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, size: 20, color: Colors.grey[700]),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(consultation.question),
                    SizedBox(height: 4),
                    Text(
                      consultation.date,
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        // AI回答
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Icon(
                Icons.health_and_safety,
                size: 20,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(consultation.answer),
                    if (consultation.suggestions.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        '建议:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      ...List.generate(
                        consultation.suggestions.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${index + 1}. '),
                              Expanded(
                                child: Text(consultation.suggestions[index]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

// AI咨询输入
class ConsultationInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const ConsultationInput({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '输入您的健康问题...',
                border: InputBorder.none,
              ),
              maxLines: 1,
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

// 健康建议卡片
class HealthSuggestionsCard extends StatelessWidget {
  final List<HealthSuggestion> suggestions;

  const HealthSuggestionsCard({super.key, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  '个性化健康建议',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...suggestions.map(
              (suggestion) => SuggestionItem(suggestion: suggestion),
            ),
          ],
        ),
      ),
    );
  }
}

// 建议项
class SuggestionItem extends StatelessWidget {
  final HealthSuggestion suggestion;

  const SuggestionItem({super.key, required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(suggestion.getCategoryIcon(), size: 18, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                suggestion.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(suggestion.content, style: TextStyle(fontSize: 13)),
          if (suggestion.baziRelevant) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_graph, size: 14, color: Colors.purple),
                  SizedBox(width: 4),
                  Text(
                    '基于八字分析',
                    style: TextStyle(fontSize: 12, color: Colors.purple),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 高级AI顾问功能（会员专享）
class PremiumAdvisorFeatures extends StatelessWidget {
  const PremiumAdvisorFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stars, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  '会员专享',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildFeatureItem(Icons.person, '专业导师一对一指导', '与专业健康顾问预约视频咨询'),
            _buildFeatureItem(Icons.analytics, '深度健康分析', '获取详细的健康状态报告与长期趋势分析'),
            _buildFeatureItem(Icons.auto_graph, '八字命理结合', '融合命理特点的个性化健康建议'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.amber),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: Text('使用')),
        ],
      ),
    );
  }
}

// 会员服务推广
class PremiumAdvisorPromotion extends StatelessWidget {
  const PremiumAdvisorPromotion({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.lock, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  '会员专享服务',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Text(
                    '升级为会员，解锁更多健康管理功能',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeaturePoint('专业导师一对一指导'),
                      SizedBox(width: 16),
                      _buildFeaturePoint('详细健康报告'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeaturePoint('八字命理健康建议'),
                      SizedBox(width: 16),
                      _buildFeaturePoint('健康风险预警'),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      minimumSize: Size(200, 40),
                    ),
                    child: Text('立即升级会员'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}

// 添加健康记录对话框
class AddHealthRecordDialog extends StatefulWidget {
  final Function(HealthRecord) onSave;

  const AddHealthRecordDialog({super.key, required this.onSave});

  @override
  _AddHealthRecordDialogState createState() => _AddHealthRecordDialogState();
}

class _AddHealthRecordDialogState extends State<AddHealthRecordDialog> {
  String _selectedType = 'physical';
  final TextEditingController _notesController = TextEditingController();
  final Map<String, TextEditingController> _metricsControllers = {};

  @override
  void initState() {
    super.initState();

    // 初始化指标输入控制器
    switch (_selectedType) {
      case 'physical':
        _metricsControllers['weight'] = TextEditingController();
        _metricsControllers['bmi'] = TextEditingController();
        _metricsControllers['bodyFat'] = TextEditingController();
        _metricsControllers['waist'] = TextEditingController();
        break;
      case 'lifestyle':
        _metricsControllers['steps'] = TextEditingController();
        _metricsControllers['sleep'] = TextEditingController();
        _metricsControllers['calories'] = TextEditingController();
        _metricsControllers['water'] = TextEditingController();
        break;
      case 'health':
        _metricsControllers['bloodPressure'] = TextEditingController();
        _metricsControllers['heartRate'] = TextEditingController();
        _metricsControllers['bloodSugar'] = TextEditingController();
        _metricsControllers['temperature'] = TextEditingController();
        break;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _metricsControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _updateMetricsControllers() {
    // 清除旧控制器
    _metricsControllers.forEach((_, controller) => controller.dispose());
    _metricsControllers.clear();

    // 创建新控制器
    switch (_selectedType) {
      case 'physical':
        _metricsControllers['weight'] = TextEditingController();
        _metricsControllers['bmi'] = TextEditingController();
        _metricsControllers['bodyFat'] = TextEditingController();
        _metricsControllers['waist'] = TextEditingController();
        break;
      case 'lifestyle':
        _metricsControllers['steps'] = TextEditingController();
        _metricsControllers['sleep'] = TextEditingController();
        _metricsControllers['calories'] = TextEditingController();
        _metricsControllers['water'] = TextEditingController();
        break;
      case 'health':
        _metricsControllers['bloodPressure'] = TextEditingController();
        _metricsControllers['heartRate'] = TextEditingController();
        _metricsControllers['bloodSugar'] = TextEditingController();
        _metricsControllers['temperature'] = TextEditingController();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '添加健康记录',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('记录类型', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            _buildTypeSelector(),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            _selectedType == 'diary' ? _buildDiaryForm() : _buildMetricsForm(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('取消'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text('保存'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTypeOption('physical', '身体指标', Icons.straighten, Colors.blue),
            _buildTypeOption(
              'lifestyle',
              '生活习惯',
              Icons.restaurant,
              Colors.green,
            ),
            _buildTypeOption('health', '健康指标', Icons.favorite, Colors.red),
            _buildTypeOption('diary', '健康日记', Icons.edit_note, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(
    String type,
    String label,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _updateMetricsControllers();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              _selectedType == type
                  ? color.withOpacity(0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: _selectedType == type ? color : Colors.grey,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: _selectedType == type ? color : Colors.grey[700],
                fontWeight:
                    _selectedType == type ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsForm() {
    return SizedBox(
      height: 300,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('指标数据', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 12),
            ..._metricsControllers.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: _formatMetricName(entry.key),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: '输入${_formatMetricName(entry.key)}',
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('备注', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '添加备注...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiaryForm() {
    return SizedBox(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('健康日记', style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _notesController,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: '记录一下今天的健康状况、感受或不适症状...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveRecord() {
    // 获取当前日期和时间
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // 收集指标数据
    Map<String, dynamic>? metrics;
    if (_selectedType != 'diary') {
      metrics = {};
      _metricsControllers.forEach((key, controller) {
        if (controller.text.isNotEmpty) {
          metrics![key] = controller.text;
        }
      });
    }

    // 创建记录对象
    final record = HealthRecord(
      id: 'HR${now.millisecondsSinceEpoch}',
      date: date,
      time: time,
      type: _selectedType,
      metrics: metrics,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    // 保存记录
    widget.onSave(record);

    // 关闭对话框
    Navigator.of(context).pop();
  }

  String _formatMetricName(String name) {
    Map<String, String> nameMap = {
      'weight': '体重 (kg)',
      'height': '身高 (cm)',
      'bmi': 'BMI',
      'waist': '腰围 (cm)',
      'bodyFat': '体脂率 (%)',
      'steps': '步数',
      'sleep': '睡眠 (小时)',
      'calories': '卡路里 (kcal)',
      'water': '饮水量 (ml)',
      'bloodPressure': '血压 (mmHg)',
      'bloodSugar': '血糖 (mmol/L)',
      'heartRate': '心率 (bpm)',
      'temperature': '体温 (℃)',
    };

    return nameMap[name] ?? name;
  }
}
