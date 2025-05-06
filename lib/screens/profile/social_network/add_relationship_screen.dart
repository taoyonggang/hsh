import 'package:flutter/material.dart';
import '../../../controllers/network_controller.dart';
import '../../../models/relationship/relationship_network.dart';
import '../../../models/relationship/virtual_user.dart';

class AddRelationshipScreen extends StatefulWidget {
  const AddRelationshipScreen({super.key});

  @override
  _AddRelationshipScreenState createState() => _AddRelationshipScreenState();
}

class _AddRelationshipScreenState extends State<AddRelationshipScreen> {
  final NetworkController _networkController = NetworkController();
  bool _isLoading = true;
  bool _isSaving = false;
  List<VirtualUser> _users = [];
  VirtualUser? _sourceUser;
  VirtualUser? _targetUser;
  String _relationshipType = 'friend';
  double _strength = 0.5;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      // 在实际应用中，这里会从API加载虚拟用户列表
      await Future.delayed(Duration(milliseconds: 800));

      // 模拟数据
      final network = await _networkController.getVirtualNetwork();
      _users =
          network.nodes
              .map((node) => VirtualUser.fromNetworkNode(node))
              .toList();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载用户数据失败: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveRelationship() async {
    if (_sourceUser == null || _targetUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请选择源节点和目标节点')));
      return;
    }

    if (_sourceUser!.id == _targetUser!.id) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('源节点和目标节点不能是同一个用户')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 在实际应用中，这里会调用API创建关系
      await Future.delayed(Duration(milliseconds: 1000));

      final newConnection = NetworkConnection(
        sourceId: _sourceUser!.id,
        targetId: _targetUser!.id,
        relationshipType: _relationshipType,
        strength: _strength,
      );

      // 这里应该调用API保存关系
      print('保存关系: ${newConnection.toJson()}');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('关系添加成功')));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('添加关系失败: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('添加关系连接')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserSelector(
                            label: '源节点',
                            selectedUser: _sourceUser,
                            onUserSelected: (user) {
                              setState(() => _sourceUser = user);
                            },
                          ),
                          SizedBox(height: 16),
                          Icon(
                            Icons.arrow_downward,
                            size: 32,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          _buildUserSelector(
                            label: '目标节点',
                            selectedUser: _targetUser,
                            onUserSelected: (user) {
                              setState(() => _targetUser = user);
                            },
                          ),
                          SizedBox(height: 24),
                          Text(
                            '关系类型',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildRelationshipTypeSelector(),
                          SizedBox(height: 24),
                          Text(
                            '关系强度: ${(_strength * 10).toStringAsFixed(0)}/10',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Slider(
                            value: _strength,
                            min: 0.1,
                            max: 1.0,
                            divisions: 9,
                            label: (_strength * 10).toStringAsFixed(0),
                            onChanged: (value) {
                              setState(() => _strength = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomAction(),
                ],
              ),
    );
  }

  Widget _buildUserSelector({
    required String label,
    required VirtualUser? selectedUser,
    required Function(VirtualUser) onUserSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () {
            _showUserSelectionDialog(onUserSelected);
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      selectedUser?.avatarUrl != null
                          ? NetworkImage(selectedUser!.avatarUrl!)
                          : null,
                  child:
                      selectedUser?.avatarUrl == null
                          ? Icon(Icons.person)
                          : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    selectedUser?.name ?? '选择用户',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          selectedUser != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showUserSelectionDialog(Function(VirtualUser) onUserSelected) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('选择用户'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                      child: user.avatarUrl == null ? Icon(Icons.person) : null,
                    ),
                    title: Text(user.name),
                    subtitle: Text(
                      _getRelationshipTypeText(user.relationshipType),
                    ),
                    onTap: () {
                      onUserSelected(user);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
            ],
          ),
    );
  }

  String _getRelationshipTypeText(String type) {
    switch (type) {
      case 'family':
        return '家人';
      case 'friend':
        return '朋友';
      case 'colleague':
        return '同事';
      case 'partner':
        return '搭子';
      case 'self':
        return '自己';
      default:
        return '其他';
    }
  }

  Widget _buildRelationshipTypeSelector() {
    return Column(
      children: [
        Row(
          children: [
            _buildRelationshipTypeOption('family', '家人'),
            SizedBox(width: 8),
            _buildRelationshipTypeOption('friend', '朋友'),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            _buildRelationshipTypeOption('colleague', '同事'),
            SizedBox(width: 8),
            _buildRelationshipTypeOption('partner', '搭子'),
          ],
        ),
        SizedBox(height: 8),
        Row(children: [_buildRelationshipTypeOption('other', '其他')]),
      ],
    );
  }

  Widget _buildRelationshipTypeOption(String value, String label) {
    final isSelected = _relationshipType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _relationshipType = value);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveRelationship,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child:
              _isSaving
                  ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                  : Text('添加关系'),
        ),
      ),
    );
  }
}
