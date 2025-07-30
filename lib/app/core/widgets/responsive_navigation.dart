import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/responsive_utils.dart';
import 'responsive_layout.dart';

/// 響應式導航控制器
class ResponsiveNavigationController extends GetxController {
  final RxBool _isDrawerOpen = false.obs;
  final RxInt _selectedIndex = 0.obs;

  bool get isDrawerOpen => _isDrawerOpen.value;
  int get selectedIndex => _selectedIndex.value;

  void toggleDrawer() {
    _isDrawerOpen.toggle();
  }

  void closeDrawer() {
    _isDrawerOpen.value = false;
  }

  void selectIndex(int index) {
    _selectedIndex.value = index;
    closeDrawer(); // 選擇項目後關閉抽屜
  }
}

/// 導航項目模型
class NavigationItem {
  final String title;
  final IconData icon;
  final String route;
  final List<NavigationItem>? children;

  NavigationItem({
    required this.title,
    required this.icon,
    required this.route,
    this.children,
  });
}

/// 響應式導航組件 - 根據螢幕大小自動切換導航方式
class ResponsiveNavigation extends StatelessWidget {
  final List<NavigationItem> navigationItems;
  final Widget body;
  final Widget? header;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const ResponsiveNavigation({
    super.key,
    required this.navigationItems,
    required this.body,
    this.header,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ResponsiveNavigationController>(
      init: ResponsiveNavigationController(),
      builder: (controller) {
        return ResponsiveLayout(
          // 手機版：使用 Drawer
          mobile: _buildMobileLayout(context, controller),
          // 平板版：使用 NavigationRail
          tablet: _buildTabletLayout(context, controller),
          // 桌面版：使用側邊欄
          desktop: _buildDesktopLayout(context, controller),
        );
      },
    );
  }

  /// 手機版佈局 - 使用 Drawer
  Widget _buildMobileLayout(
    BuildContext context,
    ResponsiveNavigationController controller,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: header ?? const Text('MD3 Admin'),
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      drawer: _buildDrawer(context, controller),
      body: body,
    );
  }

  /// 平板版佈局 - 使用 NavigationRail
  Widget _buildTabletLayout(
    BuildContext context,
    ResponsiveNavigationController controller,
  ) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor:
                backgroundColor ?? Theme.of(context).colorScheme.surface,
            selectedIndex: controller.selectedIndex,
            onDestinationSelected: controller.selectIndex,
            labelType: NavigationRailLabelType.selected,
            destinations:
                navigationItems
                    .map(
                      (item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        label: Text(item.title),
                      ),
                    )
                    .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                if (header != null)
                  Container(
                    height: 60,
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color:
                          backgroundColor ??
                          Theme.of(context).colorScheme.surface,
                      border: const Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: header,
                  ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 桌面版佈局 - 使用完整側邊欄
  Widget _buildDesktopLayout(
    BuildContext context,
    ResponsiveNavigationController controller,
  ) {
    return Scaffold(
      body: Row(
        children: [
          // 側邊欄
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: backgroundColor ?? Theme.of(context).colorScheme.surface,
              border: const Border(
                right: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Column(
              children: [
                // 標題區域
                if (header != null)
                  Container(
                    height: 80,
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: header,
                  ),
                // 導航列表
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = navigationItems[index];
                      final isSelected = controller.selectedIndex == index;

                      return _buildNavigationTile(
                        context,
                        controller,
                        item,
                        index,
                        isSelected,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // 主要內容區域
          Expanded(child: body),
        ],
      ),
    );
  }

  /// 建立 Drawer
  Widget _buildDrawer(
    BuildContext context,
    ResponsiveNavigationController controller,
  ) {
    return Drawer(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Drawer 頭部
          if (header != null)
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: header,
            ),
          // 導航項目
          Expanded(
            child: ListView.builder(
              itemCount: navigationItems.length,
              itemBuilder: (context, index) {
                final item = navigationItems[index];
                final isSelected = controller.selectedIndex == index;

                return _buildNavigationTile(
                  context,
                  controller,
                  item,
                  index,
                  isSelected,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 建立導航項目
  Widget _buildNavigationTile(
    BuildContext context,
    ResponsiveNavigationController controller,
    NavigationItem item,
    int index,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color:
            isSelected
                ? (selectedColor ??
                    Theme.of(context).colorScheme.primaryContainer)
                : null,
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          color:
              isSelected
                  ? (selectedColor ??
                      Theme.of(context).colorScheme.onPrimaryContainer)
                  : (unselectedColor ??
                      Theme.of(context).colorScheme.onSurface),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color:
                isSelected
                    ? (selectedColor ??
                        Theme.of(context).colorScheme.onPrimaryContainer)
                    : (unselectedColor ??
                        Theme.of(context).colorScheme.onSurface),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          controller.selectIndex(index);
          Get.toNamed(item.route);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// 響應式 AppBar 組件
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final bool automaticallyImplyLeading;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
      leading: leading,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      elevation: context.isMobile ? 1 : 0,
      centerTitle: context.isMobile,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
