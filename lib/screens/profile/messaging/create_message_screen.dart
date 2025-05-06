import 'package:flutter/material.dart';
import '../../../models/user/user_brief.dart';
import '../../../controllers/messaging_controller.dart';

class CreateMessageScreen extends StatefulWidget {
  const CreateMessageScreen({super.key});

  @override
  _CreateMessageScreenState createState() => _CreateMessageScreenState();
}

class _CreateMessageScreenState extends State<CreateMessageScreen> {
  final MessagingController _messagingController = MessagingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isLoading = true;
  bool _isSearching = false;
  bool _isSending = false;
  List<UserBrief> _allUsers = [];
  List<UserBrief> _filteredUsers = [];
  final List<UserBrief> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
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
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredUsers =
          _allUsers
              .where(
                (user) => user.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void _toggleUserSelection(UserBrief user) {
    setState(() {
      if (_selectedUsers.any((u) => u.id == user.id)) {
        _selectedUsers.removeWhere((u) => u.id == user.id);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请选择至少一个接收者')));
      return;
    }

    final text = _messageController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请输入消息内容')));
      return;
    }

    setState(() => _isSending = true);

    try {
      await Future.delayed(Duration(milliseconds: 1000));

      // 在实际应用中，这里会调用API发送消息
      print('发送消息给: ${_selectedUsers.map((u) => u.name).join(", ")}');
      print('消息内容: $text');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('消息已发送')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('发送消息失败: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('新消息')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildSearchBar(),
                  _buildSelectedUsers(),
                  Divider(height: 1),
                  _buildUsersList(),
                  if (_selectedUsers.isNotEmpty) _buildMessageInput(),
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
          hintText: '搜索用户',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: _filterUsers,
      ),
    );
  }

  Widget _buildSelectedUsers() {
    if (_selectedUsers.isEmpty) return SizedBox();

    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedUsers.length,
        itemBuilder: (context, index) {
          final user = _selectedUsers[index];
          return Container(
            margin: EdgeInsets.only(right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                      child: user.avatarUrl == null ? Icon(Icons.person) : null,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _toggleUserSelection(user),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  user.name,
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsersList() {
    if (_isSearching && _filteredUsers.isEmpty) {
      return Expanded(child: Center(child: Text('没有找到匹配的用户')));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          final isSelected = _selectedUsers.any((u) => u.id == user.id);

          return ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null ? Icon(Icons.person) : null,
            ),
            title: Text(user.name),
            trailing:
                isSelected
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : null,
            onTap: () => _toggleUserSelection(user),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '输入消息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(16),
              ),
              maxLines: 3,
              minLines: 1,
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child:
                    _isSending
                        ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                        : Text('发送'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
