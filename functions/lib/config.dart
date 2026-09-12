import 'dart:io';

class FunctionsConfig {
  static final String footballDataApiKey =
      Platform.environment['FOOTBALL_DATA_API_KEY'] ??
          '3c1a3a1b631a4036a81aa5028d3b30e5';

  static final String syncAuthToken =
      Platform.environment['SYNC_AUTH_TOKEN'] ??
          'score_app_secure_sync_token';

  static const String baseUrl = 'https://api.football-data.org/v4';
}
