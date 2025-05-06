# Much simpler script that fixes the issues directly

# 1. Fix main.dart
$mainDartPath = "lib\main.dart"
$mainDartContent = Get-Content -Path $mainDartPath -Raw

# Add imports we might need
if (-not $mainDartContent.Contains("import 'dart:io';")) {
    $mainDartContent = $mainDartContent.Replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';"
    )
}

# Fix the main class by replacing the entire file content
$newMainDartContent = @'
import 'package:flutter/material.dart';
import 'api/mock_api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health & Social Platform',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MockApiService _apiService = MockApiService();
  int _currentIndex = 0;
  
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _healthOverview;
  List<dynamic>? _socialFeeds;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _userProfile = await _apiService.getUserProfile();
      _healthOverview = await _apiService.getHealthOverview();
      _socialFeeds = await _apiService.getSocialFeeds();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health & Social Platform'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.message_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading == true
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserHeader(),
                _buildHealthOverview(),
                _buildSectionTitle('Social Updates', 'View All'),
                _buildSocialFeeds(),
              ],
            ),
          ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Health'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: 'Fortune'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Social'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
  
  Widget _buildUserHeader() {
    if (_userProfile == null) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Center(child: Text("Loading...")),
      );
    }
    
    return Container(
      padding: EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: _userProfile!['avatar'] != null 
                ? NetworkImage(_userProfile!['avatar']) 
                : null,
            child: _userProfile!['avatar'] == null ? Icon(Icons.person) : null,
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${_userProfile!['username'] ?? "User"}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(_getMembershipText(), style: TextStyle(color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildHealthOverview() {
    if (_healthOverview == null) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text("Loading health data...")),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Health Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          GridView.count(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildHealthCard('Steps', '${_healthOverview!['steps'] ?? "0"}', Icons.directions_walk),
              _buildHealthCard('Calories', '${_healthOverview!['calories'] ?? "0"}', Icons.local_fire_department),
              _buildHealthCard('Heart Rate', '${_healthOverview!['heartRate'] ?? "0 bpm"}', Icons.favorite),
              _buildHealthCard('Sleep', '${_healthOverview!['sleep'] ?? "0 hours"}', Icons.bedtime),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildHealthCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 8),
            Text(title),
            SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, String action) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            action,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSocialFeeds() {
    if (_socialFeeds == null || _socialFeeds!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text("No social feeds available")),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _socialFeeds!.length,
      itemBuilder: (context, index) {
        final feed = _socialFeeds![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info row
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: feed['avatar'] != null ? NetworkImage(feed['avatar']) : null,
                      child: feed['avatar'] == null ? Icon(Icons.person) : null,
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feed['user'] ?? "User",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          feed['time'] ?? "Just now",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Content
                Text(feed['content'] ?? ""),
                if (feed['image'] != null) ...[
                  SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(feed['image']),
                  ),
                ],
                SizedBox(height: 12),
                // Likes and comments
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 18, color: Colors.grey[700]),
                    SizedBox(width: 4),
                    Text('${feed['likes'] ?? 0}', style: TextStyle(color: Colors.grey[700])),
                    SizedBox(width: 16),
                    Icon(Icons.comment_outlined, size: 18, color: Colors.grey[700]),
                    SizedBox(width: 4),
                    Text('${feed['comments'] ?? 0}', style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  String _getMembershipText() {
    if (_userProfile == null || !_userProfile!.containsKey('membershipInfo')) {
      return 'Regular User';
    }
    
    var membershipInfo = _userProfile!['membershipInfo'];
    if (membershipInfo == null || !(membershipInfo is Map)) {
      return 'Regular User';
    }
    
    List<String> memberships = [];
    if (membershipInfo['socialMember'] == true) memberships.add('Social Member');
    if (membershipInfo['healthMember'] == true) memberships.add('Health Member');
    if (membershipInfo['partnerMember'] == true) memberships.add('Partner Member');
    return memberships.isEmpty ? 'Regular User' : memberships.join(' · ');
  }
}
'@

# Write updated main.dart
Set-Content -Path $mainDartPath -Value $newMainDartContent -Encoding UTF8

# 2. Fix API service
$apiServicePath = "lib\api\mock_api_service.dart"
$newApiServiceContent = @'
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class MockApiService {
  // Singleton implementation for API service
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal();
  
  // Base API path
  static const String baseApiUrl = 'https://api.huishengapp.com';
  
  // Safe JSON parsing method
  dynamic _safeJsonDecode(String jsonString) {
    try {
      return json.decode(jsonString);
    } catch (e) {
      print('Error parsing JSON: $e');
      // Return appropriate default value based on return type
      return {};
    }
  }
  
  // Mock get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      await Future.delayed(Duration(milliseconds: 300)); // Simulate network delay
      final String data = await rootBundle.loadString('assets/mock/user_profile.json');
      return _safeJsonDecode(data);
    } catch (e) {
      print('Error loading user profile: $e');
      return {};
    }
  }
  
  // Mock get health overview
  Future<Map<String, dynamic>> getHealthOverview() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      final String data = await rootBundle.loadString('assets/mock/health_overview.json');
      return _safeJsonDecode(data);
    } catch (e) {
      print('Error loading health overview: $e');
      return {};
    }
  }
  
  // Mock get health records
  Future<List<dynamic>> getHealthRecords() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      final String data = await rootBundle.loadString('assets/mock/health_records.json');
      final result = _safeJsonDecode(data);
      return result is List ? result : [];
    } catch (e) {
      print('Error loading health records: $e');
      return [];
    }
  }
  
  // Mock get health reports
  Future<List<dynamic>> getHealthReports() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      final String data = await rootBundle.loadString('assets/mock/health_reports.json');
      final result = _safeJsonDecode(data);
      return result is List ? result : [];
    } catch (e) {
      print('Error loading health reports: $e');
      return [];
    }
  }
  
  // Mock get daily fortune
  Future<Map<String, dynamic>> getFortuneDaily() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      final String data = await rootBundle.loadString('assets/mock/fortune_daily.json');
      return _safeJsonDecode(data);
    } catch (e) {
      print('Error loading fortune daily: $e');
      return {};
    }
  }
  
  // Mock get bazi fortune
  Future<Map<String, dynamic>> getFortuneBazi() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      final String data = await rootBundle.loadString('assets/mock/fortune_bazi.json');
      return _safeJsonDecode(data);
    } catch (e) {
      print('Error loading fortune bazi: $e');
      return {};
    }
  }
  
  // Mock get qimen fortune
  Future<Map<String, dynamic>> getFortuneQimen() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      final String data = await rootBundle.loadString('assets/mock/fortune_qimen.json');
      return _safeJsonDecode(data);
    } catch (e) {
      print('Error loading fortune qimen: $e');
      return {};
    }
  }
  
  // Mock get social feeds
  Future<List<dynamic>> getSocialFeeds() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      final String data = await rootBundle.loadString('assets/mock/social_feeds.json');
      final result = _safeJsonDecode(data);
      return result is List ? result : [];
    } catch (e) {
      print('Error loading social feeds: $e');
      return [];
    }
  }
  
  // Mock get social groups
  Future<List<dynamic>> getSocialGroups() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      final String data = await rootBundle.loadString('assets/mock/social_groups.json');
      final result = _safeJsonDecode(data);
      return result is List ? result : [];
    } catch (e) {
      print('Error loading social groups: $e');
      return [];
    }
  }
  
  // Mock get social activities
  Future<List<dynamic>> getSocialActivities() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      final String data = await rootBundle.loadString('assets/mock/social_activities.json');
      final result = _safeJsonDecode(data);
      return result is List ? result : [];
    } catch (e) {
      print('Error loading social activities: $e');
      return [];
    }
  }
  
  // Mock get virtual network
  Future<Map<String, dynamic>> getVirtualNetwork() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      final String data = await rootBundle.loadString('assets/mock/virtual_network.json');
      return _safeJsonDecode(data);
    } catch (e) {
      print('Error loading virtual network: $e');
      return {};
    }
  }
}
'@

