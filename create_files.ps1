# 汇升活健康社交平台 - Windows 11 创建脚本

# 创建Flutter项目
# flutter create huishengapp
# Set-Location -Path huishengapp

# 清理默认生成的内容
Remove-Item -Path lib\* -Recurse -Force
Remove-Item -Path test\* -Recurse -Force

# 创建项目目录结构
$directories = @(
    "lib\api",
    "lib\models",
    "lib\screens\home",
    "lib\screens\health",
    "lib\screens\fortune",
    "lib\screens\social",
    "lib\screens\profile",
    "lib\widgets",
    "lib\utils",
    "assets\mock"
)

foreach ($dir in $directories) {
    New-Item -Path $dir -ItemType Directory -Force
}

# 更新pubspec.yaml文件添加assets
$pubspecContent = Get-Content -Path pubspec.yaml
$newPubspecContent = @()

$assetsDefined = $false

foreach ($line in $pubspecContent) {
    $newPubspecContent += $line
    
    if ($line -match "^flutter:") {
        $assetSection = $false
    }
    
    if ($line -match "^\s*assets:") {
        $assetSection = $true
        $assetsDefined = $true
    }
}

if (-not $assetsDefined) {
    # 找到flutter:部分，添加assets配置
    $newContent = @()
    foreach ($line in $newPubspecContent) {
        $newContent += $line
        if ($line -match "^flutter:") {
            $newContent += "  assets:"
            $newContent += "    - assets/mock/"
        }
    }
    $newPubspecContent = $newContent
}

Set-Content -Path pubspec.yaml -Value $newPubspecContent

# 创建Mock数据文件
$mockFiles = @{
    "user_profile.json" = @'
{
  "userId": "u123456",
  "username": "张明",
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
    "birthLocation": "北京市朝阳区",
    "height": 175,
    "weight": 68
  }
}
'@

    "health_overview.json" = @'
{
  "healthScore": 86,
  "steps": 8547,
  "calories": 356,
  "heartRate": "72 bpm",
  "sleep": "7.5小时",
  "waterIntake": "1200ml",
  "weight": 68.5,
  "trends": {
    "weeklySteps": [7820, 8100, 9200, 7500, 8547, 0, 0],
    "weeklySleep": [7.2, 6.8, 7.5, 8.0, 7.5, 0, 0],
    "weeklyWeight": [68.7, 68.6, 68.5, 68.5, 68.5, 0, 0]
  },
  "recommendations": [
    "今日宜增加饮水量，建议达到2000ml",
    "睡眠质量良好，建议保持当前作息",
    "宜进行15-30分钟的有氧运动"
  ]
}
'@

    "health_records.json" = @'
[
  {
    "id": "hr001",
    "date": "2025-04-19",
    "metrics": {
      "weight": 68.5,
      "steps": 8547,
      "calories": 356,
      "heartRate": 72,
      "sleepHours": 7.5,
      "waterIntake": 1200
    },
    "notes": "今天感觉状态不错，早上跑步5公里"
  },
  {
    "id": "hr002",
    "date": "2025-04-18",
    "metrics": {
      "weight": 68.5,
      "steps": 7500,
      "calories": 320,
      "heartRate": 74,
      "sleepHours": 8.0,
      "waterIntake": 1500
    },
    "notes": "上午有点疲劳，下午状态恢复"
  },
  {
    "id": "hr003",
    "date": "2025-04-17",
    "metrics": {
      "weight": 68.5,
      "steps": 9200,
      "calories": 420,
      "heartRate": 76,
      "sleepHours": 7.5,
      "waterIntake": 1800
    },
    "notes": "参加了公司篮球活动，运动量较大"
  }
]
'@

    "health_reports.json" = @'
