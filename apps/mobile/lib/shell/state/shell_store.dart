import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Store do Shell — espelha `shellStore.ts` (spec §7.3). Estado de nível superapp,
/// tudo em memória (sem persistência local, restrição do protótipo).

class UserProfile {
  const UserProfile({required this.name, required this.initials});

  final String name;
  final String initials;
}

/// Tipo da notificação — decide ícone e cor na tela (`NotificacoesPage`).
enum TipoNotificacao {
  /// Lançamento concluído em campo (pesagem, NF-e conferida).
  lancamento,

  /// Movimento financeiro (crédito aprovado, pagamento agendado).
  financeiro,

  /// Pendência que pede decisão (cotação, aprovação de compra).
  pendencia,

  /// Algo pede atenção (estoque baixo, prazo vencendo).
  alerta,

  /// Cancelamento ou falha.
  cancelamento,

  /// Novidade do aplicativo.
  novidade,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.tipo,
    required this.title,
    required this.detail,
    required this.dataHora,
    required this.read,
    this.route,
  });

  final String id;
  final TipoNotificacao tipo;
  final String title;
  final String detail;

  /// Quando aconteceu — agrupa por dia e vira "há 5 min" na tela.
  final DateTime dataHora;
  final bool read;

  /// Tela aberta ao tocar; sem rota, o toque só marca como lida.
  final String? route;

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    tipo: tipo,
    title: title,
    detail: detail,
    dataHora: dataHora,
    read: read ?? this.read,
    route: route,
  );
}

/// Notificações de exemplo, datadas a partir de [agora] para os grupos
/// "Hoje", "Ontem" e dias anteriores fazerem sentido em qualquer data.
///
/// banco-real (onda 2): tipos inspirados nos alertas mais frequentes do dump
/// gbcerne (estoque abaixo do mínimo, aprovação de compra pendente) — dado
/// sintético. Três não lidas, cobertas por `shell_store_test.dart`.
///
/// As lidas ficam ancoradas no calendário (ontem às 16:40, há três dias às
/// 09:00) e as de hoje nunca recuam para antes da meia-noite: com
/// "agora − 1 dia e 2 h", abrir o app logo depois da meia-noite jogava a
/// notificação para anteontem e o grupo "Ontem" sumia.
List<AppNotification> _mockNotifications(DateTime agora) {
  final hoje = DateTime(agora.year, agora.month, agora.day);
  DateTime deHoje(Duration atras) {
    final t = agora.subtract(atras);
    return t.isBefore(hoje) ? hoje : t;
  }

  DateTime diaAtras(int dias, int hora, int minuto) =>
      DateTime(hoje.year, hoje.month, hoje.day - dias, hora, minuto);

  return [
    AppNotification(
      id: 'n1',
      tipo: TipoNotificacao.lancamento,
      title: 'Pesagem registrada',
      detail: 'Lote 42 · Fazenda São Pedro',
      dataHora: deHoje(const Duration(minutes: 5)),
      read: false,
      route: '/fazendas',
    ),
    AppNotification(
      id: 'n2',
      tipo: TipoNotificacao.financeiro,
      title: 'Crédito pré-aprovado',
      detail: 'R\$ 480.000,00 disponíveis',
      dataHora: deHoje(const Duration(hours: 1)),
      read: false,
      route: '/credito',
    ),
    AppNotification(
      id: 'n3',
      tipo: TipoNotificacao.lancamento,
      title: 'NF-e processada',
      detail: 'Entrada de insumos conferida',
      dataHora: deHoje(const Duration(hours: 3)),
      read: false,
      route: '/fazendas',
    ),
    AppNotification(
      id: 'n4',
      tipo: TipoNotificacao.financeiro,
      title: 'Pagamento agendado',
      detail: 'Fornecedor Agropecuária Vale',
      dataHora: diaAtras(1, 16, 40),
      read: true,
      route: '/bank',
    ),
    AppNotification(
      id: 'n5',
      tipo: TipoNotificacao.alerta,
      title: 'Estoque abaixo do mínimo',
      detail: 'Sal Mineral Proteinado · Armazém A',
      dataHora: diaAtras(1, 13, 40),
      read: true,
      route: '/armazem',
    ),
    AppNotification(
      id: 'n6',
      tipo: TipoNotificacao.pendencia,
      title: 'Cotação pendente de aprovação',
      detail: 'Solicitação de compra #4821 · Suprimentos',
      dataHora: diaAtras(3, 9, 0),
      read: true,
    ),
  ];
}

class ShellState {
  const ShellState({
    required this.user,
    required this.notifications,
    required this.isOnline,
    required this.balanceHidden,
    required this.menuOpen,
  });

  final UserProfile user;
  final List<AppNotification> notifications;

  /// Toggle de dev — simula perda de conexão para demonstrar banners de sync.
  final bool isOnline;

  /// Privacidade do Banking no hub — oculta saldo/valores em todas as telas do Início.
  final bool balanceHidden;

  /// Menu "reveal" global (aba Mais/Menu).
  final bool menuOpen;

  int get unreadCount => notifications.where((n) => !n.read).length;

  ShellState copyWith({
    UserProfile? user,
    List<AppNotification>? notifications,
    bool? isOnline,
    bool? balanceHidden,
    bool? menuOpen,
  }) {
    return ShellState(
      user: user ?? this.user,
      notifications: notifications ?? this.notifications,
      isOnline: isOnline ?? this.isOnline,
      balanceHidden: balanceHidden ?? this.balanceHidden,
      menuOpen: menuOpen ?? this.menuOpen,
    );
  }
}

final shellStoreProvider = NotifierProvider<ShellStoreNotifier, ShellState>(
  ShellStoreNotifier.new,
);

class ShellStoreNotifier extends Notifier<ShellState> {
  @override
  ShellState build() {
    return ShellState(
      user: const UserProfile(name: 'Silvio Ventura', initials: 'SV'),
      notifications: _mockNotifications(DateTime.now()),
      isOnline: true,
      balanceHidden: false,
      menuOpen: false,
    );
  }

  void setOnline(bool value) => state = state.copyWith(isOnline: value);

  void toggleOnline() => state = state.copyWith(isOnline: !state.isOnline);

  void toggleBalanceHidden() =>
      state = state.copyWith(balanceHidden: !state.balanceHidden);

  void markRead(String id) {
    state = state.copyWith(
      notifications: [
        for (final n in state.notifications)
          if (n.id == id) n.copyWith(read: true) else n,
      ],
    );
  }

  void markAllRead() {
    state = state.copyWith(
      notifications: [
        for (final n in state.notifications) n.copyWith(read: true),
      ],
    );
  }

  void openMenu() => state = state.copyWith(menuOpen: true);

  void closeMenu() => state = state.copyWith(menuOpen: false);

  void toggleMenu() => state = state.copyWith(menuOpen: !state.menuOpen);
}
