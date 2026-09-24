import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Dado de um ícone do sistema — **duas origens, uma API**.
///
/// **Hugeicons** ([AppIconData.glyph]) responde por quase tudo. O pacote não
/// entrega `IconData`: entrega a estrutura JSON de um SVG (lista de pares
/// `[tag, atributos]`) que `HugeIcon` monta em runtime. É exatamente isso que
/// permite sobrescrever a espessura do traço — o set gratuito nasce em 1.5 e o
/// app inteiro desenha em [AppSize.iconStroke] (1.2). Uma fonte de ícones
/// congelaria a espessura no binário e não teria essa folga.
///
/// **Vetores autorais** ([AppIconData.asset]) cobrem o que o set não tem. Não
/// existe bovino no Hugeicons gratuito, e pecuária, confinamento, agricultura
/// e frota têm desenho próprio do GB CERNE: vivem em `assets/icons/` como
/// contorno vetorizado
/// (espessura desenhada na geometria) e chegam à tela pela mesma [AppIcon].
/// Quem consome não sabe — nem precisa saber — de qual origem o ícone veio.
///
/// A classe existe para que o tipo do pacote não vaze na assinatura de nenhum
/// componente do catálogo (Lei 2): componentes e telas falam `AppIconData`.
class AppIconData {
  /// Entrada do set Hugeicons *stroke-rounded*.
  const AppIconData.glyph(List<List<dynamic>> data)
    : glyph = data,
      asset = null,
      visualScale = 1;

  /// Vetor autoral do GB CERNE, por caminho de asset.
  const AppIconData.asset(String path, {this.visualScale = 1})
    : asset = path,
      glyph = null;

  /// Estrutura JSON do SVG quando a origem é o pacote; nula para vetor autoral.
  final List<List<dynamic>>? glyph;

  /// Caminho do asset quando a origem é autoral; nulo para ícone do pacote.
  final String? asset;

  /// Ajuste óptico para vetores cuja geometria parece menor no mesmo slot.
  final double visualScale;
}

/// Catálogo semântico de ícones do GB CERNE — **fonte única** (Lei 2).
///
/// Toda a aplicação desenha a partir daqui; nenhum arquivo fora de `lib/ui/`
/// importa `package:hugeicons/hugeicons.dart` nem conhece `assets/icons/`.
/// Trocar o desenho de um conceito é uma linha neste arquivo, não uma varredura
/// por 98 telas.
///
/// O mapa de origem (Lucide → Hugeicons, 132 entradas validadas contra os 5 159
/// nomes do pacote) está versionado em `scripts/icon-map.json` e justificado em
/// `docs/ESTEIRA-PADRAO-GLOBAL-HUGEICONS.md`, §3.4.
class AppIcons {
  AppIcons._();

  // --- Setas e navegacao direcional ----------------------------------------
  static const AppIconData arrowRight = AppIconData.glyph(
    HugeIcons.strokeRoundedArrowRight01,
  );

  /// Agricultura — desenho da marca.
  static const AppIconData agriculturaAutoral = AppIconData.asset(
    'assets/icons/agricultura.svg',
  );

  /// Gestão de frota — desenho da marca.
  static const AppIconData frotaAutoral = AppIconData.asset(
    'assets/icons/frota.svg',
  );

