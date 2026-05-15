sealed class AppException implements Exception {
  final String? debugMessage;


  const AppException({
    this.debugMessage,

  });
}

// ---------------------------
// Network & API
// ---------------------------

sealed class NetworkException extends AppException {
  const NetworkException({super.debugMessage});
}

final class NoInternetException extends NetworkException {
  const NoInternetException({super.debugMessage});
}

final class SocketTimeoutException extends NetworkException {
  const SocketTimeoutException({super.debugMessage});
}

final class UnauthorizedException extends NetworkException {
  const UnauthorizedException({super.debugMessage});
}

final class ForbiddenException extends NetworkException {
  const ForbiddenException({super.debugMessage});
}

final class ServerErrorException extends NetworkException {
  final int? statusCode;
  const ServerErrorException({
    this.statusCode,
    super.debugMessage,
  });
}

final class PayloadTooLargeException extends NetworkException {
  final int? maxBytes;
  const PayloadTooLargeException({
    this.maxBytes,
    super.debugMessage,
  });
}

// ---------------------------
// Local database
// ---------------------------

sealed class LocalDbException extends AppException {
  const LocalDbException({super.debugMessage});
}

final class BoxNotOpenException extends LocalDbException {
  const BoxNotOpenException({super.debugMessage});
}

final class DiskFullException extends LocalDbException {
  const DiskFullException({super.debugMessage});
}

final class DataCorruptionException extends LocalDbException {
  const DataCorruptionException({super.debugMessage});
}

final class TypeAdapterMismatchException extends LocalDbException {
  const TypeAdapterMismatchException({super.debugMessage});
}

// ---------------------------
// Domain (business rules)
// ---------------------------

sealed class DomainException extends AppException {
  const DomainException({super.debugMessage});
}

final class FakeGpsDetectedException extends DomainException {
  const FakeGpsDetectedException({super.debugMessage});
}

final class GeofencingFailureException extends DomainException {
  final double? distanceMeters;
  final double? allowedMeters;
  const GeofencingFailureException({
    this.distanceMeters,
    this.allowedMeters,
    super.debugMessage,

  });
}

final class DuplicateVisitException extends DomainException {
  const DuplicateVisitException({super.debugMessage});
}

final class MissingRequiredDataException extends DomainException {
  final List<String> fields;
  const MissingRequiredDataException(
    this.fields, {
    super.debugMessage,

  });
}

// ---------------------------
// Device & permissions (platform/presentation boundary)
// ---------------------------

sealed class DeviceException extends AppException {
  const DeviceException({super.debugMessage});
}

final class LocationPermissionDeniedException extends DeviceException {
  final bool permanentlyDenied;
  const LocationPermissionDeniedException({
    required this.permanentlyDenied,
    super.debugMessage,
  });
}

final class CameraPermissionDeniedException extends DeviceException {
  final bool permanentlyDenied;
  const CameraPermissionDeniedException({
    required this.permanentlyDenied,
    super.debugMessage,

  });
}

final class BatteryOptimizationEnabledException extends DeviceException {
  const BatteryOptimizationEnabledException({super.debugMessage});
}

