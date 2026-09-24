import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../state/apontamento_registro.dart';
import 'dashboard_screen.dart';

String _fmtDataHora(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
    'às ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Consulta de Apontamentos agrícolas (Administrativo) — só leitura, com os
/// mesmos campos do cadastro (`ApontamentoFlow`): identificação, dados da
/// operação e as 5 coleções de lançamento. Mesma anatomia de
/// `DashOrdemServico` (Lei 2 — fonte única de dados, aqui
/// `apontamentoRegistroStoreProvider`).
class DashApontamentos extends ConsumerWidget {
  const DashApontamentos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registros = ref.watch(
      apontamentoRegistroStoreProvider.select((s) => s.registros),
    );

    return DashboardScreen(
      title: 'Apontamentos agrícolas',
      child: registros.isEmpty
          ? const AppEmptyState(
              icon: AppIcons.fileText,
              title: 'Nenhum apontamento registrado',
              description:
                  'Apontamentos agrícolas lançados pelo Operacional nesta sessão aparecem aqui.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final registro in registros) ...[
                  _ApontamentoCard(
                    registro: registro,
                    onTap: () => _abrirDetalhe(context, registro),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                ],
              ],
            ),
    );
  }

  void _abrirDetalhe(BuildContext context, ApontamentoRegistro registro) {
    showAppBottomSheet<void>(
      context,
      title: 'Detalhe do apontamento',
      child: _ApontamentoDetailBody(registro: registro),
    );
  }
}

class _ApontamentoCard extends StatelessWidget {
  const _ApontamentoCard({required this.registro, required this.onTap});

  final ApontamentoRegistro registro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppCard(
      interactive: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${registro.operacao} · ${registro.atividade}',
                  style: TextStyle(
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.fgDefault,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              AppChip(child: Text(registro.data)),
            ],
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            '${registro.responsavel} · ${registro.area}',
            style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
          ),
          const SizedBox(height: AppSpacing.space2),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: [
              if (registro.cultura != null)
                AppChip(child: Text(registro.cultura!)),
              if (registro.safra != null) AppChip(child: Text(registro.safra!)),
              AppChip(child: Text('${registro.totalLancamentos} lançamento(s)')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApontamentoDetailBody extends StatelessWidget {
  const _ApontamentoDetailBody({required this.registro});

  final ApontamentoRegistro registro;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppTypography.sm,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgMuted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          child,
        ],
      ),
    );

    Widget kv(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgDefault),
            ),
          ),
        ],
      ),
    );

    Widget bulletList(List<String> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space1),
            child: Text(
              '· $item',
              style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgDefault),
            ),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${registro.operacao} · ${registro.atividade}',
                style: TextStyle(
                  fontSize: AppTypography.lg,
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.fgDefault,
                ),
              ),
            ),
            AppChip(child: Text(registro.data)),
          ],
        ),
        if (registro.descricao.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space1),
          Text(
            registro.descricao,
            style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
          ),
        ],
        section(
          'Identificação',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kv('Responsável', registro.responsavel),
              kv('Área', registro.area),
              kv('Operação', registro.operacao),
              kv('Atividade', registro.atividade),
              kv('Data do apontamento', registro.data),
            ],
          ),
        ),
        section(
          'Dados da operação',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kv('Área total', '${registro.areaTotal} ha'),
              kv('Área utilizada', '${registro.areaUtilizada} ha'),
              if (registro.cultura != null) kv('Cultura / variedade', registro.cultura!),
              if (registro.safra != null) kv('Safra', registro.safra!),
              if (registro.armazemInsumo != null)
                kv('Armazém de insumo', registro.armazemInsumo!),
              kv('Armazém de produção', registro.armazemProducao),
            ],
          ),
        ),
        if (registro.maoDeObra.isNotEmpty)
          section('Mão de obra / Serviços', bulletList(registro.maoDeObra)),
        if (registro.maquinas.isNotEmpty)
          section('Máquinas / Implementos', bulletList(registro.maquinas)),
        if (registro.insumos.isNotEmpty)
          section('Insumos', bulletList(registro.insumos)),
        if (registro.producoes.isNotEmpty)
          section('Produção', bulletList(registro.producoes)),
        if (registro.ocorrencias.isNotEmpty)
          section('Ocorrências', bulletList(registro.ocorrencias)),
        section(
          'Registrado em',
          Text(
            _fmtDataHora(registro.registradoEm),
            style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgDefault),
          ),
        ),
      ],
    );
  }
}
