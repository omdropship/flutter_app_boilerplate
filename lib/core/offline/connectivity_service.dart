import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'sync_status.dart';

/// Service for monitoring network connectivity status.
///
/// Uses connectivity_plus to detect network type changes and
/// performs actual connectivity checks to verify internet access.
///
/// Usage:
/// ```dart
/// final service = ConnectivityService.instance;
/// await service.init();
///
/// // Check current status
/// if (service.isOnline) {
///   // Device has internet access
/// }
///
/// // Listen for changes
/// service.onStatusChanged.listen((status) {
///   // Handle status change
/// });
/// ```
class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService _instance =
      ConnectivityService._();

  static ConnectivityService get instance => _instance;

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  ConnectivityStatus _currentStatus =
      ConnectivityStatus.online;

  List<ConnectivityResult> _lastResults =
      <ConnectivityResult>[];

  bool _isInitialized = false;

  /// Current connectivity status.
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Whether the device is currently online.
  bool get isOnline =>
      _currentStatus == ConnectivityStatus.online;

  /// Whether the device is currently offline.
  bool get isOffline =>
      _currentStatus == ConnectivityStatus.offline;

  /// Stream of connectivity status changes.
  Stream<ConnectivityStatus> get onStatusChanged =>
      _statusController.stream;

  /// Last known connectivity results.
  List<ConnectivityResult> get lastResults =>
      List.unmodifiable(_lastResults);

  /// Initialize the connectivity service.
  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    try {
      // Get initial connectivity status.
      _lastResults =
          await _connectivity.checkConnectivity();

      await _updateStatus(_lastResults);

      // Listen for connectivity changes.
      _subscription =
          _connectivity.onConnectivityChanged.listen(
        _handleConnectivityChange,
        onError: (Object error) {
          if (kDebugMode) {
            debugPrint(
              'ConnectivityService: '
              'Stream error: $error',
            );
          }
        },
      );

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint(
          'ConnectivityService: '
          'Initialized with status $_currentStatus',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'ConnectivityService: '
          'Initialization error: $e',
        );
      }

      // If connectivity detection fails, assume offline.
      _setStatus(ConnectivityStatus.offline);
      _isInitialized = true;
    }
  }

  /// Handle connectivity changes from the platform.
  Future<void> _handleConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    _lastResults = results;
    await _updateStatus(results);
  }

  /// Update the connectivity status based on results.
  Future<void> _updateStatus(
    List<ConnectivityResult> results,
  ) async {
    final bool hasNetwork = results.any(
      (ConnectivityResult result) =>
          result != ConnectivityResult.none,
    );

    if (!hasNetwork) {
      _setStatus(ConnectivityStatus.offline);
      return;
    }

    // Verify actual internet connectivity.
    final bool hasInternet =
        await _checkInternetAccess();

    _setStatus(
      hasInternet
          ? ConnectivityStatus.online
          : ConnectivityStatus.offline,
    );
  }

  /// Check if there is actual internet access.
  ///
  /// Uses DNS lookup instead of relying only on the
  /// network type reported by the operating system.
  Future<bool> _checkInternetAccess() async {
    try {
      final List<InternetAddress> result =
          await InternetAddress.lookup(
        'google.com',
      ).timeout(
        const Duration(seconds: 5),
      );

      return result.isNotEmpty &&
          result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'ConnectivityService: '
          'Internet check error: $e',
        );
      }

      return false;
    }
  }

  /// Set the status and emit to the stream.
  void _setStatus(
    ConnectivityStatus status,
  ) {
    if (_currentStatus == status) {
      return;
    }

    _currentStatus = status;

    if (!_statusController.isClosed) {
      _statusController.add(status);
    }

    if (kDebugMode) {
      debugPrint(
        'ConnectivityService: '
        'Status changed to $status',
      );
    }
  }

  /// Set status to syncing.
  ///
  /// Called by SyncQueue.
  void setSyncing() {
    _setStatus(ConnectivityStatus.syncing);
  }

  /// Set status back to online after syncing.
  void setSyncComplete() {
    if (_currentStatus ==
        ConnectivityStatus.syncing) {
      _setStatus(ConnectivityStatus.online);
    }
  }

  /// Manually trigger a connectivity check.
  Future<void> checkConnectivity() async {
    try {
      _lastResults =
          await _connectivity.checkConnectivity();

      await _updateStatus(_lastResults);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'ConnectivityService: '
          'Connectivity check error: $e',
        );
      }

      _setStatus(ConnectivityStatus.offline);
    }
  }

  /// Get a human-readable description of the
  /// connection type.
  String getConnectionTypeDescription() {
    if (_lastResults.isEmpty ||
        _lastResults.contains(
          ConnectivityResult.none,
        )) {
      return 'No connection';
    }

    final Set<String> types =
        _lastResults.map(
      (ConnectivityResult result) {
        switch (result) {
          case ConnectivityResult.wifi:
            return 'WiFi';

          case ConnectivityResult.mobile:
            return 'Mobile';

          case ConnectivityResult.ethernet:
            return 'Ethernet';

          case ConnectivityResult.vpn:
            return 'VPN';

          case ConnectivityResult.bluetooth:
            return 'Bluetooth';

          case ConnectivityResult.other:
            return 'Other';

          case ConnectivityResult.none:
            return 'None';

          case ConnectivityResult.satellite:
            return 'Satellite';

          default:
            // Keeps the code compatible if
            // connectivity_plus adds another
            // ConnectivityResult in the future.
            return 'Unknown';
        }
      },
    ).toSet();

    return types.join(', ');
  }

  /// Dispose the service.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;

    if (!_statusController.isClosed) {
      _statusController.close();
    }

    _isInitialized = false;
  }
}
