import 'package:flutter/material.dart';

/// Global keys for spotlight targets during the product tour.
abstract final class OnboardingAnchors {
  static final clientsAdd = GlobalKey(debugLabel: 'onboarding_clients_add');
  static final clientsImport = GlobalKey(debugLabel: 'onboarding_clients_import');
  static final clientsImportContacts =
      GlobalKey(debugLabel: 'onboarding_clients_contacts');
  static final templatesHeader =
      GlobalKey(debugLabel: 'onboarding_templates_header');
  static final homeBirthdays =
      GlobalKey(debugLabel: 'onboarding_home_birthdays');

  static Rect? rectOf(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return null;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final offset = renderObject.localToGlobal(Offset.zero);
    return offset & renderObject.size;
  }
}
