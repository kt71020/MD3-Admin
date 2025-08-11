import 'package:admin/app/core/utils/responsive_utils.dart';
import 'package:admin/app/core/widgets/responsive_layout.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../models/application/application_model.dart';
import '../../../models/application/application_log_model.dart';
import '../controllers/application_controller.dart';
// 條件導入：Web 平台使用 dart:html，其他平台使用 url_launcher
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html if (dart.library.html) 'dart:html';

class ApplicationEdit extends GetView<ApplicationController> {
  const ApplicationEdit({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final application = arguments?['application'] as Application?;
    final isEditMode = arguments?['isEditMode'] as bool? ?? false;

    if (application == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('申請案件檢視/編輯')),
        body: const Center(child: Text('無法取得申請案件資料')),
      );
    }

    // 清除之前的錯誤狀態
    controller.clearErrorState();

    // 如果是編輯模式，初始化編輯資料
    if (isEditMode &&
        controller.editingApplication.value?.id != application.id) {
      controller.setEditingApplication(application);
    }

    // 載入歷程紀錄並清除備註
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getApplicationLogList(application.id, '1');
      controller.clearRemarks(); // 清除備註內容
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? '申請案件編輯' : '申請案件檢視'),
        centerTitle: true,
      ),
      body: _buildApplicationBody(context, application, isEditMode),
    );
  }

  /// 建立應用程式主體
  Widget _buildApplicationBody(
    BuildContext context,
    Application application,
    bool isEditMode,
  ) {
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
            // 主要內容區域
            _buildMainContent(context, application, isEditMode),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }

  /// 建立主要內容區域
  Widget _buildMainContent(
    BuildContext context,
    Application application,
    bool isEditMode,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左側：基本資料和審核結果
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Table 1: 基本資料
              _buildBasicInfoTable(context, application, isEditMode),
              const SizedBox(height: 8),
              // Table 2: 審核結果
              _buildReviewInfoTable(context, application, isEditMode),
              const SizedBox(height: 8),
              _buildActionButtons(context, application, isEditMode),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // 右側：圖檔、備註、歷程紀錄
        Expanded(
          flex: 1,
          child: Column(
            children: [
              // Table 5: 歷程紀錄
              _buildHistoryTable(context, application),
              const SizedBox(height: 8),
              // Table 4: 備註 (只在 status=0,4 時顯示)
              if (application.status == '0' || application.status == '4') ...[
                _buildRemarksTable(context, application),
                const SizedBox(height: 8),
              ],
              // Table 3: 圖檔
              _buildImageTable(context, application),
            ],
          ),
        ),
      ],
    );
  }

  /// 建立基本資料表格/表單
  Widget _buildBasicInfoTable(
    BuildContext context,
    Application application,
    bool isEditMode,
  ) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '基本資料',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 15),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),

          // 所有狀態都使用 TextField，根據 status=1 決定是否可編輯
          _buildUnifiedBasicForm(context, application),
        ],
      ),
    );
  }

  /// 建立統一的基本資料表單 (所有狀態都使用 TextField)
  Widget _buildUnifiedBasicForm(BuildContext context, Application application) {
    // 檢查是否可編輯 (只有 status=1 時可編輯)
    final canEdit = application.status == '1';

    return Column(
      children: [
        // 第一行：申請序號、商店名稱、統一編號 (3個欄位)
        Row(
          children: [
            Expanded(
              child: _buildUnifiedFormField(
                label: '申請序號',
                value: application.id.toString(),
                enabled: false, // 申請序號永遠不可編輯
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildResponsiveFormField(
                label: '商店名稱',
                application: application,
                fieldName: 'shopName',
                getValue: (app) => app.shopName,
                canEdit: canEdit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildResponsiveFormField(
                label: '統一編號',
                application: application,
                fieldName: 'shopTaxId',
                getValue: (app) => app.shopTaxId ?? '',
                canEdit: canEdit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // 第二行：訂購電話、聯絡人、行動電話 (3個欄位)
        Row(
          children: [
            Expanded(
              child: _buildResponsiveFormField(
                label: '訂購電話',
                application: application,
                fieldName: 'shopPhone',
                getValue: (app) => app.shopPhone,
                canEdit: canEdit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildResponsiveFormField(
                label: '聯絡人',
                application: application,
                fieldName: 'shopContactName',
                getValue: (app) => app.shopContactName ?? '',
                canEdit: canEdit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildResponsiveFormField(
                label: '行動電話',
                application: application,
                fieldName: 'shopMobile',
                getValue: (app) => app.shopMobile ?? '',
                canEdit: canEdit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // 第三行：網站、電子郵件 (2個欄位)
        Row(
          children: [
            Expanded(
              child: _buildResponsiveFormField(
                label: '網站',
                application: application,
                fieldName: 'shopWebsite',
                getValue: (app) => app.shopWebsite ?? '',
                canEdit: canEdit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildResponsiveFormField(
                label: '電子郵件',
                application: application,
                fieldName: 'shopEmail',
                getValue: (app) => app.shopEmail ?? '',
                canEdit: canEdit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // 第四行：城市,鄉鎮市區.地址 (3個欄位) 欄寬 城市1/4, 鄉鎮市區1/4, 地址2/4
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildResponsiveFormField(
                label: '城市',
                application: application,
                fieldName: 'shopCity',
                getValue: (app) => app.shopCity ?? '',
                canEdit: canEdit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _buildResponsiveFormField(
                label: '鄉鎮市區',
                application: application,
                fieldName: 'shopRegion',
                getValue: (app) => app.shopRegion ?? '',
                canEdit: canEdit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildResponsiveFormField(
                label: '地址',
                application: application,
                fieldName: 'shopAddress',
                getValue: (app) => app.shopAddress,
                canEdit: canEdit,
                maxLines: 1, // 保持多行輸入
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // 第五行：商店描述 (1個欄位，多行文字)
        _buildResponsiveFormField(
          label: '商店描述(最多50字)',
          application: application,
          fieldName: 'shopDescription',
          getValue: (app) => app.shopDescription ?? '',
          canEdit: canEdit,
          maxLines: 1, // 改為多行支援
        ),
        const SizedBox(height: 6),

        // 第六行：訂購附註 (1個欄位，多行文字)
        _buildResponsiveFormField(
          label: '訂購附註(最多50字)',
          application: application,
          fieldName: 'shopNote',
          getValue: (app) => app.shopNote ?? '',
          canEdit: canEdit,
          maxLines: 1, // 改為多行支援
        ),

        // 顯示未儲存變更提示 (只在可編輯狀態下顯示)
        if (canEdit)
          Obx(() {
            if (controller.hasUnsavedChanges.value) {
              return Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '您有未儲存的變更',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
      ],
    );
  }

  /// 建立只讀表單欄位 (專用於審核結果)
  Widget _buildReadOnlyFormField({
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 2),

        TextFormField(
          initialValue: value,
          readOnly: true, // 設定為只讀
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            isDense: true,
            filled: true,
            fillColor: Colors.green.shade50, // 改為淺綠色背景更明顯
          ),
          style: const TextStyle(
            color: Colors.black, // 確保文字清晰可讀
          ),
        ),
      ],
    );
  }

  /// 建立統一樣式的表單欄位 (適用於所有狀態)
  Widget _buildUnifiedFormField({
    required String label,
    required String value,
    bool enabled = true,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: 2),
        TextFormField(
          initialValue: value,
          enabled: enabled,
          maxLines: maxLines,
          minLines: maxLines > 1 ? 2 : 1, // 多行時設定最小行數
          onChanged: onChanged,
          textInputAction: TextInputAction.next, // 改善輸入體驗
          // 添加這些屬性來改善輸入體驗
          autocorrect: true,
          enableSuggestions: true,
          // 確保輸入法正常工作
          keyboardType: TextInputType.text,
          // 添加這些屬性來改善輸入體驗
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black12, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black54, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: maxLines > 1 ? 12 : 6, // 多行時增加垂直內距
            ),
            isDense: maxLines == 1, // 只有單行時才使用 isDense
            // 統一背景色：可編輯時白色，不可編輯時淺灰色
            filled: !enabled,
            fillColor: !enabled ? Colors.grey.shade100 : null,
          ),
          style: TextStyle(
            // 統一文字色：可編輯時黑色，不可編輯時灰色
            color:
                enabled ? const Color.fromARGB(255, 26, 77, 27) : Colors.black,
            fontWeight: enabled ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 建立響應式表單欄位 (監聽控制器狀態變化)
  Widget _buildResponsiveFormField({
    required String label,
    required Application application,
    required String fieldName,
    required String Function(Application) getValue,
    required bool canEdit,
    int maxLines = 1,
  }) {
    // 以編輯中資料為優先來源，避免重建後回退到舊資料
    final effectiveApplication =
        controller.editingApplication.value ?? application;

    if (!canEdit) {
      return _buildUnifiedFormField(
        label: label,
        value: getValue(effectiveApplication),
        enabled: false,
        maxLines: maxLines,
      );
    }

    return _buildUnifiedFormField(
      label: label,
      value: getValue(effectiveApplication),
      enabled: true,
      maxLines: maxLines,
      onChanged: (value) {
        controller.updateApplicationField(fieldName, value);
      },
    );
  }

  /// 建立審核結果表格
  Widget _buildReviewInfoTable(
    BuildContext context,
    Application application,
    bool isEditMode,
  ) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '審核結果',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 15),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildReadOnlyReviewForm(context, application),
        ],
      ),
    );
  }

  /// 建立只讀的審核結果表單
  Widget _buildReadOnlyReviewForm(
    BuildContext context,
    Application application,
  ) {
    return Column(
      children: [
        // 第一行：審核人姓名、審核結果、審核時間 (3個欄位)
        Row(
          children: [
            Expanded(
              child: _buildReadOnlyFormField(
                label: '審核人姓名',
                value: application.reviewByName ?? '-',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildReadOnlyFormField(
                label: '審核結果',
                value: _getReviewStatusText(application.reviewStatus),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildReadOnlyFormField(
                label: '審核時間',
                value: _formatDateTime(application.reviewAt),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 第二行：審核附註 (1個欄位，全寬)
        _buildReadOnlyFormField(
          label: '審核附註',
          value: application.reviewNote ?? '-',
          maxLines: 1,
        ),
        const SizedBox(height: 12),

        // 第三行：結案人姓名、是否結案、結案時間 (3個欄位)
        Row(
          children: [
            Expanded(
              child: _buildReadOnlyFormField(
                label: '結案人姓名',
                value: application.closeByName ?? '-',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildReadOnlyFormField(
                label: '是否結案',
                value: application.isClose ? '是' : '否',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildReadOnlyFormField(
                label: '結案時間',
                value: _formatDateTime(application.closeAt),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 第四行：申請書狀態 (1個欄位，全寬)
        _buildReadOnlyFormField(
          label: '申請書狀態',
          value: _getStatusText(application.status),
        ),
      ],
    );
  }

  /// 建立圖檔表格
  Widget _buildImageTable(BuildContext context, Application application) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '圖檔',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 15),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          if (application.imageUrl.isNotEmpty) ...[
            // 顯示圖片 URL
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      application.imageUrl,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed:
                        () => _copyImageUrlToClipboard(application.imageUrl),
                    icon: Icon(
                      Icons.copy,
                      color: Colors.blue.shade700,
                      size: 16,
                    ),
                    tooltip: '複製圖片網址',
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 圖片顯示區域（使用 Proxy Server）
            GestureDetector(
              onTap: () => _showImageDialog(context, application.imageUrl),
              child: Container(
                width: double.infinity,
                height: 350,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildProxyImage(
                        application.imageUrl,
                        width: double.infinity,
                        height: 350,
                      ),
                    ),
                    // 放大鏡指示
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    // 顯示 "透過 Proxy" 指示
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.security, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Proxy',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text('無圖片', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 建立操作按鈕區域
  Widget _buildActionButtons(
    BuildContext context,
    Application application,
    bool isEditMode,
  ) {
    if (!isEditMode) {
      // 檢視模式：只顯示返回按鈕
      return Center(
        child: ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text('返回'),
        ),
      );
    }

    // 編輯模式：根據狀態顯示不同按鈕
    switch (application.status) {
      case '0': // 新案件
        return _buildStatus0Buttons(context, application);
      case '1': // 作業中
        return _buildStatus1Buttons(context, application);
      case '2': // 新增完成
      case '3': // 複製資料
        return _buildReadonlyButtons(context);
      case '4': // 等待複檢
        return _buildStatus4Buttons(context, application);
      case '5': // 結案
        return _buildReadonlyButtons(context);
      default:
        return _buildReadonlyButtons(context);
    }
  }

  /// 狀態0：新案件的按鈕
  Widget _buildStatus0Buttons(BuildContext context, Application application) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showRejectDialog(context, application),
          icon: const Icon(Icons.close, color: Colors.white),
          label: const Text('拒絕案件申請'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _approveApplication(context, application),
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text('核准案件申請'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  /// 狀態1：作業中的按鈕
  Widget _buildStatus1Buttons(BuildContext context, Application application) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => _saveApplication(context, application),
          icon: const Icon(Icons.save),
          label: const Text('儲存'),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _downloadCSV(context, application),
          icon: const Icon(Icons.download, color: Colors.white),
          label: const Text('下載 CSV 檔案'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Obx(
          () => ElevatedButton.icon(
            onPressed:
                controller.isApiUploading.value
                    ? null
                    : () => _uploadCSVAndAddShop(context, application),
            icon:
                controller.isApiUploading.value
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.upload_file, color: Colors.white),
            label: Text(
              controller.isApiUploading.value ? '上傳中...' : '上傳 CSV 檔案',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// 狀態4：等待複檢的按鈕
  Widget _buildStatus4Buttons(BuildContext context, Application application) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showReviewFailedDialog(context, application),
          icon: const Icon(Icons.undo, color: Colors.white),
          label: const Text('退回'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _closeCase(context, application),
          icon: const Icon(Icons.check_circle, color: Colors.white),
          label: const Text('結案'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  /// 只讀狀態的按鈕
  Widget _buildReadonlyButtons(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => Get.back(),
        child: const Text('返回'),
      ),
    );
  }

  /// 顯示拒絕對話框
  void _showRejectDialog(BuildContext context, Application application) {
    final TextEditingController noteController = TextEditingController();
    String logContent = '[拒絕]';
    // 如果 Table 4 備註有內容，則預填到審核附註中
    if (controller.remarkController.text.isNotEmpty) {
      logContent += ' ${controller.remarkController.text}';
    }
    noteController.text = logContent;
    controller.clearRemarks(); // 清除備註內容

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('拒絕案件申請'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('案件編號：${application.id}'),
                Text('商店名稱：${application.shopName}'),
                const SizedBox(height: 12),
                const Text('審核附註：'),
                const SizedBox(height: 6),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '請輸入拒絕原因...',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('取消')),
              ElevatedButton(
                onPressed: () async {
                  String logContent = noteController.text;
                  debugPrint('🔄 拒絕原因：$logContent');

                  // 先執行拒絕操作，等待完成
                  final success = await controller.applicationReject(
                    application.id,
                    logContent,
                  );

                  // 關閉對話框
                  Get.back();

                  if (success) {
                    // 在 View 層顯示成功訊息，避免 snackbar 生命週期衝突
                    Get.snackbar(
                      '✅ 拒絕成功',
                      '案件 #${application.id} 已被拒絕',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Get.theme.colorScheme.errorContainer,
                      colorText: Get.theme.colorScheme.onErrorContainer,
                      duration: const Duration(seconds: 5),
                    );

                    // 延遲一下再跳轉，讓 snackbar 有時間顯示
                    await Future.delayed(const Duration(milliseconds: 2000));
                    Get.toNamed(Routes.applicationRequest); // 返回列表頁面
                    // controller.getApplicationList(); // 重新載入列表
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('確認拒絕'),
              ),
            ],
          ),
    );
  }

  /// 顯示退回對話框
  void _showReviewFailedDialog(BuildContext context, Application application) {
    final TextEditingController noteController = TextEditingController();
    String logContent = '[退回]';
    // 如果 Table 4 備註有內容，則預填到審核附註中
    if (controller.remarkController.text.isNotEmpty) {
      logContent += ' ${controller.remarkController.text}';
    }
    noteController.text = logContent;
    controller.clearRemarks(); // 清除備註內容

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('退回案件'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('案件編號：${application.id}'),
                Text('商店名稱：${application.shopName}'),
                const SizedBox(height: 12),
                const Text('退回原因：'),
                const SizedBox(height: 6),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '請輸入退回原因...',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('取消')),
              ElevatedButton(
                onPressed: () async {
                  // 先執行退回操作，等待完成
                  final success = await controller.caseReviewFailed(
                    application.id,
                    noteController.text,
                  );

                  // 關閉對話框
                  Get.back();

                  if (success) {
                    // 在 View 層顯示成功訊息，避免 snackbar 生命週期衝突
                    Get.snackbar(
                      '✅ 退回成功',
                      '案件 #${application.id} 已被退回',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Get.theme.colorScheme.errorContainer,
                      colorText: Get.theme.colorScheme.onErrorContainer,
                      duration: const Duration(seconds: 2),
                    );

                    // 延遲一下再跳轉，讓 snackbar 有時間顯示
                    await Future.delayed(const Duration(milliseconds: 500));
                    Get.back(); // 返回列表頁面
                    controller.getApplicationList(
                      application.channel,
                    ); // 重新載入列表
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('確認退回'),
              ),
            ],
          ),
    );
  }

  /// 核准申請
  void _approveApplication(
    BuildContext context,
    Application application,
  ) async {
    // 取得 Table 4: 備註
    String logContent = '[核准]';
    // 如果 Table 4 備註有內容，則預填到審核附註中
    if (controller.remarkController.text.isNotEmpty) {
      logContent += ' ${controller.remarkController.text}';
    }
    controller.clearRemarks(); // 清除備註內容
    final success = await controller.applicationApprove(
      application.id,
      logContent,
    );
    if (success) {
      // 在 View 層顯示成功訊息，避免 snackbar 生命週期衝突
      Get.snackbar(
        '✅ 核准成功',
        '案件 #${application.id} 已被核准',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        duration: const Duration(seconds: 5),
      );

      // 延遲一下再跳轉，讓 snackbar 有時間顯示
      await Future.delayed(const Duration(milliseconds: 500));
      Get.toNamed(Routes.applicationRequest); // 返回列表頁面
      // controller.getApplicationList(); // 重新載入列表
    }
  }

  /// 儲存申請
  void _saveApplication(BuildContext context, Application application) async {
    final success = await controller.saveApplicationData();
    if (success) {
      // 可以選擇是否返回列表頁面或保持在當前頁面
      // Get.back(); // 如果想要返回列表頁面，取消註解這行
    }
  }

  /// 下載 CSV 檔案
  void _downloadCSV(BuildContext context, Application application) async {
    // 使用 Controller 中的新方法來下載 CSV
    await controller.downloadCsvFile(application.id, '1', application.shopName);
  }

  /// 上傳CSV並新增商店
  void _uploadCSVAndAddShop(
    BuildContext context,
    Application application,
  ) async {
    final success = await controller.uploadCSVAndAddShop(application.id);
    if (success) {
      // 更新 status 為 4 等待複檢
      application.status = '4';
      // controller.applicationList 更新 id=application.id 的 status 為 4
      controller
          .applicationList
          .firstWhere((element) => element.id == application.id)
          .status = '4';
    }
    return;
  }

  /// 結案
  void _closeCase(BuildContext context, Application application) async {
    final success = await controller.caseClose(application.id);
    if (success) {
      Get.back(); // 返回列表頁面
      controller.getApplicationList(application.channel); // 重新載入列表
    }
  }

  /// 取得審核結果文字
  String _getReviewStatusText(String status) {
    switch (status) {
      case 'PENDING':
      case 'PENDDING':
        return '擱置中';
      case 'APPROVE':
        return '已核准';
      case 'REJECT':
        return '已拒絕';
      default:
        return status;
    }
  }

  /// 取得狀態文字
  String _getStatusText(String status) {
    switch (status) {
      case '0':
        return '新案件';
      case '1':
        return '作業中';
      case '2':
        return '新增完成';
      case '3':
        return '複製資料';
      case '4':
        return '等待複檢';
      case '5':
        return '結案';
      default:
        return '未知';
    }
  }

  /// 格式化日期時間
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  /// 複製圖片網址到剪貼簿
  void _copyImageUrlToClipboard(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: imageUrl));
      Get.snackbar(
        '✅ 已複製',
        '圖片網址已複製到剪貼簿',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
    }
  }

  /// 建立 Proxy 圖片載入器
  Widget _buildProxyImage(
    String originalImageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    // 轉換為 proxy URL
    final String proxyUrl = _convertToProxyUrl(originalImageUrl);

    return Image.network(
      proxyUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Container(
          color: Colors.grey.shade50,
          width: width,
          height: height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '載入圖片中...',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                if (loadingProgress.expectedTotalBytes != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${((loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!) * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('🖼️ Proxy 圖片載入失敗: $error');
        debugPrint('📍 Proxy URL: $proxyUrl');
        debugPrint('📍 原始 URL: $originalImageUrl');

        return Container(
          color: Colors.red.shade50,
          width: width,
          height: height,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '圖片載入失敗',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Proxy Server 可能無法存取此圖片',
                    style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Get.forceAppUpdate(),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('重試'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          side: BorderSide(color: Colors.red.shade300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _openImageInNewTab(originalImageUrl),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('直接開啟'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 將原始圖片 URL 轉換為 Proxy URL
  String _convertToProxyUrl(String originalImageUrl) {
    if (originalImageUrl.isEmpty) return '';

    // ✅ 切換回 Perl Dancer2 Proxy Server
    final String proxyBaseUrl = 'http://dev.uirapuka.com:5120/api/proxy';

    // URL 編碼原始圖片 URL
    final String encodedUrl = Uri.encodeComponent(originalImageUrl);

    // 建構 Proxy URL
    final String proxyUrl = '$proxyBaseUrl?url=$encodedUrl';

    // debugPrint('🔄 使用 Perl Dancer2 Proxy Server:');
    // debugPrint('📍 原始: $originalImageUrl');
    // debugPrint('📍 Proxy: $proxyUrl');

    return proxyUrl;
  }

  /// 在新分頁中開啟圖片
  void _openImageInNewTab(String imageUrl) async {
    if (imageUrl.isNotEmpty) {
      try {
        if (kIsWeb) {
          // Web 平台：使用 dart:html 開啟新分頁
          html.window.open(imageUrl, '_blank');
          Get.snackbar(
            '🌐 圖片已開啟',
            '圖片已在新分頁中開啟',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
            backgroundColor: Get.theme.colorScheme.primaryContainer,
            colorText: Get.theme.colorScheme.onPrimaryContainer,
          );
        } else {
          // 其他平台：使用 url_launcher
          final Uri url = Uri.parse(imageUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
            Get.snackbar(
              '🌐 圖片已開啟',
              '圖片已在外部應用程式中開啟',
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 2),
              backgroundColor: Get.theme.colorScheme.primaryContainer,
              colorText: Get.theme.colorScheme.onPrimaryContainer,
            );
          } else {
            throw Exception('Cannot launch URL');
          }
        }
      } catch (e) {
        // 備用方案：複製到剪貼簿
        _copyImageUrlToClipboard(imageUrl);
        Get.snackbar(
          '📋 網址已複製',
          '無法開啟圖片，網址已複製到剪貼簿',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          backgroundColor: Get.theme.colorScheme.secondaryContainer,
          colorText: Get.theme.colorScheme.onSecondaryContainer,
        );
      }
    }
  }

  /// 建立備註表格 (Table 4) - 只在 status=0,4 時顯示
  Widget _buildRemarksTable(BuildContext context, Application application) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '備註',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 15),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // 預設備註選單
          _buildRemarkDropdown(context, application),
          const SizedBox(height: 8),

          // 備註輸入框
          _buildRemarkTextField(context, application),
        ],
      ),
    );
  }

  /// 建立備註下拉選單
  Widget _buildRemarkDropdown(BuildContext context, Application application) {
    // 根據 status 決定預設選項
    List<String> options = [];
    if (application.status == '0') {
      options = ['圖片不法辨識', '資料不完整', '商店已經存在', '拒絕申請', '接受申請'];
    } else if (application.status == '4') {
      options = ['資料有誤', '案件完成'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '預設備註',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('選擇預設備註'),
              ),
              isExpanded: true,
              items:
                  options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(option),
                      ),
                    );
                  }).toList(),
              onChanged: (String? selectedOption) {
                if (selectedOption != null) {
                  // 將選擇的選項添加到備註輸入框
                  controller.addRemark(selectedOption);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 建立備註輸入框
  Widget _buildRemarkTextField(BuildContext context, Application application) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '備註內容',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 2),
        TextFormField(
          controller: controller.remarkController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black54, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            isDense: true,
            hintText: '請輸入備註...',
          ),
        ),
      ],
    );
  }

  /// 建立歷程紀錄表格 (Table 5)
  Widget _buildHistoryTable(BuildContext context, Application application) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '歷程紀錄',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 15),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // 歷程紀錄列表
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.applicationLogList.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('無歷程紀錄', style: TextStyle(color: Colors.grey)),
                ),
              );
            }

            return Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: controller.applicationLogList.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final log = controller.applicationLogList[index];
                  return _buildHistoryItem(log);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 建立單個歷程紀錄項目
  Widget _buildHistoryItem(ApplicationLog log) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一行：姓名和時間
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.blue.shade600),
              const SizedBox(width: 4),
              Text(
                log.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.blue.shade700,
                ),
              ),
              const Spacer(),
              Text(
                _formatDateTime(log.createdAt),
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 第二行：內容
          if (log.content != null && log.content!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                log.content!,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
        ],
      ),
    );
  }

  /// 顯示圖片放大對話框
  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // 背景點擊關閉
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              ),
              // 圖片內容
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 標題列
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.image, color: Colors.grey),
                            const SizedBox(width: 8),
                            const Text(
                              '申請圖片',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                              tooltip: '關閉',
                            ),
                          ],
                        ),
                      ),
                      // 圖片顯示
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildProxyImage(
                              imageUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      // 操作按鈕
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('關閉'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _openImageInNewTab(imageUrl);
                                },
                                icon: const Icon(Icons.open_in_new, size: 16),
                                label: const Text('新分頁開啟'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
