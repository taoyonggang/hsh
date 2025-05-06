import 'package:flutter/material.dart';
import '../../../controllers/privacy_controller.dart';
import '../../../models/privacy/authorization_record.dart';

class AuthorizationRecordsScreen extends StatefulWidget {
  const AuthorizationRecordsScreen({super.key});

  @override
  _AuthorizationRecordsScreenState createState() =>
      _AuthorizationRecordsScreenState();
}

class _AuthorizationRecordsScreenState
    extends State<AuthorizationRecordsScreen> {
  final PrivacyController _privacyController = PrivacyController();
  bool _isLoading = true;
  List<AuthorizationRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      _records = await _privacyController.getAuthorizationRecords();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载授权记录失败: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAuthorization(String authId, bool approved) async {
    try {
      await Future.delayed(Duration(milliseconds: 800));

      // 更新记录状态
      setState(() {
        final index = _records.indexWhere((record) => record.id == authId);
        if (index != -1) {
          final record = _records[index];
          final updatedRecord = AuthorizationRecord(
            id: record.id,
            requestor: record.requestor,
            status: approved ? 'approved' : 'denied',
            requestDate: record.requestDate,
            responseDate: DateTime.now(),
            expiryDate:
                approved ? DateTime.now().add(Duration(days: 30)) : null,
            dataTypes: record.dataTypes,
            purpose: record.purpose,
          );

          _records[index] = updatedRecord;
        }
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(approved ? '已批准授权请求' : '已拒绝授权请求')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('处理授权请求失败: $e')));
    }
  }

  Future<void> _revokeAuthorization(String authId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('撤销授权'),
            content: Text('确定要撤销此授权吗？被授权方将无法继续访问相关数据。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('撤销'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await Future.delayed(Duration(milliseconds: 800));

        // 更新记录状态
        setState(() {
          final index = _records.indexWhere((record) => record.id == authId);
          if (index != -1) {
            final record = _records[index];
            final updatedRecord = AuthorizationRecord(
              id: record.id,
              requestor: record.requestor,
              status: 'revoked',
              requestDate: record.requestDate,
              responseDate: record.responseDate,
              expiryDate: null,
              dataTypes: record.dataTypes,
              purpose: record.purpose,
            );

            _records[index] = updatedRecord;
          }
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已撤销授权')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('撤销授权失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('数据授权管理')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _records.isEmpty
              ? _buildEmptyState()
              : _buildRecordsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.vpn_key_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            '没有授权记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    // 对记录进行分组：待处理、已批准、已拒绝/已撤销
    final pendingRecords =
        _records.where((r) => r.status == 'pending').toList();
    final approvedRecords =
        _records.where((r) => r.status == 'approved').toList();
    final otherRecords =
        _records
            .where((r) => r.status != 'pending' && r.status != 'approved')
            .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pendingRecords.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '待处理授权请求',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...pendingRecords.map(_buildPendingRecord),
          ],

          if (approvedRecords.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '有效授权',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...approvedRecords.map(_buildApprovedRecord),
          ],

          if (otherRecords.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '已拒绝/已撤销',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...otherRecords.map(_buildOtherRecord),
          ],

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPendingRecord(AuthorizationRecord record) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      record.requestor.avatarUrl != null
                          ? NetworkImage(record.requestor.avatarUrl!)
                          : null,
                  child:
                      record.requestor.avatarUrl == null
                          ? Icon(Icons.person)
                          : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.requestor.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '请求访问您的数据',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '待处理',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '请求目的: ${record.purpose}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('请求数据类型: ${_getDataTypesText(record.dataTypes)}'),
            SizedBox(height: 8),
            Text(
              '请求时间: ${_formatDateTime(record.requestDate)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _handleAuthorization(record.id, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                  ),
                  child: Text('拒绝'),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _handleAuthorization(record.id, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('批准'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovedRecord(AuthorizationRecord record) {
    final DateTime now = DateTime.utc(2025, 4, 30, 0, 37, 21); // 使用当前时间
    final bool isExpired =
        record.expiryDate != null && record.expiryDate!.isBefore(now);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      record.requestor.avatarUrl != null
                          ? NetworkImage(record.requestor.avatarUrl!)
                          : null,
                  child:
                      record.requestor.avatarUrl == null
                          ? Icon(Icons.person)
                          : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.requestor.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '已获得访问权限',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        isExpired
                            ? Colors.grey.shade100
                            : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isExpired ? '已过期' : '已批准',
                    style: TextStyle(
                      color:
                          isExpired
                              ? Colors.grey.shade800
                              : Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '请求目的: ${record.purpose}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('请求数据类型: ${_getDataTypesText(record.dataTypes)}'),
            SizedBox(height: 4),
            if (record.expiryDate != null)
              Text(
                '有效期至: ${_formatDate(record.expiryDate!)}',
                style: TextStyle(
                  color: isExpired ? Colors.red : Colors.grey[600],
                ),
              ),
            SizedBox(height: 8),
            Text(
              '批准时间: ${record.responseDate != null ? _formatDateTime(record.responseDate!) : "未知"}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            SizedBox(height: 12),
            if (!isExpired)
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => _revokeAuthorization(record.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                  ),
                  child: Text('撤销授权'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherRecord(AuthorizationRecord record) {
    final String statusText = record.status == 'denied' ? '已拒绝' : '已撤销';
    final Color statusColor = Colors.grey.shade800;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      record.requestor.avatarUrl != null
                          ? NetworkImage(record.requestor.avatarUrl!)
                          : null,
                  backgroundColor: Colors.grey.shade300,
                  child:
                      record.requestor.avatarUrl == null
                          ? Icon(Icons.person)
                          : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.requestor.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '数据访问请求$statusText',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '请求目的: ${record.purpose}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('请求数据类型: ${_getDataTypesText(record.dataTypes)}'),
            SizedBox(height: 8),
            Text(
              '$statusText时间: ${record.responseDate != null ? _formatDateTime(record.responseDate!) : "未知"}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _getDataTypesText(List<String> dataTypes) {
    if (dataTypes.isEmpty) return '无';

    final Map<String, String> typeLabels = {
      'basic_profile': '基本资料',
      'activity_history': '活动历史',
      'relationship_graph': '关系网络',
      'chat_history': '聊天记录',
      'sensitive_health_data': '健康数据',
      'location_history': '位置历史',
    };

    return dataTypes.map((type) => typeLabels[type] ?? type).join(', ');
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)} ${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)}';
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}
