import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import '../data/match_detail_repository.dart';

class MatchDetailProvider extends ChangeNotifier {
  final MatchDetailRepository repository;

  bool _isLoading = false;
  String? _errorMessage;
  MatchModel? _match;
  StreamSubscription<MatchModel?>? _matchSubscription;
  int? _currentMatchId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MatchModel? get match => _match;

  MatchDetailProvider({required this.repository});

  void subscribeToMatchDetail(int matchId) {
    if (_currentMatchId == matchId && _match != null) return;
    _currentMatchId = matchId;
    _matchSubscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _matchSubscription = repository.watchMatchDetail(matchId).listen(
      (data) {
        _match = data;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> fetchMatchDetail(int matchId) async {
    subscribeToMatchDetail(matchId);
  }

  @override
  void dispose() {
    _matchSubscription?.cancel();
    super.dispose();
  }
}
