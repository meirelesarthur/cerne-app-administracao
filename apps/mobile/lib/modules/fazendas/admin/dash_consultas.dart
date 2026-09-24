import 'package:flutter/material.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../mocks/dashboards_mocks.dart';
import 'dashboard_screen.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../../../design/generated/app_layout.dart';

enum _Secao { lotes, estoque, pesagens, localizacao }

const _hub = [
  (id: _Secao.lotes, label: 'Lotes', icon: AppIcons.layers),
  (id: _Secao.estoque, label: 'Estoque', icon: AppIcons.boxes),
  (id: _Secao.pesagens, label: 'Pesagens do dia', icon: AppIcons.scale),
  (id: _Secao.localizacao, label: 'Localização', icon: AppIcons.mapPin),
];

/// Registros por página das listas de consulta — pequeno de propósito: são
/// telas de celular, e a amostra do protótipo é curta o bastante para que uma
/// página maior nunca pagine de verdade.
const _pageSize = 3;

/// Posições ilustrativas dos lotes no esquema da fazenda — fração da largura
/// e da altura do quadro, **não** coordenadas geográficas. O mapa segue a
/// mesma regra do resto da tela ("dados espelhados do web"): é um esquema com
/// dados mockados, não uma integração real de localização (spec §4.7 e
/// `CLAUDE.md` — Limites do protótipo).
const _posicoesLotes = <String, Offset>{
  'l1': Offset(0.24, 0.30),
  'l2': Offset(0.74, 0.24),
  'l3': Offset(0.54, 0.72),
  'l4': Offset(0.18, 0.80),
};

/// Consultas Gerenciais read-only (spec §4.7). 100% leitura: nenhum botão de
/// ação/edição. Localização de animais = esquema ilustrativo dos lotes, sem
/// GPS nem SDK de mapa — ver [_posicoesLotes]. Espelha `DashConsultas.tsx`.
class DashConsultas extends StatefulWidget {
  const DashConsultas({super.key});

  @override
  State<DashConsultas> createState() => _DashConsultasState();
}

class _DashConsultasState extends State<DashConsultas> {
  _Secao _secao = _Secao.lotes;
  final _searchController = TextEditingController();
  var _query = '';
  var _page = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LinhaConsulta> get _linhas => switch (_secao) {
    _Secao.lotes => lotes,
    _Secao.estoque => estoque,
    _Secao.pesagens => pesagensDia,
    _Secao.localizacao => const [],
  };

  void _selecionarSecao(_Secao secao) {
    if (secao == _secao) return;
    setState(() {
      _secao = secao;
      _query = '';
      _page = 0;
      _searchController.clear();
    });
  }

  void _setQuery(String value) => setState(() {
    _query = value;
    _page = 0;
  });

  void _setPage(int page) => setState(() => _page = page);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final ativo = _hub.firstWhere((h) => h.id == _secao);

    return DashboardScreen(
      title: 'Consultas Gerenciais',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppIcon(
                AppIcons.lock,
                size: AppSize.iconXs,
                color: semantic.fgSubtle,
              ),
              const SizedBox(width: AppSpacing.oneHalf),
              Text(
                'Somente leitura — dados espelhados do web.',
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  fontWeight: AppTypography.weightMedium,
                  color: semantic.fgSubtle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          // Trilho seletor de seção com a mesma anatomia do `AppDiscoveryTile`
          // da busca global (Lei 2 — fonte única): ícone em destaque, rótulo
          // na base e rolagem horizontal, em vez de um grid com borda própria.
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _hub.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.space2),
              itemBuilder: (context, index) {
                final h = _hub[index];
                return AppDiscoveryTile(
                  icon: h.icon,
                  label: h.label,
                  selected: _secao == h.id,
                  onTap: () => _selecionarSecao(h.id),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppSectionTitle(child: Text(ativo.label)),
          const SizedBox(height: AppSpacing.space2),
          if (_secao == _Secao.localizacao)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AppIcon(
                      AppIcons.info,
                      size: AppSize.iconXs,
                      color: semantic.fgSubtle,
                    ),
                    const SizedBox(width: AppSpacing.oneHalf),
                    Expanded(
                      child: Text(
                        'Posições ilustrativas dos lotes ativos — esquema, não georreferenciado.',
                        style: TextStyle(
                          fontSize: AppTypography.sm,
                          color: semantic.fgSubtle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                const _MapaIlustrativo(rows: lotes),
              ],
            )
          else
            _ConsultaLista(
              rows: _linhas,
              query: _query,
              page: _page,
              searchController: _searchController,
              onQueryChanged: _setQuery,
              onPageChanged: _setPage,
            ),
        ],
      ),
    );
  }
}

