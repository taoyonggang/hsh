import 'package:flutter/material.dart';
import '../../../controllers/network_controller.dart';
import '../../../models/relationship/relationship_network.dart';
import '../../../models/relationship/virtual_user.dart';

class EditRelationshipScreen extends StatefulWidget {
  final String sourceId;
  final String targetId;

  const EditRelationshipScreen({
    super.key,
    required this.sourceId,
    required this.targetId,
  });

  @override
  _EditRelationshipScreenState createState() => _EditRelationshipScreenState();
}

class _EditRelationshipScreenState extends State<EditRelationshipScreen> {
  final NetworkController _networkController = NetworkController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;
  VirtualUser? _sourceUser;
  VirtualUser? _targetUser;
  String _relationshipType = 'friend';
  double _strength = 0.5;
  NetworkConnection? _connection;

  @override
  void initState() {
    super.initState();
    _loadRelationship();
  }

  Future<void> _loadRelationship() async {
    setState(() => _isLoading = true);
    try {
      // 在实际应用中，这里会从API加载关系和用户数据
      await Future.delayed(Duration(milliseconds: 800));

      // 模拟数据
      final network = await _networkController.getVirtualNetwork();

      // 获取源节点和目标节点
      _sourceUser =
          network.nodes
              .where((node) => node.id == widget.sourceId)
              .map((node) => VirtualUser.fromNetworkNode(node))
              .firstOrNull;

      _targetUser =
          network.nodes
              .where((node) => node.id == widget.targetId)
              .map((node) => VirtualUser.fromNetworkNode(node))
              .firstOrNull;

      // 获取连接
      _connection = network.connections.firstWhere(
        (conn) =>
            conn.sourceId == widget.sourceId &&
            conn.targetId == widget.targetId,
        orElse:
            () => NetworkConnection(
              sourceId: widget.sourceId,
              targetId: widget.targetId,
              relationshipType: 'friend',
              strength: 0.5,
            ),
      );

      setState(() {
        _relationshipType = _connection?.relationshipType ?? 'friend';
        _strength = _connection?.strength ?? 0.5;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载数据失败: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRelationship() async {
    setState(() => _isSaving = true);

    try {
      // 在实际应用中，这里会调用API更新关系
      await Future.delayed(Duration(milliseconds: 1000));

      if (_connection != null) {
        final updatedConnection = NetworkConnection(
          sourceId: _connection!.sourceId,
          targetId: _connection!.targetId,
          relationshipType: _relationshipType,
          strength: _strength,
        );

        // 这里应该调用API保存更新后的关系
        print('更新关系: ${updatedConnection.toJson()}');
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('关系更新成功')));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('更新关系失败: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteRelationship() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('删除关系'),
            content: Text('确定要删除这个关系连接吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('删除'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);

      try {
        // 在实际应用中，这里会调用API删除关系
        await Future.delayed(Duration(milliseconds: 1000));

        // 这里应该调用API删除关系
        print('删除关系: ${widget.sourceId} -> ${widget.targetId}');

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('关系已删除')));

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除关系失败: $e')));
      } finally {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('编辑关系连接'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed:
                (_isLoading || _isSaving || _isDeleting)
                    ? null
                    : _deleteRelationship,
            color: Colors.red,
          ),
        ],
      ),
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
                          _buildUserInfo(user: _sourceUser, label: '源节点'),
                          SizedBox(height: 16),
                          Icon(
                            Icons.arrow_downward,
                            size: 32,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          _buildUserInfo(user: _targetUser, label: '目标节点'),
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

  Widget _buildUserInfo({required VirtualUser? user, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    user?.avatarUrl != null
                        ? NetworkImage(user!.avatarUrl!)
                        : null,
                child: user?.avatarUrl == null ? Icon(Icons.person) : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? '未知用户',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getRelationshipTypeText(user?.relationshipType ?? ''),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
    final bool isWorking = _isLoading || _isSaving || _isDeleting;

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
          onPressed: isWorking ? null : _updateRelationship,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child:
              isWorking
                  ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                  : Text('更新关系'),
        ),
      ),
    );
  }
}
