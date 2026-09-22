import 'models.dart';

/// Cinco OS de amostra cobrindo os cinco estados do ciclo de vida e variando
/// tipo de serviço, fazenda, prioridade e recursos internamente cadastrados
/// — mesmo padrão de fidelidade dos mocks de Confinamento
/// (`confinamento/mocks.dart`), para o Operacional e o Administrativo verem
/// dados equivalentes ao que a OS carregaria vindo do app web.
final List<OrdemServico> ordensServico = [
  // 1) Aguardando — ainda não iniciada, elegível a avaliação/cancelamento do ADM.
  OrdemServico(
    id: 'os-2201',
    codigo: 'OS #2201',
    titulo: 'Reparo de cerca do Talhão 04',
    tipo: TipoServicoOs.agricola,
    fazenda: 'Fazenda São Pedro',
    areaOuTalhao: 'Talhão 04',
    solicitante: 'Maria Fernandes — Supervisora de Campo',
    dataSolicitacao: DateTime(2026, 9, 12, 8, 30),
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 9, 12, 14, 10),
    prioridade: PrioridadeOs.alta,
    prazo: DateTime(2026, 9, 19),
    descricao:
        'Trecho de 180 m de cerca derrubado por queda de árvore na divisa '
        'com o Talhão 05. Substituir 12 mourões e esticar 3 fios de arame liso.',
    instrucoesSeguranca:
        'Uso obrigatório de luvas de raspa e óculos de proteção ao manusear '
        'arame sob tensão. Isolar a área de acesso do rebanho antes de iniciar.',
    maoDeObra: const ['João Oliveira — Encarregado', 'Pedro Alves — Auxiliar de campo'],
    maquinas: const ['Trator MF 4275 (cravador de mourão)'],
    insumos: const ['12 mourões de eucalipto tratado', 'Arame liso nº 12 — 200 m', 'Grampos galvanizados — 2 kg'],
    epis: const ['Luva de raspa', 'Óculos de proteção', 'Bota de segurança'],
    status: OrdemServicoStatus.aguardando,
    responsavelExecucao: 'João Oliveira',
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
        observacao: 'Recursos alocados: 2 colaboradores, 1 trator, insumos de cerca.',
      ),
    ],
  ),

  // 2) Em execução — já avaliada pelo ADM em campo (checkpoint), ainda cancelável.
  OrdemServico(
    id: 'os-2198',
    codigo: 'OS #2198',
    titulo: 'Vacinação contra aftosa — Lote 12',
    tipo: TipoServicoOs.pecuario,
    fazenda: 'Fazenda Santa Rita',
    areaOuTalhao: 'Curral de manejo 2',
    solicitante: 'Roberto Lima — Médico Veterinário',
    dataSolicitacao: DateTime(2026, 9, 8, 7),
    autorizador: 'Ana Beatriz — Gerente Administrativa',
    dataAutorizacao: DateTime(2026, 9, 8, 9, 15),
    prioridade: PrioridadeOs.media,
    prazo: DateTime(2026, 9, 18),
    descricao:
        'Aplicar dose de reforço da vacina contra febre aftosa em 214 animais '
        'do Lote 12, com registro individual por brinco no boletim sanitário.',
    instrucoesSeguranca:
        'Contenção no tronco de manejo antes de cada aplicação. Descarte de '
        'agulhas em coletor perfurocortante; nunca reencapar.',
    maoDeObra: const ['João Oliveira — Encarregado', 'Fabiana Rocha — Auxiliar veterinária'],
    maquinas: const ['Tronco de contenção móvel'],
    insumos: const ['Vacina Aftosa (lote VA-2026-08) — 220 doses', 'Seringas dosadoras — 4 un.'],
    epis: const ['Luva de procedimento', 'Avental impermeável', 'Bota de segurança'],
    status: OrdemServicoStatus.emExecucao,
    responsavelExecucao: 'João Oliveira',
    dataInicio: DateTime(2026, 9, 14, 7, 20),
    evidencias: [
      EvidenciaOs(
        legenda: 'Boletim sanitário parcial — 96 de 214 animais vacinados',
        dataHora: DateTime(2026, 9, 14, 11, 45),
      ),
      EvidenciaOs(
        legenda: 'Foto do lote de vacina e temperatura da caixa térmica',
        dataHora: DateTime(2026, 9, 14, 7, 25),
      ),
    ],
    avaliacao: AvaliacaoOs(
      nota: 4,
      comentario:
          'Ritmo de aplicação dentro do esperado; reforçar o registro por '
          'brinco para não atrasar o fechamento do boletim.',
      avaliador: 'Ana Beatriz',
      dataHora: DateTime(2026, 9, 14, 12),
    ),
    historico: [
      EventoOs(dataHora: DateTime(2026, 9, 8, 7), autor: 'Roberto Lima', acao: 'OS solicitada'),
      EventoOs(dataHora: DateTime(2026, 9, 8, 9, 15), autor: 'Ana Beatriz', acao: 'OS autorizada'),
      EventoOs(dataHora: DateTime(2026, 9, 14, 7, 20), autor: 'João Oliveira', acao: 'Execução iniciada'),
      EventoOs(
        dataHora: DateTime(2026, 9, 14, 12),
        autor: 'Ana Beatriz',
        acao: 'Avaliação registrada — nota 4',
        observacao: 'Reforçar o registro por brinco para não atrasar o fechamento do boletim.',
      ),
    ],
  ),

  // 3) Pausada — motivo de pausa registrado pelo Operacional.
  OrdemServico(
    id: 'os-2185',
    codigo: 'OS #2185',
    titulo: 'Manutenção do trator John Deere 6110',
    tipo: TipoServicoOs.manutencao,
    fazenda: 'Fazenda São Pedro',
    areaOuTalhao: 'Oficina mecânica',
    solicitante: 'Pedro Alves — Auxiliar de campo',
    dataSolicitacao: DateTime(2026, 9, 5, 16),
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 9, 6, 8),
    prioridade: PrioridadeOs.alta,
    prazo: DateTime(2026, 9, 20),
    descricao:
        'Troca de óleo, filtros e correia do trator John Deere 6110 (placa '
        'interna TR-03), com ruído anormal reportado na tomada de força.',
    instrucoesSeguranca:
        'Bloquear a chave de partida durante a intervenção (procedimento '
        'lockout/tagout). Motor frio antes de abrir o sistema de arrefecimento.',
    maoDeObra: const ['Sérgio Nunes — Mecânico'],
    maquinas: const ['Trator John Deere 6110 (TR-03)'],
    insumos: const ['Óleo hidráulico 15W-40 — 20 L', 'Filtro de óleo e ar', 'Correia da TDP'],
    epis: const ['Luva de raspa', 'Óculos de proteção', 'Protetor auricular'],
    status: OrdemServicoStatus.pausada,
    responsavelExecucao: 'Sérgio Nunes',
    dataInicio: DateTime(2026, 9, 15, 8),
    dataPausa: DateTime(2026, 9, 15, 10, 30),
    motivoPausa: 'Correia da tomada de força fora do estoque local — aguardando envio do almoxarifado central.',
    historico: [
      EventoOs(dataHora: DateTime(2026, 9, 5, 16), autor: 'Pedro Alves', acao: 'OS solicitada'),
      EventoOs(dataHora: DateTime(2026, 9, 6, 8), autor: 'Carlos Menezes', acao: 'OS autorizada'),
      EventoOs(dataHora: DateTime(2026, 9, 15, 8), autor: 'Sérgio Nunes', acao: 'Execução iniciada'),
      EventoOs(
        dataHora: DateTime(2026, 9, 15, 10, 30),
        autor: 'Sérgio Nunes',
        acao: 'Execução pausada',
        observacao: 'Correia da tomada de força fora do estoque local — aguardando almoxarifado central.',
      ),
    ],
  ),

  // 4) Entregue — encerrada com sucesso pelo Operacional; ADM só visualiza.
  OrdemServico(
    id: 'os-2170',
    codigo: 'OS #2170',
    titulo: 'Construção de bebedouro no Piquete 07',
    tipo: TipoServicoOs.infraestrutura,
    fazenda: 'Fazenda Boa Vista',
    areaOuTalhao: 'Piquete 07',
    solicitante: 'Ana Beatriz — Gerente Administrativa',
    dataSolicitacao: DateTime(2026, 8, 28, 9),
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 8, 28, 15, 40),
    prioridade: PrioridadeOs.media,
    prazo: DateTime(2026, 9, 10),
    descricao:
        'Instalar bebedouro de 1.000 L com boia automática e base de concreto '
        'no Piquete 07, atendendo o novo lote de recria transferido para a área.',
    instrucoesSeguranca:
        'Sinalizar a escavação durante a obra. Uso de capacete ao operar a '
        'betoneira e cinto de segurança na montagem da estrutura elevada.',
    maoDeObra: const ['Sérgio Nunes — Mecânico', 'João Oliveira — Encarregado'],
    maquinas: const ['Betoneira 400L', 'Trator MF 4275 (carreta basculante)'],
    insumos: const ['Bebedouro 1.000 L com boia', 'Cimento — 6 sacos', 'Brita e areia — 1 m³'],
    epis: const ['Capacete', 'Luva de raspa', 'Bota de segurança', 'Cinto de segurança'],
    status: OrdemServicoStatus.entregue,
    responsavelExecucao: 'Sérgio Nunes',
    dataInicio: DateTime(2026, 9, 8, 7, 30),
    dataEntrega: DateTime(2026, 9, 10, 16, 45),
    evidencias: [
      EvidenciaOs(
        legenda: 'Base de concreto curada e bebedouro nivelado',
        dataHora: DateTime(2026, 9, 10, 16),
      ),
      EvidenciaOs(
        legenda: 'Teste da boia automática com reservatório cheio',
        dataHora: DateTime(2026, 9, 10, 16, 30),
      ),
    ],
    historico: [
      EventoOs(dataHora: DateTime(2026, 8, 28, 9), autor: 'Ana Beatriz', acao: 'OS solicitada'),
      EventoOs(dataHora: DateTime(2026, 8, 28, 15, 40), autor: 'Carlos Menezes', acao: 'OS autorizada'),
      EventoOs(dataHora: DateTime(2026, 9, 8, 7, 30), autor: 'Sérgio Nunes', acao: 'Execução iniciada'),
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
    titulo: 'Contenção emergencial de gado solto — Estrada vicinal',
    tipo: TipoServicoOs.pecuario,
    fazenda: 'Fazenda Santa Rita',
    areaOuTalhao: 'Divisa com a estrada vicinal km 4',
    solicitante: 'Roberto Lima — Médico Veterinário',
    dataSolicitacao: DateTime(2026, 9, 2, 6, 45),
    autorizador: 'Ana Beatriz — Gerente Administrativa',
    dataAutorizacao: DateTime(2026, 9, 2, 7, 10),
    prioridade: PrioridadeOs.urgente,
    prazo: DateTime(2026, 9, 3),
    descricao:
        'Recolher 18 cabeças do Lote 09 que romperam a cerca em direção à '
        'estrada vicinal e montar contenção provisória até o reparo definitivo.',
    instrucoesSeguranca:
        'Sinalização com cones na estrada durante o recolhimento. Nenhum '
        'colaborador entra na pista sem colete refletivo.',
    maoDeObra: const ['João Oliveira — Encarregado', 'Fabiana Rocha — Auxiliar veterinária'],
    maquinas: const ['Camionete de apoio'],
    insumos: const ['Cerca elétrica provisória — 150 m', 'Cones de sinalização — 8 un.'],
    epis: const ['Colete refletivo', 'Luva de raspa', 'Bota de segurança'],
    status: OrdemServicoStatus.refeita,
    responsavelExecucao: 'João Oliveira',
    dataInicio: DateTime(2026, 9, 2, 7, 20),
    justificativaRefazer:
        'Cerca elétrica provisória não resistiu à chuva da noite seguinte e o '
        'lote voltou a se aproximar da estrada — necessário refazer com '
        'mourões fixos e fio de arame reforçado em vez de fita provisória.',
    historico: [
      EventoOs(dataHora: DateTime(2026, 9, 2, 6, 45), autor: 'Roberto Lima', acao: 'OS solicitada'),
      EventoOs(dataHora: DateTime(2026, 9, 2, 7, 10), autor: 'Ana Beatriz', acao: 'OS autorizada'),
      EventoOs(dataHora: DateTime(2026, 9, 2, 7, 20), autor: 'João Oliveira', acao: 'Execução iniciada'),
      EventoOs(
        dataHora: DateTime(2026, 9, 3, 6, 30),
        autor: 'João Oliveira',
        acao: 'OS marcada como refeita',
        observacao: 'Cerca provisória não resistiu à chuva — necessário refazer com fixação reforçada.',
      ),
    ],
  ),
];
