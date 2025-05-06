import 'package:flutter/material.dart';
import '../../../controllers/health_controller.dart';
import '../../../models/health/health_models.dart';

class BodyMetricsTab extends StatefulWidget {
  const BodyMetricsTab({super.key});

  @override
  _BodyMetricsTabState createState() => _BodyMetricsTabState();
}

class _BodyMetricsTabState extends State<BodyMetricsTab> {
  final HealthController _controller = HealthController();
  bool _isLoading = true;
  List<BodyMetrics>? _bodyMetrics;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _bodyMetrics = await _controller.loadBodyMetrics();
    } catch (e) {
      print('Error loading body metrics: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_bodyMetrics == null || _bodyMetrics!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor_weight_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无身体指标记录', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showAddMetricsDialog(),
              child: Text('添加身体指标'),
            ),
          ],
        ),
      );
    }

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
                  Text(
                    '最新记录',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('身高'),
                          Text(
                            '${_bodyMetrics!.last.height.toStringAsFixed(1)} cm',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('体重'),
                          Text(
                            '${_bodyMetrics!.last.weight.toStringAsFixed(1)} kg',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BMI'),
                          Text(
                            _bodyMetrics!.last.bmi.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _showAddMetricsDialog(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 36),
                    ),
                    child: Text('记录新数据'),
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
                    itemCount: _bodyMetrics!.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      // 倒序显示，最新的在上面
                      final metrics =
                          _bodyMetrics![_bodyMetrics!.length - 1 - index];
                      return ListTile(
                        title: Text('日期: ${metrics.recordDate}'),
                        subtitle: Text(
                          '身高: ${metrics.height}cm | 体重: ${metrics.weight}kg | BMI: ${metrics.bmi.toStringAsFixed(1)}',
                        ),
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

  // 添加身体指标对话框
  void _showAddMetricsDialog() {
    final heightController = TextEditingController();
    final weightController = TextEditingController();
    final waistController = TextEditingController();
    final bodyFatController = TextEditingController();

    if (_bodyMetrics != null && _bodyMetrics!.isNotEmpty) {
      final latest = _bodyMetrics!.last;
      heightController.text = latest.height.toString();
      weightController.text = latest.weight.toString();
      waistController.text = latest.waistCircumference.toString();
      bodyFatController.text = latest.bodyFatPercentage.toString();
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

                  final now = DateTime(2025, 4, 21);
                  final dateString =
                      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

                  final metrics = BodyMetrics(
                    height: height,
                    weight: weight,
                    waistCircumference: waist,
                    bodyFatPercentage: bodyFat,
                    bmi: bmi,
                    recordDate: dateString,
                  );

                  _controller.saveBodyMetrics(metrics).then((success) {
                    if (success) {
                      _loadData();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('身体指标记录成功')));
                    }
                  });
                },
                child: Text('保存'),
              ),
            ],
          ),
    );
  }
}
