# 将所有代码存入相应文件
Set-Content -Path "lib\screens\health\health_screen.dart" -Value $healthScreenContent -Encoding UTF8
Set-Content -Path "lib\screens\fortune\fortune_screen.dart" -Value $fortuneScreenContent -Encoding UTF8
Set-Content -Path "lib\screens\social\social_screen.dart" -Value $socialScreenContent -Encoding UTF8
Set-Content -Path "lib\screens\profile\profile_screen.dart" -Value $profileScreenContent -Encoding UTF8

# 更新主文件以使导航功能正常运行
$mainDartContent = @'
import 'package:flutter/material.dart';
import 'api/mock_api_service.dart';
import 'screens/health/health_screen.dart';
import 'screens/fortune/fortune_screen.dart';
import 'screens/social/social_screen.dart';
import 'screens/profile/profile_screen.dart';

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
      home: MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    HomeScreen(),
    HealthScreen(),
    FortuneScreen(),
    SocialScreen(),
    ProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
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
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MockApiService _apiService = MockApiService();
  
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
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
          GestureDetector(
            onTap: () {
              // Navigate to Social tab
              final BottomNavigationBar navBar = 
                  (context.findAncestorWidgetOfExactType<Scaffold>()?.bottomNavigationBar as BottomNavigationBar);
              if (navBar != null) {
                navBar.onTap!(3); // Index for Social tab
              }
            },
            child: Text(
              action,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
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
      itemCount: _socialFeeds!.length > 2 ? 2 : _socialFeeds!.length,  // Only show 2 items on home
      itemBuilder: (context, index) {
        final feed = _socialFeeds![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

# 写入更新后的main.dart
Set-Content -Path "lib\main.dart" -Value $mainDartContent -Encoding UTF8

Write-Output "Navigation system implementation complete! Run 'flutter run' to see the updated app with working navigation."