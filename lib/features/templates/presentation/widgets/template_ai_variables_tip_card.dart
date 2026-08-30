import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/templates/domain/template_variable_catalog.dart';
import 'package:flutter/material.dart';

/// Tip for users who draft the message with an external AI.
class TemplateAiVariablesTipCard extends StatelessWidget {
  const TemplateAiVariablesTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blushDeep,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 20,
            color: AppColors.cherry,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dica para gerar com IA',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.inkMuted,
                      height: 1.4,
                    ),
                    children: const [
                      TextSpan(
                        text:
                            'Se for criar a mensagem com IA, peça no prompt para '
                            'já incluir as variáveis ',
                      ),
                      TextSpan(
                        text: TemplateVariableCatalog.clientNameToken,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: ' e '),
                      TextSpan(
                        text: TemplateVariableCatalog.companyNameToken,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: ' exatamente assim. Assim o Cheery personaliza o envio corretamente.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
