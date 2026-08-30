import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Structured copy for the in-app privacy policy screen.
abstract final class PrivacyPolicyCopy {
  static const title = 'Política de Privacidade — Cheery';
  static const lastUpdated = 'Última atualização: 14 de agosto de 2026';

  static const intro = [
    'Esta Política de Privacidade descreve como o Cheery ("nós", "nosso", '
        '"Plataforma"), operado por Luiz Arthur Vieira Bolzani Lopes Lima, '
        'pessoa física inscrita no CPF sob o nº 453.395.458-81, com domicílio '
        'em Presidente Prudente/SP ("Controlador/Operador"), coleta, usa, '
        'armazena, compartilha e protege dados pessoais, em conformidade com a '
        'Lei Geral de Proteção de Dados (Lei nº 13.709/2018 — "LGPD").',
    'Ao criar uma conta ou usar o Cheery, você declara que leu e concorda com '
        'esta Política.',
  ];
}

class PrivacyPolicySection {
  const PrivacyPolicySection({
    required this.title,
    required this.blocks,
  });

  final String title;
  final List<PrivacyPolicyBlock> blocks;
}

sealed class PrivacyPolicyBlock {
  const PrivacyPolicyBlock();
}

class PrivacyParagraph extends PrivacyPolicyBlock {
  const PrivacyParagraph(this.text, {this.emphasis = false});

  final String text;
  final bool emphasis;
}

class PrivacyBulletList extends PrivacyPolicyBlock {
  const PrivacyBulletList(this.items, {this.ordered = false});

  final List<String> items;
  final bool ordered;
}

class PrivacyHeading extends PrivacyPolicyBlock {
  const PrivacyHeading(this.text);

  final String text;
}

class PrivacyTableBlock extends PrivacyPolicyBlock {
  const PrivacyTableBlock({
    required this.headers,
    required this.rows,
  });

  final List<String> headers;
  final List<List<String>> rows;
}

