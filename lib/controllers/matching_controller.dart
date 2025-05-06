import 'dart:convert';
import 'package:flutter/material.dart'; // 添加这一行导入 RangeValues 类
import 'package:flutter/services.dart' show rootBundle;
import '../models/partner/matching_profile.dart';

class MatchingController {
  // 单例模式
  static final MatchingController _instance = MatchingController._internal();

  factory MatchingController() {
    return _instance;
  }

  MatchingController._internal();

  // 缓存数据
  List<MatchingProfile>? _allProfiles;

  // 获取匹配的用户资料
  Future<List<MatchingProfile>> getMatchingProfiles(
    Map<String, dynamic> filters,
  ) async {
    try {
      // 如果本地缓存为空，从JSON文件加载所有资料
      if (_allProfiles == null) {
        await _loadAllProfiles();
      }

      if (_allProfiles == null) {
        return [];
      }

      // 根据过滤条件筛选匹配资料
      return _filterProfiles(_allProfiles!, filters);
    } catch (e) {
      print('加载匹配资料错误: $e');
      return [];
    }
  }

  // 加载所有匹配资料
  Future<void> _loadAllProfiles() async {
    try {
      // 模拟API调用，从JSON文件加载数据
      await Future.delayed(Duration(milliseconds: 800));
      final String jsonString = await rootBundle.loadString(
        'assets/data/partner/matching_profiles.json',
      );
      final jsonData = json.decode(jsonString) as List;
      _allProfiles =
          jsonData.map((item) => MatchingProfile.fromJson(item)).toList();
    } catch (e) {
      print('加载匹配资料错误: $e');
      _allProfiles = [];
    }
  }

  // 根据过滤条件筛选资料
  List<MatchingProfile> _filterProfiles(
    List<MatchingProfile> profiles,
    Map<String, dynamic> filters,
  ) {
    final distance = filters['distance'] as double? ?? 50.0;
    final ageRange = filters['ageRange'] as RangeValues? ?? RangeValues(18, 60);
    final gender = filters['gender'] as String? ?? 'all';
    final interests = filters['interests'] as List<String>? ?? [];

    // 筛选逻辑
    return profiles.where((profile) {
      // 距离筛选
      if (profile.distance > distance) {
        return false;
      }

      // 年龄筛选
      if (profile.age < ageRange.start.toInt() ||
          profile.age > ageRange.end.toInt()) {
        return false;
      }

      // 兴趣筛选
      if (interests.isNotEmpty &&
          !profile.interests.any((interest) => interests.contains(interest))) {
        return false;
      }

      return true;
    }).toList();
  }

  // 清除缓存
  void clearCache() {
    _allProfiles = null;
  }
}
