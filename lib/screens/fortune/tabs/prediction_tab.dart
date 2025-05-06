import 'package:flutter/material.dart';
import '../../../controllers/fortune_controller.dart';
import '../../../models/fortune/fortune_models.dart';
import '../widgets/upgrade_card.dart';

class PredictionTab extends StatefulWidget {
  const PredictionTab({super.key});

  @override
  _PredictionTabState createState() => _PredictionTabState();
}

class _PredictionTabState extends State<PredictionTab>
    with SingleTickerProviderStateMixin {
  final FortuneController _controller = FortuneController();
  late TabController _predictionTabController;
  bool _isLoading = true;
  FortuneData? _fortuneData;

  // 用于控制是否显示月度和年度的详情内容
  bool _showMonthlyDetail = false;
  bool _showYearlyDetail = false;

  @override
  void initState() {
    super.initState();
    _predictionTabController = TabController(
      length: 3,
      vsync: this,
    ); // 3个标签：日、月、年
    _loadData();
  }

  @override
  void dispose() {
    _predictionTabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _fortuneData = await _controller.loadFortuneData();
    } catch (e) {
      print('加载运势预测数据错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_fortuneData == null) {
      return Center(child: Text('无法加载运势预测数据'));
    }

    return Column(
      children: [
        TabBar(
          controller: _predictionTabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [Tab(text: '日运势'), Tab(text: '月运势'), Tab(text: '年运势')],
        ),
        Expanded(
          child: TabBarView(
            controller: _predictionTabController,
            children: [
              _buildDailyFortuneView(_fortuneData!.dailyFortune),
              _buildMonthlyFortuneView(_fortuneData!.monthlyFortune),
              _buildYearlyFortuneView(_fortuneData!.yearlyFortune),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyFortuneView(DailyFortune dailyFortune) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildDailyFortune(dailyFortune)],
      ),
    );
  }

  Widget _buildMonthlyFortuneView(MonthlyFortune monthlyFortune) {
    // 判断是否显示月运势详情
    if (monthlyFortune.isPremiumContent &&
        !_fortuneData!.isPremiumUser &&
        !_showMonthlyDetail) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: FortuneUpgradeCard(
            title: '解锁月运势分析',
            description: '升级至专业版，获取完整月运势分析、吉凶日提醒和个性化发展建议',
            onPurchase: () {
              // 直接显示详情内容，而不是弹出购买对话框
              setState(() {
                _showMonthlyDetail = true;
              });
              // 提示用户成功查看
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('您现在可以查看完整月运势分析了')));
            },
          ),
        ),
      );
    }

    // 显示月运势详情
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildMonthlyFortune(monthlyFortune)],
      ),
    );
  }

  Widget _buildYearlyFortuneView(YearlyFortune yearlyFortune) {
    // 判断是否显示年运势详情
    if (yearlyFortune.isPremiumContent &&
        !_fortuneData!.isPremiumUser &&
        !_showYearlyDetail) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: FortuneUpgradeCard(
            title: '解锁年运势分析',
            description: '升级至专业版，获取完整年度运势分析、重要日期提醒和长期发展规划建议',
            onPurchase: () {
              // 直接显示详情内容，而不是弹出购买对话框
              setState(() {
                _showYearlyDetail = true;
              });
              // 提示用户成功查看
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('您现在可以查看完整年度运势分析了')));
            },
          ),
        ),
      );
    }

    // 显示年运势详情
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildYearlyFortune(yearlyFortune)],
      ),
    );
  }

  Widget _buildDailyFortune(DailyFortune dailyFortune) {
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
                  '今日运势',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  dailyFortune.date,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    dailyFortune.overview,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getRatingColor(
                            dailyFortune.rating,
                          ).withOpacity(0.1),
                          border: Border.all(
                            color: _getRatingColor(dailyFortune.rating),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            dailyFortune.rating.toString(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _getRatingColor(dailyFortune.rating),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '整体运势',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              '各方面运势',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: dailyFortune.aspects.length,
              itemBuilder: (context, index) {
                String aspect = dailyFortune.aspects.keys.elementAt(index);
                int rating = dailyFortune.aspects[aspect] ?? 0;
                return _buildAspectItem(aspect, rating);
              },
            ),
            SizedBox(height: 24),
            Text(
              '今日建议',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...dailyFortune.advice.map(
              (advice) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text('• '), Expanded(child: Text(advice))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyFortune(MonthlyFortune monthlyFortune) {
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
                  '本月运势',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  monthlyFortune.month,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(monthlyFortune.overview, style: TextStyle(fontSize: 16)),
            SizedBox(height: 24),
            if (monthlyFortune.luckyDates.isNotEmpty) ...[
              Text(
                '本月吉日',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              ...monthlyFortune.luckyDates.map(
                (date) => _buildKeyDateItem(date),
              ),
              SizedBox(height: 20),
            ],
            if (monthlyFortune.unluckyDates.isNotEmpty) ...[
              Text(
                '本月忌日',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 12),
              ...monthlyFortune.unluckyDates.map(
                (date) => _buildKeyDateItem(date),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyFortune(YearlyFortune yearlyFortune) {
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
                  '年度运势',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  yearlyFortune.year,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(yearlyFortune.overview, style: TextStyle(fontSize: 16)),
            SizedBox(height: 24),
            Text(
              '年度各领域运势',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: yearlyFortune.aspects.length,
              itemBuilder: (context, index) {
                String aspect = yearlyFortune.aspects.keys.elementAt(index);
                int rating = yearlyFortune.aspects[aspect] ?? 0;
                return _buildAspectItem(aspect, rating);
              },
            ),
            SizedBox(height: 24),
            Text(
              '发展建议',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...yearlyFortune.developmentAdvice.map(
              (advice) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text('• '), Expanded(child: Text(advice))],
                ),
              ),
            ),
            SizedBox(height: 24),
            if (yearlyFortune.keyDates.isNotEmpty) ...[
              Text(
                '年度重要日期',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              ...yearlyFortune.keyDates.map((date) => _buildKeyDateItem(date)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAspectItem(String aspect, int rating) {
    IconData iconData;
    switch (aspect) {
      case '事业':
        iconData = Icons.work;
        break;
      case '财运':
        iconData = Icons.attach_money;
        break;
      case '感情':
        iconData = Icons.favorite;
        break;
      case '健康':
        iconData = Icons.favorite_border;
        break;
      case '学习':
        iconData = Icons.school;
        break;
      case '出行':
        iconData = Icons.flight;
        break;
      default:
        iconData = Icons.star;
    }

    return Container(
      decoration: BoxDecoration(
        color: _getRatingColor(rating).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(iconData, color: _getRatingColor(rating), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  aspect,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.grey[300],
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: rating / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: _getRatingColor(rating),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '$rating',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getRatingColor(rating),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyDateItem(KeyDate date) {
    bool isLuckyDate =
        !(date.reason.contains('凶') ||
            date.reason.contains('忌') ||
            date.reason.contains('避免'));
    Color dateColor = isLuckyDate ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dateColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dateColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(date.date, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Text(
                date.reason,
                style: TextStyle(color: dateColor, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          if (date.activities.isNotEmpty) ...[
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  date.activities
                      .map(
                        (activity) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: dateColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            activity,
                            style: TextStyle(fontSize: 12, color: dateColor),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 85) return Colors.green;
    if (rating >= 70) return Colors.lightGreen;
    if (rating >= 60) return Colors.amber;
    return Colors.redAccent;
  }
}
