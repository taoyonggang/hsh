import 'package:flutter/material.dart';
import '../../controllers/health_controller.dart';
import 'tabs/overview_tab.dart';
import 'tabs/data_recording_tab.dart';
import 'tabs/analysis_tab.dart';
import 'tabs/advisor_tab.dart';
import '../../widgets/app_bottom_navigation.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen>
    with SingleTickerProviderStateMixin {
  final HealthController _controller = HealthController();
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _controller.initialize();
    } catch (e) {
      print('Error loading health data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('健康管理'),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _loadData)],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '健康概览'),
            Tab(text: '数据记录'),
            Tab(text: '健康分析'),
            Tab(text: '健康顾问'),
          ],
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  OverviewTab(),
                  DataRecordingTab(),
                  AnalysisTab(),
                  AdvisorTab(),
                ],
              ),
      floatingActionButton:
          _tabController.index == 1
              ? FloatingActionButton(
                onPressed: () => _showAddRecordDialog(),
                tooltip: '添加记录',
                child: Icon(Icons.add),
              )
              : null,
      bottomNavigationBar: AppBottomNavigation(currentIndex: 1),
    );
  }

  void _showAddRecordDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('添加健康记录'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.monitor_weight),
                  title: Text('记录身体指标'),
                  onTap: () {
                    Navigator.pop(context);
                    // 切换到身体指标标签页
                    _tabController.animateTo(1);
                    // 延迟执行以确保标签切换完成
                    Future.delayed(Duration(milliseconds: 100), () {
                      DefaultTabController.of(context).animateTo(0);
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.restaurant),
                  title: Text('记录生活习惯'),
                  onTap: () {
                    Navigator.pop(context);
                    _tabController.animateTo(1);
                    Future.delayed(Duration(milliseconds: 100), () {
                      DefaultTabController.of(context).animateTo(1);
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('记录健康指标'),
                  onTap: () {
                    Navigator.pop(context);
                    _tabController.animateTo(1);
                    Future.delayed(Duration(milliseconds: 100), () {
                      DefaultTabController.of(context).animateTo(2);
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.book),
                  title: Text('写健康日记'),
                  onTap: () {
                    Navigator.pop(context);
                    _tabController.animateTo(1);
                    Future.delayed(Duration(milliseconds: 100), () {
                      DefaultTabController.of(context).animateTo(3);
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
            ],
          ),
    );
  }
}
