
import 'package:medical_rep/features/visit_flow/models/visit_feedback_model.dart';

abstract class VisitRepository {
  Future<bool> verifyLocation(String clinicLocation);
  Future<void> submitFeedback(VisitFeedbackModel feedback);
  Future<void> endVisit(String visitId, DateTime endTime);
}

class VisitRepositoryImpl implements VisitRepository {
  @override
  Future<bool> verifyLocation(String clinicLocation) async {
    // TODO: integrate with geolocator package
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  @override
  Future<void> submitFeedback(VisitFeedbackModel feedback) async {
    // TODO: integrate with API service
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> endVisit(String visitId, DateTime endTime) async {
    // TODO: integrate with API service
    await Future.delayed(const Duration(milliseconds: 500));
  }
}