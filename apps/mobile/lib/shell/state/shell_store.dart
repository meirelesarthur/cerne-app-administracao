import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Store do Shell — espelha `shellStore.ts` (spec §7.3). Estado de nível superapp,
/// tudo em memória (sem persistência local, restrição do protótipo).

class UserProfile {
  const UserProfile({required this.name, required this.initials});

  final String name;
  final String initials;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.detail,
    required this.time,
    required this.read,
  });

  final String id;
  final String moduleId;
  final String title;
  final String detail;
  final String time;
  final bool read;

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    moduleId: moduleId,
    title: title,
    detail: detail,
    time: time,
    read: read ?? this.read,
  );
}

const _mockNotifications = [
  AppNotification(
    id: 'n1',
    moduleId: 'fazendas',
    title: 'Pesagem registrada',
    detail: 'Lote 42 · Fazenda São Pedro',
    time: 'há 5 min',
    read: false,
  ),
  AppNotification(
    id: 'n2',
    moduleId: 'credito',
    title: 'Crédito pré-aprovado',
    detail: 'R\$ 480.000,00 disponíveis',
    time: 'há 1 h',
    read: false,
  ),
  AppNotification(
    id: 'n3',
    moduleId: 'fazendas',
    title: 'NF-e processada',
    detail: 'Entrada de insumos conferida',
    time: 'há 3 h',
    read: false,
  ),
  AppNotification(
    id: 'n4',
    moduleId: 'bank',
    title: 'Pagamento agendado',
    detail: 'Fornecedor Agropecuária Vale',
    time: 'ontem',
    read: true,
  ),
  // banco-real (onda 2): tipos de notificação inspirados nos alertas mais
  // frequentes do dump gbcerne (estoque abaixo do mínimo, aprovação de compra
  // pendente, vencimento de protocolo sanitário) — dado sintético, não copiado
  // do banco de produção. Ambas marcadas como lidas para preservar o
  // `unreadCount` já coberto por `shell_store_test.dart`. Ver
  // docs/ajustes-banco-real/02-oportunidades-banco-real.md.
  AppNotification(
    id: 'n5',
    moduleId: 'fazendas',
    title: 'Estoque abaixo do mínimo',
    detail: 'Sal Mineral Proteinado · Armazém A',
    time: 'ontem',
    read: true,
  ),
  AppNotification(
    id: 'n6',
    moduleId: 'fazendas',
    title: 'Cotação pendente de aprovação',
    detail: 'Solicitação de compra #4821 · Suprimentos',
    time: 'há 2 dias',
    read: true,
  ),
];

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
    return const ShellState(
      user: UserProfile(name: 'Silvio Ventura', initials: 'SV'),
      notifications: _mockNotifications,
      isOnline: true,
      balanceHidden: false,
      menuOpen: false,
    );
  }

  void setOnline(bool value) => state = state.copyWith(isOnline: value);

  void toggleOnline() => state = state.copyWith(isOnline: !state.isOnline);

  void toggleBalanceHidden() =>
      state = state.copyWith(balanceHidden: !state.balanceHidden);

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