  // Selos quadrados da tela de resultado (AppSuccessPanel): um por situação.
  static const AppIconData checkSquare = AppIconData.glyph(
    HugeIcons.strokeRoundedCheckmarkSquare02,
  );
  static const AppIconData editSquare = AppIconData.glyph(
    HugeIcons.strokeRoundedPencilEdit02,
  );
  static const AppIconData deleteSquare = AppIconData.glyph(
    HugeIcons.strokeRoundedDelete02,
  );
  static const AppIconData alertSquare = AppIconData.glyph(
    HugeIcons.strokeRoundedAlertSquare,
  );
  static const AppIconData cancelSquare = AppIconData.glyph(
    HugeIcons.strokeRoundedCancelSquare,
  );
  static const AppIconData infoSquare = AppIconData.glyph(
    HugeIcons.strokeRoundedInformationSquare,
  );
  static const AppIconData cloudSaved = AppIconData.glyph(
    HugeIcons.strokeRoundedCloudSavingDone01,
  );
  static const AppIconData arrowLeft = AppIconData.glyph(
    HugeIcons.strokeRoundedArrowLeft01,
  );
  static const AppIconData arrowUpRight = AppIconData.glyph(
    HugeIcons.strokeRoundedArrowUpRight01,
  );
  static const AppIconData arrowDownLeft = AppIconData.glyph(
    HugeIcons.strokeRoundedArrowDownLeft01,
  );
  static const AppIconData arrowLeftRight = AppIconData.glyph(
    HugeIcons.strokeRoundedArrowDataTransferHorizontal,
  );
  // banco-real (correção de identidade): usava o mesmo glifo 01 de
  // arrowRight/arrowLeft — dois nomes distintos apontando para o mesmo
  // `AppIconData` const (Dart canoniza literais const estruturalmente
  // iguais em um único objeto). Isso quebra a suposição de
  // `findAppIcon`/`test/helpers/app_icon_finder.dart` de que "ícones
  // distintos nunca colidem": uma tela com o botão Voltar (arrowLeft) e a
  // paginação (chevronLeft) ao mesmo tempo tinha 2 matches para o mesmo
  // `find`, ambíguo em `getRect`/`tester.tap`. Variante 02 é visualmente
  // próxima (mesma família seta-esquerda/direita do HugeIcons), mas um
  // objeto const genuinamente diferente. Ver
  // `mapped_feature_screen_test.dart` e `app_icon_test.dart`.
  static const AppIconData chevronRight = AppIconData.glyph(
    HugeIcons.strokeRoundedArrowRight02,
  );
  static const AppIconData chevronLeft = AppIconData.glyph(
    HugeIcons.strokeRoundedArrowLeft02,
  );
  static const AppIconData chevronDown = AppIconData.glyph(
    HugeIcons.strokeRoundedArrowDown01,
  );
  static const AppIconData chevronUp = AppIconData.glyph(
    HugeIcons.strokeRoundedArrowUp01,
  );

  // --- Estado, validacao e feedback ----------------------------------------
  static const AppIconData check = AppIconData.glyph(
    HugeIcons.strokeRoundedTick02,
  );
  static const AppIconData checkCircle2 = AppIconData.glyph(
    HugeIcons.strokeRoundedCheckmarkCircle02,
  );
  static const AppIconData circle = AppIconData.glyph(
    HugeIcons.strokeRoundedCircle,
  );
  static const AppIconData circleAlert = AppIconData.glyph(
    HugeIcons.strokeRoundedAlertCircle,
  );
  static const AppIconData alertCircle = AppIconData.glyph(
    HugeIcons.strokeRoundedAlertCircle,
  );
  static const AppIconData triangleAlert = AppIconData.glyph(
    HugeIcons.strokeRoundedAlert02,
  );
  static const AppIconData alertTriangle = AppIconData.glyph(
    HugeIcons.strokeRoundedAlert02,
  );
  static const AppIconData shieldAlert = AppIconData.glyph(
    HugeIcons.strokeRoundedShieldEnergy,
  );
  static const AppIconData info = AppIconData.glyph(
    HugeIcons.strokeRoundedInformationCircle,
  );
  static const AppIconData helpCircle = AppIconData.glyph(
    HugeIcons.strokeRoundedHelpCircle,
  );
  static const AppIconData x = AppIconData.glyph(
    HugeIcons.strokeRoundedCancel01,
  );
  static const AppIconData plus = AppIconData.glyph(
    HugeIcons.strokeRoundedAdd01,
  );
  static const AppIconData minus = AppIconData.glyph(
    HugeIcons.strokeRoundedMinusSign,
  );
  static const AppIconData frown = AppIconData.glyph(
    HugeIcons.strokeRoundedSad01,
  );
  static const AppIconData partyPopper = AppIconData.glyph(
    HugeIcons.strokeRoundedParty,
  );

  // --- Chrome do app: busca, menu, sessao ----------------------------------
  static const AppIconData menu = AppIconData.glyph(
    HugeIcons.strokeRoundedMenu01,
  );
  static const AppIconData moreHorizontal = AppIconData.glyph(
    HugeIcons.strokeRoundedMoreHorizontal,
  );
  static const AppIconData ellipsis = AppIconData.glyph(
    HugeIcons.strokeRoundedMoreHorizontal,
  );

