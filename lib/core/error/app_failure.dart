sealed class AppFailure {
  final String title;
  final String message;

  /// If true, UI can safely show a Retry action.
  final bool isRetryable;

  /// If true, UI should navigate to login / refresh session.
  final bool requiresReAuth;

  const AppFailure({
    required this.title,
    required this.message,
    this.isRetryable = false,
    this.requiresReAuth = false,
  });
}

// ---------------------------
// Network & API
// ---------------------------

final class NoInternetFailure extends AppFailure {
  const NoInternetFailure()
    : super(
        title: 'No internet',
        message: 'Please check your connection and try again.',
        isRetryable: true,
      );
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure()
    : super(
        title: 'Request timed out',
        message: 'The server is taking too long. Please try again.',
        isRetryable: true,
      );
}

final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure()
    : super(
        title: 'Session expired',
        message: 'Please log in again to continue.',
        requiresReAuth: true,
      );
}

final class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure()
    : super(
        title: 'Access denied',
        message: 'You do not have permission to access this resource.',
      );
}

final class ServerFailure extends AppFailure {
  const ServerFailure()
    : super(
        title: 'Server error',
        message: 'Service is currently unavailable. Please try again later.',
        isRetryable: true,
      );
}

final class PayloadTooLargeFailure extends AppFailure {
  const PayloadTooLargeFailure()
    : super(
        title: 'File too large',
        message:
            'Please upload smaller photos (or compress them) and try again.',
      );
}

// ---------------------------
// Local database
// ---------------------------

final class LocalDbFailure extends AppFailure {
  const LocalDbFailure({
    required super.title,
    required super.message,
    super.isRetryable,
  }) : super(requiresReAuth: false);
}

// ---------------------------
// Domain (business rules)
// ---------------------------

final class FakeGpsDetectedFailure extends AppFailure {
  const FakeGpsDetectedFailure()
    : super(
        title: 'Fake GPS detected',
        message: 'Disable mock location to start a visit.',
      );
}

final class GeofencingFailure extends AppFailure {
  const GeofencingFailure()
    : super(
        title: 'Location mismatch',
        message:
            'You are too far from the clinic location to start this visit.',
        isRetryable: true,
      );
}

final class DuplicateVisitFailure extends AppFailure {
  const DuplicateVisitFailure()
    : super(
        title: 'Duplicate visit',
        message: 'A visit to this doctor was already logged recently.',
      );
}

final class MissingRequiredDataFailure extends AppFailure {
  const MissingRequiredDataFailure({required String missing})
    : super(
        title: 'Missing information',
        message: 'Please fill the required fields: $missing',
      );
}

// ---------------------------
// Device & permissions
// ---------------------------

final class PermissionFailure extends AppFailure {
  const PermissionFailure({
    required super.title,
    required super.message,
    super.isRetryable,
  }) : super(requiresReAuth: false);
}
final class GeneralFailure extends AppFailure {
  const GeneralFailure({String? title, required String message})
      : super(
          title: title ?? 'Error',
          message: message,
        );
}
