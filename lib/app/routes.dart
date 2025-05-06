import 'package:flutter/material.dart';

// 首页相关
import '../screens/home/home_screen.dart';

// 健康相关
import '../screens/health/health_screen.dart';
import '../screens/health/health_data_screen.dart';
import '../screens/health/health_report_screen.dart';

// 运势相关
import '../screens/fortune/fortune_screen.dart';
import '../screens/fortune/fortune_detail_screen.dart';

// 搭子相关
import '../screens/partner/partner_screen.dart';
import '../screens/partner/partner_detail_screen.dart';
import '../screens/partner/partner_match_screen.dart';
import '../screens/partner/activity_create_screen.dart';

// 个人资料相关
import '../screens/profile/profile_screen.dart';
import '../screens/profile/profile_edit_screen.dart';

// 社交网络相关
import '../screens/profile/social_network/social_network_screen.dart';
import '../screens/profile/social_network/virtual_network_screen.dart';
import '../screens/profile/social_network/network_analysis_screen.dart';
import '../screens/profile/social_network/add_virtual_user_screen.dart';
import '../screens/profile/social_network/edit_virtual_user_screen.dart';
import '../screens/profile/social_network/add_relationship_screen.dart';
import '../screens/profile/social_network/edit_relationship_screen.dart';
import '../screens/profile/social_network/map_user_screen.dart';

// 通讯中心相关
import '../screens/profile/messaging/messaging_center_screen.dart';
import '../screens/profile/messaging/message_thread_screen.dart';
import '../screens/profile/messaging/create_message_screen.dart';
import '../screens/profile/messaging/notifications_screen.dart';
import '../screens/profile/messaging/messaging_settings_screen.dart';

// 隐私设置相关
import '../screens/profile/privacy/privacy_settings_screen.dart';
import '../screens/profile/privacy/authorization_records_screen.dart';
import '../screens/profile/privacy/mapping_records_screen.dart';
import '../screens/profile/privacy/data_export_screen.dart';
import '../screens/profile/privacy/select_users_screen.dart';
import '../screens/profile/privacy/blocked_users_screen.dart';

// 通用设置相关
import '../screens/profile/settings/settings_screen.dart';
import '../screens/profile/settings/account_settings_screen.dart';
import '../screens/profile/settings/membership_settings_screen.dart';
import '../screens/profile/settings/help_screen.dart';
import '../screens/profile/settings/about_screen.dart';
import '../screens/profile/settings/terms_screen.dart';
import '../screens/profile/settings/privacy_policy_screen.dart';

// 认证相关
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';

// 路由名称常量
class Routes {
  // 认证相关
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // 首页相关
  static const String home = '/home';

  // 个人资料相关
  static const String profileEdit = '/profile/edit';

  // 社交网络相关
  static const String socialNetwork = '/network/social';
  static const String virtualNetwork = '/network/virtual';
  static const String networkAnalysis = '/network/compare';
  static const String importContacts = '/network/import-contacts';
  static const String addVirtualUser = '/network/add-virtual-user';
  static const String addRelationship = '/network/add-relationship';
  static const String editRelationship = '/network/edit-relationship';
  static const String missedConnections = '/network/missed-connections';
  static const String virtualUserDetail = '/virtual-user/detail';
  static const String editVirtualUser = '/virtual-user/edit';
  static const String mapUser = '/virtual-user/map';

  // 通讯中心相关
  static const String directMessages = '/messaging/direct';
  static const String groupMessages = '/messaging/groups';
  static const String messageThread = '/messaging/thread';
  static const String newMessage = '/messaging/new';
  static const String messageSettings = '/messaging/settings';
  static const String notifications = '/notifications';

  // 隐私设置相关
  static const String privacySettings = '/privacy/settings';
  static const String authorizations = '/privacy/authorizations';
  static const String mappings = '/privacy/mappings';
  static const String dataExport = '/privacy/data-export';
  static const String selectUsers = '/privacy/select-users';
  static const String blockedUsers = '/privacy/blocked-users';

  // 通用设置相关
  static const String settings = '/settings';
  static const String accountSettings = '/settings/account';
  static const String membershipSettings = '/settings/membership';
  static const String help = '/settings/help';
  static const String about = '/settings/about';
  static const String terms = '/settings/terms';
  static const String privacyPolicy = '/settings/privacy-policy';
  static const String whatsnew = '/whatsnew';

  // 健康相关
  static const String healthData = '/health/data';
  static const String healthReport = '/health/report';

  // 运势相关
  static const String fortuneDetail = '/fortune/detail';

  // 搭子相关
  static const String partnerDetail = '/partner/detail';
  static const String partnerMatch = '/partner/match';
  static const String activityCreate = '/partner/activity/create';
  static const String activityDetail = '/activity/detail';
}

