import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

class CompetitionsRepository {
  final FirebaseFirestore firestore;

  CompetitionsRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of matches for a specific competition code.
  Stream<List<MatchModel>> watchCompetitionMatches(String code) {
    return firestore
        .collection('matches')
        .where('competitionCode', isEqualTo: code.toUpperCase())
        .snapshots()
        .map((snapshot) {
      final matches = snapshot.docs
          .map((doc) => MatchModel.fromFirestore(doc.data()))
          .toList();
      matches.sort((a, b) => a.utcDate.compareTo(b.utcDate));
      return matches;
    });
  }

  /// One-time fetch of competition matches.
  Future<List<MatchModel>> getCompetitionMatches(String code) async {
    final snapshot = await firestore
        .collection('matches')
        .where('competitionCode', isEqualTo: code.toUpperCase())
        .get();

    final matches = snapshot.docs
        .map((doc) => MatchModel.fromFirestore(doc.data()))
        .toList();

    matches.sort((a, b) => a.utcDate.compareTo(b.utcDate));
    return matches;
  }
}
