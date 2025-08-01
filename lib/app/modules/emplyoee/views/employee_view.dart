import 'package:admin/app/core/utils/responsive_utils.dart';
import 'package:admin/app/core/widgets/responsive_layout.dart';
import 'package:admin/app/core/widgets/responsive_navigation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';

import '../controllers/employee_controller.dart';

class EmployeeView extends GetView<EmployeeController> {
  const EmployeeView({super.key});

  // 職級映射表
  static const Map<String, String> _levelMap = {
    '1': '計時人員',
    '2': '全職人員',
    '3': '管理人員',
    '4': '系統管理',
    '5': '超級管理員',
  };

  String _getLevelDisplayName(String levelValue) {
    return _levelMap[levelValue] ?? levelValue;
  }

  // 導航項目定義
  static final List<NavigationItem> navigationItems = [
    NavigationItem(title: '儀表板', icon: Icons.dashboard, route: '/dashboard'),
    NavigationItem(title: '用戶管理', icon: Icons.people, route: '/users'),
    NavigationItem(title: '訂單管理', icon: Icons.shopping_cart, route: '/orders'),
    NavigationItem(title: '產品管理', icon: Icons.inventory, route: '/products'),
    NavigationItem(title: '員工管理', icon: Icons.inventory, route: '/emplyoee'),
    NavigationItem(title: '設定', icon: Icons.settings, route: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveNavigation(
      navigationItems: navigationItems,
      header: _buildHeader(context),
      body: _buildDashboardBody(context),
    );
  }

  /// 建立標題區域
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.admin_panel_settings,
          color: Theme.of(context).colorScheme.primary,
          size: context.responsive(mobile: 24.0, tablet: 28.0, desktop: 32.0),
        ),
        const SizedBox(width: 12),
        Text(
          'MD3 Admin',
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  /// 建立儀表板主體
  Widget _buildDashboardBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.hasError.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.fetchEmployeeList(),
                child: const Text('重新載入'),
              ),
            ],
          ),
        );
      }

      return Align(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          padding: ResponsiveUtils.responsivePadding(
            context,
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 頁面標題和操作按鈕
              _buildPageHeader(context),

              // 最近訂單表格
              _buildRecentOrders(context),
            ],
          ),
        ),
      );
    });
  }

  /// 建立頁面標題
  Widget _buildPageHeader(BuildContext context) {
    return ResponsiveRow(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '員工管理',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 28),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '這是您的管理面板概覽',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        context.isMobile
            ? Row(
              children: [
                // 手機版：只顯示圖標按鈕以節省空間
              ],
            )
            : Row(
              children: [
                // 平板和桌面版：顯示完整按鈕
                const SizedBox(width: 12),
              ],
            ),
      ],
    );
  }

  /// 建立最近訂單表格
  Widget _buildRecentOrders(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '員工列表',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                  fontWeight: FontWeight.w600,
                ),
              ),
              context.isMobile
                  ? IconButton(
                    onPressed: () {
                      Get.toNamed('/emplyoee/edit/add');
                    },
                    icon: const Icon(Icons.person_add),
                    tooltip: '新增人員',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                  : ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed('/emplyoee/edit/add');
                    },
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('新增人員'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.antiAlias,
            child: DataTable(
              columnSpacing: context.isMobile ? 16.0 : 20.0, // 桌面版用預設寬敞間距
              horizontalMargin: context.isMobile ? 4.0 : 24.0, // 桌面版用標準邊距
              columns: [
                DataColumn(
                  label: SizedBox(
                    width: context.isMobile ? 50 : 50,
                    child: const Text('編號'),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: context.isMobile ? 60 : 100,
                    child: const Text('姓名'),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: context.isMobile ? 50 : 120,
                    child: const Text('級別'),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: context.isMobile ? 60 : 40,
                    child: const Text('狀態'),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: context.isMobile ? 80 : 100,
                    child: const Text('日期'),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: context.isMobile ? 30 : 30,
                    child: const Text('編輯'),
                  ),
                ),
              ],
              rows:
                  controller.employeeList
                      .map(
                        (employee) => _buildDataRow(
                          context,
                          employee.employeeId.toString(),
                          employee.name,
                          _getLevelDisplayName(employee.level),
                          employee.status ? '啟用' : '停用',
                          employee.modifiedAt.toString(),
                          employee.email,
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 建立數據行
  DataRow _buildDataRow(
    BuildContext context,
    String id,
    String name,
    String level,
    String status,
    String date,
    String email,
  ) {
    Color statusColor;
    switch (status) {
      case '啟用':
        statusColor = Colors.green;
        break;
      case '停用':
        statusColor = Colors.orange;
        break;
      case '刪除':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    // 將日期格式化
    final String formattedDate = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.parse(date));

    return DataRow(
      cells: [
        DataCell(SizedBox(width: context.isMobile ? 50 : 50, child: Text(id))),
        DataCell(
          SizedBox(width: context.isMobile ? 60 : 120, child: Text(name)),
        ),
        DataCell(
          SizedBox(width: context.isMobile ? 50 : 120, child: Text(level)),
        ),
        DataCell(
          SizedBox(
            width: context.isMobile ? 60 : 50,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: context.isMobile ? 40 : 100,
            child: Text(formattedDate, style: TextStyle(fontSize: 16)),
          ),
        ),
        DataCell(
          SizedBox(
            width: context.isMobile ? 30 : 30,
            child: IconButton(
              onPressed: () {
                Get.toNamed('/emplyoee/edit/${Uri.encodeComponent(email)}');
              },
              icon: Icon(Icons.edit, size: 24),
              tooltip: '編輯員工資料',
            ),
          ),
        ),
      ],
    );
  }
}
