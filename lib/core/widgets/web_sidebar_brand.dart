import 'package:cheery/core/widgets/cheery_logo.dart';
import 'package:flutter/material.dart';

/// Brand block used at the top of the web sidebar.
class WebSidebarBrand extends StatelessWidget {
  const WebSidebarBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      // Match nav item horizontal inset so brand lines up with menu text.
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: CheeryLogo(size: 44, wordmarkSize: 30),
    );
  }
}
