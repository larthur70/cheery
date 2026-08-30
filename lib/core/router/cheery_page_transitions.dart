import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Instant page change — no animation (same feel as a normal website).
///
/// When [documentTitle] is set, wraps [child] in [Title] so the browser tab
/// shows e.g. `Home · Cheery`.
NoTransitionPage<void> cheeryLoadingPage({
  required LocalKey key,
  required Widget child,
  String? name,
  String? documentTitle,
}) {
  Widget pageChild = child;
  if (documentTitle != null && documentTitle.trim().isNotEmpty) {
    final tabTitle = documentTitle.contains('Cheery')
        ? documentTitle
        : '$documentTitle · Cheery';
    pageChild = Title(
      title: tabTitle,
      color: AppColors.cherry,
      child: child,
    );
  }

  return NoTransitionPage<void>(
    key: key,
    name: name,
    child: pageChild,
  );
}
