import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/shell/state/shell_store.dart';

void main() {
  group('ShellStoreNotifier', () {
    test('estado inicial', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(shellStoreProvider);
      expect(state.isOnline, isTrue);
      expect(state.menuOpen, isFalse);
      expect(state.balanceHidden, isFalse);
      expect(state.unreadCount, 3);
    });

    test('toggleOnline/toggleBalanceHidden/toggleMenu invertem o estado', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(shellStoreProvider.notifier);

      notifier.toggleOnline();
      expect(container.read(shellStoreProvider).isOnline, isFalse);

      notifier.toggleBalanceHidden();
      expect(container.read(shellStoreProvider).balanceHidden, isTrue);

      notifier.toggleMenu();
      expect(container.read(shellStoreProvider).menuOpen, isTrue);
      notifier.closeMenu();
      expect(container.read(shellStoreProvider).menuOpen, isFalse);
    });

    test('markAllRead zera o unreadCount', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(shellStoreProvider.notifier);

      notifier.markAllRead();
      expect(container.read(shellStoreProvider).unreadCount, 0);
    });
  });
}
