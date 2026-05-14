import 'package:equatable/equatable.dart';

enum LocationStatus { idle, verifying, verified, failed }

class ActiveVisitState extends Equatable {
  final LocationStatus locationStatus;
  final bool sampleGiven;
  final String notes;
  final bool isEndingVisit;
  final bool visitEndedSuccessfully;
  final String? errorMessage;
  final int tick;

  const ActiveVisitState({
    this.locationStatus = LocationStatus.idle,
    this.sampleGiven = false,
    this.notes = '',
    this.isEndingVisit = false,
    this.visitEndedSuccessfully = false,
    this.errorMessage,
    this.tick = 0,
  });

  ActiveVisitState copyWith({
    LocationStatus? locationStatus,
    bool? sampleGiven,
    String? notes,
    bool? isEndingVisit,
    bool? visitEndedSuccessfully,
    String? errorMessage,
    int? tick,
  }) {
    return ActiveVisitState(
      locationStatus: locationStatus ?? this.locationStatus,
      sampleGiven: sampleGiven ?? this.sampleGiven,
      notes: notes ?? this.notes,
      isEndingVisit: isEndingVisit ?? this.isEndingVisit,
      visitEndedSuccessfully:
      visitEndedSuccessfully ?? this.visitEndedSuccessfully,
      errorMessage: errorMessage ?? this.errorMessage,
      tick: tick ?? this.tick,
    );
  }

  @override
  List<Object?> get props => [
    locationStatus,
    sampleGiven,
    notes,
    isEndingVisit,
    visitEndedSuccessfully,
    errorMessage,
    tick,
  ];
}