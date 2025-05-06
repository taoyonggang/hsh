import 'package:flutter/material.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  _DataExportScreenState createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  bool _isExporting = false;
  final Map<String, bool> _dataTypes = {
    'profile': true,
    'real_network': true,
    'virtual_network': true,
    'messages': false,
    'privacy_settings': false,
    'authorization_history': false,
  };

  String _exportFormat = 'json';

  Future<void> _exportData() async {
    final selectedTypes =
        _dataTypes.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    if (selectedTypes.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请至少选择一种数据类型')));
      return;
    }

    setState(() => _isExporting = true);

    try {
      await Future.delayed(Duration(milliseconds: 2000));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('数据导出成功')));

      _showExportSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('数据导出失败: $e')));
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showExportSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('数据导出成功'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 64),
                SizedBox(height: 16),
                Text('您的数据已成功导出'),
                SizedBox(height: 8),
                Text('数据已发送到您的注册邮箱', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('确定'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('数据导出')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            SizedBox(height: 24),
            Text(
              '选择要导出的数据',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildDataTypeCheckboxes(),
            SizedBox(height: 24),
            Text(
              '导出格式',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildFormatSelector(),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isExporting ? null : _exportData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isExporting
                        ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                        : Text('导出数据'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '关于数据导出',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '您可以导出您在平台上的个人数据。导出的数据包括您的个人资料、关系网络、消息记录等。数据将以压缩包形式发送到您的注册邮箱。',
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              '根据数据量大小，导出可能需要几分钟到几小时不等。',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTypeCheckboxes() {
    return Column(
      children:
          _dataTypes.entries.map((entry) {
            return CheckboxListTile(
              title: Text(_getDataTypeLabel(entry.key)),
              subtitle: Text(_getDataTypeDescription(entry.key)),
              value: entry.value,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  _dataTypes[entry.key] = value ?? false;
                });
              },
            );
          }).toList(),
    );
  }

  String _getDataTypeLabel(String dataType) {
    switch (dataType) {
      case 'profile':
        return '个人资料';
      case 'real_network':
        return '真实关系网络';
      case 'virtual_network':
        return '虚拟关系网络';
      case 'messages':
        return '消息记录';
      case 'privacy_settings':
        return '隐私设置';
      case 'authorization_history':
        return '授权历史';
      default:
        return dataType;
    }
  }

  String _getDataTypeDescription(String dataType) {
    switch (dataType) {
      case 'profile':
        return '包括您的基本信息和账号设置';
      case 'real_network':
        return '您在平台上的真实互动关系网络';
      case 'virtual_network':
        return '您创建的虚拟关系网络';
      case 'messages':
        return '您的私信和群组消息历史记录';
      case 'privacy_settings':
        return '您的隐私和数据共享设置';
      case 'authorization_history':
        return '数据访问授权的历史记录';
      default:
        return '';
    }
  }

  Widget _buildFormatSelector() {
    return Column(
      children: [
        RadioListTile<String>(
          title: Text('JSON 格式'),
          subtitle: Text('适用于数据分析和导入其他系统'),
          value: 'json',
          groupValue: _exportFormat,
          activeColor: Colors.green,
          onChanged: (value) {
            setState(() {
              _exportFormat = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: Text('CSV 格式'),
          subtitle: Text('适用于电子表格软件查看'),
          value: 'csv',
          groupValue: _exportFormat,
          activeColor: Colors.green,
          onChanged: (value) {
            setState(() {
              _exportFormat = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: Text('PDF 格式'),
          subtitle: Text('适用于阅读和打印'),
          value: 'pdf',
          groupValue: _exportFormat,
          activeColor: Colors.green,
          onChanged: (value) {
            setState(() {
              _exportFormat = value!;
            });
          },
        ),
      ],
    );
  }
}
