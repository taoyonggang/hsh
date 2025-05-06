import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('隐私政策')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '汇升活健康搭子平台隐私政策',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '最后更新日期: 2025年4月1日',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 24),
            _buildSection(
              title: '1. 引言',
              content:
                  '汇升活健康科技有限公司（以下简称"我们"）深知个人信息对您的重要性，我们非常重视您的个人隐私和信息安全。本隐私政策旨在向您说明我们如何收集、使用、存储、共享和保护您的个人信息，以及您享有的相关权利。\n\n请您在使用我们的服务前，仔细阅读并理解本隐私政策的全部内容。若您使用我们的服务，即表示您同意本隐私政策的所有内容。如您不同意本隐私政策的内容，请勿使用我们的服务。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '2. 我们收集的信息',
              content:
                  '2.1 您提供的信息：\n  - 注册信息：姓名、手机号码、电子邮件地址、登录密码等\n  - 个人资料：性别、年龄、头像、个人简介等\n  - 健康信息：身高、体重、身体状况、运动数据等\n  - 社交关系：您创建的虚拟网络关系和互动记录\n\n2.2 我们在您使用服务过程中收集的信息：\n  - 设备信息：设备型号、操作系统、唯一设备标识符、IP地址等\n  - 日志信息：使用时间、使用时长、操作记录、崩溃数据等\n  - 位置信息：精确位置信息（在您授权的情况下）\n\n2.3 来自第三方的信息：\n  - 您授权的第三方应用分享的信息\n  - 公开渠道获取的信息',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '3. 信息的使用',
              content:
                  '3.1 我们使用收集的信息用于以下目的：\n  - 提供、维护和改进我们的服务\n  - 创建和维护您的账户\n  - 处理您的订单和请求\n  - 向您推荐可能感兴趣的内容和服务\n  - 进行用户分析和研究\n  - 保障您的账户安全\n  - 遵守法律法规的要求\n\n3.2 算法推荐：我们可能使用自动化决策技术向您推荐内容和服务。您可以通过隐私设置控制个性化推荐。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '4. 信息的共享',
              content:
                  '4.1 在以下情况下，我们可能会共享您的个人信息：\n  - 获得您的明确同意后与第三方共享\n  - 与我们的关联公司共享，用于支持我们的服务\n  - 与我们的服务提供商和业务合作伙伴共享，以便他们代表我们执行服务\n  - 为遵守法律法规的要求或政府机构的强制命令\n  - 在合并、收购或资产出售的情况下\n\n4.2 我们不会将您的个人信息出售给第三方。\n\n4.3 特别注意：在双网络系统中，您允许被映射的信息将被其他用户在其虚拟网络中使用。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '5. 信息的保护',
              content:
                  '5.1 数据安全措施：\n  - 使用加密技术保护数据传输和存储\n  - 实施严格的访问控制机制\n  - 定期进行安全审计和漏洞扫描\n  - 制定数据安全应急响应计划\n\n5.2 尽管我们采取了上述措施，但请理解互联网并非绝对安全的环境，我们无法保证信息百分之百的安全。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '6. 信息的存储',
              content:
                  '6.1 存储期限：我们将在实现本政策所述目的所必需的期限内保留您的个人信息，除非法律要求或允许延长保留期。\n\n6.2 存储位置：您的个人信息将存储在中国境内的服务器上。如需向境外传输，我们将严格遵守相关法律法规的要求。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '7. 您的权利',
              content:
                  '7.1 您对个人信息享有以下权利：\n  - 访问权：您有权访问我们持有的关于您的个人信息\n  - 更正权：您有权更正不准确或不完整的个人信息\n  - 删除权：在特定情况下，您有权要求删除您的个人信息\n  - 限制处理权：在特定情况下，您有权限制我们对您信息的处理\n  - 反对权：您有权反对我们处理您的个人信息\n  - 数据可携带权：您有权以结构化、常用和机器可读的形式接收您的个人信息\n\n7.2 您可以通过"我的" > "隐私设置"页面行使上述权利。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '8. 儿童隐私',
              content:
                  '我们的服务不面向16岁以下的儿童。如果我们发现收集了16岁以下儿童的个人信息，我们会立即删除相关信息。如果您认为我们可能收集了16岁以下儿童的信息，请立即联系我们。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '9. 隐私政策的更新',
              content:
                  '9.1 我们可能会不时更新本隐私政策，更新后的政策将在平台上公布。\n\n9.2 对于重大变更，我们会通过应用内通知、电子邮件或其他方式通知您。\n\n9.3 若您继续使用我们的服务，即表示您接受更新后的隐私政策。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '10. 联系我们',
              content:
                  '如果您对我们的隐私政策有任何疑问、意见或投诉，或者您希望行使您的权利，请通过以下方式联系我们：\n\n电子邮件：privacy@huishenghealth.com\n电话：400-123-4567\n地址：北京市朝阳区科技园区88号汇升健康大厦\n\n我们将在收到您的请求后30天内回复您。',
            ),
            SizedBox(height: 24),
            Text(
              '特别注意：双网络系统中的隐私保护',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '我们的平台特有的双网络系统（真实关系网络和虚拟关系网络）涉及特殊的隐私考量。您可以通过隐私设置控制：\n\n1. 哪些信息可以被映射到他人的虚拟网络\n2. 谁可以将您映射到他们的虚拟网络\n3. 是否接收映射通知\n4. 查看和管理已批准的映射\n\n我们建议您定期检查和更新这些设置，以确保您的隐私得到充分保护。',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(content, style: TextStyle(height: 1.5)),
      ],
    );
  }
}
