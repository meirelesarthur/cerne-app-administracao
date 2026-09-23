import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/ordem_servico/mocks.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/models.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/widgets.dart';
import 'package:cerne_app/ui/ui.dart';

OrdemServico _os(String id) => ordensServico.firstWhere((o) => o.id == id);

void main() {
  group('osDuracao', () {
    test('minutos, horas com minutos, horas cheias e dias', () {
      expect(osDuracao(const Duration(minutes: 40)), '40 min');
      expect(osDuracao(const Duration(hours: 2, minutes: 5)), '2h05');
      expect(osDuracao(const Duration(hours: 3)), '3h');
      expect(osDuracao(const Duration(days: 1, hours: 2)), '1 dia');
      expect(osDuracao(const Duration(days: 4)), '4 dias');
    });
  });

  group('osSituacao — precedência da linha de situação do card', () {
    test('em execução mostra há quanto tempo', () {
      final agora = DateTime(2026, 9, 15, 10);
      final os = _os('os-2198').copyWith(
        dataInicio: agora.subtract(const Duration(hours: 2, minutes: 15)),
      );
      final s = osSituacao(os, agora);
      expect(s.label, 'Em execução há 2h15');
      expect(s.tone, AppStatusCardTone.info);
    });

    test('pausada mostra tempo e motivo', () {
      final os = _os('os-2185');
      final agora = os.dataPausa!.add(const Duration(minutes: 40));
      final s = osSituacao(os, agora);
      expect(s.label, startsWith('Pausada há 40 min · '));
      expect(s.label, contains(os.motivoPausa!));
      expect(s.tone, AppStatusCardTone.warning);
    });

    test('aguardando mostra há quanto tempo foi liberada', () {
      final s = osSituacao(_os('os-2201'), DateTime(2026, 9, 15, 10));
      expect(s.label, 'Liberada há 2 dias');
      expect(s.tone, AppStatusCardTone.neutral);
    });

    test('vence hoje e vence amanhã passam na frente do tempo de execução', () {
      final os = _os('os-2198');
      expect(osSituacao(os, DateTime(2026, 9, 18, 9)).label, 'Vence hoje');
      expect(osSituacao(os, DateTime(2026, 9, 17, 9)).label, 'Vence amanhã');
    });

    test('atrasada passa na frente de tudo que está em andamento', () {
      final agora = DateTime(2026, 9, 23, 9);
      final execucao = osSituacao(_os('os-2198'), agora);
      expect(execucao.label, 'Atrasada há 5 dias');
      expect(execucao.tone, AppStatusCardTone.danger);
      // Pausada e atrasada: o atraso é o que pede atenção primeiro.
      expect(osSituacao(_os('os-2185'), agora).label, 'Atrasada há 3 dias');
    });

    test('entregue no prazo e com atraso', () {
      final noPrazo = osSituacao(_os('os-2170'), DateTime(2026, 9, 23));
      expect(noPrazo.label, 'Entregue em 10/09/2026 · no prazo');
      expect(noPrazo.tone, AppStatusCardTone.success);

      final atrasada = _os('os-2198').copyWith(
        status: OrdemServicoStatus.entregue,
        dataEntrega: DateTime(2026, 9, 20, 15),
      );
      final s = osSituacao(atrasada, DateTime(2026, 9, 23));
      expect(s.label, 'Entregue em 20/09/2026 · 2 dias de atraso');
      expect(s.tone, AppStatusCardTone.danger);
    });

    test('cancelada e refeita trazem o motivo', () {
      final cancelada = _os('os-2201').copyWith(
        status: OrdemServicoStatus.cancelada,
        motivoCancelamento: 'Serviço terceirizado',
      );
      expect(
        osSituacao(cancelada, DateTime(2026, 9, 23)).label,
        'Cancelada · Serviço terceirizado',
      );
      expect(
        osSituacao(_os('os-2160'), DateTime(2026, 9, 23)).label,
        startsWith('Refeita · '),
      );
    });
  });
}
