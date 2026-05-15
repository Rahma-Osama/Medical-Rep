import 'package:medical_rep/features/visit_flow/data/models/visit_data_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class VisitRemoteDataSource {
  Future<void> endVisit(String visitId, DateTime endTime);
  Future<void> submitFeedback(VisitFeedbackModel feedback);
}

class VisitRemoteDataSourceImpl implements VisitRemoteDataSource {
  final supabase = Supabase.instance.client;

  @override
  Future<void> endVisit(String visitId, DateTime endTime) async {
    await supabase.from('visits').update({
      'last_seen_time': endTime.toIso8601String(),
    }).eq('id', visitId);
  }

  @override
  Future<void> submitFeedback(VisitFeedbackModel feedback) async {
    await supabase.from('visits').update({
      'notes': feedback.notes,
      'status': 'done',
      'interest_level': feedback.interestLevel.name,
      'sample_given': feedback.sampleGiven,
      'follow_up_required': feedback.followUpRequired,
      'target_product': feedback.targetProduct,
    }).eq('id', feedback.visitId);
  }
}