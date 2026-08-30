import 'package:cheery/features/legal/domain/privacy_policy_copy.dart';

/// Structured copy for the in-app terms of use screen.
abstract final class TermsOfUseCopy {
  static const title = 'Termos de uso do Cheery';
  static const lastUpdated = 'Última atualização: 16 de agosto de 2026';

  static const intro = [
    'Bem-vindo ao Cheery. Estes Termos de Uso regulam o acesso e a '
        'utilização da plataforma Cheery, disponível por meio de aplicativos '
        'móveis, web e demais serviços relacionados.',
    'Ao criar uma conta ou utilizar o Cheery, você concorda com estes Termos '
        'de Uso.',
  ];
}

final termsOfUseSections = <PrivacyPolicySection>[
  PrivacyPolicySection(
    title: '1. Sobre o Cheery',
    blocks: const [
      PrivacyParagraph(
        'O Cheery é uma plataforma de relacionamento com clientes que permite '
        'organizar cadastros, importar contatos, criar templates de mensagens, '
        'receber lembretes de aniversários e, quando disponível, automatizar o '
        'envio de mensagens através do WhatsApp Business Platform.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '2. Cadastro e conta',
    blocks: const [
      PrivacyParagraph(
        'Para utilizar o Cheery, o usuário deverá criar uma conta com '
        'informações verdadeiras e atualizadas.',
      ),
      PrivacyParagraph('O usuário é responsável por:'),
      PrivacyBulletList([
        'manter a confidencialidade de suas credenciais;',
        'restringir o acesso à sua conta;',
        'responder por todas as atividades realizadas por meio dela.',
      ]),
      PrivacyParagraph(
        'O Cheery poderá suspender ou encerrar contas que violem estes Termos.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '3. Uso da plataforma',
    blocks: const [
      PrivacyParagraph(
        'O usuário concorda em utilizar o Cheery apenas para fins legítimos e '
        'relacionados ao relacionamento com seus clientes.',
      ),
      PrivacyParagraph('É proibido utilizar a plataforma para:'),
      PrivacyBulletList([
        'envio de spam;',
        'mensagens fraudulentas;',
        'conteúdo ilegal, ofensivo ou abusivo;',
        'violação dos Termos da Meta (WhatsApp Business Platform);',
        'qualquer atividade que possa prejudicar terceiros ou o funcionamento '
            'da plataforma.',
      ]),
    ],
  ),
  PrivacyPolicySection(
    title: '4. Dados de clientes',
    blocks: const [
      PrivacyParagraph(
        'O usuário poderá cadastrar ou importar informações de seus clientes, '
        'incluindo nome, telefone e data de aniversário.',
      ),
      PrivacyParagraph(
        'O usuário declara que possui base legal para tratar esses dados e é o '
        'único responsável pelo conteúdo cadastrado na plataforma.',
      ),
      PrivacyParagraph(
        'O Cheery atua como ferramenta de gestão e automação, não assumindo '
        'responsabilidade pela origem ou legalidade dos dados inseridos pelos '
        'usuários.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '5. Integração com WhatsApp',
    blocks: const [
      PrivacyParagraph(
        'Quando disponível, o usuário poderá integrar sua conta do WhatsApp '
        'Business à plataforma.',
      ),
      PrivacyParagraph('Ao realizar a integração, o usuário autoriza o Cheery a:'),
      PrivacyBulletList([
        'enviar mensagens em seu nome;',
        'gerenciar templates;',
        'consultar status de envio;',
        'executar automações configuradas pelo usuário.',
      ]),
      PrivacyParagraph(
        'O usuário permanece responsável pelo conteúdo das mensagens enviadas.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '6. Templates de mensagens',
    blocks: const [
      PrivacyParagraph(
        'Os templates utilizados na automação estão sujeitos às políticas da '
        'Meta.',
      ),
      PrivacyParagraph(
        'O Cheery não garante a aprovação de templates enviados para análise '
        'nem é responsável por rejeições, limitações ou bloqueios aplicados '
        'pela Meta.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '7. Planos e pagamentos',
    blocks: const [
      PrivacyParagraph(
        'O Cheery poderá oferecer planos gratuitos e pagos.',
      ),
      PrivacyParagraph(
        'Assinaturas pagas serão cobradas de forma recorrente, conforme o plano '
        'contratado.',
      ),
      PrivacyParagraph(
        'O cancelamento da assinatura interrompe a renovação futura, '
        'permanecendo o acesso ao plano contratado até o final do período '
        'vigente.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '8. Reembolso e direito de arrependimento',
    blocks: const [
      PrivacyParagraph(
        'Nos termos do art. 49 do Código de Defesa do Consumidor, o usuário '
        'que realizar a assinatura do Cheery tem direito de se arrepender da '
        'contratação em até 7 (sete) dias corridos, contados da data da '
        'confirmação do pagamento, com direito à devolução integral do valor '
        'pago, sem necessidade de justificativa.',
      ),
      PrivacyParagraph(
        'Para solicitar o reembolso, o usuário deve entrar em contato com o '
        'suporte através do e-mail luiz@usecheery.com, informando o e-mail '
        'cadastrado na conta e a data da assinatura. O reembolso será '
        'processado em até 7 dias úteis após a solicitação, podendo levar de '
        '5 a 10 dias úteis adicionais para refletir no meio de pagamento '
        'utilizado, conforme prazo do processador de pagamentos.',
      ),
      PrivacyParagraph(
        'Após o prazo de 7 dias, solicitações de reembolso serão avaliadas '
        'caso a caso pelo suporte, e não constituem obrigação automática, '
        'exceto em situações de vício ou defeito comprovado no serviço '
        'prestado, conforme arts. 18 a 20 do Código de Defesa do Consumidor.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '9. Custos do WhatsApp Business Platform',
    blocks: const [
      PrivacyParagraph(
        'As mensagens automáticas enviadas através da WhatsApp Business '
        'Platform poderão gerar cobranças definidas pela Meta.',
      ),
      PrivacyParagraph(
        'Essas cobranças são de responsabilidade do titular da conta do '
        'WhatsApp Business utilizada na integração, conforme as políticas '
        'aplicáveis da Meta.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '10. Disponibilidade',
    blocks: const [
      PrivacyParagraph(
        'O Cheery busca manter seus serviços disponíveis continuamente.',
      ),
      PrivacyParagraph('Entretanto, não garantimos funcionamento ininterrupto, podendo ocorrer:'),
      PrivacyBulletList([
        'manutenção;',
        'atualizações;',
        'indisponibilidade temporária;',
        'falhas decorrentes de terceiros.',
      ]),
    ],
  ),
  PrivacyPolicySection(
    title: '11. Limitação de responsabilidade',
    blocks: const [
      PrivacyParagraph(
        'Na máxima extensão permitida pela legislação aplicável, o Cheery não '
        'será responsável por:',
      ),
      PrivacyBulletList([
        'perda de lucros;',
        'perda de clientes;',
        'danos indiretos;',
        'interrupções do WhatsApp;',
        'falhas de serviços de terceiros;',
        'rejeição de templates;',
        'bloqueios ou limitações aplicadas pela Meta.',
      ]),
      PrivacyParagraph(
        'A responsabilidade total do Cheery, quando existente, limita-se ao '
        'valor efetivamente pago pelo usuário nos 12 meses anteriores ao evento '
        'que deu origem à reclamação.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '12. Propriedade intelectual',
    blocks: const [
      PrivacyParagraph(
        'Todos os direitos relacionados ao Cheery, incluindo software, '
        'identidade visual, marca, interface e conteúdo da plataforma, '
        'pertencem ao Cheery ou aos seus licenciadores.',
      ),
      PrivacyParagraph(
        'O usuário não adquire qualquer direito sobre a plataforma além da '
        'licença limitada de uso.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '13. Encerramento da conta',
    blocks: const [
      PrivacyParagraph(
        'O usuário poderá encerrar sua conta a qualquer momento.',
      ),
      PrivacyParagraph('O Cheery poderá encerrar contas que:'),
      PrivacyBulletList([
        'violem estes Termos;',
        'utilizem a plataforma de forma abusiva;',
        'representem risco para a segurança do serviço.',
      ]),
    ],
  ),
  PrivacyPolicySection(
    title: '14. Alterações destes Termos',
    blocks: const [
      PrivacyParagraph(
        'O Cheery poderá alterar estes Termos periodicamente.',
      ),
      PrivacyParagraph(
        'A versão atualizada será publicada em nosso site e/ou aplicativo.',
      ),
      PrivacyParagraph(
        'O uso continuado da plataforma após a atualização representa '
        'aceitação dos novos Termos.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '15. Contato',
    blocks: const [
      PrivacyParagraph(
        'Em caso de dúvidas sobre estes Termos, entre em contato pelo e-mail:',
      ),
      PrivacyParagraph('luiz@usecheery.com'),
    ],
  ),
  PrivacyPolicySection(
    title: '16. Lei aplicável',
    blocks: const [
      PrivacyParagraph(
        'Estes Termos são regidos pelas leis da República Federativa do '
        'Brasil.',
      ),
      PrivacyParagraph(
        'Fica eleito o foro da comarca do domicílio do usuário, quando '
        'aplicável, ou outro foro competente nos termos da legislação '
        'brasileira.',
      ),
      PrivacyParagraph(
        'Ao utilizar o Cheery, você declara que leu, compreendeu e concorda '
        'com estes Termos de Uso.',
      ),
    ],
  ),
];