  /// Overflow da top bar do padrão global — o `DotsThreeVertical` do Figma
  /// (54349:2085). Vertical de propósito: o horizontal já é o "mais opções"
  /// de linha de lista, e as duas leituras coexistem nas telas de cadastro.
  static const AppIconData moreVertical = AppIconData.glyph(
    HugeIcons.strokeRoundedMoreVertical,
  );
  static const AppIconData search = AppIconData.glyph(
    HugeIcons.strokeRoundedSearch01,
  );
  static const AppIconData searchX = AppIconData.glyph(
    HugeIcons.strokeRoundedSearchRemove,
  );

  static const AppIconData filter = AppIconData.glyph(
    HugeIcons.strokeRoundedFilterHorizontal,
  );
  static const AppIconData slidersHorizontal = AppIconData.glyph(
    HugeIcons.strokeRoundedFilterHorizontal,
  );
  static const AppIconData layoutGrid = AppIconData.glyph(
    HugeIcons.strokeRoundedDashboardSquare01,
  );
  static const AppIconData layoutDashboard = AppIconData.glyph(
    HugeIcons.strokeRoundedDashboardSpeed01,
  );
  static const AppIconData layers = AppIconData.glyph(
    HugeIcons.strokeRoundedLayers01,
  );
  static const AppIconData bell = AppIconData.glyph(
    HugeIcons.strokeRoundedNotification02,
  );
  static const AppIconData bellRing = AppIconData.glyph(
    HugeIcons.strokeRoundedNotificationSquare,
  );
  static const AppIconData bellOff = AppIconData.glyph(
    HugeIcons.strokeRoundedNotificationOff02,
  );
  static const AppIconData settings = AppIconData.glyph(
    HugeIcons.strokeRoundedSettings01,
  );
  static const AppIconData logOut = AppIconData.glyph(
    HugeIcons.strokeRoundedLogout01,
  );
  static const AppIconData user = AppIconData.glyph(
    HugeIcons.strokeRoundedUser,
  );
  static const AppIconData users = AppIconData.glyph(
    HugeIcons.strokeRoundedUserGroup,
  );
  static const AppIconData eye = AppIconData.glyph(HugeIcons.strokeRoundedView);
  static const AppIconData eyeOff = AppIconData.glyph(
    HugeIcons.strokeRoundedViewOff,
  );
  static const AppIconData lock = AppIconData.glyph(
    HugeIcons.strokeRoundedSquareLock01,
  );
  static const AppIconData shield = AppIconData.glyph(
    HugeIcons.strokeRoundedShield01,
  );
  static const AppIconData shieldCheck = AppIconData.glyph(
    HugeIcons.strokeRoundedCheckmarkBadge01,
  );
  static const AppIconData home = AppIconData.glyph(
    HugeIcons.strokeRoundedHome01,
  );

  // --- Financeiro: Banking, Credito e indicadores --------------------------
  static const AppIconData wallet = AppIconData.glyph(
    HugeIcons.strokeRoundedWallet01,
  );
  static const AppIconData landmark = AppIconData.glyph(
    HugeIcons.strokeRoundedBank,
  );
  static const AppIconData creditCard = AppIconData.glyph(
    HugeIcons.strokeRoundedCreditCard,
  );
  static const AppIconData creditCardAccept = AppIconData.glyph(
    HugeIcons.strokeRoundedCreditCardAccept,
  );
  static const AppIconData cash = AppIconData.glyph(
    HugeIcons.strokeRoundedCash02,
  );
  static const AppIconData handCoins = AppIconData.glyph(
    HugeIcons.strokeRoundedHandCoins,
  );
  static const AppIconData receipt = AppIconData.glyph(
    HugeIcons.strokeRoundedInvoice01,
  );
  static const AppIconData calculator = AppIconData.glyph(
    HugeIcons.strokeRoundedCalculator,
  );
  static const AppIconData trendingUp = AppIconData.glyph(
    HugeIcons.strokeRoundedChartUp,
  );
  static const AppIconData trendingDown = AppIconData.glyph(
    HugeIcons.strokeRoundedChartDown,
  );
  static const AppIconData lineChart = AppIconData.glyph(
    HugeIcons.strokeRoundedChartLineData01,
  );
  static const AppIconData barChart3 = AppIconData.glyph(
    HugeIcons.strokeRoundedChartAverage,
  );
  static const AppIconData activity = AppIconData.glyph(
    HugeIcons.strokeRoundedActivity01,
  );
  static const AppIconData scale = AppIconData.glyph(
    HugeIcons.strokeRoundedWeightScale01,
  );

