import 'package:limitless_flutter/features/cookie_jar/domain/cookie.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/public_cookie.dart';

abstract class CookieRepository {
  Future<List<Cookie>> fetchCookiesFromBeforeDate({
    required String userId,
    required DateTime? before,
    int limit = 20,
  });

  Future<List<PublicCookie>> fetchPublicCookies({int limit = 20});

  Future<Cookie> insertNewCookie(String userId, String content, bool isPublic);

  Future<void> deleteCookie(String cookieId);

  Future<Cookie> updateCookie(Cookie updatedCookie);
}
