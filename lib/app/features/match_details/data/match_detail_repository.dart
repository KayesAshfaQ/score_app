import 'package:shared/shared.dart';

import '../../../core/networks/dio_client.dart';

class MatchDetailRepository {
  final DioClient dioClient;

  MatchDetailRepository({required this.dioClient});

  Future<MatchModel> getMatchDetail(int matchId) async {
    final data = await dioClient.get('/matches/$matchId');
    return MatchModel.fromJson(data as Map<String, dynamic>);
  }
}
