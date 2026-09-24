import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'button.dart';
import 'collection_list.dart';
import 'collection_manager_sheet.dart';
import 'icon_button.dart';
import 'pressable.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Um grupo (coleção) da grade: nome, ícone, quantos itens tem e um resumo
/// agregado opcional.
class AppSquareGroup {
  const AppSquareGroup({
    required this.name,
    this.icon,
    this.count = 0,
    this.summary,
    this.wide = false,
  });

  /// Nome do grupo, como no contrato ("Insumos"). Também é a chave devolvida
  /// em `onAdd`/`onOpen`.
  final String name;

  final AppIconData? icon;
  final int count;

  /// Resumo agregado do que há dentro — **nunca o nome de um item** (com 7
  /// itens não há qual escolher). Ex.: "R$ 30,00", "120 kg", "Prioridade
  /// alta". Só aparece com [count] > 0.
  final String? summary;

  /// Ocupa a linha inteira, em layout horizontal — para o grupo que sobra da
  /// grade 2x2 (ex.: "Ocorrências" no apontamento). Mesmo comportamento dos
  /// cards quadrados, só muda a forma.
  final bool wide;
}

/// Grade de coleções de um cadastro: cada card é uma **gaveta** — mostra o
/// que é, quantos itens tem e um resumo agregado, mas nunca os itens soltos.
///
/// Um toque só, uma regra só:
/// - **card vazio** (borda tracejada, "Nenhum item"): tocar em qualquer lugar
///   abre o formulário de adicionar ([onAdd]);
/// - **card com itens** (borda sólida de acento, "3 itens incluídos",
///   chevron): tocar abre o que tem dentro ([onOpen]) — normalmente
///   [showAppCollectionManager], onde se lista, edita, remove e adiciona. O
///   "+" do card fica como atalho de adição rápida.
///
/// A altura dos cards não depende da quantidade de itens: 1 ou 10 itens usam
/// o mesmo card, e os dois cards de uma linha têm sempre a mesma altura.
///
/// Sem [onOpen] (`null`) todo card se comporta como vazio: tocar adiciona.
class AppSquareGroupGrid extends StatelessWidget {
  const AppSquareGroupGrid({
    super.key,
    required this.groups,
    required this.onAdd,
    this.onOpen,
  });

  final List<AppSquareGroup> groups;
  final ValueChanged<String> onAdd;
  final ValueChanged<String>? onOpen;

  @override
  Widget build(BuildContext context) {
    final rows = <List<AppSquareGroup>>[];
    for (final group in groups) {
      final last = rows.isEmpty ? null : rows.last;
      if (group.wide || last == null || last.length == 2 || last.first.wide) {
        rows.add([group]);
      } else {
        last.add(group);
      }
    }

    Widget card(AppSquareGroup group) => _GroupCard(
      key: ValueKey('square-group-${group.name}'),
      group: group,
      onAdd: () => onAdd(group.name),
      onOpen: onOpen == null ? null : () => onOpen!(group.name),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.space3),
          if (rows[i].first.wide)
            card(rows[i].first)
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: card(rows[i].first)),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: rows[i].length > 1
                        ? card(rows[i][1])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    super.key,
    required this.group,
    required this.onAdd,
    this.onOpen,
  });

  final AppSquareGroup group;
  final VoidCallback onAdd;
  final VoidCallback? onOpen;

  bool get _filled => group.count > 0 && onOpen != null;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final filled = _filled;
    final radius = BorderRadius.circular(AppRadius.xl2);

    final status = group.count == 0
        ? 'Nenhum item'
        : appItemCountLabel(group.count);
    final summary = group.count > 0 ? group.summary : null;

    final content = group.wide
        ? _WideContent(
            group: group,
            filled: filled,
            status: status,
            summary: summary,
            onAdd: onAdd,
          )
        : _SquareContent(
            group: group,
            filled: filled,
            status: status,
            summary: summary,
            onAdd: onAdd,
          );

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: filled ? semantic.accentSubtle : semantic.bgSurface,
        borderRadius: radius,
        border: filled
            ? Border.all(color: semantic.accentDefault.withValues(alpha: 0.35))
            : null,
      ),
      child: CustomPaint(
        foregroundPainter: filled
            ? null
            : _DashedBorderPainter(
                color: semantic.borderStrong,
                radius: AppRadius.xl2,
              ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: content,
        ),
      ),
    );

    return AppPressable(
      semanticLabel: [
        group.name,
        status,
        ?summary,
        filled ? 'toque para ver e editar' : 'toque para adicionar',
      ].join(', '),
      onPressed: filled ? onOpen : onAdd,
      borderRadius: radius,
      minTouchTarget: false,
      // Com itens, o "+" interno é um botão real e precisa continuar
      // acessível; vazio, o card inteiro é o único alvo.
      excludeSemantics: !filled,
      child: surface,
    );
  }
}

/// Quadradinho do ícone do grupo — neutro quando vazio, acento quando tem
/// itens.
class _GroupIcon extends StatelessWidget {
  const _GroupIcon({required this.icon, required this.filled});

