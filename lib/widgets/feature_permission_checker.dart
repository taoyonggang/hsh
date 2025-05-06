import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/permission_service.dart';

class FeaturePermissionChecker extends StatelessWidget {
  final String featureKey;
  final Widget child;
  final Widget? fallbackWidget;
  
  const FeaturePermissionChecker({
    Key? key,
    required this.featureKey,
    required this.child,
    this.fallbackWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final permissionService = PermissionService();
    
    if (permissionService.hasFeaturePermission(featureKey)) {
      return child;
    }
    
    return fallbackWidget ?? _buildDefaultFallback(context);
  }
  
  Widget _buildDefaultFallback(BuildContext context) {
    final authService = AuthService();
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 40, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '需要会员权限',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _getMembershipMessage(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (authService.isLoggedIn) {
                Navigator.pushNamed(context, '/settings/membership');
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
            child: Text(authService.isLoggedIn ? '升级会员' : '立即登录'),
          ),
        ],
      ),
    );
  }
  
  String _getMembershipMessage() {
    switch (featureKey) {
      case 'healthAnalysis':
        return '成为健康会员，每天可获取100次健康建议';
      case 'socialAnalysis':
        return '成为社交会员，畅享社交网络分析';
      case 'fortuneAnalysis':
        return '成为社交会员，进行深度八字/奇门关系分析';
      case 'communityCreate':
        return '成为搭子会员，创建更多社群';
      default:
        return '升级会员获取更多功能';
    }
  }
}