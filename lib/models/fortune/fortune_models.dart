// 完整的运势分析模型类

// 用户运势档案
class UserFortuneProfile {
  final String userId;
  final String name;
  final DateTime birthdate;
  final String birthplace;
  final String gender;
  final bool isPremiumUser;
  final DateTime lastUpdateTime;

  UserFortuneProfile({
    required this.userId,
    required this.name,
    required this.birthdate,
    required this.birthplace,
    required this.gender,
    required this.isPremiumUser,
    required this.lastUpdateTime,
  });

  factory UserFortuneProfile.fromJson(Map<String, dynamic> json) {
    return UserFortuneProfile(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      birthdate:
          json.containsKey('birthdate')
              ? DateTime.parse(json['birthdate'])
              : DateTime.now(),
      birthplace: json['birthplace'] ?? '',
      gender: json['gender'] ?? '',
      isPremiumUser: json['isPremiumUser'] ?? false,
      lastUpdateTime:
          json.containsKey('lastUpdateTime')
              ? DateTime.parse(json['lastUpdateTime'])
              : DateTime.now(),
    );
  }
}

// 八字信息
class BaziInfo {
  final String year; // 年柱
  final String month; // 月柱
  final String day; // 日柱
  final String hour; // 时柱
  final Map<String, int> fiveElements; // 五行分布
  final String mainElement; // 主命元素
  final String favorableElement; // 喜用神
  final String unfavorableElement; // 忌神
  final List<String> personalities; // 性格特点
  final String destinyType; // 命局类型
  final bool isPremiumDetail; // 是否为高级详情

  BaziInfo({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.fiveElements,
    required this.mainElement,
    required this.favorableElement,
    required this.unfavorableElement,
    required this.personalities,
    required this.destinyType,
    required this.isPremiumDetail,
  });

  factory BaziInfo.fromJson(Map<String, dynamic> json) {
    return BaziInfo(
      year: json['year'] ?? '',
      month: json['month'] ?? '',
      day: json['day'] ?? '',
      hour: json['hour'] ?? '',
      fiveElements:
          json.containsKey('fiveElements')
              ? Map<String, int>.from(json['fiveElements'])
              : {},
      mainElement: json['mainElement'] ?? '',
      favorableElement: json['favorableElement'] ?? '',
      unfavorableElement: json['unfavorableElement'] ?? '',
      personalities:
          json.containsKey('personalities')
              ? List<String>.from(json['personalities'])
              : [],
      destinyType: json['destinyType'] ?? '',
      isPremiumDetail: json['isPremiumDetail'] ?? false,
    );
  }
}

// 奇门遁甲信息
class QimenInfo {
  final String formationTime; // 排盘时间
  final String jieQi; // 节气
  final String yuanKong; // 元空
  final List<Palace> palaces; // 九宫格
  final Map<String, String> directions; // 方位吉凶
  final List<String> timeTrends; // 时空动态分析
  final String baziCompatibility; // 与八字结合的分析
  final bool isPremiumDetail; // 是否为高级详情

  QimenInfo({
    required this.formationTime,
    required this.jieQi,
    required this.yuanKong,
    required this.palaces,
    required this.directions,
    required this.timeTrends,
    required this.baziCompatibility,
    required this.isPremiumDetail,
  });

  factory QimenInfo.fromJson(Map<String, dynamic> json) {
    List<Palace> palaces = [];
    if (json.containsKey('palaces')) {
      palaces =
          (json['palaces'] as List).map((e) => Palace.fromJson(e)).toList();
    }

    return QimenInfo(
      formationTime: json['formationTime'] ?? '',
      jieQi: json['jieQi'] ?? '',
      yuanKong: json['yuanKong'] ?? '',
      palaces: palaces,
      directions:
          json.containsKey('directions')
              ? Map<String, String>.from(json['directions'])
              : {},
      timeTrends:
          json.containsKey('timeTrends')
              ? List<String>.from(json['timeTrends'])
              : [],
      baziCompatibility: json['baziCompatibility'] ?? '',
      isPremiumDetail: json['isPremiumDetail'] ?? true,
    );
  }
}

