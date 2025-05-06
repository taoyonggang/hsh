# huishengapp

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

```
lib/
├── main.dart                          # 应用入口
├── app/
│   ├── routes.dart                    # 路由配置 
│   └── theme.dart                     # 主题定义
├── models/                            # 数据模型
│   ├── user/                          # 用户模型
│   ├── relationship/                  # 关系网络模型
│   ├── messaging/                     # 消息模型
│   └── privacy/                       # 隐私设置模型
├── services/                          # 服务层
│   ├── auth_service.dart              # 认证服务
│   └── api_service.dart               # API服务
├── controllers/                       # 控制器层
│   ├── base_controller.dart           # 基础控制器
│   ├── user_controller.dart           # 用户控制器
│   ├── network_controller.dart        # 网络控制器
│   ├── messaging_controller.dart      # 消息控制器
│   └── privacy_controller.dart        # 隐私控制器
├── screens/                           # 页面
│   ├── home/                          # 首页
│   ├── health/                        # 健康
│   ├── fortune/                       # 运势
│   ├── partner/                       # 搭子
│   └── profile/                       # 我的
│       ├── profile_screen.dart        # 个人中心主页面
│       ├── social_network/            # 社交网络管理
│       ├── messaging/                 # 通讯中心
│       ├── privacy/                   # 隐私设置
│       └── settings/                  # 通用设置
└── widgets/                           # 共用组件
```


```
assets/
  └── data/
      └── users/
          └── current_user/
              ├── profile.json
              ├── real_network.json
              ├── virtual_network.json
              ├── network_comparison.json
              ├── privacy_settings.json
              ├── authorization_records.json
              ├── mapping_records.json
              ├── messages/
              │   ├── threads.json
              │   └── thread001.json
              └── notifications.json

```