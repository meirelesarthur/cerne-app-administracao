import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Perfil único da sessão demonstrativa do CERNE ADM. O app é exclusivo da
/// Administração — o perfil Operacional vive no app irmão (CERNE Operação).
enum UserAccessProfile { administration }

extension UserAccessProfileLabels on UserAccessProfile {
  String get label => 'Administração';

  String get roleLabel => 'Administrador';

  String get homeRoute => '/fazendas/visao-geral';

  /// Primeira tela depois do login. A Home administrativa está temporariamente
  /// desativada; o gestor entra direto na Visão geral de Fazendas.
  String get landingRoute => '/fazendas/visao-geral';
}

class PrototypeSessionState {
  const PrototypeSessionState._({this.profile});

  const PrototypeSessionState.signedOut() : this._();

  const PrototypeSessionState.signedIn(UserAccessProfile profile)
    : this._(profile: profile);

  final UserAccessProfile? profile;

  bool get isAuthenticated => profile != null;
}

final prototypeSessionProvider =
    NotifierProvider<PrototypeSessionNotifier, PrototypeSessionState>(
      PrototypeSessionNotifier.new,
    );

class PrototypeSessionNotifier extends Notifier<PrototypeSessionState> {
  @override
  PrototypeSessionState build() => const PrototypeSessionState.signedOut();

  void loginAs(UserAccessProfile profile) {
    state = PrototypeSessionState.signedIn(profile);
  }

  void logout() {
    state = const PrototypeSessionState.signedOut();
  }
}
