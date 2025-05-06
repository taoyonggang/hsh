import 'package:flutter/material.dart';
import '../../../models/user/user_brief.dart';
import '../../../controllers/privacy_controller.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  _BlockedUsersScreenState createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final PrivacyController _privacyController = PrivacyController();
  bool _isLoading = true;
  List<UserBrief> _blockedUsers = [];
  final Set<String> _usersToUnblock = {};

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(Duration(milliseconds: 800));

      // 模拟屏蔽用户数据
      _blockedUsers = [
        UserBrief(
          id: "user999",
          name: "李刚",
          avatarUrl: "https://randomuser.me/api/portraits/men/99.jpg",
        ),
        UserBrief(
          id: "user888",
          name: "赵丽",
          avatarUrl: "https://randomuser.me/api/portraits/women/88.jpg",
        ),
      ];
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载屏蔽用户失败: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unblockSelectedUsers() async {
    if (_usersToUnblock.isEmpty) return;

    try {
      setState(() => _isLoading = true);

      await Future.delayed(Duration(milliseconds: 800));

      // 模拟解除屏蔽
      setState(() {
        _blockedUsers.removeWhere((user) => _usersToUnblock.contains(user.id));
        _usersToUnblock.clear();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已解除屏蔽')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('解除屏蔽失败: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_usersToUnblock.contains(userId)) {
        _usersToUnblock.remove(userId);
      } else {
        _usersToUnblock.add(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('屏蔽用户管理')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _blockedUsers.isEmpty
              ? _buildEmptyState()
              : _buildBlockedUsersList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            '没有屏蔽的用户',
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

  Widget _buildBlockedUsersList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 80),
            itemCount: _blockedUsers.length,
            itemBuilder: (context, index) {
              final user = _blockedUsers[index];
              final isSelected = _usersToUnblock.contains(user.id);

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                  child: user.avatarUrl == null ? Icon(Icons.person) : null,
                ),
                title: Text(user.name),
                subtitle: Text('屏蔽中'),
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
          ),
        ),
        if (_usersToUnblock.isNotEmpty) _buildBottomAction(),
      ],
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
              '已选择 ${_usersToUnblock.length} 个用户',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _unblockSelectedUsers,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('解除屏蔽'),
            ),
          ],
        ),
      ),
    );
  }
}
