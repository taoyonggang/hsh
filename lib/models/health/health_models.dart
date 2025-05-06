// 用户基本健康信息
class UserHealthProfile {
  final String userId;
  final String name;
  final String gender;
  final int age;
  final String bloodType;
  final Map<String, dynamic> baziElement; // 八字元素分布
  final bool isPremiumMember;

  UserHealthProfile({
    required this.userId,
    required this.name,
    required this.gender,
    required this.age,
    required this.bloodType,
    required this.baziElement,
    required this.isPremiumMember,
  });

  factory UserHealthProfile.fromJson(Map<String, dynamic> json) {
    return UserHealthProfile(
      userId: json['userId'],
      name: json['name'],
      gender: json['gender'],
      age: json['age'],
      bloodType: json['bloodType'],
      baziElement: json['baziElement'],
      isPremiumMember: json['isPremiumMember'],
    );
  }
}

// 身体基础指标
class BodyMetrics {
  final double height; // 厘米
  final double weight; // 公斤
  final double waistCircumference; // 腰围，厘米
  final double bodyFatPercentage; // 体脂率，%
  final double bmi; // 体质指数
  final String recordDate;

  BodyMetrics({
    required this.height,
    required this.weight,
    required this.waistCircumference,
    required this.bodyFatPercentage,
    required this.bmi,
    required this.recordDate,
  });

  factory BodyMetrics.fromJson(Map<String, dynamic> json) {
    return BodyMetrics(
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      waistCircumference: json['waistCircumference'].toDouble(),
      bodyFatPercentage: json['bodyFatPercentage'].toDouble(),
      bmi: json['bmi'].toDouble(),
      recordDate: json['recordDate'],
    );
  }
}

// 生活习惯记录
class LifestyleRecord {
  final SleepRecord sleep;
  final List<MealRecord> meals;
  final List<ExerciseRecord> exercises;
  final MoodRecord mood;
  final WaterIntake waterIntake;
  final BowelMovement? bowelMovement;
  final int sedentaryMinutes;
  final SocialActivity? socialActivity;
  final String recordDate;

  LifestyleRecord({
    required this.sleep,
    required this.meals,
    required this.exercises,
    required this.mood,
    required this.waterIntake,
    this.bowelMovement,
    required this.sedentaryMinutes,
    this.socialActivity,
    required this.recordDate,
  });

  factory LifestyleRecord.fromJson(Map<String, dynamic> json) {
    return LifestyleRecord(
      sleep: SleepRecord.fromJson(json['sleep']),
      meals:
          (json['meals'] as List)
              .map((meal) => MealRecord.fromJson(meal))
              .toList(),
      exercises:
          (json['exercises'] as List)
              .map((ex) => ExerciseRecord.fromJson(ex))
              .toList(),
      mood: MoodRecord.fromJson(json['mood']),
      waterIntake: WaterIntake.fromJson(json['waterIntake']),
      bowelMovement:
          json['bowelMovement'] != null
              ? BowelMovement.fromJson(json['bowelMovement'])
              : null,
      sedentaryMinutes: json['sedentaryMinutes'],
      socialActivity:
          json['socialActivity'] != null
              ? SocialActivity.fromJson(json['socialActivity'])
              : null,
      recordDate: json['recordDate'],
    );
  }
}

// 睡眠记录
class SleepRecord {
  final String bedTime;
  final String wakeUpTime;
  final int sleepDurationMinutes;
  final int sleepQualityRating; // 1-5
  final String sleepNotes;

  SleepRecord({
    required this.bedTime,
    required this.wakeUpTime,
    required this.sleepDurationMinutes,
    required this.sleepQualityRating,
    required this.sleepNotes,
  });

  factory SleepRecord.fromJson(Map<String, dynamic> json) {
    return SleepRecord(
      bedTime: json['bedTime'],
      wakeUpTime: json['wakeUpTime'],
      sleepDurationMinutes: json['sleepDurationMinutes'],
      sleepQualityRating: json['sleepQualityRating'],
      sleepNotes: json['sleepNotes'],
    );
  }
}

// 膳食记录
class MealRecord {
  final String mealType; // 早餐、午餐、晚餐、加餐
  final String time;
  final String description;
  final String? imageUrl;
  final List<String> foodCategories;
  final int calories; // 估算卡路里

