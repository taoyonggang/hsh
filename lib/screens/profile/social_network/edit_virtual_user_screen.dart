import 'package:flutter/material.dart';
import '../../../controllers/network_controller.dart';
import '../../../models/relationship/virtual_user.dart';
import '../../../app/routes.dart';

class EditVirtualUserScreen extends StatefulWidget {
  final String userId;
  final bool viewOnly;

  const EditVirtualUserScreen({
    super.key,
    required this.userId,
    this.viewOnly = false,
  });

  @override
  _EditVirtualUserScreenState createState() => _EditVirtualUserScreenState();
}

class _EditVirtualUserScreenState extends State<EditVirtualUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final NetworkController _networkController = NetworkController();

  final _nameController = TextEditingController();
  String _selectedType = 'friend';
  final _tagsController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  VirtualUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      // 在实际应用中，这里会根据用户ID加载用户数据
      await Future.delayed(Duration(milliseconds: 800));

      // 模拟从服务器获取用户数据
      _user = VirtualUser(
        id: widget.userId,
        name: "李明", // 假设数据
        relationshipType: "friend",
        isMapped: true,
        mappedUserId: "user456",
        tags: ["好友", "大学同学", "篮球"],
      );

      setState(() {
        _nameController.text = _user?.name ?? "";
        _selectedType = _user?.relationshipType ?? "friend";
        _tagsController.text = _user?.tags.join(", ") ?? "";
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载用户数据失败: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        final List<String> tags =
            _tagsController.text
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList();

        if (_user != null) {
          final updatedUser = VirtualUser(
            id: _user!.id,
            name: _nameController.text,
            relationshipType: _selectedType,
            isMapped: _user!.isMapped,
            mappedUserId: _user!.mappedUserId,
            tags: tags,
            avatarUrl: _user!.avatarUrl,
            attributes: _user!.attributes,
          );

          await _networkController.updateVirtualUser(updatedUser);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('虚拟用户更新成功')));

          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('更新虚拟用户失败: $e')));
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('删除虚拟用户'),
            content: Text('确定要删除该虚拟用户吗？相关的所有关系连接也会被删除。'),
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
      try {
        setState(() => _isSaving = true);

        await _networkController.deleteVirtualUser(widget.userId);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('虚拟用户已删除')));

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除虚拟用户失败: $e')));
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.viewOnly ? '用户详情' : '编辑虚拟用户'),
        actions: [
          if (!widget.viewOnly && !_isLoading)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _isSaving ? null : _deleteUser,
              color: Colors.red,
            ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserHeader(),
                      SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '名称',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: widget.viewOnly,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入名称';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Text('关系类型'),
                      SizedBox(height: 8),
                      widget.viewOnly
                          ? Text(
                            _getRelationshipTypeText(_selectedType),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : _buildRelationshipSelector(),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _tagsController,
                        decoration: InputDecoration(
                          labelText: '标签（用逗号分隔）',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: widget.viewOnly,
                      ),
                      if (_user?.isMapped == true) ...[
                        SizedBox(height: 24),
                        _buildMappingInfo(),
                      ],
                      SizedBox(height: 24),
                      if (!widget.viewOnly)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child:
                                _isSaving
                                    ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    )
                                    : Text('保存'),
                          ),
                        ),
                      if (_user?.isMapped == false && widget.viewOnly) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                Routes.mapUser,
                                arguments: widget.userId,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text('映射到真实用户'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage:
              _user?.avatarUrl != null ? NetworkImage(_user!.avatarUrl!) : null,
          child: _user?.avatarUrl == null ? Icon(Icons.person, size: 30) : null,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _user?.name ?? "",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                _getRelationshipTypeText(_user?.relationshipType ?? ""),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        if (_user?.isMapped == true) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '已映射',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
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

  Widget _buildRelationshipSelector() {
    return Column(
      children: [
        Row(
          children: [
            _buildRelationshipOption('family', '家人'),
            SizedBox(width: 8),
            _buildRelationshipOption('friend', '朋友'),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            _buildRelationshipOption('colleague', '同事'),
            SizedBox(width: 8),
            _buildRelationshipOption('partner', '搭子'),
          ],
        ),
        SizedBox(height: 8),
        Row(children: [_buildRelationshipOption('other', '其他')]),
      ],
    );
  }

  Widget _buildRelationshipOption(String value, String label) {
    final isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedType = value);
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

  Widget _buildMappingInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '映射信息',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.link, size: 16),
                SizedBox(width: 8),
                Text('已映射到真实用户'),
              ],
            ),
            SizedBox(height: 4),
            Text(
              '映射到真实用户后，您可以访问该用户共享的数据，并在真实网络中查看互动情况。',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (!widget.viewOnly) ...[
              SizedBox(height: 8),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.mapUser,
                    arguments: widget.userId,
                  );
                },
                child: Text(
                  '修改映射',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
