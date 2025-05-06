import 'package:flutter/material.dart';
import 'body_metrics_tab.dart';
import 'lifestyle_tab.dart';
import 'health_indicators_tab.dart';
import 'health_diary_tab.dart';

class DataRecordingTab extends StatelessWidget {
  const DataRecordingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: '身体指标'),
              Tab(text: '生活习惯'),
              Tab(text: '健康指标'),
              Tab(text: '健康日记'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                BodyMetricsTab(),
                LifestyleTab(),
                HealthIndicatorsTab(),
                HealthDiaryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
