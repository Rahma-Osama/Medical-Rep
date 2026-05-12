import 'package:get_it/get_it.dart';
import '../../features/doctor_and_pharmacy/data/repositories_impl/medical_repository_impl.dart';
import '../../features/doctor_and_pharmacy/domain/repositories/medical_repository.dart';
import '../../features/doctor_and_pharmacy/domain/use_cases/get_medical_entities_use_case.dart';
import '../../features/doctor_and_pharmacy/presentation/cubit/medical_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<MedicalRepository>(
        () => MedicalRepositoryImpl(),
  );

  getIt.registerLazySingleton<GetMedicalEntitiesUseCase>(
        () => GetMedicalEntitiesUseCase(getIt<MedicalRepository>()),
  );

  getIt.registerFactory<MedicalCubit>(
        () => MedicalCubit(getIt<GetMedicalEntitiesUseCase>()),
  );
}