import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';
import '../config.dart';

class FootballApiService {
  final http.Client client;

  FootballApiService({http.Client? client}) : client = client ?? http.Client();

  Map<String, String> get _headers => {
        'X-Auth-Token': FunctionsConfig.footballDataApiKey,
        'Accept': 'application/json',
      };

  /// Fetches matches across all competitions for a specific date (YYYY-MM-DD).
  Future<List<MatchModel>> fetchMatchesByDate(String dateStr) async {
    final uri = Uri.parse('${FunctionsConfig.baseUrl}/matches?date=$dateStr');
    final response = await client.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('API error (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final matchesJson = data['matches'] as List<dynamic>? ?? [];

    return matchesJson
        .map((m) => MatchModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  /// Fetches standings for a specific competition.
  Future<List<StandingTable>> fetchCompetitionStandings(String competitionCode) async {
    final uri = Uri.parse(
        '${FunctionsConfig.baseUrl}/competitions/$competitionCode/standings');
    final response = await client.get(uri, headers: _headers);

    if (response.statusCode == 404) {
      return [];
    }

    if (response.statusCode != 200) {
      throw Exception('API error (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final standingsJson = data['standings'] as List<dynamic>? ?? [];

    return standingsJson
        .map((s) => StandingTable.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  /// Fetches all available competitions.
  Future<List<CompetitionBrief>> fetchCompetitions() async {
    final uri = Uri.parse('${FunctionsConfig.baseUrl}/competitions');
    final response = await client.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('API error (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final compsJson = data['competitions'] as List<dynamic>? ?? [];

    return compsJson
        .map((c) => CompetitionBrief.fromJson(c as Map<String, dynamic>))
        .toList();
  }
}
