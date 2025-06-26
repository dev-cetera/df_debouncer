//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by dev-cetera.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

/// A generic, in-memory cache with optional time-based expiration.
final class CacheManager<T> {
  // Internal map storing the cached items.
  final _cache = <String, _CachedItem<T>>{};

  /// Caches a [value] with a given [key].
  ///
  /// If [cacheDuration] is set, the entry will automatically expire.
  void cache(String key, T value, {Duration? cacheDuration}) {
    _cache[key] = _CachedItem(value, cacheDuration);
    if (cacheDuration != null) {
      _startExpiration(key, cacheDuration);
    }
  }

  /// Syntactic sugar for getting a cached item using map-like access.
  @pragma('vm:prefer-inline')
  T? operator [](String? key) => get(key);

  /// Retrieves an item from the cache.
  ///
  /// Returns the item's value if it exists and has not expired.
  /// Otherwise, removes the expired item (if it exists) and returns null.
  T? get(String? key) {
    if (key == null) return null;

    final item = _cache[key];
    if (item != null && !item.isExpired) {
      return item.value;
    }
    // Clean up expired or non-existent entries.
    _cache.remove(key);
    return null;
  }

  /// Schedules the asynchronous removal of a key after [duration].
  void _startExpiration(String key, Duration duration) {
    Future.delayed(duration, () => _cache.remove(key));
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Internal wrapper for a cached value and its expiration time.
final class _CachedItem<T> {
  final T value;
  final DateTime? expiration;

  _CachedItem(this.value, Duration? duration)
      : expiration = duration != null ? DateTime.now().add(duration) : null;

  /// Helper to check if the item is expired. An item without an expiration
  /// date is never considered expired.
  bool get isExpired {
    if (expiration == null) return false;
    return expiration!.isBefore(DateTime.now());
  }
}
