import 'package:flutter/material.dart';
import '../../controllers/fortune_controller.dart';
import 'tabs/bazi_tab.dart';
import 'tabs/qimen_tab.dart';
import 'tabs/prediction_tab.dart';

class FortuneScreen extends StatefulWidget {
  const FortuneScreen({super.key});

  @override
  _FortuneScreenState createState() => _FortuneScreenState();
}

class _FortuneScreenState extends State<FortuneScreen>
    with SingleTickerProviderStateMixin {
  final FortuneController _controller = FortuneController();
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      print('加载运势数据错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('运势分析'),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _loadData)],
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: '八字分析'), Tab(text: '奇门遁甲'), Tab(text: '运势预测')],
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [BaziTab(), QimenTab(), PredictionTab()],
              ),
    );
  }
}
