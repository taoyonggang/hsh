import 'package:flutter/material.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/user/user_profile.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final UserController _userController = UserController();
  bool _isLoading = true;
  bool _isSaving = false;
  UserProfile? _userProfile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // 当前日期和时间
  final DateTime _now = DateTime.utc(2025, 4, 30, 1, 0, 8);

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      _userProfile = await _userController.getUserProfile();

      // 设置初始值
      _nameController.text = _userProfile?.name ?? "taoyonggang";
      _bioController.text = _userProfile?.additionalInfo?['bio'] ?? "";
      _locationController.text =
          _userProfile?.additionalInfo?['location'] ?? "";
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载用户资料失败: $e')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载用户资料失败: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserProfile() async {
    setState(() => _isSaving = true);
    try {
      if (_userProfile != null) {
        // 更新用户资料
        final updatedProfile = UserProfile(
          id: _userProfile!.id,
          name: _nameController.text,
          avatarUrl: _userProfile!.avatarUrl,
          coverImageUrl: _userProfile!.coverImageUrl,
          isSocialMember: _userProfile!.isSocialMember,
          membershipExpiry: _userProfile!.membershipExpiry,
          partnerCount: _userProfile!.partnerCount,
          activityCount: _userProfile!.activityCount,
          relationshipCount: _userProfile!.relationshipCount,
          additionalInfo: {
            'bio': _bioController.text,
            'location': _locationController.text,
            'joinDate': _userProfile!.additionalInfo?['joinDate'],
          },
        );

        await _userController.updateUserProfile(updatedProfile);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('个人资料已更新')));

        Navigator.pop(context, true); // 返回上一页并传递更新标志
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('更新资料失败: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('编辑个人资料'),
        actions: [
          _isSaving
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
              : IconButton(icon: Icon(Icons.save), onPressed: _saveUserProfile),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCoverImage(),
                    _buildProfileHeader(),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField(
                            label: '名称',
                            controller: _nameController,
                            icon: Icons.person,
                          ),
                          SizedBox(height: 16),
                          _buildInputField(
                            label: '个人简介',
                            controller: _bioController,
                            icon: Icons.description,
                            maxLines: 3,
                            hintText: '介绍一下自己...',
                          ),
                          SizedBox(height: 16),
                          _buildInputField(
                            label: '所在地',
                            controller: _locationController,
                            icon: Icons.location_on,
                            hintText: '城市、地区',
                          ),
                          SizedBox(height: 24),
                          _buildMembershipInfo(),
                          SizedBox(height: 24),
                          _buildSocialsSection(),
                          SizedBox(height: 24),
                          _buildPrivacyTip(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildCoverImage() {
    return Stack(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            image:
                _userProfile?.coverImageUrl != null
                    ? DecorationImage(
                      image: NetworkImage(_userProfile!.coverImageUrl!),
                      fit: BoxFit.cover,
                    )
                    : null,
          ),
          child:
              _userProfile?.coverImageUrl == null
                  ? Center(
                    child: Icon(Icons.image, size: 40, color: Colors.grey),
                  )
                  : null,
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.camera_alt),
              color: Colors.white,
              onPressed: () {
                // 更换封面图片
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('封面图片更换功能开发中...')));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _userProfile?.avatarUrl != null
                          ? NetworkImage(_userProfile!.avatarUrl!)
                          : null,
                  child:
                      _userProfile?.avatarUrl == null
                          ? Icon(Icons.person, size: 50)
                          : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.camera_alt),
                      color: Colors.white,
                      iconSize: 20,
                      onPressed: () {
                        // 更换头像
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('头像更换功能开发中...')));
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '上次更新时间: ${_formatDateTime(DateTime.utc(2025, 4, 30, 1, 7, 11))}', // 使用提供的当前时间
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: hintText,
            prefixIcon: Icon(icon),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 0,
            ),
          ),
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildMembershipInfo() {
    final bool isMember = _userProfile?.isSocialMember ?? false;
    final DateTime? expiryDate = _userProfile?.membershipExpiry;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '会员信息',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.card_membership,
                  color: isMember ? Colors.green : Colors.grey,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMember ? '社交会员' : '普通用户',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isMember && expiryDate != null
                            ? '有效期至: ${_formatDate(expiryDate)}'
                            : '开通会员享受更多功能',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings/membership');
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                  child: Text(isMember ? '管理' : '开通'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '社交账号绑定',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildSocialItem(icon: Icons.wechat, name: '微信', connected: true),
            Divider(),
            _buildSocialItem(
              icon: Icons.phone_android,
              name: '手机号',
              connected: true,
              value: '138****5678',
            ),
            Divider(),
            _buildSocialItem(icon: Icons.mail, name: '电子邮箱', connected: false),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialItem({
    required IconData icon,
    required String name,
    required bool connected,
    String? value,
  }) {
    return Row(
      children: [
        Icon(icon, color: connected ? Colors.green : Colors.grey),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name),
              if (connected && value != null)
                Text(
                  value,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            // 处理绑定/解绑
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(connected ? '解绑功能开发中...' : '绑定功能开发中...')),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: connected ? Colors.red : Colors.green,
          ),
          child: Text(connected ? '解绑' : '绑定'),
        ),
      ],
    );
  }

  Widget _buildPrivacyTip() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '隐私提示',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '您可以在隐私设置中控制个人资料的可见范围，包括谁可以看到您的个人信息，以及谁可以将您映射到他们的虚拟网络中。',
            style: TextStyle(color: Colors.blue.shade800),
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/privacy/settings');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
              ),
              child: Text('前往隐私设置'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)} ${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}';
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}
