import 'package:flutter/material.dart';

import '../responsive_builder.dart';

typedef WidgetBuilder = Widget Function(BuildContext);
typedef OptionalWidgetBuilder = Widget? Function(BuildContext);
typedef SizeInfoWidgetBuilder = Widget Function(BuildContext, SizeInfo);
typedef LocalSizeWidgetBuilder = Widget Function(BuildContext, Size);
typedef Widget SizeInfoBuilder(SizeInfo sizeInfo);

/// A widget with a builder that provides you with the sizeInfo
///
/// This widget is used by the ScreenTypeLayout to provide different widget builders
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    SizeInfo sizeInfo,
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
      var sizeInfo = SizeInfo(
        deviceScreenType: getDeviceType(mediaQuery.size, breakpoints),
        refinedSize: getRefinedSize(
          mediaQuery.size,
          refinedBreakpoint: refinedBreakpoints,
        ),
        screenSize: mediaQuery.size,
        localWidgetSize:
            Size(boxConstraints.maxWidth, boxConstraints.maxHeight),
      );
      return builder(context, sizeInfo);
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
class ResponsiveLayout extends StatelessWidget {
  final ScreenBreakpoints? breakpoints;
  final SizeInfoWidgetBuilder? mobile;
  final SizeInfoWidgetBuilder? tabletPortrait;
  final SizeInfoWidgetBuilder? tabletLandscapeDesktop;
  final bool preferDesktop;

  ResponsiveLayout.screenType({
    super.key,
    this.breakpoints,
    this.mobile,
    this.tabletPortrait,
    this.tabletLandscapeDesktop,
    this.preferDesktop = ResponsiveAppUtil.preferDesktop,
  });

  ResponsiveLayout.maybeSidebar({
    super.key,
    required SizeInfoWidgetBuilder wideSidebarBuilder,
    SizeInfoWidgetBuilder? narrowSidebarBuilder,
    SizeInfoWidgetBuilder? noSideBarBuilder,
    this.breakpoints,
    this.preferDesktop = ResponsiveAppUtil.preferDesktop,
  })  : mobile = noSideBarBuilder,
        tabletLandscapeDesktop = wideSidebarBuilder,
        tabletPortrait = narrowSidebarBuilder;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      breakpoints: breakpoints,
      builder: (context, sizeInfo) {
        return sizeInfo.screenTypeLayoutBuilder(
          context,
          mobile: mobile,
          tabletPortrait: tabletPortrait,
          tabletLandscapeDesktop: tabletLandscapeDesktop,
          preferDesktop: preferDesktop,
        );
      },
    );
  }
}

/// Provides a builder function for refined screen sizes to be used with [ResponsiveLayout]
///
/// Each builder will get built based on the current device width.
/// [breakpoints] define your own custom device resolutions
/// [extraLarge] will be built if width is greater than 2160 on Desktops, 1280 on Tablets, and 600 on Mobiles
/// [large] will be built when width is greater than 1440 on Desktops, 1024 on Tablets, and 414 on Mobiles
/// [normal] will be built when width is greater than 1080 on Desktops, 768 on Tablets, and 375 on Mobiles
/// [small] will be built if width is less than 720 on Desktops, 600 on Tablets, and 320 on Mobiles
class RefinedLayoutBuilder extends StatelessWidget {
  final RefinedBreakpoints? refinedBreakpoints;

  final SizeInfoWidgetBuilder? extraLarge;
  final SizeInfoWidgetBuilder? large;
  final SizeInfoWidgetBuilder normal;
  final SizeInfoWidgetBuilder? small;

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
      builder: (context, sizeInfo) {
        // If we're at extra large size
        if (sizeInfo.refinedSize == RefinedSize.extraLarge) {
          // If we have supplied the extra large layout then display that
          if (extraLarge != null) return extraLarge!(context, sizeInfo);
          // If no extra large layout is supplied we want to check if we have the size below it and display that
          if (large != null) return large!(context, sizeInfo);
        }

        if (sizeInfo.refinedSize == RefinedSize.large) {
          // If we have supplied the large layout then display that
          if (large != null) return large!(context, sizeInfo);
          // If no large layout is supplied we want to check if we have the size below it and display that
          return normal(context, sizeInfo);
        }

        if (sizeInfo.refinedSize == RefinedSize.small) {
          // If we have supplied the small layout then display that
          if (small != null) return small!(context, sizeInfo);
        }

        // If none of the layouts above are supplied or we're on the small size layout then we show the small layout
        return normal(context, sizeInfo);
      },
    );
  }
}

class LocalWidgetSizeBuilder extends StatelessWidget {
  final LocalSizeWidgetBuilder narrow;
  final LocalSizeWidgetBuilder wide;
  final double breakPoint;

  const LocalWidgetSizeBuilder({
    super.key,
    required this.narrow,
    required this.wide,
    required this.breakPoint,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakPoint) {
          return narrow(
              context, Size(constraints.maxWidth, constraints.maxHeight));
        } else {
          return wide(
              context, Size(constraints.maxWidth, constraints.maxHeight));
        }
      },
    );
  }
}

class LocalWidgetSizesBuilder extends StatelessWidget {
  final List<LocalSizeWidgetBuilder> builders;
  final List<double> breakPoints;

  const LocalWidgetSizesBuilder({
    super.key,
    required this.builders,
    required this.breakPoints,
  }) : assert(
          builders.length == breakPoints.length + 1,
          'There should be exactly one more builder than breakpoints.',
        );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        for (int i = 0; i < breakPoints.length; i++) {
          if (constraints.maxWidth < breakPoints[i]) {
            return builders[i](
                context, Size(constraints.maxWidth, constraints.maxHeight));
          }
        }

        return builders.last(
            context, Size(constraints.maxWidth, constraints.maxHeight));
      },
    );
  }
}

class LocalWidgetSizesButtonBuilder extends StatelessWidget {
  final LocalSizeWidgetBuilder xs;
  final LocalSizeWidgetBuilder sm;
  final LocalSizeWidgetBuilder md;
  final LocalSizeWidgetBuilder lg;

  const LocalWidgetSizesButtonBuilder({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LocalWidgetSizesBuilder(
      breakPoints: const [528, 700, 1200],
      builders: [xs, sm, md, lg],
    );
  }
}