[
  {
    "id": "hpr001",
    "title": "4月健康月报",
    "type": 2,
    "startDate": "2025-04-01",
    "endDate": "2025-04-30",
    "summary": "整体健康状况良好，体重稳定，运动量充足",
    "metrics": {
      "weightTrend": {"start": 69.2, "end": 68.5, "change": -0.7},
      "sleepQuality": {"average": 7.4, "status": "良好"},
      "activityLevel": {"average": 8200, "status": "活跃"}
    },
    "recommendations": [
      "增加饮水量至2500ml/天",
      "建议增加15分钟的拉伸活动",
      "建议适当增加蛋白质摄入"
    ],
    "createTime": "2025-04-30"
  },
  {
    "id": "hpr002",
    "title": "3月健康月报",
    "type": 2,
    "startDate": "2025-03-01",
    "endDate": "2025-03-31",
    "summary": "健康状况稳定，睡眠质量略有下降",
    "metrics": {
      "weightTrend": {"start": 70.1, "end": 69.2, "change": -0.9},
      "sleepQuality": {"average": 6.8, "status": "一般"},
      "activityLevel": {"average": 7600, "status": "活跃"}
    },
    "recommendations": [
      "改善睡眠环境，保持规律作息",
      "增加户外活动时间",
      "注意工作压力管理"
    ],
    "createTime": "2025-03-31"
  }
]
'@

    "fortune_daily.json" = @'
{
  "date": "2025-04-19",
  "overallScore": 80,
  "careerScore": 85,
  "wealthScore": 75,
  "healthScore": 78,
  "relationshipScore": 82,
  "summary": "今日整体运势良好，工作中有贵人相助，财运稳定",
  "aspects": {
    "career": {
      "score": 85,
      "summary": "工作顺利，适合开展重要项目",
      "tips": ["把握上午会议机会", "展示创新想法"]
    },
    "wealth": {
      "score": 75,
      "summary": "财运稳定，不宜大额投资",
      "tips": ["适合日常收支", "避免冲动消费"]
    }
  },
  "luckyDirections": {
    "best": "东南",
    "worst": "西北"
  },
  "luckyTimes": {
    "best": "13:00-15:00",
    "worst": "19:00-21:00"
  },
  "suitable": ["谈判", "会友", "商务合作"],
  "unsuitable": ["大额支出", "长途旅行"]
}
'@

    "fortune_bazi.json" = @'
{
  "userId": "u123456",
  "yearPillar": {"heavenlyStem": "庚", "earthlyBranch": "午"},
  "monthPillar": {"heavenlyStem": "己", "earthlyBranch": "丑"},
  "dayPillar": {"heavenlyStem": "甲", "earthlyBranch": "午"},
  "hourPillar": {"heavenlyStem": "丙", "earthlyBranch": "申"},
  "fiveElements": {
    "wood": 20,
    "fire": 30,
    "earth": 25,
    "metal": 15,
    "water": 10
  },
  "dominantElement": "火",
  "weakElement": "水",
  "dayMaster": "甲木",
  "character": {
    "strengths": ["创造力强", "善于沟通", "决策果断"],
    "challenges": ["有时固执", "压力下情绪波动"],
    "traits": "性格开朗，思维活跃，善于表达，富有创造力"
  },
  "lifeAspects": {
    "career": {
      "suitable": ["创意行业", "教育培训", "管理咨询"],
      "suggestions": "适合创意性工作，善于创新和表达，可发展领导才能"
    },
    "relationships": {
      "suitable": ["丁火", "己土", "辛金"],
      "challenging": ["壬水", "癸水"],
      "suggestions": "理想伴侣应具备稳定性格，能欣赏您的创造力"
    },
    "health": {
      "strengths": "心血管系统良好，精力充沛",
      "weaknesses": "肝胆系统需关注，压力管理重要",
      "suggestions": "注意肝胆保养，规律饮食，适当运动"
    }
  }
}
'@

    "fortune_qimen.json" = @'
{
  "castTime": "2025-04-19T14:30:00+08:00",
  "panType": "阳遁",
  "ju": 3,
  "zhifu": "坤宫",
  "zhishi": "开门",
  "palace": [
    {
      "position": 1,
      "palaceName": "坎宫",
      "star": "天蓬",
      "door": "休门",
      "god": "腾蛇"
    },
    {
      "position": 2,
      "palaceName": "坤宫",
      "star": "天芮",
      "door": "开门",
      "god": "太阴"
    }
  ],
  "analysis": {
    "summary": "戊贵人值时，天盘庚申，落宫得贵，主事业有贵人相助",
    "auspicious": [
      "东南方有发展机会",
      "申时行事较顺"
    ],
    "inauspicious": [
      "西北方阻滞重重",
      "酉时不宜启动新项目"
    ]
  },
  "recommendations": [
    "今日宜向东南方行事",
    "申时（15:00-17:00）是今日吉时",
    "避免向西北方向出行",
    "投资决策宜谨慎"
  ]
}
'@

    "social_feeds.json" = @'
[
  {
    "id": "sf001",
    "user": "李佳",
    "avatar": "https://randomuser.me/api/portraits/women/44.jpg",
    "content": "今天完成了10000步目标！感觉很棒 💪",
    "image": "https://images.unsplash.com/photo-1461897104016-0b3b00cc81ee",
    "time": "10分钟前",
    "likes": 15,
    "comments": 3
  },
  {
    "id": "sf002",
    "user": "王强",
    "avatar": "https://randomuser.me/api/portraits/men/47.jpg",
    "content": "分享一个很有效的瑜伽动作，每天坚持可以改善腰痛问题",
    "image": "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b",
    "time": "42分钟前",
    "likes": 28,
    "comments": 7
  },
  {
    "id": "sf003",
    "user": "健康专家-张医生",
    "avatar": "https://randomuser.me/api/portraits/men/28.jpg",
    "content": "【健康小贴士】每天喝足够的水对身体健康至关重要。成年人每天应该摄入约2000ml的水。",
    "image": null,
    "time": "1小时前",
    "likes": 42,
    "comments": 5
  }
]
'@

    "social_groups.json" = @'
