import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:limitless_flutter/core/logging/app_logger.dart';

final List<String> requiredConfigKeys = ['SUPABASE_URL', 'SUPABASE_ANON_KEY'];

class ConfigService {
  // Singleton pattern for access from anywhere
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  late final String supabaseUrl;
  late final String supabaseAnonKey;

  bool _isLoaded = false;

  Future<void> load() async {
    if (_isLoaded) return;

    try {
      // Request 'config.json' relative to index.html
      logger.i('Loading configuration from config.json');
      final response = await http.get(Uri.parse('config.json'));

      if (response.statusCode == 200) {
        logger.i('Successfully loaded configuration from config.json');
        final Map<String, dynamic> config = jsonDecode(response.body);

        // Validate config
        for (final configKey in requiredConfigKeys) {
          if (!config.containsKey(configKey)) {
            logger.e('Required key $configKey is missing in config.json');
            throw Exception('config.json is missing required key $configKey');
          }
        }
        logger.i('Successfully decoded and validated config.json');

        supabaseUrl = config['SUPABASE_URL'];
        supabaseAnonKey = config['SUPABASE_ANON_KEY'];
        _isLoaded = true;
      } else {
        logger.e(
          'Configuration could not be loaded, status: ${response.statusCode}',
        );
        throw Exception(
          'Configuration could not be loaded, status: ${response.statusCode}',
        );
      }
    } catch (e, st) {
      logger.e('Failed to load config.json', e, st);
      throw Exception('Failed to load config.json');
    }
  }
}
