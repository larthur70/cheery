import 'package:cheery/features/legal/domain/terms_of_use_copy.dart';
import 'package:cheery/features/legal/presentation/legal_document_screen.dart';
import 'package:flutter/material.dart';

/// Public screen with Cheery terms of use.
class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentScreen(
      appBarTitle: 'Termos de uso',
      documentTitle: TermsOfUseCopy.title,
      lastUpdated: TermsOfUseCopy.lastUpdated,
      intro: TermsOfUseCopy.intro,
      sections: termsOfUseSections,
    );
  }
}
