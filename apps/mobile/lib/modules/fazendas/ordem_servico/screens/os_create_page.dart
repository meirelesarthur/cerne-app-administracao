import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design/generated/app_layout.dart';
import '../../../../design/generated/app_spacing.dart';
import '../../../../ui/ui.dart';
import '../../state/fazendas_store.dart';
import '../models.dart';
import '../state/ordem_servico_store.dart';
import '../widgets.dart';
import 'os_detail_page.dart';

/// Abre o formulário de criação de OS em **tela cheia** — mesmo padrão do
/// detalhe ([abrirDetalheOs]): empilhado no navigator raiz, cobre a navbar, e
/// o "Voltar" devolve à lista de origem. A folha inferior fica só para
/// escolhas e entradas curtas; um cadastro de seis campos é tela funda.
void abrirCriarOs(BuildContext context) {
  Navigator.of(
    context,
    rootNavigator: true,
  ).push<void>(MaterialPageRoute<void>(builder: (_) => const OsCreatePage()));
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
/// (`AppActionBar`). Mesmo padrão de validação do app Operação: enviar com
/// algo faltando **mostra o erro no campo** (nunca "não faz nada"), e sair com
/// dados preenchidos pergunta antes ([AppPageScaffold.hasUnsavedChanges]).
/// Ao criar, a tela é trocada pelo detalhe da OS nova — a confirmação visível
/// de que ela foi registrada como "Aguardando".
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

  /// Liga os erros só depois da primeira tentativa de envio — abrir a tela
  /// já com tudo vermelho assusta mais do que orienta.
  var _tentou = false;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _tituloController,
      _areaController,
      _descricaoController,
      _prazoController,
    ]) {
      c.addListener(_redesenhar);
    }
  }

  void _redesenhar() => setState(() {});

  @override
  void dispose() {
    _tituloController.dispose();
    _areaController.dispose();
    _descricaoController.dispose();
    _prazoController.dispose();
    super.dispose();
  }

  bool get _temDados => [
    _tituloController,
    _areaController,
    _descricaoController,
    _prazoController,
  ].any((c) => c.text.trim().isNotEmpty);

  String? _obrigatorio(TextEditingController c, String rotulo) =>
      c.text.trim().isEmpty ? 'Preencha o campo "$rotulo".' : null;

  String? get _erroPrazo {
    final texto = _prazoController.text.trim();
    if (texto.isEmpty) return 'Informe a data em "Prazo".';
    final data = osLerData(texto);
    if (data == null) return 'Data inválida. Use o formato DD/MM/AAAA.';
    final agora = DateTime.now();
    if (data.isBefore(DateTime(agora.year, agora.month, agora.day))) {
      return 'O prazo não pode ser anterior a hoje.';
    }
    return null;
  }

  Map<String, String?> get _erros => {
    'titulo': _obrigatorio(_tituloController, 'Título'),
    'area': _obrigatorio(_areaController, 'Área / talhão'),
    'prazo': _erroPrazo,
    'descricao': _obrigatorio(_descricaoController, 'Descrição'),
  };

  String? _erro(String campo) => _tentou ? _erros[campo] : null;

  void _criar() {
    if (_erros.values.any((e) => e != null)) {
      setState(() => _tentou = true);
      return;
    }
    final id = ref
        .read(ordemServicoStoreProvider.notifier)
        .criar(
          titulo: _tituloController.text.trim(),
          tipo: TipoServicoOs.values.byName(_tipo),
          fazenda: ref.read(fazendasStoreProvider).activeFarm.name,
          areaOuTalhao: _areaController.text.trim(),
          prioridade: PrioridadeOs.values.byName(_prioridade),
          prazo: osLerData(_prazoController.text)!,
          descricao: _descricaoController.text.trim(),
          autor: autorAdministrativoOs,
        );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => OsDetailPage(osId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final faltando = _tentou ? _erros.values.where((e) => e != null).length : 0;

    return AppPageScaffold(
      title: 'Criar OS',
      onBack: () => Navigator.of(context).maybePop(),
      hasUnsavedChanges: _temDados,
      actionBar: AppActionBar(primaryLabel: 'Criar OS', onPrimary: _criar),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'A OS será criada na ${ref.watch(fazendasStoreProvider).activeFarm.name}, '
            'com status "Aguardando", até alguém da operação iniciar.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.space4),
          if (faltando > 0) ...[
            AppBanner(
              tone: AppBannerTone.error,
              icon: const AppIcon(AppIcons.alertCircle, size: AppSize.iconSm),
              child: Text(
                faltando == 1
                    ? 'Revise o campo destacado para criar a OS.'
                    : 'Revise os $faltando campos destacados para criar a OS.',
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
          AppFormField(
            label: 'Título',
            required: true,
            error: _erro('titulo'),
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
            error: _erro('area'),
            child: AppTextInput(
              controller: _areaController,
              placeholder: 'Ex.: Talhão 04',
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          AppFormField(
            label: 'Prioridade',
            required: true,
            hint: 'Alta aparece primeiro na fila da operação.',
            child: AppFormSelect(
              options: [
                for (final p in PrioridadeOs.values)
                  AppFormSelectOption(value: p.name, label: p.label),
              ],
              value: _prioridade,
              onChanged: (v) => setState(() => _prioridade = v ?? _prioridade),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          AppFormField(
            label: 'Prazo',
            required: true,
            hint: 'Data limite para a entrega do serviço.',
            error: _erro('prazo'),
            child: AppDateInput(controller: _prazoController),
          ),
          const SizedBox(height: AppSpacing.space3),
          AppFormField(
            label: 'Descrição',
            required: true,
            error: _erro('descricao'),
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
