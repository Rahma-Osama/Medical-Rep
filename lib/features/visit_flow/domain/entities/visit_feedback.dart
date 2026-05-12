enum DoctorInterestLevel { high, medium, low }

class VisitFeedbackEntity {
  final String visitId;
  final DoctorInterestLevel interestLevel;
  final bool sampleGiven;
  final bool followUpRequired;
  final String notes;
  final List<String> attachmentPaths;
  final DateTime submittedAt;

  const VisitFeedbackEntity({
    required this.visitId,
    required this.interestLevel,
    required this.sampleGiven,
    required this.followUpRequired,
    required this.notes,
    required this.attachmentPaths,
    required this.submittedAt,
  });
}