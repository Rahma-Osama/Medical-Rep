import 'package:hive/hive.dart';

@HiveType(typeId: 10)

part 'pending_feedback_hive_model.g.dart';

@HiveType(typeId: 2)

class PendingFeedbackHiveModel extends HiveObject {
  @HiveField(0)
  final String visitId;

  @HiveField(1)
  final String interestLevel;

  @HiveField(2)
  final bool sampleGiven;

  @HiveField(3)
  final bool followUpRequired;

  @HiveField(4)
  final String notes;

  @HiveField(5)
  final DateTime submittedAt;

  @HiveField(6)
  final String doctorName;

  @HiveField(7)
  final String clinicName;

  @HiveField(8)
  bool isSynced;

  @HiveField(9)
  DateTime? endTime;

  @HiveField(10)
  String? targetProduct;

  PendingFeedbackHiveModel({
    required this.visitId,
    required this.interestLevel,
    required this.sampleGiven,
    required this.followUpRequired,
    required this.notes,
    required this.submittedAt,
    required this.doctorName,
    required this.clinicName,
    required this.targetProduct,
    this.isSynced = false,
    this.endTime,
  });
}