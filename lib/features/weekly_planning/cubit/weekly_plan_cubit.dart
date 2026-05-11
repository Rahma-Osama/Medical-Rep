import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/visit_entity.dart';
import '../domain/usecases/save_visit_usecase.dart';
import '../domain/usecases/submit_plan_usecase.dart';
import 'weekly_plan_state.dart';

class WeeklyPlanCubit extends Cubit<WeeklyPlanState> {
  final SaveVisitUseCase saveVisitUseCase;
  final SubmitPlanUseCase submitPlanUseCase;

  WeeklyPlanCubit({
    required this.saveVisitUseCase,
    required this.submitPlanUseCase,
  }) : super(WeeklyPlanInitial()) {
    _initData();
  }

  // المتغيرات اللي بتشيل حالة الصفحة الحالية
  int selectedDayIndex = 0;
  final List<String> weekDays = ["Sat", "Sun", "Mon", "Tue", "Wed"];

  // مصدر البيانات الأساسي هو الـ Entity لضمان Clean Architecture
  final Map<int, VisitEntity> _weeklyData = {
    0: VisitEntity(),
    1: VisitEntity(),
    2: VisitEntity(),
    3: VisitEntity(),
    4: VisitEntity(),
  };

  void _initData() {
    // تحميل البيانات المحفوظة محلياً (إن وجدت) عند فتح الكيوبيت
    final saved = saveVisitUseCase.repository.getLocalPlan();
    if (saved.isNotEmpty) {
      _weeklyData.addAll(saved);
    }
    _emitUpdatedState();
  }

  // 1. الدالة اللي كانت ناقصة لتغيير اليوم
  void selectDay(int index) {
    selectedDayIndex = index;
    _emitUpdatedState();
  }

  // 2. تحديث البيانات (المنطقة، الدكتور، الشفت...)
  void updateField(String field, dynamic value) {
    final current = _weeklyData[selectedDayIndex]!;
    
    // Immutable Update: بنعمل نسخة جديدة من الـ Entity
    _weeklyData[selectedDayIndex] = VisitEntity(
      brick: field == "brick" ? value : current.brick,
      // لو غيرنا المنطقة، بنصفر الدكتور عشان نختار دكتور جديد من المنطقة الجديدة
      doctor: field == "brick" ? null : (field == "doctor" ? value : current.doctor),
      shift: field == "shift" ? value : current.shift,
      type: field == "type" ? value : current.type,
      notes: field == "notes" ? value : current.notes,
    );

    _emitUpdatedState();
  }

  // 3. حفظ ورفع الخطة
  Future<void> submitPlan() async {
    if (!isPlanComplete) {
      emit(WeeklyPlanError("Please complete all 5 days first!"));
      return;
    }

    emit(WeeklyPlanLoading());
    try {
      // حفظ محلي أولاً
      await saveVisitUseCase.call(_weeklyData);
      // رفع الخطة للسيرفر (Supabase)
      await submitPlanUseCase.call();
      emit(WeeklyPlanSuccess());
    } catch (e) {
      emit(WeeklyPlanError("Sync Failed: ${e.toString()}"));
    }
  }

  // منطق الفلترة المبدئي للدكاترة بناءً على المنطقة
  List<String> getFilteredDoctors() {
    final brick = _weeklyData[selectedDayIndex]?.brick;
    if (brick == "Maadi") return ["Dr. Ahmed Ali", "Dr. Sara Hassan"];
    if (brick == "Nasr City") return ["Dr. John Doe", "Dr. Mona Samy"];
    if (brick == "Dokki") return ["Dr. Khaled Zaki", "Dr. Reham"];
    return [];
  }

  // Getter للتأكد من اكتمال الـ 5 أيام
  bool get isPlanComplete => _weeklyData.values.every((v) => v.isValid);

  // حساب نسبة الإنجاز للـ UI
  double get _calculateCompletion {
    int completed = _weeklyData.values.where((v) => v.isValid).length;
    return completed / weekDays.length;
  }

  // دالة موحدة لإرسال الحالة المحدثة للـ UI
  void _emitUpdatedState() {
    emit(WeeklyPlanUpdated(
      weeklyData: _weeklyData,
      selectedDayIndex: selectedDayIndex,
      completionRate: _calculateCompletion,
    ));
  }
}