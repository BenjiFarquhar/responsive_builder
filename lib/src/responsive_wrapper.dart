import 'package:flutter/material.dart';

/// Wrap your app with this widget if you want to use the responsive sizing extension
class ResponsiveApp extends StatelessWidget {
  final Widget Function(BuildContext) builder;

  /// Tells ResponsiveApp if we prefer desktop or mobile when a layout is not supplied
  final bool preferDesktop;

  const ResponsiveApp(
      {Key? key,
      required this.builder,
      this.preferDesktop = ResponsiveAppUtil.preferDesktop})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        ResponsiveAppUtil.setScreenSize(constraints, orientation);
        return builder(context);
      });
    });
  }
}

extension ResponsiveAppExtensions on num {
  /// Returns the pecentage of screen height based on the extended number
  /// Example: 20.screenHeight = (20 / 100) * currentScreenHeight
  double get screenHeight => (this / 100) * ResponsiveAppUtil.height;

  /// Returns the pecentage of screen width based on the extended number
  /// Example: 20.screenHeight = (20 / 100) * currentScreenHeight
  double get screenWidth => (this / 100) * ResponsiveAppUtil.width;

  /// Shorthand for [screenHeight]
  double get sh => screenHeight;

  /// Shorthand for [screenWidth]
  double get sw => screenWidth;
}

class ResponsiveAppUtil {
  static late double height;
  static late double width;
  static const bool preferDesktop = true;

  /// Saves the screenSzie for access through the extensions later
  static void setScreenSize(
    BoxConstraints constraints,
    Orientation orientation,
  ) {
    if (orientation == Orientation.portrait) {
      width = constraints.maxWidth;
      height = constraints.maxHeight;
    } else {
      width = constraints.maxHeight;
      height = constraints.maxWidth;
    }
  }
}
