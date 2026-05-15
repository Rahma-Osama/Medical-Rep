class PendingFeedbackEntity {
  final String visitId;
  final String doctorName;
  final String clinicName;
  final DateTime submittedAt;

  const PendingFeedbackEntity({
    required this.visitId,
    required this.doctorName,
    required this.clinicName,
    required this.submittedAt,
  });
}
