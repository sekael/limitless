import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:limitless_flutter/features/cookie_jar/data/cookie_repository.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie.dart';

class CookieService extends ChangeNotifier {
  CookieService({
    required this.repository,
    required this.userId,
    this.pageSize = 20,
    this.queueTarget = 10,
    this.lowWater = 3,
    int? seed,
  }) : _rng = Random(seed ?? _deriveSeed(userId));

  final CookieRepository repository;
  final String userId;
  final int pageSize;
  final int queueTarget;
  final int lowWater; // when to fetch new results
  final Random _rng;

  final Queue<Cookie> _queue = Queue();
  final Set<String> _shownCookies = <String>{};

  // Cursor settings for paginated retrieval
  DateTime? _oldestFetched;
  bool _hasMore = true;
  bool _loading = false;

  Future<void> init() async {
    if (_queue.length < queueTarget) {
      await _fillQueueUntil(queueTarget);
    }
  }

  Future<Cookie?> next() async {
    if (_queue.isEmpty) {
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

    return cookie;
  }

  // Reset after all cookies have been shown
  void resetShown() {
    _shownCookies.clear();
    notifyListeners();
  }

  Future<void> insertNewCookieForUser(
    String userId,
    String content,
    bool isPublic,
  ) async {
    repository.insertNewCookieForUser(userId, content, isPublic);
  }

  Future<Cookie> updateCookie(Cookie newCookie) async {
    // Update cookie in repository
    final updatedCookie = await repository.updateCookie(newCookie);

    // Update queue and shown cookies
    for (final cookie in _queue) {
      // Only update if updated cookie is present in queue
      if (cookie.id == updatedCookie.id) {
        final rebuiltQueue = Queue<Cookie>();
        for (final oldCookie in _queue) {
          rebuiltQueue.add(
            oldCookie.id == updatedCookie.id ? updatedCookie : oldCookie,
          );
        }
        _queue
          ..clear()
          ..addAll(rebuiltQueue);
        break;
      }
    }
    notifyListeners();
    return updatedCookie;
  }

  Future<void> deleteCookie(String cookieId) async {
    repository.deleteCookie(cookieId);
  }

  // Create a simple, deterministic seed from the userId
  static int _deriveSeed(String userId) {
    int h = 0;
    for (final c in userId.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h;
  }

  Future<void> _fillQueueUntil(int target) async {
    if (_loading) return;
    _loading = true;
    try {
      while (_queue.length < target && _hasMore) {
        final page = await repository.fetchCookiesFromBeforeDate(
          userId: userId,
          limit: pageSize,
          before: _oldestFetched,
        );

        if (page.isEmpty) {
          _hasMore = false;
          break;
        }

        // Update retrieval index
        _oldestFetched = page.last.createdAt;

        // Filter already shown cookies
        final freshCookies = page
            .where((c) => !_shownCookies.contains(c.id))
            .toList();

        // Shuffle cookies deterministically
        for (int i = freshCookies.length - 1; i > 0; i--) {
          final j = _rng.nextInt(i + 1);
          final tmp = freshCookies[i];
          freshCookies[i] = freshCookies[j];
          freshCookies[j] = tmp;
        }

        _queue.addAll(freshCookies);
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