[
  {
    "id": "g001",
    "name": "健康生活俱乐部",
    "description": "分享健康生活方式和运动技巧的社群",
    "memberCount": 128,
    "activityCount": 5,
    "coverUrl": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438",
    "lastActive": "今天"
  },
  {
    "id": "g002",
    "name": "职场八字研究会",
    "description": "探讨如何将八字与职业发展结合的小组",
    "memberCount": 86,
    "activityCount": 2,
    "coverUrl": "https://images.unsplash.com/photo-1507679799987-c73779587ccf",
    "lastActive": "昨天"
  },
  {
    "id": "g003",
    "name": "城市探索者",
    "description": "组织各类户外活动，探索城市隐藏角落",
    "memberCount": 215,
    "activityCount": 8,
    "coverUrl": "https://images.unsplash.com/photo-1506459225024-1428097a7e18",
    "lastActive": "3天前"
  }
]
'@

    "social_activities.json" = @'
[
  {
    "id": "a001",
    "title": "周末晨跑团",
    "description": "每周六早上7点，奥林匹克公园集合，一起晨跑5公里",
    "groupId": "g001",
    "startTime": "2025-04-20T07:00:00",
    "location": "奥林匹克公园南门",
    "participantCount": 18,
    "maxParticipants": 30,
    "coverUrl": "https://images.unsplash.com/photo-1461897104016-0b3b00cc81ee",
    "status": 1
  },
  {
    "id": "a002",
    "title": "职场与八字：如何选择适合的行业",
    "description": "探讨八字与职业选择的关系，分享实际案例",
    "groupId": "g002",
    "startTime": "2025-04-25T19:00:00",
    "location": "线上会议",
    "participantCount": 35,
    "maxParticipants": 50,
    "coverUrl": "https://images.unsplash.com/photo-1542744173-8659b8e77b1a",
    "status": 1
  },
  {
    "id": "a003",
    "title": "城市漫步：老胡同探索之旅",
    "description": "探索北京传统胡同，了解历史文化，拍摄纪实照片",
    "groupId": "g003",
    "startTime": "2025-04-26T14:00:00",
    "location": "鼓楼大街地铁站",
    "participantCount": 12,
    "maxParticipants": 15,
    "coverUrl": "https://images.unsplash.com/photo-1507677719041-aedc79f7dcd6",
    "status": 1
  }
]
'@

    "virtual_network.json" = @'
{
  "nodes": [
    {
      "id": "vu001",
      "name": "李四",
      "avatar": "https://randomuser.me/api/portraits/men/41.jpg",
      "relationship": "同事",
      "mappedUserId": null
    },
    {
      "id": "vu002",
      "name": "王五",
      "avatar": "https://randomuser.me/api/portraits/men/42.jpg",
      "relationship": "朋友",
      "mappedUserId": "u789012"
    },
    {
      "id": "vu003",
      "name": "赵六",
      "avatar": "https://randomuser.me/api/portraits/men/43.jpg",
      "relationship": "商业伙伴",
      "mappedUserId": null
    }
  ],
  "links": [
    {
      "source": "vu001",
      "target": "vu002",
      "type": "同事",
      "strength": 80
    },
    {
      "source": "vu002",
      "target": "vu003",
      "type": "朋友",
      "strength": 65
    }
  ],
  "analysis": {
    "nodeCount": 3,
    "edgeCount": 2,
    "centralNode": "vu002",
    "insights": [
      "王五是您社交网络中的关键节点",
      "通过王五可以拓展更多人脉"
    ]
  }
}
'@
}

# 创建Mock数据文件
foreach ($file in $mockFiles.Keys) {
    Set-Content -Path "assets\mock\$file" -Value $mockFiles[$file]
    Write-Output "Created: assets\mock\$file"
}

