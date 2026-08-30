import 'package:cheery/core/widgets/responsive_builder.dart';
import 'package:cheery/features/clients/presentation/mobile/clients_mobile_screen.dart';
import 'package:cheery/features/clients/presentation/web/clients_web_screen.dart';
import 'package:flutter/widgets.dart';

class ClientsEntryScreen extends StatelessWidget {
  const ClientsEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => const ClientsMobileScreen(),
      desktop: (_) => const ClientsWebScreen(),
    );
  }
}
