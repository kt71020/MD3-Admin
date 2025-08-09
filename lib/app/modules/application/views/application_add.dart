import 'package:admin/app/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
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
                                TextButton.icon(
                                  onPressed: controller.pickAndUploadCSVFile,
                                  icon: const Icon(
                                    Icons.file_upload,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    '上傳檔案',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // 新增：一鍵完成按鈕
                                Container(
                                  width: double.infinity,
                                  height: 1,
                                  color: Colors.grey.shade300,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),

                                Obx(
                                  () => ElevatedButton.icon(
                                    onPressed:
                                        (controller.isFileUploading.value ||
                                                controller.isApiUploading.value)
                                            ? null
                                            : () => controller
                                                .uploadCSVAndAddShop(0),
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
                                          : '🚀 一鍵完成',
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

                                const SizedBox(height: 8),
                                Text(
                                  '支援 CSV 格式檔案',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
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

            // 新增商店按鍵
            Obx(
              () =>
                  controller.selectedFileName.value.isNotEmpty &&
                          controller.csvData.isNotEmpty &&
                          controller.uploadResult.value == null
                      ? Column(
                        children: [
                          const Divider(),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: Obx(
                              () => ElevatedButton.icon(
                                onPressed:
                                    controller.isApiUploading.value
                                        ? null
                                        : () => controller.uploadAddShop(
                                          0,
                                          'APPLICATION_USER',
                                        ),
                                icon:
                                    controller.isApiUploading.value
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Icon(Icons.cloud_upload),
                                label: Text(
                                  controller.isApiUploading.value
                                      ? '正在新增商店...'
                                      : '新增商店',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '將會上傳至後端 API 進行格式檢查並新增至資料庫',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          // API 結果顯示
                          Obx(
                            () =>
                                controller.uploadResult.value != null
                                    ? Container(
                                      margin: const EdgeInsets.only(top: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.blue.shade600,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'API 回應結果',
                                                style: TextStyle(
                                                  color: Colors.blue.shade700,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '狀態：${controller.uploadResult.value!['Status'] ?? controller.uploadResult.value!['status'] ?? 'N/A'}',
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                          Builder(
                                            builder: (context) {
                                              // 解析 SID 的邏輯
                                              String sid = '';
                                              final result =
                                                  controller
                                                      .uploadResult
                                                      .value!;
                                              if (result['sid'] != null) {
                                                sid = result['sid'].toString();
                                              } else if (result['SID'] !=
                                                  null) {
                                                sid = result['SID'].toString();
                                              } else if (result['data'] !=
                                                      null &&
                                                  result['data']['upload_shop'] !=
                                                      null &&
                                                  result['data']['upload_shop']['sid'] !=
                                                      null) {
                                                sid =
                                                    result['data']['upload_shop']['sid']
                                                        .toString();
                                              }

                                              return sid.isNotEmpty
                                                  ? Text(
                                                    '商店編號：$sid',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.blue.shade700,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                  : const SizedBox.shrink();
                                            },
                                          ),
                                          if (controller
                                                  .uploadResult
                                                  .value!['message'] !=
                                              null)
                                            Text(
                                              '訊息：${controller.uploadResult.value!['message']}',
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                              ),
                                            ),

                                          // 重新開始按鍵
                                          const SizedBox(height: 16),
                                          const Divider(),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed:
                                                  controller.clearSelectedFile,
                                              icon: const Icon(Icons.refresh),
                                              label: const Text(
                                                '繼續新增商店',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '點擊重新開始下一輪新增作業',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                          ),
                        ],
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
