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

  // 获取用户资料
  Future<Map<String, dynamic>> getUserProfile() async {
    await Future.delayed(Duration(milliseconds: 500));
    final data = await rootBundle.loadString('assets/data/user_profile.json');
    return json.decode(data);
  }

  // 获取健康概览
  Future<Map<String, dynamic>> getHealthOverview() async {
    await Future.delayed(Duration(milliseconds: 500));
    final data = await rootBundle.loadString(
      'assets/data/health_overview.json',
    );
    return json.decode(data);
  }

  // 获取社交动态
  Future<List<dynamic>> getSocialFeeds() async {
    await Future.delayed(Duration(milliseconds: 500));
    final data = await rootBundle.loadString(
      'assets/data/social/social_feeds.json',
    );
    return json.decode(data);
  }

  /*
  // Mock get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      await Future.delayed(
        Duration(milliseconds: 300),
      ); // Simulate network delay
      final String data = await rootBundle.loadString(
        'assets/mock/user_profile.json',
      );
      return _safeJsonDecode(data);
    } catch (e) {
      print('Error loading user profile: $e');
      return {};
    }
  }

  // 获取健康概览
  Future<Map<String, dynamic>> getHealthOverview() async {
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 800));

    return {
      'healthScore': 86,
      'steps': 8526,
      'calories': 2135,
      'heartRate': '75 bpm',
      'sleep': '7.2 小时',
      'lastUpdated': '2025-04-19 08:30',
    };
  }

  // 获取健康记录
  Future<List<dynamic>> getHealthRecords() async {
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 1000));

    return [
      {
        'id': 'HR001',
        'date': '2025-04-19',
        'time': '08:30',
        'type': 'physical',
        'metrics': {
          'weight': '62.3 kg',
          'bmi': 22.1,
          'bodyFat': '18.6%',
          'waist': '84 cm',
        },
        'notes': '早上起床后测量，昨晚休息良好。',
      },
      {
        'id': 'HR002',
        'date': '2025-04-18',
        'time': '20:15',
        'type': 'lifestyle',
        'metrics': {
          'steps': 9430,
          'sleep': '7.2 小时',
          'calories': 2180,
          'water': '1800 ml',
        },
        'notes': '今天进行了30分钟慢跑和45分钟力量训练。',
      },
      {
        'id': 'HR003',
        'date': '2025-04-18',
        'time': '12:30',
        'type': 'health',
        'metrics': {
          'bloodPressure': '124/78 mmHg',
          'heartRate': '68 bpm',
          'bloodSugar': '5.4 mmol/L',
          'temperature': '36.5 ℃',
        },
        'notes': '午饭后测量，感觉良好。',
      },
      {
        'id': 'HR004',
        'date': '2025-04-17',
        'time': '22:00',
        'type': 'diary',
        'notes': '今天感觉精神不错，中午稍微有些疲倦，下午喝了杯咖啡后恢复精神。晚饭后有些胃胀，可能吃得太快了。',
      },
    ];
  }
  */

  // 获取健康报告
  Future<List<dynamic>> getHealthReports() async {
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 900));

    return [
      {
        'id': 'REP001',
        'title': '月度健康概览报告',
        'date': '2025-04-01',
        'type': 'general',
        'isPremium': false,
      },
      {
        'id': 'REP002',
        'title': '身体成分分析报告',
        'date': '2025-03-25',
        'type': 'physical',
        'isPremium': false,
      },
      {
        'id': 'REP003',
        'title': '生活习惯评估报告',
        'date': '2025-03-20',
        'type': 'lifestyle',
        'isPremium': false,
      },
      {
        'id': 'REP004',
        'title': '健康风险全面评估',
        'date': '2025-03-15',
        'type': 'risk',
        'isPremium': true,
      },
      {
        'id': 'REP005',
        'title': '专业健康分析报告',
        'date': '2025-03-10',
        'type': 'health',
        'isPremium': true,
      },
    ];
  }

  // 获取健康AI顾问数据
  Future<Map<String, dynamic>> getHealthAdvisor() async {
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 1100));

    return {
      'consultations': [
        {
          'id': 'CON001',
          'date': '2025-04-18',
          'question': '我最近总是感到疲倦，可能是什么原因？',
          'answer':
              '疲劳可能由多种因素引起，如睡眠不足、压力大、营养不良或某些疾病。从您的记录来看，您最近的睡眠质量不太理想，并且运动量减少。',
          'suggestions': [
            '尝试规律作息，每晚确保7-8小时的睡眠',
            '增加蛋白质和维生素B族的摄入',
            '适当增加有氧运动，如散步或慢跑',
          ],
        },
        {
          'id': 'CON002',
          'date': '2025-04-15',
          'question': '我的血压偏高，应该如何调整饮食？',
          'answer': '降低血压的饮食调整主要包括减少钠盐摄入、增加钾的摄入、维持健康体重以及均衡饮食。',
          'suggestions': [
            '减少加工食品和外卖的摄入',
            '增加蔬菜、水果和全谷物的比例',
            '适量食用富含钾的食物，如香蕉、土豆和菠菜',
            '限制酒精摄入并避免吸烟',
          ],
        },
      ],
      'suggestions': [
        {
          'id': 'SUG001',
          'category': 'diet',
          'title': '调整饮食结构',
          'content': '根据您的体质和近期记录，建议增加优质蛋白和绿叶蔬菜摄入，减少精制碳水和加工食品。',
          'baziRelevant': false,
        },
        {
          'id': 'SUG002',
          'category': 'exercise',
          'title': '平衡运动方案',
          'content': '您的八字中木火较旺，建议增加舒缓性运动如太极、瑜伽，减少高强度无氧运动，以平衡阴阳。',
          'baziRelevant': true,
        },
        {
          'id': 'SUG003',
          'category': 'sleep',
          'title': '改善睡眠质量',
          'content': '您的睡眠记录显示深度睡眠不足，建议睡前1小时不使用电子设备，可以尝试冥想或轻度拉伸。',
          'baziRelevant': false,
        },
      ],
    };
  }

  // Mock get daily fortune
  Future<Map<String, dynamic>> getFortuneDaily() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      final String data = await rootBundle.loadString(
        'assets/mock/fortune_daily.json',
      );
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
      final String data = await rootBundle.loadString(
        'assets/mock/fortune_bazi.json',
      );
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
      final String data = await rootBundle.loadString(
        'assets/mock/fortune_qimen.json',
      );
      return _safeJsonDecode(data);
    } catch (e) {
      print('Error loading fortune qimen: $e');
      return {};
    }
  }

  // Mock get social groups
  Future<List<dynamic>> getSocialGroups() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      final String data = await rootBundle.loadString(
        'assets/mock/social_groups.json',
      );
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
      final String data = await rootBundle.loadString(
        'assets/mock/social_activities.json',
      );
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
      final String data = await rootBundle.loadString(
        'assets/mock/virtual_network.json',
      );
      return _safeJsonDecode(data);
    } catch (e) {
      print('Error loading virtual network: $e');
      return {};
    }
  }
}

// 添加额外的辅助类
class MissedConnection {
  final String sourceId;
  final String targetId;
  final double confidenceScore;

  MissedConnection({
    required this.sourceId,
    required this.targetId,
    required this.confidenceScore,
  });
}

class StrengthDifference {
  final String sourceId;
  final String targetId;
  final double realStrength;
  final double virtualStrength;

  StrengthDifference({
    required this.sourceId,
    required this.targetId,
    required this.realStrength,
    required this.virtualStrength,
  });

  double get difference => (virtualStrength - realStrength).abs();
}
