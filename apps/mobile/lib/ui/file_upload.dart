import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import '../design/generated/app_layout.dart';

/// Espelha `FileUpload.tsx` — dropzone/seletor de arquivo (ex.: XML da NF-e).
///
/// Desvio do React: o protótipo web não faz upload real (usa `<input type="file">`
/// só para abrir o seletor do SO e cai num nome fixo — `nota-fiscal.xml` — quando
/// não há arquivo real). Como este pacote não depende de `file_picker` (fora do
/// escopo desta tarefa e do `pubspec.yaml` atual), o componente é **controlado**
/// (`value`/`onChanged`, como os demais do catálogo): tocar na dropzone dispara
/// `onChanged('nota-fiscal.xml')`, simulando a mesma seleção fictícia do React.
/// Uma tela que integre um seletor de arquivo real (via `file_picker`) troca esse
/// `onChanged` por um fluxo de picker de verdade sem alterar este widget.
class AppFileUpload extends StatelessWidget {
  const AppFileUpload({
    super.key,
    required this.onChanged,
    this.value,
    this.accept = '.xml',
    this.hint = 'Toque para selecionar o arquivo',
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String accept;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    if (value != null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.space3),
        decoration: BoxDecoration(
          color: AppColors.brand50,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.brand200),
        ),
        child: Row(
          children: [
            AppIcon(
              AppIcons.fileCheck2,
              size: AppSize.iconMd,
              color: semantic.accentDefault,
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Text(
                value!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.md,
                  fontWeight: AppTypography.weightMedium,
                  color: semantic.fgDefault,
                ),
              ),
            ),
            Semantics(
              button: true,
              label: 'Remover arquivo',
              child: InkWell(
                onTap: () => onChanged(null),
                child: AppIcon(
                  AppIcons.x,
                  size: AppSize.iconSmPlus,
                  color: semantic.fgSubtle,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => onChanged('nota-fiscal.xml'),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: semantic.borderStrong, width: 2),
          color: semantic.bgSubtle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              AppIcons.uploadCloud,
              size: AppSize.iconXl,
              color: semantic.fgSubtle,
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              'Selecionar arquivo ${accept.replaceFirst('.', '').toUpperCase()}',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.md,
                fontWeight: AppTypography.weightSemibold,
                color: semantic.fgDefault,
              ),
            ),
            const SizedBox(height: AppSpacing.space1),
            Text(
              hint,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.base,
                color: semantic.fgMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

WidgetbookComponent buildFileUploadWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'FileUpload',
    useCases: [
      WidgetbookUseCase(
        name: 'Interativo',
        builder: (context) => const _FileUploadUseCase(),
      ),
    ],
  );
}

class _FileUploadUseCase extends StatefulWidget {
  const _FileUploadUseCase();

  @override
  State<_FileUploadUseCase> createState() => _FileUploadUseCaseState();
}

class _FileUploadUseCaseState extends State<_FileUploadUseCase> {
  String? _fileName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        child: AppFileUpload(
          value: _fileName,
          onChanged: (v) => setState(() => _fileName = v),
        ),
      ),
    );
  }
}
