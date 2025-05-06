import 'package:flutter/material.dart';
import '../../../controllers/health_controller.dart';
import '../../../models/health/health_models.dart';

class AdvisorTab extends StatefulWidget {
  const AdvisorTab({super.key});

  @override
  _AdvisorTabState createState() => _AdvisorTabState();
}

class _AdvisorTabState extends State<AdvisorTab> {
  final HealthController _controller = HealthController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = true;
  UserHealthProfile? _userProfile;
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _userProfile = await _controller.loadUserProfile();

      // 添加初始消息
      _messages.add(
        ChatMessage(
          text: '您好，${_userProfile?.name ?? '用户'}，我是您的健康AI顾问。有什么我能帮助您的吗？',
          isFromUser: false,
        ),
      );
      _messages.add(
        ChatMessage(
          text: '您可以询问我关于饮食、运动、睡眠等健康问题，我也可以结合您的八字特点提供阴阳五行平衡建议。',
          isFromUser: false,
        ),
      );
    } catch (e) {
      print('Error loading advisor data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAdvisorHeader(),
                SizedBox(height: 20),
                _buildChatSection(),
                SizedBox(height: 20),
                if (!(_userProfile?.isPremiumMember ?? false))
                  _buildAdvisorUpgradeCard(),
                SizedBox(height: 20),
                _buildCommonHealthQuestionsCard(),
              ],
            ),
          ),
        ),
        _buildMessageInputBar(),
      ],
    );
  }

  // 顾问头部
  Widget _buildAdvisorHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.health_and_safety,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '健康AI顾问',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '您的个人健康助手，随时为您解答健康问题',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 聊天部分
  Widget _buildChatSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '咨询健康问题',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(minHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageItem(_messages[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 消息项
  Widget _buildMessageItem(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isFromUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
        children: [
          if (!message.isFromUser) ...[
            CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.2),
              radius: 16,
              child: Icon(
                Icons.health_and_safety,
                size: 16,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(maxWidth: 250),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: message.isFromUser ? Colors.blue : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: message.isFromUser ? Colors.white : Colors.black,
              ),
            ),
          ),
          if (message.isFromUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 16,
              child: Text(
                _userProfile?.name.substring(0, 1) ?? 'U',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 消息输入栏
  Widget _buildMessageInputBar() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '输入您的健康问题...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: 1,
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  // 发送消息
  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      // 添加用户消息
      _messages.add(ChatMessage(text: message, isFromUser: true));
    });

    _messageController.clear();

    // 模拟 AI 响应延迟
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _messages.add(
          ChatMessage(text: _getAIResponse(message), isFromUser: false),
        );
      });
    });
  }

  // 模拟 AI 回复（实际应用中应通过 API 获取真实回复）
  String _getAIResponse(String question) {
    // 基于关键词的简单回复
    if (question.toLowerCase().contains('睡眠') || question.contains('失眠')) {
      return '建议保持规律的作息时间，睡前避免使用电子设备。每天可以尝试冥想或深呼吸放松身心。如果您的八字偏热，可以适量喝些菊花茶帮助入睡。';
    } else if (question.toLowerCase().contains('饮食') ||
        question.contains('吃什么')) {
      return '根据您的八字特点，建议多食用${_userProfile?.isPremiumMember ?? false ? '滋阴清热的食物，如百合、莲子、银耳等' : '新鲜蔬果，粗粮杂粮，少吃辛辣油腻食物'}。保持饮食多样化，确保营养均衡。';
    } else if (question.toLowerCase().contains('运动')) {
      return '建议每周进行至少150分钟中等强度有氧运动，如快走、游泳或骑自行车。${_userProfile?.isPremiumMember ?? false ? '您的八字属性显示，水流类运动或晨间锻炼可能更适合您。' : '结合力量训练可以增强肌肉和骨骼健康。'}';
    } else {
      return '感谢您的问题。保持良好的生活习惯对健康至关重要，包括规律作息、均衡饮食和适量运动。${!(_userProfile?.isPremiumMember ?? false) ? '升级至精准健康套餐可获得更个性化的健康建议。' : ''}';
    }
  }

  // 顾问升级卡片
  Widget _buildAdvisorUpgradeCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.amber.shade50,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  '升级健康顾问功能',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('升级至精准健康套餐，获取更专业的健康咨询服务', style: TextStyle(fontSize: 14)),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('结合八字的个性化健康建议'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('健康风险预警及预防指导'),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                minimumSize: Size(double.infinity, 40),
              ),
              child: Text('立即升级 · ¥999'),
            ),
          ],
        ),
      ),
    );
  }

  // 常见健康问题卡片
  Widget _buildCommonHealthQuestionsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '常见健康问题',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildQuestionItem('如何改善睡眠质量？'),
            _buildQuestionItem('每天应该喝多少水？'),
            _buildQuestionItem('如何保持健康的心理状态？'),
            _buildQuestionItem('哪些食物有助于增强免疫力？'),
            _buildQuestionItem('如何调节五行平衡？'),
          ],
        ),
      ),
    );
  }

  // 问题项
  Widget _buildQuestionItem(String question) {
    return InkWell(
      onTap: () {
        _messageController.text = question;
        _sendMessage();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(Icons.question_answer, color: Colors.blue, size: 18),
            SizedBox(width: 12),
            Expanded(child: Text(question)),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// 聊天消息类
class ChatMessage {
  final String text;
  final bool isFromUser;

  ChatMessage({required this.text, required this.isFromUser});
}
