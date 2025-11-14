import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<SupabaseClient> initializeClientFromFile(String fileName) async {
  await dotenv.load(fileName: fileName);

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseKey == null) {
    throw Exception('Missing configuration for Supabase');
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  return Supabase.instance.client;
}
