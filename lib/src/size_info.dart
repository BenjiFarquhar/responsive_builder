import 'package:flutter/material.dart';

import 'package:responsive_builder/responsive_builder.dart' hide WidgetBuilder;

/// Contains sizing information to make responsive choices for the current screen
class SizeInfo {
  final DeviceScreenType deviceScreenType;
  final RefinedSize refinedSize;
  final Size screenSize;
  final Size localWidgetSize;

  bool get isMobile => deviceScreenType == DeviceScreenType.mobile;

  bool get isTablet => deviceScreenType == DeviceScreenType.tablet;

  bool get isDesktop => deviceScreenType == DeviceScreenType.desktop;

  bool get isWatch => deviceScreenType == DeviceScreenType.watch;

  // Refined

  bool get isExtraLarge => refinedSize == RefinedSize.extraLarge;

  bool get isLarge => refinedSize == RefinedSize.large;

  bool get isNormal => refinedSize == RefinedSize.normal;

  bool get isSmall => refinedSize == RefinedSize.small;

  const SizeInfo({
    required this.deviceScreenType,
    required this.refinedSize,
    required this.screenSize,
    required this.localWidgetSize,
  });

  factory SizeInfo.fromContext(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SizeInfo(
      deviceScreenType: getDeviceType(size),
      refinedSize: getRefinedSize(size),
      screenSize: size,
      localWidgetSize: const Size(0, 0),
    );
  }

  @override
  String toString() {
    return 'DeviceType:$deviceScreenType RefinedSize:$refinedSize ScreenSize:$screenSize LocalWidgetSize:$localWidgetSize';
  }

  static const _maxColumnWidthMobile = {
    RefinedSize.small: 470,
    RefinedSize.normal: 480,
    RefinedSize.large: 490,
    RefinedSize.extraLarge: 500,
  };

  static const _maxColumnWidthTablet = {
    RefinedSize.small: 510,
    RefinedSize.normal: 520,
    RefinedSize.large: 530,
    RefinedSize.extraLarge: 540,
  };

  static const _maxColumnWidthDesktop = {
    RefinedSize.small: 550,
    RefinedSize.normal: 560,
    RefinedSize.large: 570,
    RefinedSize.extraLarge: 580,
  };

  static const RefinedBreakpoints customRefinedBreakpoints = RefinedBreakpoints(
    // Desktop
    desktopExtraLarge: 1800,
    desktopLarge: 1400,
    desktopNormal: 1100,
    desktopSmall: 950,
    // Tablet
    tabletExtraLarge: 900,
    tabletLarge: 850,
    tabletNormal: 768,
    tabletSmall: 600,
    // Mobile
    mobileExtraLarge: 480,
    mobileLarge: 414,
    mobileNormal: 375,
    mobileSmall: 320,
  );

  double get maxWidth => _maxLength(this, Axis.horizontal);
  double get maxWidthL => _maxLength(this, Axis.horizontal, RefinedSize.large);
  double get maxWidthM => _maxLength(this, Axis.horizontal, RefinedSize.normal);
  double get maxWidthS => _maxLength(this, Axis.horizontal, RefinedSize.small);

  double cardSize(BuildContext context) => getValueForScreenType(
        context,
        mobile: 90,
        tabletLandscapeDesktop: 90,
        tabletPortrait: 90,
      );

  double cardSizeSmall(BuildContext context) => getValueForScreenType(
        context,
        mobile: 70,
        tabletLandscapeDesktop: 70,
        tabletPortrait: 70,
      );

  double fullWidth(BuildContext context) => MediaQuery.of(context).size.width;

  T getValueForScreenType<T>(
    BuildContext context, {
    required T mobile,
    required T tabletPortrait,
    required T tabletLandscapeDesktop,
  }) {
    if (deviceScreenType == DeviceScreenType.mobile) {
      return mobile;
    }

    if (isTabletPortrait(context)) {
      return tabletPortrait;
    }

    return tabletLandscapeDesktop;
  }

  bool isMobileLandScape(BuildContext context) {
    return deviceScreenType == DeviceScreenType.mobile &&
        (SizeUtils.isLandscape(context));
  }

  /// Used for screens that have a [VpTopNavBar]
  bool isNarrowScreen(BuildContext context) =>
      (isMobile || (isTabletPortrait(context)));

  bool isTabletLandscape(BuildContext context) {
    return deviceScreenType == DeviceScreenType.tablet &&
        (SizeUtils.isLandscape(context));
  }

  bool isTabletPortrait(BuildContext context) {
    return deviceScreenType == DeviceScreenType.tablet &&
        (SizeUtils.isPortrait(context));
  }

  /// Used for screens that have a [VpBottomNavBar]
  bool isWideScreen(BuildContext context) => !isNarrowScreen(context);

  Widget screenTypeLayoutBuilder(
    context, {
    required WidgetBuilder mobile,
    required WidgetBuilder tabletPortrait,
    required WidgetBuilder tabletLandscapeDesktop,
  }) {
    if (deviceScreenType == DeviceScreenType.desktop ||
        isTabletLandscape(context)) {
      return tabletLandscapeDesktop(context);
    }

    if (isTabletPortrait(context)) {
      return tabletPortrait(context);
    }

    return mobile(context);
  }

