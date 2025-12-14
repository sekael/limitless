import 'dart:math';

import 'package:limitless_flutter/core/supabase/auth.dart';
import 'package:limitless_flutter/features/cookie_jar/data/cookie_repository.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _table = 'accomplishments';

class CookieRepositoryAdapter implements CookieRepository {
  final SupabaseClient _client = getSupabaseClient();

  @override
  Future<List<Cookie>> getAllCookiesForUser(String userId) async {
    final rows = await _client
        .from(_table)
        .select('id, content, created_at')
        .eq('user_id', userId);

    return rows.map(Cookie.fromMap).toList();
  }

  @override
  Future<Cookie?> getRandomCookieForUser(String userId) async {
    final allCookies = await getAllCookiesForUser(userId);
    if (allCookies.isEmpty) {
      return null;
    }

    final i = Random().nextInt(allCookies.length);
    return allCookies[i];
  }

  @override
  Future<List<Cookie>> fetchCookiesFromBeforeDate({
    required String userId,
    required DateTime? before,
    int limit = 20,
  }) async {
    var query = _client
        .from(_table)
        .select('id, user_id, content, created_at, is_public')
        .eq('user_id', userId);
    if (before != null) {
      query.lt('created_at', before.toIso8601String());
    }

    query.order('created_at').limit(limit);

    final rows = await query;
    return rows.map(Cookie.fromMap).toList();
  }

  @override
  Future<Cookie> insertNewCookie(
    String userId,
    String content,
    bool isPublic,
  ) async {
    final newCookieResponse = await _client.from(_table).insert({
      'user_id': userId,
      'content': content,
      'is_public': isPublic,
    }).select();
    return Cookie.fromMap(newCookieResponse.first);
  }

  @override
  Future<void> deleteCookie(String cookieId) async {
    await _client.from(_table).delete().eq('id', cookieId);
  }

  @override
  Future<Cookie> updateCookie(Cookie updatedCookie) async {
    final inserted = await _client
        .from(_table)
        .update(updatedCookie.toMap())
        .eq('id', updatedCookie.id)
        .select();

    return Cookie.fromMap(inserted.first);
  }
}
