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

import 'package:df_debouncer/df_debouncer.dart';
import 'package:test/test.dart';

void main() {
  group('CacheManager', () {
    test('stores and retrieves a value', () {
      final cache = CacheManager<int>();
      cache.cache('a', 1);
      expect(cache.get('a'), 1);
      expect(cache['a'], 1);
    });

    test('returns null for missing keys', () {
      final cache = CacheManager<int>();
      expect(cache.get('missing'), isNull);
      expect(cache['missing'], isNull);
    });

    test('returns null for a null key', () {
      final cache = CacheManager<int>();
      cache.cache('a', 1);
      expect(cache.get(null), isNull);
      expect(cache[null], isNull);
    });

    test('overwriting a key replaces the value', () {
      final cache = CacheManager<String>();
      cache.cache('k', 'old');
      cache.cache('k', 'new');
      expect(cache['k'], 'new');
      expect(cache.length, 1);
    });

    test('cached entries without a duration never expire', () async {
      final cache = CacheManager<int>();
      cache.cache('persistent', 42);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cache['persistent'], 42);
    });

    test('entries expire after their duration', () async {
      final cache = CacheManager<String>();
      cache.cache('k', 'v', cacheDuration: const Duration(milliseconds: 30));
      expect(cache['k'], 'v');
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(cache['k'], isNull);
      expect(cache.length, 0);
    });

    test('a zero duration is treated as already expired', () {
      final cache = CacheManager<int>();
      cache.cache('k', 1, cacheDuration: Duration.zero);
      expect(cache['k'], isNull);
      expect(cache.length, 0);
    });

    test('re-caching a key with a different duration honours the new '
        'expiration and does not let the old timer evict the new value',
        () async {
      final cache = CacheManager<String>();
      cache.cache(
        'k',
        'first',
        cacheDuration: const Duration(milliseconds: 30),
      );
      await Future<void>.delayed(const Duration(milliseconds: 15));
      // Re-cache with a longer duration before the first timer fires.
      cache.cache(
        'k',
        'second',
        cacheDuration: const Duration(milliseconds: 200),
      );
      // Wait past where the original timer would have fired.
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(
        cache['k'],
        'second',
        reason: 'the original expiration timer must be cancelled',
      );
    });

    test('re-caching with no duration cancels any previous expiration', () async {
      final cache = CacheManager<int>();
      cache.cache('k', 1, cacheDuration: const Duration(milliseconds: 20));
      cache.cache('k', 2);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(cache['k'], 2);
    });

    test('containsKey reflects presence and expiration', () async {
      final cache = CacheManager<int>();
      cache.cache('a', 1);
      cache.cache('b', 2, cacheDuration: const Duration(milliseconds: 20));
      expect(cache.containsKey('a'), isTrue);
      expect(cache.containsKey('b'), isTrue);
      expect(cache.containsKey('missing'), isFalse);
      expect(cache.containsKey(null), isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cache.containsKey('b'), isFalse);
    });

    test('remove() pulls the value and cancels its expiration', () async {
      final cache = CacheManager<int>();
      cache.cache('k', 7, cacheDuration: const Duration(milliseconds: 20));
      expect(cache.remove('k'), 7);
      expect(cache['k'], isNull);
      // Re-cache and verify the cancelled timer doesn't evict the new entry.
      cache.cache('k', 8);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(cache['k'], 8);
    });

    test('remove() on a missing or null key returns null', () {
      final cache = CacheManager<int>();
      expect(cache.remove('missing'), isNull);
      expect(cache.remove(null), isNull);
    });

    test('clear() drops all entries and pending timers', () async {
      final cache = CacheManager<int>();
      cache.cache('a', 1);
      cache.cache('b', 2, cacheDuration: const Duration(milliseconds: 20));
      cache.clear();
      expect(cache.length, 0);
      expect(cache['a'], isNull);
      // Re-cache 'b' with a long duration; the cleared timer must not
      // evict it.
      cache.cache('b', 3, cacheDuration: const Duration(milliseconds: 200));
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(cache['b'], 3);
    });

    test('dispose() behaves like clear() and the manager remains reusable',
        () {
      final cache = CacheManager<int>();
      cache.cache('a', 1, cacheDuration: const Duration(milliseconds: 20));
      cache.dispose();
      expect(cache.length, 0);
      cache.cache('a', 9);
      expect(cache['a'], 9);
    });

    test('expired entry retrieved via get() is removed from the cache',
        () async {
      final cache = CacheManager<int>();
      cache.cache('k', 1, cacheDuration: const Duration(milliseconds: 10));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(cache.get('k'), isNull);
      expect(cache.length, 0);
    });

    test('supports arbitrary value types', () {
      final cache = CacheManager<List<int>>();
      cache.cache('xs', [1, 2, 3]);
      expect(cache['xs'], [1, 2, 3]);
    });
  });
}