  MealRecord({
    required this.mealType,
    required this.time,
    required this.description,
    this.imageUrl,
    required this.foodCategories,
    required this.calories,
  });

  factory MealRecord.fromJson(Map<String, dynamic> json) {
    return MealRecord(
      mealType: json['mealType'],
      time: json['time'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      foodCategories: List<String>.from(json['foodCategories']),
      calories: json['calories'],
    );
  }
}

// 运动记录
class ExerciseRecord {
  final String exerciseType;
  final int durationMinutes;
  final String intensity; // 低、中、高
  final int caloriesBurned;
  final String time;

  ExerciseRecord({
    required this.exerciseType,
    required this.durationMinutes,
    required this.intensity,
    required this.caloriesBurned,
    required this.time,
  });

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) {
    return ExerciseRecord(
      exerciseType: json['exerciseType'],
      durationMinutes: json['durationMinutes'],
      intensity: json['intensity'],
      caloriesBurned: json['caloriesBurned'],
      time: json['time'],
    );
  }
}

// 情绪记录
class MoodRecord {
  final String mood; // 开心、平静、焦虑、疲惫等
  final int moodRating; // 1-5
  final String notes;

  MoodRecord({
    required this.mood,
    required this.moodRating,
    required this.notes,
  });

  factory MoodRecord.fromJson(Map<String, dynamic> json) {
    return MoodRecord(
      mood: json['mood'],
      moodRating: json['moodRating'],
      notes: json['notes'],
    );
  }
}

// 饮水量记录
class WaterIntake {
  final int cups; // 杯数
  final int totalMl; // 毫升
  final List<String> drinkTimes;

  WaterIntake({
    required this.cups,
    required this.totalMl,
    required this.drinkTimes,
  });

  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      cups: json['cups'],
      totalMl: json['totalMl'],
      drinkTimes: List<String>.from(json['drinkTimes']),
    );
  }
}

// 排便记录
class BowelMovement {
  final String time;
  final String type; // 正常、硬、软、腹泻等
  final String color;
  final String notes;

  BowelMovement({
    required this.time,
    required this.type,
    required this.color,
    required this.notes,
  });

  factory BowelMovement.fromJson(Map<String, dynamic> json) {
    return BowelMovement(
      time: json['time'],
      type: json['type'],
      color: json['color'],
      notes: json['notes'],
    );
  }
}

// 社交活动
class SocialActivity {
  final String activityType;
  final int durationMinutes;
  final int peopleCount;
  final String notes;

  SocialActivity({
    required this.activityType,
    required this.durationMinutes,
    required this.peopleCount,
    required this.notes,
  });

  factory SocialActivity.fromJson(Map<String, dynamic> json) {
    return SocialActivity(
      activityType: json['activityType'],
      durationMinutes: json['durationMinutes'],
      peopleCount: json['peopleCount'],
      notes: json['notes'],
    );
  }
}

// 健康指标记录
class HealthIndicators {
  final BloodPressure? bloodPressure;
  final int? heartRate;
  final double? bloodSugar;
  final double? bodyTemperature;
  final String recordDate;

  HealthIndicators({
    this.bloodPressure,
    this.heartRate,
    this.bloodSugar,
    this.bodyTemperature,
    required this.recordDate,
  });

  factory HealthIndicators.fromJson(Map<String, dynamic> json) {
    return HealthIndicators(
      bloodPressure:
          json['bloodPressure'] != null
              ? BloodPressure.fromJson(json['bloodPressure'])
              : null,
      heartRate: json['heartRate'],
      bloodSugar: json['bloodSugar']?.toDouble(),
      bodyTemperature: json['bodyTemperature']?.toDouble(),
      recordDate: json['recordDate'],
    );
  }
}

// 血压记录
class BloodPressure {
  final int systolic; // 收缩压
  final int diastolic; // 舒张压

  BloodPressure({required this.systolic, required this.diastolic});

  factory BloodPressure.fromJson(Map<String, dynamic> json) {
    return BloodPressure(
      systolic: json['systolic'],
      diastolic: json['diastolic'],
    );
  }

  String getStatus() {
    if (systolic < 90 || diastolic < 60) {
      return "低血压";
    } else if (systolic < 120 && diastolic < 80) {
      return "正常";
    } else if (systolic < 140 || diastolic < 90) {
      return "正常偏高";
    } else {
      return "高血压";
    }
  }
}

