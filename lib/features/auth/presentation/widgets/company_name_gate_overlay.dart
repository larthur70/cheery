import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/core/widgets/cheery_logo.dart';
import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_repository_provider.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Blocks the shell until social/login users provide a company name.
class CompanyNameGateOverlay extends ConsumerStatefulWidget {
  const CompanyNameGateOverlay({super.key});

  @override
  ConsumerState<CompanyNameGateOverlay> createState() =>
      _CompanyNameGateOverlayState();
}

class _CompanyNameGateOverlayState
    extends ConsumerState<CompanyNameGateOverlay> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final company = _controller.text.trim();
    final userId = ref.read(authControllerProvider).valueOrNull?.id;
    final profile = ref.read(currentProfileProvider).valueOrNull;
    final repository = ref.read(authRepositoryProvider);
    if (userId == null || repository == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await repository.updateProfileFields(
        userId: userId,
        fullName: profile?.fullName?.trim() ?? '',
        companyName: company,
      );
      ref.invalidate(currentProfileProvider);
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = failure.message;
        });
      }
      return;
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Não foi possível salvar. Tente novamente.';
        });
      }
      return;
    }

    if (mounted) setState(() => _saving = false);
  }

  Widget _dimmedShell({required Widget child}) {
    return Positioned.fill(
      child: Stack(
        children: [
          const ModalBarrier(dismissible: false),
          ColoredBox(
            color: AppColors.ink.withValues(alpha: 0.55),
            child: const SizedBox.expand(),
          ),
          Center(child: child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final loggedIn = ref.watch(authControllerProvider).valueOrNull != null;

    if (!loggedIn) return const SizedBox.shrink();

    // Don't trap the shell on a slow / failed profile fetch (offline).
    if (profileAsync.isLoading && !profileAsync.hasValue) {
      return const SizedBox.shrink();
    }

    final profile = profileAsync.valueOrNull;
    if (profile == null || profile.hasCompanyName) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);

    return _dimmedShell(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.16),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: CheeryLogo(
                    size: 48,
                    wordmarkSize: 28,
                    axis: Axis.vertical,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Como se chama sua empresa?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Usamos esse nome nas mensagens e no seu perfil. '
                  'Leva só um instante.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _controller,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.words,
                  enabled: !_saving,
                  onFieldSubmitted: (_) => _save(),
                  decoration: const InputDecoration(
                    labelText: 'Nome da sua empresa',
                    hintText: 'Ex.: Studio Beleza',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome da sua empresa.';
                    }
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: 20),
                CheeryButton(
                  label: 'Continuar',
                  expanded: true,
                  isLoading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