// 宫位信息
class Palace {
  final int number; // 宫位数字 1-9
  final String door; // 八门
  final String star; // 九星
  final String god; // 八神
  final String heavenlyStem; // 天盘干
  final String earthlyStem; // 地盘干
  final String trigram; // 对应卦象
  final String analysis; // 宫位解析

  Palace({
    required this.number,
    required this.door,
    required this.star,
    required this.god,
    required this.heavenlyStem,
    required this.earthlyStem,
    required this.trigram,
    required this.analysis,
  });

  factory Palace.fromJson(Map<String, dynamic> json) {
    return Palace(
      number: json['number'] ?? 1,
      door: json['door'] ?? '',
      star: json['star'] ?? '',
      god: json['god'] ?? '',
      heavenlyStem: json['heavenlyStem'] ?? '',
      earthlyStem: json['earthlyStem'] ?? '',
      trigram: json['trigram'] ?? '',
      analysis: json['analysis'] ?? '',
    );
  }
}

// 运势预测信息
class FortunePrediction {
  final String periodType; // 日、月、年
  final String startDate;
  final String endDate;
  final int overallRating; // 总体评分 1-100
  final String overallDescription; // 总体描述
  final Map<String, FortuneAspect> aspects; // 各方面运势
  final List<LuckyDate> luckyDates; // 吉日
  final List<UnluckyDate> unluckyDates; // 凶日
  final List<String> advice; // 发展建议
  final bool isPremiumDetail; // 是否为高级详情

  FortunePrediction({
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.overallRating,
    required this.overallDescription,
    required this.aspects,
    required this.luckyDates,
    required this.unluckyDates,
    required this.advice,
    required this.isPremiumDetail,
  });

  factory FortunePrediction.fromJson(Map<String, dynamic> json) {
    Map<String, FortuneAspect> aspects = {};
    if (json.containsKey('aspects')) {
      json['aspects'].forEach((key, value) {
        aspects[key] = FortuneAspect.fromJson(value);
      });
    }

    List<LuckyDate> luckyDates = [];
    if (json.containsKey('luckyDates')) {
      luckyDates =
          (json['luckyDates'] as List)
              .map((e) => LuckyDate.fromJson(e))
              .toList();
    }

    List<UnluckyDate> unluckyDates = [];
    if (json.containsKey('unluckyDates')) {
      unluckyDates =
          (json['unluckyDates'] as List)
              .map((e) => UnluckyDate.fromJson(e))
              .toList();
    }

    return FortunePrediction(
      periodType: json['periodType'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      overallRating: json['overallRating'] ?? 0,
      overallDescription: json['overallDescription'] ?? '',
      aspects: aspects,
      luckyDates: luckyDates,
      unluckyDates: unluckyDates,
      advice:
          json.containsKey('advice') ? List<String>.from(json['advice']) : [],
      isPremiumDetail: json['isPremiumDetail'] ?? false,
    );
  }

  // 检查是否可以向普通用户显示
  bool isVisibleToFreeUser() {
    return !isPremiumDetail || periodType == "day"; // 日运势免费用户可见
  }
}

// 运势方面
class FortuneAspect {
  final String name; // 名称 (事业、财运、感情等)
  final int rating; // 评分 1-100
  final String description; // 描述
  final List<String> suggestions; // 建议

  FortuneAspect({
    required this.name,
    required this.rating,
    required this.description,
    required this.suggestions,
  });

  factory FortuneAspect.fromJson(Map<String, dynamic> json) {
    return FortuneAspect(
      name: json['name'] ?? '',
      rating: json['rating'] ?? 0,
      description: json['description'] ?? '',
      suggestions:
          json.containsKey('suggestions')
              ? List<String>.from(json['suggestions'])
              : [],
    );
  }
}

// 吉日信息
class LuckyDate {
  final String date;
  final String reason;
  final List<String> suitableActivities;

