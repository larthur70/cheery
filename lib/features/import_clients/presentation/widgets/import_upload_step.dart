import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/import_clients/presentation/widgets/import_example_download.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImportUploadStep extends StatelessWidget {
  const ImportUploadStep({
    required this.fileName,
    required this.isParsing,
    required this.onBrowse,
    this.errorMessage,
    super.key,
  });

  final String? fileName;
  final bool isParsing;
  final VoidCallback onBrowse;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0D6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Se a planilha tiver a coluna Template, o nome precisa ser '
                          'exatamente igual ao de um template já cadastrado. '
                          'Se não existir ou a coluna estiver vazia, usamos o template padrão.',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Material(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: isParsing ? null : onBrowse,
                        borderRadius: BorderRadius.circular(16),
                        child: CustomPaint(
                          painter: _DashedBorderPainter(
                            color: AppColors.cherryMuted,
                            radius: 16,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 28,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.blushDeep,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.upload_file_outlined,
                                    size: 28,
                                    color: AppColors.cherry,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  fileName == null
                                      ? 'Arraste sua planilha aqui'
                                      : fileName!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Text.rich(
                                  TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppColors.inkMuted),
                                    children: [
                                      const TextSpan(
                                        text:
                                            'Aceitamos arquivos .CSV ou .XLSX com até 5000 linhas. ',
                                      ),
                                      if (kIsWeb)
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.baseline,
                                          baseline: TextBaseline.alphabetic,
                                          child: GestureDetector(
                                            onTap:
                                                downloadImportExampleTemplate,
                                            child: Text(
                                              'Baixe nosso template de exemplo',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: AppColors.cherry,
                                                    fontWeight: FontWeight.w600,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationColor:
                                                        AppColors.cherry,
                                                  ),
                                            ),
                                          ),
                                        )
                                      else
                                        const TextSpan(
                                          text:
                                              'Use o template de exemplo na versão web.',
                                        ),
                                      if (kIsWeb)
                                        const TextSpan(
                                          text:
                                              ' para garantir que os dados estejam no formato correto.',
                                        ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                CheeryButton(
                                  label: 'Procurar no computador',
                                  icon: Icons.search,
                                  onPressed: isParsing ? null : onBrowse,
                                  isLoading: isParsing,
                                ),
                                if (errorMessage != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );

    const dashWidth = 7.0;
    const dashSpace = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
