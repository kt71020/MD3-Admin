import 'package:admin/app/core/utils/responsive_utils.dart';
import 'package:admin/app/core/widgets/responsive_layout.dart';
import 'package:admin/app/core/widgets/responsive_navigation.dart';
import 'package:admin/app/core/constants/app_navigation.dart';
import 'package:admin/app/models/application/application_summary_model.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/application_controller.dart';

/// 專業管理後台間距定義
class AdminSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class ApplicationView extends GetView<ApplicationController> {
  const ApplicationView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveNavigation(
      navigationItems: AppNavigation.mainNavigationItems,
      header: _buildHeader(context),
      body: _buildApplicationBody(context),
    );
  }

  /// 建立標題區域
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.apps,
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

  /// 建立應用程式主體
  Widget _buildApplicationBody(BuildContext context) {
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
                onPressed: () => controller.pickAndUploadCSVFile(),
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

              // 主要內容區域
              _buildMainContent(context),
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
              '商店進件管理',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 28),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '管理商店進件設定和配置',
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
                // 手機版：只顯示圖示按鈕以節省空間
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

  /// 建立主要內容區域 - 企業級專業設計
  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        // 快速操作區域
        _buildQuickActions(context),

        const SizedBox(height: AdminSpacing.lg),
        // 統計概覽區域
        _buildStatsOverview(
          context,
          '商店申請數量',
          controller.applicationSummary.value?.channel.shop ??
              ApplicationSummary(
                channel: 'SHOP',
                approve: 0,
                colse: 0,
                pedding: 0,
                reject: 0,
                totalApplication: 0,
                check: 0,
                newApplication: 0,
                processing: 0,
                activeApplication: 0,
              ),
          'SHOP',
        ),

        // 統計概覽區域
        _buildStatsOverview(
          context,
          '使用者推薦數',
          controller.applicationSummary.value?.channel.user ??
              ApplicationSummary(
                channel: 'USER',
                approve: 0,
                colse: 0,
                pedding: 0,
                reject: 0,
                totalApplication: 0,
                check: 0,
                newApplication: 0,
                processing: 0,
                activeApplication: 0,
              ),
          'USER',
        ),
        const SizedBox(height: AdminSpacing.lg),

        // 最近活動區域
        _buildRecentActivities(context),
      ],
    );
  }

  /// 建立統計概覽區域
  Widget _buildStatsOverview(
    BuildContext context,
    String title,
    ApplicationSummary summary,
    String channel,
  ) {
    final pending = summary.pedding;
    final newThisMonth = summary.newApplication;
    final processing = summary.processing;
    final check = summary.check;

    return ResponsiveRow(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title,
            '$newThisMonth',
            Icons.storefront,
            Colors.blue,
            'ALL',
            channel,
          ),
        ),

        const SizedBox(width: AdminSpacing.md),
        Expanded(
          child: _buildStatCard(
            context,
            '未審核',
            '$pending',
            Icons.pending_actions,
            Colors.purple,
            'PENDING_REVIEW',
            channel,
          ),
        ),
        const SizedBox(width: AdminSpacing.md),
        Expanded(
          child: _buildStatCard(
            context,
            '處理中',
            '$processing',
            Icons.integration_instructions,
            Colors.purple,
            'IN_PROGRESS',
            channel,
          ),
        ),
        const SizedBox(width: AdminSpacing.md),
        Expanded(
          child: _buildStatCard(
            context,
            '待審核',
            '$check',
            Icons.approval_rounded,
            Colors.orange,
            'WAITING_REVIEW',
            channel,
          ),
        ),
      ],
    );
  }

  /// 建立統計卡片
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String filter,
    String channel,
  ) {
    debugPrint('🔄 Filter value: $filter');
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: () {
            final route =
                channel == 'USER'
                    ? '/application/user/request/$filter'
                    : '/application/request/$filter';
            Get.toNamed(route);
          },
          child: Card(
            elevation: context.responsive(
              mobile: 2.0,
              tablet: 4.0,
              desktop: 6.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminSpacing.md),
            ),
            child: Padding(
              padding: EdgeInsets.all(
                context.responsive(mobile: 16.0, tablet: 20.0, desktop: 24.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AdminSpacing.sm),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AdminSpacing.sm),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: context.responsive(
                            mobile: 20.0,
                            tablet: 24.0,
                            desktop: 28.0,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.more_vert,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: AdminSpacing.md),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 28),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AdminSpacing.xs),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 建立快速操作區域
  Widget _buildQuickActions(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '快速操作',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AdminSpacing.lg),
          ResponsiveLayout(
            mobile: _buildMobileQuickActions(context),
            tablet: _buildDesktopQuickActions(context),
            desktop: _buildDesktopQuickActions(context),
          ),
        ],
      ),
    );
  }

  /// 手機版快速操作
  Widget _buildMobileQuickActions(BuildContext context) {
    int activeUserApplication =
        controller.applicationSummary.value?.channel.user.activeApplication ??
        0;
    int activeShopApplication =
        controller.applicationSummary.value?.channel.shop.activeApplication ??
        0;
    return Column(
      children: [
        _buildActionTile(
          context,
          '新增商店',
          '建立新的商店資料',
          Icons.add_business,
          Colors.blue,
          () => Get.toNamed(
            Routes.applicationAdd,
          )?.then((_) => controller.getApplicationSummary()),
        ),
        const SizedBox(height: AdminSpacing.sm),
        _buildActionTile(
          context,
          '商店進件管理',
          '處理商店申請案件 ',
          Icons.storefront,
          Colors.green,
          () {
            if (activeShopApplication > 0) {
              Get.toNamed(
                Routes.applicationRequest,
              )?.then((_) => controller.getApplicationSummary());
            }
          },
        ),
        const SizedBox(height: AdminSpacing.sm),
        _buildActionTile(
          context,
          '使用者推薦管理',
          '使用者進件管理 ',
          Icons.people,
          Colors.purple,
          () {
            if (activeUserApplication > 0) {
              Get.toNamed(
                Routes.applicationUserRequest,
              )?.then((_) => controller.getApplicationSummary());
            }
          },
        ),
      ],
    );
  }

  /// 桌面版快速操作
  Widget _buildDesktopQuickActions(BuildContext context) {
    int activeUserApplication =
        controller.applicationSummary.value?.channel.user.activeApplication ??
        0;
    int activeShopApplication =
        controller.applicationSummary.value?.channel.shop.activeApplication ??
        0;
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            '新增商店',
            '建立新的商店資料',
            Icons.add_business,
            Colors.blue,
            () => Get.toNamed(
              Routes.applicationAdd,
            )?.then((_) => controller.getApplicationSummary()),
          ),
        ),
        const SizedBox(width: AdminSpacing.md),
        Expanded(
          child: _buildActionCard(
            context,
            '商店進件管理',
            '處理商店申請案件',
            Icons.storefront,
            Colors.green,
            () =>
                activeShopApplication != 0
                    ? Get.toNamed(
                      Routes.applicationRequest,
                    )?.then((_) => controller.getApplicationSummary())
                    : null,
          ),
        ),
        const SizedBox(width: AdminSpacing.md),
        Expanded(
          child: _buildActionCard(
            context,
            '使用者推薦管理',
            '管理系統使用者推薦',
            Icons.people,
            Colors.purple,
            () =>
                activeUserApplication != 0
                    ? Get.toNamed(
                      Routes.applicationUserRequest,
                    )?.then((_) => controller.getApplicationSummary())
                    : null,
          ),
        ),
      ],
    );
  }

  /// 建立操作磚塊（手機版）
  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminSpacing.md),
        child: Container(
          padding: const EdgeInsets.all(AdminSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(AdminSpacing.md),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AdminSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AdminSpacing.sm),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AdminSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 建立操作卡片（桌面版）
  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AdminSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(AdminSpacing.lg),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(AdminSpacing.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AdminSpacing.md),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AdminSpacing.md),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(height: AdminSpacing.md),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AdminSpacing.xs),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 建立最近活動區域
  Widget _buildRecentActivities(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近活動',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 查看全部活動
                },
                child: const Text('查看全部'),
              ),
            ],
          ),
          const SizedBox(height: AdminSpacing.md),
          ..._buildActivityItems(context),
        ],
      ),
    );
  }

  /// 建立活動項目
  List<Widget> _buildActivityItems(BuildContext context) {
    final activities = [
      {
        'title': '新商店「美味餐廳」已通過審核',
        'time': '2 小時前',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': '用戶 John 提交了新的商店申請',
        'time': '4 小時前',
        'icon': Icons.assignment,
        'color': Colors.blue,
      },
      {
        'title': '商店「科技商城」更新了營業資訊',
        'time': '6 小時前',
        'icon': Icons.edit,
        'color': Colors.orange,
      },
      {
        'title': '系統完成每日備份',
        'time': '12 小時前',
        'icon': Icons.backup,
        'color': Colors.purple,
      },
    ];

    return activities
        .map(
          (activity) => Padding(
            padding: const EdgeInsets.only(bottom: AdminSpacing.sm),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AdminSpacing.sm),
                  decoration: BoxDecoration(
                    color: (activity['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AdminSpacing.sm),
                  ),
                  child: Icon(
                    activity['icon'] as IconData,
                    color: activity['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AdminSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activity['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
