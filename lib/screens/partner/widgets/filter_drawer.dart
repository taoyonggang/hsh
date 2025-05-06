import 'package:flutter/material.dart';

class FilterDrawer extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterDrawer({
    super.key,
    required this.initialFilters,
    required this.onApplyFilters,
  });

  @override
  _FilterDrawerState createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  late double _distance;
  late RangeValues _ageRange;
  late String _gender;
  late List<String> _selectedInterests;

  final List<String> _availableInterests = [
    '旅行',
    '美食',
    '读书',
    '户外',
    '运动',
    '游戏',
    '音乐',
    '电影',
    '摄影',
    '手工',
    '投资',
    '科技',
    '养生',
    '宠物',
    '亲子',
    '学习',
  ];

  @override
  void initState() {
    super.initState();
    _distance = widget.initialFilters['distance'] ?? 50.0;
    _ageRange = widget.initialFilters['ageRange'] ?? RangeValues(18, 60);
    _gender = widget.initialFilters['gender'] ?? 'all';
    _selectedInterests = List<String>.from(
      widget.initialFilters['interests'] ?? [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 24),
                    _buildDistanceFilter(),
                    SizedBox(height: 24),
                    _buildAgeFilter(),
                    SizedBox(height: 24),
                    _buildGenderFilter(),
                    SizedBox(height: 24),
                    _buildInterestsFilter(),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '筛选条件',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '距离范围',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Text('${_distance.toInt()} km'),
            Expanded(
              child: Slider(
                value: _distance,
                min: 1,
                max: 100,
                divisions: 99,
                label: '${_distance.toInt()} km',
                onChanged: (value) {
                  setState(() {
                    _distance = value;
                  });
                },
              ),
            ),
            Text('100 km'),
          ],
        ),
      ],
    );
  }

  Widget _buildAgeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '年龄范围',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Text('${_ageRange.start.toInt()}岁'),
            Expanded(
              child: RangeSlider(
                values: _ageRange,
                min: 18,
                max: 80,
                divisions: 62,
                labels: RangeLabels(
                  '${_ageRange.start.toInt()}岁',
                  '${_ageRange.end.toInt()}岁',
                ),
                onChanged: (values) {
                  setState(() {
                    _ageRange = values;
                  });
                },
              ),
            ),
            Text('${_ageRange.end.toInt()}岁'),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('性别', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildGenderOption('all', '全部')),
            SizedBox(width: 8),
            Expanded(child: _buildGenderOption('male', '男')),
            SizedBox(width: 8),
            Expanded(child: _buildGenderOption('female', '女')),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String value, String label) {
    final isSelected = _gender == value;

    return InkWell(
      onTap: () {
        setState(() {
          _gender = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '兴趣爱好',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedInterests = [];
                });
              },
              child: Text('清空'),
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _availableInterests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);

                return FilterChip(
                  label: Text(interest),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedInterests.add(interest);
                      } else {
                        _selectedInterests.remove(interest);
                      }
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                _distance = 50.0;
                _ageRange = RangeValues(18, 60);
                _gender = 'all';
                _selectedInterests = [];
              });
            },
            child: Text('重置'),
          ),
          SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                final filters = {
                  'distance': _distance,
                  'ageRange': _ageRange,
                  'gender': _gender,
                  'interests': _selectedInterests,
                };
                widget.onApplyFilters(filters);
                Navigator.pop(context);
              },
              child: Text('应用'),
            ),
          ),
        ],
      ),
    );
  }
}
