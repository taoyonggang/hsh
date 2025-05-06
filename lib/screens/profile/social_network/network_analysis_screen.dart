import 'package:flutter/material.dart';
import '../../../controllers/network_controller.dart';
import '../../../models/relationship/network_comparison.dart';
import '../../../widgets/comparison_graph_view.dart';
import '../../../widgets/feature_chart.dart';
import 'dart:math' as math;

class NetworkAnalysisScreen extends StatefulWidget {
  @override
  _NetworkAnalysisScreenState createState() => _NetworkAnalysisScreenState();
}

class _NetworkAnalysisScreenState extends State<NetworkAnalysisScreen>
    with SingleTickerProviderStateMixin {
  final NetworkController _networkController = NetworkController();
  NetworkComparison? _comparison;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadComparison();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadComparison() async {
    setState(() => _isLoading = true);
    try {
      _comparison = await _networkController.compareNetworks();
    } catch (e) {
      print('加载网络对比数据错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('网络对比分析'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: '对比图'), Tab(text: '差异分析'), Tab(text: '改进建议')],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('分享功能开发中...')));
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _comparison == null
              ? _buildNoDataView()
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildComparisonGraphTab(),
                  _buildDifferenceAnalysisTab(),
                  _buildSuggestionsTab(),
                ],
              ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compare, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            '无法加载网络对比数据',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text('请确保您已创建虚拟关系网络', style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadComparison,
            icon: Icon(Icons.refresh),
            label: Text('重试'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonGraphTab() {
    return Column(
      children: [
        _buildFilterControls(),
        Expanded(child: ComparisonGraphView(comparison: _comparison!)),
        _buildLegend(),
      ],
    );
  }

  Widget _buildFilterControls() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Text('对比模式:'),
          SizedBox(width: 16),
          DropdownButton<String>(
            value: 'overlay',
            items: [
              DropdownMenuItem(value: 'overlay', child: Text('叠加模式')),
              DropdownMenuItem(value: 'side-by-side', child: Text('并排模式')),
              DropdownMenuItem(value: 'difference', child: Text('差异模式')),
            ],
            onChanged: (value) {
              // 更新对比模式
            },
          ),
          Spacer(),
          Icon(Icons.info_outline, color: Colors.grey),
          SizedBox(width: 8),
          Text('社交会员专属', style: TextStyle(color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(Colors.blue, '真实网络节点'),
          _buildLegendItem(Colors.green, '虚拟网络节点'),
          _buildLegendItem(Colors.purple, '两网络共有节点'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDifferenceAnalysisTab() {
    final statisticsData = _comparison?.statistics;

    return statisticsData == null
        ? Center(child: Text('无统计数据'))
        : SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticsCard(),
              SizedBox(height: 16),
              Text(
                '关系分布对比',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                height: 220,
                child: FeatureChart(
                  // 修复参数错误：改用单一data参数并合并数据
                  data: {
                    '家人': statisticsData['realFamilyCount'] ?? 0,
                    '朋友': statisticsData['realFriendsCount'] ?? 0,
                    '同事': statisticsData['realColleaguesCount'] ?? 0,
                    '搭子': statisticsData['realPartnersCount'] ?? 0,
                    '其他': statisticsData['realOthersCount'] ?? 0,
                  },
                  title: '关系分布对比',
                ),
              ),
              SizedBox(height: 16),
              Text(
                '关系交集与差异',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildVennDiagramCard(),
              SizedBox(height: 16),
              _buildMissedConnectionsCard(),
              SizedBox(height: 16),
              _buildRelationshipStrengthCard(),
            ],
          ),
        );
  }

  Widget _buildStatisticsCard() {
    final statistics = _comparison!.statistics;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '网络统计对比',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '真实网络',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      // 修复属性访问错误：使用Map访问
                      _buildStatItem(
                        '用户节点',
                        '${statistics['realNodeCount'] ?? 0}',
                      ),
                      _buildStatItem(
                        '关系连接',
                        '${statistics['realEdgeCount'] ?? 0}',
                      ),
                      _buildStatItem(
                        '网络密度',
                        '${(statistics['realNetworkDensity'] ?? 0.0).toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 100, color: Colors.grey[300]),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '虚拟网络',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      // 修复属性访问错误：使用Map访问
                      _buildStatItem(
                        '用户节点',
                        '${statistics['virtualNodeCount'] ?? 0}',
                      ),
                      _buildStatItem(
                        '关系连接',
                        '${statistics['virtualEdgeCount'] ?? 0}',
                      ),
                      _buildStatItem(
                        '网络密度',
                        '${(statistics['virtualNetworkDensity'] ?? 0.0).toStringAsFixed(2)}',
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

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(': '),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildVennDiagramCard() {
    final statistics = _comparison!.statistics;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              child: CustomPaint(
                painter: VennDiagramPainter(
                  // 修复属性访问错误：使用Map访问
                  realOnly: statistics['realOnlyCount'] ?? 0,
                  virtualOnly: statistics['virtualOnlyCount'] ?? 0,
                  intersection: statistics['sharedCount'] ?? 0,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              // 修复属性访问错误：使用Map访问
              '您的虚拟网络与真实网络有 ${statistics['sharedCount'] ?? 0} 人重合，'
              '真实网络中有 ${statistics['realOnlyCount'] ?? 0} 人未在虚拟网络中，'
              '虚拟网络中有 ${statistics['virtualOnlyCount'] ?? 0} 人未在真实网络中。',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissedConnectionsCard() {
    // 修改为直接从_comparison中获取或初始化为空列表
    final List<dynamic> missedConnections =
        (_comparison?.comparisionData?['missedConnections'] as List?) ?? [];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '潜在社交机会',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('系统发现您可能认识但尚未添加到虚拟网络的人:'),
            SizedBox(height: 12),
            missedConnections.isEmpty
                ? Text('没有发现潜在的社交机会')
                : Column(
                  children:
                      missedConnections
                          .take(3)
                          .map((connection) => _buildConnectionItem(connection))
                          .toList(),
                ),
            if (missedConnections.length > 3) ...[
              SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/network/missed-connections');
                  },
                  child: Text('查看更多 (${missedConnections.length - 3})'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 修改函数接受类型为Map的参数
  Widget _buildConnectionItem(Map<String, dynamic> connection) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(connection['avatarUrl'] ?? ''),
            radius: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connection['name'] ?? '未知用户',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  connection['reason'] ?? '可能认识',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // 添加到虚拟网络
              Navigator.pushNamed(
                context,
                '/network/add-virtual-user',
                arguments: {'suggestedUserId': connection['id']},
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              minimumSize: Size(0, 30),
            ),
            child: Text('添加'),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipStrengthCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '关系强度感知差异',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('您对部分关系的主观强度与系统观测到的客观互动强度存在差异:'),
            SizedBox(height: 12),
            _buildStrengthDifferenceList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthDifferenceList() {
    // 修改为直接从_comparison中获取或初始化为空列表
    final List<dynamic> differences =
        (_comparison?.comparisionData?['strengthDifferences'] as List?) ?? [];

    return differences.isEmpty
        ? Text('没有明显的关系强度感知差异')
        : Column(
          children:
              differences
                  .take(3)
                  .map((diff) => _buildStrengthDifferenceItem(diff))
                  .toList(),
        );
  }

  // 修改函数接受类型为Map的参数
  Widget _buildStrengthDifferenceItem(Map<String, dynamic> diff) {
    String message;
    IconData icon;
    Color color;

    final perceivedStrength = diff['perceivedStrength'] ?? 0.5;
    final actualStrength = diff['actualStrength'] ?? 0.5;

    if (perceivedStrength > actualStrength) {
      message = '您认为关系较为亲密，但实际互动较少';
      icon = Icons.arrow_downward;
      color = Colors.orange;
    } else {
      message = '实际互动频繁，关系可能比您感知的更亲密';
      icon = Icons.arrow_upward;
      color = Colors.blue;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
                diff['avatarUrl'] != null
                    ? NetworkImage(diff['avatarUrl'])
                    : null,
            child: diff['avatarUrl'] == null ? Icon(Icons.person) : null,
            radius: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diff['userName'] ?? '未知用户',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(icon, size: 14, color: color),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '感知: ${((perceivedStrength as double) * 10).toStringAsFixed(0)}',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                '实际: ${((actualStrength as double) * 10).toStringAsFixed(0)}',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsTab() {
    final suggestions =
        _comparison?.comparisionData?['suggestedActions'] as List?;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHealthScoreCard(),
          SizedBox(height: 16),
          Text(
            '改进建议',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child:
                  suggestions == null || suggestions.isEmpty
                      ? Text('没有改进建议')
                      : Column(
                        children:
                            suggestions
                                .map(
                                  (suggestion) => _buildSuggestionItem(
                                    suggestion.toString(),
                                  ),
                                )
                                .toList(),
                      ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '长期目标',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _buildLongTermGoalsCard(),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    final networkHealthScore =
        _comparison?.comparisionData?['networkHealthScore'] as double? ?? 0.5;
    final networkSimilarity =
        _comparison?.comparisionData?['networkSimilarity'] as double? ?? 0.5;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '网络健康评分',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreCircle('网络健康度', networkHealthScore, Colors.green),
                _buildScoreCircle('网络相似度', networkSimilarity, Colors.blue),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '您的社交网络健康状态良好。相似度指标表明您对自己的社交网络有较为准确的认知。',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(String label, double score, Color color) {
    final percentage = (score * 100).toInt();

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(
                    value: score,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              Center(
                child: Text(
                  '$percentage%',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSuggestionItem(String suggestion) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          SizedBox(width: 12),
          Expanded(child: Text(suggestion)),
        ],
      ),
    );
  }

  Widget _buildLongTermGoalsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLongTermGoalItem('增加虚拟网络多样性', '平衡扩展不同类型的社交关系，丰富您的社交圈', 0.6),
            SizedBox(height: 16),
            _buildLongTermGoalItem('提高关键关系互动频率', '与重要的社交关系保持更频繁的有质量互动', 0.4),
            SizedBox(height: 16),
            _buildLongTermGoalItem('提高网络映射率', '将更多虚拟网络中的用户映射到真实用户', 0.7),
          ],
        ),
      ),
    );
  }

  Widget _buildLongTermGoalItem(
    String title,
    String description,
    double progress,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Text('${(progress * 100).toInt()}%'),
          ],
        ),
        SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ],
    );
  }
}

class VennDiagramPainter extends CustomPainter {
  final int realOnly;
  final int virtualOnly;
  final int intersection;

  VennDiagramPainter({
    required this.realOnly,
    required this.virtualOnly,
    required this.intersection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final realCircleRadius = 60.0;
    final virtualCircleRadius = 60.0;
    final centerOffset = 40.0; // 控制两个圆的交叉程度

    final realCenter = Offset(size.width / 2 - centerOffset, size.height / 2);
    final virtualCenter = Offset(
      size.width / 2 + centerOffset,
      size.height / 2,
    );

    // 绘制真实网络圆
    final realPaint =
        Paint()
          ..color = Colors.blue.withOpacity(0.5)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(realCenter, realCircleRadius, realPaint);

    // 绘制虚拟网络圆
    final virtualPaint =
        Paint()
          ..color = Colors.green.withOpacity(0.5)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(virtualCenter, virtualCircleRadius, virtualPaint);

    // 绘制标签
    final textStyle = TextStyle(
      color: Colors.black87,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    final realTextPainter = TextPainter(
      text: TextSpan(text: '真实网络\n$realOnly', style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    realTextPainter.layout();
    realTextPainter.paint(
      canvas,
      Offset(
        realCenter.dx - realTextPainter.width / 2 - 20,
        realCenter.dy - realTextPainter.height / 2,
      ),
    );

    final intersectionTextPainter = TextPainter(
      text: TextSpan(text: '共有\n$intersection', style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    intersectionTextPainter.layout();
    intersectionTextPainter.paint(
      canvas,
      Offset(
        size.width / 2 - intersectionTextPainter.width / 2,
        size.height / 2 - intersectionTextPainter.height / 2,
      ),
    );

    final virtualTextPainter = TextPainter(
      text: TextSpan(text: '虚拟网络\n$virtualOnly', style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    virtualTextPainter.layout();
    virtualTextPainter.paint(
      canvas,
      Offset(
        virtualCenter.dx - virtualTextPainter.width / 2 + 20,
        virtualCenter.dy - virtualTextPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant VennDiagramPainter oldDelegate) {
    return oldDelegate.realOnly != realOnly ||
        oldDelegate.virtualOnly != virtualOnly ||
        oldDelegate.intersection != intersection;
  }
}
