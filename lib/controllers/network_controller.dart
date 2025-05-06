import '../models/relationship/relationship_network.dart';
import '../models/relationship/network_comparison.dart';
import '../models/relationship/virtual_user.dart';
import 'base_controller.dart';

class NetworkController extends BaseController {
  // 单例模式
  static final NetworkController _instance = NetworkController._internal();
  factory NetworkController() => _instance;
  NetworkController._internal();

  Future<RelationshipNetwork> getRealNetwork() async {
    try {
      final networkData = await loadUserData('real_network.json');
      return RelationshipNetwork.fromJson(networkData);
    } catch (e) {
      print('获取真实网络错误: $e');
      throw Exception('获取真实网络失败');
    }
  }

  Future<RelationshipNetwork> getVirtualNetwork() async {
    try {
      final networkData = await loadUserData('virtual_network.json');
      return RelationshipNetwork.fromJson(networkData);
    } catch (e) {
      print('获取虚拟网络错误: $e');
      throw Exception('获取虚拟网络失败');
    }
  }

  Future<NetworkComparison> compareNetworks() async {
    try {
      final comparisonData = await loadUserData('network_comparison.json');
      return NetworkComparison.fromJson(comparisonData);
    } catch (e) {
      print('获取网络对比数据错误: $e');
      throw Exception('获取网络对比数据失败');
    }
  }

  Future<void> addVirtualUser(VirtualUser user) async {
    try {
      // 模拟API请求延迟
      await Future.delayed(Duration(milliseconds: 1000));

      // 在实际应用中，这里应该调用API保存数据
      print('添加虚拟用户: ${user.toJson()}');

      // 成功返回
      return;
    } catch (e) {
      print('添加虚拟用户错误: $e');
      throw Exception('添加虚拟用户失败');
    }
  }

  Future<void> updateVirtualUser(VirtualUser user) async {
    try {
      // 模拟API请求延迟
      await Future.delayed(Duration(milliseconds: 1000));

      // 在实际应用中，这里应该调用API保存数据
      print('更新虚拟用户: ${user.toJson()}');

      // 成功返回
      return;
    } catch (e) {
      print('更新虚拟用户错误: $e');
      throw Exception('更新虚拟用户失败');
    }
  }

  Future<void> deleteVirtualUser(String userId) async {
    try {
      // 模拟API请求延迟
      await Future.delayed(Duration(milliseconds: 1000));

      // 在实际应用中，这里应该调用API删除数据
      print('删除虚拟用户: $userId');

      // 成功返回
      return;
    } catch (e) {
      print('删除虚拟用户错误: $e');
      throw Exception('删除虚拟用户失败');
    }
  }
}
