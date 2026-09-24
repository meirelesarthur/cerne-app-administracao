import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design/generated/app_layout.dart';
import '../../../../design/generated/app_spacing.dart';
import '../../../../ui/ui.dart';
import '../../state/fazendas_store.dart';
import '../models.dart';
import '../state/ordem_servico_store.dart';
import 'os_detail_page.dart';

/// Abre o formulário de criação de OS em **tela cheia** — mesmo padrão do
/// detalhe ([abrirDetalheOs]): empilhado no navigator raiz, cobre a navbar, e
/// o "Voltar" devolve à lista de origem. A folha inferior fica só para
/// escolhas e entradas curtas; um cadastro de seis campos é tela funda.
void abrirCriarOs(BuildContext context) {
  Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(builder: (_) => const OsCreatePage()),
  );
}

/// O "+" de criar OS, encostado à direita do título da lista — fonte única
/// para a aba "OS" e para o dashboard da busca global (Lei 2).
class OsCriarButton extends StatelessWidget {
  const OsCriarButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: const AppIcon(AppIcons.plus, size: AppSize.iconMd),
      label: 'Criar OS',
      variant: AppIconButtonVariant.solid,
      onPressed: () => abrirCriarOs(context),
    );
  }
}

/// Tela cheia de criação de OS (Administrativo). O envio fica no rodapé fixo
/// (`AppActionBar`); ao criar, a OS entra no store como "Aguardando" e a tela
/// fecha, devolvendo à lista já atualizada.
class OsCreatePage extends ConsumerStatefulWidget {
  const OsCreatePage({super.key});

  @override
  ConsumerState<OsCreatePage> createState() => _OsCreatePageState();
}

class _OsCreatePageState extends ConsumerState<OsCreatePage> {
  final _tituloController = TextEditingController();
  final _areaController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _prazoController = TextEditingController();
  var _tipo = TipoServicoOs.agricola.name;
  var _prioridade = PrioridadeOs.media.name;
  DateTime? _prazo;

  @override
  void dispose() {
    _tituloController.dispose();
    _areaController.dispose();
    _descricaoController.dispose();
    _prazoController.dispose();
    super.dispose();
  }

  void _criar() {
    final titulo = _tituloController.text.trim();
    final area = _areaController.text.trim();
    final descricao = _descricaoController.text.trim();
    final prazo = _prazo;
    if (titulo.isEmpty || area.isEmpty || descricao.isEmpty || prazo == null) {
      return;
    }
    ref
        .read(ordemServicoStoreProvider.notifier)
        .criar(
          titulo: titulo,
          tipo: TipoServicoOs.values.byName(_tipo),
          fazenda: ref.read(fazendasStoreProvider).activeFarm.name,
          areaOuTalhao: area,
          prioridade: PrioridadeOs.values.byName(_prioridade),
          prazo: prazo,
          descricao: descricao,
          autor: autorAdministrativoOs,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Criar OS',
      onBack: () => Navigator.of(context).maybePop(),
      actionBar: AppActionBar(primaryLabel: 'Criar OS', onPrimary: _criar),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormField(
            label: 'Título',
            required: true,
            child: AppTextInput(
              controller: _tituloController,
              placeholder: 'Ex.: Reparo de cerca do Talhão 04',
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          AppFormField(
            label: 'Tipo de serviço',
            required: true,
            child: AppFormSelect(
              options: [
                for (final t in TipoServicoOs.values)
                  AppFormSelectOption(value: t.name, label: t.label),
              ],
              value: _tipo,
              onChanged: (v) => setState(() => _tipo = v ?? _tipo),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          AppFormField(
            label: 'Área / talhão',
            required: true,
            child: AppTextInput(
              controller: _areaController,
              placeholder: 'Ex.: Talhão 04',
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          AppFormField(
            label: 'Prioridade',
            required: true,
            child: AppFormSelect(
              options: [
                for (final p in PrioridadeOs.values)
                  AppFormSelectOption(value: p.name, label: p.label),
              ],
              value: _prioridade,
              onChanged: (v) =>
                  setState(() => _prioridade = v ?? _prioridade),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          AppFormField(
            label: 'Prazo',
            required: true,
            child: AppDateInput(
              controller: _prazoController,
              onChanged: (formatted) {
                final match = RegExp(
                  r'^(\d{2})/(\d{2})/(\d{4})$',
                ).firstMatch(formatted);
                if (match == null) return;
                final dia = int.parse(match.group(1)!);
                final mes = int.parse(match.group(2)!);
                final ano = int.parse(match.group(3)!);
                setState(() => _prazo = DateTime(ano, mes, dia));
              },
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          AppFormField(
            label: 'Descrição',
            required: true,
            child: AppTextarea(
              controller: _descricaoController,
              placeholder: 'Detalhe o que precisa ser feito...',
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
        ],
      ),
    );
  }
}
