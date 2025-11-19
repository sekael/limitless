import 'package:limitless_flutter/features/cookie_jar/domain/cookie.dart';

abstract class CookieRepository {
  Future<List<Cookie>> getAllCookiesForUser(String userId);

  Future<Cookie?> getRandomCookieForUser(String userId);

  Future<List<Cookie>> fetchCookiesFromBeforeDate({
    required String userId,
    required DateTime? before,
    int limit = 20,
  });
}
