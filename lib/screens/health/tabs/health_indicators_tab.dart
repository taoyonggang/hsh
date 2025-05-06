import 'package:flutter/material.dart';
import '../../../controllers/health_controller.dart';
import '../../../models/health/health_models.dart';

class HealthIndicatorsTab extends StatefulWidget {
  const HealthIndicatorsTab({super.key});

  @override
  _HealthIndicatorsTabState createState() => _HealthIndicatorsTabState();
}

class _HealthIndicatorsTabState extends State<HealthIndicatorsTab> {
  final HealthController _controller = HealthController();
  bool _isLoading = true;
  List<HealthIndicators>? _healthIndicators;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _healthIndicators = await _controller.loadHealthIndicators();
    } catch (e) {
      print('Error loading health indicators: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_healthIndicators == null || _healthIndicators!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无健康指标记录', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showAddIndicatorsDialog(),
              child: Text('添加指标记录'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLatestIndicatorsCard(),
            SizedBox(height: 24),
            _buildBloodPressureCard(),
            SizedBox(height: 24),
            _buildHeartRateCard(),
            SizedBox(height: 24),
            _buildBloodSugarCard(),
            SizedBox(height: 24),
            _buildHistoryCard(),
          ],
        ),
      ),
    );
  }

  // 最新指标卡片
  Widget _buildLatestIndicatorsCard() {
    final latest = _healthIndicators!.last;

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
                  '最新健康指标',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  latest.recordDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (latest.bloodPressure != null)
                  _buildIndicatorItem(
                    '血压',
                    '${latest.bloodPressure!.systolic}/${latest.bloodPressure!.diastolic}',
                    Icons.show_chart,
                    subtitle: latest.bloodPressure!.getStatus(),
                    subtitleColor: _getBloodPressureColor(
                      latest.bloodPressure!,
                    ),
                  ),
                if (latest.heartRate != null)
                  _buildIndicatorItem(
                    '心率',
                    '${latest.heartRate!}次/分',
                    Icons.favorite,
                    subtitle: _getHeartRateStatus(latest.heartRate!),
                    subtitleColor: _getHeartRateColor(latest.heartRate!),
                  ),
                if (latest.bloodSugar != null)
                  _buildIndicatorItem(
                    '血糖',
                    '${latest.bloodSugar!}mmol/L',
                    Icons.opacity,
                    subtitle: _getBloodSugarStatus(latest.bloodSugar!),
                    subtitleColor: _getBloodSugarColor(latest.bloodSugar!),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('添加健康指标'),
                  onPressed: () => _showAddIndicatorsDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 指标项
  Widget _buildIndicatorItem(
    String label,
    String value,
    IconData icon, {
    String? subtitle,
    Color? subtitleColor,
  }) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          Icon(icon, color: Colors.red[400]),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: subtitleColor ?? Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 血压卡片
  Widget _buildBloodPressureCard() {
    // 过滤有血压数据的记录
    final bloodPressureData =
        _healthIndicators!
            .where((indicator) => indicator.bloodPressure != null)
            .toList();

    if (bloodPressureData.isEmpty) {
      return Container();
    }

    final latestBP = bloodPressureData.last.bloodPressure!;
    final status = latestBP.getStatus();
    final statusColor = _getBloodPressureColor(latestBP);

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
                Icon(Icons.show_chart, color: Colors.red[400]),
                SizedBox(width: 8),
                Text(
                  '血压监测',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${latestBP.systolic} / ${latestBP.diastolic} mmHg',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '收缩压 / 舒张压',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(height: 100, child: Center(child: Text('血压趋势图表显示区域'))),
          ],
        ),
      ),
    );
  }

  // 心率卡片
  Widget _buildHeartRateCard() {
    // 过滤有心率数据的记录
    final heartRateData =
        _healthIndicators!
            .where((indicator) => indicator.heartRate != null)
            .toList();

    if (heartRateData.isEmpty) {
      return Container();
    }

    final latestHR = heartRateData.last.heartRate!;
    final status = _getHeartRateStatus(latestHR);
    final statusColor = _getHeartRateColor(latestHR);

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
                Icon(Icons.favorite, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  '心率监测',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$latestHR 次/分',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '静息心率',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(height: 100, child: Center(child: Text('心率趋势图表显示区域'))),
            SizedBox(height: 8),
            Text(
              '正常范围: 60-100次/分',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // 血糖卡片
  Widget _buildBloodSugarCard() {
    // 过滤有血糖数据的记录
    final bloodSugarData =
        _healthIndicators!
            .where((indicator) => indicator.bloodSugar != null)
            .toList();

    if (bloodSugarData.isEmpty) {
      return Container();
    }

    final latestBS = bloodSugarData.last.bloodSugar!;
    final status = _getBloodSugarStatus(latestBS);
    final statusColor = _getBloodSugarColor(latestBS);

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
                Icon(Icons.opacity, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  '血糖监测',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$latestBS mmol/L',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '空腹血糖',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(height: 100, child: Center(child: Text('血糖趋势图表显示区域'))),
            SizedBox(height: 8),
            Text(
              '正常范围: 3.9-6.1 mmol/L（空腹）',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // 历史记录卡片
  Widget _buildHistoryCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              itemCount: _healthIndicators!.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                // 倒序显示，最新的在上面
                final indicators =
                    _healthIndicators![_healthIndicators!.length - 1 - index];
                return _buildHistoryItem(indicators);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 历史记录项
  Widget _buildHistoryItem(HealthIndicators indicators) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 4),
      title: Text(
        indicators.recordDate,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (indicators.bloodPressure != null)
              Text(
                '血压: ${indicators.bloodPressure!.systolic}/${indicators.bloodPressure!.diastolic} mmHg',
                style: TextStyle(fontSize: 12),
              ),
            if (indicators.heartRate != null)
              Text(
                '心率: ${indicators.heartRate} 次/分',
                style: TextStyle(fontSize: 12),
              ),
            if (indicators.bloodSugar != null)
              Text(
                '血糖: ${indicators.bloodSugar} mmol/L',
                style: TextStyle(fontSize: 12),
              ),
            if (indicators.bodyTemperature != null)
              Text(
                '体温: ${indicators.bodyTemperature} °C',
                style: TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
      onTap: () => _showIndicatorDetails(indicators),
    );
  }

  // 添加健康指标对话框
  void _showAddIndicatorsDialog() {
    // 临时控制器
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final heartRateController = TextEditingController();
    final bloodSugarController = TextEditingController();
    final bodyTempController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('记录健康指标'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '血压 (mmHg)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: systolicController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '收缩压',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: diastolicController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '舒张压',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: heartRateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '心率 (次/分)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: bloodSugarController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '血糖 (mmol/L)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: bodyTempController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '体温 (°C)',
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
                  // 解析输入
                  final systolic = int.tryParse(systolicController.text);
                  final diastolic = int.tryParse(diastolicController.text);
                  final heartRate = int.tryParse(heartRateController.text);
                  final bloodSugar = double.tryParse(bloodSugarController.text);
                  final bodyTemp = double.tryParse(bodyTempController.text);

                  BloodPressure? bloodPressure;
                  if (systolic != null && diastolic != null) {
                    bloodPressure = BloodPressure(
                      systolic: systolic,
                      diastolic: diastolic,
                    );
                  }

                  final now = DateTime(2025, 4, 21);
                  final dateString =
                      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

                  final indicators = HealthIndicators(
                    bloodPressure: bloodPressure,
                    heartRate: heartRate,
                    bloodSugar: bloodSugar,
                    bodyTemperature: bodyTemp,
                    recordDate: dateString,
                  );

                  _controller.saveHealthIndicators(indicators).then((success) {
                    if (success) {
                      _loadData();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('健康指标记录成功')));
                    }
                  });
                },
                child: Text('保存'),
              ),
            ],
          ),
    );
  }

  // 显示详细信息对话框
  void _showIndicatorDetails(HealthIndicators indicators) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('健康指标详情'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '记录日期: ${indicators.recordDate}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                if (indicators.bloodPressure != null) ...[
                  _buildDetailRow(
                    '血压',
                    '${indicators.bloodPressure!.systolic}/${indicators.bloodPressure!.diastolic} mmHg',
                  ),
                  Text(
                    '(${indicators.bloodPressure!.getStatus()})',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getBloodPressureColor(indicators.bloodPressure!),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                if (indicators.heartRate != null) ...[
                  _buildDetailRow('心率', '${indicators.heartRate} 次/分'),
                  Text(
                    '(${_getHeartRateStatus(indicators.heartRate!)})',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getHeartRateColor(indicators.heartRate!),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                if (indicators.bloodSugar != null) ...[
                  _buildDetailRow('血糖', '${indicators.bloodSugar} mmol/L'),
                  Text(
                    '(${_getBloodSugarStatus(indicators.bloodSugar!)})',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getBloodSugarColor(indicators.bloodSugar!),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                if (indicators.bodyTemperature != null)
                  _buildDetailRow('体温', '${indicators.bodyTemperature} °C'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('关闭'),
              ),
            ],
          ),
    );
  }

  // 详情行
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // 获取血压状态颜色
  Color _getBloodPressureColor(BloodPressure bp) {
    if (bp.systolic < 90 || bp.diastolic < 60) {
      return Colors.blue;
    } else if (bp.systolic < 120 && bp.diastolic < 80) {
      return Colors.green;
    } else if (bp.systolic < 140 || bp.diastolic < 90) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  // 获取心率状态
  String _getHeartRateStatus(int heartRate) {
    if (heartRate < 60) {
      return "偏低";
    } else if (heartRate <= 100) {
      return "正常";
    } else {
      return "偏高";
    }
  }

  // 获取心率状态颜色
  Color _getHeartRateColor(int heartRate) {
    if (heartRate < 60) {
      return Colors.blue;
    } else if (heartRate <= 100) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  // 获取血糖状态
  String _getBloodSugarStatus(double bloodSugar) {
    if (bloodSugar < 3.9) {
      return "偏低";
    } else if (bloodSugar <= 6.1) {
      return "正常";
    } else if (bloodSugar <= 7.0) {
      return "偏高";
    } else {
      return "过高";
    }
  }

  // 获取血糖状态颜色
  Color _getBloodSugarColor(double bloodSugar) {
    if (bloodSugar < 3.9) {
      return Colors.blue;
    } else if (bloodSugar <= 6.1) {
      return Colors.green;
    } else if (bloodSugar <= 7.0) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
}
