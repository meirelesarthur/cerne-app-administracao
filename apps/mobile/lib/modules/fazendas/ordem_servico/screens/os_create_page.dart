import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design/generated/app_layout.dart';
import '../../../../design/generated/app_spacing.dart';
import '../../../../ui/ui.dart';
import '../../state/fazendas_store.dart';
import '../catalogos.dart';
import '../models.dart';
import '../state/ordem_servico_store.dart';
import '../widgets.dart';
import 'os_detail_page.dart';

const _etapasOs = [
  'Identificação',
  'Tipo de Serviço',
  'Execução',
  'Condições e Restrições',
  'Instruções Detalhadas',
  'Segurança e Sustentabilidade',
  'Recursos e Insumos',
];

String _formatarDataOs(DateTime data) =>
    '${data.day.toString().padLeft(2, '0')}/'
    '${data.month.toString().padLeft(2, '0')}/${data.year}';

num? _lerNumeroOs(String texto) =>
    num.tryParse(texto.trim().replaceAll(',', '.'));

String _formatarNumeroOs(num valor) => valor % 1 == 0
    ? valor.toStringAsFixed(0)
    : valor
          .toStringAsFixed(2)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '')
          .replaceAll('.', ',');

/// Abre o cadastro completo de OS em tela cheia. Cada bloco do formulário WEB
/// tem uma etapa própria; recursos e insumos usam os componentes públicos do
/// catálogo para manter o mesmo padrão de coleção em todo o ADM.
void abrirCriarOs(BuildContext context) {
  Navigator.of(
    context,
    rootNavigator: true,
  ).push<void>(MaterialPageRoute<void>(builder: (_) => const OsCreatePage()));
}

class OsCreatePage extends ConsumerStatefulWidget {
  const OsCreatePage({super.key});

  @override
  ConsumerState<OsCreatePage> createState() => _OsCreatePageState();
}

class _OsCreatePageState extends ConsumerState<OsCreatePage> {
  final _hoje = DateUtils.dateOnly(DateTime.now());
  late final _dataEmissao = TextEditingController(text: _formatarDataOs(_hoje));
  late final _dataExecucao = TextEditingController(
    text: _formatarDataOs(_hoje),
  );
  final _prazo = TextEditingController();
  final _requisitosClimaticos = TextEditingController();
  final _temperaturaMinima = TextEditingController();
  final _temperaturaMaxima = TextEditingController();
  final _horarioInicio = TextEditingController();
  final _horarioFim = TextEditingController();
  final _descricao = TextEditingController();
  final _resultadosEsperados = TextEditingController();
  final _criteriosSucesso = TextEditingController();
  final _roteiro = TextEditingController();
  final _restricoesAmbientais = TextEditingController();
  final _conformidadeLegal = TextEditingController();

  late final List<TextEditingController> _controllers = [
    _dataEmissao,
    _dataExecucao,
    _prazo,
    _requisitosClimaticos,
    _temperaturaMinima,
    _temperaturaMaxima,
    _horarioInicio,
    _horarioFim,
    _descricao,
    _resultadosEsperados,
    _criteriosSucesso,
    _roteiro,
    _restricoesAmbientais,
    _conformidadeLegal,
  ];

  var _etapa = 0;
  final _etapasTentadas = <int>{};
  UsoOs? _uso;
  String? _responsavel;
  String? _operacao;
  String? _atividade;
  String? _area;
  String? _culturaVariedade;
  String? _lote;
  String? _categoria;
  String? _armazemInsumos;
  String? _armazemProducao;

  final _maoDeObra = <MaoDeObraOs>[];
  final _maquinas = <MaquinaOs>[];
  final _insumos = <InsumoOs>[];
  final _producao = <ProducaoOs>[];
  final _epis = <EpiOs>[];

