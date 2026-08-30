import 'package:cheery/core/constants/app_breakpoints.dart';
import 'package:flutter/widgets.dart';

/// Builds different layouts based on viewport width.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (AppBreakpoints.isDesktop(width) && desktop != null) {
          return desktop!(context);
        }
        if (AppBreakpoints.isTablet(width) && tablet != null) {
          return tablet!(context);
        }
        if (width >= AppBreakpoints.mobile && desktop != null) {
          return desktop!(context);
        }
        return mobile(context);
      },
    );
  }
}
