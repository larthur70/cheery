import 'package:cheery/core/router/app_router.dart';
import 'package:cheery/core/theme/app_theme.dart';
import 'package:cheery/core/widgets/deep_link_bootstrap.dart';
import 'package:cheery/features/analytics/presentation/widgets/analytics_bootstrap.dart';
import 'package:cheery/features/birthday_reminders/presentation/widgets/push_notification_bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheeryApp extends ConsumerWidget {
  const CheeryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Cheery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        return DeepLinkBootstrap(
          router: router,
          child: AnalyticsBootstrap(
            child: PushNotificationBootstrap(
              router: router,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
