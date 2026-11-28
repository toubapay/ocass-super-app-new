import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';

/// Live updates (server: app/Noor/LiveSignal.php). Screens that subscribe
/// reload as soon as one of the user's taxi rides, Je Voyage trips or
/// messages changes. Three signals: the server's version
/// (GET /api/v1/customer/live) read every 4 s while someone listens and the
/// app is in front, a push received in the foreground, and coming back to
/// the app.
class LiveSync with WidgetsBindingObserver {
  LiveSync._();
  static final LiveSync instance = LiveSync._();

  final _listeners = <VoidCallback>{};
  Timer? _timer;
  int? _last;
  bool _busy = false;
  bool _foreground = true;
  bool _observing = false;

  /// Calls [reload] on every change; call the returned function in dispose().
  VoidCallback subscribe(VoidCallback reload) {
    _listeners.add(reload);
    _start();
    return () {
      _listeners.remove(reload);
      if (_listeners.isEmpty) _stop();
    };
  }

  /// A push arrived (taxi, voyage, voyage_message...): reload now.
  void ping() => _fire();

  void _fire() {
    for (final cb in List<VoidCallback>.from(_listeners)) {
      try {
        cb();
      } catch (_) {}
    }
  }

  void _start() {
    if (_timer != null) return;
    if (!_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }
    _last = null;
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _tick());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _tick() async {
    if (_busy || !_foreground || _listeners.isEmpty) return;
    if (!Get.isRegistered<AuthController>() || !Get.find<AuthController>().isLoggedIn()) return;
    _busy = true;
    try {
      final r = await Get.find<ApiClient>().getData('/api/v1/customer/live', handleError: false);
      if (r.statusCode == 200 && r.body is Map) {
        final v = (r.body['v'] as num?)?.toInt() ?? 0;
        if (_last != null && v != _last) _fire();
        _last = v;
      }
    } catch (_) {
      // Offline: the next tick tries again.
    } finally {
      _busy = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground && _listeners.isNotEmpty) {
      _fire();
      _tick();
    }
  }
}