/// Busca e paginação de uma seção de consulta — mesmo padrão de
/// `_RecordsList` (`mapped_feature_screen.dart`): campo de busca com
/// `AppTextInput`, lista filtrada e `AppPagination` no rodapé (Lei 2).
class _ConsultaLista extends StatelessWidget {
  const _ConsultaLista({
    required this.rows,
    required this.query,
    required this.page,
    required this.searchController,
    required this.onQueryChanged,
    required this.onPageChanged,
  });

  final List<LinhaConsulta> rows;
  final String query;
  final int page;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final termo = query.trim().toLowerCase();
    final filtradas = termo.isEmpty
        ? rows
        : rows
              .where(
                (r) => '${r.titulo} ${r.subtitulo} ${r.meta}'
                    .toLowerCase()
                    .contains(termo),
              )
              .toList(growable: false);
    final pageCount = (filtradas.length / _pageSize).ceil().clamp(1, 999);
    final currentPage = page.clamp(0, pageCount - 1);
    final start = currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, filtradas.length);
    final visiveis = filtradas.sublist(start, end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormField(
          label: 'Buscar registros',
          child: AppTextInput(
            controller: searchController,
            placeholder: 'Nome, curral ou detalhe',
            prefixIcon: const AppIcon(AppIcons.search),
            onChanged: onQueryChanged,
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        if (filtradas.isEmpty)
          const AppEmptyState(
            icon: AppIcons.searchX,
            title: 'Nenhum registro encontrado',
            description: 'Ajuste a busca para encontrar outro item.',
          )
        else
          _ReadOnlyList(rows: visiveis),
        if (filtradas.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space3),
          AppPagination(
            page: currentPage,
            totalItems: filtradas.length,
            pageSize: _pageSize,
            onPageChanged: onPageChanged,
          ),
        ],
      ],
    );
  }
}

/// Esquema ilustrativo dos lotes na fazenda — pinos posicionados por fração
/// do quadro ([_posicoesLotes]), não por coordenada real. Substitui o antigo
/// placeholder "carregamento em desenvolvimento": a renderização é leve o
/// bastante (sem tiles nem SDK externo) para não depender de uma integração
/// pesada, mas segue rotulada como esquema — nunca como localização real.
class _MapaIlustrativo extends StatelessWidget {
  const _MapaIlustrativo({required this.rows});

  final List<LinhaConsulta> rows;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Container(
      height: 260,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: semantic.bgSubtle,
        border: Border.all(color: semantic.borderDefault),
        borderRadius: BorderRadius.circular(AppRadius.xl2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (final r in rows)
                if (_posicoesLotes[r.id] case final posicao?)
                  Positioned(
                    left: constraints.maxWidth * posicao.dx - 44,
                    top: constraints.maxHeight * posicao.dy - 34,
                    child: _PinLote(row: r),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _PinLote extends StatelessWidget {
  const _PinLote({required this.row});

  final LinhaConsulta row;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return SizedBox(
      width: 88,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: semantic.bgSurface,
              shape: BoxShape.circle,
              border: Border.all(color: semantic.accentDefault),
            ),
            child: AppIcon(
              AppIcons.mapPin,
              size: AppSize.iconMd,
              color: semantic.accentDefault,
            ),
          ),
          const SizedBox(height: AppSpacing.oneHalf),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space2,
              vertical: AppSpacing.oneHalf,
            ),
            decoration: BoxDecoration(
              color: semantic.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: semantic.borderSubtle),
            ),
            child: Text(
              '${row.titulo} · ${row.meta}',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.sm,
                fontWeight: AppTypography.weightMedium,
                color: semantic.fgDefault,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyList extends StatelessWidget {
  const _ReadOnlyList({required this.rows});

  final List<LinhaConsulta> rows;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: semantic.bgSurface,
        border: Border.all(color: semantic.borderDefault),
        borderRadius: BorderRadius.circular(AppRadius.xl2),
      ),
      child: Column(
        children: [
          for (final r in rows) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
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
                          r.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: AppTypography.weightSemibold,
                            color: semantic.fgDefault,
                          ),
                        ),
                        Text(
                          r.subtitulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.base,
                            color: semantic.fgMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppChip(child: Text(r.meta)),
                ],
              ),
            ),
            if (r != rows.last)
              Divider(height: 1, color: semantic.borderSubtle),
          ],
        ],
      ),
    );
  }
}
