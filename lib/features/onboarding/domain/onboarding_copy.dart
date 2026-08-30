import 'package:cheery/features/onboarding/domain/onboarding_tour_step.dart';
import 'package:flutter/foundation.dart';

/// Copy for the first-run product tour.
abstract final class OnboardingCopy {
  static const welcomeTitle = 'Bem-vindo ao Cheery';
  static const welcomeBody =
      'O Cheery é um app para fidelizar clientes com lembretes e mensagens '
      'de aniversário. Vamos fazer um tour rápido pela plataforma?';
  static const welcomeCta = 'Começar o tour';

  static String title(OnboardingTourStep step) => switch (step) {
        OnboardingTourStep.welcome => welcomeTitle,
        OnboardingTourStep.clients => 'Comece pelos clientes',
        OnboardingTourStep.templates => 'Personalize o template',
        OnboardingTourStep.importClients => 'Importe seus clientes',
        OnboardingTourStep.home => 'Seu dia a dia começa aqui',
      };

  static String body(OnboardingTourStep step, {required bool isMobile}) {
    switch (step) {
      case OnboardingTourStep.welcome:
        return welcomeBody;
      case OnboardingTourStep.clients:
        if (isMobile) {
          return 'Aqui você cadastra quem recebe os parabéns — '
              'manual, por contatos do celular ou planilha na web.';
        }
        return 'Aqui você cadastra quem recebe os parabéns — '
            'manual ou importando uma planilha.';
      case OnboardingTourStep.templates:
        return 'O template é a mensagem de parabéns. Edite o padrão: '
            'o nome da sua empresa e o do cliente entram sozinhos '
            'quando a mensagem for para o WhatsApp. '
            'Agora vamos importar os primeiros clientes.';
      case OnboardingTourStep.importClients:
        if (isMobile) {
          return 'Selecione os contatos e complete o aniversário. '
              'Quando terminar (ou cancelar), seguimos o tour.';
        }
        return 'Envie sua planilha e revise os dados. '
            'Quando terminar (ou cancelar), seguimos o tour.';
      case OnboardingTourStep.home:
        return 'Aqui aparecem os aniversariantes do dia e o próximo da fila. '
            'É daqui que você envia os parabéns com um toque.';
    }
  }

  static String cta(OnboardingTourStep step, {required bool isLast}) {
    if (step.isWelcome) return welcomeCta;
    if (step == OnboardingTourStep.templates) return 'Ir para importação';
    if (step.isImportClients) return 'Continuar';
    if (isLast) return 'Concluir';
    return 'Próximo';
  }

  static const skipLabel = 'Fechar';

  static bool get isMobilePlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }
}
