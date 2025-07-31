import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/responsive_navigation.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  // 導航項目定義
  static final List<NavigationItem> navigationItems = [
    NavigationItem(title: '儀表板', icon: Icons.dashboard, route: '/dashboard'),
    NavigationItem(title: '用戶管理', icon: Icons.people, route: '/users'),
    NavigationItem(title: '訂單管理', icon: Icons.shopping_cart, route: '/orders'),
    NavigationItem(title: '產品管理', icon: Icons.inventory, route: '/products'),
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

  /// 顯示登出確認對話框
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('確認登出'),
            ],
          ),
          content: const Text('您確定要登出嗎？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('登出'),
            ),
          ],
        );
      },
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

      return SingleChildScrollView(
        padding: ResponsiveUtils.responsivePadding(
          context,
          mobile: 16.0,
          tablet: 20.0,
          desktop: 24.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 頁面標題和操作按鈕
            _buildPageHeader(context),

            const ResponsiveSpacing(mobile: 24),

            // 統計卡片區域
            _buildStatsCards(context),

            const ResponsiveSpacing(mobile: 32),

            // 圖表和最近活動區域
            _buildChartsSection(context),

            const ResponsiveSpacing(mobile: 32),

            // 最近訂單表格
            _buildRecentOrders(context),
          ],
        ),
      );
    });
  }

  /// 建立頁面標題
  Widget _buildPageHeader(BuildContext context) {
    return ResponsiveRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '儀表板',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 28),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '歡迎回來！這是您的管理面板概覽',
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
                IconButton(
                  onPressed: controller.refreshData,
                  icon: const Icon(Icons.refresh),
                  tooltip: '刷新數據',
                ),
                IconButton(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout),
                  tooltip: '登出',
                  color: Colors.red,
                ),
              ],
            )
            : Row(
              children: [
                // 平板和桌面版：顯示完整按鈕
                ElevatedButton.icon(
                  onPressed: controller.refreshData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('刷新數據'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsive(
                        mobile: 16.0,
                        desktop: 24.0,
                      ),
                      vertical: context.responsive(mobile: 12.0, desktop: 16.0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('登出'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsive(
                        mobile: 16.0,
                        desktop: 24.0,
                      ),
                      vertical: context.responsive(mobile: 12.0, desktop: 16.0),
                    ),
                  ),
                ),
              ],
            ),
      ],
    );
  }

  /// 建立統計卡片
  Widget _buildStatsCards(BuildContext context) {
    final stats = [
      {
        'title': '總用戶數',
        'value': controller.totalUsers.value.toString(),
        'icon': Icons.people,
        'color': Colors.blue,
      },
      {
        'title': '總訂單數',
        'value': controller.totalOrders.value.toString(),
        'icon': Icons.shopping_cart,
        'color': Colors.green,
      },
      {
        'title': '總收入',
        'value': '\$${controller.totalRevenue.value.toStringAsFixed(2)}',
        'icon': Icons.attach_money,
        'color': Colors.orange,
      },
      {
        'title': '活躍產品',
        'value': controller.activeProducts.value.toString(),
        'icon': Icons.inventory,
        'color': Colors.purple,
      },
    ];

    return ResponsiveGrid(
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 4,
      children:
          stats
              .map(
                (stat) => _buildStatCard(
                  context,
                  title: stat['title'] as String,
                  value: stat['value'] as String,
                  icon: stat['icon'] as IconData,
                  color: stat['color'] as Color,
                ),
              )
              .toList(),
    );
  }

  /// 建立單個統計卡片
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: context.responsive(mobile: 20.0, desktop: 24.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 建立圖表區域
  Widget _buildChartsSection(BuildContext context) {
    return ResponsiveRow(
      children: [
        Expanded(
          flex: context.isDesktop ? 2 : 1,
          child: ResponsiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '月度銷售趨勢',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('圖表區域\n(可整合 fl_chart 或其他圖表庫)'),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (context.isDesktop) ...[
          const SizedBox(width: 24),
          Expanded(
            child: ResponsiveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最近活動',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActivityList(),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 建立活動列表
  Widget _buildActivityList() {
    final activities = [
      {'action': '新用戶註冊', 'time': '2 分鐘前', 'icon': Icons.person_add},
      {'action': '新訂單產生', 'time': '15 分鐘前', 'icon': Icons.shopping_bag},
      {'action': '產品庫存更新', 'time': '1 小時前', 'icon': Icons.inventory_2},
      {'action': '系統備份完成', 'time': '3 小時前', 'icon': Icons.backup},
    ];

    return Column(
      children:
          activities
              .map(
                (activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        activity['icon'] as IconData,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['action'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              activity['time'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  /// 建立最近訂單表格
  Widget _buildRecentOrders(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '最近訂單',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('訂單編號')),
                DataColumn(label: Text('客戶')),
                DataColumn(label: Text('金額')),
                DataColumn(label: Text('狀態')),
                DataColumn(label: Text('日期')),
              ],
              rows: [
                _buildDataRow('#001', '張小明', '\$299.99', '已完成', '2024-01-15'),
                _buildDataRow('#002', '李小華', '\$599.50', '處理中', '2024-01-14'),
                _buildDataRow('#003', '王小美', '\$799.00', '已發貨', '2024-01-13'),
                _buildDataRow('#004', '陳小強', '\$199.99', '已完成', '2024-01-12'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 建立數據行
  DataRow _buildDataRow(
    String id,
    String customer,
    String amount,
    String status,
    String date,
  ) {
    Color statusColor;
    switch (status) {
      case '已完成':
        statusColor = Colors.green;
        break;
      case '處理中':
        statusColor = Colors.orange;
        break;
      case '已發貨':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return DataRow(
      cells: [
        DataCell(Text(id)),
        DataCell(Text(customer)),
        DataCell(Text(amount)),
        DataCell(
          Container(
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
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        DataCell(Text(date)),
      ],
    );
  }
}
