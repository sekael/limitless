import 'dart:math';

import 'package:limitless_flutter/features/cookie_jar/domain/cookie.dart';
import 'package:limitless_flutter/supabase/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _table = 'accomplishments';
const _textColumn = 'content';

class CookieRepositoryAdapter {
  final SupabaseClient _client = getSupabaseClient();

  Future<List<Cookie>> getAllCookiesForUser(String userId) async {
    final rows = await _client
        .from(_table)
        .select('id, $_textColumn, created_at')
        .eq('user_id', userId);

    return rows.map(Cookie.fromMap).toList();
  }

  Future<Cookie?> getRandomCookieForUser(String userId) async {
    final allCookies = await getAllCookiesForUser(userId);
    if (allCookies.isEmpty) {
      return null;
    }

    final i = Random().nextInt(allCookies.length);
    return allCookies[i];
  }
}
