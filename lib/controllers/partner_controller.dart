import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/partner/partner_group.dart';

class PartnerController {
  // 获取我的搭子组
  Future<List<PartnerGroup>> getMyPartnerGroups() async {
    // 模拟网络请求延迟
    await Future.delayed(Duration(milliseconds: 800));

    try {
      // 从本地JSON文件加载数据
      final String jsonString = await rootBundle.loadString(
        'assets/data/partner/my_partners.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.map((json) => PartnerGroup.fromJson(json)).toList();
    } catch (e) {
      print('加载我的搭子数据错误: $e');
      // 返回空列表或抛出异常
      return [];
    }
  }

  // 获取推荐的搭子组
  Future<List<PartnerGroup>> getRecommendedPartnerGroups() async {
    // 模拟网络请求延迟
    await Future.delayed(Duration(milliseconds: 800));

    try {
      // 从本地JSON文件加载数据
      final String jsonString = await rootBundle.loadString(
        'assets/data/partner/recommended_partners.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.map((json) => PartnerGroup.fromJson(json)).toList();
    } catch (e) {
      print('加载推荐搭子数据错误: $e');
      // 返回空列表或抛出异常
      return [];
    }
  }
}
