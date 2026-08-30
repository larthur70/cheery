import 'package:cheery/core/widgets/responsive_builder.dart';
import 'package:cheery/features/templates/presentation/mobile/template_form_mobile_screen.dart';
import 'package:cheery/features/templates/presentation/web/template_form_web_screen.dart';
import 'package:flutter/widgets.dart';

class TemplateFormEntryScreen extends StatelessWidget {
  const TemplateFormEntryScreen({this.templateId, super.key});

  final String? templateId;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => TemplateFormMobileScreen(templateId: templateId),
      desktop: (_) => TemplateFormWebScreen(templateId: templateId),
    );
  }
}
