import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../features/habits/domain/services/sync_service.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import 'dart:developer' as developer;

class ConnectivityService {
  final Connectivity _connectivity;
  final SyncService _syncService;
  final AuthCubit _authCubit;
  StreamSubscription? _subscription;

  ConnectivityService({
    required Connectivity connectivity,
    required SyncService syncService,
    required AuthCubit authCubit,
  }) : _connectivity = connectivity,
       _syncService = syncService,
       _authCubit = authCubit;

  void startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });
  }

  void stopListening() {
    _subscription?.cancel();
  }

  Future<void> _handleConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    final hasConnection = results.any(
      (r) => r == ConnectivityResult.mobile || r == ConnectivityResult.wifi,
    );

    if (hasConnection && _authCubit.isAuthenticated) {
      developer.log(
        'Connection restored. Triggering background sync...',
        name: 'multazim.sync',
      );
      try {
        await _syncService.fullSync();
      } catch (e) {
        developer.log('Background sync failed: $e', name: 'multazim.sync');
      }
    }
  }
}
