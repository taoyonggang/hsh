import 'package:flutter/material.dart';
import 'tabs/partners_tab.dart';
import 'tabs/activities_tab.dart';
import 'tabs/matching_tab.dart';
import '../../widgets/app_bottom_navigation.dart';

class PartnerScreen extends StatefulWidget {
  const PartnerScreen({super.key});

  @override
  _PartnerScreenState createState() => _PartnerScreenState();
}

class _PartnerScreenState extends State<PartnerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的搭子'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/partner/search'),
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed:
                () => Navigator.pushNamed(context, '/partner/notifications'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: '我的搭子'), Tab(text: '搭子活动'), Tab(text: '搭子匹配')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [PartnersTab(), ActivitiesTab(), MatchingTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 根据当前标签页显示不同的创建选项
          if (_tabController.index == 0) {
            _showCreateOptions(context, 'partner');
          } else if (_tabController.index == 1) {
            _showCreateOptions(context, 'activity');
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showCreateOptions(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  type == 'partner' ? Icons.group_add : Icons.event_available,
                ),
                title: Text(type == 'partner' ? '创建新搭子' : '创建新活动'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    type == 'partner' ? '/partner/create' : '/activity/create',
                  );
                },
              ),
              ListTile(
                leading: Icon(type == 'partner' ? Icons.search : Icons.pages),
                title: Text(type == 'partner' ? '加入搭子' : '活动模板'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    type == 'partner' ? '/partner/join' : '/activity/templates',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
