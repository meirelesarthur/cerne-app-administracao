import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'bottom_sheet.dart';
import 'empty_state.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'field_capsule.dart';
import 'pressable.dart';
import 'package:cerne_app/design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';

class AppSearchSelectOption {
  const AppSearchSelectOption({
    required this.value,
    required this.label,
    this.detail,
  });

  final String value;
  final String label;
  final String? detail;
}

/// Espelha `SearchSelect.tsx`, adaptado para o padrão "dock": os domínios que
/// este campo representa (lote, produto, armazém, centro de custo...) são
/// massivos em produção, então a lista não pode ficar sempre inline dentro do
/// formulário (empurrando o resto do cadastro fora da viewport). O campo
/// mostra o valor selecionado como um dropdown fechado e, ao ser tocado, abre
/// [showAppSearchSelectDock] — um bottom sheet a 75% da altura da tela com
/// busca no topo e a lista rolável ocupando o espaço restante. Selecionar um
/// item fecha o dock e devolve o valor por `onChanged`, liberando o cadastro.
class AppSearchSelect extends StatelessWidget {
  const AppSearchSelect({
    super.key,
    required this.options,
    required this.onChanged,
    this.value,
    this.placeholder = 'Selecionar',
    this.searchPlaceholder = 'Buscar...',
    this.label,
    this.enabled = true,
    this.invalid = false,
  });

  final List<AppSearchSelectOption> options;
  final String? value;
  final ValueChanged<String> onChanged;
  final String placeholder;
  final String searchPlaceholder;

  /// Título exibido no topo do dock — em geral o mesmo rótulo do campo
  /// (`AppFormField.label`), para orientar a busca. Opcional.
  final String? label;

  /// Permite manter uma etapa em cascata visível até o campo pai ser escolhido.
  final bool enabled;

  /// Borda de erro após a primeira tentativa de validação do formulário.
  final bool invalid;

