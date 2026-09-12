import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

import '../data/competitions_repository.dart';

class CompetitionsProvider extends ChangeNotifier {
  final CompetitionsRepository repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<MatchModel> _matches = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MatchModel> get matches => _matches;

  CompetitionsProvider({required this.repository});

  Future<void> fetchCompetitionMatches(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _matches = await repository.getCompetitionMatches(code);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