final privacyPolicySections = <PrivacyPolicySection>[
  PrivacyPolicySection(
    title: '1. Quem somos e como agimos em relação aos dados',
    blocks: const [
      PrivacyParagraph(
        'O Cheery é uma plataforma de fidelização de clientes para pequenos '
        'negócios (barbearias, clínicas, pet shops, academias, salões de '
        'beleza e comércios similares), que ajuda o dono do negócio a lembrar '
        'datas de aniversário de seus clientes e enviar mensagens de forma '
        'manual ou, futuramente, automatizada via WhatsApp.',
      ),
      PrivacyParagraph(
        'Para efeitos da LGPD, existem dois papéis diferentes conforme o tipo '
        'de dado:',
      ),
      PrivacyBulletList([
        'Em relação aos dados de cadastro do usuário da plataforma (o dono do '
            'negócio que assina o Cheery), a Empresa atua como Controladora — '
            'decide como e por que esses dados são tratados.',
        'Em relação aos dados dos contatos importados pelo usuário (os '
            'clientes finais do negócio — ex.: clientes da barbearia), a '
            'Empresa atua como Operadora. O usuário da plataforma é o '
            'Controlador desses dados: é ele quem decide importar aqueles '
            'contatos e é responsável por ter base legal e autorização para '
            'tratá-los. O Cheery apenas processa esses dados em nome do '
            'usuário, conforme as instruções dele, dentro da Plataforma.',
      ]),
      PrivacyParagraph(
        'Essa distinção é importante porque define quem é responsável por quê '
        '— detalhamos isso na Seção 6.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '2. Quais dados coletamos',
    blocks: const [
      PrivacyHeading('2.1. Dados do usuário da plataforma (dono do negócio)'),
      PrivacyBulletList([
        'Nome completo',
        'E-mail',
        'Telefone',
        'Nome do negócio / marca',
        'Dados de acesso (senha criptografada)',
        'Dados de pagamento da assinatura (processados diretamente pelo Stripe '
            '— o Cheery não armazena número de cartão de crédito)',
        'Dados de uso da Plataforma (páginas acessadas, ações realizadas, data '
            'de login)',
      ]),
      PrivacyHeading(
        '2.2. Dados dos contatos importados (clientes finais do negócio)',
      ),
      PrivacyParagraph(
        'Quando o usuário cadastra ou importa sua base de clientes, os '
        'seguintes dados podem ser tratados:',
      ),
      PrivacyBulletList([
        'Nome do contato',
        'Número de telefone (WhatsApp)',
        'Data de aniversário',
      ]),
      PrivacyParagraph(
        'O Cheery não coleta esses dados diretamente do titular (o cliente '
        'final) — eles são fornecidos pelo usuário da plataforma, que declara '
        'ter autorização para isso (ver Seção 6).',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '3. Como coletamos os dados',
    blocks: const [
      PrivacyBulletList([
        'Diretamente, quando o usuário se cadastra, preenche formulários ou '
            'insere dados manualmente na Plataforma',
        'Por importação, quando o usuário faz upload de planilha (CSV) ou, no '
            'aplicativo móvel, importa contatos da agenda do telefone',
        'Automaticamente, por meio de cookies e tecnologias similares no site '
            'institucional, para fins de análise de navegação (ver Seção 9)',
      ]),
    ],
  ),
  PrivacyPolicySection(
    title: '4. Para que usamos os dados (finalidade)',
    blocks: const [
      PrivacyTableBlock(
        headers: ['Dado', 'Finalidade'],
        rows: [
          [
            'Cadastro do usuário',
            'Criar e gerenciar a conta, autenticação, suporte, comunicação '
                'sobre a assinatura',
          ],
          [
            'Dados de pagamento',
            'Processar cobrança da assinatura (via Stripe)',
          ],
          [
            'Contatos importados (nome, telefone, aniversário)',
            'Permitir que o usuário visualize aniversariantes e envie '
                'mensagens de felicitação, manualmente ou de forma automatizada',
          ],
          [
            'Dados de uso',
            'Melhorar a Plataforma, prevenir fraude, cumprir obrigação legal',
          ],
        ],
      ),
      PrivacyParagraph(
        'Não usamos os dados dos contatos importados para nenhuma finalidade '
        'além de viabilizar o envio de mensagens solicitado pelo usuário da '
        'plataforma. Não vendemos dados pessoais a terceiros.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '5. Base legal (LGPD, art. 7º)',
    blocks: const [
      PrivacyBulletList([
        'Execução de contrato: tratamento dos dados do usuário da plataforma, '
            'necessário para prestar o serviço contratado.',
        'Consentimento: tratamento dos dados dos contatos importados, obtido '
            'pelo usuário da plataforma junto aos próprios clientes finais '
            'dele, antes da importação (ver Seção 6).',
        'Cumprimento de obrigação legal ou regulatória, quando aplicável '
            '(ex.: dados fiscais).',
        'Legítimo interesse, para prevenção de fraude e segurança da '
            'Plataforma.',
      ]),
    ],
  ),
  PrivacyPolicySection(
    title: '6. Responsabilidade sobre os dados importados — leia com atenção',
    blocks: const [
      PrivacyParagraph(
        'O usuário da plataforma (dono do negócio) é o único responsável por '
        'garantir que possui base legal e autorização dos seus clientes finais '
        'antes de importar os dados deles no Cheery.',
        emphasis: true,
      ),
      PrivacyParagraph(
        'Ao importar contatos, o usuário deve confirmar, por meio de '
        'declaração expressa dentro da Plataforma, que:',
      ),
      PrivacyBulletList(
        [
          'Possui autorização/consentimento dos titulares para tratar seus '
              'dados pessoais para a finalidade de envio de mensagens de '
              'aniversário e fidelização;',
          'Comunicou ou tem condições de comunicar a esses titulares como seus '
              'dados serão usados;',
          'Assume total responsabilidade civil e legal por qualquer '
              'irregularidade nessa base de dados, isentando a Empresa de '
              'responsabilidade decorrente de dados importados sem a devida '
              'autorização.',
        ],
        ordered: true,
      ),
      PrivacyParagraph(
        'O Cheery atua apenas como Operador dessa base — ou seja, processa os '
        'dados conforme instruído pelo usuário, mas não verifica nem pode '
        'verificar tecnicamente se cada contato individual de fato consentiu. '
        'Essa responsabilidade é do usuário, como Controlador dessa relação.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '7. Com quem compartilhamos os dados',
    blocks: const [
      PrivacyParagraph(
        'Compartilhamos dados pessoais apenas com os seguintes prestadores de '
        'serviço, estritamente para viabilizar o funcionamento da Plataforma:',
      ),
      PrivacyTableBlock(
        headers: ['Terceiro', 'Finalidade', 'Dado compartilhado'],
        rows: [
          [
            'Supabase',
            'Hospedagem de banco de dados e autenticação',
            'Todos os dados armazenados na Plataforma',
          ],
          [
            'Stripe',
            'Processamento de pagamento da assinatura',
            'Dados de cobrança do usuário da plataforma',
          ],
          [
            'Cloudflare',
            'Hospedagem e entrega do site/aplicativo web',
            'Dados de navegação, IP',
          ],
          [
            'Meta / WhatsApp (quando o recurso de automação estiver disponível)',
            'Envio automatizado de mensagens em nome do usuário',
            'Número de telefone do contato, conteúdo da mensagem',
          ],
        ],
      ),
      PrivacyParagraph(
        'Não compartilhamos dados pessoais com terceiros para fins de '
        'publicidade ou revenda.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '8. Transferência internacional de dados',
    blocks: const [
      PrivacyParagraph(
        'Alguns dos prestadores listados na Seção 7 (como Supabase, Stripe e '
        'Meta) podem armazenar ou processar dados em servidores localizados '
        'fora do Brasil. Nesses casos, a transferência ocorre em conformidade '
        'com o art. 33 da LGPD, adotando salvaguardas contratuais e técnicas '
        'adequadas exigidas por esses fornecedores para proteção dos dados '
        'pessoais.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '9. Cookies',
    blocks: const [
      PrivacyParagraph(
        'O site institucional do Cheery pode usar cookies e tecnologias '
        'similares para:',
      ),
      PrivacyBulletList([
        'Lembrar preferências de navegação',
        'Medir tráfego e uso do site (analytics)',
      ]),
      PrivacyParagraph(
        'Você pode desativar cookies nas configurações do seu navegador, ainda '
        'que isso possa afetar algumas funcionalidades do site.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '10. Tempo de retenção dos dados',
    blocks: const [
      PrivacyParagraph(
        'Mantemos os dados pessoais pelo tempo necessário para cumprir as '
        'finalidades descritas nesta Política, ou até que o titular solicite a '
        'exclusão (quando aplicável) ou o usuário da plataforma encerre sua '
        'conta. Após o encerramento, os dados são eliminados ou anonimizados, '
        'exceto quando a manutenção for exigida por obrigação legal ou '
        'regulatória.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '11. Segurança da informação',
    blocks: const [
      PrivacyParagraph(
        'Adotamos medidas técnicas e organizacionais razoáveis para proteger '
        'os dados pessoais contra acesso não autorizado, perda, alteração ou '
        'vazamento, incluindo criptografia de senhas e controle de acesso à '
        'infraestrutura. Nenhum sistema é 100% livre de risco, e nos '
        'comprometemos a notificar as autoridades e os titulares afetados em '
        'caso de incidente de segurança relevante, conforme exigido pela LGPD.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '12. Seus direitos como titular de dados',
    blocks: const [
      PrivacyParagraph('Nos termos do art. 18 da LGPD, você tem direito a:'),
      PrivacyBulletList([
        'Confirmar a existência de tratamento de seus dados',
        'Acessar seus dados',
        'Corrigir dados incompletos, inexatos ou desatualizados',
        'Solicitar anonimização, bloqueio ou eliminação de dados '
            'desnecessários ou tratados em desconformidade com a lei',
        'Solicitar a portabilidade dos dados',
        'Solicitar a eliminação dos dados tratados com base no seu '
            'consentimento',
        'Revogar o consentimento a qualquer momento',
        'Solicitar informação sobre entidades com as quais compartilhamos '
            'seus dados',
      ]),
      PrivacyParagraph(
        'Se você é cliente final de um negócio que usa o Cheery (ex.: cliente '
        'de uma barbearia cadastrada na Plataforma) e deseja exercer algum '
        'desses direitos, recomendamos contatar diretamente o negócio (que é '
        'o Controlador dos seus dados). Alternativamente, você pode nos '
        'contatar pelo canal abaixo, e faremos a intermediação necessária.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '13. Menores de idade',
    blocks: const [
      PrivacyParagraph(
        'O Cheery não é direcionado a menores de 18 anos, e o cadastro na '
        'Plataforma como usuário requer capacidade civil plena. Caso dados de '
        'menores sejam incluídos entre os contatos importados por um usuário, '
        'cabe a esse usuário garantir a base legal apropriada, conforme o art. '
        '14 da LGPD.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '14. Alterações nesta Política',
    blocks: const [
      PrivacyParagraph(
        'Podemos atualizar esta Política periodicamente para refletir mudanças '
        'na Plataforma ou na legislação aplicável. A versão mais recente '
        'estará sempre disponível nesta página, com a data de atualização '
        'indicada no topo.',
      ),
    ],
  ),
  PrivacyPolicySection(
    title: '15. Contato e Encarregado de Dados (DPO)',
    blocks: const [
      PrivacyParagraph(
        'Para exercer seus direitos, tirar dúvidas ou reportar qualquer '
        'preocupação relacionada a esta Política, entre em contato:',
      ),
      PrivacyBulletList([
        'E-mail: luiz@usecheery.com',
        'Responsável: Luiz Arthur Vieira Bolzani Lopes Lima',
      ]),
    ],
  ),
];

/// Shared body text style for legal documents.
TextStyle privacyBodyStyle(BuildContext context, {bool emphasis = false}) {
  return Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: emphasis ? AppColors.ink : AppColors.inkMuted,
        height: 1.5,
        fontWeight: emphasis ? FontWeight.w600 : FontWeight.w400,
      );
}
