import 'package:flutter/material.dart';
import '../../../controllers/network_controller.dart';
import '../../../models/relationship/virtual_user.dart';
import '../../../models/user/user_brief.dart';

class MapUserScreen extends StatefulWidget {
  final String virtualUserId;

  const MapUserScreen({super.key, required this.virtualUserId});

  @override
  _MapUserScreenState createState() => _MapUserScreenState();
}

class _MapUserScreenState extends State<MapUserScreen> {
  final NetworkController _networkController = NetworkController();
  bool _isLoading = true;
  bool _isProcessing = false;
  VirtualUser? _virtualUser;
  List<UserBrief> _suggestedUsers = [];
  UserBrief? _selectedUser;

  final TextEditingController _searchController = TextEditingController();
  List<UserBrief> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 在实际应用中，这里会加载虚拟用户和推荐的真实用户
      await Future.delayed(Duration(milliseconds: 800));

      // 模拟数据
      _virtualUser = VirtualUser(
        id: widget.virtualUserId,
        name: "李明",
        relationshipType: "friend",
        tags: ["好友", "大学同学", "篮球"],
      );

      _suggestedUsers = [
        UserBrief(
          id: "user456",
          name: "李明",
          avatarUrl: "https://randomuser.me/api/portraits/men/45.jpg",
        ),
        UserBrief(
          id: "user789",
          name: "王芳",
          avatarUrl: "https://randomuser.me/api/portraits/women/22.jpg",
        ),
        UserBrief(
          id: "user234",
          name: "张伟",
          avatarUrl: "https://randomuser.me/api/portraits/men/67.jpg",
        ),
      ];
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载数据失败: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      // 在实际应用中，这里会调用API搜索用户
      await Future.delayed(Duration(milliseconds: 500));

      // 模拟搜索结果
      setState(() {
        _searchResults =
            _suggestedUsers
                .where(
                  (user) =>
                      user.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      });
    } catch (e) {
      print('搜索失败: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _mapUser() async {
    if (_selectedUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请先选择一个用户')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 在实际应用中，这里会调用API进行映射
      await Future.delayed(Duration(milliseconds: 1000));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('映射成功')));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('映射失败: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('映射到真实用户')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildVirtualUserCard(),
                  Divider(),
                  _buildSearchBar(),
                  Expanded(child: _buildUserList()),
                  _buildBottomAction(),
                ],
              ),
    );
  }

  Widget _buildVirtualUserCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(radius: 24, child: Icon(Icons.person)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _virtualUser?.name ?? "",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('虚拟用户', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          Icon(Icons.arrow_forward),
          SizedBox(width: 16),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            child:
                _selectedUser != null
                    ? ClipOval(
                      child: Image.network(
                        _selectedUser!.avatarUrl ?? "",
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, color: Colors.grey);
                        },
                      ),
                    )
                    : Icon(Icons.question_mark, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索真实用户',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _search("");
                    },
                  )
                  : null,
        ),
        onChanged: _search,
      ),
    );
  }

  Widget _buildUserList() {
    final List<UserBrief> usersToShow =
        _searchController.text.isNotEmpty ? _searchResults : _suggestedUsers;

    if (_isSearching) {
      return Center(child: CircularProgressIndicator());
    }

    if (usersToShow.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty ? '没有推荐用户' : '没有找到匹配的用户',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: usersToShow.length,
      itemBuilder: (context, index) {
        final user = usersToShow[index];
        final isSelected = _selectedUser?.id == user.id;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: isSelected ? Colors.green.shade50 : null,
          margin: EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              setState(() => _selectedUser = user);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                    child: user.avatarUrl == null ? Icon(Icons.person) : null,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      user.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isSelected) Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selectedUser == null || _isProcessing ? null : _mapUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child:
              _isProcessing
                  ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                  : Text('确认映射'),
        ),
      ),
    );
  }
}
