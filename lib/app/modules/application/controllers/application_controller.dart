import 'package:get/get.dart';
import 'package:admin/app/services/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../constants/api_urls.dart';

class ApplicationController extends GetxController {
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

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
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
      print('📊 開始解析多段式配置檔案...');

      // 檢查檔案基本信息
      final lines = csvContent.split('\n');
      print('檔案總行數：${lines.length}');
      print('檔案總字符數：${csvContent.length}');

      // 分段解析
      final sections = _parseConfigSections(lines);

      print('\n📋 檔案結構分析：');
      print('發現 ${sections.length} 個配置區段');

      for (final section in sections) {
        print('\n📦 區段：${section['title']}');
        print('   行數：${section['data'].length}');
        if (section['data'].isNotEmpty && section['data'].first is List) {
          print('   欄位數：${(section['data'].first as List).length}');
        }

        // 顯示前3行數據
        final data = section['data'] as List<List<dynamic>>;
        for (int i = 0; i < data.length && i < 3; i++) {
          print('   第 ${i + 1} 行：${data[i]}');
        }
      }

      // 將解析結果存儲（你可以根據需要調整存儲格式）
      csvData.value =
          sections
              .expand((section) => section['data'] as List<List<dynamic>>)
              .toList();

      print('\n✅ 成功解析多段式配置檔案');
    } catch (e) {
      print('❌ 配置檔案解析錯誤：$e');
      print('錯誤詳情：${e.toString()}');
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
    print('檔案換行符號標準化完成，共 $lineCount 行');

    return decoded;
  }

  /// 上傳商店資料到後端 API
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
          print('⚠️  嘗試 ${fileFieldNames[attempt]} 欄位失敗，嘗試下一個欄位名稱...');
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

  /// 嘗試使用指定的檔案欄位名稱上傳
  Future<Map<String, dynamic>> _attemptUpload(
    String fileFieldName,
    int attemptNumber,
  ) async {
    try {
      isApiUploading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      print('🚀 嘗試第 $attemptNumber 次上傳（欄位名稱：$fileFieldName）');

      // 檢查是否有 CSV 內容
      if (rawCsvContent.value.isEmpty) {
        throw Exception('請先選取並解析 CSV 檔案');
      }

      // 準備 API 請求
      final apiUrl = ApiUrls.getFullUrl(ApiUrls.uploadAddShopAPI);
      print('API URL: $apiUrl');

      // 建立 multipart 請求
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // 加入 Authorization 欄位
      final authService = AuthService.instance;
      request.headers['Authorization'] = authService.currentToken;

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

      print('📁 上傳檔案：$filename (${csvBytes.length} bytes)');

      // 發送請求
      print('📤 發送 API 請求...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📨 API 回應狀態碼: ${response.statusCode}');
      print('📨 API 回應內容: ${response.body}');

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

        print('✅ 商店新增成功 - SID: $sid, 狀態: $status');

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
      print('❌ 嘗試第 $attemptNumber 次上傳失敗：$e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
