import 'package:flutter/material.dart';
import '../../../models/user/user_brief.dart';

class SelectUsersScreen extends StatefulWidget {
  final List<String> initialSelectedUserIds;

  const SelectUsersScreen({super.key, this.initialSelectedUserIds = const []});

  @override
  _SelectUsersScreenState createState() => _SelectUsersScreenState();
}

class _SelectUsersScreenState extends State<SelectUsersScreen> {
  bool _isLoading = true;
  List<UserBrief> _allUsers = [];
  Set<String> _selectedUserIds = {};
  final TextEditingController _searchController = TextEditingController();
  List<UserBrief> _filteredUsers = [];
  bool _searchMode = false;

  @override
  void initState() {
    super.initState();
    _selectedUserIds = Set.from(widget.initialSelectedUserIds);
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(Duration(milliseconds: 800));

      // 模拟用户数据
      _allUsers = [
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
        UserBrief(
          id: "user345",
          name: "刘洋",
          avatarUrl: "https://randomuser.me/api/portraits/men/76.jpg",
        ),
        UserBrief(
          id: "user567",
          name: "陈思",
          avatarUrl: "https://randomuser.me/api/portraits/women/45.jpg",
        ),
      ];

      _filteredUsers = List.from(_allUsers);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载用户数据失败: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = List.from(_allUsers);
        _searchMode = false;
      });
      return;
    }

    setState(() {
      _searchMode = true;
      _filteredUsers =
          _allUsers
              .where(
                (user) => user.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _saveSelection() {
    Navigator.pop(context, _selectedUserIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _searchMode
                ? TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索用户',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.white),
                  autofocus: true,
                  onChanged: _filterUsers,
                )
                : Text('选择用户'),
        actions: [
          if (!_searchMode)
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() => _searchMode = true);
              },
            ),
          if (_searchMode)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                _filterUsers('');
              },
            ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(child: _buildUserList()),
                  _buildBottomAction(),
                ],
              ),
    );
  }

  Widget _buildUserList() {
    if (_filteredUsers.isEmpty) {
      return Center(
        child: Text(
          _searchMode ? '没有找到匹配的用户' : '没有可选择的用户',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        final isSelected = _selectedUserIds.contains(user.id);

        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null ? Icon(Icons.person) : null,
          ),
          title: Text(user.name),
          trailing: Checkbox(
            value: isSelected,
            activeColor: Colors.green,
            onChanged: (value) {
              _toggleUserSelection(user.id);
            },
          ),
          onTap: () {
            _toggleUserSelection(user.id);
          },
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
      child: SafeArea(
        child: Row(
          children: [
            Text(
              '已选择 ${_selectedUserIds.length} 个用户',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Spacer(),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedUserIds.clear();
                });
              },
              child: Text('清除'),
            ),
            SizedBox(width: 12),
            ElevatedButton(
              onPressed: _saveSelection,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('确认'),
            ),
          ],
        ),
      ),
    );
  }
}
