// ── VisitModel ───────────────────────────────────────────────
import 'package:medical_rep/features/visit_flow/domain/entities/visit.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_task.dart';

class VisitModel extends VisitEntity {
  const VisitModel({
    required super.visitId,
    required super.doctorName,
    required super.specialty,
    required super.clinicName,
    required super.location,
    required super.shift,
    required super.targetProduct,
    required super.startTime,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) => VisitModel(
    visitId: json['visit_id'] as String,
    doctorName: json['doctor_name'] as String,
    specialty: json['specialty'] as String,
    clinicName: json['clinic_name'] as String,
    location: json['location'] as String,
    shift: json['shift'] as String,
    targetProduct: json['target_product'] as String,
    startTime: DateTime.parse(json['start_time'] as String),
  );

  Map<String, dynamic> toJson() => {
    'visit_id': visitId,
    'doctor_name': doctorName,
    'specialty': specialty,
    'clinic_name': clinicName,
    'location': location,
    'shift': shift,
    'target_product': targetProduct,
    'start_time': startTime.toIso8601String(),
  };

  // Default tasks are a DATA concern (hardcoded seed data).
  // Domain entity is clean — this stays here.
  static List<VisitTaskModel> get defaultTasks => [
    VisitTaskModel(id: '1', title: 'Product Presentation'),
    VisitTaskModel(id: '2', title: 'Answer Doctor Questions'),
    VisitTaskModel(id: '3', title: 'Discuss Clinical Data'),
    VisitTaskModel(id: '4', title: 'Leave Marketing Material'),
  ];
}

// ── VisitTaskModel ────────────────────────────────────────────
class VisitTaskModel extends VisitTaskEntity {
  const VisitTaskModel({
    required super.id,
    required super.title,
    super.isDone,
  });

  factory VisitTaskModel.fromJson(Map<String, dynamic> json) => VisitTaskModel(
    id: json['id'] as String,
    title: json['title'] as String,
    isDone: (json['is_done'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'is_done': isDone,
  };

  @override
  VisitTaskModel copyWith({bool? isDone}) =>
      VisitTaskModel(id: id, title: title, isDone: isDone ?? this.isDone);
}

// ── VisitFeedbackModel ────────────────────────────────────────
class VisitFeedbackModel extends VisitFeedbackEntity {
  const VisitFeedbackModel({
    required super.visitId,
    required super.interestLevel,
    required super.sampleGiven,
    required super.followUpRequired,
    required super.notes,
    required super.attachmentPaths,
    required super.submittedAt,
  });

  factory VisitFeedbackModel.fromEntity(VisitFeedbackEntity entity) =>
      VisitFeedbackModel(
        visitId: entity.visitId,
        interestLevel: entity.interestLevel,
        sampleGiven: entity.sampleGiven,
        followUpRequired: entity.followUpRequired,
        notes: entity.notes,
        attachmentPaths: entity.attachmentPaths,
        submittedAt: entity.submittedAt,
      );

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