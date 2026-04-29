import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/data/repositeries/weekly_plan_repository.dart';
import 'package:medical_rep/features/weekly_planning/cubit/weekly_plan_state.dart';
import 'package:medical_rep/features/weekly_planning/model/visit_model.dart';

class WeeklyPlanCubit extends Cubit<WeeklyPlanState> {
  final WeeklyPlanRepository repository;

  WeeklyPlanCubit(this.repository) : super(WeeklyPlanInitial()) {
    _loadSavedPlan();
  }

  int selectedDayIndex = 0;
  // داخل WeeklyPlanCubit
final List<String> weekDays = ["Sat", "Sun", "Mon", "Tue", "Wed"]; // 5 أيام فقط

// خريطة البيانات المبدئية لـ 5 أيام
Map<int, VisitModel> _weeklyData = {
  0: VisitModel(),
  1: VisitModel(),
  2: VisitModel(),
  3: VisitModel(),
  4: VisitModel(),
};

// Function عشان نتأكد إن كل الأيام تم إدخال بياناتها (المنطقة والدكتور)
bool get isPlanComplete {
  // بنلف على الـ 5 أيام ونشوف هل كل يوم فيه (منطقة + دكتور)
  return _weeklyData.values.every((visit) => visit.isDayComplete);
}
  // 2. تحميل البيانات من Hive عند فتح الشاشة
  void _loadSavedPlan() {
    final savedPlan = repository.getLocalPlan();
    if (savedPlan.isNotEmpty) {
      _weeklyData = savedPlan;
    }
    _emitUpdatedState();
  }

  // 3. تحديث الحقول ديناميكياً (تعديل مباشر على الـ Object)
  void updateField(String field, dynamic value) {
    final currentVisit = _weeklyData[selectedDayIndex]!;

    if (field == "brick") {
      currentVisit.brick = value;
      currentVisit.doctor = null; // تصفير الدكتور عند تغيير المنطقة
    } else if (field == "doctor") {
      currentVisit.doctor = value;
    } else if (field == "shift") {
      currentVisit.shift = value;
    } else if (field == "type") {
      currentVisit.type = value;
    } else if (field == "notes") {
      currentVisit.notes = value;
    }

    _emitUpdatedState();
  }

  void selectDay(int index) {
    selectedDayIndex = index;
    _emitUpdatedState();
  }

  // 4. الحفظ النهائي (تم تعديل الوصول للبيانات ليكون من المتغير الخاص مباشرة)
  Future<void> submitPlan() async {
    emit(WeeklyPlanLoading()); 

    try {
      // ✅ نستخدم _weeklyData مباشرة لأنها هي المصدر الحقيقي للبيانات (Single Source of Truth)
      await repository.saveLocalPlan(_weeklyData);

      emit(WeeklyPlanSuccess());
    } catch (e) {
      emit(WeeklyPlanError("Failed to save plan: ${e.toString()}"));
    }
  }

  // 5. فلترة الدكاترة (Smart Logic)
  List<String> getFilteredDoctors() {
    final brick = _weeklyData[selectedDayIndex]?.brick;
    if (brick == "Maadi") return ["Dr. Ahmed Ali", "Dr. Sara Hassan"];
    if (brick == "Nasr City") return ["Dr. John Doe", "Dr. Mona Samy"];
    if (brick == "Dokki") return ["Dr. Khaled Yassin"];
    return [];
  }

  // 6. حساب نسبة الاكتمال
  double get _calculateCompletion {
    int completed = _weeklyData.values.where((v) => v.isDayComplete).length;
    return completed / weekDays.length;
  }

  // 7. دالة تحديث الـ UI (تحويل الموديلات لـ JSON للـ UI)
  void _emitUpdatedState() {
    emit(WeeklyPlanUpdated(
      weeklyData: _weeklyData.map((key, value) => MapEntry(key, value.toJson())), 
      selectedDayIndex: selectedDayIndex,
      completionRate: _calculateCompletion,
    ));
  }
}