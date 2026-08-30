import 'package:cheery/app.dart';
import 'package:cheery/core/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CheeryApp shows login brand', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseReadyProvider.overrideWithValue(false),
        ],
        child: const CheeryApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Cheery'), findsWidgets);
    expect(find.text('Entrar'), findsWidgets);
  });
}
