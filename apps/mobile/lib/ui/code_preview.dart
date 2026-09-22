import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'icon_button.dart';

/// Fonte monoespaçada usada exclusivamente para exibir trechos de código nos
/// painéis de handoff do Widgetbook — não é uma segunda família de
/// apresentação do app (a Lei 3 do CLAUDE.md, "Outfit é a única família
/// tipográfica", continua valendo integralmente para as telas reais).
/// Deliberadamente fora do pipeline DTCG (design/tokens.ts → tokens.json →
/// Dart gerado): não é um token de produto, é uma convenção só deste painel
/// de ferramenta de desenvolvimento. Centralizada aqui para nunca virar
/// literal solto em múltiplos arquivos.
const kCodeFontFamily = 'monospace';

/// Painel de handoff do Widgetbook: mostra a prévia viva de um caso de uso e,
/// logo abaixo, o trecho Dart exato que a produz — copiável com um toque.
/// Uso: envolver o `builder` de um `WidgetbookUseCase` com este widget,
/// passando o mesmo código-fonte como string em `code`.
///
/// Só aparece dentro do Widgetbook (ferramenta de desenvolvimento); nunca é
/// consumido pelas telas do app real.
class AppCodePreview extends StatefulWidget {
  const AppCodePreview({
    super.key,
    required this.code,
    required this.child,
    this.title,
  });

  /// Trecho Dart exibido e copiável — normalmente o próprio literal usado
  /// para construir [child] no caso de uso.
  final String code;

  /// Prévia viva do componente.
  final Widget child;

  /// Rótulo do painel de código (padrão: "Código").
  final String? title;

  @override
  State<AppCodePreview> createState() => _AppCodePreviewState();
}

class _AppCodePreviewState extends State<AppCodePreview> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.space6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: semantic.bgSubtle,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: semantic.borderSubtle),
          ),
          child: widget.child,
        ),
        const SizedBox(height: AppSpacing.space3),
        Container(
          decoration: BoxDecoration(
            color: semantic.inkBg,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: semantic.inkLine),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  AppSpacing.space1,
                  AppSpacing.space2,
                  AppSpacing.space1,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title ?? 'Código',
                        style: TextStyle(
                          color: semantic.inkMuted,
                          fontSize: AppTypography.xs,
                          fontWeight: AppTypography.weightSemibold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    AppIconButton(
                      icon: AppIcon(
                        _copied ? AppIcons.check : AppIcons.copy,
                        color: semantic.inkFg,
                      ),
                      label: 'Copiar código',
                      size: AppIconButtonSize.sm,
                      variant: AppIconButtonVariant.onDark,
                      onPressed: _copy,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  0,
                  AppSpacing.space4,
                  AppSpacing.space4,
                ),
                child: SelectableText(
                  widget.code,
                  style: TextStyle(
                    fontFamily: kCodeFontFamily,
                    fontSize: AppTypography.sm,
                    height: 1.5,
                    color: semantic.inkFg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

WidgetbookComponent buildCodePreviewWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Code Preview',
    useCases: [
      WidgetbookUseCase(
        name: 'Exemplo',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppCodePreview(
            code: '''
AppCodePreview(
  code: '...',
  child: AppButton(
    onPressed: () {},
    child: Text('Exemplo'),
  ),
)''',
            child: Text('Prévia do componente aparece aqui'),
          ),
        ),
      ),
    ],
  );
}
