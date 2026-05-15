import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_medical_entities_use_case.dart';
import 'medical_state.dart';

class MedicalCubit extends Cubit<MedicalState> {
  final GetMedicalEntitiesUseCase getEntitiesUseCase;

  MedicalCubit(this.getEntitiesUseCase) : super(MedicalInitial());

  Future<void> fetchEntities() async {
    emit(MedicalLoading());
    try {
      // استدعاء الـ Use Case لجلب البيانات
      final entities = await getEntitiesUseCase.call();

      // سطر مهم جداً للتأكد من وصول الداتا في الـ Console
      print("Successfully fetched ${entities.length} entities from Supabase");

      if (entities.isEmpty) {
        // لو الداتا رجعت فاضية بنبعت حالة النجاح بس القائمة فاضية
        emit(MedicalSuccess(const []));
      } else {
        emit(MedicalSuccess(entities));
      }
    } catch (e) {
      // طباعة الخطأ بالتفصيل عشان لو فيه مشكلة في الـ Connection
      print("Cubit Error: $e");
      emit(MedicalError("Failed to load data: ${e.toString()}"));
    }
  }
}