  // --- Documentos, tarefas e registro --------------------------------------
  static const AppIconData fileText = AppIconData.glyph(
    HugeIcons.strokeRoundedFile01,
  );
  static const AppIconData fileCheck2 = AppIconData.glyph(
    HugeIcons.strokeRoundedDocumentValidation,
  );
  static const AppIconData fileSignature = AppIconData.glyph(
    HugeIcons.strokeRoundedLegalDocument01,
  );
  static const AppIconData fileBarChart = AppIconData.glyph(
    HugeIcons.strokeRoundedDocumentCode,
  );
  static const AppIconData clipboardList = AppIconData.glyph(
    HugeIcons.strokeRoundedTask01,
  );
  static const AppIconData clipboardCheck = AppIconData.glyph(
    HugeIcons.strokeRoundedTaskDone01,
  );
  static const AppIconData bookOpen = AppIconData.glyph(
    HugeIcons.strokeRoundedBookOpen01,
  );
  static const AppIconData bookSearch = AppIconData.glyph(
    HugeIcons.strokeRoundedBookSearch,
  );
  static const AppIconData listOrdered = AppIconData.glyph(
    HugeIcons.strokeRoundedLeftToRightListNumber,
  );
  static const AppIconData pencil = AppIconData.glyph(
    HugeIcons.strokeRoundedPencilEdit01,
  );
  static const AppIconData copy = AppIconData.glyph(
    HugeIcons.strokeRoundedCopy01,
  );
  static const AppIconData trash2 = AppIconData.glyph(
    HugeIcons.strokeRoundedDelete02,
  );
  static const AppIconData download = AppIconData.glyph(
    HugeIcons.strokeRoundedDownload01,
  );
  static const AppIconData uploadCloud = AppIconData.glyph(
    HugeIcons.strokeRoundedCloudUpload,
  );
  static const AppIconData send = AppIconData.glyph(
    HugeIcons.strokeRoundedSent,
  );
  static const AppIconData saveAll = AppIconData.glyph(
    HugeIcons.strokeRoundedSaveEnergy01,
  );

  // --- Logistica, estoque e marketplace ------------------------------------
  static const AppIconData package = AppIconData.glyph(
    HugeIcons.strokeRoundedPackage,
  );
  static const AppIconData packageCheck = AppIconData.glyph(
    HugeIcons.strokeRoundedPackageDelivered,
  );
  static const AppIconData packageSearch = AppIconData.glyph(
    HugeIcons.strokeRoundedPackageSearch,
  );
  static const AppIconData boxes = AppIconData.glyph(
    HugeIcons.strokeRoundedCube,
  );
  static const AppIconData warehouse = AppIconData.glyph(
    HugeIcons.strokeRoundedWarehouse,
  );
  static const AppIconData inbox = AppIconData.glyph(
    HugeIcons.strokeRoundedInbox,
  );
  static const AppIconData truck = AppIconData.glyph(
    HugeIcons.strokeRoundedTruck,
  );
  static const AppIconData store = AppIconData.glyph(
    HugeIcons.strokeRoundedStore01,
  );
  static const AppIconData store02 = AppIconData.glyph(
    HugeIcons.strokeRoundedStore02,
  );
  static const AppIconData shoppingBag = AppIconData.glyph(
    HugeIcons.strokeRoundedShoppingBag01,
  );
  static const AppIconData shoppingCart = AppIconData.glyph(
    HugeIcons.strokeRoundedShoppingCart01,
  );

