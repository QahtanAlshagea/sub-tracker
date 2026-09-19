import 'dart:async';
import 'package:flutter/foundation.dart';

/// Utility to prevent rapid duplicate executions (double-click / double-tap) on buttons.
///
/// Implements [EC-01-5]: "النقر المزدوج السريع على حفظ لا ينتج سوى سجل واحد".
class DebounceGuard {
  final Duration window;
  DateTime? _lastExecutionTime;
  bool _isExecuting = false;

  DebounceGuard({this.window = const Duration(milliseconds: 500)});

  /// Whether an action is currently permitted to execute.
  bool get canExecute {
    if (_isExecuting) return false;
    if (_lastExecutionTime == null) return true;
    return DateTime.now().difference(_lastExecutionTime!) >= window;
  }

  /// Runs [action] if the debounce window has elapsed and no action is currently executing.
  /// Returns true if the action was executed, false if ignored.
  bool run(VoidCallback action) {
    if (!canExecute) return false;

    _lastExecutionTime = DateTime.now();
    _isExecuting = true;
    try {
      action();
      return true;
    } finally {
      _isExecuting = false;
    }
  }

  /// Runs an asynchronous [action] guarding against concurrent re-entry.
  Future<bool> runAsync(Future<void> Function() action) async {
    if (!canExecute) return false;

    _lastExecutionTime = DateTime.now();
    _isExecuting = true;
    try {
      await action();
      return true;
    } finally {
      _isExecuting = false;
    }
  }

  /// Resets the debounce state.
  void reset() {
    _lastExecutionTime = null;
    _isExecuting = false;
  }
}
