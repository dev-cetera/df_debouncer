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

import 'dart:async';

import 'package:df_debouncer/df_debouncer.dart';
import 'package:test/test.dart';

void main() {
  group('Debouncer', () {
    test('onCall fires immediately on each call', () async {
      var callCount = 0;
      final d = Debouncer(
        delay: const Duration(milliseconds: 30),
        onCall: () => callCount++,
      );
      d();
      d();
      d();
      // Let any sequencer microtasks settle.
      await Future<void>.delayed(Duration.zero);
      expect(callCount, 3);
    });

    test('onStart fires once for a series of rapid calls', () async {
      var startCount = 0;
      final d = Debouncer(
        delay: const Duration(milliseconds: 30),
        onStart: () => startCount++,
      );
      d();
      d();
      d();
      await Future<void>.delayed(Duration.zero);
      expect(startCount, 1);
    });

    test('onWaited fires once after the delay following the last call',
        () async {
      var callCount = 0;
      var waitedCount = 0;
      final d = Debouncer(
        delay: const Duration(milliseconds: 40),
        onCall: () => callCount++,
        onWaited: () => waitedCount++,
      );
      d();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      d();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      d();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(callCount, 3);
      expect(waitedCount, 1);
    });

    test('isPending reflects the timer state', () async {
      final d = Debouncer(delay: const Duration(milliseconds: 30));
      expect(d.isPending, isFalse);
      d();
      expect(d.isPending, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(d.isPending, isFalse);
    });

    test('cancel() drops the pending onWaited', () async {
      var waited = 0;
      final d = Debouncer(
        delay: const Duration(milliseconds: 30),
        onWaited: () => waited++,
      );
      d();
      expect(d.isPending, isTrue);
      expect(d.cancel(), isTrue);
      expect(d.isPending, isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(waited, 0);
    });

    test('cancel() returns false when nothing is pending', () {
      final d = Debouncer(delay: const Duration(milliseconds: 30));
      expect(d.cancel(), isFalse);
    });

    test('finalize() runs onWaited immediately when a wait is pending',
        () async {
      var waited = 0;
      final d = Debouncer(
        delay: const Duration(milliseconds: 200),
        onWaited: () => waited++,
      );
      d();
      await d.finalize();
      expect(waited, 1);
      expect(d.isPending, isFalse);
    });

    test('finalize() with no pending wait is a no-op', () async {
      var waited = 0;
      final d = Debouncer(
        delay: const Duration(milliseconds: 30),
        onWaited: () => waited++,
      );
      await d.finalize();
      expect(waited, 0);
    });

    test('finalize() resets started state so onStart fires again on next call',
        () async {
      var starts = 0;
      final d = Debouncer(
        delay: const Duration(milliseconds: 200),
        onStart: () => starts++,
      );
      d();
      await d.finalize();
      expect(starts, 1);
      d();
      await Future<void>.delayed(Duration.zero);
      expect(starts, 2);
    });

    test('per-call callbacks run alongside the default ones', () async {
      final order = <String>[];
      final d = Debouncer(
        delay: const Duration(milliseconds: 20),
        onStart: () => order.add('default-start'),
        onCall: () => order.add('default-call'),
        onWaited: () => order.add('default-waited'),
      );
      d(
        onStart: () => order.add('one-shot-start'),
        onCall: () => order.add('one-shot-call'),
        onWaited: () => order.add('one-shot-waited'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(order, [
        'default-start',
        'one-shot-start',
        'default-call',
        'one-shot-call',
        'default-waited',
        'one-shot-waited',
      ]);
    });

    test('async onWaited is awaited before finalize completes', () async {
      var finished = false;
      final d = Debouncer(
        delay: const Duration(milliseconds: 200),
        onWaited: () async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          finished = true;
        },
      );
      d();
      await d.finalize();
      expect(finished, isTrue);
    });

    test('after onWaited fires, the next call re-triggers onStart', () async {
      var starts = 0;
      final d = Debouncer(
        delay: const Duration(milliseconds: 20),
        onStart: () => starts++,
      );
      d();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      d();
      await Future<void>.delayed(Duration.zero);
      expect(starts, 2);
    });

    test('rapid calls keep extending the wait window', () async {
      var waited = 0;
      final d = Debouncer(
        delay: const Duration(milliseconds: 50),
        onWaited: () => waited++,
      );
      d();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      d();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      d();
      // 60ms after the most recent call — onWaited should have fired exactly
      // once by now.
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(waited, 1);
    });

    test('dispose() cancels the pending wait without flushing onWaited',
        () async {
      var waited = 0;
      final d = Debouncer(
        delay: const Duration(milliseconds: 30),
        onWaited: () => waited++,
      );
      d();
      d.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(waited, 0);
      expect(d.isPending, isFalse);
    });

    test('debouncer is reusable after dispose()', () async {
      var starts = 0;
      final d = Debouncer(
        delay: const Duration(milliseconds: 20),
        onStart: () => starts++,
      );
      d();
      d.dispose();
      d();
      await Future<void>.delayed(Duration.zero);
      expect(starts, 2);
    });

    test('exposes the getters for the configured callbacks and delay', () {
      Future<void> w() async {}
      final d = Debouncer(
        delay: const Duration(milliseconds: 5),
        onStart: w,
        onCall: w,
        onWaited: w,
      );
      expect(d.delay, const Duration(milliseconds: 5));
      expect(d.onStart, isNotNull);
      expect(d.onCall, isNotNull);
      expect(d.onWaited, isNotNull);
    });
  });
}
