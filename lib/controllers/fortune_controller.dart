import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/fortune/fortune_models.dart';

class FortuneController {
  // 单例模式
  static final FortuneController _instance = FortuneController._internal();

  factory FortuneController() {
    return _instance;
  }

  FortuneController._internal();

  // 数据缓存
  UserFortuneProfile? _userProfile;
  BaziInfo? _baziInfo;
  QimenInfo? _qimenInfo;
  final Map<String, FortunePrediction> _predictions = {};
  BaziData? _baziData;
  FortuneData? _fortuneData;

  // 初始化方法
  Future<void> initialize() async {
    try {
      await Future.wait([
        loadUserProfile(),
        loadBaziInfo(),
        loadQimenInfo(),
        loadDailyPrediction(),
        loadMonthlyPrediction(),
        loadYearlyPrediction(),
        loadBaziData(),
        loadFortuneData(),
      ]);
    } catch (e) {
      print('初始化运势控制器出错: $e');
    }
  }

  // 加载用户运势档案
  Future<UserFortuneProfile> loadUserProfile() async {
    if (_userProfile != null) return _userProfile!;

    try {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 300));
      final jsonString = await rootBundle.loadString(
        'assets/data/fortune/user_profile.json',
      );
      final jsonData = json.decode(jsonString);
      _userProfile = UserFortuneProfile.fromJson(jsonData);
    } catch (e) {
      print('加载用户运势档案失败: $e');
      // 创建默认档案
      _userProfile = UserFortuneProfile(
        userId: 'taoyonggang',
        name: '陶永刚',
        birthdate: DateTime(1985, 7, 15, 13, 30),
        birthplace: '北京',
        gender: '男',
        isPremiumUser: false,
        lastUpdateTime: DateTime.now(),
      );
    }

    return _userProfile!;
  }

  // 加载八字信息
  Future<BaziInfo> loadBaziInfo() async {
    if (_baziInfo != null) return _baziInfo!;

    try {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 300));
      final jsonString = await rootBundle.loadString(
        'assets/data/fortune/bazi_info.json',
      );
      final jsonData = json.decode(jsonString);
      _baziInfo = BaziInfo.fromJson(jsonData);
    } catch (e) {
      print('加载八字信息失败: $e');
      // 创建默认八字信息
      _baziInfo = BaziInfo(
        year: '乙丑',
        month: '丙午',
        day: '戊申',
        hour: '甲午',
        fiveElements: {'木': 2, '火': 3, '土': 1, '金': 2, '水': 0},
        mainElement: '火',
        favorableElement: '木',
        unfavorableElement: '水',
        personalities: ['聪明机智', '热情开朗'],
        destinyType: '偏财格',
        isPremiumDetail: false,
      );
    }

    return _baziInfo!;
  }

  // 加载奇门遁甲信息
  Future<QimenInfo> loadQimenInfo() async {
    if (_qimenInfo != null) return _qimenInfo!;

    try {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 300));
      final jsonString = await rootBundle.loadString(
        'assets/data/fortune/qimen_info.json',
      );
      final jsonData = json.decode(jsonString);
      _qimenInfo = QimenInfo.fromJson(jsonData);
    } catch (e) {
      print('加载奇门遁甲信息失败: $e');
      // 创建简化的默认信息
      _qimenInfo = QimenInfo(
        formationTime: DateTime.now().toString(),
        jieQi: '谷雨',
        yuanKong: '辛壬',
        palaces: [],
        directions: {'东': '吉', '南': '中', '西': '凶', '北': '大吉'},
        timeTrends: ['数据加载失败'],
        baziCompatibility: '无数据',
        isPremiumDetail: true,
      );
    }

    return _qimenInfo!;
  }

  // 加载日运势预测
  Future<FortunePrediction> loadDailyPrediction() async {
    if (_predictions.containsKey('daily')) return _predictions['daily']!;

    try {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 300));
      final jsonString = await rootBundle.loadString(
        'assets/data/fortune/daily_prediction.json',
      );
      final jsonData = json.decode(jsonString);
      _predictions['daily'] = FortunePrediction.fromJson(jsonData);
    } catch (e) {
      print('加载日运势预测失败: $e');
      // 创建简化的默认信息
      _predictions['daily'] = FortunePrediction(
        periodType: 'day',
        startDate: DateTime.now().toString().split(' ')[0],
        endDate: DateTime.now().toString().split(' ')[0],
        overallRating: 70,
        overallDescription: '今日运势一般，宜静不宜动。',
        aspects: {
          'career': FortuneAspect(
            name: '事业',
            rating: 70,
            description: '工作进展顺利，注意细节',
            suggestions: ['专注当前任务'],
          ),
        },
        luckyDates: [],
        unluckyDates: [],
        advice: ['保持平常心'],
        isPremiumDetail: false,
      );
    }

    return _predictions['daily']!;
  }

  // 加载月运势预测
  Future<FortunePrediction> loadMonthlyPrediction() async {
    if (_predictions.containsKey('monthly')) return _predictions['monthly']!;

    try {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 300));
      final jsonString = await rootBundle.loadString(
        'assets/data/fortune/monthly_prediction.json',
      );
      final jsonData = json.decode(jsonString);
      _predictions['monthly'] = FortunePrediction.fromJson(jsonData);
    } catch (e) {
      print('加载月运势预测失败: $e');
      // 创建简化的默认信息
      _predictions['monthly'] = FortunePrediction(
        periodType: 'month',
        startDate: '2025-04-01',
        endDate: '2025-04-30',
        overallRating: 75,
        overallDescription: '本月运势稳定，适合稳步发展。',
        aspects: {},
        luckyDates: [],
        unluckyDates: [],
        advice: ['保持积极心态'],
        isPremiumDetail: true,
      );
    }

    return _predictions['monthly']!;
  }

  // 加载年运势预测
  Future<FortunePrediction> loadYearlyPrediction() async {
    if (_predictions.containsKey('yearly')) return _predictions['yearly']!;

    try {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 300));
      final jsonString = await rootBundle.loadString(
        'assets/data/fortune/yearly_prediction.json',
      );
      final jsonData = json.decode(jsonString);
      _predictions['yearly'] = FortunePrediction.fromJson(jsonData);
    } catch (e) {
      print('加载年运势预测失败: $e');
      // 创建简化的默认信息
      _predictions['yearly'] = FortunePrediction(
        periodType: 'year',
        startDate: '2025-01-01',
        endDate: '2025-12-31',
        overallRating: 80,
        overallDescription: '2025年整体运势向好，有发展机遇。',
        aspects: {},
        luckyDates: [],
        unluckyDates: [],
        advice: ['把握关键机会'],
        isPremiumDetail: true,
      );
    }

    return _predictions['yearly']!;
  }

  // 判断用户是否有权限查看高级内容
  bool canViewPremiumContent() {
    return _userProfile?.isPremiumUser ?? false;
  }

  // 获取指定周期的运势预测
  FortunePrediction? getPrediction(String periodType) {
    switch (periodType.toLowerCase()) {
      case 'day':
      case 'daily':
        return _predictions['daily'];
      case 'month':
      case 'monthly':
        return _predictions['monthly'];
      case 'year':
      case 'yearly':
        return _predictions['yearly'];
      default:
        return null;
    }
  }

  // 刷新数据
  Future<void> refreshData() async {
    // 清除缓存，强制重新加载
    _userProfile = null;
    _baziInfo = null;
    _qimenInfo = null;
    _predictions.clear();
    _baziData = null;
    _fortuneData = null;

    await initialize();
  }

  // 加载八字数据
  Future<BaziData> loadBaziData() async {
    if (_baziData != null) return _baziData!;

    try {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 300));
      final userProfile = await loadUserProfile();
      final baziInfo = await loadBaziInfo();

      // 根据现有数据构造BaziData
      List<BaziPillar> pillars = [
        BaziPillar(
          name: '年柱',
          heavenlyStem: baziInfo.year.substring(0, 1),
          earthlyBranch: baziInfo.year.substring(1, 2),
          element: _getElementForStem(baziInfo.year.substring(0, 1)),
          hiddenElements: '',
        ),
        BaziPillar(
          name: '月柱',
          heavenlyStem: baziInfo.month.substring(0, 1),
          earthlyBranch: baziInfo.month.substring(1, 2),
          element: _getElementForStem(baziInfo.month.substring(0, 1)),
          hiddenElements: '',
        ),
        BaziPillar(
          name: '日柱',
          heavenlyStem: baziInfo.day.substring(0, 1),
          earthlyBranch: baziInfo.day.substring(1, 2),
          element: _getElementForStem(baziInfo.day.substring(0, 1)),
          hiddenElements: '',
        ),
        BaziPillar(
          name: '时柱',
          heavenlyStem: baziInfo.hour.substring(0, 1),
          earthlyBranch: baziInfo.hour.substring(1, 2),
          element: _getElementForStem(baziInfo.hour.substring(0, 1)),
          hiddenElements: '',
        ),
      ];

      _baziData = BaziData(
        name: userProfile.name,
        birthDateTime: userProfile.birthdate,
        birthLocation: userProfile.birthplace,
        pillars: pillars,
        elementCounts: baziInfo.fiveElements,
        mainElement: baziInfo.mainElement,
        favorableElement: baziInfo.favorableElement,
        unfavorableElement: baziInfo.unfavorableElement,
        traits: baziInfo.personalities,
        lifeType: baziInfo.destinyType,
      );
    } catch (e) {
      print('加载八字数据失败: $e');
      // 创建一个默认八字数据
      _baziData = BaziData(
        name: '陶永刚',
        birthDateTime: DateTime(1985, 7, 15, 13, 30),
        birthLocation: '北京',
        pillars: [
          BaziPillar(
            name: '年柱',
            heavenlyStem: '乙',
            earthlyBranch: '丑',
            element: '木',
            hiddenElements: '土',
          ),
          BaziPillar(
            name: '月柱',
            heavenlyStem: '丙',
            earthlyBranch: '午',
            element: '火',
            hiddenElements: '火',
          ),
          BaziPillar(
            name: '日柱',
            heavenlyStem: '戊',
            earthlyBranch: '申',
            element: '土',
            hiddenElements: '金',
          ),
          BaziPillar(
            name: '时柱',
            heavenlyStem: '甲',
            earthlyBranch: '午',
            element: '木',
            hiddenElements: '火',
          ),
        ],
        elementCounts: {'木': 2, '火': 3, '土': 1, '金': 1, '水': 0},
        mainElement: '火',
        favorableElement: '木',
        unfavorableElement: '水',
        traits: ['聪明机智', '热情开朗'],
        lifeType: '偏财格',
      );
    }

    return _baziData!;
  }

  // 加载运势数据
  Future<FortuneData> loadFortuneData() async {
    if (_fortuneData != null) return _fortuneData!;

    try {
      // 模拟API调用
      await Future.delayed(Duration(milliseconds: 300));
      final userProfile = await loadUserProfile();
      final dailyPrediction = await loadDailyPrediction();
      final monthlyPrediction = await loadMonthlyPrediction();
      final yearlyPrediction = await loadYearlyPrediction();

      // 构造日运势数据
      DailyFortune dailyFortune = DailyFortune(
        date: dailyPrediction.startDate,
        rating: dailyPrediction.overallRating,
        overview: dailyPrediction.overallDescription,
        aspects: _extractAspectRatings(dailyPrediction.aspects),
        advice: dailyPrediction.advice,
      );

      // 构造月运势数据
      List<KeyDate> monthlyLuckyDates =
          monthlyPrediction.luckyDates
              .map(
                (date) => KeyDate(
                  date: date.date,
                  reason: date.reason,
                  activities: date.suitableActivities,
                ),
              )
              .toList();

      List<KeyDate> monthlyUnluckyDates =
          monthlyPrediction.unluckyDates
              .map(
                (date) => KeyDate(
                  date: date.date,
                  reason: date.reason,
                  activities: date.activitiesToAvoid,
                ),
              )
              .toList();

      MonthlyFortune monthlyFortune = MonthlyFortune(
        month: monthlyPrediction.startDate.substring(0, 7),
        overview: monthlyPrediction.overallDescription,
        luckyDates: monthlyLuckyDates,
        unluckyDates: monthlyUnluckyDates,
        isPremiumContent: monthlyPrediction.isPremiumDetail,
      );

      // 构造年运势数据
      Map<String, int> yearlyAspects = {};
      yearlyPrediction.aspects.forEach((key, aspect) {
        yearlyAspects[aspect.name] = aspect.rating;
      });

      List<KeyDate> yearlyKeyDates = [];
      // 合并吉日和凶日到重要日期
      for (var date in yearlyPrediction.luckyDates) {
        yearlyKeyDates.add(
          KeyDate(
            date: date.date,
            reason: "吉日: ${date.reason}",
            activities: date.suitableActivities,
          ),
        );
      }

      for (var date in yearlyPrediction.unluckyDates) {
        yearlyKeyDates.add(
          KeyDate(
            date: date.date,
            reason: "凶日: ${date.reason}",
            activities: date.activitiesToAvoid,
          ),
        );
      }

      YearlyFortune yearlyFortune = YearlyFortune(
        year: yearlyPrediction.startDate.substring(0, 4),
        overview: yearlyPrediction.overallDescription,
        aspects: yearlyAspects,
        keyDates: yearlyKeyDates,
        developmentAdvice: yearlyPrediction.advice,
        isPremiumContent: yearlyPrediction.isPremiumDetail,
      );

      _fortuneData = FortuneData(
        dailyFortune: dailyFortune,
        monthlyFortune: monthlyFortune,
        yearlyFortune: yearlyFortune,
        isPremiumUser: userProfile.isPremiumUser,
      );
    } catch (e) {
      print('加载运势数据失败: $e');
      // 创建默认运势数据
      _fortuneData = FortuneData(
        dailyFortune: DailyFortune(
          date: '2025-04-21',
          rating: 75,
          overview: '今日运势良好，适合社交和创意活动。',
          aspects: {'事业': 70, '财运': 65, '感情': 80, '健康': 75},
          advice: ['今天适合与朋友聚会', '事业上可尝试创新方法'],
        ),
        monthlyFortune: MonthlyFortune(
          month: '2025-04',
          overview: '本月整体运势稳定，事业有进展机会。',
          luckyDates: [
            KeyDate(
              date: '2025-04-05',
              reason: '贵人日',
              activities: ['谈判', '签约', '求职'],
            ),
          ],
          unluckyDates: [
            KeyDate(
              date: '2025-04-12',
              reason: '冲煞日',
              activities: ['出行', '搬家', '开业'],
            ),
          ],
          isPremiumContent: true,
        ),
        yearlyFortune: YearlyFortune(
          year: '2025',
          overview: '2025年整体运势向好，是事业发展和个人提升的关键年份。',
          aspects: {'事业': 85, '财运': 75, '感情': 80, '健康': 70, '学习': 85},
          keyDates: [
            KeyDate(
              date: '2025-02-15',
              reason: '开春吉日',
              activities: ['开展新项目', '职业规划', '社交活动'],
            ),
            KeyDate(
              date: '2025-06-15',
              reason: '健康警示日',
              activities: ['避免剧烈运动', '注意休息', '健康检查'],
            ),
          ],
          developmentAdvice: [
            '2025年是事业发展的关键年份，应重视专业能力提升',
            '上半年适合专注事业和学习，下半年应关注家庭和个人成长',
            '保持健康的生活方式，定期体检',
          ],
          isPremiumContent: true,
        ),
        isPremiumUser: false,
      );
    }

    return _fortuneData!;
  }

  // 获取天干对应的五行
  String _getElementForStem(String stem) {
    Map<String, String> stemElements = {
      '甲': '木',
      '乙': '木',
      '丙': '火',
      '丁': '火',
      '戊': '土',
      '己': '土',
      '庚': '金',
      '辛': '金',
      '壬': '水',
      '癸': '水',
    };
    return stemElements[stem] ?? '未知';
  }

  // 从运势方面中提取评分
  Map<String, int> _extractAspectRatings(Map<String, FortuneAspect> aspects) {
    Map<String, int> ratings = {};
    aspects.forEach((key, aspect) {
      ratings[aspect.name] = aspect.rating;
    });
    return ratings;
  }

  // 获取五行对应的颜色
  Color getElementColor(String element) {
    switch (element) {
      case '木':
        return Colors.green;
      case '火':
        return Colors.red;
      case '土':
        return Colors.brown;
      case '金':
        return Colors.amber;
      case '水':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // 计算五行百分比分布
  Map<String, double> calculateElementPercentages() {
    if (_baziData == null) {
      return {'木': 0.0, '火': 0.0, '土': 0.0, '金': 0.0, '水': 0.0};
    }

    Map<String, int> counts = _baziData!.elementCounts;
    int total = counts.values.fold(0, (sum, count) => sum + count);

    if (total == 0) {
      return {'木': 0.0, '火': 0.0, '土': 0.0, '金': 0.0, '水': 0.0};
    }

    return {
      '木': (counts['木'] ?? 0) / total,
      '火': (counts['火'] ?? 0) / total,
      '土': (counts['土'] ?? 0) / total,
      '金': (counts['金'] ?? 0) / total,
      '水': (counts['水'] ?? 0) / total,
    };
  }
}