# 创建API服务文件
$mockApiServiceContent = @'
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class MockApiService {
  // 单例模式实现API服务
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal();
  
  // API基础路径
  static const String baseApiUrl = 'https://api.huishengapp.com';
  
  // 模拟获取用户信息
  Future<Map<String, dynamic>> getUserProfile() async {
    await Future.delayed(Duration(milliseconds: 300)); // 模拟网络延迟
    final String data = await rootBundle.loadString('assets/mock/user_profile.json');
    return json.decode(data);
  }
  
  // 模拟获取健康概览
  Future<Map<String, dynamic>> getHealthOverview() async {
    await Future.delayed(Duration(milliseconds: 300));
    final String data = await rootBundle.loadString('assets/mock/health_overview.json');
    return json.decode(data);
  }
  
  // 模拟获取健康记录
  Future<List<dynamic>> getHealthRecords() async {
    await Future.delayed(Duration(milliseconds: 300));
    final String data = await rootBundle.loadString('assets/mock/health_records.json');
    return json.decode(data);
  }
  
  // 模拟获取健康报告
  Future<List<dynamic>> getHealthReports() async {
    await Future.delayed(Duration(milliseconds: 300));
    final String data = await rootBundle.loadString('assets/mock/health_reports.json');
    return json.decode(data);
  }
  
  // 模拟获取每日运势
  Future<Map<String, dynamic>> getFortuneDaily() async {
    await Future.delayed(Duration(milliseconds: 300));
    final String data = await rootBundle.loadString('assets/mock/fortune_daily.json');
    return json.decode(data);
  }
  
  // 模拟获取八字分析
  Future<Map<String, dynamic>> getFortuneBazi() async {
    await Future.delayed(Duration(milliseconds: 300));
    final String data = await rootBundle.loadString('assets/mock/fortune_bazi.json');
    return json.decode(data);
  }
  
  // 模拟获取奇门遁甲分析
  Future<Map<String, dynamic>> getFortuneQimen() async {
    await Future.delayed(Duration(milliseconds: 300));
    final String data = await rootBundle.loadString('assets/mock/fortune_qimen.json');
    return json.decode(data);
  }
  
  // 模拟获取社交动态
  Future<List<dynamic>> getSocialFeeds() async {
    await Future.delayed(Duration(milliseconds: 300));
    final String data = await rootBundle.loadString('assets/mock/social_feeds.json');
    return json.decode(data);
  }
  
  // 模拟获取社群列表
  Future<List<dynamic>> getSocialGroups() async {
    await Future.delayed(Duration(milliseconds: 300));
    final String data = await rootBundle.loadString('assets/mock/social_groups.json');
    return json.decode(data);
  }
  
  // 模拟获取活动列表
  Future<List<dynamic>> getSocialActivities() async {
    await Future.delayed(Duration(milliseconds: 300));
    final String data = await rootBundle.loadString('assets/mock/social_activities.json');
    return json.decode(data);
  }
  
  // 模拟获取虚拟网络
  Future<Map<String, dynamic>> getVirtualNetwork() async {
    await Future.delayed(Duration(milliseconds: 300));
    final String data = await rootBundle.loadString('assets/mock/virtual_network.json');
    return json.decode(data);
  }
}
'@

# 创建API服务文件
Set-Content -Path "lib\api\mock_api_service.dart" -Value $mockApiServiceContent

# 创建主文件
$mainDartContent = @'
import 'package:flutter/material.dart';
import 'api/mock_api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '汇升活健康社交平台',
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
        title: Text('汇升活健康社交平台'),
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
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserHeader(),
                _buildHealthOverview(),
                _buildSectionTitle('社交动态', '查看全部'),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '健康'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: '运势'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '社交'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
  
  Widget _buildUserHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(_userProfile!['avatar']),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '您好，${_userProfile!['username']}',
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
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('健康概览', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          GridView.count(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildHealthCard('步数', '${_healthOverview!['steps']}', Icons.directions_walk),
              _buildHealthCard('卡路里', '${_healthOverview!['calories']}', Icons.local_fire_department),
              _buildHealthCard('心率', '${_healthOverview!['heartRate']}', Icons.favorite),
              _buildHealthCard('睡眠', '${_healthOverview!['sleep']}', Icons.bedtime),
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
                // 用户信息行
                Row(
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          feed['time'],
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
                // 动态内容
                Text(feed['content']),
                if (feed['image'] != null) ...[
                  SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(feed['image']),
                  ),
                ],
                SizedBox(height: 12),
                // 点赞和评论
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 18, color: Colors.grey[700]),
                    SizedBox(width: 4),
                    Text('${feed['likes']}', style: TextStyle(color: Colors.grey[700])),
                    SizedBox(width: 16),
                    Icon(Icons.comment_outlined, size: 18, color: Colors.grey[700]),
                    SizedBox(width: 4),
                    Text('${feed['comments']}', style: TextStyle(color: Colors.grey[700])),
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
    List<String> memberships = [];
    if (_userProfile!['membershipInfo']['socialMember']) memberships.add('社交会员');
    if (_userProfile!['membershipInfo']['healthMember']) memberships.add('健康会员');
    if (_userProfile!['membershipInfo']['partnerMember']) memberships.add('搭子会员');
    return memberships.isEmpty ? '普通用户' : memberships.join(' · ');
  }
}
'@

# 创建主文件
Set-Content -Path "lib\main.dart" -Value $mainDartContent

Write-Output "汇升活健康社交平台项目创建完成!"
Write-Output "运行 'flutter pub get' 以获取依赖，然后运行 'flutter run' 启动应用。"