  final AppIconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Container(
      width: AppSpacing.space9,
      height: AppSpacing.space9,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? semantic.bgSurface : semantic.bgCanvas,
        borderRadius: BorderRadius.circular(AppRadius.base),
      ),
      child: AppIcon(
        icon,
        size: AppSize.iconMd,
        color: filled ? semantic.accentDefault : semantic.fgMuted,
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({
    required this.status,
    required this.summary,
    required this.filled,
  });

  final String status;
  final String? summary;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppTypography.sm,
              fontWeight: filled
                  ? AppTypography.weightSemibold
                  : AppTypography.weightNormal,
              color: filled ? semantic.accentDefault : semantic.fgMuted,
            ),
          ),
          if (summary case final summary?)
            Text(
              summary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: semantic.fgMuted,
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return ExcludeSemantics(
      child: Text(
        name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: AppTypography.sm,
          fontWeight: AppTypography.weightSemibold,
          color: semantic.fgDefault,
        ),
      ),
    );
  }
}

/// "+ Adicionar" do card vazio: parece botão, mas o alvo é o card inteiro —
/// `IgnorePointer` deixa o toque cair no card e evita dois alvos iguais.
class _AddPill extends StatelessWidget {
  const _AddPill({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    // Em cards muito estreitos o botão encolhe inteiro em vez de estourar.
    return IgnorePointer(
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: AppButton(
            size: AppButtonSize.sm,
            variant: AppButtonVariant.secondary,
            leftIcon: const AppIcon(AppIcons.plus, size: AppSize.iconSm),
            onPressed: onAdd,
            child: const Text('Adicionar'),
          ),
        ),
      ),
    );
  }
}

class _QuickAdd extends StatelessWidget {
  const _QuickAdd({required this.name, required this.onAdd});

  final String name;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: semantic.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: semantic.borderDefault),
      ),
      child: AppIconButton(
        size: AppIconButtonSize.sm,
        icon: const AppIcon(AppIcons.plus, size: AppSize.iconSm),
        label: 'Adicionar em $name',
        onPressed: onAdd,
      ),
    );
  }
}

class _SeeItems extends StatelessWidget {
  const _SeeItems();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              'Ver itens',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.sm,
                fontWeight: AppTypography.weightSemibold,
                color: semantic.accentDefault,
              ),
            ),
          ),
          AppIcon(
            AppIcons.chevronRight,
            size: AppSize.iconSm,
            color: semantic.accentDefault,
          ),
        ],
      ),
    );
  }
}

class _SquareContent extends StatelessWidget {
  const _SquareContent({
    required this.group,
    required this.filled,
    required this.status,
    required this.summary,
    required this.onAdd,
  });

  final AppSquareGroup group;
  final bool filled;
  final String status;
  final String? summary;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (group.icon case final icon?) ...[
          _GroupIcon(icon: icon, filled: filled),
          const SizedBox(height: AppSpacing.space3),
        ],
        _GroupTitle(group.name),
        const SizedBox(height: AppSpacing.space2),
        const Spacer(),
        _StatusText(status: status, summary: summary, filled: filled),
        const SizedBox(height: AppSpacing.space3),
        if (filled)
          Row(
            children: [
              const Expanded(child: _SeeItems()),
              _QuickAdd(name: group.name, onAdd: onAdd),
            ],
          )
        else
          _AddPill(onAdd: onAdd),
      ],
    );
  }
}

class _WideContent extends StatelessWidget {
  const _WideContent({
    required this.group,
    required this.filled,
    required this.status,
    required this.summary,
    required this.onAdd,
  });

  final AppSquareGroup group;
  final bool filled;
  final String status;
  final String? summary;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (group.icon case final icon?) ...[
          _GroupIcon(icon: icon, filled: filled),
          const SizedBox(width: AppSpacing.space3),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _GroupTitle(group.name),
              _StatusText(status: status, summary: summary, filled: filled),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.space2),
        if (filled) ...[
          _QuickAdd(name: group.name, onAdd: onAdd),
          const SizedBox(width: AppSpacing.space1),
          const _SeeItems(),
        ] else
          _AddPill(onAdd: onAdd),
      ],
    );
  }
}

/// Borda tracejada do card vazio — "espaço esperando conteúdo". O Flutter
/// não tem borda tracejada nativa; o traço segue o contorno arredondado.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const _dash = AppSpacing.space1 * 1.5;
  static const _gap = AppSpacing.space1;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.5),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

// ---------------------------------------------------------------------------
// Widgetbook
// ---------------------------------------------------------------------------

const _grupoMaoDeObra = 'Mão de obra / Serviços';
const _grupoMaquinas = 'Máquinas / Implementos';
const _grupoInsumos = 'Insumos';
const _grupoProducao = 'Produção';
const _grupoOcorrencias = 'Ocorrências';

