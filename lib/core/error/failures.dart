// A Failure is a domain-level error — something that can go wrong
// that the UI needs to know about and handle gracefully.
// It is NOT an exception. Exceptions are low-level (network crash, DB error).
// Failures are high-level ("habit not found", "sync failed").

abstract class Failure {
  final String message;
  const Failure(this.message);
}

// Local database operation failed
class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

// Remote / Supabase operation failed
class RemoteFailure extends Failure {
  const RemoteFailure(super.message);
}

// Something wasn't found
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

// Input validation failed
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// Network is unavailable
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}
