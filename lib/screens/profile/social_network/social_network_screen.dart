import 'package:flutter/material.dart';
import '../../../controllers/network_controller.dart';
import '../../../widgets/relationship_graph_view.dart';
import '../../../models/relationship/relationship_network.dart';

class SocialNetworkScreen extends StatefulWidget {
  const SocialNetworkScreen({super.key});

  @override
  _SocialNetworkScreenState createState() => _SocialNetworkScreenState();
}

class _SocialNetworkScreenState extends State<SocialNetworkScreen> {
  final NetworkController _networkController = NetworkController();
  RelationshipNetwork? _network;
  bool _isLoading = true;
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadNetwork();
  }

  Future<void> _loadNetwork() async {
    setState(() => _isLoading = true);
    try {
      _network = await _networkController.getRealNetwork();
    } catch (e) {
      print('加载真实关系网络错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('真实关系网络'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showNetworkInfo();
            },
          ),
        ],
      ),
      body:
          _isLoading
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
                              onNodeTap: (nodeId) {
                                _showUserDetails(nodeId);
                              },
                            )
                            : Center(child: Text('无法加载关系网络数据')),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNetworkActions();
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.more_vert),
      ),
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
                '真实关系网络',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                '• 基于平台上实际用户互动数据\n• 需要相关用户授权才能获取详细信息\n• 包含系统记录的真实互动数据\n• 数据准确但受权限限制',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '网络节点: ${_network?.nodes.length ?? 0}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '关系连接: ${_network?.connections.length ?? 0}',
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
                leading: Icon(Icons.search),
                title: Text('搜索关系网络'),
                onTap: () {
                  Navigator.pop(context);
                  // 导航到搜索页面
                },
              ),
              ListTile(
                leading: Icon(Icons.refresh),
                title: Text('刷新网络数据'),
                onTap: () {
                  Navigator.pop(context);
                  _loadNetwork();
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
                title: Text('与虚拟网络对比'),
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

  void _showUserDetails(String userId) {
    // 导航到用户详情页面
    Navigator.pushNamed(context, '/user/detail', arguments: userId);
  }
}
