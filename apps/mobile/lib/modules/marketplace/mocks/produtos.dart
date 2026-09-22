import '../../../ui/ui.dart';

/// Mocks determinísticos do catálogo do Marketplace — espelha
/// `src/modules/marketplace/mocks/produtos.ts`.

/// Categoria de insumo/produto do Marketplace, com ícone para chips e cards.
class Categoria {
  const Categoria({required this.id, required this.label, required this.icon});

  final String id;
  final String label;
  final AppIconData icon;
}

/// Par chave-valor de especificação técnica, exibido na página do produto (PDP).
class Especificacao {
  const Especificacao({required this.label, required this.valor});

  final String label;
  final String valor;
}

/// Item de catálogo do Marketplace (dados determinísticos, protótipo).
class Produto {
  const Produto({
    required this.id,
    required this.nome,
    required this.vendedor,
    required this.preco,
    required this.unidade,
    required this.categoriaId,
    this.freteGratis = false,
    this.desconto,
    required this.descricao,
    required this.especificacoes,
  });

  final String id;
  final String nome;
  final String vendedor;

  /// valor já formatado em BRL, ex.: 'R$ 189,90'
  final String preco;

  /// unidade de venda, ex.: 'saca 60kg'
  final String unidade;
  final String categoriaId;
  final bool freteGratis;

  /// percentual promocional formatado, ex.: '-12%'
  final String? desconto;

  /// texto descritivo mockado, exibido na PDP
  final String descricao;

  /// lista chave-valor de especificações técnicas, exibida na PDP
  final List<Especificacao> especificacoes;
}

const List<Categoria> categorias = [
  Categoria(id: 'sementes', label: 'Sementes', icon: AppIcons.sprout),
  Categoria(
    id: 'fertilizantes',
    label: 'Fertilizantes',
    icon: AppIcons.flaskConical,
  ),
  Categoria(id: 'defensivos', label: 'Defensivos', icon: AppIcons.shieldCheck),
  Categoria(
    id: 'nutricao-animal',
    label: 'Nutrição animal',
    icon: AppIcons.beef,
  ),
  Categoria(id: 'maquinas', label: 'Máquinas', icon: AppIcons.tractor),
  Categoria(id: 'pecas', label: 'Peças', icon: AppIcons.wrench),
];

const List<Produto> produtos = [
  Produto(
    id: 'prod-1',
    nome: 'Semente de soja Intacta',
    vendedor: 'AgroSeed Distribuidora',
    preco: 'R\$ 489,90',
    unidade: 'saca 40kg',
    categoriaId: 'sementes',
    freteGratis: true,
    descricao:
        'Semente de soja com tecnologia Intacta, alta germinação e resistência a lagartas. Indicada para plantio em solos de média a alta fertilidade, com ciclo precoce.',
    especificacoes: [
      Especificacao(label: 'Ciclo', valor: 'Precoce (105-115 dias)'),
      Especificacao(label: 'Germinação', valor: 'mín. 90%'),
      Especificacao(label: 'Tratamento de semente', valor: 'Sim, industrial'),
      Especificacao(label: 'Validade', valor: '12 meses após tratamento'),
    ],
  ),
  Produto(
    id: 'prod-2',
    nome: 'Ureia 45% granulada',
    vendedor: 'Fertil Nordeste',
    preco: 'R\$ 149,90',
    unidade: 'saca 60kg',
    categoriaId: 'fertilizantes',
    desconto: '-18%',
    descricao:
        'Fertilizante nitrogenado granulado de alta concentração, indicado para adubação de cobertura em grandes culturas e pastagens.',
    especificacoes: [
      Especificacao(label: 'Teor de nitrogênio', valor: '45%'),
      Especificacao(label: 'Granulometria', valor: '2-4 mm'),
      Especificacao(label: 'Origem', valor: 'Nacional'),
      Especificacao(label: 'Armazenamento', valor: 'Local seco e coberto'),
    ],
  ),
  Produto(
    id: 'prod-3',
    nome: 'Herbicida sistêmico pós-emergente',
    vendedor: 'DefendAgro',
    preco: 'R\$ 312,00',
    unidade: 'L',
    categoriaId: 'defensivos',
    desconto: '-12%',
    descricao:
        'Herbicida sistêmico de ação pós-emergente, com absorção rápida via folhas indicado para controle de plantas daninhas de folha larga e estreita.',
    especificacoes: [
      Especificacao(
        label: 'Classe toxicológica',
        valor: 'III - medianamente tóxico',
      ),
      Especificacao(label: 'Modo de ação', valor: 'Sistêmico foliar'),
      Especificacao(label: 'Formulação', valor: 'Concentrado solúvel'),
      Especificacao(label: 'Carência', valor: '30 dias'),
    ],
  ),
  Produto(
    id: 'prod-4',
    nome: 'Ração confinamento 30kg',
    vendedor: 'NutriBoi Alimentos',
    preco: 'R\$ 98,50',
    unidade: 'saca 30kg',
    categoriaId: 'nutricao-animal',
    freteGratis: true,
    descricao:
        'Ração balanceada para bovinos em fase de confinamento, formulada para ganho de peso acelerado com alta conversão alimentar.',
    especificacoes: [
      Especificacao(label: 'Proteína bruta', valor: 'mín. 18%'),
      Especificacao(label: 'Fase indicada', valor: 'Terminação'),
      Especificacao(
        label: 'Composição',
        valor: 'Milho, farelo de soja, minerais',
      ),
      Especificacao(label: 'Validade', valor: '6 meses'),
    ],
  ),
  Produto(
    id: 'prod-5',
    nome: 'Óleo diesel S10 (1000L)',
    vendedor: 'Petro Rural Combustíveis',
    preco: 'R\$ 6.190,00',
    unidade: 'un',
    categoriaId: 'maquinas',
    descricao:
        'Diesel S10 com baixo teor de enxofre para máquinas e implementos agrícolas, entrega programada direto na propriedade em tanque próprio.',
    especificacoes: [
      Especificacao(label: 'Volume', valor: '1000 L'),
      Especificacao(label: 'Teor de enxofre', valor: 'máx. 10 mg/kg'),
      Especificacao(label: 'Entrega', valor: 'Caminhão-tanque próprio'),
      Especificacao(label: 'Prazo de entrega', valor: '2-4 dias úteis'),
    ],
  ),
  Produto(
    id: 'prod-6',
    nome: 'Arame liso 500m',
    vendedor: 'Cercas & Arames Sul',
    preco: 'R\$ 279,90',
    unidade: 'un',
    categoriaId: 'pecas',
    freteGratis: true,
    descricao:
        'Arame liso galvanizado de alta resistência, indicado para cercas de divisa e contenção de pastagens.',
    especificacoes: [
      Especificacao(label: 'Comprimento', valor: '500 m'),
      Especificacao(label: 'Revestimento', valor: 'Galvanizado a fogo'),
      Especificacao(label: 'Bitola', valor: '14 (2,11 mm)'),
      Especificacao(label: 'Resistência à tração', valor: 'mín. 480 kgf/mm²'),
    ],
  ),
];

/// IDs de produtos favoritados (mock determinístico, protótipo).
const List<String> favoritosIds = ['prod-1', 'prod-4'];

/// Banner promocional em destaque na home do Marketplace.
class OfertaDestaque {
  static const titulo = 'Semana do Plantio';
  static const subtitulo = 'Fertilizantes com até 18% off + frete grátis';
  static const cta = 'Ver ofertas';
}
