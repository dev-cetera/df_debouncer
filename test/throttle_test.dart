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
  group('Throttle', () {
    test(
        'first call executes immediately, subsequent calls within the '
        'cool-down are ignored', () {
      final throttle = Throttle(const Duration(milliseconds: 100));
      var count = 0;
      throttle.run(() => count++);
      throttle.run(() => count++);
      throttle.run(() => count++);
      expect(count, 1);
      expect(throttle.isThrottled, isTrue);
    });

    test('isThrottled is false after the cool-down expires', () async {
      final throttle = Throttle(const Duration(milliseconds: 30));
      throttle.run(() {});
      expect(throttle.isThrottled, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(throttle.isThrottled, isFalse);
    });

    test('a second run after the cool-down executes', () async {
      final throttle = Throttle(const Duration(milliseconds: 30));
      var count = 0;
      throttle.run(() => count++);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      throttle.run(() => count++);
      expect(count, 2);
    });

    test('cancel() resets the throttle so the next run executes immediately',
        () {
      final throttle = Throttle(const Duration(milliseconds: 200));
      var count = 0;
      throttle.run(() => count++);
      expect(throttle.isThrottled, isTrue);
      throttle.cancel();
      expect(throttle.isThrottled, isFalse);
      throttle.run(() => count++);
      expect(count, 2);
    });

    test('throwing actions still arm the cool-down and rethrow', () async {
      final throttle = Throttle(const Duration(milliseconds: 30));
      expect(
        () => throttle.run(() => throw StateError('boom')),
        throwsStateError,
      );
      expect(throttle.isThrottled, isTrue);
      var count = 0;
      throttle.run(() => count++);
      expect(count, 0);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      throttle.run(() => count++);
      expect(count, 1);
    });

    test('ThrottleImmediate runs every call synchronously', () {
      final throttle = ThrottleImmediate();
      var count = 0;
      for (var i = 0; i < 10; i++) {
        throttle.run(() => count++);
      }
      expect(count, 10);
      expect(throttle.isThrottled, isFalse);
    });

    test('preset frequency-based throttles have the expected duration', () {
      expect(Throttle24Hz().duration.inMilliseconds, 1000 ~/ 24);
      expect(Throttle30Hz().duration.inMilliseconds, 1000 ~/ 30);
      expect(Throttle48Hz().duration.inMilliseconds, 1000 ~/ 48);
      expect(Throttle60Hz().duration.inMilliseconds, 1000 ~/ 60);
      expect(Throttle120Hz().duration.inMilliseconds, 1000 ~/ 120);
    });

    test('multiple runs across multiple cool-downs each execute once',
        () async {
      final throttle = Throttle(const Duration(milliseconds: 25));
      var count = 0;
      for (var round = 0; round < 3; round++) {
        throttle.run(() => count++);
        throttle.run(() => count++);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      expect(count, 3);
    });
  });
}
