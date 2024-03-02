import 'package:flutter/material.dart';

import '../responsive_builder.dart';

typedef WidgetBuilder = Widget Function(BuildContext);
typedef SizingInfoWidgetBuilder = Widget Function(
    BuildContext, SizingInformation);

/// A widget with a builder that provides you with the sizingInformation
///
/// This widget is used by the ScreenTypeLayout to provide different widget builders
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    SizingInformation sizingInformation,
  ) builder;

  final ScreenBreakpoints? breakpoints;
  final RefinedBreakpoints? refinedBreakpoints;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
    this.breakpoints,
    this.refinedBreakpoints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, boxConstraints) {
      var mediaQuery = MediaQuery.of(context);
      var sizingInformation = SizingInformation(
        deviceScreenType: getDeviceType(mediaQuery.size, breakpoints),
        refinedSize: getRefinedSize(
          mediaQuery.size,
          refinedBreakpoint: refinedBreakpoints,
        ),
        screenSize: mediaQuery.size,
        localWidgetSize:
            Size(boxConstraints.maxWidth, boxConstraints.maxHeight),
      );
      return builder(context, sizingInformation);
    });
  }
}

enum OrientationLayoutBuilderMode {
  auto,
  landscape,
  portrait,
}

/// Provides a builder function for a landscape and portrait widget
class OrientationLayoutBuilder extends StatelessWidget {
  final WidgetBuilder? landscape;
  final WidgetBuilder portrait;
  final OrientationLayoutBuilderMode mode;

  const OrientationLayoutBuilder({
    Key? key,
    this.landscape,
    required this.portrait,
    this.mode = OrientationLayoutBuilderMode.auto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        var orientation = MediaQuery.of(context).orientation;
        if (mode != OrientationLayoutBuilderMode.portrait &&
            (orientation == Orientation.landscape ||
                mode == OrientationLayoutBuilderMode.landscape)) {
          if (landscape != null) {
            return landscape!(context);
          }
        }

        return portrait(context);
      },
    );
  }
}

/// Provides a builder function for different screen types
///
/// Each builder will get built based on the current device width.
/// [breakpoints] define your own custom device resolutions
/// [watch] will be built and shown when width is less than 300
/// [mobile] will be built when width greater than 300
/// [tablet] will be built when width is greater than 600
/// [desktopTabletLandscape] will be built if width is greater than 950
class ScreenTypeLayout extends StatelessWidget {
  final ScreenBreakpoints? breakpoints;
  final SizingInfoWidgetBuilder mobile;
  final SizingInfoWidgetBuilder tabletPortrait;
  final SizingInfoWidgetBuilder desktopTabletLandscape;

  @Deprecated(
    'Use ScreenTypeLayout.builder instead for performance improvements',
  )
  ScreenTypeLayout({
    super.key,
    this.breakpoints,
    required Widget mobile,
    required Widget tabletPortrait,
    required Widget desktopTabletLandscape,
  })  : 
        this.mobile = ((c, s) => mobile),
        this.tabletPortrait = ((c, s) => tabletPortrait),
        this.desktopTabletLandscape = ((c, s) => desktopTabletLandscape);

  ScreenTypeLayout.builder({
    super.key,
    this.breakpoints,
    required this.mobile,
    required this.tabletPortrait,
    required this.desktopTabletLandscape,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      breakpoints: breakpoints,
      builder: (context, sizingInformation) {
        final orientation = MediaQuery.orientationOf(context);

        if (sizingInformation.deviceScreenType == DeviceScreenType.desktop || sizingInformation.deviceScreenType == DeviceScreenType.tablet && orientation == Orientation.landscape) {
          return desktopTabletLandscape(context, sizingInformation);
        }

        if (sizingInformation.deviceScreenType == DeviceScreenType.tablet && orientation == Orientation.portrait) {
          return tabletPortrait(context, sizingInformation);
        }

        return mobile(context, sizingInformation);
      },
    );
  }
}

/// Provides a builder function for refined screen sizes to be used with [ScreenTypeLayout]
///
/// Each builder will get built based on the current device width.
/// [breakpoints] define your own custom device resolutions
/// [extraLarge] will be built if width is greater than 2160 on Desktops, 1280 on Tablets, and 600 on Mobiles
/// [large] will be built when width is greater than 1440 on Desktops, 1024 on Tablets, and 414 on Mobiles
/// [normal] will be built when width is greater than 1080 on Desktops, 768 on Tablets, and 375 on Mobiles
/// [small] will be built if width is less than 720 on Desktops, 600 on Tablets, and 320 on Mobiles
class RefinedLayoutBuilder extends StatelessWidget {
  final RefinedBreakpoints? refinedBreakpoints;

  final SizingInfoWidgetBuilder? extraLarge;
  final SizingInfoWidgetBuilder? large;
  final SizingInfoWidgetBuilder normal;
  final SizingInfoWidgetBuilder? small;

  const RefinedLayoutBuilder({
    Key? key,
    this.refinedBreakpoints,
    this.extraLarge,
    this.large,
    required this.normal,
    this.small,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      refinedBreakpoints: refinedBreakpoints,
      builder: (context, sizingInformation) {
        // If we're at extra large size
        if (sizingInformation.refinedSize == RefinedSize.extraLarge) {
          // If we have supplied the extra large layout then display that
          if (extraLarge != null)
            return extraLarge!(context, sizingInformation);
          // If no extra large layout is supplied we want to check if we have the size below it and display that
          if (large != null) return large!(context, sizingInformation);
        }

        if (sizingInformation.refinedSize == RefinedSize.large) {
          // If we have supplied the large layout then display that
          if (large != null) return large!(context, sizingInformation);
          // If no large layout is supplied we want to check if we have the size below it and display that
          return normal(context, sizingInformation);
        }

        if (sizingInformation.refinedSize == RefinedSize.small) {
          // If we have supplied the small layout then display that
          if (small != null) return small!(context, sizingInformation);
        }

        // If none of the layouts above are supplied or we're on the small size layout then we show the small layout
        return normal(context, sizingInformation);
      },
    );
  }
}
