import '../ui/ui.dart' show AppTransactionItem, AppTransactionDirection;

/// Mocks do Banking — espelha `src/modules/bank/mocks/banking.ts`. Determinísticos
/// (sem `Date.now`). Consumidos pelo hub (widget de conta) e pelo módulo Bank.
/// Em produção viriam do BFF do módulo Bank via contrato de "widget de hub".

class Saldo {
  static const valor = 'R\$ 128.450,32';
  static const conta = 'Conta GB Bank · Ag 0001 · CC 48213-7';
}

class ResumoMes {
  static const entradas = 'R\$ 342.800,00';
  static const saidas = 'R\$ 214.349,68';
}

class CreditoPreaprovado {
  static const valor = 'R\$ 480.000,00';
  static const condicao = 'Custeio safra 25/26 · a partir de 1,29% a.m.';
}

class Cartao {
  static const finalNumero = '4821';
  static const titular = 'ARTHUR M';
  static const bandeira = 'Mastercard';
  static const tipo = 'GB Corp · Crédito';
  static const validade = '08/29';
  static const limiteUsado = 'R\$ 53.500,00';
  static const limiteDisponivel = 'R\$ 96.500,00';
  static const limiteTotal = 'R\$ 150.000,00';
  static const usoPct = 36;
}

class FaixaLimite {
  const FaixaLimite({
    required this.id,
    required this.label,
    required this.usadoPct,
    required this.usado,
    required this.total,
  });

  final String id;
  final String label;
  final int usadoPct;
  final String usado;
  final String total;
}

/// Faixas de limite exibidas em Bank › Limites (mock determinístico).
const List<FaixaLimite> faixasLimite = [
  FaixaLimite(
    id: 'credito',
    label: 'Limite de crédito',
    usadoPct: 36,
    usado: 'R\$ 53.500,00',
    total: 'R\$ 150.000,00',
  ),
  FaixaLimite(
    id: 'pixDia',
    label: 'Pix por transação (diurno)',
    usadoPct: 25,
    usado: 'R\$ 12.380,00',
    total: 'R\$ 50.000,00',
  ),
  FaixaLimite(
    id: 'pixNoite',
    label: 'Pix por transação (noturno)',
    usadoPct: 0,
    usado: 'R\$ 0,00',
    total: 'R\$ 1.000,00',
  ),
  FaixaLimite(
    id: 'saque',
    label: 'Saque diário',
    usadoPct: 12,
    usado: 'R\$ 240,00',
    total: 'R\$ 2.000,00',
  ),
];

/// Conta de origem para os fluxos de pagamento (Pix, transferência).
class ContaOrigem {
  static const label = 'GB Bank · Ag 0001 · CC 48213-7';
  static const saldo = Saldo.valor;
}

class PixContato {
  const PixContato({
    required this.id,
    required this.nome,
    required this.chave,
    required this.tipoChave,
    required this.inicial,
  });

  final String id;
  final String nome;
  final String chave;
  final String tipoChave;
  final String inicial;
}

/// Contatos Pix frequentes (mock) — atalhos na entrada do fluxo Pix.
const List<PixContato> pixContatos = [
  PixContato(
    id: 'p1',
    nome: 'Agropecuária Vale Verde',
    chave: 'contato@valeverde.com.br',
    tipoChave: 'E-mail',
    inicial: 'AV',
  ),
  PixContato(
    id: 'p2',
    nome: 'Cooperativa Cerrado',
    chave: '12.345.678/0001-90',
    tipoChave: 'CNPJ',
    inicial: 'CC',
  ),
  PixContato(
    id: 'p3',
    nome: 'João Batista · arrendamento',
    chave: '(62) 98411-2033',
    tipoChave: 'Telefone',
    inicial: 'JB',
  ),
  PixContato(
    id: 'p4',
    nome: 'Frigorífico Boi Forte',
    chave: '047.882.910-55',
    tipoChave: 'CPF',
    inicial: 'BF',
  ),
];

class BancoOption {
  const BancoOption({required this.value, required this.label});
  final String value;
  final String label;
}

/// Bancos de destino para transferência (mock).
const List<BancoOption> bancos = [
  BancoOption(value: 'gbbank', label: 'GB Bank'),
  BancoOption(value: '001', label: 'Banco do Brasil'),
  BancoOption(value: '237', label: 'Bradesco'),
  BancoOption(value: '341', label: 'Itaú Unibanco'),
  BancoOption(value: '104', label: 'Caixa Econômica'),
  BancoOption(value: '077', label: 'Banco Inter'),
];

const List<AppTransactionItem> transacoes = [
  AppTransactionItem(
    id: 'tx1',
    title: 'Venda de gado · Frigorífico Boi Forte',
    subtitle: 'TED recebida',
    time: 'hoje, 09:12',
    value: 'R\$ 86.400,00',
    direction: AppTransactionDirection.income,
  ),
  AppTransactionItem(
    id: 'tx2',
    title: 'Agropecuária Vale Verde',
    subtitle: 'Pix · insumos',
    time: 'hoje, 08:05',
    value: 'R\$ 12.380,00',
    direction: AppTransactionDirection.expense,
  ),
  AppTransactionItem(
    id: 'tx3',
    title: 'Folha de pagamento',
    subtitle: 'Lote agendado',
    time: 'ontem',
    value: 'R\$ 38.120,50',
    direction: AppTransactionDirection.expense,
  ),
  AppTransactionItem(
    id: 'tx4',
    title: 'Cooperativa Cerrado',
    subtitle: 'Liquidação de soja',
    time: 'ontem',
    value: 'R\$ 154.900,00',
    direction: AppTransactionDirection.income,
  ),
  AppTransactionItem(
    id: 'tx5',
    title: 'Energia rural · CEMIG',
    subtitle: 'Débito automático',
    time: 'seg',
    value: 'R\$ 4.812,90',
    direction: AppTransactionDirection.expense,
  ),
  AppTransactionItem(
    id: 'tx6',
    title: 'Combustível · Posto Trevo',
    subtitle: 'Cartão corporativo',
    time: 'seg',
    value: 'R\$ 2.640,00',
    direction: AppTransactionDirection.expense,
  ),
  AppTransactionItem(
    id: 'tx7',
    title: 'Arrendamento pasto leste',
    subtitle: 'Pix recebido',
    time: 'dom',
    value: 'R\$ 18.500,00',
    direction: AppTransactionDirection.income,
  ),
];