// 健康日记
class HealthDiary {
  final String date;
  final String title;
  final String content;
  final List<String> tags;
  final List<String>? imageUrls;

  HealthDiary({
    required this.date,
    required this.title,
    required this.content,
    required this.tags,
    this.imageUrls,
  });

  factory HealthDiary.fromJson(Map<String, dynamic> json) {
    return HealthDiary(
      date: json['date'],
      title: json['title'],
      content: json['content'],
      tags: List<String>.from(json['tags']),
      imageUrls:
          json['imageUrls'] != null
              ? List<String>.from(json['imageUrls'])
              : null,
    );
  }
}

// 健康分析报告
class HealthAnalysis {
  final String analysisDate;
  final String overallStatus;
  final int healthScore; // 0-100分
  final List<HealthInsight> insights;
  final List<HealthRecommendation> recommendations;
  final List<HealthRisk> risks;
  final bool isPremiumReport;

  HealthAnalysis({
    required this.analysisDate,
    required this.overallStatus,
    required this.healthScore,
    required this.insights,
    required this.recommendations,
    required this.risks,
    required this.isPremiumReport,
  });

  factory HealthAnalysis.fromJson(Map<String, dynamic> json) {
    return HealthAnalysis(
      analysisDate: json['analysisDate'],
      overallStatus: json['overallStatus'],
      healthScore: json['healthScore'],
      insights:
          (json['insights'] as List)
              .map((i) => HealthInsight.fromJson(i))
              .toList(),
      recommendations:
          (json['recommendations'] as List)
              .map((r) => HealthRecommendation.fromJson(r))
              .toList(),
      risks:
          (json['risks'] as List).map((r) => HealthRisk.fromJson(r)).toList(),
      isPremiumReport: json['isPremiumReport'],
    );
  }
}

// 健康洞察
class HealthInsight {
  final String category;
  final String description;
  final String trendDirection; // 上升、持平、下降

  HealthInsight({
    required this.category,
    required this.description,
    required this.trendDirection,
  });

  factory HealthInsight.fromJson(Map<String, dynamic> json) {
    return HealthInsight(
      category: json['category'],
      description: json['description'],
      trendDirection: json['trendDirection'],
    );
  }
}

// 健康建议
class HealthRecommendation {
  final String category;
  final String recommendation;
  final String urgency; // 低、中、高
  final bool isPremiumOnly;

  HealthRecommendation({
    required this.category,
    required this.recommendation,
    required this.urgency,
    required this.isPremiumOnly,
  });

  factory HealthRecommendation.fromJson(Map<String, dynamic> json) {
    return HealthRecommendation(
      category: json['category'],
      recommendation: json['recommendation'],
      urgency: json['urgency'],
      isPremiumOnly: json['isPremiumOnly'],
    );
  }
}

// 健康风险
class HealthRisk {
  final String riskFactor;
  final String description;
  final String severity; // 低、中、高
  final List<String> preventiveMeasures;
  final bool isPremiumOnly;

  HealthRisk({
    required this.riskFactor,
    required this.description,
    required this.severity,
    required this.preventiveMeasures,
    required this.isPremiumOnly,
  });

  factory HealthRisk.fromJson(Map<String, dynamic> json) {
    return HealthRisk(
      riskFactor: json['riskFactor'],
      description: json['description'],
      severity: json['severity'],
      preventiveMeasures: List<String>.from(json['preventiveMeasures']),
      isPremiumOnly: json['isPremiumOnly'],
    );
  }
}

// 健康目标
class HealthGoal {
  final String id;
  final String category; // 体重、运动、饮食等
  final String description;
  final String startDate;
  final String targetDate;
  final String status; // 进行中、已完成、已放弃
  final double progress; // 0-100%
  final List<String> milestones;

  HealthGoal({
    required this.id,
    required this.category,
    required this.description,
    required this.startDate,
    required this.targetDate,
    required this.status,
    required this.progress,
    required this.milestones,
  });

  factory HealthGoal.fromJson(Map<String, dynamic> json) {
    return HealthGoal(
      id: json['id'],
      category: json['category'],
      description: json['description'],
      startDate: json['startDate'],
      targetDate: json['targetDate'],
      status: json['status'],
      progress: json['progress'].toDouble(),
      milestones: List<String>.from(json['milestones']),
    );
  }
}
