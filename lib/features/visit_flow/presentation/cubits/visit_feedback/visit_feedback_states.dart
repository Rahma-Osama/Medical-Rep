import 'package:medical_rep/core/error/app_failure.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';

class VisitFeedbackState {
  final DoctorInterestLevel interestLevel;
  final bool sampleGiven;
  final bool followUpRequired;
  final List<String> attachmentPaths;
  final AppFailure? failure;
  final bool isLoading;
  final bool isSuccess;

  VisitFeedbackState({
    this.interestLevel = DoctorInterestLevel.medium,
    this.sampleGiven = false,
    this.followUpRequired = false,
    this.attachmentPaths = const [],
    this.failure,
    this.isLoading = false,
    this.isSuccess = false,
  });

  VisitFeedbackState copyWith({
    DoctorInterestLevel? interestLevel,
    bool? sampleGiven,
    bool? followUpRequired,
    List<String>? attachmentPaths,
    AppFailure? failure,
    bool clearFailure = false,
    bool? isLoading,
    bool? isSuccess,
  }) {
    return VisitFeedbackState(
      interestLevel: interestLevel ?? this.interestLevel,
      sampleGiven: sampleGiven ?? this.sampleGiven,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      failure: clearFailure ? null : (failure ?? this.failure),
      isLoading: isLoading ?? false,
      isSuccess: isSuccess ?? false,
    );
  }
}