// 路由生成器
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // 认证相关
      case Routes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case Routes.register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case Routes.forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());

      // 个人资料相关
      case Routes.profileEdit:
        return MaterialPageRoute(builder: (_) => ProfileEditScreen());

      // 社交网络相关
      case Routes.socialNetwork:
        return MaterialPageRoute(builder: (_) => SocialNetworkScreen());
      case Routes.virtualNetwork:
        return MaterialPageRoute(builder: (_) => VirtualNetworkScreen());
      case Routes.networkAnalysis:
        return MaterialPageRoute(builder: (_) => NetworkAnalysisScreen());
      case Routes.addVirtualUser:
        return MaterialPageRoute(
          builder:
              (_) => AddVirtualUserScreen(
                suggestedUserId: args is Map ? args['suggestedUserId'] : null,
              ),
        );
      case Routes.addRelationship:
        return MaterialPageRoute(builder: (_) => AddRelationshipScreen());
      case Routes.editRelationship:
        if (args is Map &&
            args.containsKey('sourceId') &&
            args.containsKey('targetId')) {
          return MaterialPageRoute(
            builder:
                (_) => EditRelationshipScreen(
                  sourceId: args['sourceId'],
                  targetId: args['targetId'],
                ),
          );
        }
        return _errorRoute();
      case Routes.virtualUserDetail:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => EditVirtualUserScreen(userId: args, viewOnly: true),
          );
        }
        return _errorRoute();
      case Routes.editVirtualUser:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => EditVirtualUserScreen(userId: args),
          );
        }
        return _errorRoute();
      case Routes.mapUser:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => MapUserScreen(virtualUserId: args),
          );
        }
        return _errorRoute();

      // 通讯中心相关
      case Routes.directMessages:
      case Routes.groupMessages:
      case Routes.notifications:
        return MaterialPageRoute(builder: (_) => MessagingCenterScreen());
      case Routes.messageThread:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => MessageThreadScreen(threadId: args),
          );
        }
        return _errorRoute();
      case Routes.newMessage:
        return MaterialPageRoute(builder: (_) => CreateMessageScreen());
      case Routes.messageSettings:
        return MaterialPageRoute(builder: (_) => MessagingSettingsScreen());

      // 隐私设置相关
      case Routes.privacySettings:
        return MaterialPageRoute(builder: (_) => PrivacySettingsScreen());
      case Routes.authorizations:
        return MaterialPageRoute(builder: (_) => AuthorizationRecordsScreen());
      case Routes.mappings:
        return MaterialPageRoute(builder: (_) => MappingRecordsScreen());
      case Routes.dataExport:
        return MaterialPageRoute(builder: (_) => DataExportScreen());
      case Routes.selectUsers:
        return MaterialPageRoute(builder: (_) => SelectUsersScreen());
      case Routes.blockedUsers:
        return MaterialPageRoute(builder: (_) => BlockedUsersScreen());

      // 通用设置相关
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case Routes.accountSettings:
        return MaterialPageRoute(builder: (_) => AccountSettingsScreen());
      case Routes.membershipSettings:
        return MaterialPageRoute(builder: (_) => MembershipSettingsScreen());
      case Routes.help:
        return MaterialPageRoute(builder: (_) => HelpScreen());
      case Routes.about:
        return MaterialPageRoute(builder: (_) => AboutScreen());
      case Routes.terms:
        return MaterialPageRoute(builder: (_) => TermsScreen());
      case Routes.privacyPolicy:
        return MaterialPageRoute(builder: (_) => PrivacyPolicyScreen());

      // 健康相关
      case Routes.healthData:
        return MaterialPageRoute(builder: (_) => HealthDataScreen());
      case Routes.healthReport:
        return MaterialPageRoute(builder: (_) => HealthReportScreen());

      // 运势相关
      case Routes.fortuneDetail:
        return MaterialPageRoute(builder: (_) => FortuneDetailScreen());

      // 搭子相关
      case Routes.partnerDetail:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => PartnerDetailScreen(partnerId: args),
          );
        }
        return _errorRoute();
      case Routes.partnerMatch:
        return MaterialPageRoute(builder: (_) => PartnerMatchScreen());
      case Routes.activityCreate:
        return MaterialPageRoute(builder: (_) => ActivityCreateScreen());
      case Routes.activityDetail:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ActivityDetailScreen(activityId: args),
          );
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: Text('错误')),
          body: Center(child: Text('页面不存在')),
        );
      },
    );
  }
}

// 用于ActivityDetailScreen的空实现，以便编译通过
class ActivityDetailScreen extends StatelessWidget {
  final String activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('活动详情')),
      body: Center(child: Text('活动ID: $activityId')),
    );
  }
}