  LuckyDate({
    required this.date,
    required this.reason,
    required this.suitableActivities,
  });

  factory LuckyDate.fromJson(Map<String, dynamic> json) {
    return LuckyDate(
      date: json['date'] ?? '',
      reason: json['reason'] ?? '',
      suitableActivities:
          json.containsKey('suitableActivities')
              ? List<String>.from(json['suitableActivities'])
              : [],
    );
  }
}

// 凶日信息
class UnluckyDate {
  final String date;
  final String reason;
  final List<String> activitiesToAvoid;

  UnluckyDate({
    required this.date,
    required this.reason,
    required this.activitiesToAvoid,
  });

  factory UnluckyDate.fromJson(Map<String, dynamic> json) {
    return UnluckyDate(
      date: json['date'] ?? '',
      reason: json['reason'] ?? '',
      activitiesToAvoid:
          json.containsKey('activitiesToAvoid')
              ? List<String>.from(json['activitiesToAvoid'])
              : [],
    );
  }
}

// 八字数据
class BaziData {
  final String name;
  final DateTime birthDateTime;
  final String birthLocation;
  final List<BaziPillar> pillars;
  final Map<String, int> elementCounts;
  final String mainElement;
  final String favorableElement;
  final String unfavorableElement;
  final List<String> traits;
  final String lifeType;

  BaziData({
    required this.name,
    required this.birthDateTime,
    required this.birthLocation,
    required this.pillars,
    required this.elementCounts,
    required this.mainElement,
    required this.favorableElement,
    required this.unfavorableElement,
    required this.traits,
    required this.lifeType,
  });
}

// 八字柱
class BaziPillar {
  final String name; // 年柱、月柱、日柱、时柱
  final String heavenlyStem; // 天干
  final String earthlyBranch; // 地支
  final String element; // 天干五行
  final String hiddenElements; // 地支藏干

  BaziPillar({
    required this.name,
    required this.heavenlyStem,
    required this.earthlyBranch,
    required this.element,
    required this.hiddenElements,
  });
}

// 运势数据
class FortuneData {
  final DailyFortune dailyFortune;
  final MonthlyFortune monthlyFortune;
  final YearlyFortune yearlyFortune;
  final bool isPremiumUser;

  FortuneData({
    required this.dailyFortune,
    required this.monthlyFortune,
    required this.yearlyFortune,
    required this.isPremiumUser,
  });
}

// 日运势
class DailyFortune {
  final String date;
  final int rating;
  final String overview;
  final Map<String, int> aspects;
  final List<String> advice;

  DailyFortune({
    required this.date,
    required this.rating,
    required this.overview,
    required this.aspects,
    required this.advice,
  });
}

// 月运势
class MonthlyFortune {
  final String month;
  final String overview;
  final List<KeyDate> luckyDates;
  final List<KeyDate> unluckyDates;
  final bool isPremiumContent;

  MonthlyFortune({
    required this.month,
    required this.overview,
    required this.luckyDates,
    required this.unluckyDates,
    required this.isPremiumContent,
  });
}

// 年运势
class YearlyFortune {
  final String year;
  final String overview;
  final Map<String, int> aspects;
  final List<KeyDate> keyDates;
  final List<String> developmentAdvice;
  final bool isPremiumContent;

  YearlyFortune({
    required this.year,
    required this.overview,
    required this.aspects,
    required this.keyDates,
    required this.developmentAdvice,
    required this.isPremiumContent,
  });
}

// 重要日期
class KeyDate {
  final String date;
  final String reason;
  final List<String> activities;

  KeyDate({required this.date, required this.reason, required this.activities});
}

// 元素分布
class ElementDistribution {
  final Map<String, double> distribution;

  ElementDistribution({required this.distribution});
}
