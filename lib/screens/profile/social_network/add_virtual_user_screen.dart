import 'package:flutter/material.dart';
import '../../../controllers/network_controller.dart';
import '../../../models/relationship/virtual_user.dart';

class AddVirtualUserScreen extends StatefulWidget {
  final String? suggestedUserId;

  const AddVirtualUserScreen({super.key, this.suggestedUserId});

  @override
  _AddVirtualUserScreenState createState() => _AddVirtualUserScreenState();
}

class _AddVirtualUserScreenState extends State<AddVirtualUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final NetworkController _networkController = NetworkController();

  final _nameController = TextEditingController();
  String _selectedType = 'friend';
  final _tagsController = TextEditingController();
  bool _isLoading = false;

  // 预加载建议的用户数据
  bool _isLoadingSuggestion = false;

  @override
  void initState() {
    super.initState();
    if (widget.suggestedUserId != null) {
      _loadSuggestedUser();
    }
  }

  Future<void> _loadSuggestedUser() async {
    setState(() => _isLoadingSuggestion = true);
    try {
      // 在实际应用中，这里会根据建议的用户ID加载用户数据
      await Future.delayed(Duration(milliseconds: 800));

      // 模拟从服务器获取用户数据
      setState(() {
        _nameController.text = "建议的用户";
        _selectedType = 'friend';
        _tagsController.text = "推荐,朋友";
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载建议用户数据失败: $e')));
    } finally {
      setState(() => _isLoadingSuggestion = false);
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
      setState(() => _isLoading = true);

      try {
        final List<String> tags =
            _tagsController.text
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList();

        final newUser = VirtualUser(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          relationshipType: _selectedType,
          tags: tags,
        );

        await _networkController.addVirtualUser(newUser);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('虚拟用户添加成功')));

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('添加虚拟用户失败: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('添加虚拟用户')),
      body:
          _isLoadingSuggestion
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.suggestedUserId != null)
                        Card(
                          color: Colors.green.shade50,
                          margin: EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.green),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    '根据您的社交活动，我们建议您添加此用户到虚拟网络中',
                                    style: TextStyle(
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '名称 *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入名称';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Text('关系类型 *'),
                      SizedBox(height: 8),
                      _buildRelationshipSelector(),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _tagsController,
                        decoration: InputDecoration(
                          labelText: '标签（用逗号分隔）',
                          border: OutlineInputBorder(),
                          hintText: '例如: 朋友,篮球,大学',
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child:
                              _isLoading
                                  ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  )
                                  : Text('保存'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
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
}
