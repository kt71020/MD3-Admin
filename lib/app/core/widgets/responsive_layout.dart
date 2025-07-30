import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

/// 響應式佈局組件 - 這是你構建響應式 UI 的基礎！
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveUtils.getDeviceType(context);

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
      },
    );
  }
}

/// 響應式容器組件
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final Color? backgroundColor;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? ResponsiveUtils.responsiveContainerWidth(context),
      ),
      padding: padding ?? ResponsiveUtils.responsivePadding(context),
      decoration:
          backgroundColor != null
              ? BoxDecoration(color: backgroundColor)
              : null,
      child: child,
    );
  }
}

/// 響應式行佈局
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      // 在手機上變成垂直排列
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children:
            children
                .map(
                  (child) => Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: child,
                  ),
                )
                .toList(),
      );
    }

    // 在平板和桌面上保持水平排列
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children:
          children
              .expand(
                (child) => [
                  child,
                  if (child != children.last) SizedBox(width: spacing),
                ],
              )
              .toList(),
    );
  }
}

/// 響應式網格組件
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? largeDesktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.largeDesktopColumns,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.responsiveGridColumns(
      context,
      mobile: mobileColumns ?? 1,
      tablet: tabletColumns ?? 2,
      desktop: desktopColumns ?? 3,
      largeDesktop: largeDesktopColumns ?? 4,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// 響應式卡片組件
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? (context.isMobile ? 2.0 : 4.0),
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius:
            borderRadius ??
            BorderRadius.circular(
              context.responsive(mobile: 8.0, tablet: 12.0, desktop: 16.0),
            ),
      ),
      child: Padding(
        padding:
            padding ??
            ResponsiveUtils.responsivePadding(
              context,
              mobile: 16.0,
              tablet: 20.0,
              desktop: 24.0,
            ),
        child: child,
      ),
    );
  }
}

/// 響應式間距組件
class ResponsiveSpacing extends StatelessWidget {
  final double mobile;
  final double? tablet;
  final double? desktop;
  final double? largeDesktop;
  final bool isVertical;

  const ResponsiveSpacing({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.isVertical = true,
  });

  const ResponsiveSpacing.horizontal({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  }) : isVertical = false;

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveUtils.responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );

    return SizedBox(
      height: isVertical ? spacing : null,
      width: isVertical ? null : spacing,
    );
  }
}
