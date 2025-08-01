import 'package:admin/app/core/utils/responsive_utils.dart';
import 'package:admin/app/core/widgets/responsive_navigation.dart';
import 'package:admin/app/models/emplyoee/emplyoee_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employee_controller.dart';

class EmployeeEditView extends GetView<EmployeeController> {
  const EmployeeEditView({super.key});

  // Navigation items
  static final List<NavigationItem> navigationItems = [
    NavigationItem(title: '儀表板', icon: Icons.dashboard, route: '/dashboard'),
    NavigationItem(title: '用戶管理', icon: Icons.people, route: '/users'),
    NavigationItem(title: '訂單管理', icon: Icons.shopping_cart, route: '/orders'),
    NavigationItem(title: '產品管理', icon: Icons.inventory, route: '/products'),
    NavigationItem(title: '員工管理', icon: Icons.inventory, route: '/emplyoee'),
    NavigationItem(title: '設定', icon: Icons.settings, route: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveNavigation(
      navigationItems: navigationItems,
      header: _buildHeader(context),
      body: _buildEditBody(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final String? encodedEmail = Get.parameters['email'];
    final bool isAddMode = encodedEmail == 'add';

    return Row(
      children: [
        Icon(
          isAddMode ? Icons.person_add : Icons.edit,
          color: Theme.of(context).colorScheme.primary,
          size: context.responsive(mobile: 24.0, tablet: 28.0, desktop: 32.0),
        ),
        const SizedBox(width: 12),
        Text(
          isAddMode ? '新增員工資料' : '編輯員工資料',
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildEditBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // 取得傳入的 email 參數並解碼
      final String? encodedEmail = Get.parameters['email'];
      if (encodedEmail == null) {
        return _buildErrorMessage('未指定員工 Email');
      }

      // 檢查是否為新增模式
      if (encodedEmail == 'add') {
        // 新增員工資料
        return _buildAddForm(context);
      }

      final String email = Uri.decodeComponent(encodedEmail);

      // 從 employeeList 中找到對應的員工
      final EmployeeList? employee = controller.employeeList.firstWhereOrNull(
        (emp) => emp.email == email,
      );

      if (employee == null) {
        return _buildErrorMessage('找不到 Email 為 $email 的員工');
      }
      // 編輯員工資料
      return _buildEditForm(context, employee);
    });
  }

  Widget _buildErrorMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => Get.back(), child: const Text('返回')),
        ],
      ),
    );
  }

  Widget _buildAddForm(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final employeeIdController = TextEditingController();

    final RxString selectedLevel = '1'.obs; // 預設為計時人員
    final RxBool selectedStatus = true.obs; // 預設啟用

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '新增員工資料',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 員工編號
                  _buildTextField(
                    controller: employeeIdController,
                    label: '員工編號',
                    icon: Icons.badge,
                  ),
                  const SizedBox(height: 16),

                  // 姓名
                  _buildTextField(
                    controller: nameController,
                    label: '姓名',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _buildTextField(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 16),

                  // 職級下拉選單
                  Obx(() {
                    final options = _getLevelOptions();
                    // 如果當前值不在選項中，自動設定為第一個選項
                    if (!options.contains(selectedLevel.value) &&
                        options.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        selectedLevel.value = options.first;
                      });
                    }
                    return _buildDropdownField(
                      value: selectedLevel.value,
                      label: '職級',
                      icon: Icons.work,
                      items: options,
                      onChanged: (value) => selectedLevel.value = value ?? '',
                    );
                  }),
                  const SizedBox(height: 16),

                  // 狀態開關
                  Obx(
                    () => _buildSwitchField(
                      value: selectedStatus.value,
                      label: '帳號狀態',
                      subtitle: selectedStatus.value ? '啟用' : '停用',
                      onChanged: (value) => selectedStatus.value = value,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 按鈕區域
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed:
                            () => _addEmployee(
                              nameController.text,
                              emailController.text,
                              employeeIdController.text,
                              selectedLevel.value,
                              selectedStatus.value,
                            ),
                        child: const Text('新增'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditForm(BuildContext context, EmployeeList employee) {
    final nameController = TextEditingController(text: employee.name);
    final emailController = TextEditingController(text: employee.email);
    final employeeIdController = TextEditingController(
      text: employee.employeeId,
    );

    final RxString selectedLevel = employee.level.obs;
    final RxBool selectedStatus = employee.status.obs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '編輯員工資料',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 員工編號
                  _buildTextField(
                    controller: employeeIdController,
                    label: '員工編號',
                    icon: Icons.badge,
                    enabled: false, // 通常不允許修改員工編號
                  ),
                  const SizedBox(height: 16),

                  // 姓名
                  _buildTextField(
                    controller: nameController,
                    label: '姓名',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _buildTextField(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.email,
                    enabled: false, // 編輯模式下 Email 不可修改
                  ),
                  const SizedBox(height: 16),

                  // 職級下拉選單
                  Obx(() {
                    final options = _getLevelOptions();
                    // 如果當前值不在選項中，自動設定為第一個選項
                    if (!options.contains(selectedLevel.value) &&
                        options.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        selectedLevel.value = options.first;
                      });
                    }
                    return _buildDropdownField(
                      value: selectedLevel.value,
                      label: '職級',
                      icon: Icons.work,
                      items: options,
                      onChanged: (value) => selectedLevel.value = value ?? '',
                    );
                  }),
                  const SizedBox(height: 16),

                  // 狀態開關
                  Obx(
                    () => _buildSwitchField(
                      value: selectedStatus.value,
                      label: '帳號狀態',
                      subtitle: selectedStatus.value ? '啟用' : '停用',
                      onChanged: (value) => selectedStatus.value = value,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 建立和修改時間顯示
                  _buildInfoRow('建立時間', _formatDateTime(employee.createdAt)),
                  const SizedBox(height: 8),
                  _buildInfoRow('最後修改', _formatDateTime(employee.modifiedAt)),

                  const SizedBox(height: 32),

                  // 按鈕區域
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed:
                            () => _saveEmployee(
                              employee,
                              nameController.text,
                              emailController.text,
                              employeeIdController.text,
                              selectedLevel.value,
                              selectedStatus.value,
                            ),
                        child: const Text('儲存'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    // 確保 value 在 items 中，如果不在則使用第一個選項或 null
    String? validValue =
        items.contains(value) ? value : (items.isNotEmpty ? items.first : null);

    return DropdownButtonFormField<String>(
      value: validValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(_getLevelDisplayName(item)),
                ),
              )
              .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSwitchField({
    required bool value,
    required String label,
    required String subtitle,
    required Function(bool) onChanged,
  }) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: const Icon(Icons.toggle_on),
        title: Text(label),
        subtitle: Text(subtitle),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Text(value),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // 職級映射表
  static const Map<String, String> _levelMap = {
    '1': '計時人員',
    '2': '全職人員',
    '3': '管理人員',
    '4': '系統管理',
    '5': '超級管理員',
  };

  List<String> _getLevelOptions() {
    // 收集所有員工的職級值
    final Set<String> employeeLevels =
        controller.employeeList
            .map((emp) => emp.level)
            .where((level) => level.isNotEmpty)
            .toSet();

    // 合併預定義的職級和員工現有的職級
    final Set<String> allLevelKeys = {..._levelMap.keys, ...employeeLevels};

    return allLevelKeys.toList()..sort();
  }

  String _getLevelDisplayName(String levelValue) {
    return _levelMap[levelValue] ?? levelValue;
  }

  Future<void> _addEmployee(
    String name,
    String email,
    String employeeId,
    String level,
    bool status,
  ) async {
    debugPrint('vup addEmployee: $name, $email, $employeeId, $level, $status');
    // 檢查必填欄位
    if (name.trim().isEmpty) {
      Get.snackbar(
        '錯誤',
        '姓名不能為空',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (email.trim().isEmpty) {
      Get.snackbar(
        '錯誤',
        'Email不能為空',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (employeeId.trim().isEmpty) {
      Get.snackbar(
        '錯誤',
        '員工編號不能為空',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 檢查 email 是否已存在
    final existingEmployee = controller.employeeList.firstWhereOrNull(
      (emp) => emp.email == email.trim(),
    );
    if (existingEmployee != null) {
      Get.snackbar(
        '錯誤',
        'Email 已存在，請使用其他 Email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // // 檢查員工編號是否已存在
    // final existingId = controller.employeeList.firstWhereOrNull(
    //   (emp) => emp.employeeId == employeeId.trim(),
    // );
    // if (existingId != null) {
    //   Get.snackbar(
    //     '錯誤',
    //     '員工編號已存在，請使用其他編號',
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    //   return;
    // }

    // 這裡應該呼叫 API 新增員工資料
    // TODO: 實作新增員工資料的 API 呼叫
    bool success = await controller.addEmployee(
      name,
      email,
      level,
      status,
      employeeId,
    );
    if (success) {
      Get.snackbar(
        '成功',
        '員工資料已新增',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // 新增成功後重新載入列表並返回
      controller.fetchEmployeeList();
      Get.back();
    } else {
      Get.snackbar(
        '錯誤',
        '新增員工資料失敗',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _saveEmployee(
    EmployeeList originalEmployee,
    String name,
    String email,
    String employeeId,
    String level,
    bool status,
  ) async {
    // 檢查必填欄位
    if (name.trim().isEmpty) {
      Get.snackbar(
        '錯誤',
        '姓名不能為空',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (email.trim().isEmpty) {
      Get.snackbar(
        '錯誤',
        'Email不能為空',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 這裡應該呼叫 API 更新員工資料
    bool success = await controller.editEmployee(
      name,
      email,
      level,
      status,
      employeeId,
    );
    if (!success) {
      Get.snackbar(
        '錯誤',
        '更新員工資料失敗',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    Get.snackbar(
      '成功',
      '員工資料已更新',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // 編輯成功後重新載入列表並返回
    controller.fetchEmployeeList();
    Get.back();
  }
}
