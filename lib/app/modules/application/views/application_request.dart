import 'package:admin/app/core/utils/responsive_utils.dart';
import 'package:admin/app/core/widgets/responsive_layout.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/application_controller.dart';

class ApplicationRequest extends GetView<ApplicationController> {
  const ApplicationRequest({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ApplicationRequest'),
        centerTitle: true,
      ),
      body: _buildApplicationBody(context),
    );
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
                '商店申請列表',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                  fontWeight: FontWeight.w600,
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
              children: [Text('顯示列表')],
            ),
          ),
        ],
      ),
    );
  }
}
