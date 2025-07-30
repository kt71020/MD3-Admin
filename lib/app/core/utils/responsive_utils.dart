import 'package:flutter/material.dart';

/// 響應式斷點定義
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
  static const double largeDesktop = 1920;
}

/// 設備類型枚舉
enum DeviceType { mobile, tablet, desktop, largeDesktop }

/// 響應式工具類 - 這是你做響應式的核心工具！
class ResponsiveUtils {
  /// 獲取當前設備類型
  static DeviceType getDeviceType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < ResponsiveBreakpoints.mobile) {
      return DeviceType.mobile;
    } else if (screenWidth < ResponsiveBreakpoints.tablet) {
      return DeviceType.tablet;
    } else if (screenWidth < ResponsiveBreakpoints.desktop) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  /// 檢查是否為手機
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// 檢查是否為平板
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// 檢查是否為桌面
  static bool isDesktop(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.desktop ||
        deviceType == DeviceType.largeDesktop;
  }

  /// 根據設備類型返回不同的值
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  /// 響應式字體大小
  static double responsiveFontSize(BuildContext context, double baseFontSize) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return baseFontSize;
      case DeviceType.tablet:
        return baseFontSize * 1.1;
      case DeviceType.desktop:
        return baseFontSize * 1.2;
      case DeviceType.largeDesktop:
        return baseFontSize * 1.3;
    }
  }

  /// 響應式邊距
  static EdgeInsets responsivePadding(
    BuildContext context, {
    double mobile = 16.0,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    final padding = responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
    return EdgeInsets.all(padding);
  }

  /// 響應式間距
  static double responsiveSpacing(BuildContext context, double baseSpacing) {
    return responsiveValue(
      context,
      mobile: baseSpacing,
      tablet: baseSpacing * 1.2,
      desktop: baseSpacing * 1.4,
      largeDesktop: baseSpacing * 1.6,
    );
  }

  /// 響應式網格列數
  static int responsiveGridColumns(
    BuildContext context, {
    int mobile = 1,
    int? tablet,
    int? desktop,
    int? largeDesktop,
  }) {
    return responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet ?? 2,
      desktop: desktop ?? 3,
      largeDesktop: largeDesktop ?? 4,
    );
  }

  /// 響應式容器寬度
  static double responsiveContainerWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return screenWidth * 0.95;
      case DeviceType.tablet:
        return screenWidth * 0.85;
      case DeviceType.desktop:
        return screenWidth * 0.75;
      case DeviceType.largeDesktop:
        return screenWidth * 0.65;
    }
  }
}

/// 響應式 Extension，讓你更方便使用
extension ResponsiveContext on BuildContext {
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) => ResponsiveUtils.responsiveValue(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
    largeDesktop: largeDesktop,
  );
}
