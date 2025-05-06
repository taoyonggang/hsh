import 'package:flutter/material.dart';
import '../../../controllers/partner_controller.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/tag_selector_widget.dart';

class CreatePartnerPage extends StatefulWidget {
  const CreatePartnerPage({super.key});

  @override
  _CreatePartnerPageState createState() => _CreatePartnerPageState();
}

class _CreatePartnerPageState extends State<CreatePartnerPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = PartnerController();

  String _name = '';
  String _description = '';
  String _coverImageUrl = '';
  List<String> _selectedTags = [];
  bool _isPrivate = false;
  bool _requiresApproval = true;
  bool _isLoading = false;

  // 预设标签列表
  final List<String> _availableTags = [
    '旅行',
    '美食',
    '读书',
    '户外',
    '运动',
    '游戏',
    '音乐',
    '电影',
    '摄影',
    '手工',
    '投资',
    '科技',
    '养生',
    '宠物',
    '亲子',
    '学习',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('创建搭子'),
        actions: [
          _isLoading
              ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : TextButton(
                onPressed: _createPartner,
                child: Text('创建', style: TextStyle(color: Colors.white)),
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
                      _buildHeaderTitle('基本信息'),
                      SizedBox(height: 16),
                      _buildNameField(),
                      SizedBox(height: 16),
                      _buildDescriptionField(),
                      SizedBox(height: 24),
                      _buildHeaderTitle('搭子封面'),
                      SizedBox(height: 16),
                      ImagePickerWidget(
                        initialImageUrl: _coverImageUrl,
                        onImageSelected: (String url) {
                          setState(() {
                            _coverImageUrl = url;
                          });
                        },
                      ),
                      SizedBox(height: 24),
                      _buildHeaderTitle('搭子标签'),
                      SizedBox(height: 4),
                      Text(
                        '选择合适的标签，让更多人发现你的搭子',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      TagSelectorWidget(
                        availableTags: _availableTags,
                        selectedTags: _selectedTags,
                        maxSelection: 5,
                        onTagsChanged: (List<String> tags) {
                          setState(() {
                            _selectedTags = tags;
                          });
                        },
                      ),
                      SizedBox(height: 24),
                      _buildHeaderTitle('权限设置'),
                      SizedBox(height: 16),
                      _buildPrivacySettings(),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildHeaderTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: '搭子名称',
        hintText: '输入搭子名称，最多15个字',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      maxLength: 15,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入搭子名称';
        }
        return null;
      },
      onSaved: (value) {
        _name = value?.trim() ?? '';
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: '搭子介绍',
        hintText: '介绍一下你的搭子，吸引更多志同道合的朋友',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        alignLabelWithHint: true,
      ),
      maxLength: 200,
      maxLines: 5,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入搭子介绍';
        }
        return null;
      },
      onSaved: (value) {
        _description = value?.trim() ?? '';
      },
    );
  }

  Widget _buildPrivacySettings() {
    return Column(
      children: [
        SwitchListTile(
          title: Text('私密搭子'),
          subtitle: Text('仅被邀请的用户可以看到和加入'),
          value: _isPrivate,
          activeColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onChanged: (value) {
            setState(() {
              _isPrivate = value;
              if (!_isPrivate) {
                _requiresApproval = true; // 公开搭子默认需要审核
              }
            });
          },
        ),
        SwitchListTile(
          title: Text('需要审核'),
          subtitle: Text('新成员加入搭子需要管理员审核'),
          value: _requiresApproval,
          activeColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onChanged:
              _isPrivate
                  ? null
                  : (value) {
                    setState(() {
                      _requiresApproval = value;
                    });
                  },
        ),
      ],
    );
  }

  Future<void> _createPartner() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_coverImageUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请上传搭子封面')));
      return;
    }

    if (_selectedTags.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请至少选择一个标签')));
      return;
    }

    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _controller.createPartnerGroup(
        name: _name,
        description: _description,
        coverImageUrl: _coverImageUrl,
        tags: _selectedTags,
        isPrivate: _isPrivate,
        requiresApproval: _requiresApproval,
      );

      if (success) {
        Navigator.of(context).pop(true); // 返回并刷新
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('搭子创建成功')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('创建失败，请稍后重试')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('创建失败: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
