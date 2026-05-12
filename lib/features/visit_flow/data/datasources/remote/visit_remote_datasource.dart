import 'package:medical_rep/features/visit_flow/data/models/visit_data_models.dart';

abstract class VisitRemoteDataSource {
  Future<bool> verifyLocation(String location);
  Future<void> endVisit(String visitId, DateTime endTime);
  Future<void> submitFeedback(VisitFeedbackModel feedback);
}

// ── Implementation (Dio / http) ──────────────────────────────
class VisitRemoteDataSourceImpl implements VisitRemoteDataSource {
  // final Dio _dio;
  // VisitRemoteDataSourceImpl(this._dio);

  @override
  Future<bool> verifyLocation(String location) async {
    // TODO: call your location-verification endpoint
    // e.g. await _dio.post('/visits/verify-location', data: {'location': location})
    throw UnimplementedError();
  }

  @override
  Future<void> endVisit(String visitId, DateTime endTime) async {
    // TODO: await _dio.patch('/visits/$visitId/end', data: {'end_time': endTime.toIso8601String()})
    throw UnimplementedError();
  }

  @override
  Future<void> submitFeedback(VisitFeedbackModel feedback) async {
    // TODO: await _dio.post('/visits/feedback', data: feedback.toJson())
    throw UnimplementedError();
  }
}