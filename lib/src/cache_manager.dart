//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Copyright © dev-cetera.com & contributors.
//
// The use of this source code is governed by an MIT-style license described in
// the LICENSE file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'dart:async' show Timer;

/// A generic, in-memory cache with optional time-based expiration.
final class CacheManager<T> {
  final _cache = <String, _CachedItem<T>>{};
  final _expirationTimers = <String, Timer>{};

  /// Caches a [value] with a given [key].
  ///
  /// If [cacheDuration] is set, the entry will automatically expire after
  /// that duration. Re-caching an existing key cancels its previous
  /// expiration timer so the new entry's own expiration applies.
  void cache(String key, T value, {Duration? cacheDuration}) {
    _expirationTimers.remove(key)?.cancel();
    _cache[key] = _CachedItem(value, cacheDuration);
    if (cacheDuration != null && cacheDuration > Duration.zero) {
      _expirationTimers[key] = Timer(cacheDuration, () => _evict(key));
    } else if (cacheDuration != null) {
      // Zero/negative duration: treat as already expired.
      _evict(key);
    }
  }

  /// Syntactic sugar for getting a cached item using map-like access.
  @pragma('vm:prefer-inline')
  T? operator [](String? key) => get(key);

  /// Retrieves an item from the cache.
  ///
  /// Returns the item's value if it exists and has not expired. Otherwise,
  /// removes the expired item (if it exists) and returns `null`.
  T? get(String? key) {
    if (key == null) return null;
    final item = _cache[key];
    if (item == null) return null;
    if (item.isExpired) {
      _evict(key);
      return null;
    }
    return item.value;
  }

  /// Returns `true` if [key] is present and not expired.
  bool containsKey(String? key) {
    if (key == null) return false;
    final item = _cache[key];
    if (item == null) return false;
    if (item.isExpired) {
      _evict(key);
      return false;
    }
    return true;
  }

  /// Removes the entry for [key] (if any) and returns its value, or `null`
  /// if the key was absent or expired.
  T? remove(String? key) {
    if (key == null) return null;
    _expirationTimers.remove(key)?.cancel();
    final item = _cache.remove(key);
    if (item == null || item.isExpired) return null;
    return item.value;
  }

  /// Removes all entries and cancels all pending expiration timers.
  void clear() {
    for (final timer in _expirationTimers.values) {
      timer.cancel();
    }
    _expirationTimers.clear();
    _cache.clear();
  }

  /// The number of entries currently in the cache, including any that are
  /// expired but have not yet been evicted.
  int get length => _cache.length;

  /// Cancels timers and clears the cache. After calling this, the manager
  /// can still be reused.
  void dispose() => clear();

  void _evict(String key) {
    _expirationTimers.remove(key)?.cancel();
    _cache.remove(key);
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Internal wrapper for a cached value and its expiration time.
final class _CachedItem<T> {
  final T value;
  final DateTime? expiration;

  _CachedItem(this.value, Duration? duration)
      : expiration = duration != null ? DateTime.now().add(duration) : null;

  /// `true` if the item has a deadline that is at or before [DateTime.now].
  /// An item without an expiration is never considered expired.
  bool get isExpired {
    final exp = expiration;
    if (exp == null) return false;
    return !DateTime.now().isBefore(exp);
  }
}
