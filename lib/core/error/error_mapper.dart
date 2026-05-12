import 'app_exception.dart';
import 'app_failure.dart';

AppFailure mapExceptionToFailure(Object error) {
  //App Exception Converted to App Failure ==> User
  if (error is AppException) {
    return switch (error) {
      // Network
      NoInternetException() => const NoInternetFailure(),
      SocketTimeoutException() => const TimeoutFailure(),
      UnauthorizedException() => const UnauthorizedFailure(),
      ForbiddenException() => const ForbiddenFailure(),
      PayloadTooLargeException() => const PayloadTooLargeFailure(),
      ServerErrorException() => const ServerFailure(),

      // Local DB
      BoxNotOpenException() => const LocalDbFailure(
          title: 'Storage not ready',
          message: 'Local storage is not available right now. Restart the app and try again.',
          isRetryable: true,
        ),
      DiskFullException() => const LocalDbFailure(
          title: 'Storage full',
          message: 'Your device storage is full. Free up space and try again.',
          isRetryable: true,
        ),
      DataCorruptionException() => const LocalDbFailure(
          title: 'Data corrupted',
          message: 'Local data is corrupted. Clear app data or reinstall.',
        ),
      TypeAdapterMismatchException() => const LocalDbFailure(
          title: 'App update required',
          message: 'Local data format changed. Update the app or clear local data.',
        ),

      // Domain
      FakeGpsDetectedException() => const FakeGpsDetectedFailure(),
      GeofencingFailureException() => const GeofencingFailure(),
      DuplicateVisitException() => const DuplicateVisitFailure(),
      MissingRequiredDataException(fields: final fields) =>
        MissingRequiredDataFailure(missing: fields.join(', ')),

      // Device
      LocationPermissionDeniedException(permanentlyDenied: final perm) => PermissionFailure(
          title: 'Location permission required',
          message: perm
              ? 'Location permission is permanently denied. Enable it from Settings.'
              : 'Please allow location permission to continue.',
          isRetryable: !perm,
        ),
      CameraPermissionDeniedException(permanentlyDenied: final perm) => PermissionFailure(
          title: 'Camera permission required',
          message: perm
              ? 'Camera permission is permanently denied. Enable it from Settings.'
              : 'Please allow camera permission to continue.',
          isRetryable: !perm,
        ),
      BatteryOptimizationEnabledException() => const PermissionFailure(
          title: 'Battery optimization enabled',
          message: 'Disable battery optimization for reliable background location.',
        ),

      _ => const ServerFailure(),
    };
  }

  // Unknown/untyped errors → keep generic.
  return const ServerFailure();
}