  /// Max landscape column width tablet
  /// Can be used to in portrait but is less often used that way
  double _maxLength(
    SizeInfo sizingInfo,
    Axis axis, [
    RefinedSize? size,
  ]) {
    double maxLength = 0;

    const maxWidthDesktop = _maxColumnWidthDesktop;
    const maxWidthTablet = _maxColumnWidthTablet;
    const maxWidthMobile = _maxColumnWidthMobile;

    // ignore: missing_enum_constant_in_switch
    switch (sizingInfo.deviceScreenType) {
      case DeviceScreenType.desktop:
        maxLength = _theMaxLength(
          sizingInfo,
          axis,
          size: size,
          maxWidths: maxWidthDesktop,
        );
        break;
      case DeviceScreenType.tablet:
        maxLength = _theMaxLength(
          sizingInfo,
          axis,
          size: size,
          maxWidths: maxWidthTablet,
        );
        break;
      case DeviceScreenType.mobile:
        maxLength = _theMaxLength(
          sizingInfo,
          axis,
          size: size,
          maxWidths: maxWidthMobile,
        );
        break;
      default:
        maxLength = _theMaxLength(
          sizingInfo,
          axis,
          size: size,
          maxWidths: maxWidthMobile,
        );
    }

    return maxLength;
  }

  double _theMaxLength(
    SizeInfo sizingInfo,
    Axis axis, {
    required Map<RefinedSize, int> maxWidths,
    RefinedSize? size,
  }) {
    double maxLength = 0;
    if (axis == Axis.horizontal) {
      // width
      maxLength = maxWidths[size ?? sizingInfo.refinedSize]!.toDouble();

      return sizingInfo.localWidgetSize.width < maxLength
          ? sizingInfo.localWidgetSize.width
          : maxLength.toDouble();
    } else {
      // height
      //do not use this
      return sizingInfo.localWidgetSize.height < maxLength
          ? sizingInfo.localWidgetSize.height
          : maxLength.toDouble();
    }
  }
}

/// Manually define screen resolution breakpoints
///
/// Overrides the defaults
class ScreenBreakpoints {
  final double watch;
  final double tablet;
  final double desktop;

  const ScreenBreakpoints({
    required this.desktop,
    required this.tablet,
    required this.watch,
  });

  @override
  String toString() {
    return "Desktop: $desktop, Tablet: $tablet, Watch: $watch";
  }
}

/// Manually define refined breakpoints
///
/// Overrides the defaults
class RefinedBreakpoints {
  final double mobileSmall;
  final double mobileNormal;
  final double mobileLarge;
  final double mobileExtraLarge;

  final double tabletSmall;
  final double tabletNormal;
  final double tabletLarge;
  final double tabletExtraLarge;

  final double desktopSmall;
  final double desktopNormal;
  final double desktopLarge;
  final double desktopExtraLarge;

  const RefinedBreakpoints({
    this.mobileSmall = 320,
    this.mobileNormal = 375,
    this.mobileLarge = 414,
    this.mobileExtraLarge = 480,
    this.tabletSmall = 600,
    this.tabletNormal = 768,
    this.tabletLarge = 850,
    this.tabletExtraLarge = 900,
    this.desktopSmall = 950,
    this.desktopNormal = 1920,
    this.desktopLarge = 3840,
    this.desktopExtraLarge = 4096,
  });

  @override
  String toString() {
    return "Desktop: Small - $desktopSmall Normal - $desktopNormal Large - $desktopLarge ExtraLarge - $desktopExtraLarge" +
        "\nTablet: Small - $tabletSmall Normal - $tabletNormal Large - $tabletLarge ExtraLarge - $tabletExtraLarge" +
        "\nMobile: Small - $mobileSmall Normal - $mobileNormal Large - $mobileLarge ExtraLarge - $mobileExtraLarge";
  }
}

/// For when you don't have [SizeInfo]
class SizeUtils {
  static bool isDesktop(BuildContext context) {
    final deviceType = _getDeviceType(context);

    return deviceType == DeviceScreenType.desktop;
  }

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// For when you don't have [SizeInfo]
  static bool isMobile(BuildContext context) {
    final deviceType = _getDeviceType(context);

    return deviceType == DeviceScreenType.mobile;
  }

  /// Is mobile landscape
  static bool isMobileLandScape([
    BuildContext? context,
    SizeInfo? sizeInfo,
  ]) {
    final deviceType = sizeInfo != null
        ? sizeInfo.deviceScreenType
        : getDeviceType(MediaQuery.of(context!).size);

    return deviceType == DeviceScreenType.mobile && (isLandscape(context!));
  }

  /// For when you don't have [SizeInfo]
  static bool isNotDesktop(BuildContext context) => !isDesktop(context);

  /// For when you don't have [SizeInfo]
  static bool isNotMobile(context) => !isMobile(context);

  /// Is not mobile landscape
  static bool isNotMobileLandscape([
    BuildContext? context,
    SizeInfo? sizeInfo,
  ]) {
    return !isMobileLandScape(context, sizeInfo);
  }

  /// For when you don't have [SizeInfo]
  static bool isNotTablet(BuildContext? context) => !isTablet(context);

  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// For when you don't have [SizeInfo]
  static bool isTablet(context) {
    final deviceType = _getDeviceType(context);

    return deviceType == DeviceScreenType.tablet;
  }

  /// For when you don't have [SizeInfo]
  static DeviceScreenType _getDeviceType(BuildContext? context) {
    final deviceType = getDeviceType(MediaQuery.of(context!).size);
    return deviceType;
  }
}