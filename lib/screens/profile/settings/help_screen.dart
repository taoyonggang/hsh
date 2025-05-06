import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _faqCategories = [];
  List<Map<String, dynamic>> _filteredFaqs = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFaqs() async {
    setState(() => _isLoading = true);
    try {
      // 模拟加载FAQ数据
      await Future.delayed(Duration(milliseconds: 800));

      _faqCategories = [
        {
          'title': '账户管理',
          'icon': Icons.person,
          'faqs': [
            {
              'question': '如何修改我的个人资料？',
              'answer': '您可以在"我的" > "账户管理"中编辑您的个人资料，包括更新头像、姓名和其他基本信息。',
            },
            {
              'question': '忘记密码怎么办？',
              'answer': '在登录页面点击"忘记密码"，然后按照提示操作。您需要提供注册时使用的电子邮箱，我们会发送密码重置链接给您。',
            },
            {
              'question': '如何注销账号？',
              'answer':
                  '您可以在"我的" > "账户管理" > "危险操作"中找到"注销账号"选项。请注意，注销账号是永久性操作，所有数据将被删除且无法恢复。',
            },
          ],
        },
        {
          'title': '双网络系统',
          'icon': Icons.bubble_chart,
          'faqs': [
            {
              'question': '真实关系网络和虚拟关系网络有什么区别？',
              'answer':
                  '真实关系网络是基于平台上实际用户互动数据形成的社交网络，而虚拟关系网络是您自行创建和维护的，反映您对社交关系的理解和规划。',
            },
            {
              'question': '如何创建虚拟用户？',
              'answer':
                  '在"我的" > "虚拟关系网络"页面，点击右下角的"+"按钮即可添加虚拟用户。您需要提供名称和关系类型等信息。',
            },
            {
              'question': '什么是映射功能？',
              'answer':
                  '映射功能允许您将虚拟网络中的用户与平台上的真实用户建立关联，从而获取更多真实数据和互动信息。映射需要真实用户的授权。',
            },
          ],
        },
        {
          'title': '隐私与安全',
          'icon': Icons.shield,
          'faqs': [
            {
              'question': '谁可以看到我的个人信息？',
              'answer': '您可以在"我的" > "隐私设置"中控制每种类型信息的可见范围，包括基本信息、敏感信息和社交信息等。',
            },
            {
              'question': '如何拒绝数据授权请求？',
              'answer': '当收到数据授权请求时，您可以在通知中直接拒绝，或者在"数据授权管理"页面中处理待处理的请求。',
            },
            {
              'question': '如何知道谁将我映射到了他们的虚拟网络中？',
              'answer':
                  '您可以在"我的" > "被映射管理"中查看所有将您映射到虚拟网络中的用户，并可以选择接受或拒绝这些映射请求。',
            },
          ],
        },
        {
          'title': '会员服务',
          'icon': Icons.card_membership,
          'faqs': [
            {
              'question': '如何开通会员？',
              'answer': '您可以在"我的" > "会员管理"页面选择适合您的会员方案，并完成付款流程即可成功开通会员。',
            },
            {
              'question': '会员有哪些特权？',
              'answer':
                  '会员特权包括但不限于：创建虚拟关系网络、网络对比分析、无限消息、优先客服支持、专属徽章等。不同级别的会员可能有不同的特权。',
            },
            {
              'question': '如何取消自动续费？',
              'answer':
                  '您可以在"我的" > "会员管理"页面中找到"取消自动续费"选项。取消后，您的会员资格将在当前周期结束后停止。',
            },
          ],
        },
        {
          'title': '消息与通知',
          'icon': Icons.notifications,
          'faqs': [
            {
              'question': '如何管理通知设置？',
              'answer': '您可以在"我的" > "消息设置"中自定义各类通知的接收方式，包括私信、群组消息、@提及和系统通知等。',
            },
            {
              'question': '如何屏蔽某个用户的消息？',
              'answer':
                  '在与该用户的聊天界面中，点击右上角的菜单，选择"屏蔽用户"即可。您也可以在"隐私设置" > "已屏蔽用户"中管理被屏蔽的用户。',
            },
            {
              'question': '如何清空聊天记录？',
              'answer':
                  '您可以在"消息设置" > "清空聊天记录"中删除所有聊天记录，或者在特定聊天界面中选择清除该对话的历史记录。',
            },
          ],
        },
      ];
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载帮助信息失败: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _searchFaqs(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredFaqs = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredFaqs = [];

      for (var category in _faqCategories) {
        for (var faq in category['faqs']) {
          if (faq['question'].toLowerCase().contains(query.toLowerCase()) ||
              faq['answer'].toLowerCase().contains(query.toLowerCase())) {
            _filteredFaqs.add({
              'category': category['title'],
              'question': faq['question'],
              'answer': faq['answer'],
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('帮助与反馈'),
        actions: [
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              _showContactSupportDialog();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child:
                        _isSearching
                            ? _buildSearchResults()
                            : _buildFaqCategories(),
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
          hintText: '搜索常见问题...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _searchFaqs('');
                    },
                  )
                  : null,
        ),
        onChanged: _searchFaqs,
      ),
    );
  }

  Widget _buildFaqCategories() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: _faqCategories.length,
      itemBuilder: (context, index) {
        final category = _faqCategories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _FaqCategoryScreen(category: category),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(category['icon'], color: Colors.green),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${category['faqs'].length}个常见问题',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredFaqs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              '没有找到匹配的问题',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text('请尝试其他关键词或联系客服', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showContactSupportDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('联系客服'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredFaqs.length,
      itemBuilder: (context, index) {
        final faq = _filteredFaqs[index];
        return _buildFaqItem(faq);
      },
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            faq['question'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            faq['category'] ?? '',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(faq['answer'], style: TextStyle(height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactSupportDialog() {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('联系客服'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: '主题',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: '问题描述',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    minLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('已收到您的反馈，我们会尽快处理')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('提交'),
              ),
            ],
          ),
    );
  }
}

class _FaqCategoryScreen extends StatelessWidget {
  final Map<String, dynamic> category;

  const _FaqCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final List faqs = category['faqs'];

    return Scaffold(
      appBar: AppBar(title: Text(category['title'])),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  faq['question'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(faq['answer'], style: TextStyle(height: 1.5)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
