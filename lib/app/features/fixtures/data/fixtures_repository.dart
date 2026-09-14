import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

class FixturesRepository {
  final FirebaseFirestore firestore;

  FixturesRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Realtime stream of matches for a given date.
  /// Automatically emits whenever Cloud Functions updates Firestore.
  Stream<List<MatchModel>> watchMatchesByDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    return firestore
        .collection('matches')
        .where('dateKey', isEqualTo: dateStr)
        .snapshots()
        .map((snapshot) {
      final matches = snapshot.docs
          .map((doc) => MatchModel.fromFirestore(doc.data()))
          .toList();

      // Sort client-side by utcDate so no composite index is strictly required
      matches.sort((a, b) => a.utcDate.compareTo(b.utcDate));
      return matches;
    });
  }

  /// One-time fetch of matches for a given date.
  Future<List<MatchModel>> getMatchesByDate(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    final snapshot = await firestore
        .collection('matches')
        .where('dateKey', isEqualTo: dateStr)
        .get();

    final matches = snapshot.docs
        .map((doc) => MatchModel.fromFirestore(doc.data()))
        .toList();

    matches.sort((a, b) => a.utcDate.compareTo(b.utcDate));
    return matches;
  }
}
