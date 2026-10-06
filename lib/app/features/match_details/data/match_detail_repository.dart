import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

class MatchDetailRepository {
  final FirebaseFirestore firestore;

  MatchDetailRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of single match details.
  Stream<MatchModel?> watchMatchDetail(int matchId) {
    return firestore
        .collection('matches')
        .doc(matchId.toString())
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return MatchModel.fromFirestore(doc.data()!);
    });
  }

  /// One-time fetch of match details.
  Future<MatchModel?> getMatchDetail(int matchId) async {
    final doc =
        await firestore.collection('matches').doc(matchId.toString()).get();
    if (!doc.exists || doc.data() == null) return null;
    return MatchModel.fromFirestore(doc.data()!);
  }
}
