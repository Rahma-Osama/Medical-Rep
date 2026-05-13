import 'package:medical_rep/core/error/app_exception.dart';
import 'package:medical_rep/core/error/error_mapper.dart';
import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/features/visit_flow/domain/repositories/visit_repository.dart';
import '../models/visit_data_models.dart';

class VisitRepositoryImpl implements VisitRepository {
  @override
  Future<Result<bool>> verifyLocation(String clinicLocation) async {
    try {
      // TODO: integrate with geolocator package + fake-gps detection + geofencing.
      await Future.delayed(const Duration(seconds: 2));
      return const Success(true);
    } catch (e, st) {
      return Failure(mapExceptionToFailure(
        e is AppException ? e : ServerErrorException(),
      ));
    }
  }

  @override
  Future<Result<void>> submitFeedback(VisitFeedbackModel feedback) async {
    try {
      if (feedback.notes.trim().isEmpty) {
        throw const MissingRequiredDataException(['Notes']);
      }

      // TODO: integrate with API service + payload-size checks for attachments.
      await Future.delayed(const Duration(seconds: 1));
      return const Success(null);
    } catch (e, st) {
      return Failure(mapExceptionToFailure(
        e is AppException ? e : ServerErrorException(),
      ));
    }
  }

  @override
  Future<Result<void>> endVisit(String visitId, DateTime endTime) async {
    try {
      // TODO: integrate with API service
      await Future.delayed(const Duration(milliseconds: 500));
      return const Success(null);
    } catch (e, st) {
      return Failure(mapExceptionToFailure(
        e is AppException ? e : ServerErrorException(),
      ));
    }
  }
}
