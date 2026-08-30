import 'package:flutter/material.dart';

/// Destination item for the web sidebar navigation.
class WebNavDestination {
  const WebNavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Canonical web destinations matching the dashboard mock.
abstract final class WebNavItems {
  static const List<WebNavDestination> main = [
    WebNavDestination(
      label: 'Início',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    WebNavDestination(
      label: 'Clientes',
      icon: Icons.people_outline,
      selectedIcon: Icons.people_rounded,
    ),
    WebNavDestination(
      label: 'Calendário',
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today,
    ),
    WebNavDestination(
      label: 'Templates',
      icon: Icons.description_outlined,
      selectedIcon: Icons.description,
    ),
  ];
}
