import 'package:flutter/material.dart';
import '../../../controllers/fortune_controller.dart';
import '../../../models/fortune/fortune_models.dart';
import '../widgets/upgrade_card.dart';

class QimenTab extends StatefulWidget {
  const QimenTab({super.key});

  @override
  _QimenTabState createState() => _QimenTabState();
}

class _QimenTabState extends State<QimenTab> {
  final FortuneController _controller = FortuneController();
  bool _isLoading = true;
  QimenInfo? _qimenInfo;
  bool _showQimenDetail = false; // 添加状态变量控制是否显示奇门遁甲详情

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _qimenInfo = await _controller.loadQimenInfo();
    } catch (e) {
      print('加载奇门遁甲数据错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_qimenInfo == null) {
      return Center(child: Text('无法加载奇门遁甲数据'));
    }

    // 仅对付费用户显示奇门遁甲内容
    if (_qimenInfo!.isPremiumDetail &&
        !_controller.canViewPremiumContent() &&
        !_showQimenDetail) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: FortuneUpgradeCard(
            title: '解锁奇门遁甲功能',
            description: '升级至专业版，获取奇门遁甲排盘、九宫格局解析、吉凶方位和个性化指导',
            height: 300,
            onPurchase: () {
              // 直接显示奇门遁甲详情
              setState(() {
                _showQimenDetail = true;
              });
              // 提示用户成功查看
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('您现在可以查看奇门遁甲详情了')));
            },
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQimenBasicInfo(),
          SizedBox(height: 20),
          _buildDirectionsCard(),
          SizedBox(height: 20),
          _buildPalacesCard(),
          SizedBox(height: 20),
          _buildBaziCompatibilityCard(),
        ],
      ),
    );
  }

  // 其余方法保持不变
  Widget _buildQimenBasicInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '奇门遁甲排盘',
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
                        '排盘时间',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _qimenInfo!.formationTime,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '当前节气',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _qimenInfo!.jieQi,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '元空',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  _qimenInfo!.yuanKong,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionsCard() {
    if (_qimenInfo!.directions.isEmpty) {
      return SizedBox.shrink();
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
              '方位吉凶',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              children:
                  _qimenInfo!.directions.entries.map((entry) {
                    // 方位状态颜色
                    Color statusColor;
                    if (entry.value.contains('大吉')) {
                      statusColor = Colors.green;
                    } else if (entry.value.contains('吉')) {
                      statusColor = Colors.lightGreen;
                    } else if (entry.value.contains('中')) {
                      statusColor = Colors.amber;
                    } else {
                      statusColor = Colors.red;
                    }

                    return Card(
                      elevation: 0,
                      color: statusColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              entry.value,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPalacesCard() {
    if (_qimenInfo!.palaces.isEmpty) {
      return SizedBox.shrink();
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
              '九宫格局',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _qimenInfo!.palaces.length,
              itemBuilder: (context, index) {
                final palace = _qimenInfo!.palaces[index];
                return _buildPalaceItem(palace);
              },
            ),
            SizedBox(height: 16),
            if (_qimenInfo!.timeTrends.isNotEmpty) ...[
              Text(
                '时空动态分析',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              ...List.generate(
                _qimenInfo!.timeTrends.length,
                (index) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• '),
                      Expanded(child: Text(_qimenInfo!.timeTrends[index])),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPalaceItem(Palace palace) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${palace.number}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 4),
          Divider(height: 1),
          SizedBox(height: 4),
          Text(palace.door, style: TextStyle(color: Colors.blue, fontSize: 12)),
          SizedBox(height: 4),
          Text(
            palace.star,
            style: TextStyle(color: Colors.purple, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBaziCompatibilityCard() {
    if (_qimenInfo!.baziCompatibility.isEmpty) {
      return SizedBox.shrink();
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
              '八字与奇门结合分析',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(_qimenInfo!.baziCompatibility, style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
