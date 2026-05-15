import '../../domain/entities/medical_entity.dart';

abstract class MedicalState {}

class MedicalInitial extends MedicalState {}
class MedicalLoading extends MedicalState {}
class MedicalSuccess extends MedicalState {
  final List<MedicalEntity> entities;
  MedicalSuccess(this.entities);
}
class MedicalError extends MedicalState {
  final String message;
  MedicalError(this.message);
}