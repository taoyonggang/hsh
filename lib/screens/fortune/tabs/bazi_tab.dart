import 'package:flutter/material.dart';
import '../../../controllers/fortune_controller.dart';
import '../../../models/fortune/fortune_models.dart';
import '../widgets/element_chart.dart';

class BaziTab extends StatefulWidget {
  const BaziTab({super.key});

  @override
  _BaziTabState createState() => _BaziTabState();
}

class _BaziTabState extends State<BaziTab> {
  final FortuneController _controller = FortuneController();
  bool _isLoading = true;
  BaziData? _baziData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _baziData = await _controller.loadBaziData();
    } catch (e) {
      print('加载八字数据错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_baziData == null) {
      return Center(child: Text('无法加载八字数据'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserBaziHeader(_baziData!),
          SizedBox(height: 20),
          _buildBaziChart(_baziData!),
          SizedBox(height: 20),
          _buildElementDistribution(_baziData!),
          SizedBox(height: 20),
          _buildBaziAnalysis(_baziData!),
        ],
      ),
    );
  }

  Widget _buildUserBaziHeader(BaziData baziData) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Text(
                    baziData.name.substring(0, 1),
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baziData.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '出生: ${_formatDate(baziData.birthDateTime)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '地点: ${baziData.birthLocation}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text(
              '命局类型: ${baziData.lifeType}',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('主气: ${baziData.mainElement}'),
                      SizedBox(height: 4),
                      Text('喜神: ${baziData.favorableElement}'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text('忌神: ${baziData.unfavorableElement}')],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaziChart(BaziData baziData) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '四柱八字',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  baziData.pillars
                      .map((pillar) => _buildPillarColumn(pillar))
                      .toList(),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text(
              '五行解读',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              '本命局${baziData.mainElement}为主气，需${baziData.favorableElement}相助，避${baziData.unfavorableElement}克制。',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarColumn(BaziPillar pillar) {
    return Column(
      children: [
        Container(
          width: 60,
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _controller.getElementColor(pillar.element).withOpacity(0.1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                pillar.heavenlyStem,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '(${pillar.element})',
                style: TextStyle(
                  fontSize: 12,
                  color: _controller
                      .getElementColor(pillar.element)
                      .withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 60,
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            pillar.earthlyBranch,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _controller.getElementColor(pillar.element),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          pillar.name,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildElementDistribution(BaziData baziData) {
    Map<String, double> percentages = _controller.calculateElementPercentages();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '五行分布',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: ElementDistributionChart(
                    distribution: ElementDistribution(
                      distribution: percentages,
                    ),
                    controller: _controller,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildElementItem(
                        '木',
                        baziData.elementCounts['木'] ?? 0,
                        percentages['木'] ?? 0,
                      ),
                      SizedBox(height: 8),
                      _buildElementItem(
                        '火',
                        baziData.elementCounts['火'] ?? 0,
                        percentages['火'] ?? 0,
                      ),
                      SizedBox(height: 8),
                      _buildElementItem(
                        '土',
                        baziData.elementCounts['土'] ?? 0,
                        percentages['土'] ?? 0,
                      ),
                      SizedBox(height: 8),
                      _buildElementItem(
                        '金',
                        baziData.elementCounts['金'] ?? 0,
                        percentages['金'] ?? 0,
                      ),
                      SizedBox(height: 8),
                      _buildElementItem(
                        '水',
                        baziData.elementCounts['水'] ?? 0,
                        percentages['水'] ?? 0,
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

  Widget _buildElementItem(String element, int count, double percentage) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: _controller.getElementColor(element),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(element, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(width: 8),
        Text('$count 个', style: TextStyle(fontSize: 14)),
        Spacer(),
        Text(
          '${(percentage * 100).toStringAsFixed(1)}%',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBaziAnalysis(BaziData baziData) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '性格特点分析',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  baziData.traits
                      .map(
                        (trait) => Chip(
                          label: Text(trait),
                          backgroundColor: Colors.indigo.withOpacity(0.1),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 16),
            Text(
              '性格解读',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '根据您的八字特点，天干偏${baziData.mainElement}，具有${_getElementCharacteristics(baziData.mainElement)}的特质。${baziData.favorableElement}能帮助您平衡并增强运势。',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            if (!_controller.canViewPremiumContent()) ...[
              Divider(),
              SizedBox(height: 12),
              Center(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.lock),
                  label: Text('升级获取更详细分析'),
                  onPressed: _showUpgradeDialog,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getElementCharacteristics(String element) {
    switch (element) {
      case '木':
        return '进取、仁慈、灵活';
      case '火':
        return '热情、活力、创造力';
      case '土':
        return '稳重、踏实、忠诚';
      case '金':
        return '坚毅、果断、正直';
      case '水':
        return '智慧、适应力、冷静';
      default:
        return '多样';
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('升级至专业版'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 64, color: Colors.amber),
                SizedBox(height: 16),
                Text(
                  '解锁全部高级功能',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 16),
                Text('• 完整八字命盘解析'),
                Text('• 五行喜忌详解'),
                Text('• 流年流月运势预测'),
                Text('• 个性化运势指导'),
                SizedBox(height: 16),
                Text(
                  '¥199/年',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('稍后再说'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: Text('立即升级'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
