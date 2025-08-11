import 'package:admin/app/core/utils/responsive_utils.dart';
import 'package:admin/app/core/widgets/responsive_layout.dart';
import 'package:admin/app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/application/application_model.dart';
import '../controllers/application_controller.dart';

class ApplicationRequest extends StatefulWidget {
  final String channel;
  const ApplicationRequest({super.key, required this.channel});

  @override
  State<ApplicationRequest> createState() => _ApplicationRequestState();
}

class _ApplicationRequestState extends State<ApplicationRequest> {
  late final ApplicationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ApplicationController>();

    // 清除之前的錯誤狀態
    controller.clearErrorState();

    // 每次進入頁面時載入資料
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getApplicationList(widget.channel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('商店進件管理'), centerTitle: true),
      body: _buildApplicationBody(context),
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
                onPressed:
                    () =>
                        controller.getApplicationList(controller.channel.value),
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
            children: [_buildMainContent(context)],
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
              ElevatedButton.icon(
                onPressed:
                    () =>
                        controller.getApplicationList(controller.channel.value),
                icon: const Icon(Icons.refresh),
                label: const Text('重新整理'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 篩選按鈕群組（Bootstrap 5 風格）
          _buildBootstrapFilterButtons(context),
          const SizedBox(height: 20),

          // 分頁控制
          _buildPaginationControls(context),
          const SizedBox(height: 16),

          // 申請列表表格（需隨篩選/資料變動更新）
          Obx(() => _buildApplicationTable(context)),

          const SizedBox(height: 16),
          // 分頁資訊和導航
          _buildPaginationInfo(context),
        ],
      ),
    );
  }

  /// Bootstrap 5 風格的篩選按鈕群組
  Widget _buildBootstrapFilterButtons(BuildContext context) {
    return Obx(() {
      final ColorScheme cs = Theme.of(context).colorScheme;

      Widget buildBtn({
        required String text,
        required String value,
        required Color bg,
        required Color fg,
        required Color border,
      }) {
        final bool active = controller.requestFilter.value == value;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: OutlinedButton(
            onPressed: () => controller.setRequestFilter(value),
            style: OutlinedButton.styleFrom(
              backgroundColor: active ? bg : Colors.transparent,
              foregroundColor: active ? fg : cs.primary,
              side: BorderSide(color: active ? border : cs.primary),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      }

      return Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          children: [
            buildBtn(
              text: '未核准',
              value: 'PENDING_REVIEW',
              bg: const Color(0xFFF8D7DA),
              fg: const Color(0xFF842029),
              border: const Color(0xFFF5C2C7),
            ),
            buildBtn(
              text: '處理中',
              value: 'IN_PROGRESS',
              bg: const Color(0xFFFFECB5),
              fg: const Color(0xFF664D03),
              border: const Color(0xFFFFE69C),
            ),
            buildBtn(
              text: '待複檢',
              value: 'WAITING_REVIEW2',
              bg: const Color(0xFFCFE2FF),
              fg: const Color(0xFF084298),
              border: const Color(0xFFB6D4FE),
            ),
            buildBtn(
              text: '全部',
              value: 'ALL',
              bg: const Color(0xFFD1E7DD),
              fg: const Color(0xFF0F5132),
              border: const Color(0xFFBADBCC),
            ),
          ],
        ),
      );
    });
  }

  /// 建立申請列表表格
  Widget _buildApplicationTable(BuildContext context) {
    if (controller.applicationList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                '目前沒有申請案件',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: _buildTableColumns(),
        rows: _buildTableRows(context),
        columnSpacing: 20,
        headingRowHeight: 56,
        dataRowHeight: 72,
        sortColumnIndex: 8, // 按申請建立時間排序
        sortAscending: true,
      ),
    );
  }

  /// 建立表格欄位標題
  List<DataColumn> _buildTableColumns() {
    return [
      const DataColumn(label: Text('申請序號')),
      const DataColumn(label: Text('商店名稱')),
      const DataColumn(label: Text('申請人')),
      const DataColumn(label: Text('審核人姓名')),
      const DataColumn(label: Text('結案人姓名')),
      const DataColumn(label: Text('審核結果')),
      const DataColumn(label: Text('狀態')),
      const DataColumn(label: Text('審核附註')),
      const DataColumn(label: Text('申請建立時間')),
      const DataColumn(label: Text('操作')),
    ];
  }

  /// 建立表格行資料
  List<DataRow> _buildTableRows(BuildContext context) {
    // 取得當前頁面的資料（已經在controller中排序）
    final paginatedList = controller.paginatedList;

    return paginatedList.map((application) {
      return DataRow(
        cells: [
          DataCell(Text(application.id.toString())),

          DataCell(
            SizedBox(
              width: 120,
              child: Text(
                application.shopName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          DataCell(Text(application.userName)),

          DataCell(Text(application.reviewByName ?? '-')),
          DataCell(Text(application.closeByName ?? '-')),
          DataCell(_buildReviewStatusChip(application.reviewStatus)),
          DataCell(_buildStatusChip(application.status)),
          DataCell(
            SizedBox(
              width: 100,
              child: Text(
                application.reviewNote ?? '-',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          DataCell(Text(_formatDateTime(application.createdAt))),
          DataCell(_buildActionButtons(context, application)),
        ],
      );
    }).toList();
  }

  /// 建立狀態晶片
  Widget _buildStatusChip(String status) {
    String label;
    Color color;

    switch (status) {
      case '0':
        label = '新案件';
        color = Colors.blue;
        break;
      case '1':
        label = '作業中';
        color = Colors.orange;
        break;
      case '2':
        label = '新增完成';
        color = Colors.green;
        break;
      case '3':
        label = '複製資料';
        color = Colors.purple;
        break;
      case '4':
        label = '等待複檢';
        color = Colors.amber;
        break;
      case '5':
        label = '結案';
        color = Colors.grey;
        break;
      default:
        label = '未知';
        color = Colors.grey;
    }

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }

  /// 建立審核結果晶片
  Widget _buildReviewStatusChip(String reviewStatus) {
    Color color;
    String label = reviewStatus;

    switch (reviewStatus) {
      case 'PENDING':
      case 'PENDDING':
        color = Colors.orange;
        label = '擱置中';
        break;
      case 'APPROVE':
        color = Colors.green;
        label = '已核准';
        break;
      case 'REJECT':
        color = Colors.red;
        label = '已拒絕';
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }

  /// 建立操作按鈕
  Widget _buildActionButtons(BuildContext context, Application application) {
    final authService = AuthService.instance;
    final currentUid = authService.currentUid;

    // 權限控制邏輯
    bool canEdit = false;
    bool canView = true;

    if (application.reviewBy == null || application.reviewBy!.isEmpty) {
      // 沒有審核人，所有人都可以編輯
      canEdit = true;
    } else if (application.reviewBy == currentUid) {
      // 當前用戶是審核人，可以編輯
      canEdit = true;
    } else {
      // 其他人只能檢視
      canEdit = false;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canEdit)
          TextButton.icon(
            onPressed: () => _navigateToEdit(application, true),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('編輯'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        if (canView)
          TextButton.icon(
            onPressed: () => _navigateToEdit(application, false),
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('檢視'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
      ],
    );
  }

  /// 導航到編輯/檢視頁面
  void _navigateToEdit(Application application, bool isEditMode) {
    Get.toNamed(
      '/application/edit',
      arguments: {'application': application, 'isEditMode': isEditMode},
    );
  }

  /// 建立分頁控制
  Widget _buildPaginationControls(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          const Text('每頁顯示：'),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: controller.itemsPerPage.value,
            items:
                controller.pageOptions.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value 筆'),
                  );
                }).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                controller.setItemsPerPage(newValue, controller.channel.value);
              }
            },
          ),
          const Spacer(),
          Text(controller.paginationInfo),
        ],
      ),
    );
  }

  /// 建立分頁資訊和導航
  Widget _buildPaginationInfo(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed:
                controller.currentPage.value > 1
                    ? () => controller.previousPage(controller.channel.value)
                    : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: '上一頁',
          ),
          const SizedBox(width: 16),
          Text(
            '第 ${controller.currentPage.value} 頁，共 ${controller.totalPages} 頁',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed:
                controller.currentPage.value < controller.totalPages
                    ? () => controller.nextPage(controller.channel.value)
                    : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: '下一頁',
          ),
        ],
      ),
    );
  }

  /// 格式化日期時間
  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }
}