# Write updated API service file
Set-Content -Path $apiServicePath -Value $newApiServiceContent -Encoding UTF8

# 3. Fix all mock JSON files - rewrite them with proper encoding
$mockFiles = @{
    "assets\mock\user_profile.json" = @'
{
  "userId": "u123456",
  "username": "Zhang Ming",
  "userType": 1,
  "avatar": "https://randomuser.me/api/portraits/men/32.jpg",
  "membershipInfo": {
    "socialMember": true,
    "healthMember": false,
    "partnerMember": false,
    "expirationDates": {
      "socialMember": "2025-05-19"
    }
  },
  "quotaInfo": {
    "healthAdvice": {
      "daily": 100,
      "used": 5
    },
    "fortuneAnalysis": {
      "daily": 100,
      "used": 12
    },
    "socialAnalysis": {
      "daily": 100,
      "used": 3
    }
  },
  "personalInfo": {
    "gender": "male",
    "birthDate": "1990-05-15",
    "birthTime": "13:30",
    "birthLocation": "Beijing",
    "height": 175,
    "weight": 68
  }
}
'@

    "assets\mock\health_overview.json" = @'
{
  "healthScore": 86,
  "steps": 8547,
  "calories": 356,
  "heartRate": "72 bpm",
  "sleep": "7.5 hours",
  "waterIntake": "1200ml",
  "weight": 68.5,
  "trends": {
    "weeklySteps": [7820, 8100, 9200, 7500, 8547, 0, 0],
    "weeklySleep": [7.2, 6.8, 7.5, 8.0, 7.5, 0, 0],
    "weeklyWeight": [68.7, 68.6, 68.5, 68.5, 68.5, 0, 0]
  },
  "recommendations": [
    "Increase water intake to 2000ml today",
    "Sleep quality is good, maintain current sleep schedule",
    "Recommended 15-30 minutes of aerobic exercise"
  ]
}
'@

    "assets\mock\social_feeds.json" = @'
[
  {
    "id": "sf001",
    "user": "Li Jia",
    "avatar": "https://randomuser.me/api/portraits/women/44.jpg",
    "content": "Completed 10,000 steps goal today! Feeling great!",
    "image": "https://images.unsplash.com/photo-1461897104016-0b3b00cc81ee",
    "time": "10 minutes ago",
    "likes": 15,
    "comments": 3
  },
  {
    "id": "sf002",
    "user": "Wang Qiang",
    "avatar": "https://randomuser.me/api/portraits/men/47.jpg",
    "content": "Sharing an effective yoga pose that helps with back pain when practiced daily",
    "image": "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b",
    "time": "42 minutes ago",
    "likes": 28,
    "comments": 7
  },
  {
    "id": "sf003",
    "user": "Health Expert - Dr. Zhang",
    "avatar": "https://randomuser.me/api/portraits/men/28.jpg",
    "content": "Health Tip: Drinking enough water is essential for health. Adults should consume about 2000ml daily.",
    "image": null,
    "time": "1 hour ago",
    "likes": 42,
    "comments": 5
  }
]
'@
}

# Write updated mock files
foreach ($file in $mockFiles.Keys) {
    Set-Content -Path $file -Value $mockFiles[$file] -Encoding UTF8
    Write-Output "Fixed file: $file"
}

Write-Output "All fixes complete! Run 'flutter run' to start the app."