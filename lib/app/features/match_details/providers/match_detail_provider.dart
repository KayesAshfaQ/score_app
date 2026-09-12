import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import '../data/match_detail_repository.dart';

class MatchDetailProvider extends ChangeNotifier {
  final MatchDetailRepository repository;

  bool _isLoading = false;
  String? _errorMessage;
  MatchModel? _match;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MatchModel? get match => _match;

  MatchDetailProvider({required this.repository});

  Future<void> fetchMatchDetail(int matchId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _match = await repository.getMatchDetail(matchId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
