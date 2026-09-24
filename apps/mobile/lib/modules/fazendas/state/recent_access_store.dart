import 'package:flutter_riverpod/flutter_riverpod.dart';

const farmRecentAccessLimit = 10;

class FarmRecentAccessEntry {
  const FarmRecentAccessEntry({required this.functionId, required this.route});

  final String functionId;
  final String route;
}

class FarmRecentAccessState {
  const FarmRecentAccessState({
    this.entriesByFarmId = const <String, List<FarmRecentAccessEntry>>{},
  });

  final Map<String, List<FarmRecentAccessEntry>> entriesByFarmId;

  List<FarmRecentAccessEntry> forFarm(String farmId) =>
      entriesByFarmId[farmId] ?? const <FarmRecentAccessEntry>[];
}

final farmRecentAccessProvider =
    NotifierProvider<FarmRecentAccessNotifier, FarmRecentAccessState>(
      FarmRecentAccessNotifier.new,
    );

class FarmRecentAccessNotifier extends Notifier<FarmRecentAccessState> {
  @override
  FarmRecentAccessState build() => const FarmRecentAccessState();

  void record(String farmId, String functionId, String route) {
    if (farmId.isEmpty || functionId.isEmpty || route.isEmpty) return;

    final current = state.forFarm(farmId);
    if (current.isNotEmpty &&
        current.first.functionId == functionId &&
        current.first.route == route) {
      return;
    }

    final recent = [
      FarmRecentAccessEntry(functionId: functionId, route: route),
      for (final entry in current)
        if (entry.functionId != functionId) entry,
    ].take(farmRecentAccessLimit).toList(growable: false);

    state = FarmRecentAccessState(
      entriesByFarmId: {...state.entriesByFarmId, farmId: recent},
    );
  }
}
