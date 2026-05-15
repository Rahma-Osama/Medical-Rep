import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';

class VisitFeedbackState {
  final DoctorInterestLevel interestLevel;
  final bool sampleGiven;
  final bool followUpRequired;
  final List<String> attachmentPaths;
  final String? errorMessage;
  final bool isLoading;
  final bool isSuccess;

  VisitFeedbackState({
    this.interestLevel = DoctorInterestLevel.medium,
    this.sampleGiven = false,
    this.followUpRequired = false,
    this.attachmentPaths = const [],
    this.errorMessage,
    this.isLoading = false,
    this.isSuccess = false,
  });

  VisitFeedbackState copyWith({
    DoctorInterestLevel? interestLevel,
    bool? sampleGiven,
    bool? followUpRequired,
    List<String>? attachmentPaths,
    String? errorMessage,
    bool? isLoading,
    bool? isSuccess,
  }) {
    return VisitFeedbackState(
      interestLevel: interestLevel ?? this.interestLevel,
      sampleGiven: sampleGiven ?? this.sampleGiven,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      errorMessage: errorMessage,
      isLoading: isLoading ?? false,
      isSuccess: isSuccess ?? false,
    );
  }
}