  // --- Agro: dominio da operacao de campo ----------------------------------
  static const AppIconData sprout = AppIconData.glyph(
    HugeIcons.strokeRoundedPlant01,
  );
  static const AppIconData leaf = AppIconData.glyph(
    HugeIcons.strokeRoundedLeaf01,
  );
  static const AppIconData wheat = AppIconData.glyph(
    HugeIcons.strokeRoundedWheat,
  );
  static const AppIconData tractor = AppIconData.glyph(
    HugeIcons.strokeRoundedTractor,
  );
  static const AppIconData barns = AppIconData.glyph(
    HugeIcons.strokeRoundedBarns,
  );
  static const AppIconData greenHouse = AppIconData.glyph(
    HugeIcons.strokeRoundedGreenHouse,
  );
  static const AppIconData beef = AppIconData.glyph(
    HugeIcons.strokeRoundedSteak,
  );
  static const AppIconData milk = AppIconData.glyph(
    HugeIcons.strokeRoundedMilkBottle,
  );
  static const AppIconData egg = AppIconData.glyph(HugeIcons.strokeRoundedEgg);
  static const AppIconData heart = AppIconData.glyph(
    HugeIcons.strokeRoundedFavouriteCircle,
  );
  static const AppIconData heartPulse = AppIconData.glyph(
    HugeIcons.strokeRoundedHeartCheck,
  );
  static const AppIconData heartCrack = AppIconData.glyph(
    HugeIcons.strokeRoundedSad02,
  );
  static const AppIconData scanHeart = AppIconData.glyph(
    HugeIcons.strokeRoundedScanHeart,
  );
  static const AppIconData baby = AppIconData.glyph(
    HugeIcons.strokeRoundedBaby01,
  );
  static const AppIconData flaskConical = AppIconData.glyph(
    HugeIcons.strokeRoundedTestTube01,
  );

  // --- Operacao, hardware e conectividade ----------------------------------
  static const AppIconData wrench = AppIconData.glyph(
    HugeIcons.strokeRoundedWrench01,
  );
  static const AppIconData construction = AppIconData.glyph(
    HugeIcons.strokeRoundedRepair,
  );
  static const AppIconData zap = AppIconData.glyph(
    HugeIcons.strokeRoundedFlash,
  );
  static const AppIconData scanLine = AppIconData.glyph(
    HugeIcons.strokeRoundedBarcodeScan,
  );
  static const AppIconData qrCode = AppIconData.glyph(
    HugeIcons.strokeRoundedQrCode,
  );
  static const AppIconData mapPin = AppIconData.glyph(
    HugeIcons.strokeRoundedLocation01,
  );
  static const AppIconData mapPinned = AppIconData.glyph(
    HugeIcons.strokeRoundedLocation04,
  );
  static const AppIconData clock = AppIconData.glyph(
    HugeIcons.strokeRoundedClock01,
  );
  // Ciclo de execução (iniciar/retomar e pausar uma OS).
  static const AppIconData play = AppIconData.glyph(
    HugeIcons.strokeRoundedPlay,
  );
  static const AppIconData pause = AppIconData.glyph(
    HugeIcons.strokeRoundedPause,
  );
  static const AppIconData calendar = AppIconData.glyph(
    HugeIcons.strokeRoundedCalendar03,
  );
  static const AppIconData refreshCw = AppIconData.glyph(
    HugeIcons.strokeRoundedReload,
  );
  static const AppIconData rotateCw = AppIconData.glyph(
    HugeIcons.strokeRoundedRefresh,
  );
  static const AppIconData cloudSync = AppIconData.glyph(
    HugeIcons.strokeRoundedCloudSavingDone01,
  );
  static const AppIconData cloudOff = AppIconData.glyph(
    HugeIcons.strokeRoundedCloudOff,
  );
  static const AppIconData cloudSun = AppIconData.glyph(
    HugeIcons.strokeRoundedSunCloud01,
  );
  static const AppIconData sun = AppIconData.glyph(
    HugeIcons.strokeRoundedSun01,
  );
  static const AppIconData moon = AppIconData.glyph(
    HugeIcons.strokeRoundedMoon02,
  );
  static const AppIconData wifi = AppIconData.glyph(
    HugeIcons.strokeRoundedWifi01,
  );
  static const AppIconData wifiOff = AppIconData.glyph(
    HugeIcons.strokeRoundedWifiOff01,
  );
  static const AppIconData bluetooth = AppIconData.glyph(
    HugeIcons.strokeRoundedBluetooth,
  );
  static const AppIconData battery = AppIconData.glyph(
    HugeIcons.strokeRoundedBatteryMedium01,
  );
  static const AppIconData signal = AppIconData.glyph(
    HugeIcons.strokeRoundedSignal,
  );
  static const AppIconData smartphone = AppIconData.glyph(
    HugeIcons.strokeRoundedSmartPhone01,
  );
  static const AppIconData camera = AppIconData.glyph(
    HugeIcons.strokeRoundedCamera01,
  );
  static const AppIconData phone = AppIconData.glyph(
    HugeIcons.strokeRoundedCall,
  );
  static const AppIconData globe = AppIconData.glyph(
    HugeIcons.strokeRoundedGlobe,
  );
  static const AppIconData radio = AppIconData.glyph(
    HugeIcons.strokeRoundedRadio,
  );
  static const AppIconData headset = AppIconData.glyph(
    HugeIcons.strokeRoundedCustomerSupport,
  );
  static const AppIconData handshake = AppIconData.glyph(
    HugeIcons.strokeRoundedAgreement01,
  );
  static const AppIconData messageCircle = AppIconData.glyph(
    HugeIcons.strokeRoundedMessage01,
  );
  static const AppIconData connect = AppIconData.glyph(
    HugeIcons.strokeRoundedConnect,
  );

