import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/health/health_models.dart';

class HealthController {
  // 单例模式
  static final HealthController _instance = HealthController._internal();

  factory HealthController() {
    return _instance;
  }

  HealthController._internal();

  // 数据缓存
  UserHealthProfile? _userProfile;
  List<BodyMetrics>? _bodyMetrics;
  List<LifestyleRecord>? _lifestyleRecords;
  List<HealthIndicators>? _healthIndicators;
  List<HealthDiary>? _healthDiaries;
  HealthAnalysis? _healthAnalysis;
  List<HealthGoal>? _healthGoals;

  // 初始化方法
  Future<void> initialize() async {
    try {
      await Future.wait([
        loadUserProfile(),
        loadBodyMetrics(),
        loadLifestyleRecords(),
        loadHealthIndicators(),
        loadHealthDiaries(),
        loadHealthAnalysis(),
        loadHealthGoals(),
      ]);
    } catch (e) {
      print('初始化健康控制器出错: $e');
    }
  }

  // 加载用户健康档案
  Future<UserHealthProfile> loadUserProfile() async {
    if (_userProfile != null) return _userProfile!;

    try {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 300));
      final jsonString = await rootBundle.loadString(
        'assets/data/health/user_profile.json',
      );
      final jsonData = json.decode(jsonString);
      _userProfile = UserHealthProfile.fromJson(jsonData);
    } catch (e) {
      print('加载用户健康档案失败: $e');
      // 创建默认档案
      _userProfile = UserHealthProfile(
        userId: 'taoyonggang',
        name: '陶永刚',
        gender: '男',
        age: 40,
        bloodType: 'A',
        baziElement: {'木': 2, '火': 3, '土': 5, '金': 4, '水': 2},
        isPremiumMember: false,
      );
    }

    return _userProfile!;
  }

  // 加载身体指标历史记录
  Future<List<BodyMetrics>> loadBodyMetrics() async {
    if (_bodyMetrics != null) return _bodyMetrics!;

    try {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 300));
      final jsonString = await rootBundle.loadString(
        'assets/data/health/body_metrics.json',
      );
      final jsonData = json.decode(jsonString) as List;
      _bodyMetrics =
          jsonData.map((item) => BodyMetrics.fromJson(item)).toList();
    } catch (e) {
      print('加载身体指标历史记录失败: $e');
      // 创建默认数据
      _bodyMetrics = [
        BodyMetrics(
          height: 175.0,
          weight: 70.0,
          waistCircumference: 80.0,
          bodyFatPercentage: 15.0,
          bmi: 22.9,
          recordDate: '2025-04-21',
        ),
      ];
    }

    return _bodyMetrics!;
  }

  // 加载生活习惯记录
  Future<List<LifestyleRecord>> loadLifestyleRecords() async {
    if (_lifestyleRecords != null) return _lifestyleRecords!;

    try {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 300));
      final jsonString = await rootBundle.loadString(
        'assets/data/health/lifestyle_records.json',
      );
      final jsonData = json.decode(jsonString) as List;
      _lifestyleRecords =
          jsonData.map((item) => LifestyleRecord.fromJson(item)).toList();
    } catch (e) {
      print('加载生活习惯记录失败: $e');
      // 创建默认数据
      _lifestyleRecords = [];
    }

    return _lifestyleRecords!;
  }

  // 加载健康指标记录
  Future<List<HealthIndicators>> loadHealthIndicators() async {
    if (_healthIndicators != null) return _healthIndicators!;

    try {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 300));
      final jsonString = await rootBundle.loadString(
        'assets/data/health/health_indicators.json',
      );
      final jsonData = json.decode(jsonString) as List;
      _healthIndicators =
          jsonData.map((item) => HealthIndicators.fromJson(item)).toList();
    } catch (e) {
      print('加载健康指标记录失败: $e');
      // 创建默认数据
      _healthIndicators = [];
    }

    return _healthIndicators!;
  }

  // 加载健康日记
  Future<List<HealthDiary>> loadHealthDiaries() async {
    if (_healthDiaries != null) return _healthDiaries!;

    try {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 300));
      final jsonString = await rootBundle.loadString(
        'assets/data/health/health_diaries.json',
      );
      final jsonData = json.decode(jsonString) as List;
      _healthDiaries =
          jsonData.map((item) => HealthDiary.fromJson(item)).toList();
    } catch (e) {
      print('加载健康日记失败: $e');
      // 创建默认数据
      _healthDiaries = [];
    }

    return _healthDiaries!;
  }

  // 加载健康分析报告
  Future<HealthAnalysis> loadHealthAnalysis() async {
    if (_healthAnalysis != null) return _healthAnalysis!;

    try {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 500));
      final jsonString = await rootBundle.loadString(
        'assets/data/health/health_analysis.json',
      );
      final jsonData = json.decode(jsonString);
      _healthAnalysis = HealthAnalysis.fromJson(jsonData);
    } catch (e) {
      print('加载健康分析报告失败: $e');
      // 创建默认数据
      _healthAnalysis = HealthAnalysis(
        analysisDate: '2025-04-21',
        overallStatus: '总体健康状况良好',
        healthScore: 78,
        insights: [],
        recommendations: [],
        risks: [],
        isPremiumReport: false,
      );
    }

    return _healthAnalysis!;
  }

  // 加载健康目标
  Future<List<HealthGoal>> loadHealthGoals() async {
    if (_healthGoals != null) return _healthGoals!;

    try {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 300));
      final jsonString = await rootBundle.loadString(
        'assets/data/health/health_goals.json',
      );
      final jsonData = json.decode(jsonString) as List;
      _healthGoals = jsonData.map((item) => HealthGoal.fromJson(item)).toList();
    } catch (e) {
      print('加载健康目标失败: $e');
      // 创建默认数据
      _healthGoals = [];
    }

    return _healthGoals!;
  }

  // 保存身体指标
  Future<bool> saveBodyMetrics(BodyMetrics metrics) async {
    // 模拟API调用
    await Future.delayed(Duration(milliseconds: 500));

    // 更新本地缓存
    if (_bodyMetrics != null) {
      _bodyMetrics!.add(metrics);
    } else {
      _bodyMetrics = [metrics];
    }

    return true;
  }

  // 保存生活习惯记录
  Future<bool> saveLifestyleRecord(LifestyleRecord record) async {
    // 模拟API调用
    await Future.delayed(Duration(milliseconds: 500));

    // 更新本地缓存
    if (_lifestyleRecords != null) {
      _lifestyleRecords!.add(record);
    } else {
      _lifestyleRecords = [record];
    }

    return true;
  }

  // 保存健康日记
  Future<bool> saveHealthDiary(HealthDiary diary) async {
    // 模拟API调用
    await Future.delayed(Duration(milliseconds: 500));

    // 更新本地缓存
    if (_healthDiaries != null) {
      _healthDiaries!.add(diary);
    } else {
      _healthDiaries = [diary];
    }

    return true;
  }

  // 保存健康指标
  Future<bool> saveHealthIndicators(HealthIndicators indicators) async {
    // 模拟API调用
    await Future.delayed(Duration(milliseconds: 500));

    // 更新本地缓存
    if (_healthIndicators != null) {
      _healthIndicators!.add(indicators);
    } else {
      _healthIndicators = [indicators];
    }

    return true;
  }

  // 创建健康目标
  Future<bool> createHealthGoal(HealthGoal goal) async {
    // 模拟API调用
    await Future.delayed(Duration(milliseconds: 500));

    // 更新本地缓存
    if (_healthGoals != null) {
      _healthGoals!.add(goal);
    } else {
      _healthGoals = [goal];
    }

    return true;
  }

  // 判断用户是否是会员
  bool isUserPremiumMember() {
    if (_userProfile == null) return false;
    return _userProfile!.isPremiumMember;
  }

  // 获取最新的身体指标
  BodyMetrics? getLatestBodyMetrics() {
    if (_bodyMetrics == null || _bodyMetrics!.isEmpty) return null;
    return _bodyMetrics!.last;
  }

  // 获取BMI状态描述
  String getBMIStatus(double bmi) {
    if (bmi < 18.5) {
      return "体重过轻";
    } else if (bmi < 24) {
      return "正常范围";
    } else if (bmi < 28) {
      return "超重";
    } else {
      return "肥胖";
    }
  }

  // 根据生活习惯计算健康评分
  int calculateLifestyleScore(LifestyleRecord record) {
    int score = 70; // 基础分

    // 睡眠评分
    if (record.sleep.sleepDurationMinutes >= 420) score += 5; // 7小时以上加分
    if (record.sleep.sleepQualityRating >= 4) score += 5;

    // 运动评分
    int totalExerciseMinutes = 0;
    for (var ex in record.exercises) {
      totalExerciseMinutes += ex.durationMinutes;
    }
    if (totalExerciseMinutes >= 30) score += 5;

    // 久坐扣分
    if (record.sedentaryMinutes > 480) score -= 5; // 8小时以上久坐扣分

    // 水分摄入
    if (record.waterIntake.cups >= 8) score += 5;

    return score > 100 ? 100 : (score < 0 ? 0 : score);
  }
}
