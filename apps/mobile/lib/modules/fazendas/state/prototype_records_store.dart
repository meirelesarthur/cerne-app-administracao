import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PrototypeRecordStatus { active, completed, scheduled }

class PrototypeRecord {
  const PrototypeRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.details = const {},
  });

  final String id;
  final String title;
  final String description;
  final PrototypeRecordStatus status;
  final Map<String, String> details;
}

const initialPrototypeRecords = <String, List<PrototypeRecord>>{
  'saldo-estoque': [
    PrototypeRecord(
      id: 'saldo-1',
      title: 'Ração Engorda',
      description: 'Armazém A · 12.400 kg',
      status: PrototypeRecordStatus.active,
      details: {
        'Local': 'Armazém A',
        'Saldo': '12.400 kg',
        'Reserva': '1.000 kg',
        'Atualização': 'Hoje, 08:42',
      },
    ),
    PrototypeRecord(
      id: 'saldo-2',
      title: 'Sal Mineral',
      description: 'Armazém A · 3.200 kg',
      status: PrototypeRecordStatus.active,
      details: {
        'Local': 'Armazém A',
        'Saldo': '3.200 kg',
        'Reserva': '240 kg',
        'Atualização': 'Ontem, 17:18',
      },
    ),
    PrototypeRecord(
      id: 'saldo-3',
      title: 'Vacina Aftosa',
      description: 'Farmácia · 540 doses',
      status: PrototypeRecordStatus.active,
      details: {
        'Local': 'Farmácia',
        'Saldo': '540 doses',
        'Lote': 'VA-2026-08',
        'Validade': '30/11/2026',
      },
    ),
  ],
  'processamentos': [
    PrototypeRecord(
      id: 'processo-1',
      title: 'Transferência do Lote 42',
      description: 'Pendente · aguardando sincronização',
      status: PrototypeRecordStatus.scheduled,
      details: {
        'Tipo': 'Transferência',
        'Lote': 'Lote 42',
        'Responsável': 'João Oliveira',
        'Estado': 'Aguardando sincronização',
      },
    ),
    PrototypeRecord(
      id: 'processo-2',
      title: 'Pesagem do Lote 19',
      description: 'Concluída · hoje às 08:03',
      status: PrototypeRecordStatus.completed,
      details: {
        'Tipo': 'Pesagem',
        'Lote': 'Lote 19',
        'Responsável': 'Maria Souza',
        'Estado': 'Concluída',
      },
    ),
  ],
  'configuracoes-misturador': [
    PrototypeRecord(
      id: 'config-mist-1',
      title: 'Configuração Fazenda São Pedro',
      description: 'kg · tolerância 2% · alertas ativados',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Carlos Dias',
        'Unidade': 'kg',
        'Tolerância': '2%',
        'Alertas': 'Ativados',
      },
    ),
  ],
  // fidelidade-campos (onda 16 — visualização de abas): as etapas reais de
  // `marcacao` ("Identificação"/"Marcação"/"Safra e custo") exigem que o
  // registro guarde o valor sob a MESMA label exibida em cada campo — as
  // labels antigas ('Tipo'/'Referência') não batiam com as reais ('Tipo de
  // marcação'/'Referência de localização') e a aba correspondente ficava
  // vazia. Ver `functional_catalog.dart`, `marcacao.steps`.
  'marcacao': [
    PrototypeRecord(
      id: 'marcacao-1',
      title: 'Erosão na curva de nível',
      description: 'Ponto de atenção · Talhão 02',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Maria Souza',
        'Data da marcação': '05/08/2026',
        'Área': 'Talhão 02',
        'Referência de localização': 'Próximo à porteira leste',
        'Tipo de marcação': 'Ponto de atenção',
        'Descrição': 'Erosão na curva de nível',
        'Cor no mapa': '#F97316',
        'Quantidade': '1',
        'Safra': '2025/2026',
        'Variedade / cultura': 'Soja',
        'Semana da safra': '18',
        'Funcionário': 'Carlos Dias',
        'Centro de custo': 'Centro Agrícola',
      },
    ),
    PrototypeRecord(
      id: 'marcacao-2',
      title: 'Foco de daninhas resistentes',
      description: 'Ocorrência · Talhão 05',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'João Oliveira',
        'Data da marcação': '12/08/2026',
        'Área': 'Talhão 05',
        'Referência de localização': 'Faixa lateral próxima à estrada',
        'Tipo de marcação': 'Ocorrência',
        'Descrição': 'Foco de daninhas resistentes ao herbicida',
        'Cor no mapa': '#EF4444',
        'Quantidade': '3',
        'Safra': '2025/2026',
        'Variedade / cultura': 'Milho',
        'Semana da safra': '22',
        'Funcionário': 'João Oliveira',
        'Centro de custo': 'Centro Agrícola',
      },
    ),
    PrototypeRecord(
      id: 'marcacao-3',
      title: 'Amostragem de solo pré-plantio',
      description: 'Amostragem · Talhão 01',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'Carlos Dias',
        'Data da marcação': '20/07/2026',
        'Área': 'Talhão 01',
        'Referência de localização': 'Centro do talhão, grade 25x25',
        'Tipo de marcação': 'Amostragem',
        'Descrição': 'Amostragem de solo para análise pré-plantio',
        'Cor no mapa': '#22C55E',
        'Quantidade': '12',
        'Safra': '2026/2027',
        'Variedade / cultura': 'Soja',
        'Semana da safra': '2',
        'Funcionário': 'Maria Souza',
        'Centro de custo': 'Centro Agrícola',
      },
    ),
  ],
  'compras-animais': [
    PrototypeRecord(
      id: 'compra-animal-1',
      title: 'Fazenda Boa Vista',
      description: '36 novilhas · 12/08/2026',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'João Oliveira',
        'Espécie': 'Bovino',
        'Documento': 'NF 008421',
        // fidelidade-campos (onda 5): o bloco financeiro required de
        // `/movement-purchases`, que a consulta passou a documentar.
        'Forma de pagamento': 'Parcelado',
        'Total de produtos (R\$)': '198.400,00',
        'Frete (R\$)': '4.200,00',
        'Outros valores (R\$)': '0,00',
        'Desconto (R\$)': '2.600,00',
        // fidelidade-esteira (onda 10): categoria/quantidade/valor unitário
        // saíram do cabeçalho — vivem só em "Itens da compra" (dump real:
        // `item_movement_purchases`), não em `movement_purchases`.
        'Vendedor': 'Corretora Campo Alto',
        'Itens da compra': '2 item(ns)',
        'Parcelas': '3 item(ns)',
      },
    ),
  ],
  'apartacao': [
    PrototypeRecord(
      id: 'apartacao-1',
      title: 'Lote Recria 02',
      description: 'Peso · Lote Engorda 05 · 28 animais',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'Carlos Dias',
        'Critério': 'Peso',
        'Destino': 'Lote Engorda 05',
        'Quantidade': '28',
        'Data': '15/08/2026',
      },
    ),
  ],
  // fidelidade-campos (onda 16 — visualização de abas): as 8 funcionalidades
  // operacionais abaixo declaram `steps` no catálogo funcional
  // (`functional_catalog.dart`) mas não tinham nenhum registro manual
  // semeado — a lista caía inteiramente na amostra genérica de
  // `_recordsWithMinimumSample` (só "Fazenda"/"Situação"/"Atualização"), sem
  // nenhum dado real para mostrar nas abas do registro. Dado sintético,
  // coerente entre si e com os mocks já usados no módulo — nenhum copiado de
  // banco de produção. Ver `mapped_feature_screen.dart`, `_recordFieldGroups`.
  'sanitario': [
    PrototypeRecord(
      id: 'sanitario-1',
      title: 'Vacinação Lote Recria 02',
      description: 'Vacinação · Lote Recria 02 · 05/08/2026',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'Maria Souza',
        'Lote': 'Lote Recria 02',
        'Data do manejo': '05/08/2026',
        'Tipo de manejo': 'Vacinação',
        'Produto / procedimento': 'Vacina Aftosa',
        'Controle por tempo (carência)': 'Não',
        'Observação': 'Aplicação em massa antes da soltura no piquete.',
        'Animais alvo': '84 item(ns)',
        'Itens de estoque': '1 item(ns)',
        'Mão de obra': '2 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'sanitario-2',
      title: 'Vermifugação Lote Engorda 05',
      description: 'Vermifugação · Lote Engorda 05 · 18/08/2026',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Carlos Dias',
        'Lote': 'Lote Engorda 05',
        'Data do manejo': '18/08/2026',
        'Tipo de manejo': 'Vermifugação',
        'Produto / procedimento': 'Vermífugo Injetável',
        'Controle por tempo (carência)': 'Sim',
        'Observação': 'Carência de 21 dias antes do abate — lote sinalizado.',
        'Animais alvo': '126 item(ns)',
        'Itens de estoque': '1 item(ns)',
        'Mão de obra': '3 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'sanitario-3',
      title: 'Exame de casco Lote Matrizes 01',
      description: 'Exame · Lote Matrizes 01 · 02/09/2026',
      status: PrototypeRecordStatus.scheduled,
      details: {
        'Responsável': 'João Oliveira',
        'Lote': 'Lote Matrizes 01',
        'Data do manejo': '02/09/2026',
        'Tipo de manejo': 'Exame',
        'Produto / procedimento': 'Exame de casco',
        'Controle por tempo (carência)': 'Não',
        'Observação': 'Inspeção de rotina antes da estação de monta.',
        'Animais alvo': '212 item(ns)',
        'Itens de estoque': '0 item(ns)',
        'Mão de obra': '1 item(ns)',
      },
    ),
  ],
  'pastagens': [
    PrototypeRecord(
      id: 'pastagens-1',
      title: 'Adubação de cobertura Pasto Norte',
      description: 'Manutenção de pastagem · Pasto Norte · 03/08/2026',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'João Oliveira',
        'Data do manejo': '03/08/2026',
        'Local do manejo': 'Área',
        'Área': 'Pasto Norte',
        'Operação': 'Manutenção de pastagem',
        'Atividade': 'Adubação de cobertura',
        'Lote': 'Lote Engorda 05',
        'Armazém de insumos': 'Armazém A',
        'Armazém de produção': 'Depósito B',
        'Observação': 'Adubação de cobertura após rotação do lote.',
        'Máquinas / Equipamentos': '1 item(ns)',
        'Insumos': '2 item(ns)',
        'Produção': '0 item(ns)',
        'Serviços': '1 item(ns)',
        'Ocorrências': '0 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'pastagens-2',
      title: 'Rotação de piquete 03',
      description: 'Vedação / diferimento · Piquete 03 · 15/08/2026',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Carlos Dias',
        'Data do manejo': '15/08/2026',
        'Local do manejo': 'Piquete',
        'Piquete': 'Piquete 03',
        'Operação': 'Vedação / diferimento',
        'Atividade': 'Rotação de piquete',
        'Lote': 'Lote Recria 02',
        'Armazém de insumos': 'Depósito B',
        'Armazém de produção': 'Armazém A',
        'Observação':
            'Piquete vedado para rebrota antes da próxima entrada.',
        'Máquinas / Equipamentos': '0 item(ns)',
        'Insumos': '0 item(ns)',
        'Produção': '1 item(ns)',
        'Serviços': '0 item(ns)',
        'Ocorrências': '1 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'pastagens-3',
      title: 'Roçada Talhão 02',
      description: 'Formação de pastagem · Talhão 02 · 25/08/2026',
      status: PrototypeRecordStatus.scheduled,
      details: {
        'Responsável': 'Maria Souza',
        'Data do manejo': '25/08/2026',
        'Local do manejo': 'Área',
        'Área': 'Talhão 02',
        'Operação': 'Formação de pastagem',
        'Atividade': 'Roçada',
        'Lote': 'Lote Matrizes 01',
        'Animal': 'Brinco 4471',
        'Armazém de insumos': 'Armazém A',
        'Armazém de produção': 'Armazém A',
        'Observação': 'Roçada mecanizada antes da sobressemeadura.',
        'Máquinas / Equipamentos': '2 item(ns)',
        'Insumos': '1 item(ns)',
        'Produção': '0 item(ns)',
        'Serviços': '0 item(ns)',
        'Ocorrências': '0 item(ns)',
      },
    ),
  ],
  'registrar-animal': [
    PrototypeRecord(
      id: 'registrar-animal-1',
      title: 'Brinco 4471',
      description: 'Bovino · Novilha · 320 kg',
      status: PrototypeRecordStatus.completed,
      details: {
        'Espécie': 'Bovino',
        'Modo de identificação': 'Brinco',
        'Identificação principal': '4471',
        'Categoria': 'Novilha',
        'Raça': 'Nelore',
        'Data de entrada': '10/07/2026',
        'Data de nascimento': '02/01/2025',
        'Quantidade': '1',
        'Mãe': '2210',
        'Pai': 'TOU-018',
        'Peso (kg)': '320',
        'Pelagem': 'Branca',
        'Preço do kg vivo': '32,50',
        'Preço da arroba (vivo)': '292,50',
        'Valor unitário (R\$)': '10.400,00',
        'Unidade animal (UA)': '0,85',
        'Observação': 'Entrada por compra na Fazenda Boa Vista.',
        'Identificações': '2 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'registrar-animal-2',
      title: 'RFID 900012345678901',
      description: 'Bovino · Vaca · 480 kg',
      status: PrototypeRecordStatus.active,
      details: {
        'Espécie': 'Bovino',
        'Modo de identificação': 'RFID',
        'Identificação principal': '900012345678901',
        'Categoria': 'Vaca',
        'Raça': 'Angus',
        'Data de entrada': '15/03/2024',
        'Data de nascimento': '20/11/2021',
        'Quantidade': '1',
        'Mãe': '1187',
        'Pai': 'TOU-018',
        'Previsão de parto': '28/11/2026',
        'Peso (kg)': '480',
        'Pelagem': 'Preta',
        'Preço do kg vivo': '30,00',
        'Preço da arroba (vivo)': '270,00',
        'Valor unitário (R\$)': '14.400,00',
        'Unidade animal (UA)': '1,20',
        'Observação':
            'Matriz prenha, cobertura de monta natural com TOU-018.',
        'Identificações': '3 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'registrar-animal-3',
      title: 'SISBOV 105000123456789',
      description: 'Bovino · Boi · 560 kg',
      status: PrototypeRecordStatus.scheduled,
      details: {
        'Espécie': 'Bovino',
        'Modo de identificação': 'SISBOV',
        'Identificação principal': '105000123456789',
        'Categoria': 'Boi',
        'Raça': 'Nelore',
        'Data de entrada': '02/06/2026',
        'Data de nascimento': '14/02/2023',
        'Quantidade': '1',
        'Peso (kg)': '560',
        'Pelagem': 'Branca',
        'Preço do kg vivo': '31,20',
        'Preço da arroba (vivo)': '280,80',
        'Valor unitário (R\$)': '17.472,00',
        'Unidade animal (UA)': '1,40',
        'Observação': 'Animal comprado adulto — genealogia desconhecida.',
        'Identificações': '1 item(ns)',
      },
    ),
  ],
  'rebanho-inicial': [
    PrototypeRecord(
      id: 'rebanho-inicial-1',
      title: 'Lote Recria 02',
      description: 'Bovino · Novilha · 84 animais',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'Carlos Dias',
        'Data de referência': '01/07/2026',
        'Data de entrada': '01/07/2026',
        'Área / módulo inicial': 'Pasto Norte',
        'Espécie': 'Bovino',
        'Categoria': 'Novilha',
        'Raça': 'Nelore',
        'Quantidade de animais': '84',
        'Modo de identificação': 'Brinco',
        'Peso médio (kg)': '280',
        'Preço do kg vivo': '31,00',
        'Preço da arroba (vivo)': '279,00',
        'Valor unitário (R\$)': '8.680,00',
        'Unidade animal (UA)': '0,75',
        'Identificações': '84 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'rebanho-inicial-2',
      title: 'Lote Matrizes 01',
      description: 'Bovino · Vaca · 212 animais',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Maria Souza',
        'Data de referência': '10/06/2026',
        'Data de entrada': '10/06/2026',
        'Área / módulo inicial': 'Curral 02',
        'Espécie': 'Bovino',
        'Categoria': 'Vaca',
        'Raça': 'Angus',
        'Quantidade de animais': '212',
        'Modo de identificação': 'SISBOV',
        'Peso médio (kg)': '460',
        'Preço do kg vivo': '29,50',
        'Preço da arroba (vivo)': '265,50',
        'Valor unitário (R\$)': '13.570,00',
        'Unidade animal (UA)': '1,15',
        'Mãe': 'Plantel herdado da Fazenda Boa Vista',
        'Pai': 'Plantel herdado da Fazenda Boa Vista',
        'Identificações': '212 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'rebanho-inicial-3',
      title: 'Lote Engorda 05',
      description: 'Bovino · Boi · 126 animais',
      status: PrototypeRecordStatus.scheduled,
      details: {
        'Responsável': 'João Oliveira',
        'Data de referência': '20/08/2026',
        'Data de entrada': '20/08/2026',
        'Área / módulo inicial': 'Curral 02',
        'Espécie': 'Bovino',
        'Categoria': 'Boi',
        'Raça': 'Nelore',
        'Quantidade de animais': '126',
        'Modo de identificação': 'RFID',
        'Peso médio (kg)': '410',
        'Preço do kg vivo': '30,80',
        'Preço da arroba (vivo)': '277,20',
        'Valor unitário (R\$)': '12.628,00',
        'Unidade animal (UA)': '1,05',
        'Identificações': '126 item(ns)',
      },
    ),
  ],
  'monta-natural': [
    PrototypeRecord(
      id: 'monta-natural-1',
      title: 'Acasalamento Lote Matrizes 01',
      description: 'Monta natural · Lote Matrizes 01 · 01/09/2026',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Maria Souza',
        'Data': '01/09/2026',
        'Tipo de acasalamento': 'Monta natural',
        'Tipo de lançamento': 'Por lote',
        'Estação de monta': 'Estação Primavera 2026',
        'Lote de matrizes': 'Lote Matrizes 01',
        'Touro / reprodutor': 'TOU-018',
        'Material reprodutivo':
            'Touro TOU-018 do estoque de material reprodutivo',
        'Touro / sêmen da estação': 'BSS-2026-012',
        'Quantidade de fêmeas': '212',
        'Observação':
            'Monta natural em campo com um touro por 60 fêmeas.',
        'Vacas do acasalamento': '212 item(ns)',
        'Animais (lançamento simplificado)': '0 item(ns)',
        'Animais do protocolo': '0 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'monta-natural-2',
      title: 'Acasalamento IATF Lote Receptoras 03',
      description: 'IATF · Lote Receptoras 03 · 05/09/2026',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'Carlos Dias',
        'Data': '05/09/2026',
        'Tipo de acasalamento': 'IATF',
        'Tipo de lançamento': 'Animal por animal',
        'Estação de monta': 'Estação Primavera 2026',
        'Lote de matrizes': 'Lote Receptoras 03',
        'Touro / reprodutor': 'Sêmen SEM-4471',
        'Material reprodutivo': 'Sêmen Nelore SEM-4471 do estoque',
        'Touro / sêmen da estação': 'BSS-2026-007',
        'Protocolo': 'Protocolo IATF Primavera',
        'Identificação do protocolo': 'PS-2026-003',
        'Quantidade de fêmeas': '64',
        'Observação': 'IATF no D11 conforme protocolo de 11 dias.',
        'Vacas do acasalamento': '64 item(ns)',
        'Animais (lançamento simplificado)': '64 item(ns)',
        'Animais do protocolo': '64 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'monta-natural-3',
      title: 'Acasalamento FIV Lote Matrizes 01',
      description: 'FIV · Lote Matrizes 01 · 12/09/2026',
      status: PrototypeRecordStatus.scheduled,
      details: {
        'Responsável': 'João Oliveira',
        'Data': '12/09/2026',
        'Tipo de acasalamento': 'FIV',
        'Tipo de lançamento': 'Animal por animal',
        'Estação de monta': 'Estação Primavera 2026',
        'Lote de matrizes': 'Lote Matrizes 01',
        'Touro / reprodutor': 'TOU-018',
        'Material reprodutivo': 'Embrião FIV vinculado a TOU-018',
        'Touro / sêmen da estação': 'BSS-2026-012',
        'Protocolo': 'Protocolo FIV Primavera',
        'Identificação do protocolo': 'PF-2026-001',
        'Quantidade de fêmeas': '18',
        'Observação':
            'Transferência de embriões produzidos em laboratório parceiro.',
        'Vacas do acasalamento': '18 item(ns)',
        'Animais (lançamento simplificado)': '0 item(ns)',
        'Animais do protocolo': '18 item(ns)',
      },
    ),
  ],
  'diagnostico-gestacao': [
    PrototypeRecord(
      id: 'diagnostico-gestacao-1',
      title: 'Diagnóstico Lote Matrizes 01',
      description: 'Prenhe · Lote Matrizes 01 · 15/09/2026',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'Maria Souza',
        'Data do diagnóstico': '15/09/2026',
        'Lote': 'Lote Matrizes 01',
        'Veterinário responsável': 'Dr. Rafael Nunes',
        'Técnica de diagnóstico': 'Ultrassonografia',
        'Resultado': 'Prenhe',
        'Dias de gestação': '35',
        'Touro atribuído': 'TOU-018',
        'Quantidade de animais': '198',
        'Animais diagnosticados': '198 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'diagnostico-gestacao-2',
      title: 'Diagnóstico Lote Receptoras 03',
      description: 'Reavaliar · Lote Receptoras 03 · 20/09/2026',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Carlos Dias',
        'Data do diagnóstico': '20/09/2026',
        'Lote': 'Lote Receptoras 03',
        'Veterinário responsável': 'Dra. Camila Rocha',
        'Técnica de diagnóstico': 'Palpação retal',
        'Resultado': 'Reavaliar',
        'Dias de gestação': '18',
        'Touro atribuído': 'BSS-2026-007',
        'Quantidade de animais': '64',
        'Animais diagnosticados': '64 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'diagnostico-gestacao-3',
      title: 'Diagnóstico Lote Engorda 05',
      description: 'Vazia · Lote Engorda 05 · 22/09/2026',
      status: PrototypeRecordStatus.scheduled,
      details: {
        'Responsável': 'João Oliveira',
        'Data do diagnóstico': '22/09/2026',
        'Lote': 'Lote Engorda 05',
        'Veterinário responsável': 'Dr. Rafael Nunes',
        'Técnica de diagnóstico': 'Dosagem hormonal',
        'Resultado': 'Vazia',
        'Dias de gestação': '0',
        'Quantidade de animais': '12',
        'Animais diagnosticados': '12 item(ns)',
      },
    ),
  ],
  'manutencao-frota': [
    PrototypeRecord(
      id: 'manutencao-frota-1',
      title: 'Troca de óleo — Trator John Deere 6110',
      description: 'Preventiva · Trator John Deere 6110 · 10/08/2026',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'Carlos Dias',
        'Veículo / equipamento': 'Trator John Deere 6110',
        'Data prevista': '10/08/2026',
        'Tipo': 'Preventiva',
        'Serviço': 'Troca de óleo — Trator John Deere 6110',
        'Oficina / responsável externo': 'Oficina Mecânica Central',
        'Custo estimado (R\$)': '850,00',
        'Horímetro': '1240',
        'Horas de mão de obra': '3',
        'Observação': 'Revisão dos 1.200h conforme manual do fabricante.',
        'Peças / Insumos': '2 item(ns)',
        'Mão de obra': '1 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'manutencao-frota-2',
      title: 'Reparo do sistema hidráulico — Colheitadeira CR7',
      description: 'Corretiva · Colheitadeira CR7 · 22/08/2026',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'João Oliveira',
        'Veículo / equipamento': 'Colheitadeira CR7',
        'Data prevista': '22/08/2026',
        'Tipo': 'Corretiva',
        'Serviço': 'Reparo do sistema hidráulico',
        'Oficina / responsável externo': 'Assistência Técnica CR Máquinas',
        'Custo estimado (R\$)': '4.200,00',
        'Horímetro': '3180',
        'Horas de mão de obra': '8',
        'Observação':
            'Vazamento identificado na inspeção de pré-colheita.',
        'Peças / Insumos': '3 item(ns)',
        'Mão de obra': '2 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'manutencao-frota-3',
      title: 'Inspeção veicular — Caminhão Boiadeiro',
      description: 'Inspeção · Caminhão Boiadeiro · 05/09/2026',
      status: PrototypeRecordStatus.scheduled,
      details: {
        'Responsável': 'Maria Souza',
        'Veículo / equipamento': 'Caminhão Boiadeiro',
        'Data prevista': '05/09/2026',
        'Tipo': 'Inspeção',
        'Serviço': 'Inspeção veicular anual',
        'Oficina / responsável externo': 'Oficina Mecânica Central',
        'Custo estimado (R\$)': '320,00',
        'Hodômetro': '84500',
        'Horas de mão de obra': '2',
        'Observação':
            'Inspeção obrigatória antes do vencimento do licenciamento.',
        'Peças / Insumos': '0 item(ns)',
        'Mão de obra': '1 item(ns)',
      },
    ),
  ],
  // banco-real (onda 2): dado sintético inspirado nas categorias e na ordem de
  // grandeza reais de `products` (543.983 linhas no dump gbcerne) — nenhum
  // registro copiado do banco de produção. Ver
  // docs/ajustes-banco-real/02-oportunidades-banco-real.md, seção 2.6.
  //
  // fidelidade-esteira (onda 16 — visualização de abas): `details` reescrito
  // com as labels REAIS e completas dos 39 campos das 4 etapas de conteúdo
  // (`Dados básicos`/`Estoque e controle`/`Tributação`/`Reforma tributária` —
  // `functional_catalog.dart`, `consulta-produtos.steps`). As labels antigas
  // ('Unidade'/'Custo médio'/'Preço de mercado', sem o sufixo `(R$)`/`de
  // medida`) não batiam com as reais e a maior parte da Tributação/Reforma
  // tributária não tinha chave nenhuma — as abas correspondentes ficavam
  // vazias ou nem apareciam.
  'consulta-produtos': [
    PrototypeRecord(
      id: 'produto-1',
      title: 'Ração Engorda 18%',
      description: 'Nutrição · kg · custo médio R\$ 2,38/kg',
      status: PrototypeRecordStatus.active,
      details: {
        'Grupo do produto': 'Insumo agropecuário',
        'Categoria': 'Nutrição',
        'Unidade de medida': 'kg',
        'Código de barras': '7891000001018',
        'Código de referência interno': 'REF-RE18-001',
        'Princípio ativo': 'Não aplicável',
        'Controla lote': 'true',
        'É equipamento': 'false',
        'Produto ativo': 'true',
        'Controla estoque': 'true',
        'Permite apontamento': 'true',
        'Armazém padrão': 'Armazém A',
        'Centro de custo padrão': 'Centro Pecuária',
        'Estoque mínimo': '2000',
        'Custo médio (R\$)': '2,38',
        'Último preço de compra (R\$)': '2,42',
        'Preço de compra (R\$)': '2,45',
        'Preço de mercado (R\$)': '2,55',
        'NCM': '2309.90.90 — Preparações para alimentação animal',
        'Categoria financeira': 'Insumos pecuários',
        'CFOP saída — dentro do estado':
            '5102 — Venda de mercadoria dentro do estado',
        'CFOP saída — fora do estado':
            '6102 — Venda de mercadoria fora do estado',
        'CST/CSOSN': '40 — Isenta',
        'CST PIS': '04 — Tributável, alíquota zero',
        'CST COFINS': '04 — Tributável, alíquota zero',
        'CST IPI': '00 — Entrada tributada com alíquota zero',
        '% ICMS': '0',
        '% PIS': '0',
        '% COFINS': '0',
        '% IPI': '0',
        'Origem da mercadoria': '0 — Nacional',
        'CEST': '17.041.00',
        'CST IBS/CBS': '200 — Alíquota reduzida',
        '% IBS (UF)': '4,41',
        '% IBS (Município)': '0,92',
        '% CBS': '2,20',
        'CST Imposto Seletivo': '400 — Imunidade',
        '% Imposto Seletivo': '0',
      },
    ),
    PrototypeRecord(
      id: 'produto-2',
      title: 'Sal Mineral Proteinado',
      description: 'Nutrição · kg · custo médio R\$ 4,90/kg',
      status: PrototypeRecordStatus.active,
      details: {
        'Grupo do produto': 'Insumo agropecuário',
        'Categoria': 'Nutrição',
        'Unidade de medida': 'kg',
        'Código de barras': '7891000002025',
        'Código de referência interno': 'REF-SMP-002',
        'Princípio ativo': 'Não aplicável',
        'Controla lote': 'true',
        'É equipamento': 'false',
        'Produto ativo': 'true',
        'Controla estoque': 'true',
        'Permite apontamento': 'true',
        'Armazém padrão': 'Armazém A',
        'Centro de custo padrão': 'Centro Pecuária',
        'Estoque mínimo': '500',
        'Custo médio (R\$)': '4,90',
        'Último preço de compra (R\$)': '4,95',
        'Preço de compra (R\$)': '5,00',
        'Preço de mercado (R\$)': '5,20',
        'NCM': '2309.90.90 — Preparações para alimentação animal',
        'Categoria financeira': 'Insumos pecuários',
        'CFOP saída — dentro do estado':
            '5102 — Venda de mercadoria dentro do estado',
        'CFOP saída — fora do estado':
            '6102 — Venda de mercadoria fora do estado',
        'CST/CSOSN': '40 — Isenta',
        'CST PIS': '04 — Tributável, alíquota zero',
        'CST COFINS': '04 — Tributável, alíquota zero',
        'CST IPI': '00 — Entrada tributada com alíquota zero',
        '% ICMS': '0',
        '% PIS': '0',
        '% COFINS': '0',
        '% IPI': '0',
        'Origem da mercadoria': '0 — Nacional',
        'CEST': '17.041.01',
        'CST IBS/CBS': '200 — Alíquota reduzida',
        '% IBS (UF)': '4,41',
        '% IBS (Município)': '0,92',
        '% CBS': '2,20',
        'CST Imposto Seletivo': '400 — Imunidade',
        '% Imposto Seletivo': '0',
      },
    ),
    PrototypeRecord(
      id: 'produto-3',
      title: 'Vacina Aftosa',
      description: 'Sanitário · dose · custo médio R\$ 3,10/dose',
      status: PrototypeRecordStatus.active,
      details: {
        'Grupo do produto': 'Insumo agropecuário',
        'Categoria': 'Sanitário',
        'Unidade de medida': 'dose',
        'Código de barras': '7891000003032',
        'Código de referência interno': 'REF-VAC-003',
        'Princípio ativo': 'Vírus inativado da febre aftosa (trivalente)',
        'Controla lote': 'true',
        'É equipamento': 'false',
        'Produto ativo': 'true',
        'Controla estoque': 'true',
        'Permite apontamento': 'true',
        'Armazém padrão': 'Farmácia',
        'Centro de custo padrão': 'Centro Pecuária',
        'Estoque mínimo': '200',
        'Custo médio (R\$)': '3,10',
        'Último preço de compra (R\$)': '3,15',
        'Preço de compra (R\$)': '3,20',
        'Preço de mercado (R\$)': '3,40',
        'NCM': '3004.90.99 — Medicamentos veterinários',
        'Categoria financeira': 'Insumos pecuários',
        'CFOP saída — dentro do estado':
            '5102 — Venda de mercadoria dentro do estado',
        'CFOP saída — fora do estado':
            '6102 — Venda de mercadoria fora do estado',
        'CST/CSOSN': '40 — Isenta',
        'CST PIS': '04 — Tributável, alíquota zero',
        'CST COFINS': '04 — Tributável, alíquota zero',
        'CST IPI': '00 — Entrada tributada com alíquota zero',
        '% ICMS': '0',
        '% PIS': '0',
        '% COFINS': '0',
        '% IPI': '0',
        'Origem da mercadoria':
            '3 — Nacional, conteúdo de importação acima de 40%',
        'CEST': '13.007.00',
        'CST IBS/CBS': '400 — Imunidade',
        '% IBS (UF)': '0',
        '% IBS (Município)': '0',
        '% CBS': '0',
        'CST Imposto Seletivo': '400 — Imunidade',
        '% Imposto Seletivo': '0',
      },
    ),
    PrototypeRecord(
      id: 'produto-4',
      title: 'Vermífugo Injetável',
      description: 'Sanitário · frasco 500ml · custo médio R\$ 68,00',
      status: PrototypeRecordStatus.active,
      details: {
        'Grupo do produto': 'Insumo agropecuário',
        'Categoria': 'Sanitário',
        'Unidade de medida': 'frasco',
        'Código de barras': '7891000004049',
        'Código de referência interno': 'REF-VER-004',
        'Princípio ativo': 'Ivermectina 1% + Clorsulon',
        'Controla lote': 'true',
        'É equipamento': 'false',
        'Produto ativo': 'true',
        'Controla estoque': 'true',
        'Permite apontamento': 'true',
        'Armazém padrão': 'Farmácia',
        'Centro de custo padrão': 'Centro Pecuária',
        'Estoque mínimo': '20',
        'Custo médio (R\$)': '68,00',
        'Último preço de compra (R\$)': '69,50',
        'Preço de compra (R\$)': '70,00',
        'Preço de mercado (R\$)': '74,90',
        'NCM': '3004.90.99 — Medicamentos veterinários',
        'Categoria financeira': 'Insumos pecuários',
        'CFOP saída — dentro do estado':
            '5102 — Venda de mercadoria dentro do estado',
        'CFOP saída — fora do estado':
            '6102 — Venda de mercadoria fora do estado',
        'CST/CSOSN': '40 — Isenta',
        'CST PIS': '04 — Tributável, alíquota zero',
        'CST COFINS': '04 — Tributável, alíquota zero',
        'CST IPI': '00 — Entrada tributada com alíquota zero',
        '% ICMS': '0',
        '% PIS': '0',
        '% COFINS': '0',
        '% IPI': '0',
        'Origem da mercadoria':
            '3 — Nacional, conteúdo de importação acima de 40%',
        'CEST': '13.007.01',
        'CST IBS/CBS': '400 — Imunidade',
        '% IBS (UF)': '0',
        '% IBS (Município)': '0',
        '% CBS': '0',
        'CST Imposto Seletivo': '400 — Imunidade',
        '% Imposto Seletivo': '0',
      },
    ),
    PrototypeRecord(
      id: 'produto-5',
      title: 'Diesel S10',
      description: 'Combustível · L · custo médio R\$ 6,12/L',
      status: PrototypeRecordStatus.active,
      details: {
        'Grupo do produto': 'Combustível e lubrificante',
        'Categoria': 'Combustível',
        'Unidade de medida': 'L',
        'Código de barras': '7891000005056',
        'Código de referência interno': 'REF-DS10-005',
        'Princípio ativo': 'Não aplicável',
        'Controla lote': 'false',
        'É equipamento': 'false',
        'Produto ativo': 'true',
        'Controla estoque': 'true',
        'Permite apontamento': 'true',
        'Armazém padrão': 'Depósito B',
        'Centro de custo padrão': 'Centro Frota',
        'Estoque mínimo': '1000',
        'Custo médio (R\$)': '6,12',
        'Último preço de compra (R\$)': '6,20',
        'Preço de compra (R\$)': '6,25',
        'Preço de mercado (R\$)': '6,35',
        'NCM': '2710.19.21 — Óleo diesel',
        'Categoria financeira': 'Combustíveis',
        'CFOP saída — dentro do estado':
            '5102 — Venda de mercadoria dentro do estado',
        'CFOP saída — fora do estado':
            '6102 — Venda de mercadoria fora do estado',
        'CST/CSOSN': '60 — ICMS cobrado por substituição tributária',
        'CST PIS': '06 — Tributável, alíquota zero (monofásica)',
        'CST COFINS': '06 — Tributável, alíquota zero (monofásica)',
        'CST IPI': '00 — Entrada tributada com alíquota zero',
        '% ICMS': '12',
        '% PIS': '4,21',
        '% COFINS': '19,42',
        '% IPI': '0',
        'Origem da mercadoria': '0 — Nacional',
        'CEST': '06.001.00',
        'CST IBS/CBS': '000 — Tributação integral',
        '% IBS (UF)': '14,10',
        '% IBS (Município)': '3,70',
        '% CBS': '8,80',
        'CST Imposto Seletivo': '000 — Tributação integral',
        '% Imposto Seletivo': '1,00',
      },
    ),
    PrototypeRecord(
      id: 'produto-6',
      title: 'Semente de Braquiária',
      description: 'Agrícola · kg · custo médio R\$ 18,50/kg',
      status: PrototypeRecordStatus.active,
      details: {
        'Grupo do produto': 'Insumo agropecuário',
        'Categoria': 'Agrícola',
        'Unidade de medida': 'kg',
        'Código de barras': '7891000006067',
        'Código de referência interno': 'REF-SEM-006',
        'Princípio ativo': 'Não aplicável',
        'Controla lote': 'true',
        'É equipamento': 'false',
        'Produto ativo': 'true',
        'Controla estoque': 'true',
        'Permite apontamento': 'true',
        'Armazém padrão': 'Armazém A',
        'Centro de custo padrão': 'Centro Agrícola',
        'Estoque mínimo': '300',
        'Custo médio (R\$)': '18,50',
        'Último preço de compra (R\$)': '19,00',
        'Preço de compra (R\$)': '19,20',
        'Preço de mercado (R\$)': '21,00',
        'NCM': '1209.29.00 — Sementes forrageiras',
        'Categoria financeira': 'Insumos agrícolas',
        'CFOP saída — dentro do estado':
            '5101 — Venda de produção do estabelecimento',
        'CFOP saída — fora do estado':
            '6101 — Venda de produção fora do estado',
        'CST/CSOSN': '40 — Isenta',
        'CST PIS': '04 — Tributável, alíquota zero',
        'CST COFINS': '04 — Tributável, alíquota zero',
        'CST IPI': '00 — Entrada tributada com alíquota zero',
        '% ICMS': '0',
        '% PIS': '0',
        '% COFINS': '0',
        '% IPI': '0',
        'Origem da mercadoria': '0 — Nacional',
        'CEST': '09.005.00',
        'CST IBS/CBS': '200 — Alíquota reduzida',
        '% IBS (UF)': '4,41',
        '% IBS (Município)': '0,92',
        '% CBS': '2,20',
        'CST Imposto Seletivo': '400 — Imunidade',
        '% Imposto Seletivo': '0',
      },
    ),
    PrototypeRecord(
      id: 'produto-7',
      title: 'Fertilizante NPK 20-05-20',
      description: 'Agrícola · saca 50 kg · custo médio R\$ 189,00',
      status: PrototypeRecordStatus.active,
      details: {
        'Grupo do produto': 'Insumo agropecuário',
        'Categoria': 'Agrícola',
        'Unidade de medida': 'saca',
        'Código de barras': '7891000007078',
        'Código de referência interno': 'REF-NPK-007',
        'Princípio ativo': 'Não aplicável',
        'Controla lote': 'true',
        'É equipamento': 'false',
        'Produto ativo': 'true',
        'Controla estoque': 'true',
        'Permite apontamento': 'true',
        'Armazém padrão': 'Armazém A',
        'Centro de custo padrão': 'Centro Agrícola',
        'Estoque mínimo': '100',
        'Custo médio (R\$)': '189,00',
        'Último preço de compra (R\$)': '192,00',
        'Preço de compra (R\$)': '195,00',
        'Preço de mercado (R\$)': '205,00',
        'NCM': '3105.20.10 — Adubos NPK',
        'Categoria financeira': 'Insumos agrícolas',
        'CFOP saída — dentro do estado':
            '5102 — Venda de mercadoria dentro do estado',
        'CFOP saída — fora do estado':
            '6102 — Venda de mercadoria fora do estado',
        'CST/CSOSN': '40 — Isenta',
        'CST PIS': '04 — Tributável, alíquota zero',
        'CST COFINS': '04 — Tributável, alíquota zero',
        'CST IPI': '00 — Entrada tributada com alíquota zero',
        '% ICMS': '0',
        '% PIS': '0',
        '% COFINS': '0',
        '% IPI': '0',
        'Origem da mercadoria':
            '5 — Nacional, conteúdo de importação até 40%',
        'CEST': '10.003.00',
        'CST IBS/CBS': '200 — Alíquota reduzida',
        '% IBS (UF)': '4,41',
        '% IBS (Município)': '0,92',
        '% CBS': '2,20',
        'CST Imposto Seletivo': '400 — Imunidade',
        '% Imposto Seletivo': '0',
      },
    ),
    PrototypeRecord(
      id: 'produto-8',
      title: 'Filtro de óleo — trator',
      description: 'Peça de equipamento · unidade · custo médio R\$ 42,00',
      status: PrototypeRecordStatus.active,
      details: {
        'Grupo do produto': 'Peça e equipamento',
        'Categoria': 'Peça de equipamento',
        'Unidade de medida': 'unidade',
        'Código de barras': '7891000008089',
        'Código de referência interno': 'REF-FIL-008',
        'Princípio ativo': 'Não aplicável',
        'Controla lote': 'false',
        'É equipamento': 'false',
        'Produto ativo': 'true',
        'Controla estoque': 'true',
        'Permite apontamento': 'false',
        'Armazém padrão': 'Depósito B',
        'Centro de custo padrão': 'Centro Frota',
        'Estoque mínimo': '10',
        'Custo médio (R\$)': '42,00',
        'Último preço de compra (R\$)': '43,50',
        'Preço de compra (R\$)': '44,00',
        'Preço de mercado (R\$)': '49,90',
        'NCM': '8421.23.00 — Filtros de óleo/combustível para motores',
        'Categoria financeira': 'Manutenção e peças',
        'CFOP saída — dentro do estado':
            '5102 — Venda de mercadoria dentro do estado',
        'CFOP saída — fora do estado':
            '6102 — Venda de mercadoria fora do estado',
        'CST/CSOSN': '00 — Tributada integralmente',
        'CST PIS': '01 — Tributável, alíquota básica',
        'CST COFINS': '01 — Tributável, alíquota básica',
        'CST IPI': '50 — Saída tributada',
        '% ICMS': '18',
        '% PIS': '1,65',
        '% COFINS': '7,60',
        '% IPI': '3,25',
        'Origem da mercadoria':
            '2 — Estrangeira, adquirida no mercado interno',
        'CEST': '11.008.00',
        'CST IBS/CBS': '000 — Tributação integral',
        '% IBS (UF)': '14,10',
        '% IBS (Município)': '3,70',
        '% CBS': '8,80',
        'CST Imposto Seletivo': '400 — Imunidade',
        '% Imposto Seletivo': '0',
      },
    ),
  ],
  // banco-real (correção de demonstrabilidade): estas 8 features viraram
  // `readOnly: true` nas Ondas 1/2 (ver docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md)
  // mas não tinham amostra semeada — como o app não cria mais registros para
  // elas, a lista ficava vazia para sempre. Dados sintéticos, coerentes com
  // os campos do catálogo e com os mocks já usados no módulo (nenhum copiado
  // de banco de produção).
  'cadastrar-area': [
    PrototypeRecord(
      id: 'area-1',
      title: 'Talhão 03',
      description: 'Produtiva · 42 ha',
      status: PrototypeRecordStatus.active,
      details: {
        // fidelidade-contrato (onda 2): `AreaType` real é
        // `{Produtiva, Reserva}` — o valor de uso setorial (agricultura,
        // pecuária…) mora em "Atividade", abaixo.
        'Tipo de uso': 'Produtiva',
        'Área total': '42 ha',
        'Área produtiva': '38 ha',
        'Área não produtiva': '4 ha',
        'Unidade': 'ha',
        'Localização': 'Setor Norte',
        'Cultura / cobertura': 'Braquiária',
        // fidelidade-campos (onda 3): campos de `/areas` que a consulta
        // passou a documentar — a amostra mostra o que a tela agora conhece.
        // fidelidade-esteira (onda 11): hex real (`areas.color` no banco
        // real é `varchar(7)` livre, não um rótulo de enum).
        'Cor no mapa': '#22C55E',
        'Matrícula': '18.472',
        'Atividade': 'Agricultura',
        'Proprietário': 'Fazenda Cerne S/A',
        'Ativa': 'Sim',
        // fidelidade-campos (onda 9 — re-auditoria 11/09): `farm_uuid` e
        // `coordinates`, os dois residuais de `/areas`.
        'Fazenda': 'Fazenda São Pedro',
        'Coordenadas (polígono)': 'Desenhado no mapa · 6 vértices',
        'Infraestrutura': '3 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'area-2',
      title: 'Piquete 07',
      description: 'Produtiva · 18 ha',
      status: PrototypeRecordStatus.active,
      details: {
        'Tipo de uso': 'Produtiva',
        'Área total': '18 ha',
        'Carga animal (UA/ha)': '1,8',
        'Unidade': 'ha',
        'Localização': 'Setor Leste',
        'Cor no mapa': '#F59E0B',
        'Atividade': 'Pecuária',
        'Área de recreio': 'Não',
        'Ativa': 'Sim',
        'Fazenda': 'Fazenda São Pedro',
        'Coordenadas (polígono)': 'Desenhado no mapa · 4 vértices',
      },
    ),
  ],
  'formulacoes': [
    PrototypeRecord(
      id: 'formulacao-1',
      title: 'Ração Engorda 18%',
      description: '1.000 kg · R\$ 2.380,00',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'João Oliveira',
        'Ativo': 'Sim',
        'Quantidade de referência': '1.000',
        'Unidade de medida': 'kg',
        'Tipo': 'Porcentagem',
        'Custo por kg (R\$)': '2,38',
        'Custo estimado (R\$)': '2.380,00',
        'Data da formulação': '2026-08-11',
        'Unidade da matéria-prima': 'kg',
        'Objetivo': 'Ganho de peso na terminação',
      },
    ),
    PrototypeRecord(
      id: 'formulacao-2',
      title: 'Sal Mineral Proteinado',
      description: '500 kg · R\$ 2.450,00',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Maria Souza',
        'Ativo': 'Sim',
        'Quantidade de referência': '500',
        'Unidade de medida': 'kg',
        'Tipo': 'Unidade',
        'Custo por kg (R\$)': '4,90',
        'Custo estimado (R\$)': '2.450,00',
      },
    ),
  ],
  'batidas': [
    PrototypeRecord(
      id: 'batida-1',
      title: 'Ração Engorda 18%',
      description: '1.000 kg previsto · 985 kg realizado',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'João Oliveira',
        'Tipo': 'Formulação',
        'Armazém de destino': 'Armazém A',
        'Quantidade prevista': '1.000',
        'Quantidade realizada': '985',
        'Unidade de medida': 'kg',
        // fidelidade-campos (onda 5): os três required de `/diet-beats`.
        'Dieta': 'Dieta Terminação',
        'Vagão / equipamento': 'Vagão Misturador 01',
        'Data da batida': '2026-08-30',
        'Itens da batida': '5 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'batida-2',
      title: 'Sal Mineral Proteinado',
      description: '500 kg previsto · 500 kg realizado',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'Carlos Dias',
        'Tipo': 'Estoque',
        'Armazém de destino': 'Depósito B',
        'Quantidade prevista': '500',
        'Quantidade realizada': '500',
        'Unidade de medida': 'kg',
      },
    ),
  ],
  'lote-animais': [
    PrototypeRecord(
      id: 'lote-animais-1',
      title: 'Lote Recria 02',
      description: 'Bovino · Novilha',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Carlos Dias',
        'Espécie': 'Bovino',
        'Categoria': 'Novilha',
        'Data de formação': '2026-07-14',
        'Parâmetro de peso': 'Médio',
        'Animais do lote': '84 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'lote-animais-2',
      title: 'Lote Engorda 05',
      description: 'Bovino · Boi',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'João Oliveira',
        'Espécie': 'Bovino',
        'Categoria': 'Boi',
        'Data de formação': '2026-08-02',
        'Curral de confinamento': 'Curral 02',
        'Parâmetro de peso': 'Pesado',
        'Animais do lote': '126 item(ns)',
      },
    ),
  ],
  'estacao-monta': [
    PrototypeRecord(
      id: 'estacao-monta-1',
      title: 'Estação Primavera 2026',
      description: 'IATF · 01/09/2026 a 30/11/2026',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Maria Souza',
        'Código': 'EM-2026-01',
        'Data do lançamento': '2026-08-20',
        'Data de início': '01/09/2026',
        'Data de término': '30/11/2026',
        'Método principal': 'IATF',
      },
    ),
  ],
  // fidelidade-campos (onda 4): `lotes-reproducao` volta como consulta
  // somente leitura e, como as demais `readOnly`, precisa de amostra semeada
  // — o app não cria registro para ela, então sem isto a lista ficaria vazia
  // para sempre. Dado sintético, coerente com os mocks do módulo.
  'lotes-reproducao': [
    PrototypeRecord(
      id: 'lotes-reproducao-1',
      title: 'Lote Matrizes 01',
      description: 'Matrizes · Estação Primavera 2026 · 2026-08-22',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Maria Souza',
        'Código': 'LR-2026-014',
        'Data do vínculo': '2026-08-22',
        // fidelidade-campos (onda 9 — re-auditoria 11/09): `description`,
        // único required residual de `/breeding-batches`.
        'Descrição': 'Vínculo das matrizes à IATF da estação Primavera',
        'Estação de monta': 'Estação Primavera 2026',
        'Lote': 'Lote Matrizes 01',
        'Finalidade': 'Matrizes',
        'Quantidade de animais': '212',
        // fidelidade-contrato (onda 4): `batch_uuids[]`, a cardinalidade real
        // do vínculo.
        'Lotes vinculados': '1 item(ns) · Lote Matrizes 01',
      },
    ),
    PrototypeRecord(
      id: 'lotes-reproducao-2',
      title: 'Lote Receptoras 03',
      description: 'Receptoras · Estação Primavera 2026 · 2026-08-25',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Carlos Dias',
        'Código': 'LR-2026-015',
        'Data do vínculo': '2026-08-25',
        'Descrição': 'Receptoras aptas para transferência de embrião',
        'Estação de monta': 'Estação Primavera 2026',
        'Lote': 'Lote Receptoras 03',
        'Finalidade': 'Receptoras',
        'Quantidade de animais': '64',
        'Lotes vinculados': '1 item(ns) · Lote Receptoras 03',
      },
    ),
  ],
  'material-reprodutivo': [
    PrototypeRecord(
      id: 'material-reprodutivo-1',
      title: 'SEM-4471',
      description: 'Sêmen · Nelore · 120 doses',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Maria Souza',
        'Tipo de recurso': 'Sêmen',
        'Raça': 'Nelore',
        'Fornecedor / origem': 'Central de Genética Boa Vista',
        'Quantidade disponível': '120',
        'Código': 'BSS-2026-007',
        'Data do lançamento': '2026-08-18',
        'Descrição': 'Partida de sêmen Nelore para a estação de primavera',
        'Estação de monta': 'Estação Primavera 2026',
        'Produtos (armazém e sêmen)': '2 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'material-reprodutivo-2',
      title: 'TOU-018',
      description: 'Touro · Angus · 1 unidade',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'João Oliveira',
        'Tipo de recurso': 'Touro',
        'Raça': 'Angus',
        'Fornecedor / origem': 'Fazenda São Pedro',
        'Quantidade disponível': '1',
      },
    ),
  ],
  'protocolos-estacao': [
    PrototypeRecord(
      id: 'protocolo-estacao-1',
      title: 'Protocolo IATF Primavera',
      description: 'IATF · Estação Primavera 2026 · 01/09/2026',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Maria Souza',
        'Estação de monta': 'Estação Primavera 2026',
        'Tipo': 'IATF',
        'Data de início': '01/09/2026',
        'Código': 'PS-2026-003',
        'Descrição': 'Protocolo de 11 dias com implante e IATF no D11',
        'Etapas do protocolo': '6 item(ns)',
      },
    ),
  ],
  // banco-real (Onda 1): "Vendas" subiu para decisão ADM — cliente, valor e
  // condição de pagamento são decisão comercial (ver
  // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1). A tela não declara
  // `fields` (mesmo padrão de `minhas-os`), então a amostra usa apenas
  // `details` livres.
  'vendas': [
    PrototypeRecord(
      id: 'venda-1',
      title: 'Frigorífico Vale Verde',
      description: '42 bois · R\$ 210.000,00 · 10/08/2026',
      status: PrototypeRecordStatus.completed,
      details: {
        'Cliente': 'Frigorífico Vale Verde',
        'Quantidade': '42 bois',
        'Valor total': 'R\$ 210.000,00',
        'Condição de pagamento': '28 dias',
        'Data': '10/08/2026',
      },
    ),
    PrototypeRecord(
      id: 'venda-2',
      title: 'Pecuária Santa Fé',
      description: '15 novilhas · R\$ 67.500,00 · 22/08/2026',
      status: PrototypeRecordStatus.completed,
      details: {
        'Cliente': 'Pecuária Santa Fé',
        'Quantidade': '15 novilhas',
        'Valor total': 'R\$ 67.500,00',
        'Condição de pagamento': 'À vista',
        'Data': '22/08/2026',
      },
    ),
  ],
};

