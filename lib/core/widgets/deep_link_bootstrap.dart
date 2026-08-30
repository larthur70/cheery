import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:cheery/core/config/app_deep_links.dart';
import 'package:cheery/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Listens for `cheery://` returns (Stripe, email, WhatsApp) and routes them.
///
/// Must receive [router] explicitly: this widget sits in
/// [MaterialApp.router]'s builder, above [GoRouter.of] in the tree.
class DeepLinkBootstrap extends StatefulWidget {
  const DeepLinkBootstrap({
    required this.router,
    required this.child,
    super.key,
  });

  final GoRouter router;
  final Widget child;

  @override
  State<DeepLinkBootstrap> createState() => _DeepLinkBootstrapState();
}

class _DeepLinkBootstrapState extends State<DeepLinkBootstrap> {
  StreamSubscription<Uri>? _subscription;
  String? _handled;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    unawaited(_listen());
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  Future<void> _listen() async {
    try {
      final appLinks = AppLinks();
      final initial = await appLinks.getInitialLink();
      if (initial != null) {
        _open(initial);
      }
      _subscription = appLinks.uriLinkStream.listen(_open);
    } catch (error, stackTrace) {
      AppLogger.e(
        'deep link listen failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _open(Uri uri) {
    final location = AppDeepLinks.goLocationFrom(uri);
    if (location == null || location == _handled) return;
    _handled = location;
    AppLogger.i('Deep link → $location');
    widget.router.go(location);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
