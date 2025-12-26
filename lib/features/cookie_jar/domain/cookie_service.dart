import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:limitless_flutter/core/exceptions/cookie_not_owned.dart';
import 'package:limitless_flutter/core/exceptions/unauthenticated_user.dart';
import 'package:limitless_flutter/core/logging/app_logger.dart';
import 'package:limitless_flutter/features/cookie_jar/data/cookie_repository.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/public_cookie.dart';

class CookieService extends ChangeNotifier {
  CookieService({
    required this.repository,
    this.pageSize = 10,
    this.queueTarget = 10,
    this.lowWater = 3,
  });

  final CookieRepository repository;
  final int pageSize;
  final int queueTarget;
  final int lowWater; // when to fetch new results

  Random? _rng;
  String? _userId;

  final Queue<Cookie> _queue = Queue();
  final Set<String> _shownCookies = <String>{};

  // Cursor settings for paginated retrieval
  DateTime? _oldestFetched;
  bool _hasMore = true;
  bool _loading = false;
  int _generation = 0; // protection against stale async fills

  // Handle public cookies
  List<PublicCookie> _publicCookies = [];
  bool _loadingPublic = false;

  // Getter for the UI
  List<PublicCookie> get publicCookies => UnmodifiableListView(_publicCookies);
  bool get loadingPublic => _loadingPublic;

  Future<void> setUser(String? userId) async {
    if (_userId == userId) return;

    logger.i('Setting cookie service user to $userId');
    _userId = userId;
    _rng = userId == null ? null : Random(_deriveSeed(userId));

    // Reset per-user state
    logger.i('Resetting user state');
    _queue.clear();
    _shownCookies.clear();
    _oldestFetched = null;
    _hasMore = true;
    _loading = false;

    // Invalidate in-flight fetches
    _generation++;
    notifyListeners();

    if (_userId != null) {
      await _fillQueueUntil(queueTarget);
      unawaited(refreshPublicFeed());
    }
  }

  Future<Cookie?> next() async {
    if (_userId == null) return null;

    if (_queue.isEmpty) {
      logger.i('Queue is currently empty, filling queue first');
      await _fillQueueUntil(lowWater);
      if (_queue.isEmpty) return null;
    }

    final cookie = _queue.removeFirst();
    _shownCookies.add(cookie.id);
    notifyListeners();

    // Keep queue warm in the background
    if (_queue.length <= lowWater) {
      // fire and forget
      unawaited(_fillQueueUntil(queueTarget));
    }

    logger.i('Showed next cookie from queue (current size = ${_queue.length})');
    return cookie;
  }

  // Reset after all cookies have been shown
  void resetShown() {
    _shownCookies.clear();
    notifyListeners();
  }

  Future<void> addNewCookie(
    String userId,
    String content,
    bool isPublic,
  ) async {
    if (_userId == null) throw UnauthenticatedUserException();
    if (userId != _userId) throw CookieNotOwnedByUserException();

    final newCookie = await repository.insertNewCookie(
      userId,
      content,
      isPublic,
    );
    _queue.addLast(newCookie);
    unawaited(refreshPublicFeed());
    notifyListeners();
  }

  Future<Cookie> updateCookie(Cookie updatedCookie) async {
    if (_userId == null) throw UnauthenticatedUserException();
    if (updatedCookie.userId != _userId) throw CookieNotOwnedByUserException();

    // Update cookie in repository
    final cookieAfterUpdate = await repository.updateCookie(updatedCookie);

    // Update queue and shown cookies
    if (_queue.any((c) => c.id == cookieAfterUpdate.id)) {
      final rebuiltQueue = Queue<Cookie>.from(
        _queue.map((c) => c.id == cookieAfterUpdate.id ? cookieAfterUpdate : c),
      );
      _queue
        ..clear()
        ..addAll(rebuiltQueue);
      unawaited(refreshPublicFeed());
      notifyListeners();
    }
    return cookieAfterUpdate;
  }

  Future<void> deleteCookie(Cookie cookieToDelete) async {
    if (_userId == null) throw UnauthenticatedUserException();
    if (cookieToDelete.userId != _userId) throw CookieNotOwnedByUserException();

    await repository.deleteCookie(cookieToDelete.id);
    _queue.removeWhere((c) => c.id == cookieToDelete.id);
    _shownCookies.remove(cookieToDelete.id);

    unawaited(refreshPublicFeed());
    notifyListeners();
  }

  Future<void> refreshPublicFeed() async {
    _loadingPublic = true;
    try {
      logger.i('Getting public cookies');
      final publicCookies = await repository.fetchPublicCookies();
      logger.i(
        'Retrieved ${publicCookies.length} public cookies from repository',
      );
      _publicCookies = publicCookies;
    } catch (e, st) {
      logger.e('Error retrieving public cookies from repository', e, st);
    } finally {
      _loadingPublic = false;
      notifyListeners();
    }
  }

  // Create a simple, deterministic seed from the userId
  int _deriveSeed(String userId) {
    int h = 0;
    for (final c in userId.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h;
  }

  Future<void> _fillQueueUntil(int target) async {
    if (_userId == null) return;
    if (_loading) return;

    final localGeneration = _generation;
    final localUserId = _userId!;

    // Prevent infinite loops
    bool justRecycled = false;

    _loading = true;
    logger.i('Filling cookie service queue to target value $target');

    try {
      while (_queue.length < target) {
        // If user changed while fetching -> stop
        if (localGeneration != _generation || _userId != localUserId) return;

        // Recycle previously shown cookies if the user does not have any more
        if (!_hasMore) {
          if (_queue.isEmpty && _shownCookies.isEmpty) {
            logger.i(
              'Cookie jar is truly empty (no cookies available or shown), stopping to fill the queue',
            );
            break;
          }

          logger.i(
            'No more cookies in repository, recycling cookies to refill the queue',
          );

          // Reset cursor
          _oldestFetched = null;
          _hasMore = true;
          _shownCookies.clear();
          justRecycled = true;

          // Continue immediately to trigger refetch
          continue;
        }

        final page = await repository.fetchCookiesFromBeforeDate(
          userId: localUserId,
          limit: pageSize,
          before: _oldestFetched,
        );

        if (page.isEmpty && justRecycled) {
          logger.w(
            'Attempted recycling cookies but received no cookies from repository, stopping',
          );
          _hasMore = false;
          break;
        }

        justRecycled = false;

        if (page.isEmpty) {
          _hasMore = false;
          // Continue loop and hit recycle in the next iteration
          continue;
        }

        // If only a partial page is returned, we can stop processing after current batch
        if (page.length < pageSize) {
          _hasMore = false;
        }

        // Update retrieval index
        _oldestFetched = page.last.createdAt;

        // Filter already shown cookies
        final freshCookies = page
            .where((c) => !_shownCookies.contains(c.id))
            .toList();

        // Shuffle cookies deterministically
        final rng = _rng!;
        for (int i = freshCookies.length - 1; i > 0; i--) {
          final j = rng.nextInt(i + 1);
          final tmp = freshCookies[i];
          freshCookies[i] = freshCookies[j];
          freshCookies[j] = tmp;
        }

        _queue.addAll(freshCookies);
        logger.i(
          'Added ${freshCookies.length} cookies to queue (current size = ${_queue.length})',
        );
      }
    } catch (e, st) {
      logger.e('Error filling the cookie queue', e, st);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
