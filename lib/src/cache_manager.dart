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

final class CacheManager<T> {
  final _cache = <String, _CachedItem<T>>{};

  void cache(String key, T value, {Duration? cacheDuration}) {
    _cache[key] = _CachedItem(value, cacheDuration);
    if (cacheDuration != null) {
      _startExpiration(key, cacheDuration);
    }
  }

  @pragma('vm:prefer-inline')
  T? operator [](String? key) => get(key);

  T? get(String? key) {
    if (key == null) {
      return null;
    }
    final item = _cache[key];
    if (item != null && (item.expiration == null || item.expiration!.isAfter(DateTime.now()))) {
      return item.value;
    }
    _cache.remove(key);
    return null;
  }

  void _startExpiration(String key, Duration duration) {
    Future<void>.delayed(duration).then((_) {
      _cache.remove(key);
    });
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class _CachedItem<T> {
  final T value;
  final DateTime? expiration;

  _CachedItem(this.value, Duration? duration)
      : expiration = duration != null ? DateTime.now().add(duration) : null;
}
