import '../entities/medical_entity.dart';

abstract class MedicalRepository {
  Future<List<MedicalEntity>> getMedicalEntities();
  Future<void> addMedicalEntity(MedicalEntity entity);
}