  AppSearchSelectOption? get _selected {
    if (value == null || value!.isEmpty) return null;
    for (final option in options) {
      if (option.value == value) return option;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final inputColors = appInputColors(context);
    final selected = _selected;

    // A cápsula inteira é o alvo de toque (antes só o texto respondia: o ícone
    // de busca e a seta eram zonas mortas nas bordas).
    return AppPressable(
      semanticLabel:
          '${label ?? placeholder}: ${selected?.label ?? 'nada escolhido'}'
          '${enabled ? '' : ', indisponível'}',
      onPressed: enabled ? () => _open(context) : null,
      borderRadius: BorderRadius.circular(AppRadius.tile),
      minTouchTarget: false,
      child: AppFieldCapsule(
        invalid: invalid,
        leading: AppIcon(
          AppIcons.search,
          size: AppSize.iconSm,
          color: enabled ? inputColors.placeholder : inputColors.muted,
        ),
        trailing: AppIcon(
          AppIcons.chevronDown,
          size: AppSize.iconSm,
          color: enabled ? inputColors.placeholder : inputColors.muted,
        ),
        child: Text(
          selected?.label ?? placeholder,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.md,
            color: !enabled
                ? inputColors.muted
                : selected == null
                ? inputColors.placeholder
                : inputColors.foreground,
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    if (!enabled) return;
    final result = await showAppSearchSelectDock(
      context,
      options: options,
      value: value,
      title: label,
      searchPlaceholder: searchPlaceholder,
    );
    if (result != null) onChanged(result);
  }
}

/// Abre o dock de seleção com busca: bottom sheet fixo em 75% da altura da
/// tela (`maxHeightFraction: 0.75`, `expand: true` — a lista preenche esse
/// espaço em vez de crescer com o conteúdo), com o campo de busca no topo e a
/// lista rolável abaixo. Tocar numa opção fecha o dock devolvendo o valor;
/// tocar fora ou no fechar devolve `null` (sem mudança). A busca não recebe
/// foco automático ao abrir — só ao ser tocada — para não estourar o teclado
/// por cima do dock inteiro assim que ele aparece.
Future<String?> showAppSearchSelectDock(
  BuildContext context, {
  required List<AppSearchSelectOption> options,
  String? value,
  String? title,
  String searchPlaceholder = 'Buscar...',
}) {
  return showAppBottomSheet<String>(
    context,
    title: title,
    maxHeightFraction: 0.75,
    expand: true,
    child: _SearchSelectDockContent(
      options: options,
      value: value,
      searchPlaceholder: searchPlaceholder,
    ),
  );
}

class _SearchSelectDockContent extends StatefulWidget {
  const _SearchSelectDockContent({
    required this.options,
    required this.value,
    required this.searchPlaceholder,
  });

  final List<AppSearchSelectOption> options;
  final String? value;
  final String searchPlaceholder;

  @override
  State<_SearchSelectDockContent> createState() =>
      _SearchSelectDockContentState();
}

class _SearchSelectDockContentState extends State<_SearchSelectDockContent> {
  final _queryController = TextEditingController();

  /// O anel de foco é pintado pela cápsula, então o estado de foco precisa ser
  /// observável aqui.
  final _queryFocusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _queryFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _queryFocusNode.removeListener(_handleFocusChange);
    _queryFocusNode.dispose();
    _queryController.dispose();
    super.dispose();
  }

  void _handleFocusChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final inputColors = appInputColors(context);
    final filtered = widget.options
        .where((o) => o.label.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFieldCapsule(
          focused: _queryFocusNode.hasFocus,
          horizontalPadding: AppSpacing.space4,
          leading: AppIcon(
            AppIcons.search,
            size: AppSize.iconSm,
            color: inputColors.placeholder,
          ),
          child: TextField(
            controller: _queryController,
            focusNode: _queryFocusNode,
            onChanged: (v) => setState(() => _query = v),
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.md,
              color: inputColors.foreground,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              filled: false,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: widget.searchPlaceholder,
              hintStyle: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.md,
                color: inputColors.placeholder,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        Expanded(
          child: filtered.isEmpty
              // Duas variações: a busca zerou a lista, ou a lista já chegou
              // vazia (ex.: só produtos com estoque e nenhum tem saldo).
              ? Center(
                  child: SingleChildScrollView(
                    child: widget.options.isEmpty
                        ? const AppEmptyState(
                            size: AppEmptyStateSize.compact,
                            icon: AppIcons.inbox,
                            title: 'Nenhuma opção disponível',
                            description:
                                'Não há itens cadastrados para esta escolha.',
                          )
                        : const AppEmptyState(
                            size: AppEmptyStateSize.compact,
                            icon: AppIcons.search,
                            badgeIcon: AppIcons.x,
                            tone: AppEmptyStateTone.info,
                            title: 'Nada encontrado',
                            description: 'Tente outro termo de busca.',
                          ),
                  ),
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: semantic.borderSubtle),
                  itemBuilder: (context, index) {
                    final option = filtered[index];
                    final selected = option.value == widget.value;
                    return InkWell(
                      onTap: () => Navigator.of(context).pop(option.value),
                      child: Container(
                        color: selected
                            ? semantic.accentSubtle
                            : AppColors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space3,
                          vertical: AppSpacing.space3,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    option.label,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: AppTypography.md,
                                      fontWeight: AppTypography.weightMedium,
                                      color: semantic.fgDefault,
                                    ),
                                  ),
                                  if (option.detail != null)
                                    Text(
                                      option.detail!,
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: AppTypography.md,
                                        color: semantic.fgMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (selected)
                              AppIcon(
                                AppIcons.check,
                                size: AppSize.iconSm,
                                color: semantic.accentDefault,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

WidgetbookComponent buildSearchSelectWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'SearchSelect',
    useCases: [
      WidgetbookUseCase(
        name: 'Interativo (dock)',
        builder: (context) => const _SearchSelectUseCase(),
      ),
      WidgetbookUseCase(
        name: 'Desabilitado até escolher o campo anterior',
        builder: (context) => Center(
          child: SizedBox(
            width: 320,
            child: AppSearchSelect(
              options: const [
                AppSearchSelectOption(value: 'atividade', label: 'Aração'),
              ],
              enabled: false,
              onChanged: (_) {},
              placeholder: 'Escolha uma operação primeiro',
              label: 'Atividade',
            ),
          ),
        ),
      ),
    ],
  );
}

class _SearchSelectUseCase extends StatefulWidget {
  const _SearchSelectUseCase();

  @override
  State<_SearchSelectUseCase> createState() => _SearchSelectUseCaseState();
}

class _SearchSelectUseCaseState extends State<_SearchSelectUseCase> {
  String? _value;

  static const _options = [
    AppSearchSelectOption(
      value: 'lote-01',
      label: 'Lote 01',
      detail: '120 sacas',
    ),
    AppSearchSelectOption(
      value: 'lote-02',
      label: 'Lote 02',
      detail: '80 sacas',
    ),
    AppSearchSelectOption(
      value: 'lote-03',
      label: 'Lote 03',
      detail: '210 sacas',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        child: AppSearchSelect(
          options: _options,
          value: _value,
          onChanged: (v) => setState(() => _value = v),
          placeholder: 'Selecionar lote',
          searchPlaceholder: 'Buscar lote...',
          label: 'Lote',
        ),
      ),
    );
  }
}
