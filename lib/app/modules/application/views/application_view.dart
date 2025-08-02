import 'package:admin/app/core/utils/responsive_utils.dart';
import 'package:admin/app/core/widgets/responsive_layout.dart';
import 'package:admin/app/core/widgets/responsive_navigation.dart';
import 'package:admin/app/core/constants/app_navigation.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/application_controller.dart';

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

  /// 建立主要內容區域
  Widget _buildMainContent(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '列表',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                  fontWeight: FontWeight.w600,
                ),
              ),
              context.isMobile
                  ? IconButton(
                    onPressed: () {
                      // TODO: 實作新增應用程式功能
                    },
                    icon: const Icon(Icons.add),
                    tooltip: '新增商店進件',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                  : ElevatedButton.icon(
                    onPressed: () {
                      // TODO: 實作新增應用程式功能
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('新增商店進件'),
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

          // TODO: 在這裡添加主要內容，例如表格、卡片或列表
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: context.isMobile ? 10 : 40,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.applicationAdd);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_rounded,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '新增商店',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.applicationAdd);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.storefront,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '商店進件',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.applicationAdd);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.man_2,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '使用者進件',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
