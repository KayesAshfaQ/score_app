import '../../../core/networks/dio_client.dart';
import '../models/standing_model.dart';

class StandingsRepository {
  final DioClient dioClient;

  StandingsRepository({required this.dioClient});

  Future<List<StandingTable>> getStandings(String competitionCode) async {
    final data = await dioClient.get(
      '/competitions/$competitionCode/standings',
    );
    final standingsJson = data['standings'] as List<dynamic>?;
    if (standingsJson == null) return [];

    return standingsJson
        .map((json) => StandingTable.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
