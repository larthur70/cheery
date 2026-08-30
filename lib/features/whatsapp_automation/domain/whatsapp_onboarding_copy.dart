/// Shared copy for the 3-step WhatsApp onboarding.
abstract final class WhatsAppOnboardingCopy {
  static const steps = [
    (
      title: 'Automação de aniversários',
      body:
          'No dia do aniversário, o Cheery envia automaticamente a mensagem '
          'pelo WhatsApp Business Cloud API — sem abrir o WhatsApp no celular.',
    ),
    (
      title: 'Seu WhatsApp Business continua funcionando',
      body:
          'A integração usa coexistência da Meta: você segue atendendo clientes '
          'no app WhatsApp Business enquanto o Cheery envia as automações.',
    ),
    (
      title: 'Templates precisam de aprovação',
      body:
          'A Meta exige que cada mensagem de automação use um template aprovado. '
          'Você cria no Cheery, envia para análise e, após aprovação, ativa a '
          'automação nos clientes.',
    ),
  ];
}
