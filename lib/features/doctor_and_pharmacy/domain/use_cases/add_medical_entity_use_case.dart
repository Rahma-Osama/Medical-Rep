import '../entities/medical_entity.dart';
import '../repositories/medical_repository.dart';

class AddMedicalEntityUseCase {
  final MedicalRepository repository;

  AddMedicalEntityUseCase(this.repository);

  Future<void> call(MedicalEntity entity) async {
    return await repository.addMedicalEntity(entity);
  }
}