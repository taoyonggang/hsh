import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FeatureChart extends StatelessWidget {
  final Map<String, dynamic> realData;
  final Map<String, dynamic>? virtualData;
  final String title;

  const FeatureChart({
    Key? key,
    required this.realData,
    this.virtualData,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keys = realData.keys.toList();
    final maxValue = _getMaxValue();

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 16),
        Expanded(
          child: RadarChart(
            RadarChartData(
              radarShape: RadarShape.polygon,
              tickCount: 4,
              radarBorderData: BorderSide(color: Colors.grey[400]!),
              gridBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
              tickBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
              // 更新为新的API接口
              getTitle:
                  (index, angle) => RadarChartTitle(
                    text: keys[index % keys.length],
                    angle: angle,
                  ),
              titleTextStyle: TextStyle(color: Colors.grey[600]!, fontSize: 12),
              titlePositionPercentageOffset: 0.2,
              dataSets: [
                RadarDataSet(
                  dataEntries:
                      keys.map((key) {
                        final value =
                            (realData[key] is num)
                                ? (realData[key] as num).toDouble()
                                : 0.0;
                        return RadarEntry(value: value);
                      }).toList(),
                  fillColor: Colors.blue.withOpacity(0.2),
                  borderColor: Colors.blue,
                  entryRadius: 4,
                ),
                if (virtualData != null)
                  RadarDataSet(
                    dataEntries:
                        keys.map((key) {
                          final value =
                              (virtualData![key] is num)
                                  ? (virtualData![key] as num).toDouble()
                                  : 0.0;
                          return RadarEntry(value: value);
                        }).toList(),
                    fillColor: Colors.green.withOpacity(0.2),
                    borderColor: Colors.green,
                    entryRadius: 4,
                  ),
              ],
              // 更新触摸数据API
              radarTouchData: RadarTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, touchResponse) {
                  // 可以在这里处理触摸事件
                },
              ),
              // 移除不支持的 maxEntryRadius 参数
            ),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.blue, '真实网络'),
            SizedBox(width: 24),
            if (virtualData != null) _buildLegendItem(Colors.green, '虚拟网络'),
          ],
        ),
      ],
    );
  }

  // 计算最大值，仅用于内部参考
  double _getMaxValue() {
    double max = 0;

    // 检查真实数据的最大值
    realData.forEach((key, value) {
      if (value is num && value > max) {
        max = value.toDouble();
      }
    });

    // 如果有虚拟数据，也检查其最大值
    if (virtualData != null) {
      virtualData!.forEach((key, value) {
        if (value is num && value > max) {
          max = value.toDouble();
        }
      });
    }

    return max;
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
}
