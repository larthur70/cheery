import 'package:cheery/core/theme/app_brand_typography.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _supportEmail = 'luiz@usecheery.com';

Future<void> _openSupportEmail() {
  return launchUrl(
    Uri(scheme: 'mailto', path: _supportEmail),
    mode: LaunchMode.externalApplication,
  );
}

/// Footer shared across Cheery web layouts.
class WebAppFooter extends StatelessWidget {
  const WebAppFooter({
    this.onPrivacyTap,
    this.onTermsTap,
    this.onContactTap,
    super.key,
  });

  final VoidCallback? onPrivacyTap;
  final VoidCallback? onTermsTap;
  final VoidCallback? onContactTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;
          if (isCompact) {
            return Column(
              children: [
                const _FooterBrand(),
                const SizedBox(height: 12),
                _FooterLinks(
                  onPrivacyTap: onPrivacyTap,
                  onTermsTap: onTermsTap,
                  onContactTap: onContactTap ?? _openSupportEmail,
                ),
                const SizedBox(height: 12),
                const _FooterCopyright(),
              ],
            );
          }

          return Row(
            children: [
              const _FooterBrand(),
              const Spacer(),
              _FooterLinks(
                onPrivacyTap: onPrivacyTap,
                onTermsTap: onTermsTap,
                onContactTap: onContactTap ?? _openSupportEmail,
              ),
              const Spacer(),
              const _FooterCopyright(),
            ],
          );
        },
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Cheery',
      style: AppBrandTypography.wordmark(fontSize: 20),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({
    this.onPrivacyTap,
    this.onTermsTap,
    this.onContactTap,
  });

  final VoidCallback? onPrivacyTap;
  final VoidCallback? onTermsTap;
  final VoidCallback? onContactTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _FooterLink(label: 'Privacidade', onTap: onPrivacyTap),
        _FooterLink(label: 'Termos de Uso', onTap: onTermsTap),
        _FooterLink(label: 'Contato', onTap: onContactTap),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

class _FooterCopyright extends StatelessWidget {
  const _FooterCopyright();

  @override
  Widget build(BuildContext context) {
    return Text(
      '© ${DateTime.now().year} Cheery. Todos os direitos reservados.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.inkMuted,
          ),
    );
  }
}
