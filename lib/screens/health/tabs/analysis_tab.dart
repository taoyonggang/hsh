import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../controllers/health_controller.dart';
import '../../../models/health/health_models.dart';

class AnalysisTab extends StatefulWidget {
  const AnalysisTab({super.key});

  @override
  _AnalysisTabState createState() => _AnalysisTabState();
}

class _AnalysisTabState extends State<AnalysisTab> {
  final HealthController _controller = HealthController();
  bool _isLoading = true;

  HealthAnalysis? _healthAnalysis;
  List<BodyMetrics>? _bodyMetrics;
  List<HealthIndicators>? _healthIndicators;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _healthAnalysis = await _controller.loadHealthAnalysis();
      _bodyMetrics = await _controller.loadBodyMetrics();
      _healthIndicators = await _controller.loadHealthIndicators();
    } catch (e) {
      print('Error loading analysis data: $e');
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
          _buildHealthAnalysisHeader(),
          SizedBox(height: 20),
          _buildHealthInsightsCard(),
          SizedBox(height: 20),
          _buildHealthRecommendationsCard(),
          SizedBox(height: 20),
          _buildHealthRisksCard(),
          SizedBox(height: 20),
          _buildTrendsCard(),
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
    if (_healthAnalysis == null || _healthAnalysis!.insights.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('暂无健康洞察数据', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
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
              '健康洞察',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
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
    if (_healthAnalysis == null || _healthAnalysis!.recommendations.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('暂无健康建议', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    // 筛选可见和会员专属建议
    List<HealthRecommendation> visibleRecommendations = [];
    List<HealthRecommendation> premiumRecommendations = [];

    for (var rec in _healthAnalysis!.recommendations) {
      if (!rec.isPremiumOnly || _controller.isUserPremiumMember()) {
        visibleRecommendations.add(rec);
      } else {
        premiumRecommendations.add(rec);
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
                child: Text('暂无健康建议', style: TextStyle(color: Colors.grey)),
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
    if (_healthAnalysis == null || _healthAnalysis!.risks.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('暂无健康风险预警', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    // 筛选可见和会员专属风险
    List<HealthRisk> visibleRisks = [];
    List<HealthRisk> premiumRisks = [];

    for (var risk in _healthAnalysis!.risks) {
      if (!risk.isPremiumOnly || _controller.isUserPremiumMember()) {
        visibleRisks.add(risk);
      } else {
        premiumRisks.add(risk);
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
                child: Text('暂无健康风险预警', style: TextStyle(color: Colors.grey)),
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
          Text(risk.description),
        ],
      ),
    );
  }

  // 趋势卡片
  Widget _buildTrendsCard() {
    if (_bodyMetrics == null || _bodyMetrics!.length < 2) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '健康趋势',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    '数据不足，无法生成趋势图',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
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
              '健康趋势',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: _buildTrendChart(),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildChartLegend('体重', Colors.blue),
                _buildChartLegend('BMI', Colors.green),
                _buildChartLegend('腰围', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 图表图例
  Widget _buildChartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: color),
        SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  // 简单趋势图
  Widget _buildTrendChart() {
    // 实际应用中应使用图表库，这里简单实现为占位
    return Center(child: Text('此处显示趋势图表'));
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

  // 会员升级对话框
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
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star, color: Colors.amber, size: 40),
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
                Text('全面健康检测 + 个性化报告 + 定制健康方案', textAlign: TextAlign.center),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('暂不升级'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: Text('立即购买'),
              ),
            ],
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
