class CookieNotOwnedByUserException implements Exception {
  final String message = 'Current user does not own this cookie';

  const CookieNotOwnedByUserException();

  @override
  String toString() => message;
}
