import 'package:shared/shared.dart';
import '../../../core/networks/dio_client.dart';

class CompetitionsRepository {
  final DioClient dioClient;

  CompetitionsRepository({required this.dioClient});

  Future<List<MatchModel>> getCompetitionMatches(String code) async {
    final data = await dioClient.get('/competitions/$code/matches');
    final matches =
        (data['matches'] as List<dynamic>?)
            ?.map((json) => MatchModel.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];
    return matches;
  }
}
