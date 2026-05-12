import 'package:equatable/equatable.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_task.dart';

enum LocationStatus { idle, verifying, verified, failed }
class ActiveVisitState extends Equatable {
  final Duration elapsed;
  final LocationStatus locationStatus;
  final bool sampleGiven;
  final String notes;
  final bool isEndingVisit;
  final bool visitEndedSuccessfully;
  final String? errorMessage;
  final bool visitEnded;


  const ActiveVisitState({
    this.elapsed = Duration.zero,
    this.locationStatus = LocationStatus.idle,
    this.sampleGiven = false,
    this.notes = '',
    this.isEndingVisit = false,
    this.visitEndedSuccessfully = false,
    this.errorMessage,
    this.visitEnded=false
  });

  ActiveVisitState copyWith({
    Duration? elapsed,
    LocationStatus? locationStatus,
    bool? sampleGiven,
    String? notes,
    bool? isEndingVisit,
    bool? visitEndedSuccessfully,
    String? errorMessage,
    bool? visitEnded,
  }) {
    return ActiveVisitState(
      elapsed: elapsed ?? this.elapsed,
      locationStatus: locationStatus ?? this.locationStatus,
      sampleGiven: sampleGiven ?? this.sampleGiven,
      notes: notes ?? this.notes,
      isEndingVisit: isEndingVisit ?? this.isEndingVisit,
      visitEndedSuccessfully: visitEndedSuccessfully ?? this.visitEndedSuccessfully,
      errorMessage: errorMessage ?? this.errorMessage,
      visitEnded: visitEnded ?? this.visitEnded,
    );
  }


  @override
  List<Object?> get props => [
    elapsed,
    locationStatus,
    sampleGiven,
    notes,
    isEndingVisit,
    visitEndedSuccessfully,
    errorMessage,
    visitEnded
  ];
}