class PrototypeRecordsState {
  const PrototypeRecordsState({
    this.recordsByFeature = const {},
    this.nextId = 100,
  });

  final Map<String, List<PrototypeRecord>> recordsByFeature;
  final int nextId;

  List<PrototypeRecord> recordsFor(String featureId) =>
      recordsByFeature[featureId] ?? const [];

  PrototypeRecordsState copyWith({
    Map<String, List<PrototypeRecord>>? recordsByFeature,
    int? nextId,
  }) {
    return PrototypeRecordsState(
      recordsByFeature: recordsByFeature ?? this.recordsByFeature,
      nextId: nextId ?? this.nextId,
    );
  }
}

final prototypeRecordsProvider =
    NotifierProvider<PrototypeRecordsNotifier, PrototypeRecordsState>(
      PrototypeRecordsNotifier.new,
    );

class PrototypeRecordsNotifier extends Notifier<PrototypeRecordsState> {
  @override
  PrototypeRecordsState build() =>
      const PrototypeRecordsState(recordsByFeature: initialPrototypeRecords);

  PrototypeRecord addRecord({
    required String featureId,
    required String title,
    required String description,
    required PrototypeRecordStatus status,
    Map<String, String> details = const {},
  }) {
    final created = PrototypeRecord(
      id: '$featureId-${state.nextId}',
      title: title,
      description: description,
      status: status,
      details: Map.unmodifiable(details),
    );
    final current = state.recordsFor(featureId);
    state = state.copyWith(
      nextId: state.nextId + 1,
      recordsByFeature: {
        ...state.recordsByFeature,
        featureId: [created, ...current],
      },
    );
    return created;
  }

  /// Substitui um registro existente pelos dados revisados — a contraparte de
  /// [addRecord] para a edição operacional de um registro já gravado. Mantém
  /// o `id` e a posição na lista; se o `id` não existir mais (removido em
  /// outra aba), a edição é descartada silenciosamente.
  PrototypeRecord? updateRecord({
    required String featureId,
    required String id,
    required String title,
    required String description,
    required PrototypeRecordStatus status,
    Map<String, String> details = const {},
  }) {
    final current = state.recordsFor(featureId);
    final index = current.indexWhere((record) => record.id == id);
    if (index == -1) return null;

    final updated = PrototypeRecord(
      id: id,
      title: title,
      description: description,
      status: status,
      details: Map.unmodifiable(details),
    );
    final next = [...current];
    next[index] = updated;
    state = state.copyWith(
      recordsByFeature: {...state.recordsByFeature, featureId: next},
    );
    return updated;
  }

  void seed(Map<String, List<PrototypeRecord>> recordsByFeature) {
    state = state.copyWith(
      recordsByFeature: {
        for (final entry in recordsByFeature.entries)
          entry.key: List.unmodifiable(entry.value),
      },
    );
  }

  void clear() => state = const PrototypeRecordsState();
}
