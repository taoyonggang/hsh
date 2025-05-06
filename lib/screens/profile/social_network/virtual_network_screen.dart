import 'package:flutter/material.dart';
import '../../../controllers/network_controller.dart';
import '../../../widgets/relationship_graph_view.dart';
import '../../../models/relationship/relationship_network.dart';
import '../../../models/relationship/virtual_user.dart';

class VirtualNetworkScreen extends StatefulWidget {
  const VirtualNetworkScreen({super.key});

  @override
  _VirtualNetworkScreenState createState() => _VirtualNetworkScreenState();
}

class _VirtualNetworkScreenState extends State<VirtualNetworkScreen>
    with SingleTickerProviderStateMixin {
  final NetworkController _networkController = NetworkController();
  RelationshipNetwork? _network;
  bool _isLoading = true;
  String _currentFilter = 'all';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNetwork();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNetwork() async {
    setState(() => _isLoading = true);
    try {
      _network = await _networkController.getVirtualNetwork();
    } catch (e) {
      print('加载虚拟关系网络错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('虚拟关系网络'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: '关系图谱'), Tab(text: '虚拟用户')],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showNetworkInfo();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildNetworkGraphTab(), _buildVirtualUsersTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _tabController.index == 0
              ? _showNetworkActions()
              : _showAddUserDialog();
        },
        backgroundColor: Colors.green,
        child: Icon(_tabController.index == 0 ? Icons.more_vert : Icons.add),
      ),
    );
  }

  Widget _buildNetworkGraphTab() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
          children: [
            _buildFilterTabs(),
            Expanded(
              child:
                  _network != null
                      ? RelationshipGraphView(
                        network: _network!,
                        filter: _currentFilter,
                        editable: true,
                        onNodeTap: (nodeId) {
                          _showUserDetails(nodeId);
                        },
                        onNodeEdit: (nodeId) {
                          _editVirtualUser(nodeId);
                        },
                        onEdgeEdit: (sourceId, targetId) {
                          _editRelationship(sourceId, targetId);
                        },
                      )
                      : Center(child: Text('无法加载关系网络数据')),
            ),
          ],
        );
  }

  Widget _buildVirtualUsersTab() {
    final virtualUsers =
        _network?.nodes
            .map((node) => VirtualUser.fromNetworkNode(node))
            .toList();

    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : virtualUsers == null || virtualUsers.isEmpty
        ? _buildEmptyVirtualUsers()
        : ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: virtualUsers.length,
          itemBuilder: (context, index) {
            final user = virtualUsers[index];
            return _buildVirtualUserCard(user);
          },
        );
  }

  Widget _buildEmptyVirtualUsers() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            '还没有创建虚拟用户',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text('点击右下角的"+"按钮添加虚拟用户', style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showAddUserDialog();
            },
            icon: Icon(Icons.add),
            label: Text('添加虚拟用户'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVirtualUserCard(VirtualUser user) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _showUserDetails(user.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                child:
                    user.avatarUrl == null
                        ? Icon(Icons.person, size: 30)
                        : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        if (user.isMapped) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '已映射',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getRelationshipTypeText(user.relationshipType),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children:
                          user.tags.map((tag) => _buildTagChip(tag)).toList(),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editVirtualUser(user.id);
                      break;
                    case 'map':
                      _mapToRealUser(user);
                      break;
                    case 'delete':
                      _deleteVirtualUser(user);
                      break;
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(value: 'edit', child: Text('编辑')),
                      PopupMenuItem(
                        value: 'map',
                        child: Text(user.isMapped ? '修改映射' : '映射到真实用户'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        textStyle: TextStyle(color: Colors.red),
                        child: Text('删除'),
                      ),
                    ],
              ),
            ],
          ),
        ),
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

  Widget _buildTagChip(String tag) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(tag, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('all', '全部'),
          SizedBox(width: 8),
          _buildFilterChip('family', '家人'),
          SizedBox(width: 8),
          _buildFilterChip('friends', '朋友'),
          SizedBox(width: 8),
          _buildFilterChip('colleagues', '同事'),
          SizedBox(width: 8),
          _buildFilterChip('partners', '搭子'),
          SizedBox(width: 8),
          _buildFilterChip('others', '其他'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _currentFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = filter;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showNetworkInfo() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '虚拟关系网络',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                '• 由用户自行创建和维护\n• 反映用户对社交关系的主观理解\n• 可不受平台限制自由构建\n• 可与真实网络建立映射获取更多数据',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '虚拟用户: ${_network?.nodes.length ?? 0}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '虚实映射: ${_network?.nodes.where((n) => n.isMapped).length ?? 0}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('了解更多'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNetworkActions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.add_circle_outline),
                title: Text('添加虚拟用户'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddUserDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.linked_camera),
                title: Text('添加关系连接'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddRelationshipDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.autorenew),
                title: Text('批量导入联系人'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/network/import-contacts');
                },
              ),
              ListTile(
                leading: Icon(Icons.save_alt),
                title: Text('导出网络图谱'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('网络图谱导出中...')));
                },
              ),
              ListTile(
                leading: Icon(Icons.compare),
                title: Text('与真实网络对比'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/network/compare');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddUserDialog() {
    // 简化版示例，实际应用中应该有更详细的表单
    Navigator.pushNamed(context, '/network/add-virtual-user');
  }

  void _showAddRelationshipDialog() {
    // 简化版示例，实际应用中应该有更详细的表单
    Navigator.pushNamed(context, '/network/add-relationship');
  }

  void _showUserDetails(String userId) {
    // 导航到虚拟用户详情页面
    Navigator.pushNamed(context, '/virtual-user/detail', arguments: userId);
  }

  void _editVirtualUser(String userId) {
    // 导航到编辑虚拟用户页面
    Navigator.pushNamed(context, '/virtual-user/edit', arguments: userId);
  }

  void _editRelationship(String sourceId, String targetId) {
    // 导航到编辑关系页面
    Navigator.pushNamed(
      context,
      '/network/edit-relationship',
      arguments: {'sourceId': sourceId, 'targetId': targetId},
    );
  }

  void _mapToRealUser(VirtualUser user) {
    // 导航到用户映射页面
    Navigator.pushNamed(context, '/virtual-user/map', arguments: user.id);
  }

  void _deleteVirtualUser(VirtualUser user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('删除虚拟用户'),
            content: Text('确定要删除虚拟用户 "${user.name}" 吗？相关的所有关系连接也会被删除。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // 执行删除操作
                  try {
                    await _networkController.deleteVirtualUser(user.id);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('虚拟用户已删除')));
                    // 重新加载网络
                    _loadNetwork();
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('删除'),
              ),
            ],
          ),
    );
  }
}
