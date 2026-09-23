import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../components/sub_page_header.dart';
import '../state/shell_store.dart';

/// Notificações do app — espelha `Notificacoes.tsx`.
///
/// Duas abas: **Novidades** (não lidas) e **Histórico** (já lidas). Cada aba
/// agrupa por dia ("Hoje, 23 de setembro", "Ontem, …") e mostra a mais
/// recente primeiro. Tocar numa notificação a marca como lida — ela passa
/// para o Histórico — e abre a tela de origem quando existe uma.
class NotificacoesPage extends ConsumerStatefulWidget {
  const NotificacoesPage({super.key});

  @override
  ConsumerState<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends ConsumerState<NotificacoesPage> {
  int _aba = 0;

  static const _abas = ['Novidades', 'Histórico'];

  void _abrir(AppNotification n) {
    ref.read(shellStoreProvider.notifier).markRead(n.id);
    final route = n.route;
    if (route != null) context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final notifications = ref.watch(shellStoreProvider).notifications;
    final agora = DateTime.now();
    final novidades = _aba == 0;
    final visiveis = notifications.where((n) => n.read != novidades).toList()
      ..sort((a, b) => b.dataHora.compareTo(a.dataHora));
    final temNaoLidas = notifications.any((n) => !n.read);

    final itens = <Widget>[];
    DateTime? diaAtual;
    for (final n in visiveis) {
      final dia = DateTime(n.dataHora.year, n.dataHora.month, n.dataHora.day);
      if (dia != diaAtual) {
        diaAtual = dia;
        itens.add(
          Padding(
            padding: EdgeInsets.only(
              top: itens.isEmpty ? AppSpacing.space0 : AppSpacing.space4,
              bottom: AppSpacing.space3,
            ),
            child: Text(
              _rotuloDia(dia, agora),
              style: TextStyle(
                fontSize: AppTypography.md,
                fontWeight: AppTypography.weightSemibold,
                color: semantic.fgMuted,
              ),
            ),
          ),
        );
      }
      final visual = _visualDoTipo(n.tipo);
      itens.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space3),
          child: AppNotificationTile(
            icon: visual.icon,
            tone: visual.tone,
            title: n.title,
            message: n.detail,
            timeLabel: _tempoRelativo(n.dataHora, agora),
            unread: !n.read,
            onTap: () => _abrir(n),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            SubPageHeader(
              title: 'Notificações',
              action: novidades && temNaoLidas
                  ? AppButton(
                      variant: AppButtonVariant.ghost,
                      size: AppButtonSize.sm,
                      onPressed: () =>
                          ref.read(shellStoreProvider.notifier).markAllRead(),
                      child: const Text('Marcar lidas'),
                    )
                  : null,
            ),
            Expanded(
              child: AppContentSheet(
                padded: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.space4,
                        AppSpacing.space4,
                        AppSpacing.space4,
                        AppSpacing.space2,
                      ),
                      child: AppSegmentedTabs(
                        labels: _abas,
                        selectedIndex: _aba,
                        onChanged: (i) => setState(() => _aba = i),
                      ),
                    ),
                    Expanded(
                      child: itens.isEmpty
                          ? Center(
                              child: novidades
                                  ? const AppEmptyState(
                                      icon: AppIcons.bellOff,
                                      title: 'Você está em dia',
                                      description:
                                          'Nenhuma notificação nova por aqui.',
                                    )
                                  : const AppEmptyState(
                                      icon: AppIcons.bell,
                                      title: 'Histórico vazio',
                                      description:
                                          'As notificações lidas aparecem aqui.',
                                    ),
                            )
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.space4,
                                AppSpacing.space3,
                                AppSpacing.space4,
                                AppSpacing.space4,
                              ),
                              children: itens,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

({AppIconData icon, AppNotificationTone tone}) _visualDoTipo(
  TipoNotificacao tipo,
) => switch (tipo) {
  TipoNotificacao.lancamento => (
    icon: AppIcons.check,
    tone: AppNotificationTone.success,
  ),
  TipoNotificacao.financeiro => (
    icon: AppIcons.handCoins,
    tone: AppNotificationTone.info,
  ),
  TipoNotificacao.pendencia => (
    icon: AppIcons.fileText,
    tone: AppNotificationTone.warning,
  ),
  TipoNotificacao.alerta => (
    icon: AppIcons.alertTriangle,
    tone: AppNotificationTone.warning,
  ),
  TipoNotificacao.cancelamento => (
    icon: AppIcons.x,
    tone: AppNotificationTone.danger,
  ),
  TipoNotificacao.novidade => (
    icon: AppIcons.bell,
    tone: AppNotificationTone.warning,
  ),
};

const _meses = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

const _diasSemana = [
  'Segunda',
  'Terça',
  'Quarta',
  'Quinta',
  'Sexta',
  'Sábado',
  'Domingo',
];

/// "Hoje, 23 de setembro" · "Ontem, 22 de setembro" · "Sexta, 20 de setembro".
String _rotuloDia(DateTime dia, DateTime agora) {
  final hoje = DateTime(agora.year, agora.month, agora.day);
  final diferenca = hoje.difference(dia).inDays;
  final data = '${dia.day} de ${_meses[dia.month - 1]}';
  if (diferenca == 0) return 'Hoje, $data';
  if (diferenca == 1) return 'Ontem, $data';
  return '${_diasSemana[dia.weekday - 1]}, $data';
}

/// "agora" · "há 5 min" · "há 3 h" · "ontem às 14:20" · "20/09 às 08:15".
String _tempoRelativo(DateTime quando, DateTime agora) {
  final d = agora.difference(quando);
  if (d.inMinutes < 1) return 'agora';
  if (d.inMinutes < 60) return 'há ${d.inMinutes} min';
  final hoje = DateTime(agora.year, agora.month, agora.day);
  final dia = DateTime(quando.year, quando.month, quando.day);
  final hora =
      '${quando.hour.toString().padLeft(2, '0')}:'
      '${quando.minute.toString().padLeft(2, '0')}';
  if (dia == hoje) return 'há ${d.inHours} h';
  if (hoje.difference(dia).inDays == 1) return 'ontem às $hora';
  return '${quando.day.toString().padLeft(2, '0')}/'
      '${quando.month.toString().padLeft(2, '0')} às $hora';
}
