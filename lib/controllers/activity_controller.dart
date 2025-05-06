import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/partner/partner_activity.dart';
import '../models/user/user_brief.dart';

class ActivityController {
  // 单例模式
  static final ActivityController _instance = ActivityController._internal();

  factory ActivityController() {
    return _instance;
  }

  ActivityController._internal();

  // 活动列表和详情缓存
  List<PartnerActivity> _activities = [];
  Map<String, PartnerActivity> _activityDetails = {};
  Map<String, bool> _userJoinedActivities = {};

  List<PartnerActivity> _myActivities = [];
  List<PartnerActivity> _recommendedActivities = [];

  // 获取我的活动
  Future<List<PartnerActivity>> getMyActivities() async {
    // 如果没有缓存数据，先加载数据
    if (_activities.isEmpty) {
      await _loadActivities();
    }

    // 如果我的活动为空，根据用户参与情况筛选
    if (_myActivities.isEmpty) {
      _myActivities =
          _activities
              .where(
                (activity) =>
                    activity.hasSignedUp ||
                    _userJoinedActivities[activity.id] == true,
              )
              .toList();

      // 如果依然为空，提供至少一个示例数据
      if (_myActivities.isEmpty) {
        _myActivities = [
          PartnerActivity(
            id: 'example1',
            title: '每周健步走',
            description: '每周一次的健步走活动，增强体质',
            time: '每周六 08:00',
            startTime: '2025-05-04 08:00:00',
            endTime: '2025-05-04 10:00:00',
            location: '城市公园',
            hasSignedUp: true,
            participantCount: 8,
            maxParticipants: 20,
            participantsList: [
              UserBrief(
                id: 'current_user_id',
                name: 'taoyonggang',
                avatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
              ),
            ],
          ),
        ];
      }
    }

    return _myActivities;
  }

  // 获取推荐活动
  Future<List<PartnerActivity>> getRecommendedActivities() async {
    // 如果没有缓存数据，先加载数据
    if (_activities.isEmpty) {
      await _loadActivities();
    }

    // 如果推荐活动为空，从所有活动中筛选
    if (_recommendedActivities.isEmpty) {
      _recommendedActivities =
          _activities
              .where(
                (activity) =>
                    !activity.hasSignedUp &&
                    !activity.isFull &&
                    _userJoinedActivities[activity.id] != true,
              )
              .take(3)
              .toList();

      // 如果依然为空，提供至少一个示例数据
      if (_recommendedActivities.isEmpty) {
        _recommendedActivities = [
          PartnerActivity(
            id: 'example2',
            title: '周末户外徒步',
            description: '一起徒步，享受大自然',
            time: '2025-05-11 09:00',
            startTime: '2025-05-11 09:00:00',
            endTime: '2025-05-11 16:00:00',
            location: '城郊森林公园',
            hasSignedUp: false,
            participantCount: 5,
            maxParticipants: 20,
            participantsList: [],
          ),
        ];
      }
    }

    return _recommendedActivities;
  }

  // 加载活动数据
  Future<void> _loadActivities() async {
    try {
      // 模拟网络延迟
      await Future.delayed(Duration(milliseconds: 800));

      try {
        // 尝试从本地 JSON 文件加载活动数据
        final jsonString = await rootBundle.loadString(
          'assets/data/partner/activities.json',
        );
        final jsonList = json.decode(jsonString) as List;

        _activities =
            jsonList.map((json) => PartnerActivity.fromJson(json)).toList();
      } catch (e) {
        print('无法从JSON文件加载活动数据: $e，将使用默认数据');
        // 如果JSON加载失败，使用硬编码的默认数据
        _activities = _getDefaultActivities();
      }

      // 随机设置一些已参加的活动
      if (_activities.isNotEmpty) {
        _userJoinedActivities[_activities.first.id] = true;
        _activityDetails[_activities.first.id] = _activities.first.copyWith(
          hasSignedUp: true,
        );
      }
    } catch (e) {
      print('加载活动数据错误: $e');
      _activities = _getDefaultActivities();
    }
  }

