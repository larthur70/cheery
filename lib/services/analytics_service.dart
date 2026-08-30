import 'package:cheery/core/utils/app_logger.dart';
import 'package:cheery/services/posthog_js_bridge_stub.dart'
    if (dart.library.html) 'package:cheery/services/posthog_js_bridge_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Runtime platform for product analytics (`web` | `mobile`).
enum AnalyticsPlatform {
  web,
  mobile;

  String get wireValue => name;

  static AnalyticsPlatform detect() {
    if (kIsWeb) return AnalyticsPlatform.web;
    return AnalyticsPlatform.mobile;
  }
}

/// Onboarding funnel steps tracked in PostHog.
enum OnboardingAnalyticsStep {
  apresentacao,
  import,
  template,
  home;

  String get wireValue => name;
}

/// Successful client-import source.
enum ImportAnalyticsOrigem {
  csv,
  contatosTelefone;

  String get wireValue => switch (this) {
        ImportAnalyticsOrigem.csv => 'csv',
        ImportAnalyticsOrigem.contatosTelefone => 'contatos_telefone',
      };
}

/// Free-plan limit that blocked the user.
enum LimiteAnalyticsTipo {
  clientes,
  templates;

  String get wireValue => name;
}

/// Where the Pro checkout CTA was clicked.
enum AssinaturaOrigemGatilho {
  limiteClientes,
  limiteTemplates,
  bannerLp,
  menuConfiguracoes;

  String get wireValue => switch (this) {
        AssinaturaOrigemGatilho.limiteClientes => 'limite_clientes',
        AssinaturaOrigemGatilho.limiteTemplates => 'limite_templates',
        AssinaturaOrigemGatilho.bannerLp => 'banner_lp',
        AssinaturaOrigemGatilho.menuConfiguracoes => 'menu_configuracoes',
      };

  static AssinaturaOrigemGatilho? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return switch (raw) {
      'limite_clientes' => AssinaturaOrigemGatilho.limiteClientes,
      'limite_templates' => AssinaturaOrigemGatilho.limiteTemplates,
      'banner_lp' => AssinaturaOrigemGatilho.bannerLp,
      'menu_configuracoes' => AssinaturaOrigemGatilho.menuConfiguracoes,
      _ => null,
    };
  }
}

/// Central PostHog facade — typed events, silent failures, shared `platform`.
class AnalyticsService {
  AnalyticsService({Posthog? posthog}) : _posthog = posthog ?? Posthog();

  final Posthog _posthog;
  var _enabled = false;

  bool get isEnabled => _enabled;

  void markEnabled() => _enabled = true;

  AnalyticsPlatform get platform => AnalyticsPlatform.detect();

  Future<void> identifyUser(String userId) async {
    await _safe(() async {
      if (kIsWeb) {
        if (!PosthogJsBridge.isAvailable) {
          throw StateError(
            'window.posthog missing — check web/index.html snippet',
          );
        }
        PosthogJsBridge.identify(userId);
        return;
      }
      await _posthog.identify(userId: userId);
    });
  }

  Future<void> reset() async {
    await _safe(() async {
      if (kIsWeb) {
        if (!PosthogJsBridge.isAvailable) {
          throw StateError(
            'window.posthog missing — check web/index.html snippet',
          );
        }
        PosthogJsBridge.reset();
        return;
      }
      await _posthog.reset();
    });
  }

  Future<void> trackOnboardingStepCompleted(
    OnboardingAnalyticsStep step,
  ) async {
    await _capture(
      'onboarding_step_completed',
      {'step': step.wireValue},
    );
  }

  Future<void> trackClienteCriadoManual({
    required bool duranteOnboarding,
  }) async {
    await _capture(
      'cliente_criado_manual',
      {'durante_onboarding': duranteOnboarding},
    );
  }

  Future<void> trackImportCompleted({
    required ImportAnalyticsOrigem origem,
    required int quantidade,
    required bool duranteOnboarding,
  }) async {
    await _capture(
      'import_completed',
      {
        'origem': origem.wireValue,
        'quantidade': quantidade,
        'durante_onboarding': duranteOnboarding,
      },
    );
  }

  Future<void> trackWhatsappAberto({
    required String clienteId,
    required String templateId,
  }) async {
    await _capture(
      'whatsapp_aberto',
      {
        'cliente_id': clienteId,
        'template_id': templateId,
      },
    );
  }

  Future<void> trackTemplateCriado({
    required String templateId,
    required bool duranteOnboarding,
  }) async {
    await _capture(
      'template_criado',
      {
        'template_id': templateId,
        'durante_onboarding': duranteOnboarding,
      },
    );
  }

  Future<void> trackTemplateEditado({
    required String templateId,
  }) async {
    await _capture(
      'template_editado',
      {'template_id': templateId},
    );
  }

  Future<void> trackLimiteAtingido({
    required LimiteAnalyticsTipo tipo,
    required int valorAtual,
  }) async {
    await _capture(
      'limite_atingido',
      {
        'tipo': tipo.wireValue,
        'valor_atual': valorAtual,
      },
    );
  }

  Future<void> trackAssinaturaProIniciada({
    required AssinaturaOrigemGatilho origemGatilho,
  }) async {
    await _capture(
      'assinatura_pro_iniciada',
      {'origem_gatilho': origemGatilho.wireValue},
    );
  }

  Future<void> trackSessaoAberta({
    required int diasDesdeCadastro,
  }) async {
    await _capture(
      'sessao_aberta',
      {'dias_desde_cadastro': diasDesdeCadastro},
    );
  }

  Future<void> _capture(
    String eventName,
    Map<String, Object> properties,
  ) async {
    if (!_enabled) {
      AppLogger.i('Analytics skipped (disabled): $eventName');
      if (kIsWeb) {
        // ignore: avoid_print
        print('[Cheery][Analytics] SKIPPED (disabled): $eventName');
      }
      return;
    }
    final payload = <String, Object>{
      'platform': platform.wireValue,
      ...properties,
    };
    await _safe(() async {
      if (kIsWeb) {
        if (!PosthogJsBridge.isAvailable) {
          throw StateError(
            'window.posthog missing — check web/index.html snippet',
          );
        }
        PosthogJsBridge.capture(eventName, payload);
        return;
      }
      await _posthog.capture(eventName: eventName, properties: payload);
      AppLogger.i('Analytics captured: $eventName');
    });
  }

  Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stackTrace) {
      AppLogger.e(
        'Analytics call failed (ignored)',
        error: error,
        stackTrace: stackTrace,
      );
      // Surface failures in the browser console during web debugging.
      if (kIsWeb) {
        // ignore: avoid_print
        print('[Cheery][Analytics] FAILED: $error');
      }
    }
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
