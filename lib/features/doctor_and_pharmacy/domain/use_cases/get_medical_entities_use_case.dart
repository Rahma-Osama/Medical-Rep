import '../entities/medical_entity.dart';
import '../repositories/medical_repository.dart';

class GetMedicalEntitiesUseCase {
  final MedicalRepository repository;

  GetMedicalEntitiesUseCase(this.repository);

  Future<List<MedicalEntity>> call() async {
    return await repository.getMedicalEntities();
  }
}