  // 获取默认活动数据
  List<PartnerActivity> _getDefaultActivities() {
    return [
      PartnerActivity(
        id: 'default1',
        title: '周末登山活动',
        description: '一起爬山，感受大自然',
        time: '2025-05-04 09:00',
        startTime: '2025-05-04 09:00:00',
        endTime: '2025-05-04 16:00:00',
        location: '香山公园北门',
        coverImageUrl: null,
        isOnline: false,
        fee: 0.0,
        participantCount: 8,
        maxParticipants: 20,
        isSignUpRequired: true,
        type: '户外运动',
        tags: ['登山', '户外', '休闲'],
        participantsList: [],
      ),
      PartnerActivity(
        id: 'default2',
        title: '读书分享会',
        description: '分享阅读心得，推荐好书',
        time: '2025-05-08 19:30',
        startTime: '2025-05-08 19:30:00',
        endTime: '2025-05-08 21:30:00',
        location: '城市图书馆',
        coverImageUrl: null,
        isOnline: false,
        fee: 0.0,
        participantCount: 6,
        maxParticipants: 15,
        isSignUpRequired: true,
        hasSignedUp: false,
        type: '读书会',
        participantsList: [],
      ),
    ];
  }

  // 参加活动
  Future<bool> joinActivity(String activityId) async {
    // 找到对应的活动
    final targetActivity = _activities.firstWhere(
      (activity) => activity.id == activityId,
      orElse:
          () => PartnerActivity(
            id: '',
            title: '',
            description: '',
            time: '',
            location: '',
          ),
    );

    if (targetActivity.id.isEmpty) {
      return false;
    }

    final newParticipantCount = targetActivity.participantCount + 1;
    final isFull = newParticipantCount >= targetActivity.maxParticipants;

    // 更新活动信息
    final updatedActivity = targetActivity.copyWith(
      participantCount: newParticipantCount,
      isFull: isFull,
      hasSignedUp: true,
      participantsList: [
        ...targetActivity.participantsList,
        UserBrief(
          id: 'current_user_id',
          name: 'taoyonggang',
          avatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
        ),
      ],
    );

    // 更新活动列表和缓存
    final activityIndex = _activities.indexWhere(
      (activity) => activity.id == activityId,
    );
    if (activityIndex != -1) {
      _activities[activityIndex] = updatedActivity;
    }

    // 更新详情缓存
    _activityDetails[activityId] = updatedActivity;

    // 更新我的活动列表
    _myActivities.add(updatedActivity);

    // 从推荐列表中移除
    _recommendedActivities.removeWhere((activity) => activity.id == activityId);

    // 更新用户参与记录
    _userJoinedActivities[activityId] = true;

    return true;
  }

  // 取消参加活动
  Future<bool> cancelJoinActivity(String activityId) async {
    // 找到对应的活动
    final targetActivity = _activities.firstWhere(
      (activity) => activity.id == activityId,
      orElse:
          () => PartnerActivity(
            id: '',
            title: '',
            description: '',
            time: '',
            location: '',
          ),
    );

    if (targetActivity.id.isEmpty) {
      return false;
    }

    final newParticipantCount = targetActivity.participantCount - 1;

    // 更新活动信息
    final updatedActivity = targetActivity.copyWith(
      participantCount: newParticipantCount < 0 ? 0 : newParticipantCount,
      isFull: false,
      hasSignedUp: false,
      participantsList:
          targetActivity.participantsList
              .where((p) => p.id != 'current_user_id')
              .toList(),
    );

    // 更新活动列表和缓存
    final activityIndex = _activities.indexWhere(
      (activity) => activity.id == activityId,
    );
    if (activityIndex != -1) {
      _activities[activityIndex] = updatedActivity;
    }

    // 更新详情缓存
    _activityDetails[activityId] = updatedActivity;

    // 从我的活动列表中移除
    _myActivities.removeWhere((activity) => activity.id == activityId);

    // 可能添加到推荐列表
    if (_recommendedActivities.length < 3 && !updatedActivity.isFull) {
      _recommendedActivities.add(updatedActivity);
    }

    // 更新用户参与记录
    _userJoinedActivities[activityId] = false;

    return true;
  }

  // 清除所有缓存数据
  void clearCache() {
    _activities = [];
    _activityDetails = {};
    _userJoinedActivities = {};
    _myActivities = [];
    _recommendedActivities = [];
  }
}
