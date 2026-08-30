import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({
    required this.userFirstName,
    required this.date,
    super.key,
  });

  static const _cherriesAsset =
      'assets/images/svgs/cherries-couple-svgrepo-com.svg';

  final String userFirstName;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat("EEEE, d 'de' MMMM 'de' y", 'pt_BR').format(date);
    final capitalizedDate =
        formattedDate[0].toUpperCase() + formattedDate.substring(1);
    final greetingStyle = Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: AppColors.cherry,
          fontWeight: FontWeight.w600,
          height: 1.15,
        );
    final cherrySize = (greetingStyle?.fontSize ?? 32) * 0.95;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Olá, $userFirstName!',
                style: greetingStyle,
              ),
            ),
            if (kIsWeb) ...[
              const SizedBox(width: 10),
              SvgPicture.asset(
                _cherriesAsset,
                width: cherrySize,
                height: cherrySize,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
                placeholderBuilder: (_) => SizedBox(
                  width: cherrySize,
                  height: cherrySize,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          capitalizedDate,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.inkMuted,
              ),
        ),
      ],
    );
  }
}
