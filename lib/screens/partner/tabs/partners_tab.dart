import 'package:flutter/material.dart';
import '../../../models/partner/partner_group.dart';
import '../../../controllers/partner_controller.dart';
import '../widgets/partner_card.dart';

class PartnersTab extends StatefulWidget {
  const PartnersTab({super.key});

  @override
  _PartnersTabState createState() => _PartnersTabState();
}

class _PartnersTabState extends State<PartnersTab> {
  final PartnerController _controller = PartnerController();
  bool _isLoading = true;
  List<PartnerGroup> _myPartners = [];
  List<PartnerGroup> _recommendedPartners = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _myPartners = await _controller.getMyPartnerGroups();
      _recommendedPartners = await _controller.getRecommendedPartnerGroups();
    } catch (e) {
      print('加载搭子数据错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMyPartnersSection(),
            SizedBox(height: 24),
            _buildRecommendedPartnersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPartnersSection() {
    if (_myPartners.isEmpty) {
      return _buildEmptyPartnerSection();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '我的搭子',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/partner/all'),
              child: Text('查看全部'),
            ),
          ],
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _myPartners.length > 3 ? 3 : _myPartners.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: PartnerCard(
                partner: _myPartners[index],
                onTap:
                    () => Navigator.pushNamed(
                      context,
                      '/partner/detail',
                      arguments: _myPartners[index],
                    ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendedPartnersSection() {
    if (_recommendedPartners.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '推荐搭子',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _recommendedPartners.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: PartnerCard(
                partner: _recommendedPartners[index],
                isRecommended: true,
                onTap:
                    () => Navigator.pushNamed(
                      context,
                      '/partner/detail',
                      arguments: _recommendedPartners[index],
                    ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyPartnerSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/empty_partners.png', height: 150),
          SizedBox(height: 16),
          Text(
            '还没有加入任何搭子',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '创建或加入搭子，与志同道合的朋友一起活动',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('创建搭子'),
            onPressed: () => Navigator.pushNamed(context, '/partner/create'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
