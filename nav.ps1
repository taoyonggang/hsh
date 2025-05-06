# 创建必要的页面文件

# 1. 创建健康页面
$healthScreenContent = @'
import 'package:flutter/material.dart';
import '../api/mock_api_service.dart';

class HealthScreen extends StatefulWidget {
  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final MockApiService _apiService = MockApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _healthOverview;
  List<dynamic>? _healthRecords;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _healthOverview = await _apiService.getHealthOverview();
      _healthRecords = await _apiService.getHealthRecords();
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
        title: Text('Health Center'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHealthScore(),
                  _buildHealthMetrics(),
                  _buildHealthRecords(),
                ],
              ),
            ),
    );
  }

  Widget _buildHealthScore() {
    if (_healthOverview == null || !_healthOverview!.containsKey('healthScore')) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_healthOverview!['healthScore']}',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    'Health Score',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics() {
    if (_healthOverview == null) {
      return Center(child: Text('No health data available'));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Today\'s Health Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildMetricCard('Steps', '${_healthOverview!['steps'] ?? 0}', Icons.directions_walk),
              _buildMetricCard('Calories', '${_healthOverview!['calories'] ?? 0} cal', Icons.local_fire_department),
              _buildMetricCard('Heart Rate', '${_healthOverview!['heartRate'] ?? "0 bpm"}', Icons.favorite),
              _buildMetricCard('Sleep', '${_healthOverview!['sleep'] ?? "0 hours"}', Icons.bedtime),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRecords() {
    if (_healthRecords == null || _healthRecords!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text('No health records available')),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Records',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _healthRecords!.length,
            itemBuilder: (context, index) {
              final record = _healthRecords![index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            record['date'] ?? 'Unknown date',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ID: ${record['id']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      if (record.containsKey('metrics') && record['metrics'] is Map) ...[
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _buildMetricItem('Steps', '${record['metrics']['steps'] ?? 0}'),
                            _buildMetricItem('Calories', '${record['metrics']['calories'] ?? 0}'),
                            _buildMetricItem('Weight', '${record['metrics']['weight'] ?? 0} kg'),
                            _buildMetricItem('Heart Rate', '${record['metrics']['heartRate'] ?? 0} bpm'),
                          ],
                        ),
                      ],
                      if (record.containsKey('notes') && record['notes'] != null) ...[
                        SizedBox(height: 12),
                        Text(
                          'Notes:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          record['notes'],
                          style: TextStyle(
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
'@

# 2. 创建运势页面
$fortuneScreenContent = @'
import 'package:flutter/material.dart';
import '../api/mock_api_service.dart';

class FortuneScreen extends StatefulWidget {
  @override
  _FortuneScreenState createState() => _FortuneScreenState();
}

class _FortuneScreenState extends State<FortuneScreen> with SingleTickerProviderStateMixin {
  final MockApiService _apiService = MockApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _dailyFortune;
  Map<String, dynamic>? _baziFortune;
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      _dailyFortune = await _apiService.getFortuneDaily();
      _baziFortune = await _apiService.getFortuneBazi();
    } catch (e) {
      print('Error loading fortune data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fortune Analysis'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Daily Fortune'),
            Tab(text: 'BaZi Analysis'),
          ],
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildDailyFortune(),
              _buildBaziAnalysis(),
            ],
          ),
    );
  }
  
  Widget _buildDailyFortune() {
    if (_dailyFortune == null || _dailyFortune!.isEmpty) {
      return Center(child: Text('No daily fortune data available'));
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(),
            SizedBox(height: 24),
            _buildOverallScore(),
            SizedBox(height: 24),
            _buildFortuneAspects(),
            SizedBox(height: 24),
            _buildLuckyInfo(),
            SizedBox(height: 24),
            _buildSuitableActivities(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDateHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Today\'s Fortune',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _dailyFortune!['date'] ?? 'Unknown date',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildOverallScore() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 5,
                ),
              ],
              gradient: RadialGradient(
                colors: [Colors.amber[300]!, Colors.amber[600]!],
              ),
            ),
            child: Center(
              child: Text(
                '${_dailyFortune!['overallScore'] ?? 0}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Overall Fortune Score',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _dailyFortune!['summary'] ?? 'No summary available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFortuneAspects() {
    if (!_dailyFortune!.containsKey('aspects') || _dailyFortune!['aspects'] == null) {
      return SizedBox.shrink();
    }
    
    Map<String, dynamic> aspects = _dailyFortune!['aspects'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Life Aspects',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        if (aspects.containsKey('career'))
          _buildAspectCard('Career', aspects['career']),
        SizedBox(height: 12),
        if (aspects.containsKey('wealth'))
          _buildAspectCard('Wealth', aspects['wealth']),
      ],
    );
  }
  
  Widget _buildAspectCard(String title, Map<String, dynamic> aspect) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Score: ${aspect['score'] ?? 0}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              aspect['summary'] ?? 'No summary available',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            if (aspect.containsKey('tips') && aspect['tips'] is List) ...[
              SizedBox(height: 8),
              Text(
                'Tips:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              ...List<Widget>.from(
                (aspect['tips'] as List).map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_right, size: 16, color: Colors.amber),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(tip),
                      ),
                    ],
                  ),
                )),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildLuckyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lucky Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Lucky Directions', 
                'Best: ${_dailyFortune!['luckyDirections']?['best'] ?? 'N/A'}\nWorst: ${_dailyFortune!['luckyDirections']?['worst'] ?? 'N/A'}',
                Icons.explore,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                'Lucky Times',
                'Best: ${_dailyFortune!['luckyTimes']?['best'] ?? 'N/A'}\nWorst: ${_dailyFortune!['luckyTimes']?['worst'] ?? 'N/A'}',
                Icons.access_time,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              content,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuitableActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activities for Today',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildActivitiesList(
                'Suitable',
                _dailyFortune!['suitable'] ?? [],
                Colors.green,
                Icons.check_circle_outline,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildActivitiesList(
                'Unsuitable',
                _dailyFortune!['unsuitable'] ?? [],
                Colors.red,
                Icons.cancel_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActivitiesList(String title, List activities, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            SizedBox(height: 12),
            ...List<Widget>.from(
              activities.map((activity) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 16, color: color),
                    SizedBox(width: 8),
                    Expanded(child: Text(activity)),
                  ],
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBaziAnalysis() {
    if (_baziFortune == null || _baziFortune!.isEmpty) {
      return Center(child: Text('No BaZi analysis data available'));
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBaziChart(),
            SizedBox(height: 24),
            _buildFiveElements(),
            SizedBox(height: 24),
            _buildCharacterAnalysis(),
            SizedBox(height: 24),
            _buildLifeAspects(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBaziChart() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Your BaZi Chart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPillar('Year', _baziFortune!['yearPillar']),
                _buildPillar('Month', _baziFortune!['monthPillar']),
                _buildPillar('Day', _baziFortune!['dayPillar']),
                _buildPillar('Hour', _baziFortune!['hourPillar']),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Day Master: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _baziFortune!['dayMaster'] ?? 'Unknown',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPillar(String label, Map<String, dynamic>? pillar) {
    if (pillar == null) {
      return Column(
        children: [
          Text(label),
          SizedBox(height: 8),
          Container(
            width: 60,
            height: 80,
            color: Colors.grey[300],
            child: Center(child: Text('N/A')),
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(label),
        SizedBox(height: 8),
        Container(
          width: 60,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            border: Border.all(color: Colors.amber),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                pillar['heavenlyStem'] ?? '',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(thickness: 1, height: 16),
              Text(
                pillar['earthlyBranch'] ?? '',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildFiveElements() {
    if (!_baziFortune!.containsKey('fiveElements') || _baziFortune!['fiveElements'] == null) {
      return SizedBox.shrink();
    }
    
    Map<String, dynamic> elements = _baziFortune!['fiveElements'];
    Map<String, Color> elementColors = {
      'wood': Colors.green,
      'fire': Colors.red,
      'earth': Colors.brown,
      'metal': Colors.grey,
      'water': Colors.blue,
    };
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Five Elements Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            ...elements.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: elementColors[entry.key.toLowerCase()] ?? Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: entry.value / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      elementColors[entry.key.toLowerCase()] ?? Colors.blue,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${entry.value}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            )).toList(),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildElementInfoCard(
                    'Dominant Element',
                    _baziFortune!['dominantElement'] ?? 'N/A',
                    Colors.green,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildElementInfoCard(
                    'Weak Element',
                    _baziFortune!['weakElement'] ?? 'N/A',
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildElementInfoCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCharacterAnalysis() {
    if (!_baziFortune!.containsKey('character')) {
      return SizedBox.shrink();
    }
    
    Map<String, dynamic> character = _baziFortune!['character'];
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Character Analysis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (character.containsKey('traits') && character['traits'] != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Text(
                  character['traits'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            if (character.containsKey('strengths') && character['strengths'] is List) ...[
              SizedBox(height: 16),
              _buildCharacterList('Strengths', character['strengths'], Colors.green),
            ],
            if (character.containsKey('challenges') && character['challenges'] is List) ...[
              SizedBox(height: 12),
              _buildCharacterList('Challenges', character['challenges'], Colors.orange),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildCharacterList(String title, List items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              title == 'Strengths' ? Icons.thumb_up : Icons.warning_amber_rounded,
              size: 18,
              color: color,
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• '),
              Expanded(child: Text(item)),
            ],
          ),
        )).toList(),
      ],
    );
  }
  
  Widget _buildLifeAspects() {
    if (!_baziFortune!.containsKey('lifeAspects')) {
      return SizedBox.shrink();
    }
    
    Map<String, dynamic> aspects = _baziFortune!['lifeAspects'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Life Aspects',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        if (aspects.containsKey('career'))
          _buildLifeAspectCard('Career', aspects['career']),
        SizedBox(height: 16),
        if (aspects.containsKey('relationships'))
          _buildLifeAspectCard('Relationships', aspects['relationships']),
        SizedBox(height: 16),
        if (aspects.containsKey('health'))
          _buildLifeAspectCard('Health', aspects['health']),
      ],
    );
  }
  
  Widget _buildLifeAspectCard(String title, Map<String, dynamic> aspect) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  title == 'Career' ? Icons.work :
                  title == 'Relationships' ? Icons.favorite :
                  Icons.health_and_safety,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (aspect.containsKey('suitable') && aspect['suitable'] is List) ...[
              Text(
                'Suitable:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List<Widget>.from(
                  aspect['suitable'].map((item) => Chip(
                    label: Text(item),
                    backgroundColor: Colors.green.withOpacity(0.1),
                  )),
                ),
              ),
            ],
            if (aspect.containsKey('challenging') && aspect['challenging'] is List) ...[
              SizedBox(height: 12),
              Text(
                'Challenging:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List<Widget>.from(
                  aspect['challenging'].map((item) => Chip(
                    label: Text(item),
                    backgroundColor: Colors.red.withOpacity(0.1),
                  )),
                ),
              ),
            ],
            if (aspect.containsKey('suggestions') && aspect['suggestions'] != null) ...[
              SizedBox(height: 16),
              Text(
                'Suggestions:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Text(aspect['suggestions']),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
'@

# 3. 创建社交页面
$socialScreenContent = @'
import 'package:flutter/material.dart';
import '../api/mock_api_service.dart';

class SocialScreen extends StatefulWidget {
  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> with SingleTickerProviderStateMixin {
  final MockApiService _apiService = MockApiService();
  bool _isLoading = true;
  List<dynamic>? _socialFeeds;
  List<dynamic>? _socialGroups;
  List<dynamic>? _socialActivities;
  
  late TabController _tabController;
  
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
      _socialFeeds = await _apiService.getSocialFeeds();
      _socialGroups = await _apiService.getSocialGroups();
      _socialActivities = await _apiService.getSocialActivities();
    } catch (e) {
      print('Error loading social data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Social Network'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Feed'),
            Tab(text: 'Groups'),
            Tab(text: 'Activities'),
          ],
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildFeedsTab(),
              _buildGroupsTab(),
              _buildActivitiesTab(),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Create post, group or activity depending on current tab
          int currentTab = _tabController.index;
          String action = currentTab == 0 ? "post" : currentTab == 1 ? "group" : "activity";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Create new $action')),
          );
        },
      ),
    );
  }
  
  Widget _buildFeedsTab() {
    if (_socialFeeds == null || _socialFeeds!.isEmpty) {
      return Center(child: Text('No social feeds available'));
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _socialFeeds!.length,
      itemBuilder: (context, index) {
        final feed = _socialFeeds![index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(feed['avatar']),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feed['user'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          feed['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(feed['content']),
              ),
              if (feed['image'] != null) ...[
                SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(feed['image']),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(Icons.thumb_up_outlined, '${feed['likes']}', 'Like'),
                    _buildActionButton(Icons.comment_outlined, '${feed['comments']}', 'Comment'),
                    _buildActionButton(Icons.share_outlined, 'Share', 'Share'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildActionButton(IconData icon, String text, String action) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$action clicked')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[700]),
            SizedBox(width: 4),
            Text(text, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGroupsTab() {
    if (_socialGroups == null || _socialGroups!.isEmpty) {
      return Center(child: Text('No groups available'));
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _socialGroups!.length,
      itemBuilder: (context, index) {
        final group = _socialGroups![index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  group['coverUrl'],
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      group['description'],
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildGroupStat(Icons.people, '${group['memberCount']}', 'Members'),
                        SizedBox(width: 24),
                        _buildGroupStat(Icons.event, '${group['activityCount']}', 'Activities'),
                        Spacer(),
                        Text(
                          'Last active: ${group['lastActive']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          icon: Icon(Icons.info_outline),
                          label: Text('More Info'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('View ${group['name']} details')),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.people),
                          label: Text('Join Group'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Join ${group['name']}')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildGroupStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColor),
        SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildActivitiesTab() {
    if (_socialActivities == null || _socialActivities!.isEmpty) {
      return Center(child: Text('No activities available'));
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _socialActivities!.length,
      itemBuilder: (context, index) {
        final activity = _socialActivities![index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      activity['coverUrl'],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _formatActivityDate(activity['startTime']),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[700]),
                        SizedBox(width: 4),
                        Text(
                          activity['location'],
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
                        SizedBox(width: 4),
                        Text(
                          _formatActivityTime(activity['startTime']),
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      activity['description'],
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildAttendeeStatus(
                          activity['participantCount'],
                          activity['maxParticipants'],
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Joining ${activity['title']}')),
                            );
                          },
                          child: Text('Join Activity'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  String _formatActivityDate(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    } catch (e) {
      return 'TBD';
    }
  }
  
  String _formatActivityTime(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      String period = dateTime.hour >= 12 ? 'PM' : 'AM';
      int hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      hour = hour == 0 ? 12 : hour;
      String minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    } catch (e) {
      return 'TBD';
    }
  }
  
  Widget _buildAttendeeStatus(int current, int max) {
    double percentage = current / max;
    Color statusColor = percentage > 0.8 ? Colors.red : 
                        percentage > 0.5 ? Colors.orange : Colors.green;
                        
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              strokeWidth: 6,
            ),
            Text(
              '$current/$max',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(width: 12),
        Text(
          percentage >= 1.0 ? 'Full' :
          percentage > 0.8 ? 'Almost Full' :
          percentage > 0.5 ? 'Filling Up' :
          'Open',
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
'@

# 4. 创建个人资料页面
$profileScreenContent = @'
import 'package:flutter/material.dart';
import '../api/mock_api_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MockApiService _apiService = MockApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _virtualNetwork;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _userProfile = await _apiService.getUserProfile();
      _virtualNetwork = await _apiService.getVirtualNetwork();
    } catch (e) {
      print('Error loading profile data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settings')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  SizedBox(height: 24),
                  _buildMembershipSection(),
                  SizedBox(height: 24),
                  _buildPersonalInfoSection(),
                  SizedBox(height: 24),
                  _buildNetworkSection(),
                  SizedBox(height: 24),
                  _buildActionButtons(),
                  SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
  
  Widget _buildProfileHeader() {
    if (_userProfile == null) {
      return SizedBox.shrink();
    }

    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(_userProfile!['avatar']),
              ),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.grey[700],
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            _userProfile!['username'] ?? 'User',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ID: ${_userProfile!['userId']}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProfileStat('Posts', '58'),
              _buildDivider(),
              _buildProfileStat('Followers', '843'),
              _buildDivider(),
              _buildProfileStat('Following', '162'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[300],
    );
  }
  
  Widget _buildMembershipSection() {
    if (_userProfile == null || !_userProfile!.containsKey('membershipInfo')) {
      return SizedBox.shrink();
    }
    
    Map<String, dynamic> membershipInfo = _userProfile!['membershipInfo'];
    Map<String, dynamic> quotaInfo = _userProfile!['quotaInfo'];
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Membership',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMembershipBadge(
                        'Social',
                        membershipInfo['socialMember'] == true,
                        membershipInfo['expirationDates']?['socialMember'],
                      ),
                      _buildMembershipBadge(
                        'Health',
                        membershipInfo['healthMember'] == true,
                        membershipInfo['expirationDates']?['healthMember'],
                      ),
                      _buildMembershipBadge(
                        'Partner',
                        membershipInfo['partnerMember'] == true,
                        membershipInfo['expirationDates']?['partnerMember'],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Daily Quota',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildQuotaMeter('Health Advice', quotaInfo['healthAdvice']),
                  SizedBox(height: 8),
                  _buildQuotaMeter('Fortune Analysis', quotaInfo['fortuneAnalysis']),
                  SizedBox(height: 8),
                  _buildQuotaMeter('Social Analysis', quotaInfo['socialAnalysis']),
                  SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Upgrade membership')),
                      );
                    },
                    child: Text('Upgrade Membership'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMembershipBadge(String type, bool isActive, String? expirationDate) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey[200],
            border: Border.all(
              color: isActive ? Colors.green : Colors.grey[400]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == 'Social' ? Icons.people :
                  type == 'Health' ? Icons.favorite :
                  Icons.handshake,
                  color: isActive ? Colors.green : Colors.grey,
                  size: 32,
                ),
                SizedBox(height: 4),
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          type,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        if (expirationDate != null) ...[
          SizedBox(height: 4),
          Text(
            'Expires: $expirationDate',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildQuotaMeter(String label, Map<String, dynamic>? quota) {
    if (quota == null) {
      return SizedBox.shrink();
    }
    
    int daily = quota['daily'] ?? 0;
    int used = quota['used'] ?? 0;
    double percentage = daily > 0 ? used / daily : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$used / $daily'),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage > 0.9 ? Colors.red : 
            percentage > 0.7 ? Colors.orange : 
            Colors.green,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPersonalInfoSection() {
    if (_userProfile == null || !_userProfile!.containsKey('personalInfo')) {
      return SizedBox.shrink();
    }
    
    Map<String, dynamic> personalInfo = _userProfile!['personalInfo'];
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow('Gender', personalInfo['gender'] == 'male' ? 'Male' : 'Female'),
                  _buildInfoRow('Birth Date', personalInfo['birthDate']),
                  _buildInfoRow('Birth Time', personalInfo['birthTime']),
                  _buildInfoRow('Birth Location', personalInfo['birthLocation']),
                  _buildInfoRow('Height', '${personalInfo['height']} cm'),
                  _buildInfoRow('Weight', '${personalInfo['weight']} kg'),
                  SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Edit personal information')),
                      );
                    },
                    child: Text('Edit Information'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
          Text(
            value ?? 'Not specified',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNetworkSection() {
    if (_virtualNetwork == null || !_virtualNetwork!.containsKey('nodes') || _virtualNetwork!['nodes'].isEmpty) {
      return SizedBox.shrink();
    }
    
    List<dynamic> nodes = _virtualNetwork!['nodes'];
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Social Network',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_virtualNetwork!.containsKey('analysis')) ...[
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Network Analysis',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Nodes: ${_virtualNetwork!['analysis']['nodeCount']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          if (_virtualNetwork!['analysis']['insights'] is List) ...[
                            ...List<Widget>.from(
                              (_virtualNetwork!['analysis']['insights'] as List).map((insight) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                                    SizedBox(width: 4),
                                    Expanded(child: Text(insight)),
                                  ],
                                ),
                              )),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  Text(
                    'Your Connections',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: nodes.length,
                      itemBuilder: (context, index) {
                        final node = nodes[index];
                        return Container(
                          width: 80,
                          margin: EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(node['avatar']),
                              ),
                              SizedBox(height: 8),
                              Text(
                                node['name'],
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                node['relationship'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('View full network')),
                      );
                    },
                    child: Text('View Full Network'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('View your health records')),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite),
                SizedBox(width: 8),
                Text('My Health Records'),
              ],
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48),
              primary: Colors.green,
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('View your fortune analysis')),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_graph),
                SizedBox(width: 8),
                Text('My Fortune Analysis'),
              ],
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48),
              primary: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }
}