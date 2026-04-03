import 'package:medical_rep/features/visit_flow/models/visit_feedback_model.dart';

abstract class VisitFeedbackState {}

class VisitFeedbackInitial extends VisitFeedbackState {
  final DoctorInterestLevel interestLevel;
  final bool sampleGiven;
  final bool followUpRequired;
  final List<String> attachmentPaths;

  VisitFeedbackInitial({
    this.interestLevel = DoctorInterestLevel.medium,
    this.sampleGiven = false,
    this.followUpRequired = false,
    this.attachmentPaths = const [],
  });

  VisitFeedbackInitial copyWith({
    DoctorInterestLevel? interestLevel,
    bool? sampleGiven,
    bool? followUpRequired,
    List<String>? attachmentPaths,
  }) {
    return VisitFeedbackInitial(
      interestLevel: interestLevel ?? this.interestLevel,
      sampleGiven: sampleGiven ?? this.sampleGiven,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
    );
  }
}

class VisitFeedbackLoading extends VisitFeedbackState {}

class VisitFeedbackSuccess extends VisitFeedbackState {}

class VisitFeedbackFailure extends VisitFeedbackState {
  final String message;
  VisitFeedbackFailure(this.message);
}