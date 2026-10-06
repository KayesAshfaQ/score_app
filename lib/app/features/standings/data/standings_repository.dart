import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

class StandingsRepository {
  final FirebaseFirestore firestore;

  StandingsRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Realtime stream of standings for a competition.
  Stream<List<StandingTable>> watchStandings(String competitionCode) {
    return firestore
        .collection('standings')
        .doc(competitionCode.toUpperCase())
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return [];
      final data = doc.data()!;
      final standingsList = data['standings'] as List<dynamic>?;
      if (standingsList == null) return [];

      return standingsList
          .map((json) => StandingTable.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  /// One-time fetch of standings.
  Future<List<StandingTable>> getStandings(String competitionCode) async {
    final doc = await firestore
        .collection('standings')
        .doc(competitionCode.toUpperCase())
        .get();

    if (!doc.exists || doc.data() == null) return [];
    final data = doc.data()!;
    final standingsList = data['standings'] as List<dynamic>?;
    if (standingsList == null) return [];

    return standingsList
        .map((json) => StandingTable.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
