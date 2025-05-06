import 'package:flutter/material.dart';
import '../models/relationship/network_comparison.dart';

class ComparisonGraphView extends StatelessWidget {
  final NetworkComparison comparison;

  const ComparisonGraphView({super.key, required this.comparison});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.compare, size: 60, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              '网络对比分析',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('该组件正在开发中...'),
          ],
        ),
      ),
    );
  }
}
