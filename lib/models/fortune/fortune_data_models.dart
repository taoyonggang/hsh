// 修改FortuneData类，添加yearlyFortune字段
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

  factory FortuneData.fromJson(Map<String, dynamic> json) {
    return FortuneData(
      dailyFortune: DailyFortune.fromJson(json['dailyFortune']),
      monthlyFortune: MonthlyFortune.fromJson(json['monthlyFortune']),
      yearlyFortune: YearlyFortune.fromJson(json['yearlyFortune']),
      isPremiumUser: json['isPremiumUser'] ?? false,
    );
  }
}

// 添加年运势类
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

  factory YearlyFortune.fromJson(Map<String, dynamic> json) {
    List<KeyDate> keyDates = [];
    if (json.containsKey('keyDates')) {
      keyDates =
          (json['keyDates'] as List)
              .map((date) => KeyDate.fromJson(date))
              .toList();
    }

    Map<String, int> aspects = {};
    if (json.containsKey('aspects')) {
      json['aspects'].forEach((key, value) {
        aspects[key] = value;
      });
    }

    return YearlyFortune(
      year: json['year'] ?? '',
      overview: json['overview'] ?? '',
      aspects: aspects,
      keyDates: keyDates,
      developmentAdvice:
          json.containsKey('developmentAdvice')
              ? List<String>.from(json['developmentAdvice'])
              : [],
      isPremiumContent: json['isPremiumContent'] ?? true,
    );
  }
}
