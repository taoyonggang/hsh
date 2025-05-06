import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';
import 'screens/health/health_screen.dart';
import 'screens/fortune/fortune_screen.dart';
import 'screens/partner/partner_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'services/auth_service.dart';
import 'app/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化认证服务
  await AuthService().initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '汇升活健康搭子平台',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Color(0xFFF5F6FA),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      home: MainNavigationScreen(),
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 主导航屏幕 - 控制底部导航和页面切换
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final String _username = "taoyonggang"; // 当前登录用户
  final DateTime _now = DateTime.utc(2025, 4, 30, 1, 7, 11); // 使用当前的UTC时间

  // 定义所有主要页面
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // 初始化所有页面，并传入用户名
    _screens = [
      HomeScreen(username: _username, currentDate: _now),
      HealthScreen(),
      FortuneScreen(),
      PartnerScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: '健康',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph),
            activeIcon: Icon(Icons.auto_graph),
            label: '运势',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: '搭子',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
