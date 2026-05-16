import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:medical_rep/features/visit_flow/domain/usecases/validate_location_usecase.dart';
import 'package:medical_rep/features/weekly_planning/data/data%20source/weekly_plan_remote_data_source.dart';
import 'package:medical_rep/features/weekly_planning/data/repositories/weekly_plan_repository_impl.dart';
import 'package:medical_rep/features/weekly_planning/domain/repositories/weekly_plan_repository.dart';
import '../../features/home/data/home_dashboard_repository.dart';
import '../../features/doctor_and_pharmacy/data/repositories_impl/medical_repository_impl.dart';
import '../../features/doctor_and_pharmacy/domain/repositories/medical_repository.dart';
import '../../features/doctor_and_pharmacy/domain/use_cases/get_medical_entities_use_case.dart';
import '../../features/doctor_and_pharmacy/presentation/cubit/medical_cubit.dart';
import '../../features/weekly_planning/cubit/weekly_plan_cubit.dart';
import '../../features/weekly_planning/data/data%20source/weekly_plan_local_data_source.dart';
import '../../features/weekly_planning/domain/usecases/save_visit_usecase.dart';
import '../../features/weekly_planning/domain/usecases/submit_plan_usecase.dart';
import '../../core/services/image_upload.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/update_profile_photo_usecase.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {

  getIt.registerLazySingleton<ImageUpload>(() => ImageUpload());

  // ===========================================================================
  // 1. Profile & Home
  // ===========================================================================

  getIt.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(),
  );
  getIt.registerLazySingleton<UpdateProfilePhotoUseCase>(
    () => UpdateProfilePhotoUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<HomeDashboardRepository>(
        () => HomeDashboardRepositoryImpl(
      profileRepository: getIt<ProfileRepository>(),
    ),
  );

  // ===========================================================================
  // 2. Medical (Doctors & Pharmacies)
  // ===========================================================================
  getIt.registerLazySingleton<MedicalRepository>(
        () => MedicalRepositoryImpl(),
  );

  getIt.registerLazySingleton<GetMedicalEntitiesUseCase>(
        () => GetMedicalEntitiesUseCase(getIt<MedicalRepository>()),
  );

  getIt.registerFactory<MedicalCubit>(
        () => MedicalCubit(getIt<GetMedicalEntitiesUseCase>()),
  );

  // ===========================================================================
  // 3. Weekly Planning (Data Sources & Repos)
  // ===========================================================================
getIt.registerLazySingleton<WeeklyPlanLocalDataSource>(
  () => WeeklyPlanLocalDataSourceImpl(
    // ✅ بنمرر الصندوق المفتوح جاهز من الـ Hive منعاً لأي سباق أو كراش
    weeklyBox: Hive.box('weekly_visits_box'), 
  ),
);
  getIt.registerLazySingleton<WeeklyPlanRemoteDataSource>(
        () => WeeklyPlanRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<WeeklyPlanRepository>(
        () => WeeklyPlanRepositoryImpl(
      localDS: getIt<WeeklyPlanLocalDataSource>(),
      remoteDS: getIt<WeeklyPlanRemoteDataSource>(),
    ),
  );

  // ===========================================================================
  // 4. Use Cases
  // ===========================================================================
  getIt.registerLazySingleton<SaveVisitUseCase>(
        () => SaveVisitUseCase(getIt<WeeklyPlanRepository>()),
  );

  getIt.registerLazySingleton<SubmitPlanUseCase>(
        () => SubmitPlanUseCase(getIt<WeeklyPlanRepository>()),
  );

  // تم إضافة تسجيل الـ Validator هنا لحل مشكلة الـ GetIt error في الـ UI
  getIt.registerLazySingleton<ValidateLocationUseCase>(
        () => ValidateLocationUseCase(radiusInMeters: 100),
  );

  // ===========================================================================
  // 5. Cubits
  // ===========================================================================
  getIt.registerFactory<WeeklyPlanCubit>(
        () => WeeklyPlanCubit(
      saveVisitUseCase: getIt<SaveVisitUseCase>(),
      submitPlanUseCase: getIt<SubmitPlanUseCase>(),
    ),
  );


}