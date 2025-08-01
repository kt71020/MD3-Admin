import 'package:flutter/material.dart';
import '../widgets/responsive_navigation.dart';

/// 應用程式導航配置
class AppNavigation {
  // 私有構造函數，防止實例化
  AppNavigation._();

  /// 主要導航項目列表
  static final List<NavigationItem> mainNavigationItems = [
    NavigationItem(title: '儀表板', icon: Icons.dashboard, route: '/dashboard'),
    NavigationItem(title: '用戶管理', icon: Icons.people, route: '/users'),
    NavigationItem(title: '訂單管理', icon: Icons.shopping_cart, route: '/orders'),
    NavigationItem(title: '產品管理', icon: Icons.inventory, route: '/products'),
    NavigationItem(title: '員工管理', icon: Icons.people_alt, route: '/emplyoee'),
    NavigationItem(title: '設定', icon: Icons.settings, route: '/settings'),
  ];

  /// 根據路由路徑找到對應的導航項目
  static NavigationItem? findNavigationItemByRoute(String route) {
    try {
      return mainNavigationItems.firstWhere((item) => item.route == route);
    } catch (e) {
      return null;
    }
  }

  /// 根據標題找到對應的導航項目
  static NavigationItem? findNavigationItemByTitle(String title) {
    try {
      return mainNavigationItems.firstWhere((item) => item.title == title);
    } catch (e) {
      return null;
    }
  }

  /// 獲取所有導航路由列表
  static List<String> get allRoutes {
    return mainNavigationItems.map((item) => item.route).toList();
  }

  /// 獲取所有導航標題列表
  static List<String> get allTitles {
    return mainNavigationItems.map((item) => item.title).toList();
  }
}
