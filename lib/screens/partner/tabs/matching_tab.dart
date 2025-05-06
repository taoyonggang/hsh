import 'package:flutter/material.dart';
import '../../../models/partner/matching_profile.dart';
import '../../../controllers/matching_controller.dart';
import '../../../screens/partner/partner_detail_screen.dart';

class MatchingTab extends StatefulWidget {
  const MatchingTab({super.key});

  @override
  _MatchingTabState createState() => _MatchingTabState();
}

class _MatchingTabState extends State<MatchingTab> {
  final MatchingController _matchingController = MatchingController();
  List<dynamic>? _matchProfiles;
  bool _isLoading = true;

  final Map<String, dynamic> _filters = {
    'distance': 50.0,
    'ageRange': RangeValues(18, 60),
    'gender': 'all',
    'interests': <String>[],
  };

  @override
  void initState() {
    super.initState();
    _loadMatchData();
  }

  Future<void> _loadMatchData() async {
    setState(() => _isLoading = true);
    try {
      final profiles = await _matchingController.getMatchingProfiles(_filters);
      _matchProfiles = profiles.map((p) => p.toJson()).toList();
    } catch (e) {
      print('Error loading match data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
          onRefresh: _loadMatchData,
          child: Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child:
                    _matchProfiles == null || _matchProfiles!.isEmpty
                        ? Center(child: Text('没有找到匹配的搭子'))
                        : GridView.builder(
                          padding: EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: _matchProfiles!.length,
                          itemBuilder: (context, index) {
                            final profile = _matchProfiles![index];
                            return _buildMatchCard(profile);
                          },
                        ),
              ),
            ],
          ),
        );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 20, color: Colors.grey[700]),
          SizedBox(width: 8),
          Text('筛选:', style: TextStyle(color: Colors.grey[700])),
          SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('距离', '${_filters['distance'].round()} km'),
                  _buildFilterChip(
                    '年龄',
                    '${_filters['ageRange'].start.round()}-${_filters['ageRange'].end.round()}岁',
                  ),
                  _buildFilterChip(
                    '兴趣',
                    _filters['interests'].isEmpty
                        ? '全部'
                        : '已选${_filters['interests'].length}项',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          _showFilterDialog(label);
        },
        child: Chip(
          label: Text('$label: $value'),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  void _showFilterDialog(String filterType) {
    switch (filterType) {
      case '距离':
        _showDistanceFilterDialog();
        break;
      case '年龄':
        _showAgeFilterDialog();
        break;
      case '兴趣':
        _showInterestsFilterDialog();
        break;
    }
  }

  void _showDistanceFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double distance = _filters['distance'];
        return AlertDialog(
          title: Text('设置距离'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('最大距离: ${distance.round()} km'),
                  Slider(
                    value: distance,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: '${distance.round()} km',
                    onChanged: (value) {
                      setState(() => distance = value);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filters['distance'] = distance;
                });
                _loadMatchData();
                Navigator.pop(context);
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _showAgeFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        RangeValues ageRange = _filters['ageRange'];
        return AlertDialog(
          title: Text('设置年龄范围'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${ageRange.start.round()} - ${ageRange.end.round()}岁'),
                  RangeSlider(
                    values: ageRange,
                    min: 18,
                    max: 80,
                    divisions: 62,
                    labels: RangeLabels(
                      '${ageRange.start.round()}岁',
                      '${ageRange.end.round()}岁',
                    ),
                    onChanged: (values) {
                      setState(() => ageRange = values);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filters['ageRange'] = ageRange;
                });
                _loadMatchData();
                Navigator.pop(context);
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _showInterestsFilterDialog() {
    final allInterests = [
      '运动',
      '旅行',
      '美食',
      '影视',
      '音乐',
      '阅读',
      '摄影',
      '绘画',
      '手工',
      '舞蹈',
      '登山',
      '徒步',
      '露营',
      '瑜伽',
      '烘焙',
      '投资',
      '科技',
      '时尚',
    ];

    showDialog(
      context: context,
      builder: (context) {
        List<String> selectedInterests = List<String>.from(
          _filters['interests'],
        );
        return AlertDialog(
          title: Text('选择兴趣'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: double.maxFinite,
                height: 300, // 设置一个固定高度避免溢出
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        allInterests.map((interest) {
                          final isSelected = selectedInterests.contains(
                            interest,
                          );
                          return FilterChip(
                            selected: isSelected,
                            label: Text(interest),
                            selectedColor: Colors.green[100],
                            checkmarkColor: Colors.green,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedInterests.add(interest);
                                } else {
                                  selectedInterests.remove(interest);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filters['interests'] = selectedInterests;
                });
                _loadMatchData();
                Navigator.pop(context);
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> profile) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PartnerDetailScreen(partnerData: profile),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 照片
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child:
                    profile['image'] != null
                        ? Image.network(profile['image'], fit: BoxFit.cover)
                        : Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),

            // 信息
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile['user'] ?? '用户'}, ${profile['age'] ?? '?'}岁',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    '距离 ${profile['distance'] ?? '?'} km',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 14, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        '匹配度 ${(profile['matchScore'] ?? 0.7 * 100).toInt()}%',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
