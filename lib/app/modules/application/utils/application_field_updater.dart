import '../../../models/application/application_model.dart';

/// Application 欄位更新工具類
class ApplicationFieldUpdater {
  /// 更新 Application 的指定欄位
  ///
  /// [current] 當前的 Application 對象
  /// [fieldName] 要更新的欄位名稱
  /// [value] 新的值
  ///
  /// 返回更新後的 Application 對象，如果沒有變更則返回 null
  static Application? updateField(
    Application current,
    String fieldName,
    String value,
  ) {
    // 檢查值是否真的改變了
    if (_getCurrentValue(current, fieldName) == value) {
      return null;
    }

    // 使用 copyWith 方法來創建新的對象
    return current.copyWith(
      shopName: fieldName == 'shopName' ? value : current.shopName,
      shopTaxId:
          fieldName == 'shopTaxId'
              ? (value.isEmpty ? null : value)
              : current.shopTaxId,
      shopPhone: fieldName == 'shopPhone' ? value : current.shopPhone,
      shopContactName:
          fieldName == 'shopContactName' ? value : current.shopContactName,
      shopMobile:
          fieldName == 'shopMobile'
              ? (value.isEmpty ? null : value)
              : current.shopMobile,
      shopWebsite: fieldName == 'shopWebsite' ? value : current.shopWebsite,
      shopEmail:
          fieldName == 'shopEmail'
              ? (value.isEmpty ? null : value)
              : current.shopEmail,
      shopAddress: fieldName == 'shopAddress' ? value : current.shopAddress,
      shopDescription:
          fieldName == 'shopDescription'
              ? (value.isEmpty ? null : value)
              : current.shopDescription,
      shopNote:
          fieldName == 'shopNote'
              ? (value.isEmpty ? null : value)
              : current.shopNote,
    );
  }

  /// 獲取指定欄位的當前值
  static String? _getCurrentValue(Application application, String fieldName) {
    switch (fieldName) {
      case 'shopName':
        return application.shopName;
      case 'shopTaxId':
        return application.shopTaxId;
      case 'shopPhone':
        return application.shopPhone;
      case 'shopContactName':
        return application.shopContactName;
      case 'shopMobile':
        return application.shopMobile;
      case 'shopWebsite':
        return application.shopWebsite;
      case 'shopEmail':
        return application.shopEmail;
      case 'shopAddress':
        return application.shopAddress;
      case 'shopDescription':
        return application.shopDescription;
      case 'shopNote':
        return application.shopNote;
      case 'shopCity':
        return application.shopCity;
      case 'shopRegion':
        return application.shopRegion;
      default:
        return null;
    }
  }

  /// 檢查欄位是否有效
  static bool isValidField(String fieldName) {
    const validFields = [
      'shopName',
      'shopTaxId',
      'shopPhone',
      'shopContactName',
      'shopMobile',
      'shopWebsite',
      'shopEmail',
      'shopAddress',
      'shopDescription',
      'shopNote',
      'shopCity',
      'shopRegion',
    ];
    return validFields.contains(fieldName);
  }
}
