import 'package:cheery/features/legal/domain/privacy_policy_copy.dart';
import 'package:cheery/features/legal/presentation/legal_document_screen.dart';
import 'package:flutter/material.dart';

/// Public screen with the Cheery privacy policy (LGPD).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentScreen(
      appBarTitle: 'Política de privacidade',
      documentTitle: PrivacyPolicyCopy.title,
      lastUpdated: PrivacyPolicyCopy.lastUpdated,
      intro: PrivacyPolicyCopy.intro,
      sections: privacyPolicySections,
    );
  }
}
