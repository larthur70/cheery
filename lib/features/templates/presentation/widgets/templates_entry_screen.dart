import 'package:cheery/core/widgets/responsive_builder.dart';
import 'package:cheery/features/templates/presentation/mobile/templates_mobile_screen.dart';
import 'package:cheery/features/templates/presentation/web/templates_web_screen.dart';
import 'package:flutter/widgets.dart';

class TemplatesEntryScreen extends StatelessWidget {
  const TemplatesEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => const TemplatesMobileScreen(),
      desktop: (_) => const TemplatesWebScreen(),
    );
  }
}
