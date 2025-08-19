import 'package:admin/app/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/application_controller.dart';

class ApplicationAdd extends GetView<ApplicationController> {
  const ApplicationAdd({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('上傳檔案新增商店'), centerTitle: true),
      body: Padding(
        padding:
            ResponsiveUtils.isMobile(context)
                ? EdgeInsets.all(24)
                : EdgeInsets.fromLTRB(120, 40, 120, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '新增商店',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 檔案上傳區域
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 64,
                    color: Colors.blue.shade400,
                  ),
                  const SizedBox(height: 16),

                  Obx(
                    () =>
                        controller.isFileUploading.value
                            ? const Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text('正在上傳檔案...'),
                              ],
                            )
                            : Column(
                              children: [
                                // 一鍵完成按鈕
                                Obx(
                                  () => ElevatedButton.icon(
                                    onPressed:
                                        (controller.isFileUploading.value ||
                                                controller.isApiUploading.value)
                                            ? null
                                            : () =>
                                                controller.uploadCSVAndAddShop(
                                                  0,
                                                  'ADMIN',
                                                ),
                                    icon:
                                        (controller.isFileUploading.value ||
                                                controller.isApiUploading.value)
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : const Icon(Icons.rocket_launch),
                                    label: Text(
                                      (controller.isFileUploading.value ||
                                              controller.isApiUploading.value)
                                          ? '正在處理...'
                                          : '🚀 上傳檔案新增商店',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),
                                Text(
                                  '選擇CSV檔案並直接新增商店',
                                  style: TextStyle(
                                    color: Colors.orange.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 檔案資訊顯示
            Obx(
              () =>
                  controller.selectedFileName.value.isNotEmpty
                      ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          border: Border.all(color: Colors.green.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '已選取檔案：',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    controller.selectedFileName.value,
                                    style: TextStyle(
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                  if (controller.csvData.isNotEmpty)
                                    Text(
                                      '共 ${controller.csvData.length} 行數據',
                                      style: TextStyle(
                                        color: Colors.green.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: controller.clearSelectedFile,
                              icon: Icon(
                                Icons.close,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ],
                        ),
                      )
                      : const SizedBox.shrink(),
            ),

            // 錯誤訊息顯示
            Obx(
              () =>
                  controller.hasError.value
                      ? Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.errorMessage.value,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      )
                      : const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            // CSV 內容顯示區域
            Obx(
              () =>
                  controller.csvContentList.isNotEmpty
                      ? Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.file_present,
                                  color: Colors.blue.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'CSV 上傳結果',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    final allContent = controller.csvContentList
                                        .join('\n');
                                    Clipboard.setData(
                                      ClipboardData(text: allContent),
                                    );
                                    Get.snackbar(
                                      '✅ 已複製',
                                      'CSV 內容已複製到剪貼簿',
                                      snackPosition: SnackPosition.TOP,
                                      duration: const Duration(seconds: 2),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.copy,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  tooltip: '複製全部內容',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '共 ${controller.csvContentList.length} 行資料',
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      controller.csvContentList
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                            final index = entry.key;
                                            final content = entry.value;
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 2,
                                                  ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 40,
                                                    child: Text(
                                                      '${index + 1}.',
                                                      style: TextStyle(
                                                        color:
                                                            Colors
                                                                .blue
                                                                .shade600,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: SelectableText(
                                                      content,
                                                      style: TextStyle(
                                                        color:
                                                            Colors
                                                                .blue
                                                                .shade700,
                                                        fontSize: 12,
                                                        fontFamily: 'monospace',
                                                      ),
                                                      maxLines: null,
                                                      enableInteractiveSelection:
                                                          true,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          })
                                          .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      : const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            // 移除無用的 API 結果顯示，因為現在使用 csvContentList 來顯示結果
          ],
        ),
      ),
    );
  }
}
