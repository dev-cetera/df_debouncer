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

import 'dart:async' show FutureOr, Timer;

import 'package:df_safer_dart/df_safer_dart.dart';

typedef _VoidCallback = FutureOr<void> Function();

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A practical Debouncer for optimizing performance by controlling the
/// frequency of function calls in response to rapid events.
final class Debouncer {
  //
  //
  //

  Timer? _timer;
  bool _hasStarted = false;
  final _sequencer = TaskSequencer();

  /// The function to call once at the very beginning.
  final _VoidCallback? _onStart;
  _VoidCallback? get onStart => _onStart;

  /// The function to call after the [delay] has passed.
  final _VoidCallback? _onWaited;
  _VoidCallback? get onWaited => _onWaited;

  /// The function to call immediately.
  final _VoidCallback? _onCall;
  _VoidCallback? get onCall => _onCall;

  /// The delay before calling the [_onWaited] function.
  final Duration delay;

  //
  //
  //

  Debouncer({
    required this.delay,
    FutureOr<void> Function()? onStart,
    FutureOr<void> Function()? onWaited,
    FutureOr<void> Function()? onCall,
  })  : _onCall = onCall,
        _onWaited = onWaited,
        _onStart = onStart;

  //
  //
  //

  /// Calls the [onCall] function and then waits for [delay] before calling the
  /// [onWaited] function.
  FutureOr<void> call({
    FutureOr<void> Function()? onStart,
    FutureOr<void> Function()? onWaited,
    FutureOr<void> Function()? onCall,
  }) {
    cancel();
    if (!_hasStarted) {
      if (_onStart != null) {
        _sequencer.then(_convertHandler(_onStart)).end();
      }
      if (onStart != null) {
        _sequencer.then(_convertHandler(onStart)).end();
      }
      _hasStarted = true;
    }
    if (_onCall != null) {
      _sequencer.then(_convertHandler(_onCall)).end();
    }
    if (onCall != null) {
      _sequencer.then(_convertHandler(onCall)).end();
    }
    _timer = Timer(delay, () {
      if (_onWaited != null) {
        _sequencer.then(_convertHandler(_onWaited)).end();
      }
      if (onWaited != null) {
        _sequencer.then(_convertHandler(onWaited)).end();
      }
      _hasStarted = false;
    });

    return _sequencer.completion.value;
  }

  //
  //
  //

  /// Finalizes the debouncer and calls the [onWaited] function.
  FutureOr<void> finalize({FutureOr<void> Function()? onWaited}) {
    if (cancel()) {
      if (_onWaited != null) {
        _sequencer.then(_convertHandler(_onWaited)).end();
      }
      if (onWaited != null) {
        _sequencer.then(_convertHandler(onWaited)).end();
      }
      return _sequencer.completion.value;
    }
  }

  //
  //
  //

  /// Cancels the debouncer.
  bool cancel() {
    if (_timer != null) {
      if (_timer!.isActive) {
        _timer!.cancel();
        _timer = null;
        return true;
      }
    }
    return false;
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

TTaskHandler<Object> _convertHandler(FutureOr<void> Function() handler) {
  return (_) {
    final f = handler();
    if (f is Future) {
      return f.then((_) => const None()).toResolvable();
    }
    return Sync.okValue(const None());
  };
}