  // --- Vetores autorais do GB CERNE --------------------------------------
  // Desenhos próprios, fora do set Hugeicons (§3.3 da esteira): não há bovino
  // no set gratuito, e o confinamento é um desenho da marca.

  /// Confinamento — curral e bovino, desenho da marca.
  static const AppIconData confinamentoAutoral = AppIconData.asset(
    'assets/icons/confinamento.svg',
    visualScale: 1.15,
  );

  /// Pecuária de corte — bovino, desenho da marca.
  static const AppIconData pecuariaAutoral = AppIconData.asset(
    'assets/icons/pecuaria.svg',
  );

  // --- Apelidos de domínio -----------------------------------------------
  // Nomeiam o conceito do agronegócio, não o desenho. São os nomes que as telas
  // de Fazendas e o padrão global do Figma devem usar: quando o desenho de um
  // conceito mudar, muda aqui — e só aqui.

  /// Confinamento — ladrilho da home de Operação.
  static const AppIconData confinamento = confinamentoAutoral;

  /// Pecuária de corte.
  static const AppIconData pecuaria = pecuariaAutoral;

  /// Agricultura.
  static const AppIconData agricultura = agriculturaAutoral;

  /// Ordem de serviço.
  static const AppIconData ordemServico = fileText;

  /// Misturador / batelada de dieta.
  static const AppIconData misturador = flaskConical;

  /// Reprodução.
  static const AppIconData reproducao = scanHeart;

  /// Consultas gerenciais.
  static const AppIconData consultas = bookSearch;

  /// Gestão de frota.
  static const AppIconData gestaoFrota = frotaAutoral;

  /// Sincronizar aplicativo.
  static const AppIconData sincronizar = cloudSync;

  /// Fazenda — seletor de contexto do cabeçalho global.
  static const AppIconData fazenda = barns;

  /// Gestão de estoque / Armazém.
  static const AppIconData estoque = boxes;

  /// Marketplace.
  static const AppIconData marketplace = store02;

  /// Open Finance.
  static const AppIconData openFinance = connect;

  /// Conta GB Banking.
  static const AppIconData banking = landmark;
}

