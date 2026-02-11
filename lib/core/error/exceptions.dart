// Exceptions are thrown inside the data layer only.
// They are caught by the repository and converted into Failures.
// The domain and presentation layers never see raw exceptions.

class LocalException implements Exception {
  final String message;
  const LocalException(this.message);

  @override
  String toString() => 'LocalException: $message';
}

class RemoteException implements Exception {
  final String message;
  const RemoteException(this.message);

  @override
  String toString() => 'RemoteException: $message';
}

class NetworkException implements Exception {
  const NetworkException();

  @override
  String toString() => 'NetworkException: No internet connection';
}
// ```

// **Why two separate concepts?**

// The flow is always:
// ```
// ObjectBox crashes     → throws LocalException   (data layer)
// Repository catches it → returns LocalFailure     (domain layer)
// Cubit receives it     → emits ErrorState         (presentation layer)
// UI sees ErrorState    → shows error message      (widget)
