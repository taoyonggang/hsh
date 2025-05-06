import 'package:flutter/material.dart';

class FeatureChart extends StatelessWidget {
  final Map<String, double> data;
  final String title;

  const FeatureChart({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Center(child: Text('图表组件开发中...')),
          ],
        ),
      ),
    );
  }
}
