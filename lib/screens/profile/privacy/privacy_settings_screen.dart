import 'package:flutter/material.dart';
import '../../../controllers/privacy_controller.dart';
import '../../../models/privacy/privacy_settings.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  _PrivacySettingsScreenState createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final PrivacyController _privacyController = PrivacyController();
  bool _isLoading = true;
  late PrivacySettings _settings;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    setState(() => _isLoading = true);
    try {
      _settings = await _privacyController.getPrivacySettings();
    } catch (e) {
      print('加载隐私设置错误: $e');
      _settings = PrivacySettings(
        basicInfo: VisibilitySettings(visibility: 'public'),
        sensitiveInfo: VisibilitySettings(visibility: 'private'),
        socialInfo: VisibilitySettings(visibility: 'friends'),
        dataAuthorization: AuthorizationSettings(),
        mappingSettings: MappingSettings(),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePrivacySettings() async {
    setState(() => _isLoading = true);
    try {
      await _privacyController.updatePrivacySettings(_settings);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('隐私设置已保存')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存设置失败: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('隐私设置'),
        actions: [
          _isLoading
              ? Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
              : IconButton(
                icon: Icon(Icons.save),
                onPressed: _savePrivacySettings,
              ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoVisibilitySection('基本信息可见性', _settings.basicInfo),
                    SizedBox(height: 24),
                    _buildInfoVisibilitySection(
                      '敏感信息可见性',
                      _settings.sensitiveInfo,
                    ),
                    SizedBox(height: 24),
                    _buildInfoVisibilitySection(
                      '社交信息可见性',
                      _settings.socialInfo,
                    ),
                    SizedBox(height: 24),
                    _buildDataAuthorizationSection(),
                    SizedBox(height: 24),
                    _buildMappingSettingsSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoVisibilitySection(
    String title,
    VisibilitySettings settings,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildVisibilitySelector(title, settings),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('允许映射这些信息'),
              subtitle: Text('允许他人在虚拟网络中映射这些信息'),
              value: settings.allowMapping,
              onChanged: (value) {
                setState(() {
                  if (title == '基本信息可见性') {
                    _settings = _settings.copyWith(
                      basicInfo: _settings.basicInfo.copyWith(
                        allowMapping: value,
                      ),
                    );
                  } else if (title == '敏感信息可见性') {
                    _settings = _settings.copyWith(
                      sensitiveInfo: _settings.sensitiveInfo.copyWith(
                        allowMapping: value,
                      ),
                    );
                  } else if (title == '社交信息可见性') {
                    _settings = _settings.copyWith(
                      socialInfo: _settings.socialInfo.copyWith(
                        allowMapping: value,
                      ),
                    );
                  }
                });
              },
            ),
            if (settings.visibility == 'selected')
              TextButton(
                onPressed: () {
                  // 导航到选择用户页面
                  Navigator.pushNamed(context, '/privacy/select-users');
                },
                child: Text('选择可见用户'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilitySelector(
    String settingTitle,
    VisibilitySettings settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('谁可以看到这些信息?'),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildVisibilityOption(
              settingTitle,
              settings,
              'public',
              '所有人',
              Icons.public,
            ),
            _buildVisibilityOption(
              settingTitle,
              settings,
              'friends',
              '朋友',
              Icons.people,
            ),
            _buildVisibilityOption(
              settingTitle,
              settings,
              'selected',
              '指定用户',
              Icons.person_add,
            ),
            _buildVisibilityOption(
              settingTitle,
              settings,
              'private',
              '仅自己',
              Icons.lock,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVisibilityOption(
    String settingTitle,
    VisibilitySettings settings,
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = settings.visibility == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (settingTitle == '基本信息可见性') {
            _settings = _settings.copyWith(
              basicInfo: _settings.basicInfo.copyWith(visibility: value),
            );
          } else if (settingTitle == '敏感信息可见性') {
            _settings = _settings.copyWith(
              sensitiveInfo: _settings.sensitiveInfo.copyWith(
                visibility: value,
              ),
            );
          } else if (settingTitle == '社交信息可见性') {
            _settings = _settings.copyWith(
              socialInfo: _settings.socialInfo.copyWith(visibility: value),
            );
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataAuthorizationSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '数据授权设置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('自动批准基础数据请求'),
              subtitle: Text('自动接受对非敏感数据的访问请求'),
              value: _settings.dataAuthorization.autoApproveBasicData,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(
                    dataAuthorization: _settings.dataAuthorization.copyWith(
                      autoApproveBasicData: value,
                    ),
                  );
                });
              },
            ),
            SwitchListTile(
              title: Text('自动批准敏感数据请求'),
              subtitle: Text('自动接受对敏感数据的访问请求'),
              value: _settings.dataAuthorization.autoApproveSensitiveData,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(
                    dataAuthorization: _settings.dataAuthorization.copyWith(
                      autoApproveSensitiveData: value,
                    ),
                  );
                });
              },
            ),
            SwitchListTile(
              title: Text('数据访问通知'),
              subtitle: Text('当有人访问您的数据时接收通知'),
              value: _settings.dataAuthorization.notifyOnDataAccess,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(
                    dataAuthorization: _settings.dataAuthorization.copyWith(
                      notifyOnDataAccess: value,
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMappingSettingsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '映射设置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('允许任何人映射'),
              subtitle: Text('允许任何人将您映射到他们的虚拟网络中'),
              value: _settings.mappingSettings.allowMappingByAnyone,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(
                    mappingSettings: _settings.mappingSettings.copyWith(
                      allowMappingByAnyone: value,
                    ),
                  );
                });
              },
            ),
            SwitchListTile(
              title: Text('映射通知'),
              subtitle: Text('当有人将您映射到他们的网络时接收通知'),
              value: _settings.mappingSettings.notifyOnMapping,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(
                    mappingSettings: _settings.mappingSettings.copyWith(
                      notifyOnMapping: value,
                    ),
                  );
                });
              },
            ),
            ListTile(
              title: Text('被屏蔽的用户'),
              subtitle: Text('管理不允许将您映射到他们网络的用户'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // 导航到屏蔽用户管理页面
                Navigator.pushNamed(context, '/privacy/blocked-users');
              },
            ),
          ],
        ),
      ),
    );
  }
}
