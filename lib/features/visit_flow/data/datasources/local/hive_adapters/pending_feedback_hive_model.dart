import 'package:hive/hive.dart';

@HiveType(typeId: 10)
class PendingFeedbackHiveModel extends HiveObject {
  @HiveField(0)
  String visitId;

  @HiveField(1)
  String interestLevel; // stored as string e.g. "high"

  @HiveField(2)
  bool sampleGiven;

  @HiveField(3)
  bool followUpRequired;

  @HiveField(4)
  String notes;

  @HiveField(5)
  List<String> attachmentPaths;

  @HiveField(6)
  DateTime submittedAt;

  @HiveField(7)
  bool isSynced;

  // for display in pending screen
  @HiveField(8)
  String doctorName;

  @HiveField(9)
  String clinicName;

  PendingFeedbackHiveModel({
    required this.visitId,
    required this.interestLevel,
    required this.sampleGiven,
    required this.followUpRequired,
    required this.notes,
    required this.attachmentPaths,
    required this.submittedAt,
    this.isSynced = false,
    required this.doctorName,
    required this.clinicName,
  });
}