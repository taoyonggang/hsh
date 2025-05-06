import 'package:flutter/material.dart';
import '../../../controllers/privacy_controller.dart';
import '../../../models/privacy/mapping_record.dart';

class MappingRecordsScreen extends StatefulWidget {
  const MappingRecordsScreen({super.key});

  @override
  _MappingRecordsScreenState createState() => _MappingRecordsScreenState();
}

class _MappingRecordsScreenState extends State<MappingRecordsScreen> {
  final PrivacyController _privacyController = PrivacyController();
  List<MappingRecord> _mappingRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMappingRecords();
  }

  Future<void> _loadMappingRecords() async {
    setState(() => _isLoading = true);
    try {
      _mappingRecords = await _privacyController.getMappingRecords();
    } catch (e) {
      print('加载映射记录错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('被映射管理')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _mappingRecords.isEmpty
              ? _buildEmptyState()
              : _buildMappingRecordsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.link_off, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            '没有映射记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '当其他用户将您映射到他们的虚拟网络中时，记录将显示在这里',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMappingRecordsList() {
    // 将记录分为待审批和已处理两组
    final pendingRecords =
        _mappingRecords.where((record) => !record.isApproved).toList();
    final processedRecords =
        _mappingRecords.where((record) => record.isApproved).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pendingRecords.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '待处理映射请求',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: pendingRecords.length,
              itemBuilder: (context, index) {
                return _buildMappingRecordItem(pendingRecords[index], true);
              },
            ),
          ],
          if (processedRecords.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '已处理映射请求',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: processedRecords.length,
              itemBuilder: (context, index) {
                return _buildMappingRecordItem(processedRecords[index], false);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMappingRecordItem(MappingRecord record, bool isPending) {
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
                      record.mapper.avatarUrl != null
                          ? NetworkImage(record.mapper.avatarUrl!)
                          : null,
                  child:
                      record.mapper.avatarUrl == null
                          ? Icon(Icons.person)
                          : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.mapper.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '请求将您映射为"${record.virtualUserName}"',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isPending
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPending ? '待处理' : '已同意',
                    style: TextStyle(
                      color: isPending ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '申请时间: ${_formatDate(record.createdDate)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            if (record.isApproved && record.approvalDate != null)
              Text(
                '批准时间: ${_formatDate(record.approvalDate!)}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            if (isPending) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      _rejectMapping(record);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                    ),
                    child: Text('拒绝', style: TextStyle(color: Colors.red)),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      _approveMapping(record);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text('同意'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_padZero(date.month)}-${_padZero(date.day)} ${_padZero(date.hour)}:${_padZero(date.minute)}';
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }

  Future<void> _approveMapping(MappingRecord record) async {
    try {
      await _privacyController.updateMappingRecord(record.id, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已同意映射请求')));
      _loadMappingRecords(); // 重新加载数据
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
    }
  }

  Future<void> _rejectMapping(MappingRecord record) async {
    try {
      // 在实际应用中，这里应该有一个拒绝映射的API调用
      // 这里我们简单地从列表中移除
      setState(() {
        _mappingRecords.remove(record);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已拒绝映射请求')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
    }
  }
}