List<AppSquareGroup> _apontamentoGroups(Map<String, int> counts) => [
  AppSquareGroup(
    name: _grupoMaoDeObra,
    icon: AppIcons.users,
    count: counts[_grupoMaoDeObra] ?? 0,
    summary: 'R\$ ${(counts[_grupoMaoDeObra] ?? 0) * 10},00',
  ),
  AppSquareGroup(
    name: _grupoMaquinas,
    icon: AppIcons.tractor,
    count: counts[_grupoMaquinas] ?? 0,
    summary: '${(counts[_grupoMaquinas] ?? 0) * 4} h · R\$ 480,00',
  ),
  AppSquareGroup(
    name: _grupoInsumos,
    icon: AppIcons.package,
    count: counts[_grupoInsumos] ?? 0,
    summary: 'R\$ 1.245,90',
  ),
  AppSquareGroup(
    name: _grupoProducao,
    icon: AppIcons.wheat,
    count: counts[_grupoProducao] ?? 0,
    summary: '120 sc',
  ),
  AppSquareGroup(
    name: _grupoOcorrencias,
    icon: AppIcons.triangleAlert,
    count: counts[_grupoOcorrencias] ?? 0,
    summary: 'Prioridade alta',
    wide: true,
  ),
];

WidgetbookComponent buildSquareGroupGridWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'SquareGroupGrid',
    useCases: [
      WidgetbookUseCase(
        name: 'Interativo (apontamento)',
        builder: (context) => const _InteractiveUseCase(),
      ),
      WidgetbookUseCase(
        name: 'Estados: 0, 1 e 10 itens',
        builder: (context) => _StaticUseCase(
          groups: _apontamentoGroups({
            _grupoMaoDeObra: 1,
            _grupoMaquinas: 0,
            _grupoInsumos: 10,
            _grupoProducao: 0,
            _grupoOcorrencias: 3,
          }),
        ),
      ),
      WidgetbookUseCase(
        name: 'Tudo vazio (primeiro acesso)',
        builder: (context) => _StaticUseCase(groups: _apontamentoGroups({})),
      ),
      WidgetbookUseCase(
        name: 'Controle de quantidade (knob)',
        builder: (context) {
          final count = context.knobs.int.slider(
            label: 'Itens em Insumos',
            initialValue: 1,
            max: 12,
          );
          final summary = context.knobs.boolean(
            label: 'Mostrar resumo agregado',
          );
          return _StaticUseCase(
            groups: [
              AppSquareGroup(
                name: _grupoInsumos,
                icon: AppIcons.package,
                count: count,
                summary: summary ? 'R\$ ${count * 125},00' : null,
              ),
              const AppSquareGroup(name: _grupoProducao, icon: AppIcons.wheat),
            ],
          );
        },
      ),
      WidgetbookUseCase(
        name: 'Sem ícone e sem gerenciar (só adicionar)',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppSquareGroupGrid(
            groups: const [
              AppSquareGroup(name: 'Etapas', count: 2),
              AppSquareGroup(name: 'Anexos'),
            ],
            onAdd: (_) {},
          ),
        ),
      ),
    ],
  );
}

class _StaticUseCase extends StatelessWidget {
  const _StaticUseCase({required this.groups});

  final List<AppSquareGroup> groups;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSize.phone),
          child: AppSquareGroupGrid(
            groups: groups,
            onAdd: (_) {},
            onOpen: (_) {},
          ),
        ),
      ),
    );
  }
}

/// Grade + gerenciador ligados como no apontamento: adicionar no card vazio,
/// abrir o card com itens, editar, remover e desfazer.
class _InteractiveUseCase extends StatefulWidget {
  const _InteractiveUseCase();

  @override
  State<_InteractiveUseCase> createState() => _InteractiveUseCaseState();
}

class _InteractiveUseCaseState extends State<_InteractiveUseCase> {
  final _items = <String, List<String>>{
    _grupoMaoDeObra: ['José da Silva'],
    _grupoMaquinas: [],
    _grupoInsumos: [],
    _grupoProducao: [],
    _grupoOcorrencias: [],
  };

  Future<void> _add(String group) async {
    final list = _items[group]!;
    setState(() => list.add('$group — item ${list.length + 1}'));
  }

  void _open(BuildContext context, String group) {
    final list = _items[group]!;
    showAppCollectionManager(
      context,
      title: group,
      items: () => [
        for (final item in list)
          AppCollectionItemView(title: item, subtitle: '1 un · R\$ 10,00'),
      ],
      summary: () => 'R\$ ${list.length * 10},00',
      onAdd: () => _add(group),
      onEdit: (index) async =>
          setState(() => list[index] = '${list[index]} (editado)'),
      onRemove: (index) {
        final removed = list.removeAt(index);
        setState(() {});
        return () => setState(() => list.insert(index, removed));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final counts = {
      for (final entry in _items.entries) entry.key: entry.value.length,
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSize.phone),
          child: Builder(
            builder: (context) => AppSquareGroupGrid(
              groups: _apontamentoGroups(counts),
              onAdd: _add,
              onOpen: (group) => _open(context, group),
            ),
          ),
        ),
      ),
    );
  }
}
