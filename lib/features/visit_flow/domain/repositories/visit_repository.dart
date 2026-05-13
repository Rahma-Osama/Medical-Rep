import 'package:medical_rep/core/error/result.dart';
import '../../data/models/visit_data_models.dart';

/// Visit flow persistence / remote contract (implemented in the data layer).
abstract class VisitRepository {
  Future<Result<bool>> verifyLocation(String clinicLocation);
  Future<Result<void>> submitFeedback(VisitFeedbackModel feedback);
  Future<Result<void>> endVisit(String visitId, DateTime endTime);
}
