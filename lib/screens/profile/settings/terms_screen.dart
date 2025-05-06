import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('用户协议')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '汇升活健康搭子平台用户协议',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '最后更新日期: 2025年4月1日',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 24),
            _buildSection(
              title: '1. 协议概述',
              content:
                  '本用户协议（以下简称"协议"）是您与汇升活健康科技有限公司（以下简称"我们"或"公司"）就汇升活健康搭子平台服务等相关事宜所订立的契约。本协议描述了您与我们之间关于"汇升活健康搭子平台"服务的权利和义务。请您在使用我们的服务前，仔细阅读并理解本协议内容。\n\n若您使用我们的服务，即表示您已充分阅读、理解并接受本协议的全部内容，同意受本协议约束。如您不同意本协议的内容，请勿使用我们的服务。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '2. 定义',
              content:
                  '2.1 用户：指注册、登录、使用、浏览本服务的个人或组织。\n\n2.2 账号：指用户为使用本服务而注册的特定账户，包括用户名、密码等信息。\n\n2.3 真实关系网络：指基于平台上实际用户互动数据形成的社交关系网络。\n\n2.4 虚拟关系网络：指用户自行创建和维护的，反映用户对社交关系的理解和规划的网络。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '3. 注册与账号',
              content:
                  '3.1 用户在注册时应当向我们提供真实、准确、完整、合法有效的注册信息，包括但不限于用户名、密码、电子邮件、手机号码等。\n\n3.2 用户应当对账号信息保密，并对所有使用其账号进行的活动承担责任。如发现任何未经授权使用用户账号的情况，应立即通知我们。\n\n3.3 我们保留在任何时候收回任何用户名的权利。\n\n3.4 用户不得将其账号转让、出售或出借给他人使用。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '4. 服务内容',
              content:
                  '4.1 我们提供的服务内容包括但不限于：双网络系统（真实关系网络和虚拟关系网络）、健康管理、运势预测、搭子匹配等功能。\n\n4.2 部分服务可能需要用户付费使用，具体收费标准以我们在平台上的公示为准。\n\n4.3 我们保留随时变更、中断或终止部分或全部服务的权利。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '5. 用户行为规范',
              content:
                  '5.1 用户在使用我们的服务时，必须遵守中华人民共和国相关法律法规。\n\n5.2 用户不得利用我们的服务从事违法违规活动，包括但不限于：\n  - 发布、传播违法、有害、淫秽、暴力、恐怖等信息\n  - 侵犯他人知识产权、商业秘密等合法权益\n  - 干扰或破坏我们服务的正常运行\n  - 收集其他用户个人信息未经授权\n\n5.3 对于违反上述规定的用户，我们有权采取警告、删除内容、限制功能、暂停或终止服务等措施。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '6. 隐私政策',
              content:
                  '6.1 我们重视用户的隐私保护，我们会根据《隐私政策》收集、使用、存储和保护您的个人信息。\n\n6.2 您使用我们的服务，即表示您同意我们按照《隐私政策》收集、使用、存储和保护您的个人信息。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '7. 知识产权',
              content:
                  '7.1 本平台所有内容，包括但不限于文本、图形、标志、按钮图标、图像、音频、数据汇编和软件，均为我们或内容提供者所有，受中国和国际版权法保护。\n\n7.2 未经我们事先书面许可，用户不得以任何形式复制、修改、传播平台内容。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '8. 免责声明',
              content:
                  '8.1 我们不对用户发布的内容负责，不保证内容的准确性、完整性或质量。\n\n8.2 我们不对因网络故障、系统故障、设备故障、黑客攻击等原因导致的服务中断、数据丢失或损坏承担责任。\n\n8.3 我们不保证服务一定能满足用户的所有需求，不保证服务不会中断，不保证服务的及时性、安全性和准确性。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '9. 协议修改',
              content:
                  '9.1 我们保留随时修改本协议的权利，修改后的协议将在平台上公布。\n\n9.2 若您在协议修改后继续使用我们的服务，即表示您已同意修改后的协议。\n\n9.3 若您不同意修改后的协议，应当停止使用我们的服务。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '10. 法律适用与争议解决',
              content:
                  '10.1 本协议的订立、执行和解释及争议的解决均应适用中华人民共和国法律。\n\n10.2 如双方就本协议内容或执行发生争议，应友好协商解决；协商不成的，任何一方均可向公司所在地人民法院提起诉讼。',
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '11. 其他',
              content:
                  '11.1 本协议构成双方对本协议之约定事项的完整协议，除本协议规定的之外，未赋予本协议各方其他权利。\n\n11.2 如本协议中的任何条款无论因何种原因完全或部分无效或不具有执行力，本协议的其余条款仍有效并且有约束力。',
            ),
            SizedBox(height: 24),
            Text(
              '联系我们',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '如您对本协议有任何疑问，请通过以下方式联系我们：\n电子邮件：support@huishenghealth.com\n电话：400-123-4567\n地址：北京市朝阳区科技园区88号汇升健康大厦',
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
