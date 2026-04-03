enum DoctorInterestLevel { high, medium, low }

class VisitFeedbackModel {
  final String visitId;
  final DoctorInterestLevel interestLevel;
  final bool sampleGiven;
  final bool followUpRequired;
  final String notes;
  final List<String> attachmentPaths;
  final DateTime submittedAt;

  const VisitFeedbackModel({
    required this.visitId,
    required this.interestLevel,
    required this.sampleGiven,
    required this.followUpRequired,
    required this.notes,
    required this.attachmentPaths,
    required this.submittedAt,
  });

  Map<String, dynamic> toJson() => {
    'visit_id': visitId,
    'interest_level': interestLevel.name,
    'sample_given': sampleGiven,
    'follow_up_required': followUpRequired,
    'notes': notes,
    'attachment_paths': attachmentPaths,
    'submitted_at': submittedAt.toIso8601String(),
  };
}