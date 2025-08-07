import 'package:admin/app/models/application/application_csv_model.dart';
import 'package:admin/app/models/application/application_log_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/app/services/auth_service.dart';
import 'package:admin/app/services/application_service.dart';
import '../../../models/application/application_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../constants/api_urls.dart';
import 'dart:html' as html show AnchorElement, Blob, Url;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApplicationController extends GetxController {
  // 服務實例
  final _applicationService = ApplicationService.instance;

  // 基本狀態管理
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // 檔案相關狀態
  final selectedFileName = ''.obs;
  final csvData = <List<dynamic>>[].obs;
  final isFileUploading = false.obs;

  // API 上傳狀態
  final isApiUploading = false.obs;
  final uploadResult = Rxn<Map<String, dynamic>>();
  final rawCsvContent = ''.obs; // 存儲原始 CSV 內容

  // 申請資料
  final applicationModel = Rxn<ApplicationModel>();
  final applicationList = <Application>[].obs;

  // 案件歷程紀錄
  final applicationLogModel = Rxn<ApplicationLogModel>();
  final applicationLogList = <ApplicationLog>[].obs;
  final totalLogItems = 0.obs;

  // 編輯中的申請資料
  final editingApplication = Rxn<Application>();
  final hasUnsavedChanges = false.obs;

  // 備註輸入控制器
  final remarkController = TextEditingController();
  final remarkText = ''.obs;

  // 分頁相關
  final currentPage = 1.obs;
  final itemsPerPage = 30.obs;
  final totalItems = 0.obs;
  final pageOptions = [5, 30, 50, 100].obs;

  @override
  void onInit() {
    super.onInit();
    // 監聽備註輸入變化
    remarkController.addListener(() {
      remarkText.value = remarkController.text;
    });
    // getApplicationList();
  }

  @override
  void onReady() {
    super.onReady();
    // 每次頁面準備就緒時清除錯誤狀態
    clearErrorState();
  }

  @override
  void onClose() {
    remarkController.dispose();
    super.onClose();
    applicationList.clear();
    applicationModel.value = null;
  }

  /// 清除備註內容
  void clearRemarks() {
    remarkController.clear();
    remarkText.value = '';
  }

  /// 添加備註內容
  void addRemark(String remark) {
    final currentText = remarkController.text;
    if (currentText.isEmpty) {
      remarkController.text = remark;
    } else {
      remarkController.text = '$currentText $remark';
    }
  }

  /// 選取並上傳 CSV 檔案
  Future<void> pickAndUploadCSVFile() async {
    try {
      isFileUploading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      uploadResult.value = null; // 確保清除之前的上傳結果

      // 使用 file_picker 選取檔案
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        selectedFileName.value = file.name;

        // 讀取檔案內容
        String csvString;
        if (file.bytes != null) {
          // Web 平台使用 bytes
          csvString = _decodeBytes(file.bytes!);
        } else if (file.path != null) {
          // 桌面/移動平台使用 path
          final csvFile = File(file.path!);
          final bytes = await csvFile.readAsBytes();
          csvString = _decodeBytes(bytes);
        } else {
          throw Exception('無法讀取檔案內容');
        }

        // 存儲原始 CSV 內容供 API 上傳使用
        rawCsvContent.value = csvString;

        await _processCsvContent(csvString);

        Get.snackbar(
          '成功',
          '成功上傳 CSV 檔案：${file.name}',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        // 使用者取消選取
        Get.snackbar('提示', '未選取任何檔案', snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = '上傳檔案時發生錯誤：$e';
      Get.snackbar('錯誤', '上傳檔案失敗：$e', snackPosition: SnackPosition.TOP);
    } finally {
      isFileUploading.value = false;
    }
  }

  /// 處理多段式配置檔案內容
  Future<void> _processCsvContent(String csvContent) async {
    try {
      debugPrint('📊 開始解析多段式配置檔案...');

      // 檢查檔案基本信息
      final lines = csvContent.split('\n');
      debugPrint('檔案總行數：${lines.length}');
      debugPrint('檔案總字符數：${csvContent.length}');

      // 分段解析
      final sections = _parseConfigSections(lines);

      debugPrint('\n📋 檔案結構分析：');
      debugPrint('發現 ${sections.length} 個配置區段');

      for (final section in sections) {
        debugPrint('\n📦 區段：${section['title']}');
        debugPrint('   行數：${section['data'].length}');
        if (section['data'].isNotEmpty && section['data'].first is List) {
          debugPrint('   欄位數：${(section['data'].first as List).length}');
        }

        // 顯示前3行數據
        final data = section['data'] as List<List<dynamic>>;
        for (int i = 0; i < data.length && i < 3; i++) {
          debugPrint('   第 ${i + 1} 行：${data[i]}');
        }
      }

      // 將解析結果存儲（你可以根據需要調整存儲格式）
      csvData.value =
          sections
              .expand((section) => section['data'] as List<List<dynamic>>)
              .toList();

      debugPrint('\n✅ 成功解析多段式配置檔案');
    } catch (e) {
      debugPrint('❌ 配置檔案解析錯誤：$e');
      debugPrint('錯誤詳情：${e.toString()}');
      throw Exception('配置檔案格式錯誤：$e');
    }
  }

  /// 解析多段式配置檔案
  List<Map<String, dynamic>> _parseConfigSections(List<String> lines) {
    final sections = <Map<String, dynamic>>[];
    String currentTitle = '未知區段';
    List<String> currentSectionLines = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // 檢查是否是分隔線（區段標題）
      if (line.startsWith('---') && line.endsWith('---')) {
        // 處理前一個區段
        if (currentSectionLines.isNotEmpty) {
          final sectionData = _parseSectionData(currentSectionLines);
          sections.add({'title': currentTitle, 'data': sectionData});
        }

        // 開始新區段
        currentTitle = line.replaceAll('---', '').replaceAll(',', '').trim();
        currentSectionLines = [];
      } else if (line.isNotEmpty) {
        currentSectionLines.add(line);
      }
    }

    // 處理最後一個區段
    if (currentSectionLines.isNotEmpty) {
      final sectionData = _parseSectionData(currentSectionLines);
      sections.add({'title': currentTitle, 'data': sectionData});
    }

    return sections;
  }

  /// 解析單個區段的數據
  List<List<dynamic>> _parseSectionData(List<String> sectionLines) {
    final result = <List<dynamic>>[];

    for (final line in sectionLines) {
      if (line.trim().isNotEmpty && !RegExp(r'^\d+$').hasMatch(line.trim())) {
        // 使用 CSV 解析器處理單行
        try {
          final List<List<dynamic>> parsed = const CsvToListConverter().convert(
            line,
          );
          if (parsed.isNotEmpty) {
            result.addAll(parsed);
          }
        } catch (e) {
          // 如果 CSV 解析失敗，嘗試簡單的逗號分割
          final parts = line.split(',').map((part) => part.trim()).toList();
          result.add(parts);
        }
      }
    }

    return result;
  }

  /// 清除已選取的檔案
  void clearSelectedFile() {
    selectedFileName.value = '';
    csvData.clear();
    rawCsvContent.value = '';
    uploadResult.value = null;
    hasError.value = false;
    errorMessage.value = '';
    isApiUploading.value = false; // 重置上傳狀態
  }

  /// 清除檔案狀態但保留上傳結果（用於成功後重新開始）
  void clearFileStateOnly() {
    selectedFileName.value = '';
    csvData.clear();
    rawCsvContent.value = '';
    hasError.value = false;
    errorMessage.value = '';
    isApiUploading.value = false; // 重置上傳狀態
  }

  /// ==========================================
  /// 正確解碼位元組為 UTF-8 字串，處理 BOM 和換行符號
  String _decodeBytes(Uint8List bytes) {
    // 檢查並移除 UTF-8 BOM (0xEF, 0xBB, 0xBF)
    if (bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF) {
      bytes = bytes.sublist(3);
    }

    String decoded;
    try {
      // 使用 UTF-8 解碼器
      decoded = utf8.decode(bytes, allowMalformed: false);
    } catch (e) {
      // 如果 UTF-8 解碼失敗，嘗試其他常見編碼
      try {
        decoded = latin1.decode(bytes);
      } catch (e2) {
        // 最後嘗試允許錯誤字符的 UTF-8
        decoded = utf8.decode(bytes, allowMalformed: true);
      }
    }

    // 標準化換行符號 - 統一轉換為 \n
    decoded = decoded.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    final lineCount = decoded.split('\n').length;
    debugPrint('檔案換行符號標準化完成，共 $lineCount 行');

    return decoded;
  }

  /// ==========================================
  /// 上傳商店資料到後端 API
  /// ==========================================
  Future<Map<String, dynamic>> uploadAddShop() async {
    try {
      // 嘗試不同的檔案欄位名稱
      final fileFieldNames = ['file', 'csv_file', 'upload', 'document'];

      for (int attempt = 0; attempt < fileFieldNames.length; attempt++) {
        final result = await _attemptUpload(
          fileFieldNames[attempt],
          attempt + 1,
        );
        if (result['success'] == true) {
          return result;
        }

        // 如果不是最後一次嘗試，並且是檔案上傳錯誤，則繼續嘗試
        if (attempt < fileFieldNames.length - 1 &&
            result['error'] != null &&
            result['error'].toString().contains('未上傳任何檔案')) {
          debugPrint('⚠️  嘗試 ${fileFieldNames[attempt]} 欄位失敗，嘗試下一個欄位名稱...');
          continue;
        }

        // 其他錯誤或最後一次嘗試，直接返回結果
        return result;
      }

      // 所有嘗試都失敗了
      hasError.value = true;
      errorMessage.value = '上傳商店資料失敗：所有檔案欄位名稱都嘗試失敗';

      Get.snackbar(
        '❌ 上傳失敗',
        '已嘗試所有可能的檔案欄位名稱，請檢查後端API設定',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        duration: const Duration(seconds: 4),
      );

      return {'success': false, 'error': '所有檔案欄位名稱都嘗試失敗'};
    } finally {
      // 無論成功還是失敗，都要重置上傳狀態
      isApiUploading.value = false;
    }
  }

  /// ==========================================
  /// 嘗試使用指定的檔案欄位名稱上傳
  /// ==========================================
  Future<Map<String, dynamic>> _attemptUpload(
    String fileFieldName,
    int attemptNumber,
  ) async {
    try {
      isApiUploading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      debugPrint('🚀 嘗試第 $attemptNumber 次上傳（欄位名稱：$fileFieldName）');

      // 檢查是否有 CSV 內容
      if (rawCsvContent.value.isEmpty) {
        throw Exception('請先選取並解析 CSV 檔案');
      }

      // 準備 API 請求
      final apiUrl = ApiUrls.getFullUrl(ApiUrls.uploadAddShopAPI);
      debugPrint('API URL: $apiUrl');

      // 建立 multipart 請求
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // 加入 Authorization 欄位
      final authService = AuthService.instance;

      // 檢查 JWT token 是否存在
      if (authService.currentToken.isEmpty) {
        throw Exception('JWT Token 不存在，請重新登入');
      }

      request.headers['Authorization'] = 'Bearer ${authService.currentToken}';

      // 加入用戶 ID（如果需要）
      request.fields['uid'] = authService.currentUid;

      // 加入 CSV 檔案內容 - 使用正確的欄位名稱和格式
      final csvBytes = utf8.encode(rawCsvContent.value);
      final filename =
          selectedFileName.value.isNotEmpty
              ? selectedFileName.value
              : 'shop_data.csv';

      request.files.add(
        http.MultipartFile.fromBytes(
          fileFieldName, // 動態檔案欄位名稱
          csvBytes,
          filename: filename,
          contentType: MediaType('text', 'csv'),
        ),
      );

      // 加入額外的表單欄位，有些API需要這些資訊
      request.fields['file_type'] = 'csv';
      request.fields['upload_type'] = 'shop_data';

      debugPrint('📁 上傳檔案：$filename (${csvBytes.length} bytes)');

      // 發送請求
      debugPrint('📤 發送 API 請求...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📨 API 回應狀態碼: ${response.statusCode}');
      debugPrint('📨 API 回應內容: ${response.body}');

      // 處理回應
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        uploadResult.value = responseData;

        // 檢查業務邏輯狀態
        final status = responseData['Status'] ?? responseData['status'] ?? 0;
        final message =
            responseData['message'] ?? responseData['Message'] ?? '未知錯誤';

        // 解析 SID - 檢查多層結構
        String sid = '';
        if (responseData['sid'] != null) {
          sid = responseData['sid'].toString();
        } else if (responseData['SID'] != null) {
          sid = responseData['SID'].toString();
        } else if (responseData['data'] != null &&
            responseData['data']['upload_shop'] != null &&
            responseData['data']['upload_shop']['sid'] != null) {
          sid = responseData['data']['upload_shop']['sid'].toString();
        }

        debugPrint('✅ 商店新增成功 - SID: $sid, 狀態: $status');

        if (status == 1) {
          // 成功
          Get.snackbar(
            '✅ 新增成功',
            '商店編號：$sid\n$message',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Get.theme.colorScheme.primaryContainer,
            colorText: Get.theme.colorScheme.onPrimaryContainer,
            duration: const Duration(seconds: 4),
          );

          return {
            'success': true,
            'status': status,
            'sid': sid,
            'message': message,
          };
        } else {
          // 業務邏輯錯誤
          throw Exception('新增商店失敗：$message');
        }
      } else {
        throw Exception('API 請求失敗：HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 嘗試第 $attemptNumber 次上傳失敗：$e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// ==========================================
  /// 取得進件資料列表
  /// ==========================================
  Future<ApplicationModel?> getApplicationList() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _applicationService.getApplicationList();

      if (result.isSuccess) {
        // 將 API 回應轉換成 ApplicationModel
        final model = ApplicationModel.fromJson(result.data!);
        debugPrint('🔄 取得案件列表成功：${model.data.length} 筆');
        // 更新觀察變數
        applicationModel.value = model;
        applicationList.value = model.data;
        totalItems.value = model.count;

        return model;
      } else {
        _handleError(result.error ?? '取得案件列表失敗');
        return null;
      }
    } catch (e) {
      _handleError('取得案件列表時發生錯誤：$e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// ==========================================
  /// 案件審核結果：拒絕
  /// ==========================================
  Future<bool> applicationReject(int applicationId, String reviewNote) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _applicationService.applicationReject(
        applicationId: applicationId,
        reviewNote: reviewNote,
      );

      if (result.isSuccess) {
        debugPrint('🔄 拒絕成功：$reviewNote');
        // 移除 snackbar，由 View 層處理 UI 反饋
        return true;
      } else {
        _handleError(result.error ?? '拒絕案件失敗');
        return false;
      }
    } catch (e) {
      _handleError('拒絕案件時發生錯誤：$e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ==========================================
  /// 案件審核結果：通過
  /// ==========================================
  Future<bool> applicationApprove(int applicationId, String reviewNote) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _applicationService.applicationApprove(
        applicationId: applicationId,
        reviewNote: reviewNote,
      );

      if (result.isSuccess) {
        Get.snackbar(
          '✅ 批准成功',
          '案件 #$applicationId 已被批准',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer,
        );
        return true;
      } else {
        _handleError(result.error ?? '批准案件失敗');
        return false;
      }
    } catch (e) {
      _handleError('批准案件時發生錯誤：$e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ==========================================
  /// 檢查案件是否已審核
  /// ==========================================
  Future<bool> isApplicationReviewed(int applicationId) async {
    try {
      final result = await _applicationService.isApplicationReviewed(
        applicationId,
      );

      if (result.isSuccess) {
        return true;
      } else {
        _handleError(result.error ?? '檢查審核狀態失敗');
        return false;
      }
    } catch (e) {
      _handleError('檢查審核狀態時發生錯誤：$e');
      return false;
    }
  }

  /// 統一錯誤處理
  void _handleError(String error) {
    hasError.value = true;
    errorMessage.value = error;
    Get.snackbar(
      '❌ 錯誤',
      error,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      colorText: Get.theme.colorScheme.onErrorContainer,
    );
  }

  /// ==========================================
  /// 選擇CSV檔案並呼叫API上傳與新增商店
  /// 整合 pickAndUploadCSVFile() 與 uploadAddShop() 的功能
  /// 讓使用者選擇檔案後直接進行商店新增程序
  /// ==========================================
  Future<bool> uploadCSVAndAddShop() async {
    try {
      // 第一步：選擇並解析CSV檔案
      debugPrint('🔄 開始選擇CSV檔案...');
      await _pickCSVFileForUpload();

      // 檢查是否成功選擇檔案
      if (rawCsvContent.value.isEmpty || selectedFileName.value.isEmpty) {
        throw Exception('未選擇檔案或檔案內容為空');
      }

      debugPrint('✅ 檔案選擇完成：${selectedFileName.value}');

      // 第二步：直接上傳到API進行商店新增
      debugPrint('🚀 開始上傳檔案並新增商店...');
      final result = await uploadAddShop();

      if (result['success'] == true) {
        debugPrint('✅ 商店新增成功');

        // 顯示成功訊息
        final sid = result['sid'] ?? '';
        final message = result['message'] ?? '新增成功';

        Get.snackbar(
          '🎉 一次完成！',
          '檔案已上傳並成功新增商店！\n商店編號：$sid\n$message',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer,
          duration: const Duration(seconds: 5),
        );

        return true;
      } else {
        throw Exception(result['error'] ?? '上傳失敗');
      }
    } catch (e) {
      // 統一錯誤處理
      hasError.value = true;
      errorMessage.value = '選擇檔案並新增商店失敗：$e';

      Get.snackbar(
        '❌ 操作失敗',
        '選擇檔案並新增商店失敗：$e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        duration: const Duration(seconds: 4),
      );

      return false;
    }
  }

  /// 內部方法：選擇CSV檔案並準備上傳（不顯示上傳成功訊息）
  Future<void> _pickCSVFileForUpload() async {
    try {
      isFileUploading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      uploadResult.value = null;

      // 使用 file_picker 選取檔案
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        selectedFileName.value = file.name;

        // 讀取檔案內容
        String csvString;
        if (file.bytes != null) {
          // Web 平台使用 bytes
          csvString = _decodeBytes(file.bytes!);
        } else if (file.path != null) {
          // 桌面/移動平台使用 path
          final csvFile = File(file.path!);
          final bytes = await csvFile.readAsBytes();
          csvString = _decodeBytes(bytes);
        } else {
          throw Exception('無法讀取檔案內容');
        }

        // 存儲原始 CSV 內容供 API 上傳使用
        rawCsvContent.value = csvString;

        await _processCsvContent(csvString);

        debugPrint('📁 檔案準備完成：${file.name}');
      } else {
        // 使用者取消選取
        throw Exception('使用者取消選擇檔案');
      }
    } finally {
      isFileUploading.value = false;
    }
  }

  /// ==========================================
  /// 案件審核結果：資料錯誤退回重新輸入
  /// ==========================================
  Future<bool> caseReviewFailed(int applicationId, String reviewNote) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _applicationService.caseReviewFailed(
        applicationId: applicationId,
        reviewNote: reviewNote,
      );

      if (result.isSuccess) {
        Get.snackbar(
          '✅ 批准成功',
          '案件 #$applicationId 已被批准',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer,
        );
        return true;
      } else {
        _handleError(result.error ?? '批准案件失敗');
        return false;
      }
    } catch (e) {
      _handleError('批准案件時發生錯誤：$e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ==========================================
  /// 案件審核結果：結案
  /// ==========================================
  Future<bool> caseClose(int applicationId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _applicationService.applicationCaseClose(
        applicationId: applicationId,
      );

      if (result.isSuccess) {
        Get.snackbar(
          '✅ 批准成功',
          '案件 #$applicationId 已被批准',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer,
        );
        return true;
      } else {
        _handleError(result.error ?? '批准案件失敗');
        return false;
      }
    } catch (e) {
      _handleError('批准案件時發生錯誤：$e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ==========================================
  /// 分頁相關方法
  /// ==========================================

  /// 設定每頁顯示數量
  void setItemsPerPage(int items) {
    itemsPerPage.value = items;
    currentPage.value = 1; // 重置到第一頁
    getApplicationList(); // 重新載入資料
  }

  /// 前往指定頁面
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
      getApplicationList();
    }
  }

  /// 下一頁
  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
      getApplicationList();
    }
  }

  /// 上一頁
  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      getApplicationList();
    }
  }

  /// 計算總頁數
  int get totalPages {
    if (totalItems.value == 0) return 1;
    return (totalItems.value / itemsPerPage.value).ceil();
  }

  /// 取得當前頁面的資料
  List<Application> get paginatedList {
    // 首先按申請建立時間升序排序
    final sortedList = List<Application>.from(applicationList);
    sortedList.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = (startIndex + itemsPerPage.value).clamp(
      0,
      sortedList.length,
    );

    if (startIndex >= sortedList.length) return [];

    return sortedList.sublist(startIndex, endIndex);
  }

  /// 取得分頁資訊文字
  String get paginationInfo {
    if (applicationList.isEmpty) return '共 0 筆';

    final startIndex = (currentPage.value - 1) * itemsPerPage.value + 1;
    final endIndex = (startIndex + itemsPerPage.value - 1).clamp(
      startIndex,
      totalItems.value,
    );

    return '第 $startIndex - $endIndex 筆，共 ${totalItems.value} 筆';
  }

  /// ==========================================
  /// 申請資料編輯相關方法
  /// ==========================================

  /// 設定正在編輯的申請資料
  void setEditingApplication(Application application) {
    editingApplication.value = Application(
      id: application.id,
      reviewNote: application.reviewNote,
      imageUrl: application.imageUrl,
      closeAt: application.closeAt,
      closeBy: application.closeBy,
      shopImage: application.shopImage,
      shopAddress: application.shopAddress,
      uid: application.uid,
      shopMobile: application.shopMobile,
      shopName: application.shopName,
      shopEmail: application.shopEmail,
      shopDescription: application.shopDescription,
      reviewStatus: application.reviewStatus,
      closeByName: application.closeByName,
      shopPhone: application.shopPhone,
      shopContactName: application.shopContactName,
      reviewBy: application.reviewBy,
      status: application.status,
      shopWebsite: application.shopWebsite,
      isClose: application.isClose,
      reviewerName: application.reviewerName,
      shopTaxId: application.shopTaxId,
      shopNote: application.shopNote,
      applicantIdentity: application.applicantIdentity,
      reviewAt: application.reviewAt,
      reviewByName: application.reviewByName,
      createdAt: application.createdAt,
      closerName: application.closerName,
      userName: application.userName,
    );
    hasUnsavedChanges.value = false;
  }

  /// 更新申請資料欄位
  void updateApplicationField(String fieldName, String value) {
    if (editingApplication.value == null) return;

    final current = editingApplication.value!;
    Application updatedApplication;

    switch (fieldName) {
      case 'shopName':
        if (current.shopName == value) return;
        updatedApplication = Application(
          id: current.id,
          reviewNote: current.reviewNote,
          imageUrl: current.imageUrl,
          closeAt: current.closeAt,
          closeBy: current.closeBy,
          shopImage: current.shopImage,
          shopAddress: current.shopAddress,
          uid: current.uid,
          shopMobile: current.shopMobile,
          shopName: value,
          shopEmail: current.shopEmail,
          shopDescription: current.shopDescription,
          reviewStatus: current.reviewStatus,
          closeByName: current.closeByName,
          shopPhone: current.shopPhone,
          shopContactName: current.shopContactName,
          reviewBy: current.reviewBy,
          status: current.status,
          shopWebsite: current.shopWebsite,
          isClose: current.isClose,
          reviewerName: current.reviewerName,
          shopTaxId: current.shopTaxId,
          shopNote: current.shopNote,
          applicantIdentity: current.applicantIdentity,
          reviewAt: current.reviewAt,
          reviewByName: current.reviewByName,
          createdAt: current.createdAt,
          closerName: current.closerName,
          userName: current.userName,
        );
        break;
      case 'shopTaxId':
        if (current.shopTaxId == value) return;
        updatedApplication = Application(
          id: current.id,
          reviewNote: current.reviewNote,
          imageUrl: current.imageUrl,
          closeAt: current.closeAt,
          closeBy: current.closeBy,
          shopImage: current.shopImage,
          shopAddress: current.shopAddress,
          uid: current.uid,
          shopMobile: current.shopMobile,
          shopName: current.shopName,
          shopEmail: current.shopEmail,
          shopDescription: current.shopDescription,
          reviewStatus: current.reviewStatus,
          closeByName: current.closeByName,
          shopPhone: current.shopPhone,
          shopContactName: current.shopContactName,
          reviewBy: current.reviewBy,
          status: current.status,
          shopWebsite: current.shopWebsite,
          isClose: current.isClose,
          reviewerName: current.reviewerName,
          shopTaxId: value.isEmpty ? null : value,
          shopNote: current.shopNote,
          applicantIdentity: current.applicantIdentity,
          reviewAt: current.reviewAt,
          reviewByName: current.reviewByName,
          createdAt: current.createdAt,
          closerName: current.closerName,
          userName: current.userName,
        );
        break;
      case 'shopPhone':
        if (current.shopPhone == value) return;
        updatedApplication = Application(
          id: current.id,
          reviewNote: current.reviewNote,
          imageUrl: current.imageUrl,
          closeAt: current.closeAt,
          closeBy: current.closeBy,
          shopImage: current.shopImage,
          shopAddress: current.shopAddress,
          uid: current.uid,
          shopMobile: current.shopMobile,
          shopName: current.shopName,
          shopEmail: current.shopEmail,
          shopDescription: current.shopDescription,
          reviewStatus: current.reviewStatus,
          closeByName: current.closeByName,
          shopPhone: value,
          shopContactName: current.shopContactName,
          reviewBy: current.reviewBy,
          status: current.status,
          shopWebsite: current.shopWebsite,
          isClose: current.isClose,
          reviewerName: current.reviewerName,
          shopTaxId: current.shopTaxId,
          shopNote: current.shopNote,
          applicantIdentity: current.applicantIdentity,
          reviewAt: current.reviewAt,
          reviewByName: current.reviewByName,
          createdAt: current.createdAt,
          closerName: current.closerName,
          userName: current.userName,
        );
        break;
      case 'shopContactName':
        if (current.shopContactName == value) return;
        updatedApplication = Application(
          id: current.id,
          reviewNote: current.reviewNote,
          imageUrl: current.imageUrl,
          closeAt: current.closeAt,
          closeBy: current.closeBy,
          shopImage: current.shopImage,
          shopAddress: current.shopAddress,
          uid: current.uid,
          shopMobile: current.shopMobile,
          shopName: current.shopName,
          shopEmail: current.shopEmail,
          shopDescription: current.shopDescription,
          reviewStatus: current.reviewStatus,
          closeByName: current.closeByName,
          shopPhone: current.shopPhone,
          shopContactName: value,
          reviewBy: current.reviewBy,
          status: current.status,
          shopWebsite: current.shopWebsite,
          isClose: current.isClose,
          reviewerName: current.reviewerName,
          shopTaxId: current.shopTaxId,
          shopNote: current.shopNote,
          applicantIdentity: current.applicantIdentity,
          reviewAt: current.reviewAt,
          reviewByName: current.reviewByName,
          createdAt: current.createdAt,
          closerName: current.closerName,
          userName: current.userName,
        );
        break;
      case 'shopMobile':
        if (current.shopMobile == value) return;
        updatedApplication = Application(
          id: current.id,
          reviewNote: current.reviewNote,
          imageUrl: current.imageUrl,
          closeAt: current.closeAt,
          closeBy: current.closeBy,
          shopImage: current.shopImage,
          shopAddress: current.shopAddress,
          uid: current.uid,
          shopMobile: value.isEmpty ? null : value,
          shopName: current.shopName,
          shopEmail: current.shopEmail,
          shopDescription: current.shopDescription,
          reviewStatus: current.reviewStatus,
          closeByName: current.closeByName,
          shopPhone: current.shopPhone,
          shopContactName: current.shopContactName,
          reviewBy: current.reviewBy,
          status: current.status,
          shopWebsite: current.shopWebsite,
          isClose: current.isClose,
          reviewerName: current.reviewerName,
          shopTaxId: current.shopTaxId,
          shopNote: current.shopNote,
          applicantIdentity: current.applicantIdentity,
          reviewAt: current.reviewAt,
          reviewByName: current.reviewByName,
          createdAt: current.createdAt,
          closerName: current.closerName,
          userName: current.userName,
        );
        break;
      case 'shopWebsite':
        if (current.shopWebsite == value) return;
        updatedApplication = Application(
          id: current.id,
          reviewNote: current.reviewNote,
          imageUrl: current.imageUrl,
          closeAt: current.closeAt,
          closeBy: current.closeBy,
          shopImage: current.shopImage,
          shopAddress: current.shopAddress,
          uid: current.uid,
          shopMobile: current.shopMobile,
          shopName: current.shopName,
          shopEmail: current.shopEmail,
          shopDescription: current.shopDescription,
          reviewStatus: current.reviewStatus,
          closeByName: current.closeByName,
          shopPhone: current.shopPhone,
          shopContactName: current.shopContactName,
          reviewBy: current.reviewBy,
          status: current.status,
          shopWebsite: value,
          isClose: current.isClose,
          reviewerName: current.reviewerName,
          shopTaxId: current.shopTaxId,
          shopNote: current.shopNote,
          applicantIdentity: current.applicantIdentity,
          reviewAt: current.reviewAt,
          reviewByName: current.reviewByName,
          createdAt: current.createdAt,
          closerName: current.closerName,
          userName: current.userName,
        );
        break;
      case 'shopEmail':
        if (current.shopEmail == value) return;
        updatedApplication = Application(
          id: current.id,
          reviewNote: current.reviewNote,
          imageUrl: current.imageUrl,
          closeAt: current.closeAt,
          closeBy: current.closeBy,
          shopImage: current.shopImage,
          shopAddress: current.shopAddress,
          uid: current.uid,
          shopMobile: current.shopMobile,
          shopName: current.shopName,
          shopEmail: value.isEmpty ? null : value,
          shopDescription: current.shopDescription,
          reviewStatus: current.reviewStatus,
          closeByName: current.closeByName,
          shopPhone: current.shopPhone,
          shopContactName: current.shopContactName,
          reviewBy: current.reviewBy,
          status: current.status,
          shopWebsite: current.shopWebsite,
          isClose: current.isClose,
          reviewerName: current.reviewerName,
          shopTaxId: current.shopTaxId,
          shopNote: current.shopNote,
          applicantIdentity: current.applicantIdentity,
          reviewAt: current.reviewAt,
          reviewByName: current.reviewByName,
          createdAt: current.createdAt,
          closerName: current.closerName,
          userName: current.userName,
        );
        break;
      case 'shopAddress':
        if (current.shopAddress == value) return;
        updatedApplication = Application(
          id: current.id,
          reviewNote: current.reviewNote,
          imageUrl: current.imageUrl,
          closeAt: current.closeAt,
          closeBy: current.closeBy,
          shopImage: current.shopImage,
          shopAddress: value,
          uid: current.uid,
          shopMobile: current.shopMobile,
          shopName: current.shopName,
          shopEmail: current.shopEmail,
          shopDescription: current.shopDescription,
          reviewStatus: current.reviewStatus,
          closeByName: current.closeByName,
          shopPhone: current.shopPhone,
          shopContactName: current.shopContactName,
          reviewBy: current.reviewBy,
          status: current.status,
          shopWebsite: current.shopWebsite,
          isClose: current.isClose,
          reviewerName: current.reviewerName,
          shopTaxId: current.shopTaxId,
          shopNote: current.shopNote,
          applicantIdentity: current.applicantIdentity,
          reviewAt: current.reviewAt,
          reviewByName: current.reviewByName,
          createdAt: current.createdAt,
          closerName: current.closerName,
          userName: current.userName,
        );
        break;
      case 'shopDescription':
        if (current.shopDescription == value) return;
        updatedApplication = Application(
          id: current.id,
          reviewNote: current.reviewNote,
          imageUrl: current.imageUrl,
          closeAt: current.closeAt,
          closeBy: current.closeBy,
          shopImage: current.shopImage,
          shopAddress: current.shopAddress,
          uid: current.uid,
          shopMobile: current.shopMobile,
          shopName: current.shopName,
          shopEmail: current.shopEmail,
          shopDescription: value.isEmpty ? null : value,
          reviewStatus: current.reviewStatus,
          closeByName: current.closeByName,
          shopPhone: current.shopPhone,
          shopContactName: current.shopContactName,
          reviewBy: current.reviewBy,
          status: current.status,
          shopWebsite: current.shopWebsite,
          isClose: current.isClose,
          reviewerName: current.reviewerName,
          shopTaxId: current.shopTaxId,
          shopNote: current.shopNote,
          applicantIdentity: current.applicantIdentity,
          reviewAt: current.reviewAt,
          reviewByName: current.reviewByName,
          createdAt: current.createdAt,
          closerName: current.closerName,
          userName: current.userName,
        );
        break;
      case 'shopNote':
        if (current.shopNote == value) return;
        updatedApplication = Application(
          id: current.id,
          reviewNote: current.reviewNote,
          imageUrl: current.imageUrl,
          closeAt: current.closeAt,
          closeBy: current.closeBy,
          shopImage: current.shopImage,
          shopAddress: current.shopAddress,
          uid: current.uid,
          shopMobile: current.shopMobile,
          shopName: current.shopName,
          shopEmail: current.shopEmail,
          shopDescription: current.shopDescription,
          reviewStatus: current.reviewStatus,
          closeByName: current.closeByName,
          shopPhone: current.shopPhone,
          shopContactName: current.shopContactName,
          reviewBy: current.reviewBy,
          status: current.status,
          shopWebsite: current.shopWebsite,
          isClose: current.isClose,
          reviewerName: current.reviewerName,
          shopTaxId: current.shopTaxId,
          shopNote: value.isEmpty ? null : value,
          applicantIdentity: current.applicantIdentity,
          reviewAt: current.reviewAt,
          reviewByName: current.reviewByName,
          createdAt: current.createdAt,
          closerName: current.closerName,
          userName: current.userName,
        );
        break;
      default:
        return; // 未知欄位，不做任何處理
    }

    editingApplication.value = updatedApplication;
    hasUnsavedChanges.value = true;
  }

  /// 儲存申請資料
  Future<bool> saveApplicationData() async {
    if (editingApplication.value == null) {
      _handleError('沒有可儲存的資料');
      return false;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // TODO: 實現儲存 API 調用
      // final result = await _applicationService.updateApplication(editingApplication.value!);

      // 暫時模擬儲存成功
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        '✅ 儲存成功',
        '申請資料已更新',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );

      hasUnsavedChanges.value = false;
      return true;
    } catch (e) {
      _handleError('儲存資料時發生錯誤：$e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 重置變更
  void resetChanges() {
    hasUnsavedChanges.value = false;
    editingApplication.value = null;
  }

  /// 檢查是否有未儲存的變更
  bool get hasChanges => hasUnsavedChanges.value;

  /// ==========================================
  /// 狀態管理方法
  /// ==========================================

  /// 清除錯誤狀態
  void clearErrorState() {
    hasError.value = false;
    errorMessage.value = '';
    debugPrint('🧹 已清除錯誤狀態');
  }

  /// 清除所有狀態（用於頁面重置）
  void clearAllStates() {
    clearErrorState();
    isLoading.value = false;
    hasUnsavedChanges.value = false;
    debugPrint('🧹 已清除所有狀態');
  }

  /// ==========================================
  /// 取得進件資料列表
  /// ==========================================
  Future<ApplicationLogModel?> getApplicationLogList(
    int id,
    String type,
  ) async {
    // 初始化觀察變數
    applicationLogModel.value = ApplicationLogModel(
      status: 0,
      message: '',
      count: 0,
      applicationLog: [],
    );
    applicationLogList.value = [];
    totalLogItems.value = 0;

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _applicationService.getApplicationLogList(id, type);

      if (result.isSuccess) {
        // 將 API 回應轉換成 ApplicationModel
        final model = ApplicationLogModel.fromJson(result.data!);
        debugPrint('🔄 取得案件列表成功：${model.applicationLog.length} 筆');
        // 更新觀察變數
        applicationLogModel.value = model;
        applicationLogList.value = model.applicationLog;
        totalLogItems.value = model.count;

        return model;
      } else {
        _handleError(result.error ?? '取得案件列表失敗');
        return null;
      }
    } catch (e) {
      _handleError('取得案件列表時發生錯誤：$e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 取得進件資料列表 CSV
  /// ==========================================
  Future<AppleicationCsvModel?> getApplicationCsvList(
    int id,
    String type,
  ) async {
    // 初始化觀察變數

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _applicationService.getApplicationCsvList(id, type);

      if (result.isSuccess) {
        // 將 API 回應轉換成 ApplicationModel
        final model = AppleicationCsvModel.fromJson(result.data!);
        debugPrint('🔄 取得案件列表成功：${model.csv.length} 筆');
        return model;
      } else {
        _handleError(result.error ?? '取得案件列表失敗');
        return null;
      }
    } catch (e) {
      _handleError('取得案件列表時發生錯誤：$e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// ==========================================
  /// 下載 CSV 檔案
  /// ==========================================
  Future<void> downloadCsvFile(int id, String type, String shopName) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      debugPrint('🔄 開始取得 CSV 資料...');

      // 取得 CSV 資料
      final csvModel = await getApplicationCsvList(id, type);

      if (csvModel == null || csvModel.csv.isEmpty) {
        throw Exception('沒有可下載的資料');
      }

      // 將 List<String> 轉換為 CSV 文字內容
      final csvContent = csvModel.csv.join('');

      // 生成檔案名稱
      // 取得日期 MM_DD
      final date = DateTime.now().toString().split(' ')[0].split('-').join('_');
      // 取得  timestamp 最後 6 碼
      final timestamp = DateTime.now().millisecondsSinceEpoch
          .toString()
          .substring(
            DateTime.now().millisecondsSinceEpoch.toString().length - 6,
          );
      final fileName = '${shopName}_${date}_$timestamp.csv';

      debugPrint('📁 準備下載檔案：$fileName (${csvContent.length} 字元)');

      if (kIsWeb) {
        // Web 平台：使用瀏覽器下載
        _downloadForWeb(csvContent, fileName);
      } else {
        // 非 Web 平台：儲存到檔案系統
        await _downloadForNonWeb(csvContent, fileName);
      }

      Get.snackbar(
        '✅ 下載成功',
        '檔案 $fileName 已準備下載',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      _handleError('下載 CSV 檔案時發生錯誤：$e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Web 平台檔案下載
  void _downloadForWeb(String content, String fileName) {
    // 轉換為 UTF-8 bytes 並加上 BOM
    final bytes = [0xEF, 0xBB, 0xBF] + utf8.encode(content);
    final blob = html.Blob([Uint8List.fromList(bytes)], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // 建立下載連結並觸發下載
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();

    html.Url.revokeObjectUrl(url);
    debugPrint('✅ Web 檔案下載觸發完成');
  }

  /// 非 Web 平台檔案下載（儲存到下載資料夾）
  Future<void> _downloadForNonWeb(String content, String fileName) async {
    try {
      // 對於非 Web 平台，我們可以使用 file_picker 讓使用者選擇儲存位置
      final result = await FilePicker.platform.saveFile(
        dialogTitle: '儲存 CSV 檔案',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final file = File(result);
        // 寫入 UTF-8 BOM + 內容
        final bytes = [0xEF, 0xBB, 0xBF] + utf8.encode(content);
        await file.writeAsBytes(bytes);
        debugPrint('✅ 檔案已儲存到：$result');
      } else {
        debugPrint('⚠️  使用者取消儲存');
      }
    } catch (e) {
      throw Exception('儲存檔案失敗：$e');
    }
  }
}
