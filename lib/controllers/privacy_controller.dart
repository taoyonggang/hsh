import '../models/privacy/privacy_settings.dart';
import '../models/privacy/mapping_record.dart';
import '../models/privacy/authorization_record.dart';
import '../models/user/user_brief.dart';
import 'base_controller.dart';

class PrivacyController extends BaseController {
  // 单例模式
  static final PrivacyController _instance = PrivacyController._internal();
  factory PrivacyController() => _instance;
  PrivacyController._internal();

  Future<PrivacySettings> getPrivacySettings() async {
    try {
      final settingsData = await loadUserData('privacy_settings.json');
      return PrivacySettings.fromJson(settingsData);
    } catch (e) {
      print('获取隐私设置错误: $e');
      throw Exception('获取隐私设置失败');
    }
  }

  Future<void> updatePrivacySettings(PrivacySettings settings) async {
    try {
      // 模拟API请求延迟
      await Future.delayed(Duration(milliseconds: 1000));

      // 在实际应用中，这里应该调用API保存数据
      print('更新隐私设置: ${settings.toJson()}');

      // 成功返回
      return;
    } catch (e) {
      print('更新隐私设置错误: $e');
      throw Exception('更新隐私设置失败');
    }
  }

  Future<List<MappingRecord>> getMappingRecords() async {
    try {
      final recordsData = await loadUserData('mapping_records.json');
      return (recordsData as List)
          .map((data) => MappingRecord.fromJson(data))
          .toList();
    } catch (e) {
      // 如果文件不存在，返回模拟数据
      print('获取映射记录错误: $e');

      // 返回模拟数据
      return [
        MappingRecord(
          id: 'map001',
          mapper: UserBrief(
            id: 'user234',
            name: '张伟',
            avatarUrl: 'https://randomuser.me/api/portraits/men/67.jpg',
          ),
          isApproved: false,
          createdDate: DateTime.utc(2025, 4, 25),
          virtualUserName: '张伟的好友',
        ),
        MappingRecord(
          id: 'map002',
          mapper: UserBrief(
            id: 'user456',
            name: '李明',
            avatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
          ),
          isApproved: true,
          createdDate: DateTime.utc(2025, 4, 20),
          approvalDate: DateTime.utc(2025, 4, 21),
          virtualUserName: '大学同学',
        ),
      ];
    }
  }

  Future<List<AuthorizationRecord>> getAuthorizationRecords() async {
    try {
      final recordsData = await loadUserData('authorization_records.json');
      return (recordsData as List)
          .map((data) => AuthorizationRecord.fromJson(data))
          .toList();
    } catch (e) {
      // 如果文件不存在，返回模拟数据
      print('获取授权记录错误: $e');

      // 返回模拟数据
      return [
        AuthorizationRecord(
          id: 'auth001',
          requestor: UserBrief(
            id: 'user456',
            name: '李明',
            avatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
          ),
          status: 'pending',
          requestDate: DateTime.utc(
            2025,
            4,
            29,
            1,
            7,
            11,
          ).subtract(Duration(hours: 2)),
          dataTypes: ['basic_profile', 'activity_history'],
          purpose: '社交圈分析',
        ),
        AuthorizationRecord(
          id: 'auth002',
          requestor: UserBrief(
            id: 'user567',
            name: '陈思',
            avatarUrl: 'https://randomuser.me/api/portraits/women/45.jpg',
          ),
          status: 'approved',
          requestDate: DateTime.utc(2025, 4, 25),
          responseDate: DateTime.utc(2025, 4, 25),
          expiryDate: DateTime.utc(2025, 5, 25),
          dataTypes: ['basic_profile', 'relationship_graph'],
          purpose: '搭子匹配',
        ),
        AuthorizationRecord(
          id: 'auth003',
          requestor: UserBrief(
            id: 'user789',
            name: '王芳',
            avatarUrl: 'https://randomuser.me/api/portraits/women/22.jpg',
          ),
          status: 'denied',
          requestDate: DateTime.utc(2025, 4, 23),
          responseDate: DateTime.utc(2025, 4, 24),
          dataTypes: [
            'basic_profile',
            'location_history',
            'sensitive_health_data',
          ],
          purpose: '健康分析',
        ),
      ];
    }
  }

  Future<void> updateMappingRecord(String recordId, bool approved) async {
    try {
      // 模拟API请求延迟
      await Future.delayed(Duration(milliseconds: 1000));

      // 在实际应用中，这里应该调用API更新数据
      print('更新映射记录: $recordId, 批准: $approved');

      // 成功返回
      return;
    } catch (e) {
      print('更新映射记录错误: $e');
      throw Exception('更新映射记录失败');
    }
  }
}
