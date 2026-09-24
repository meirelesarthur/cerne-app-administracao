import 'models.dart';

/// Nove OS de amostra cobrindo os seis estados do ciclo de vida, com a
/// composição real do formulário do WEB (mapa de campos de 24/09/2026):
/// Uso → Operação → Atividade do catálogo, execução por área/cultura/lote/
/// categoria, condições, instruções, segurança e as cinco abas de recursos
/// — cada aba com um armazém só, como lá.
///
/// Operações, atividades, categorias e armazéns são os valores do catálogo
/// do WEB. Pessoas, fazendas, fornecedores e lotes são fictícios.
const _armazemInsumos = 'Armazém Insumos';
const _tanqueS10 = 'Tanque Combustível S10';
const _armazemProducao = 'Armazém Produção';

const _nr31 =
    'NR-31 — EPI entregue com ficha assinada e treinamento da atividade em '
    'dia para todos os executores.';

final List<OrdemServico> ordensServico = [
  // 1) Aguardando — ainda não iniciada, elegível a cancelamento pelo escritório.
  OrdemServico(
    id: 'os-2201',
    codigo: 'OS #2201',
    fazenda: 'Fazenda São Pedro',
    solicitante: 'Maria Fernandes — Supervisora de Campo',
    dataEmissao: DateTime(2026, 9, 12, 8, 30),
    dataExecucao: DateTime(2026, 9, 17),
    prazo: DateTime(2026, 9, 19),
    responsavelExecucao: 'João Oliveira',
    uso: UsoOs.pecuaria,
    operacao: 'Construção Instalações',
    atividade: 'Construção de Cercas',
    area: 'Pasto 04',
    lote: 'Lote 04 - Novilhas Recria',
    categoria: 'Fêmeas 13 a 24 meses',
    condicoes: const CondicoesOs(
      requisitosClimaticos: 'Sem chuva; solo firme para cravar os mourões.',
      temperaturaMinima: 15,
      temperaturaMaxima: 34,
      horarioInicio: '06:30',
      horarioFim: '17:00',
    ),
    descricao:
        'Trecho de 180 m de cerca derrubado por queda de árvore na divisa com '
        'o Pasto 05. Substituir 12 mourões e esticar 3 fios de arame liso.',
    instrucoes: const InstrucoesOs(
      resultadosEsperados:
          '180 m de cerca refeitos, com 3 fios esticados e o rebanho contido '
          'no Pasto 04.',
      criteriosSucesso:
          'Mourões a no máximo 2,5 m entre si, fios sem folga e nenhum animal '
          'passando para o Pasto 05.',
      roteiro:
          '1. Retirar o lote do Pasto 04. 2. Cortar e empilhar a árvore '
          'caída. 3. Cravar os 12 mourões. 4. Esticar e grampear os fios. '
          '5. Devolver o lote e conferir a cerca.',
    ),
    seguranca: const SegurancaOs(
      restricoesAmbientais:
          'Madeira da árvore caída fica na fazenda como lenha; não queimar '
          'resíduos no pasto.',
      conformidadeLegal: _nr31,
    ),
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        executor: 'João Oliveira',
        funcao: 'Encarregado',
      ),
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        executor: 'Pedro Alves',
        funcao: 'Auxiliar de campo',
      ),
    ],
    maquinas: const [
      MaquinaOs(equipamento: 'Trator MF 4275'),
      MaquinaOs(
        equipamento: 'Cravador de mourão hidráulico',
        observacao: 'Acoplar no trator antes de sair da sede.',
      ),
    ],
    armazemInsumos: _armazemInsumos,
    insumos: const [
      InsumoOs(
        produto: 'Mourão de eucalipto tratado 2,2 m',
        unidadeMedida: 'un',
        estoque: 48,
        quantidadePorHa: 0,
        quantidadeTotal: 12,
      ),
      InsumoOs(
        produto: 'Arame liso nº 12',
        unidadeMedida: 'm',
        estoque: 1500,
        quantidadePorHa: 0,
        quantidadeTotal: 540,
      ),
      InsumoOs(
        produto: 'Grampo galvanizado',
        unidadeMedida: 'kg',
        estoque: 18.5,
        quantidadePorHa: 0,
        quantidadeTotal: 2,
      ),
    ],
    armazemProducao: _armazemProducao,
    producao: const [
      ProducaoOs(
        produto: 'Lenha de eucalipto',
        unidadeMedida: 'm³',
        quantidade: 2,
        observacao:
            'Madeira da árvore caída sobre a cerca, cortada e empilhada.',
      ),
    ],
    epis: const [
      EpiOs(
        produto: 'Luva de raspa',
        observacao: 'Ao manusear arame sob tensão.',
      ),
      EpiOs(produto: 'Óculos de proteção'),
      EpiOs(produto: 'Bota de segurança'),
    ],
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 9, 12, 14, 10),
    prioridade: PrioridadeOs.alta,
    status: OrdemServicoStatus.aguardando,
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 12, 8, 30),
        autor: 'Maria Fernandes',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 12, 14, 10),
        autor: 'Carlos Menezes',
        acao: 'OS autorizada',
        observacao:
            'Recursos alocados: 2 colaboradores, trator com cravador e '
            'material de cerca.',
      ),
    ],
  ),

  // 2) Em execução, com evidências registradas — ainda cancelável.
  OrdemServico(
    id: 'os-2198',
    codigo: 'OS #2198',
    fazenda: 'Fazenda Santa Rita',
    solicitante: 'Roberto Lima — Médico Veterinário',
    dataEmissao: DateTime(2026, 9, 8, 7),
    dataExecucao: DateTime(2026, 9, 14),
    prazo: DateTime(2026, 9, 18),
    responsavelExecucao: 'João Oliveira',
    uso: UsoOs.pecuaria,
    operacao: 'Sanidade Animal',
    atividade: 'Vacinação',
    area: 'Pasto 12',
    lote: 'Lote 12 - Recria',
    categoria: 'Machos 13 a 24 meses',
    condicoes: const CondicoesOs(
      requisitosClimaticos:
          'Manejo nas horas frescas; suspender com chuva forte no curral.',
      temperaturaMinima: 12,
      temperaturaMaxima: 30,
      horarioInicio: '06:00',
      horarioFim: '10:30',
    ),
    descricao:
        'Aplicar dose de reforço da vacina contra febre aftosa em 214 animais '
        'do Lote 12, com registro individual por brinco no boletim sanitário.',
    instrucoes: const InstrucoesOs(
      resultadosEsperados:
          '214 animais vacinados e o boletim sanitário do lote completo.',
      criteriosSucesso:
          'Todos os brincos do lote conferidos no boletim; vacina mantida '
          'entre 2 °C e 8 °C do início ao fim.',
      roteiro:
          '1. Conferir a temperatura da caixa térmica. 2. Passar o lote pelo '
          'tronco em grupos de 20. 3. Aplicar 5 ml subcutâneo por animal. '
          '4. Anotar o brinco no boletim. 5. Devolver o lote ao Pasto 12.',
    ),
    seguranca: const SegurancaOs(
      restricoesAmbientais:
          'Frascos vazios e agulhas vão para o coletor de perfurocortante e '
          'depois para o recolhimento oficial; nada no lixo comum.',
      conformidadeLegal:
          'Calendário oficial de vacinação contra aftosa; declaração de '
          'vacinação na agência de defesa agropecuária até 10 dias depois.',
    ),
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        executor: 'João Oliveira',
        funcao: 'Encarregado',
      ),
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        executor: 'Fabiana Rocha',
        funcao: 'Auxiliar veterinária',
      ),
    ],
    maquinas: const [
      MaquinaOs(
        equipamento: 'Tronco de contenção móvel',
        observacao: 'Montar na saída do curral de manejo 2.',
      ),
    ],
    armazemInsumos: _armazemInsumos,
    insumos: const [
      InsumoOs(
        produto: 'Vacina Aftosa (lote VA-2026-08)',
        unidadeMedida: 'dose',
        estoque: 640,
        quantidadePorHa: 0,
        quantidadeTotal: 220,
      ),
      InsumoOs(
        produto: 'Seringa dosadora 50 ml',
        unidadeMedida: 'un',
        estoque: 11,
        quantidadePorHa: 0,
        quantidadeTotal: 4,
      ),
      InsumoOs(
        produto: 'Agulha 15x18 descartável',
        unidadeMedida: 'un',
        estoque: 380,
        quantidadePorHa: 0,
        quantidadeTotal: 60,
      ),
    ],
    epis: const [
      EpiOs(
        produto: 'Luva nitrílica sem pó',
        observacao: 'Trocar a cada 50 animais.',
      ),
      EpiOs(produto: 'Avental impermeável'),
      EpiOs(produto: 'Bota de segurança'),
    ],
    autorizador: 'Ana Beatriz — Gerente Administrativa',
    dataAutorizacao: DateTime(2026, 9, 8, 9, 15),
    prioridade: PrioridadeOs.media,
    status: OrdemServicoStatus.emExecucao,
    dataInicio: DateTime(2026, 9, 14, 7, 20),
    avaliacao: AvaliacaoOs(
      nota: 4,
      comentario:
          'Ritmo de aplicação dentro do esperado; conferir cada brinco antes '
          'de fechar o boletim sanitário.',
      avaliador: 'Ana Beatriz',
      dataHora: DateTime(2026, 9, 14, 12),
    ),
    evidencias: [
      EvidenciaOs(
        legenda: 'Boletim sanitário parcial — 96 de 214 animais vacinados',
        dataHora: DateTime(2026, 9, 14, 11, 45),
        autor: 'João Oliveira',
        observacao:
            'Faltam os lotes do retiro; o restante fica para amanhã cedo, '
            'antes do calor.',
      ),
      EvidenciaOs(
        legenda: 'Foto do lote de vacina e temperatura da caixa térmica',
        dataHora: DateTime(2026, 9, 14, 7, 25),
        autor: 'Fabiana Rocha',
        observacao:
            'Caixa térmica a 5 °C na abertura, dentro da faixa de 2 °C a 8 °C.',
      ),
    ],
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 8, 7),
        autor: 'Roberto Lima',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 8, 9, 15),
        autor: 'Ana Beatriz',
        acao: 'OS autorizada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 14, 7, 20),
        autor: 'João Oliveira',
        acao: 'Execução iniciada',
      ),
    ],
  ),

  // 3) Pausada — motivo de pausa registrado pelo Operacional.
  OrdemServico(
    id: 'os-2185',
    codigo: 'OS #2185',
    fazenda: 'Fazenda São Pedro',
    solicitante: 'Pedro Alves — Auxiliar de campo',
    dataEmissao: DateTime(2026, 9, 5, 16),
    dataExecucao: DateTime(2026, 9, 15),
    prazo: DateTime(2026, 9, 20),
    responsavelExecucao: 'Sérgio Nunes',
    uso: UsoOs.pecuaria,
    operacao: 'Manutenção Instalações',
    atividade: 'Manutenções de Currais',
    area: 'Curral de manejo 1',
    condicoes: const CondicoesOs(
      requisitosClimaticos: 'Sem chuva — madeira molhada não recebe verniz.',
      temperaturaMinima: 15,
      temperaturaMaxima: 35,
      horarioInicio: '07:00',
      horarioFim: '17:00',
    ),
    descricao:
        'Trocar 8 tábuas quebradas do corredor e a porteira do embarcadouro '
        'do curral de manejo 1, que empenou e não fecha mais.',
    instrucoes: const InstrucoesOs(
      resultadosEsperados:
          'Corredor sem tábuas soltas e a porteira do embarcadouro fechando '
          'com a tranca.',
      criteriosSucesso:
          'Nenhuma tábua com folga ao empurrar; porteira abre e fecha sem '
          'arrastar no chão.',
      roteiro:
          '1. Isolar o curral. 2. Retirar as tábuas quebradas. 3. Instalar as '
          'novas com parafuso. 4. Trocar a porteira. 5. Liberar o curral.',
    ),
    seguranca: const SegurancaOs(
      restricoesAmbientais:
          'Tábuas retiradas vão para a caçamba de madeira da sede; não '
          'queimar no curral.',
      conformidadeLegal: _nr31,
    ),
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        executor: 'Sérgio Nunes',
        funcao: 'Mecânico',
      ),
      MaoDeObraOs(tipo: TipoMaoDeObraOs.funcao, executor: 'Ajudante Geral'),
    ],
    maquinas: const [
      MaquinaOs(
        equipamento: 'Furadeira de impacto a bateria',
        observacao: 'Levar as duas baterias carregadas.',
      ),
    ],
    armazemInsumos: _armazemInsumos,
    insumos: const [
      InsumoOs(
        produto: 'Tábua de eucalipto tratado 2,5 m',
        unidadeMedida: 'un',
        estoque: 3,
        quantidadePorHa: 0,
        quantidadeTotal: 8,
      ),
      InsumoOs(
        produto: 'Porteira de madeira 3 m',
        unidadeMedida: 'un',
        estoque: 0,
        quantidadePorHa: 0,
        quantidadeTotal: 1,
      ),
      InsumoOs(
        produto: 'Parafuso francês 1/2" x 6"',
        unidadeMedida: 'un',
        estoque: 120,
        quantidadePorHa: 0,
        quantidadeTotal: 32,
      ),
    ],
    epis: const [
      EpiOs(produto: 'Luva de raspa'),
      EpiOs(produto: 'Óculos de proteção'),
      EpiOs(
        produto: 'Protetor auricular',
        observacao: 'Com a furadeira ligada.',
      ),
    ],
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 9, 6, 8),
    prioridade: PrioridadeOs.alta,
    status: OrdemServicoStatus.pausada,
    dataInicio: DateTime(2026, 9, 15, 8),
    dataPausa: DateTime(2026, 9, 15, 10, 30),
    motivoPausa:
        'Porteira e 5 das 8 tábuas fora do estoque local — aguardando envio '
        'do almoxarifado central.',
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 5, 16),
        autor: 'Pedro Alves',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 6, 8),
        autor: 'Carlos Menezes',
        acao: 'OS autorizada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 15, 8),
        autor: 'Sérgio Nunes',
        acao: 'Execução iniciada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 15, 10, 30),
        autor: 'Sérgio Nunes',
        acao: 'Execução pausada',
        observacao:
            'Porteira e tábuas fora do estoque local — aguardando '
            'almoxarifado central.',
      ),
    ],
  ),

  // 4) Entregue — encerrada com sucesso pelo Operacional; escritório só visualiza.
  OrdemServico(
    id: 'os-2170',
    codigo: 'OS #2170',
    fazenda: 'Fazenda Boa Vista',
    solicitante: 'Ana Beatriz — Gerente Administrativa',
    dataEmissao: DateTime(2026, 8, 28, 9),
    dataExecucao: DateTime(2026, 9, 8),
    prazo: DateTime(2026, 9, 10),
    responsavelExecucao: 'Sérgio Nunes',
    uso: UsoOs.pecuaria,
    operacao: 'Manutenção Instalações',
    atividade: 'Manutenções Cochos/Bebedouros',
    area: 'Pasto 07',
    lote: 'Lote 07 - Bezerras Desmamadas',
    categoria: 'Fêmeas 0 a 12 meses',
    condicoes: const CondicoesOs(
      requisitosClimaticos: 'Sem chuva por 24 h para a cura do concreto.',
      temperaturaMinima: 15,
      temperaturaMaxima: 35,
      horarioInicio: '07:00',
      horarioFim: '16:30',
    ),
    descricao:
        'Instalar bebedouro de 1.000 L com boia automática e base de concreto '
        'no Pasto 07, atendendo o lote de bezerras transferido para a área.',
    instrucoes: const InstrucoesOs(
      resultadosEsperados:
          'Bebedouro nivelado, com boia funcionando e água limpa à '
          'disposição do lote.',
      criteriosSucesso:
          'Reservatório enche e a boia corta sozinha; nenhum vazamento na '
          'base depois de 24 h.',
      roteiro:
          '1. Escavar e nivelar a base. 2. Concretar e aguardar a cura. '
          '3. Assentar o bebedouro. 4. Ligar a boia. 5. Testar com o '
          'reservatório cheio.',
    ),
    seguranca: const SegurancaOs(
      restricoesAmbientais:
          'Não lavar a betoneira perto do córrego; sobra de concreto vai para '
          'o entulho da sede.',
      conformidadeLegal: _nr31,
    ),
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        executor: 'Sérgio Nunes',
        funcao: 'Mecânico',
      ),
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        executor: 'João Oliveira',
        funcao: 'Encarregado',
      ),
    ],
    maquinas: const [
      MaquinaOs(equipamento: 'Betoneira 400 L'),
      MaquinaOs(
        equipamento: 'Trator MF 4275',
        observacao: 'Com a carreta basculante para levar areia e brita.',
      ),
    ],
    armazemInsumos: _armazemInsumos,
    insumos: const [
      InsumoOs(
        produto: 'Bebedouro 1.000 L com boia',
        unidadeMedida: 'un',
        estoque: 3,
        quantidadePorHa: 0,
        quantidadeTotal: 1,
      ),
      InsumoOs(
        produto: 'Cimento CP-II 50 kg',
        unidadeMedida: 'saco',
        estoque: 42,
        quantidadePorHa: 0,
        quantidadeTotal: 6,
      ),
      InsumoOs(
        produto: 'Brita nº 1',
        unidadeMedida: 'm³',
        estoque: 8,
        quantidadePorHa: 0,
        quantidadeTotal: 0.5,
      ),
    ],
    epis: const [
      EpiOs(produto: 'Capacete', observacao: 'Ao operar a betoneira.'),
      EpiOs(produto: 'Luva de raspa'),
      EpiOs(produto: 'Bota de segurança'),
    ],
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 8, 28, 15, 40),
    prioridade: PrioridadeOs.media,
    status: OrdemServicoStatus.entregue,
    dataInicio: DateTime(2026, 9, 8, 7, 30),
    dataEntrega: DateTime(2026, 9, 10, 16, 45),
    evidencias: [
      EvidenciaOs(
        legenda: 'Base de concreto curada e bebedouro nivelado',
        dataHora: DateTime(2026, 9, 10, 16),
        autor: 'Sérgio Nunes',
      ),
      EvidenciaOs(
        legenda: 'Teste da boia automática com reservatório cheio',
        dataHora: DateTime(2026, 9, 10, 16, 30),
        autor: 'João Oliveira',
      ),
    ],
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 8, 28, 9),
        autor: 'Ana Beatriz',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 8, 28, 15, 40),
        autor: 'Carlos Menezes',
        acao: 'OS autorizada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 8, 7, 30),
        autor: 'Sérgio Nunes',
        acao: 'Execução iniciada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 10, 16, 45),
        autor: 'Sérgio Nunes',
        acao: 'OS marcada como entregue',
      ),
    ],
  ),

  // 5) Refeita — encerrada pelo Operacional com justificativa de retrabalho.
  OrdemServico(
    id: 'os-2160',
    codigo: 'OS #2160',
    fazenda: 'Fazenda Santa Rita',
    solicitante: 'Roberto Lima — Médico Veterinário',
    dataEmissao: DateTime(2026, 9, 2, 6, 45),
    dataExecucao: DateTime(2026, 9, 2),
    prazo: DateTime(2026, 9, 3),
    responsavelExecucao: 'João Oliveira',
    uso: UsoOs.pecuaria,
    operacao: 'Manutenção Instalações',
    atividade: 'Manutenções de Cercas',
    area: 'Pasto 09',
    lote: 'Lote 09 - Vacas p/ Reprodução',
    categoria: 'Fêmeas > 36 meses',
    condicoes: const CondicoesOs(
      requisitosClimaticos:
          'Qualquer tempo (emergência); com chuva, reforçar a sinalização.',
      temperaturaMinima: 10,
      temperaturaMaxima: 38,
      horarioInicio: '06:00',
      horarioFim: '18:00',
    ),
    descricao:
        'Recolher 18 cabeças do Lote 09 que romperam a cerca em direção à '
        'estrada vicinal e montar contenção provisória até o reparo definitivo.',
    instrucoes: const InstrucoesOs(
      resultadosEsperados:
          '18 cabeças de volta ao Pasto 09 e a divisa com a estrada contida.',
      criteriosSucesso:
          'Contagem do lote bate com o cadastro; nenhum animal na estrada nas '
          '24 h seguintes.',
      roteiro:
          '1. Sinalizar a estrada. 2. Recolher os animais a cavalo. 3. Contar '
          'o lote no curral. 4. Montar a cerca elétrica provisória na divisa.',
    ),
    seguranca: const SegurancaOs(
      restricoesAmbientais:
          'Cerca provisória fora da área de preservação da margem do córrego.',
      conformidadeLegal:
          'Sinalização na via pública durante o recolhimento; ninguém na '
          'pista sem colete refletivo.',
    ),
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        executor: 'João Oliveira',
        funcao: 'Encarregado',
      ),
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        executor: 'Fabiana Rocha',
        funcao: 'Auxiliar veterinária',
      ),
    ],
    maquinas: const [
      MaquinaOs(
        equipamento: 'Camionete de apoio Hilux',
        observacao: 'Levar os cones e o eletrificador.',
      ),
    ],
    armazemInsumos: _armazemInsumos,
    insumos: const [
      InsumoOs(
        produto: 'Fita para cerca elétrica provisória',
        unidadeMedida: 'm',
        estoque: 600,
        quantidadePorHa: 0,
        quantidadeTotal: 150,
      ),
      InsumoOs(
        produto: 'Haste isoladora',
        unidadeMedida: 'un',
        estoque: 120,
        quantidadePorHa: 0,
        quantidadeTotal: 40,
      ),
    ],
    epis: const [
      EpiOs(produto: 'Colete refletivo', observacao: 'Obrigatório na pista.'),
      EpiOs(produto: 'Luva de raspa'),
      EpiOs(produto: 'Bota de segurança'),
    ],
    autorizador: 'Ana Beatriz — Gerente Administrativa',
    dataAutorizacao: DateTime(2026, 9, 2, 7, 10),
    prioridade: PrioridadeOs.urgente,
    status: OrdemServicoStatus.refeita,
    dataInicio: DateTime(2026, 9, 2, 7, 20),
    justificativaRefazer:
        'Cerca elétrica provisória não resistiu à chuva da noite seguinte e o '
        'lote voltou a se aproximar da estrada — necessário refazer com '
        'mourões fixos e fio de arame reforçado em vez de fita provisória.',
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 2, 6, 45),
        autor: 'Roberto Lima',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 2, 7, 10),
        autor: 'Ana Beatriz',
        acao: 'OS autorizada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 2, 7, 20),
        autor: 'João Oliveira',
        acao: 'Execução iniciada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 3, 6, 30),
        autor: 'João Oliveira',
        acao: 'OS marcada como refeita',
        observacao:
            'Cerca provisória não resistiu à chuva — necessário refazer com '
            'fixação reforçada.',
      ),
    ],
  ),

  // 6) Aguardando — urgente, a próxima da fila depois das já iniciadas.
  OrdemServico(
    id: 'os-2207',
    codigo: 'OS #2207',
    fazenda: 'Fazenda São Pedro',
    solicitante: 'João Oliveira — Encarregado',
    dataEmissao: DateTime(2026, 9, 22, 6, 40),
    dataExecucao: DateTime(2026, 9, 23),
    prazo: DateTime(2026, 9, 24),
    responsavelExecucao: 'Pedro Alves',
    uso: UsoOs.pecuaria,
    operacao: 'Manutenção Instalações',
    atividade: 'Manutenções de Construções',
    area: 'Curral 12',
    condicoes: const CondicoesOs(
      requisitosClimaticos: 'Sem vento forte nem chuva — trabalho em altura.',
      temperaturaMinima: 15,
      temperaturaMaxima: 33,
      horarioInicio: '07:00',
      horarioFim: '16:00',
    ),
    descricao:
        'Boia travada e trinca na base da caixa d’água de 5.000 L que abastece '
        'os bebedouros do Curral 12. Trocar a boia e vedar a trinca.',
    instrucoes: const InstrucoesOs(
      resultadosEsperados:
          'Caixa d’água sem vazamento e a boia controlando o nível.',
      criteriosSucesso:
          'Base seca 2 h depois de encher; boia fecha no nível máximo.',
      roteiro:
          '1. Fechar o registro geral. 2. Esvaziar a caixa. 3. Trocar a boia. '
          '4. Vedar a trinca com epóxi. 5. Encher e conferir.',
    ),
    seguranca: const SegurancaOs(
      restricoesAmbientais:
          'Água esvaziada da caixa vai para os bebedouros, não para o chão '
          'do curral.',
      conformidadeLegal:
          'NR-35 — trabalho em altura com cinto preso e um colaborador '
          'segurando a escada o tempo todo.',
    ),
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        executor: 'Pedro Alves',
        funcao: 'Auxiliar de campo',
      ),
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.fornecedor,
        executor: 'Hidráulica Araguaia Ltda',
      ),
    ],
    maquinas: const [MaquinaOs(equipamento: 'Escada extensível 7 m')],
    armazemInsumos: _armazemInsumos,
    insumos: const [
      InsumoOs(
        produto: 'Boia 3/4"',
        unidadeMedida: 'un',
        estoque: 5,
        quantidadePorHa: 0,
        quantidadeTotal: 1,
      ),
      InsumoOs(
        produto: 'Massa epóxi para vedação',
        unidadeMedida: 'un',
        estoque: 9,
        quantidadePorHa: 0,
        quantidadeTotal: 2,
      ),
    ],
    epis: const [
      EpiOs(
        produto: 'Cinto de segurança tipo paraquedista',
        observacao: 'Acima de 2 m de altura.',
      ),
      EpiOs(produto: 'Luva de raspa'),
      EpiOs(produto: 'Bota de segurança'),
    ],
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 9, 22, 7, 5),
    prioridade: PrioridadeOs.urgente,
    status: OrdemServicoStatus.aguardando,
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 22, 6, 40),
        autor: 'João Oliveira',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 22, 7, 5),
        autor: 'Carlos Menezes',
        acao: 'OS autorizada',
      ),
    ],
  ),

  // 7) Aguardando — média; gera produção (feno).
  OrdemServico(
    id: 'os-2204',
    codigo: 'OS #2204',
    fazenda: 'Fazenda Boa Vista',
    solicitante: 'Maria Fernandes — Supervisora de Campo',
    dataEmissao: DateTime(2026, 9, 19, 10),
    dataExecucao: DateTime(2026, 9, 25),
    prazo: DateTime(2026, 9, 27),
    responsavelExecucao: 'Pedro Alves',
    uso: UsoOs.pecuaria,
    operacao: 'Manutenção Culturas Perenes',
    atividade: 'Manutenção Pastagens',
    area: 'Pasto 03',
    lote: 'Lote 04 - Novilhas Recria',
    categoria: 'Fêmeas 13 a 24 meses',
    condicoes: const CondicoesOs(
      requisitosClimaticos:
          'Três dias sem chuva: o capim precisa secar antes de enfardar.',
      temperaturaMinima: 18,
      temperaturaMaxima: 36,
      horarioInicio: '08:00',
      horarioFim: '17:30',
    ),
    descricao:
        'Roçar 6 ha de pasto com excesso de capim-colonião antes da entrada '
        'do Lote 04 e enfardar o capim roçado como feno.',
    instrucoes: const InstrucoesOs(
      resultadosEsperados:
          '6 ha roçados a 20 cm e o capim enfardado no armazém de produção.',
      criteriosSucesso:
          'Altura de corte uniforme; fardos secos, sem mofo, de cerca de 20 kg.',
      roteiro:
          '1. Retirar o gado do Pasto 03. 2. Roçar a 20 cm. 3. Deixar secar '
          '2 dias. 4. Enfardar. 5. Levar os fardos ao armazém.',
    ),
    seguranca: const SegurancaOs(
      restricoesAmbientais:
          'Não roçar a faixa de 30 m da nascente no canto do pasto.',
      conformidadeLegal:
          'NR-31 — ninguém a menos de 30 m da roçadeira em funcionamento.',
    ),
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        executor: 'Pedro Alves',
        funcao: 'Operador de máquinas',
      ),
    ],
    maquinas: const [
      MaquinaOs(equipamento: 'Trator MF 4275'),
      MaquinaOs(
        equipamento: 'Roçadeira hidráulica 1,7 m',
        observacao: 'Altura de corte em 20 cm.',
      ),
      MaquinaOs(equipamento: 'Enfardadora de feno'),
    ],
    armazemInsumos: _tanqueS10,
    insumos: const [
      InsumoOs(
        produto: 'ÓLEO DIESEL S 10',
        unidadeMedida: 'l',
        estoque: 4300,
        quantidadePorHa: 10,
        quantidadeTotal: 60,
      ),
    ],
    armazemProducao: _armazemProducao,
    producao: const [
      ProducaoOs(
        produto: 'Feno de capim-colonião',
        unidadeMedida: 'fardo',
        quantidade: 120,
        observacao: 'Enfardar só com o capim seco; fardos de cerca de 20 kg.',
      ),
    ],
    epis: const [
      EpiOs(
        produto: 'Protetor auricular',
        observacao: 'Com a roçadeira ligada.',
      ),
      EpiOs(produto: 'Óculos de proteção'),
      EpiOs(produto: 'Bota de segurança'),
    ],
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 9, 19, 16, 20),
    prioridade: PrioridadeOs.media,
    status: OrdemServicoStatus.aguardando,
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 19, 10),
        autor: 'Maria Fernandes',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 19, 16, 20),
        autor: 'Carlos Menezes',
        acao: 'OS autorizada',
      ),
    ],
  ),

  // 8) Aguardando — baixa, prazo folgado.
  OrdemServico(
    id: 'os-2209',
    codigo: 'OS #2209',
    fazenda: 'Fazenda São Pedro',
    solicitante: 'Ana Beatriz — Gerente Administrativa',
    dataEmissao: DateTime(2026, 9, 21, 14),
    dataExecucao: DateTime(2026, 9, 30),
    prazo: DateTime(2026, 10, 3),
    responsavelExecucao: 'Fabiana Rocha',
    uso: UsoOs.ambos,
    operacao: 'Armazenagem',
    atividade: 'Limpeza',
    area: 'Galpão de insumos',
    condicoes: const CondicoesOs(
      requisitosClimaticos: 'Telhado seco; não subir com chuva ou orvalho.',
      temperaturaMinima: 15,
      temperaturaMaxima: 32,
      horarioInicio: '08:00',
      horarioFim: '15:00',
    ),
    descricao:
        'Retirar folhas e barro das calhas antes do período de chuva para '
        'evitar infiltração sobre os sacos de ração.',
    instrucoes: const InstrucoesOs(
      resultadosEsperados: 'Calhas e condutores desentupidos.',
      criteriosSucesso:
          'Água de teste com a mangueira escoa pelos condutores sem '
          'transbordar.',
      roteiro:
          '1. Prender a linha de vida. 2. Retirar a sujeira das calhas. '
          '3. Desentupir os condutores. 4. Testar com a mangueira.',
    ),
    seguranca: const SegurancaOs(
      restricoesAmbientais:
          'Folhas e barro para a composteira, não para o pátio.',
      conformidadeLegal:
          'NR-35 — trabalho em altura com cinto preso à linha de vida.',
    ),
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        executor: 'Fabiana Rocha',
        funcao: 'Auxiliar',
      ),
    ],
    maquinas: const [MaquinaOs(equipamento: 'Escada extensível 7 m')],
    armazemInsumos: _armazemInsumos,
    insumos: const [
      InsumoOs(
        produto: 'Saco de lixo 100 L',
        unidadeMedida: 'un',
        estoque: 85,
        quantidadePorHa: 0,
        quantidadeTotal: 10,
      ),
    ],
    epis: const [
      EpiOs(
        produto: 'Cinto de segurança tipo paraquedista',
        observacao: 'Preso à linha de vida.',
      ),
      EpiOs(produto: 'Luva de raspa'),
      EpiOs(produto: 'Capacete'),
    ],
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 9, 22, 8),
    prioridade: PrioridadeOs.baixa,
    status: OrdemServicoStatus.aguardando,
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 21, 14),
        autor: 'Ana Beatriz',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 22, 8),
        autor: 'Carlos Menezes',
        acao: 'OS autorizada',
      ),
    ],
  ),

  // 9) Cancelada — o escritório cancelou antes do início.
  OrdemServico(
    id: 'os-2192',
    codigo: 'OS #2192',
    fazenda: 'Fazenda Santa Rita',
    solicitante: 'Maria Fernandes — Supervisora de Campo',
    dataEmissao: DateTime(2026, 9, 10, 9),
    dataExecucao: DateTime(2026, 9, 14),
    prazo: DateTime(2026, 9, 16),
    responsavelExecucao: 'Pedro Alves',
    uso: UsoOs.agricultura,
    operacao: 'Tratos Fitossanitários',
    atividade: 'Aplicação de Herbicida',
    area: 'Talhão 09',
    culturaVariedade: 'Milho - Safrinha 2026',
    condicoes: const CondicoesOs(
      requisitosClimaticos:
          'Vento abaixo de 10 km/h, umidade acima de 55% e sem chuva prevista '
          'por 6 h.',
      temperaturaMinima: 18,
      temperaturaMaxima: 30,
      horarioInicio: '06:00',
      horarioFim: '10:00',
    ),
    descricao:
        'Aplicação de herbicida pré-emergente em 22 ha antes do plantio do '
        'milho safrinha.',
    instrucoes: const InstrucoesOs(
      resultadosEsperados: '22 ha aplicados na dose da receita.',
      criteriosSucesso:
          'Faixas sem falha nem sobreposição no mapa do GPS; calda toda '
          'aplicada no talhão.',
      roteiro:
          '1. Calibrar o pulverizador. 2. Preparar a calda na ordem da bula. '
          '3. Aplicar com barra a 50 cm. 4. Tríplice lavagem das embalagens.',
    ),
    seguranca: const SegurancaOs(
      restricoesAmbientais:
          'Bordadura de 30 m do córrego sem aplicação; tríplice lavagem e '
          'devolução das embalagens.',
      conformidadeLegal:
          'Receituário agronômico nº 4812/2026; aplicador com curso NR-31 de '
          'agrotóxicos em dia.',
    ),
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        executor: 'Pedro Alves',
        funcao: 'Operador de máquinas',
      ),
    ],
    maquinas: const [
      MaquinaOs(equipamento: 'Trator MF 4275'),
      MaquinaOs(
        equipamento: 'Pulverizador Jacto 2000 L',
        observacao: 'Bicos leque 110.02 calibrados para 100 L/ha.',
      ),
    ],
    armazemInsumos: _armazemInsumos,
    insumos: const [
      InsumoOs(
        produto: 'Herbicida pré-emergente',
        unidadeMedida: 'l',
        estoque: 7.02,
        quantidadePorHa: 2,
        quantidadeTotal: 44,
      ),
      InsumoOs(
        produto: 'Adjuvante óleo mineral',
        unidadeMedida: 'l',
        estoque: 60,
        quantidadePorHa: 0.5,
        quantidadeTotal: 11,
      ),
    ],
    epis: const [
      EpiOs(
        produto: 'Máscara com filtro químico',
        observacao: 'Durante o preparo da calda e a aplicação.',
      ),
      EpiOs(produto: 'Macacão impermeável'),
      EpiOs(produto: 'Luva nitrílica'),
    ],
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 9, 10, 11),
    prioridade: PrioridadeOs.media,
    status: OrdemServicoStatus.cancelada,
    motivoCancelamento:
        'Chuva prevista para a semana toda; aplicação remarcada em nova OS.',
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 10, 9),
        autor: 'Maria Fernandes',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 10, 11),
        autor: 'Carlos Menezes',
        acao: 'OS autorizada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 12, 8),
        autor: 'Carlos Menezes',
        acao: 'OS cancelada',
        observacao: 'Chuva prevista para a semana toda.',
      ),
    ],
  ),
];
