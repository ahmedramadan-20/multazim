import 'dart:async';
import 'package:flutter/material.dart';

/// Converts any Stream into a ChangeNotifier so GoRouter
/// can listen to it via refreshListenable.
class RouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;

  RouterRefreshStream(Stream stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
