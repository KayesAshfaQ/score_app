import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import '../data/competitions_repository.dart';

class CompetitionsProvider extends ChangeNotifier {
  final CompetitionsRepository repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<MatchModel> _matches = [];
  StreamSubscription<List<MatchModel>>? _matchesSubscription;
  String? _currentCode;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MatchModel> get matches => _matches;

  CompetitionsProvider({required this.repository});

  void subscribeToCompetitionMatches(String code) {
    if (_currentCode == code && _matches.isNotEmpty) return;
    _currentCode = code;
    _matchesSubscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _matchesSubscription =
        repository.watchCompetitionMatches(code).listen(
      (data) {
        _matches = data;
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

  Future<void> fetchCompetitionMatches(String code) async {
    subscribeToCompetitionMatches(code);
  }

  @override
  void dispose() {
    _matchesSubscription?.cancel();
    super.dispose();
  }
}
