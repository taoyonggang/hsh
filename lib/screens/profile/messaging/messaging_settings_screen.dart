import 'package:flutter/material.dart';

class MessagingSettingsScreen extends StatefulWidget {
  const MessagingSettingsScreen({super.key});

  @override
  _MessagingSettingsScreenState createState() =>
      _MessagingSettingsScreenState();
}

class _MessagingSettingsScreenState extends State<MessagingSettingsScreen> {
  bool _isLoading = false;

  // 消息设置
  bool _allowDirectMessages = true;
  bool _allowGroupInvites = true;
  String _messagePrivacy = 'friends'; // all, friends, none
  bool _showReadReceipts = true;
  bool _showTypingIndicator = true;
  bool _autoDownloadMedia = true;

  // 通知设置
  bool _enableNotifications = true;
  bool _notifyDirectMessages = true;
  bool _notifyGroupMessages = true;
  bool _notifyMentions = true;
  bool _notifySystem = true;
  String _notificationSound = 'default';
  bool _vibrate = true;
  String _previewMode = 'full'; // full, sender, none

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      // 模拟保存设置
      await Future.delayed(Duration(milliseconds: 1000));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('设置已保存')));
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
        title: Text('消息设置'),
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
              : IconButton(icon: Icon(Icons.save), onPressed: _saveSettings),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageSettingsSection(),
            SizedBox(height: 16),
            _buildNotificationSettingsSection(),
            SizedBox(height: 16),
            _buildPrivacySettingsSection(),
            SizedBox(height: 16),
            _buildStorageSettingsSection(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageSettingsSection() {
    return _buildSection(
      title: '消息设置',
      children: [
        SwitchListTile(
          title: Text('允许私信'),
          subtitle: Text('允许其他用户向您发送私信'),
          value: _allowDirectMessages,
          onChanged: (value) {
            setState(() => _allowDirectMessages = value);
          },
        ),
        SwitchListTile(
          title: Text('允许群组邀请'),
          subtitle: Text('允许其他用户邀请您加入群组'),
          value: _allowGroupInvites,
          onChanged: (value) {
            setState(() => _allowGroupInvites = value);
          },
        ),
        ListTile(
          title: Text('消息权限'),
          subtitle: Text(_getMessagePrivacyText()),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showMessagePrivacyDialog();
          },
        ),
        SwitchListTile(
          title: Text('显示已读回执'),
          subtitle: Text('显示消息是否已被阅读'),
          value: _showReadReceipts,
          onChanged: (value) {
            setState(() => _showReadReceipts = value);
          },
        ),
        SwitchListTile(
          title: Text('显示输入指示器'),
          subtitle: Text('当您正在输入时向对方显示'),
          value: _showTypingIndicator,
          onChanged: (value) {
            setState(() => _showTypingIndicator = value);
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSettingsSection() {
    return _buildSection(
      title: '通知设置',
      children: [
        SwitchListTile(
          title: Text('启用通知'),
          value: _enableNotifications,
          onChanged: (value) {
            setState(() => _enableNotifications = value);
          },
        ),
        SwitchListTile(
          title: Text('私信通知'),
          subtitle: Text('接收私信通知'),
          value: _notifyDirectMessages,
          onChanged:
              _enableNotifications
                  ? (value) {
                    setState(() => _notifyDirectMessages = value);
                  }
                  : null,
        ),
        SwitchListTile(
          title: Text('群组消息通知'),
          subtitle: Text('接收群组消息通知'),
          value: _notifyGroupMessages,
          onChanged:
              _enableNotifications
                  ? (value) {
                    setState(() => _notifyGroupMessages = value);
                  }
                  : null,
        ),
        SwitchListTile(
          title: Text('@提及通知'),
          subtitle: Text('当有人@提及您时接收通知'),
          value: _notifyMentions,
          onChanged:
              _enableNotifications
                  ? (value) {
                    setState(() => _notifyMentions = value);
                  }
                  : null,
        ),
        SwitchListTile(
          title: Text('系统通知'),
          subtitle: Text('接收系统和活动通知'),
          value: _notifySystem,
          onChanged:
              _enableNotifications
                  ? (value) {
                    setState(() => _notifySystem = value);
                  }
                  : null,
        ),
        ListTile(
          title: Text('通知声音'),
          subtitle: Text(_getNotificationSoundText()),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          enabled: _enableNotifications,
          onTap:
              _enableNotifications
                  ? () {
                    _showNotificationSoundDialog();
                  }
                  : null,
        ),
        SwitchListTile(
          title: Text('振动'),
          subtitle: Text('接收通知时振动'),
          value: _vibrate,
          onChanged:
              _enableNotifications
                  ? (value) {
                    setState(() => _vibrate = value);
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildPrivacySettingsSection() {
    return _buildSection(
      title: '隐私设置',
      children: [
        ListTile(
          title: Text('通知预览'),
          subtitle: Text(_getPreviewModeText()),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showPreviewModeDialog();
          },
        ),
        ListTile(
          title: Text('已屏蔽用户'),
          subtitle: Text('管理您已屏蔽的用户'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pushNamed(context, '/privacy/blocked-users');
          },
        ),
        ListTile(
          title: Text('清空聊天记录'),
          subtitle: Text('删除所有聊天记录'),
          trailing: Icon(Icons.delete_forever, color: Colors.red),
          onTap: () {
            _showClearHistoryDialog();
          },
        ),
      ],
    );
  }

  Widget _buildStorageSettingsSection() {
    return _buildSection(
      title: '存储设置',
      children: [
        SwitchListTile(
          title: Text('自动下载媒体文件'),
          subtitle: Text('自动下载图片和视频'),
          value: _autoDownloadMedia,
          onChanged: (value) {
            setState(() => _autoDownloadMedia = value);
          },
        ),
        ListTile(
          title: Text('管理存储空间'),
          subtitle: Text('查看和清理缓存文件'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showStorageUsageDialog();
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  String _getMessagePrivacyText() {
    switch (_messagePrivacy) {
      case 'all':
        return '所有人';
      case 'friends':
        return '仅朋友和搭子';
      case 'none':
        return '不允许任何人';
      default:
        return '';
    }
  }

  String _getNotificationSoundText() {
    switch (_notificationSound) {
      case 'default':
        return '默认';
      case 'none':
        return '无';
      default:
        return _notificationSound;
    }
  }

  String _getPreviewModeText() {
    switch (_previewMode) {
      case 'full':
        return '显示发送者和内容';
      case 'sender':
        return '仅显示发送者';
      case 'none':
        return '仅显示"新消息"';
      default:
        return '';
    }
  }

  void _showMessagePrivacyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('谁可以给我发私信'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text('所有人'),
                  value: 'all',
                  groupValue: _messagePrivacy,
                  onChanged: (value) {
                    setState(() => _messagePrivacy = value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: Text('仅朋友和搭子'),
                  value: 'friends',
                  groupValue: _messagePrivacy,
                  onChanged: (value) {
                    setState(() => _messagePrivacy = value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: Text('不允许任何人'),
                  value: 'none',
                  groupValue: _messagePrivacy,
                  onChanged: (value) {
                    setState(() => _messagePrivacy = value!);
                    Navigator.pop(context);
                  },
                ),
              ],
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

  void _showNotificationSoundDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('通知声音'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text('默认'),
                  value: 'default',
                  groupValue: _notificationSound,
                  onChanged: (value) {
                    setState(() => _notificationSound = value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: Text('铃声1'),
                  value: 'ringtone1',
                  groupValue: _notificationSound,
                  onChanged: (value) {
                    setState(() => _notificationSound = value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: Text('铃声2'),
                  value: 'ringtone2',
                  groupValue: _notificationSound,
                  onChanged: (value) {
                    setState(() => _notificationSound = value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: Text('无声'),
                  value: 'none',
                  groupValue: _notificationSound,
                  onChanged: (value) {
                    setState(() => _notificationSound = value!);
                    Navigator.pop(context);
                  },
                ),
              ],
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

  void _showPreviewModeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('通知预览'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text('显示发送者和内容'),
                  value: 'full',
                  groupValue: _previewMode,
                  onChanged: (value) {
                    setState(() => _previewMode = value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: Text('仅显示发送者'),
                  value: 'sender',
                  groupValue: _previewMode,
                  onChanged: (value) {
                    setState(() => _previewMode = value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: Text('仅显示"新消息"'),
                  value: 'none',
                  groupValue: _previewMode,
                  onChanged: (value) {
                    setState(() => _previewMode = value!);
                    Navigator.pop(context);
                  },
                ),
              ],
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

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('清空聊天记录'),
            content: Text('确定要删除所有聊天记录吗？此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('聊天记录已清空')));
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('确定'),
              ),
            ],
          ),
    );
  }

  void _showStorageUsageDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('存储空间使用情况'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(title: Text('图片'), trailing: Text('12.5 MB')),
                ListTile(title: Text('视频'), trailing: Text('35.2 MB')),
                ListTile(title: Text('文件'), trailing: Text('8.7 MB')),
                ListTile(title: Text('缓存'), trailing: Text('6.3 MB')),
                Divider(),
                ListTile(title: Text('总计'), trailing: Text('62.7 MB')),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('缓存已清除')));
                },
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                child: Text('清除缓存'),
              ),
            ],
          ),
    );
  }
}