/// Renderizador único de ícone do sistema.
///
/// Substitui `Icon(IconData)` em todo o app. Quatro responsabilidades, todas em
/// um lugar só:
///
/// 1. **Origem.** Resolve `AppIconData` para o desenho certo — glifo do pacote
///    ou vetor autoral — sem que o consumidor saiba qual é.
/// 2. **Espessura.** Aplica [AppSize.iconStroke] (1.2) a todo ícone do pacote.
///    Nenhuma tela passa espessura própria — é o que mantém o traço uniforme.
/// 3. **Herança.** Reproduz o contrato de `Icon`: sem [size]/[color]
///    explícitos, herda do `IconTheme` do contexto (botões, listas e barras já
///    pintam seus ícones por lá), caindo em 24 px e na cor de texto padrão.
/// 4. **Semântica.** [semanticLabel] chega ao leitor de tela; ícone sem rótulo
///    permanece decorativo, como em `Icon`.
///
/// [icon] é nulo-aceitável pelo mesmo motivo que em `Icon`: um slot opcional
/// (`AppEmptyState`, `AppMenuItem`, `AppIllustrationSlot`) reserva a caixa do
/// ícone sem desenhar nada, em vez de obrigar cada chamador a ramificar.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  /// Entrada do catálogo — sempre `AppIcons.xxx`. Nulo reserva a caixa sem
  /// desenhar, como `Icon(null)`.
  final AppIconData? icon;

  /// Aresta do ícone em pixels lógicos. Prefira a escala gerada
  /// (`AppSize.iconXs` … `AppSize.iconXl`). Quando nulo, herda o `IconTheme`.
  final double? size;

  /// Cor do traço. Quando nula, herda o `IconTheme` do contexto.
  final Color? color;

  /// Rótulo para leitores de tela. Nulo mantém o ícone decorativo.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final semantic = Theme.of(context).extension<AppSemanticColors>();
    final resolvedSize = size ?? iconTheme.size ?? AppSize.iconLg;
    final resolvedColor =
        color ??
        iconTheme.color ??
        semantic?.fgDefault ??
        AppColorsLight.fgDefault;

    final Widget? drawing;
    if (icon?.glyph case final data?) {
      drawing = HugeIcon(
        icon: data,
        size: resolvedSize,
        color: resolvedColor,
        strokeWidth: AppSize.iconStroke,
      );
    } else if (icon?.asset case final path?) {
      // O vetor autoral chega pronto em `assets/icons/`, então aqui só resta
      // pintá-lo: `srcIn` recolore preenchimento e traço de uma vez. Ressalva
      // registrada na esteira: os desenhos oficiais são contorno vetorizado,
      // e não traço — a espessura fica fixada no desenho e não segue o token.
      final asset = SvgPicture.asset(
        path,
        // `fit` fica no padrão (`contain`): encaixar o vetor autoral na caixa
        // quadrada do ícone preserva a proporção do desenho, qualquer que
        // seja o viewBox exportado.
        width: resolvedSize,
        height: resolvedSize,
        colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
      );
      drawing = icon!.visualScale == 1
          ? asset
          : Transform.scale(scale: icon!.visualScale, child: asset);
    } else {
      drawing = null;
    }

    final glyph = SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: drawing,
    );

    if (semanticLabel == null) return glyph;
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(child: glyph),
    );
  }
}

WidgetbookComponent buildAppIconWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Icon',
    useCases: [
      WidgetbookUseCase(
        name: 'Escala',
        builder: (context) => Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final entry in const <(String, double)>[
                ('xs', AppSize.iconXs),
                ('sm', AppSize.iconSm),
                ('md', AppSize.iconMd),
                ('lg', AppSize.iconLg),
                ('xl', AppSize.iconXl),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space3,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(AppIcons.tractor, size: entry.$2),
                      const SizedBox(height: AppSpacing.space2),
                      Text(
                        entry.$1,
                        style: const TextStyle(fontSize: AppTypography.sm),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Domínio agro',
        builder: (context) => Center(
          child: Wrap(
            spacing: AppSpacing.space5,
            runSpacing: AppSpacing.space5,
            alignment: WrapAlignment.center,
            children: [
              for (final entry in const <(String, AppIconData)>[
                ('Confinamento', AppIcons.confinamento),
                ('Pecuária', AppIcons.pecuaria),
                ('Agricultura', AppIcons.agricultura),
                ('Ordem de serviço', AppIcons.ordemServico),
                ('Misturador', AppIcons.misturador),
                ('Reprodução', AppIcons.reproducao),
                ('Consultas', AppIcons.consultas),
                ('Gestão de frota', AppIcons.gestaoFrota),
                ('Sincronizar', AppIcons.sincronizar),
              ])
                SizedBox(
                  width: 96,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(entry.$2, size: AppSize.iconLg),
                      const SizedBox(height: AppSpacing.space2),
                      Text(
                        entry.$1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: AppTypography.sm),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Autoral ao lado do set',
        builder: (context) => Center(
          child: Wrap(
            spacing: AppSpacing.space6,
            runSpacing: AppSpacing.space6,
            alignment: WrapAlignment.center,
            children: [
              for (final entry in const <(String, AppIconData)>[
                ('Confinamento (autoral)', AppIcons.confinamento),
                ('Pecuária (autoral)', AppIcons.pecuaria),
                ('Barns (set)', AppIcons.barns),
                ('Tractor (set)', AppIcons.tractor),
              ])
                SizedBox(
                  width: 110,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(entry.$2, size: AppSize.iconXl),
                      const SizedBox(height: AppSpacing.space2),
                      Text(
                        entry.$1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: AppTypography.sm),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}