  bool get _temDados {
    final hoje = _formatarDataOs(_hoje);
    for (final controller in _controllers) {
      if (identical(controller, _dataEmissao) ||
          identical(controller, _dataExecucao)) {
        if (controller.text.trim() != hoje) return true;
      } else if (controller.text.trim().isNotEmpty) {
        return true;
      }
    }
    return _responsavel != null ||
        _uso != null ||
        _operacao != null ||
        _atividade != null ||
        _area != null ||
        _culturaVariedade != null ||
        _lote != null ||
        _categoria != null ||
        _maoDeObra.isNotEmpty ||
        _maquinas.isNotEmpty ||
        _insumos.isNotEmpty ||
        _producao.isNotEmpty ||
        _epis.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_redesenhar);
    }
  }

  void _redesenhar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller
        ..removeListener(_redesenhar)
        ..dispose();
    }
    super.dispose();
  }

  String? _obrigatorio(String? valor, String rotulo) =>
      valor == null || valor.trim().isEmpty
      ? 'Preencha o campo "$rotulo".'
      : null;

  String? _erroData(TextEditingController controller, String rotulo) {
    final texto = controller.text.trim();
    if (texto.isEmpty) return 'Informe a data em "$rotulo".';
    if (osLerData(texto) == null) {
      return 'Data inválida. Use o formato DD/MM/AAAA.';
    }
    return null;
  }

  DateTime? get _dataEmissaoValor => osLerData(_dataEmissao.text);
  DateTime? get _dataExecucaoValor => osLerData(_dataExecucao.text);
  DateTime? get _prazoValor => osLerData(_prazo.text);

  Map<String, String?> _errosDaEtapa(int etapa) {
    switch (etapa) {
      case 0:
        final emissao = _erroData(_dataEmissao, 'Data de emissão');
        final execucao = _erroData(_dataExecucao, 'Data de execução');
        final prazo = _erroData(_prazo, 'Prazo');
        final dataEmissao = _dataEmissaoValor;
        final dataExecucao = _dataExecucaoValor;
        final dataPrazo = _prazoValor;
        return {
          'responsavel': _obrigatorio(_responsavel, 'Responsável'),
          'emissao': emissao,
          'execucao':
              execucao ??
              (dataEmissao != null &&
                      dataExecucao != null &&
                      dataExecucao.isBefore(dataEmissao)
                  ? 'A execução não pode começar antes da emissão.'
                  : null),
          'prazo':
              prazo ??
              (dataPrazo != null && dataPrazo.isBefore(_hoje)
                  ? 'O prazo não pode ser anterior a hoje.'
                  : (dataPrazo != null &&
                            dataExecucao != null &&
                            dataPrazo.isBefore(dataExecucao)
                        ? 'O prazo deve ser igual ou posterior à execução.'
                        : null)),
        };
      case 1:
        return {
          'uso': _uso == null ? 'Selecione o uso da ordem de serviço.' : null,
          'operacao': _obrigatorio(_operacao, 'Operação'),
          'atividade': _obrigatorio(_atividade, 'Atividade'),
        };
      case 2:
        return {
          'area': _obrigatorio(_area, 'Área'),
          if (_uso?.usaCultura ?? false)
            'cultura': _obrigatorio(_culturaVariedade, 'Cultura / variedade'),
          if (_uso?.usaLote ?? false) ...{
            'lote': _obrigatorio(_lote, 'Lote'),
            'categoria': _obrigatorio(_categoria, 'Categoria zootécnica'),
          },
        };
      case 3:
        final minimo = _lerNumeroOs(_temperaturaMinima.text);
        final maximo = _lerNumeroOs(_temperaturaMaxima.text);
        return {
          'clima': _obrigatorio(
            _requisitosClimaticos.text,
            'Requisitos climáticos',
          ),
          'temperaturaMinima': _numeroObrigatorio(
            _temperaturaMinima.text,
            'Temperatura mínima',
          ),
          'temperaturaMaxima':
              _numeroObrigatorio(
                _temperaturaMaxima.text,
                'Temperatura máxima',
              ) ??
              (minimo != null && maximo != null && maximo < minimo
                  ? 'A máxima deve ser igual ou maior que a mínima.'
                  : null),
          'horarioInicio': _erroHorario(_horarioInicio.text, 'Horário inicial'),
          'horarioFim': _erroHorario(_horarioFim.text, 'Horário final'),
        };
      case 4:
        return {
          'descricao': _obrigatorio(_descricao.text, 'Descrição do serviço'),
          'resultados': _obrigatorio(
            _resultadosEsperados.text,
            'Resultados esperados',
          ),
          'criterios': _obrigatorio(
            _criteriosSucesso.text,
            'Critérios de sucesso',
          ),
          'roteiro': _obrigatorio(_roteiro.text, 'Roteiro / planejamento'),
        };
      case 5:
        return {
          'ambiental': _obrigatorio(
            _restricoesAmbientais.text,
            'Restrições ambientais',
          ),
          'legal': _obrigatorio(_conformidadeLegal.text, 'Conformidade legal'),
        };
      case 6:
        return {
          'maoDeObra': _maoDeObra.isEmpty
              ? 'Inclua pelo menos um item de MO / Serviços.'
              : null,
          'maquinas': _maquinas.isEmpty
              ? 'Inclua pelo menos uma máquina ou implemento.'
              : null,
          'insumos': _insumos.isEmpty || _armazemInsumos == null
              ? 'Inclua pelo menos um insumo com armazém definido.'
              : null,
          'epis': _epis.isEmpty ? 'Inclua pelo menos um EPI.' : null,
        };
      default:
        return const {};
    }
  }

  String? _numeroObrigatorio(String texto, String rotulo) {
    final valor = _lerNumeroOs(texto);
    if (texto.trim().isEmpty) return 'Informe "$rotulo".';
    if (valor == null) return 'Informe um número válido em "$rotulo".';
    return null;
  }

  String? _erroHorario(String texto, String rotulo) {
    if (texto.trim().isEmpty) return 'Informe "$rotulo".';
    if (!RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$').hasMatch(texto.trim())) {
      return 'Use o formato HH:MM.';
    }
    return null;
  }

  String? _erro(String campo) =>
      _etapasTentadas.contains(_etapa) ? _errosDaEtapa(_etapa)[campo] : null;

  int get _quantidadeErros => _etapasTentadas.contains(_etapa)
      ? _errosDaEtapa(_etapa).values.where((erro) => erro != null).length
      : 0;

  bool _validarEtapaAtual() {
    final erros = _errosDaEtapa(_etapa);
    if (erros.values.any((erro) => erro != null)) {
      setState(() => _etapasTentadas.add(_etapa));
      return false;
    }
    return true;
  }

  void _avancar() {
    if (!_validarEtapaAtual()) return;
    setState(() {
      _etapasTentadas.add(_etapa);
      _etapa++;
    });
  }

  void _voltarEtapa() => setState(() => _etapa--);

  void _escolherUso(String? nome) {
    if (nome == null) return;
    final uso = UsoOs.values.byName(nome);
    if (_uso == uso) return;
    setState(() {
      _uso = uso;
      _operacao = null;
      _atividade = null;
      if (!uso.usaCultura) _culturaVariedade = null;
      if (!uso.usaLote) {
        _lote = null;
        _categoria = null;
      }
    });
  }

  void _escolherLote(String lote) {
    setState(() {
      _lote = lote;
      final cadastrado = loteOsPorNome(lote);
      final categorias =
          categoriasPorEspecieOs[cadastrado?.especie] ?? const [];
      _categoria = categorias.contains(cadastrado?.categoria)
          ? cadastrado!.categoria
          : null;
    });
  }

  void _criar() {
    if (!_validarEtapaAtual()) return;
    final dataEmissao = _dataEmissaoValor!;
    final dataExecucao = _dataExecucaoValor!;
    final prazo = _prazoValor!;
    final id = ref
        .read(ordemServicoStoreProvider.notifier)
        .criar(
          fazenda: ref.read(fazendasStoreProvider).activeFarm.name,
          responsavelExecucao: _responsavel!,
          dataEmissao: dataEmissao,
          dataExecucao: dataExecucao,
          prazo: prazo,
          uso: _uso!,
          operacao: _operacao!,
          atividade: _atividade!,
          area: _area!,
          culturaVariedade: _uso!.usaCultura ? _culturaVariedade : null,
          lote: _uso!.usaLote ? _lote : null,
          categoria: _uso!.usaLote ? _categoria : null,
          condicoes: CondicoesOs(
            requisitosClimaticos: _requisitosClimaticos.text.trim(),
            temperaturaMinima: _lerNumeroOs(_temperaturaMinima.text)!,
            temperaturaMaxima: _lerNumeroOs(_temperaturaMaxima.text)!,
            horarioInicio: _horarioInicio.text.trim(),
            horarioFim: _horarioFim.text.trim(),
          ),
          descricao: _descricao.text.trim(),
          instrucoes: InstrucoesOs(
            resultadosEsperados: _resultadosEsperados.text.trim(),
            criteriosSucesso: _criteriosSucesso.text.trim(),
            roteiro: _roteiro.text.trim(),
          ),
          seguranca: SegurancaOs(
            restricoesAmbientais: _restricoesAmbientais.text.trim(),
            conformidadeLegal: _conformidadeLegal.text.trim(),
          ),
          maoDeObra: _maoDeObra,
          maquinas: _maquinas,
          armazemInsumos: _armazemInsumos!,
          insumos: _insumos,
          armazemProducao: _armazemProducao,
          producao: _producao,
          epis: _epis,
          autor: autorAdministrativoOs,
        );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => OsDetailPage(osId: id)),
    );
  }

  List<AppSearchSelectOption> _opcoes(List<String> valores) => [
    for (final valor in valores)
      AppSearchSelectOption(value: valor, label: valor),
  ];

  Widget _campoTexto(
    String chave,
    String rotulo,
    TextEditingController controller, {
    String? placeholder,
    bool obrigatorio = true,
    TextInputType? teclado,
    bool multiline = false,
    String? hint,
  }) {
    final erro = _erro(chave);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
      child: AppFormField(
        label: rotulo,
        required: obrigatorio,
        hint: hint,
        error: erro,
        child: multiline
            ? AppTextarea(
                controller: controller,
                placeholder: placeholder,
                minLines: 3,
                maxLines: 6,
                invalid: erro != null,
              )
            : AppTextInput(
                controller: controller,
                placeholder: placeholder,
                keyboardType: teclado,
                invalid: erro != null,
              ),
      ),
    );
  }

  Widget _campoData(String chave, String rotulo, TextEditingController c) {
    final erro = _erro(chave);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
      child: AppFormField(
        label: rotulo,
        required: true,
        error: erro,
        child: AppDateInput(
          controller: c,
          invalid: erro != null,
          firstDate: identical(c, _prazo) ? _hoje : DateTime(1900),
          lastDate: DateTime(_hoje.year + 20),
        ),
      ),
    );
  }

  Widget _campoBusca(
    String chave,
    String rotulo,
    String? value,
    List<AppSearchSelectOption> options,
    ValueChanged<String> onChanged, {
    bool enabled = true,
    bool obrigatorio = true,
    String? placeholder,
    String? hint,
  }) {
    final erro = _erro(chave);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
      child: AppFormField(
        label: rotulo,
        required: obrigatorio,
        hint: hint,
        error: erro,
        child: AppSearchSelect(
          options: options,
          value: value,
          enabled: enabled,
          invalid: erro != null,
          onChanged: onChanged,
          label: rotulo,
          placeholder: placeholder ?? 'Selecionar $rotulo',
        ),
      ),
    );
  }

  Widget _somenteLeitura(String rotulo, String valor) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.space3),
    child: AppFormField(
      label: rotulo,
      child: AppTextInput(initialValue: valor, enabled: false),
    ),
  );

  Widget _tituloEtapa(String descricao) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.space4),
    child: Text(descricao, style: Theme.of(context).textTheme.bodyMedium),
  );

  Widget _etapaIdentificacao() {
    final fazenda = ref.watch(fazendasStoreProvider).activeFarm.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _tituloEtapa(
          'Informe quem acompanha o serviço e quando ele será executado na fazenda.',
        ),
        _somenteLeitura('Fazenda', fazenda),
        _somenteLeitura('Solicitante', autorAdministrativoOs),
        _somenteLeitura('Código', 'Gerado ao criar a OS'),
        _campoBusca(
          'responsavel',
          'Responsável pela execução',
          _responsavel,
          [
            for (final pessoa in responsaveisOs)
              AppSearchSelectOption(
                value: pessoa.nome,
                label: pessoa.nome,
                detail: pessoa.funcao,
              ),
          ],
          (valor) => setState(() => _responsavel = valor),
        ),
        _campoData('emissao', 'Data de emissão', _dataEmissao),
        _campoData('execucao', 'Data de execução', _dataExecucao),
        _campoData('prazo', 'Prazo final', _prazo),
      ],
    );
  }

  Widget _etapaTipoServico() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _tituloEtapa('As opções seguintes dependem do uso selecionado.'),
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.space3),
        child: AppFormField(
          label: 'Uso',
          required: true,
          error: _erro('uso'),
          child: AppFormSelect(
            options: [
              for (final uso in UsoOs.values)
                AppFormSelectOption(value: uso.name, label: uso.label),
            ],
            value: _uso?.name,
            placeholder: 'Selecione o uso',
            invalid: _erro('uso') != null,
            onChanged: _escolherUso,
          ),
        ),
      ),
      _campoBusca(
        'operacao',
        'Operação',
        _operacao,
        _opcoes(operacoesPorUso[_uso] ?? const []),
        (valor) => setState(() {
          _operacao = valor;
          _atividade = null;
        }),
        enabled: _uso != null,
        placeholder: _uso == null
            ? 'Escolha o uso primeiro'
            : 'Selecionar operação',
      ),
      _campoBusca(
        'atividade',
        'Atividade',
        _atividade,
        _opcoes(atividadesParaOperacao(_operacao)),
        (valor) => setState(() => _atividade = valor),
        enabled: _operacao != null,
        placeholder: _operacao == null
            ? 'Escolha a operação primeiro'
            : 'Selecionar atividade',
      ),
    ],
  );

  Widget _etapaExecucao() {
    final categorias = _lote == null
        ? [
            for (final item in categoriasZootecnicasOs)
              AppSearchSelectOption(value: item.categoria, label: item.rotulo),
          ]
        : [
            for (final categoria
                in categoriasPorEspecieOs[loteOsPorNome(_lote)?.especie] ??
                    const <String>[])
              AppSearchSelectOption(
                value: categoria,
                label: '${loteOsPorNome(_lote)?.especie} — $categoria',
              ),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _tituloEtapa(
          'Defina onde o serviço acontece e os cadastros ligados ao uso.',
        ),
        _campoBusca('area', 'Área / talhão', _area, [
          for (final area in areasOs)
            AppSearchSelectOption(
              value: area.nome,
              label: area.nome,
              detail: '${_formatarNumeroOs(area.hectares)} ha',
            ),
        ], (valor) => setState(() => _area = valor)),
        if (_uso?.usaCultura ?? false)
          _campoBusca(
            'cultura',
            'Cultura / variedade',
            _culturaVariedade,
            _opcoes([for (final item in culturasVariedadesOs) item.rotulo]),
            (valor) => setState(() => _culturaVariedade = valor),
          )
        else
          _campoBusca(
            'cultura',
            'Cultura / variedade',
            null,
            const [],
            (_) {},
            enabled: false,
            obrigatorio: false,
            placeholder: 'Não se aplica ao uso selecionado',
          ),
        if (_uso?.usaLote ?? false) ...[
          _campoBusca('lote', 'Lote', _lote, [
            for (final lote in lotesOs)
              AppSearchSelectOption(
                value: lote.nome,
                label: lote.nome,
                detail: '${lote.especie} · ${lote.quantidade} animais',
              ),
          ], _escolherLote),
          _campoBusca(
            'categoria',
            'Categoria zootécnica',
            _categoria,
            categorias,
            (valor) => setState(() => _categoria = valor),
            enabled: _lote != null,
            placeholder: _lote == null
                ? 'Escolha o lote primeiro'
                : 'Selecionar categoria',
          ),
        ] else ...[
          _campoBusca(
            'lote',
            'Lote',
            null,
            const [],
            (_) {},
            enabled: false,
            obrigatorio: false,
            placeholder: 'Não se aplica ao uso selecionado',
          ),
          _campoBusca(
            'categoria',
            'Categoria zootécnica',
            null,
            const [],
            (_) {},
            enabled: false,
            obrigatorio: false,
            placeholder: 'Não se aplica ao uso selecionado',
          ),
        ],
      ],
    );
  }

  Widget _etapaCondicoes() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _tituloEtapa(
        'Registre as condições permitidas para a execução do serviço.',
      ),
      _campoTexto(
        'clima',
        'Requisitos climáticos',
        _requisitosClimaticos,
        placeholder: 'Ex.: Não aplicar com vento acima de 10 km/h',
        multiline: true,
      ),
      _campoTexto(
        'temperaturaMinima',
        'Temperatura mínima (°C)',
        _temperaturaMinima,
        placeholder: 'Ex.: 18',
        teclado: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
      ),
      _campoTexto(
        'temperaturaMaxima',
        'Temperatura máxima (°C)',
        _temperaturaMaxima,
        placeholder: 'Ex.: 30',
        teclado: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
      ),
      _campoTexto(
        'horarioInicio',
        'Horário permitido — início',
        _horarioInicio,
        placeholder: 'HH:MM',
        teclado: TextInputType.datetime,
      ),
      _campoTexto(
        'horarioFim',
        'Horário permitido — fim',
        _horarioFim,
        placeholder: 'HH:MM',
        teclado: TextInputType.datetime,
      ),
    ],
  );

  Widget _etapaInstrucoes() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _tituloEtapa('Descreva o serviço e deixe claro o resultado esperado.'),
      _campoTexto(
        'descricao',
        'Descrição do serviço',
        _descricao,
        placeholder: 'Detalhe o que precisa ser feito...',
        multiline: true,
      ),
      _campoTexto(
        'resultados',
        'Resultados esperados',
        _resultadosEsperados,
        placeholder: 'O que deve estar concluído ao final?',
        multiline: true,
      ),
      _campoTexto(
        'criterios',
        'Critérios de sucesso',
        _criteriosSucesso,
        placeholder: 'Como a equipe confirma que o serviço foi bem executado?',
        multiline: true,
      ),
      _campoTexto(
        'roteiro',
        'Roteiro / planejamento',
        _roteiro,
        placeholder: 'Informe as etapas ou a sequência de execução.',
        multiline: true,
      ),
    ],
  );

  Widget _etapaSeguranca() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _tituloEtapa('Informe os cuidados ambientais e as exigências legais.'),
      _campoTexto(
        'ambiental',
        'Restrições ambientais',
        _restricoesAmbientais,
        placeholder: 'Áreas de preservação, clima ou descarte...',
        multiline: true,
      ),
      _campoTexto(
        'legal',
        'Conformidade legal',
        _conformidadeLegal,
        placeholder: 'Licenças, normas ou registros necessários...',
        multiline: true,
      ),
    ],
  );

  Widget _etapaRecursos() {
    final groups = [
      AppSquareGroup(
        name: _OsItemKind.maoDeObra.label,
        icon: AppIcons.users,
        count: _maoDeObra.length,
      ),
      AppSquareGroup(
        name: _OsItemKind.maquinas.label,
        icon: AppIcons.tractor,
        count: _maquinas.length,
      ),
      AppSquareGroup(
        name: _OsItemKind.insumos.label,
        icon: AppIcons.package,
        count: _insumos.length,
      ),
      AppSquareGroup(
        name: _OsItemKind.producao.label,
        icon: AppIcons.wheat,
        count: _producao.length,
      ),
      AppSquareGroup(
        name: _OsItemKind.epis.label,
        icon: AppIcons.shieldCheck,
        count: _epis.length,
        wide: true,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _tituloEtapa(
          'Inclua os recursos e insumos exigidos. Produção é opcional; os demais grupos precisam de ao menos um item.',
        ),
        if (_quantidadeErros > 0) ...[
          AppBanner(
            tone: AppBannerTone.error,
            icon: const AppIcon(AppIcons.alertCircle, size: AppSize.iconSm),
            child: Text(
              _quantidadeErros == 1
                  ? 'Revise o grupo destacado para criar a OS.'
                  : 'Revise os $_quantidadeErros grupos destacados para criar a OS.',
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
        ],
        _erroGrupo('maoDeObra'),
        _erroGrupo('maquinas'),
        _erroGrupo('insumos'),
        _erroGrupo('epis'),
        AppSquareGroupGrid(
          groups: groups,
          onAdd: _adicionarPeloCard,
          onOpen: (grupo) => unawaited(_abrirGerenciador(context, grupo)),
        ),
      ],
    );
  }

  Widget _erroGrupo(String campo) {
    final erro = _erro(campo);
    if (erro == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: Text(erro, style: Theme.of(context).textTheme.bodySmall),
    );
  }

  Widget _conteudoEtapa() => switch (_etapa) {
    0 => _etapaIdentificacao(),
    1 => _etapaTipoServico(),
    2 => _etapaExecucao(),
    3 => _etapaCondicoes(),
    4 => _etapaInstrucoes(),
    5 => _etapaSeguranca(),
    _ => _etapaRecursos(),
  };

  List<Object> _itensDoGrupo(String grupo) =>
      switch (_OsItemKind.fromLabel(grupo)) {
        _OsItemKind.maoDeObra => _maoDeObra,
        _OsItemKind.maquinas => _maquinas,
        _OsItemKind.insumos => _insumos,
        _OsItemKind.producao => _producao,
        _OsItemKind.epis => _epis,
      };

  List<AppCollectionItemView> _visualizacoesDoGrupo(String grupo) {
    return switch (_OsItemKind.fromLabel(grupo)) {
      _OsItemKind.maoDeObra => [
        for (final item in _maoDeObra)
          AppCollectionItemView(
            title: item.executor,
            subtitle: [item.tipo.label, ?item.funcao].join(' · '),
          ),
      ],
      _OsItemKind.maquinas => [
        for (final item in _maquinas)
          AppCollectionItemView(
            title: item.equipamento,
            subtitle: [
              equipamentoOsPorNome(item.equipamento)?.tipo,
              equipamentoOsPorNome(item.equipamento)?.unidadeUso,
              item.observacao,
            ].whereType<String>().join(' · '),
          ),
      ],
      _OsItemKind.insumos => [
        for (final item in _insumos)
          AppCollectionItemView(
            title: item.produto,
            subtitle:
                '${_formatarNumeroOs(item.quantidadeTotal)} ${item.unidadeMedida} · ${_formatarNumeroOs(item.quantidadePorHa)} ${item.unidadeMedida}/ha · saldo ${_formatarNumeroOs(item.estoque)}',
          ),
      ],
      _OsItemKind.producao => [
        for (final item in _producao)
          AppCollectionItemView(
            title: item.produto,
            subtitle: [
              '${_formatarNumeroOs(item.quantidade)} ${item.unidadeMedida}',
              ?item.observacao,
            ].join(' · '),
          ),
      ],
      _OsItemKind.epis => [
        for (final item in _epis)
          AppCollectionItemView(title: item.produto, subtitle: item.observacao),
      ],
    };
  }

  Future<void> _abrirGerenciador(BuildContext context, String grupo) =>
      showAppCollectionManager(
        context,
        title: grupo,
        items: () => _visualizacoesDoGrupo(grupo),
        onAdd: () => _adicionarItem(grupo),
        onEdit: (indice) => _editarItem(grupo, indice),
        onRemove: (indice) => _removerItem(grupo, indice),
      );

  void _adicionarPeloCard(String grupo) => unawaited(_adicionarItem(grupo));

  Future<void> _adicionarItem(String grupo) async {
    final draft = await _abrirEditor(grupo);
    if (draft == null || !mounted) return;
    setState(() {
      _atualizarArmazens(draft);
      _itensDoGrupo(grupo).add(draft.item);
    });
  }

  Future<void> _editarItem(String grupo, int indice) async {
    final atual = _itensDoGrupo(grupo)[indice];
    final draft = await _abrirEditor(grupo, original: atual);
    if (draft == null || !mounted) return;
    setState(() {
      _atualizarArmazens(draft);
      _itensDoGrupo(grupo)[indice] = draft.item;
    });
  }

  void _atualizarArmazens(_OsResourceDraft draft) {
    if (draft.armazemInsumos case final armazem?) {
      _armazemInsumos = armazem;
    }
    if (draft.armazemProducao case final armazem?) {
      _armazemProducao = armazem;
    }
  }

  VoidCallback _removerItem(String grupo, int indice) {
    final lista = _itensDoGrupo(grupo);
    final removido = lista.removeAt(indice);
    setState(() {});
    return () {
      if (!mounted) return;
      setState(() => lista.insert(indice, removido));
    };
  }

  Future<_OsResourceDraft?> _abrirEditor(String grupo, {Object? original}) {
    final kind = _OsItemKind.fromLabel(grupo);
    final key = GlobalKey<_OsResourceEditorSheetState>();
    return showAppBottomSheet<_OsResourceDraft>(
      context,
      title: '${original == null ? 'Adicionar' : 'Editar'} ${kind.titulo}',
      maxHeightFraction: 0.9,
      child: _OsResourceEditorSheet(
        key: key,
        kind: kind,
        original: original,
        armazemInsumos: _armazemInsumos,
        armazemProducao: _armazemProducao,
        armazemInsumosBloqueado: _insumos.isNotEmpty,
        armazemProducaoBloqueado: _producao.isNotEmpty,
      ),
      footer: AppButton(
        onPressed: () => key.currentState?._salvar(),
        child: const Text('Salvar item'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final faltando = _quantidadeErros;
    final farm = ref.watch(fazendasStoreProvider).activeFarm.name;
    return AppPageScaffold(
      title: 'Criar OS',
      onBack: () => Navigator.of(context).maybePop(),
      totalSteps: _etapasOs.length,
      currentStep: _etapa + 1,
      stepLabel: _etapasOs[_etapa],
      hasUnsavedChanges: _temDados,
      actionBar: AppActionBar(
        primaryLabel: _etapa == _etapasOs.length - 1 ? 'Criar OS' : 'Continuar',
        onPrimary: _etapa == _etapasOs.length - 1 ? _criar : _avancar,
        alternativeLabel: _etapa > 0 ? 'Etapa anterior' : null,
        onAlternative: _etapa > 0 ? _voltarEtapa : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_etapa == 0) ...[
            Text(
              'A OS será criada na $farm, com status "Aguardando", até a equipe iniciar o serviço.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
          if (faltando > 0) ...[
            AppBanner(
              tone: AppBannerTone.error,
              icon: const AppIcon(AppIcons.alertCircle, size: AppSize.iconSm),
              child: Text(
                faltando == 1
                    ? 'Revise o campo destacado para continuar.'
                    : 'Revise os $faltando campos destacados para continuar.',
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
          _conteudoEtapa(),
          const SizedBox(height: AppSpacing.space6),
        ],
      ),
    );
  }
}

enum _OsItemKind {
  maoDeObra('MO / Serviços', 'mão de obra'),
  maquinas('Máq. / Implementos', 'máquina ou implemento'),
  insumos('Insumos', 'insumo'),
  producao('Produção', 'produto de produção'),
  epis('EPI', 'EPI');

  const _OsItemKind(this.label, this.titulo);

  final String label;
  final String titulo;

  static _OsItemKind fromLabel(String label) => values.firstWhere(
    (kind) => kind.label == label,
    orElse: () =>
        throw ArgumentError.value(label, 'label', 'Grupo desconhecido'),
  );
}

class _OsResourceDraft {
  const _OsResourceDraft({
    required this.item,
    this.armazemInsumos,
    this.armazemProducao,
  });

  final Object item;
  final String? armazemInsumos;
  final String? armazemProducao;
}

class _OsResourceEditorSheet extends StatefulWidget {
  const _OsResourceEditorSheet({
    super.key,
    required this.kind,
    required this.original,
    required this.armazemInsumos,
    required this.armazemProducao,
    required this.armazemInsumosBloqueado,
    required this.armazemProducaoBloqueado,
  });

  final _OsItemKind kind;
  final Object? original;
  final String? armazemInsumos;
  final String? armazemProducao;
  final bool armazemInsumosBloqueado;
  final bool armazemProducaoBloqueado;

  @override
  State<_OsResourceEditorSheet> createState() => _OsResourceEditorSheetState();
}

class _OsResourceEditorSheetState extends State<_OsResourceEditorSheet> {
  TipoMaoDeObraOs? _tipoMaoDeObra;
  String? _executor;
  String? _equipamento;
  String? _armazemInsumos;
  String? _produtoInsumo;
  String? _armazemProducao;
  String? _produtoProducao;
  String? _epi;
  final _observacao = TextEditingController();
  final _quantidadePorHa = TextEditingController();
  final _quantidadeTotal = TextEditingController();
  final _quantidadeProducao = TextEditingController();
  var _tentouSalvar = false;

  @override
  void initState() {
    super.initState();
    switch (widget.kind) {
      case _OsItemKind.maoDeObra:
        final item = widget.original;
        if (item is MaoDeObraOs) {
          _tipoMaoDeObra = item.tipo;
          _executor = item.executor;
        }
        break;
      case _OsItemKind.maquinas:
        final item = widget.original;
        if (item is MaquinaOs) {
          _equipamento = item.equipamento;
          _observacao.text = item.observacao ?? '';
        }
        break;
      case _OsItemKind.insumos:
        final item = widget.original;
        _armazemInsumos = widget.armazemInsumos;
        if (item is InsumoOs) {
          _produtoInsumo = item.produto;
          _quantidadePorHa.text = _formatarNumeroOs(item.quantidadePorHa);
          _quantidadeTotal.text = _formatarNumeroOs(item.quantidadeTotal);
        }
        break;
      case _OsItemKind.producao:
        final item = widget.original;
        _armazemProducao = widget.armazemProducao;
        if (item is ProducaoOs) {
          _produtoProducao = item.produto;
          _quantidadeProducao.text = _formatarNumeroOs(item.quantidade);
          _observacao.text = item.observacao ?? '';
        }
        break;
      case _OsItemKind.epis:
        final item = widget.original;
        if (item is EpiOs) {
          _epi = item.produto;
          _observacao.text = item.observacao ?? '';
        }
        break;
    }
  }

  @override
  void dispose() {
    _observacao.dispose();
    _quantidadePorHa.dispose();
    _quantidadeTotal.dispose();
    _quantidadeProducao.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? 'Selecione $label.' : null;

  String? _quantity(TextEditingController controller, String label) {
    final value = _lerNumeroOs(controller.text);
    if (controller.text.trim().isEmpty) return 'Informe $label.';
    if (value == null || value <= 0) return 'Informe um valor maior que zero.';
    return null;
  }

  Map<String, String?> get _erros {
    switch (widget.kind) {
      case _OsItemKind.maoDeObra:
        return {
          'tipo': _required(_tipoMaoDeObra?.name, 'o tipo de executor'),
          'executor': _required(_executor, 'um executor'),
        };
      case _OsItemKind.maquinas:
        return {'equipamento': _required(_equipamento, 'um equipamento')};
      case _OsItemKind.insumos:
        final item = produtoEstoqueOs(_armazemInsumos, _produtoInsumo);
        return {
          'armazem': _required(_armazemInsumos, 'um armazém'),
          'produto': item == null || item.saldo <= 0
              ? 'Selecione um produto com saldo nesse armazém.'
              : null,
          'dose': _quantity(_quantidadePorHa, 'a quantidade por hectare'),
          'total':
              _quantity(_quantidadeTotal, 'a quantidade total') ??
              (item != null &&
                      (_lerNumeroOs(_quantidadeTotal.text) ?? 0) > item.saldo
                  ? 'A quantidade total supera o saldo disponível.'
                  : null),
        };
      case _OsItemKind.producao:
        return {
          'armazem': _required(_armazemProducao, 'um armazém de produção'),
          'produto': _required(_produtoProducao, 'um produto'),
          'quantidade': _quantity(_quantidadeProducao, 'a quantidade'),
        };
      case _OsItemKind.epis:
        return {'epi': _required(_epi, 'um EPI')};
    }
  }

  String? _erro(String campo) => _tentouSalvar ? _erros[campo] : null;

  void _salvar() {
    final erros = _erros;
    if (erros.values.any((erro) => erro != null)) {
      setState(() => _tentouSalvar = true);
      return;
    }
    final draft = switch (widget.kind) {
      _OsItemKind.maoDeObra => _OsResourceDraft(
        item: MaoDeObraOs(
          tipo: _tipoMaoDeObra!,
          executor: _executor!,
          funcao: executorMaoDeObraOsPorNome(_tipoMaoDeObra, _executor)?.funcao,
        ),
      ),
      _OsItemKind.maquinas => _OsResourceDraft(
        item: MaquinaOs(
          equipamento: _equipamento!,
          observacao: _observacao.text.trim().isEmpty
              ? null
              : _observacao.text.trim(),
        ),
      ),
      _OsItemKind.insumos => _OsResourceDraft(
        item: InsumoOs(
          produto: _produtoInsumo!,
          unidadeMedida: produtoEstoqueOs(
            _armazemInsumos,
            _produtoInsumo,
          )!.unidade,
          estoque: produtoEstoqueOs(_armazemInsumos, _produtoInsumo)!.saldo,
          quantidadePorHa: _lerNumeroOs(_quantidadePorHa.text)!,
          quantidadeTotal: _lerNumeroOs(_quantidadeTotal.text)!,
        ),
        armazemInsumos: _armazemInsumos,
      ),
      _OsItemKind.producao => _OsResourceDraft(
        item: ProducaoOs(
          produto: _produtoProducao!,
          unidadeMedida: produtosProducaoOs
              .firstWhere((produto) => produto.produto == _produtoProducao)
              .unidade,
          quantidade: _lerNumeroOs(_quantidadeProducao.text)!,
          observacao: _observacao.text.trim().isEmpty
              ? null
              : _observacao.text.trim(),
        ),
        armazemProducao: _armazemProducao,
      ),
      _OsItemKind.epis => _OsResourceDraft(
        item: EpiOs(
          produto: _epi!,
          observacao: _observacao.text.trim().isEmpty
              ? null
              : _observacao.text.trim(),
        ),
      ),
    };
    Navigator.of(context).pop(draft);
  }

  Widget _campoBusca(
    String chave,
    String label,
    String? value,
    List<AppSearchSelectOption> options,
    ValueChanged<String> onChanged, {
    bool enabled = true,
    bool mandatory = true,
    String? placeholder,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.space3),
    child: AppFormField(
      label: label,
      required: mandatory,
      error: _erro(chave),
      child: AppSearchSelect(
        options: options,
        value: value,
        enabled: enabled,
        invalid: _erro(chave) != null,
        onChanged: onChanged,
        label: label,
        placeholder: placeholder ?? 'Selecionar $label',
      ),
    ),
  );

  Widget _campoSelectTipo() => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.space3),
    child: AppFormField(
      label: 'Tipo',
      required: true,
      error: _erro('tipo'),
      child: AppFormSelect(
        options: [
          for (final tipo in TipoMaoDeObraOs.values)
            AppFormSelectOption(value: tipo.name, label: tipo.label),
        ],
        value: _tipoMaoDeObra?.name,
        placeholder: 'Selecione o tipo',
        invalid: _erro('tipo') != null,
        onChanged: (value) => setState(() {
          _tipoMaoDeObra = value == null
              ? null
              : TipoMaoDeObraOs.values.byName(value);
          _executor = null;
        }),
      ),
    ),
  );

  Widget _campoTexto(
    String label,
    TextEditingController controller, {
    String? error,
    String? placeholder,
    bool mandatory = false,
    TextInputType? keyboardType,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.space3),
    child: AppFormField(
      label: label,
      required: mandatory,
      error: error,
      child: AppTextInput(
        controller: controller,
        placeholder: placeholder,
        keyboardType: keyboardType,
        invalid: error != null,
      ),
    ),
  );

  Widget _campoSomenteLeitura(String label, String? value) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.space3),
    child: AppFormField(
      label: label,
      child: AppTextInput(
        initialValue: value ?? 'Selecione um produto',
        enabled: false,
      ),
    ),
  );

  Widget _formularioMaoDeObra() {
    final executores = executoresPorTipoMaoDeObraOs(_tipoMaoDeObra);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _campoSelectTipo(),
        _campoBusca(
          'executor',
          'Executor',
          _executor,
          [
            for (final executor in executores)
              AppSearchSelectOption(
                value: executor.nome,
                label: executor.nome,
                detail: [
                  ?executor.funcao,
                  if (executor.custoHora case final custo?)
                    'R\$ ${_formatarNumeroOs(custo)}/h',
                ].join(' · '),
              ),
          ],
          (valor) => setState(() => _executor = valor),
          enabled: _tipoMaoDeObra != null,
          placeholder: _tipoMaoDeObra == null
              ? 'Escolha o tipo primeiro'
              : 'Selecionar executor',
        ),
      ],
    );
  }

  Widget _formularioMaquina() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _campoBusca(
        'equipamento',
        'Máquina / implemento / veículo',
        _equipamento,
        [
          for (final equipamento in equipamentosOs)
            AppSearchSelectOption(
              value: equipamento.nome,
              label: equipamento.nome,
              detail: '${equipamento.tipo} · uso em ${equipamento.unidadeUso}',
            ),
        ],
        (valor) => setState(() => _equipamento = valor),
      ),
      _campoTexto('Observação', _observacao, placeholder: 'Opcional'),
    ],
  );

  Widget _formularioInsumo() {
    final estoque = produtoEstoqueOs(_armazemInsumos, _produtoInsumo);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _campoBusca(
          'armazem',
          'Armazém',
          _armazemInsumos,
          [
            for (final nome in armazensInsumosOs)
              AppSearchSelectOption(value: nome, label: nome),
          ],
          (valor) => setState(() {
            _armazemInsumos = valor;
            _produtoInsumo = null;
          }),
          enabled: !widget.armazemInsumosBloqueado,
          placeholder: widget.armazemInsumosBloqueado
              ? _armazemInsumos ?? 'Armazém da coleção'
              : 'Selecionar armazém',
        ),
        _campoBusca(
          'produto',
          'Produto com saldo',
          _produtoInsumo,
          [
            for (final item in produtosComSaldoOs(_armazemInsumos))
              AppSearchSelectOption(
                value: item.produto,
                label: item.produto,
                detail:
                    '${_formatarNumeroOs(item.saldo)} ${item.unidade} disponíveis',
              ),
          ],
          (valor) => setState(() => _produtoInsumo = valor),
          enabled: _armazemInsumos != null,
          placeholder: _armazemInsumos == null
              ? 'Escolha o armazém primeiro'
              : 'Selecionar produto',
        ),
        _campoSomenteLeitura('Unidade de medida', estoque?.unidade),
        _campoSomenteLeitura(
          'Estoque disponível',
          estoque == null
              ? null
              : '${_formatarNumeroOs(estoque.saldo)} ${estoque.unidade}',
        ),
        _campoTexto(
          'Quantidade por hectare',
          _quantidadePorHa,
          error: _erro('dose'),
          placeholder: 'Ex.: 2,5',
          mandatory: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        _campoTexto(
          'Quantidade total',
          _quantidadeTotal,
          error: _erro('total'),
          placeholder: 'Ex.: 80',
          mandatory: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _formularioProducao() {
    ProdutoProducaoOsCadastro? produto;
    for (final cadastrado in produtosProducaoOs) {
      if (cadastrado.produto == _produtoProducao) produto = cadastrado;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _campoBusca(
          'armazem',
          'Armazém de produção',
          _armazemProducao,
          [
            for (final nome in armazensProducaoOs)
              AppSearchSelectOption(value: nome, label: nome),
          ],
          (valor) => setState(() {
            _armazemProducao = valor;
            _produtoProducao = null;
          }),
          enabled: !widget.armazemProducaoBloqueado,
          placeholder: widget.armazemProducaoBloqueado
              ? _armazemProducao ?? 'Armazém da coleção'
              : 'Selecionar armazém',
        ),
        _campoBusca(
          'produto',
          'Produto gerado',
          _produtoProducao,
          _opcoes(produtosPorArmazemProducaoOs[_armazemProducao] ?? const []),
          (valor) => setState(() => _produtoProducao = valor),
          enabled: _armazemProducao != null,
          placeholder: _armazemProducao == null
              ? 'Escolha o armazém primeiro'
              : 'Selecionar produto',
        ),
        _campoSomenteLeitura('Unidade de medida', produto?.unidade),
        _campoTexto(
          'Quantidade',
          _quantidadeProducao,
          error: _erro('quantidade'),
          placeholder: 'Ex.: 120',
          mandatory: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        _campoTexto('Observação', _observacao, placeholder: 'Opcional'),
      ],
    );
  }

  List<AppSearchSelectOption> _opcoes(List<String> values) => [
    for (final value in values)
      AppSearchSelectOption(value: value, label: value),
  ];

  Widget _formularioEpi() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _campoBusca(
        'epi',
        'Produto de proteção',
        _epi,
        _opcoes(episOs),
        (valor) => setState(() => _epi = valor),
      ),
      _campoTexto('Observação', _observacao, placeholder: 'Opcional'),
    ],
  );

  @override
  Widget build(BuildContext context) => switch (widget.kind) {
    _OsItemKind.maoDeObra => _formularioMaoDeObra(),
    _OsItemKind.maquinas => _formularioMaquina(),
    _OsItemKind.insumos => _formularioInsumo(),
    _OsItemKind.producao => _formularioProducao(),
    _OsItemKind.epis => _formularioEpi(),
  };
}
