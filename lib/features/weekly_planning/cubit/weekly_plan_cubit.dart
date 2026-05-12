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

  int selectedDayIndex = 0;
  final List<String> weekDays = ["Sat", "Sun", "Mon", "Tue", "Wed"];

  // قوائم البيانات التي سيتم جلبها من Supabase
  List<String> allBricks = []; 
  List<String> filteredDoctors = [];

  // تخزين البيانات: كل يوم يحتوي على قائمة من الزيارات
  final Map<int, List<VisitEntity>> _weeklyData = {
    0: [], // Saturday
    1: [], // Sunday
    2: [], // Monday
    3: [], // Tuesday
    4: [], // Wednesday
  };

  // كائن مؤقت لتخزين الاختيارات الحالية
  VisitEntity _tempVisit = VisitEntity(shift: "AM", type: "Single");

  // جلب المناطق (Bricks) فور تشغيل الكيوبيت
// في ملف weekly_plan_cubit.dart
// داخل WeeklyPlanCubit
void _initData() async {
  try {
    // 1. جلب المناطق (كودك القديم)
    final fetchedBricks = await saveVisitUseCase.repository.getAreasFromSupabase();
    allBricks = List<String>.from(fetchedBricks); 

    // 2. الجزء الجديد: جلب الخطة المحفوظة في الكاش (Hive)
    final cachedPlan = saveVisitUseCase.repository.getLocalPlan();
    if (cachedPlan.isNotEmpty) {
      // لو لقينا بيانات في الكاش، بنحطها في الـ _weeklyData عشان تظهر في الـ UI
      _weeklyData.clear();
      _weeklyData.addAll(cachedPlan);
      print("✅ Cached Plan Loaded: ${_weeklyData.length} days found.");
    }

    _emitUpdatedState();
  } catch (e) {
    print("Cubit Init Error: $e");
    _emitUpdatedState(error: "حدث خطأ في جلب البيانات");
  }
}
void tempUpdateField(String field, dynamic value) async {
  _tempVisit = _tempVisit.copyWith(
    // لما بنختار بريك من الـ UI، بنسجله في حقل brick جوه الـ Entity
    brick: field == "brick" ? value : _tempVisit.brick, 
    doctor: field == "doctor" ? value : (field == "brick" ? null : _tempVisit.doctor),
    shift: field == "shift" ? value : _tempVisit.shift,
    type: field == "type" ? value : _tempVisit.type,
    notes: field == "notes" ? value : _tempVisit.notes,
    date: _getDateForDay(selectedDayIndex),
    dayName: weekDays[selectedDayIndex],
    // باقي الحقول...
  );

  // لو الحقل اللي اتغير هو الـ "brick" (اللي جاي من area_name)
  if (field == "brick" && value != null) {
    filteredDoctors = []; 
    _emitUpdatedState();
    // بنروح نجيب الدكاترة اللي الـ area_name بتاعهم بيساوي القيمة اللي اخترناها
    filteredDoctors = await saveVisitUseCase.repository.getDoctorsByArea(value);
  }
  
  _emitUpdatedState();
}
  String _getDateForDay(int index) {
    DateTime now = DateTime.now();
    DateTime targetDate = now.add(Duration(days: index)); 
    return "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
  }

  void selectDay(int index) {
    selectedDayIndex = index;
    _tempVisit = VisitEntity(shift: "AM", type: "Single");
    _emitUpdatedState();
  }

  /// تحديث الحقول وجلب الدكاترة ديناميكياً عند اختيار المنطقة
  
  /// إضافة الزيارة مع التحقق من عدم تكرار الدكتور في نفس اليوم
  Future<void> addVisitToDay() async {
    if (_tempVisit.doctor == null || _tempVisit.brick == null || _tempVisit.doctor!.isEmpty) {
      _emitUpdatedState(error: "Please select Brick and Doctor first");
      return;
    }

    final currentDayVisits = _weeklyData[selectedDayIndex]!;
    bool isDuplicate = currentDayVisits.any((v) => v.doctor == _tempVisit.doctor);

    if (isDuplicate) {
      // نرسل رسالة الخطأ مع الحفاظ على استقرار الواجهة
      _emitUpdatedState(error: "هذا الدكتور مضاف بالفعل في جدول اليوم!");
      return;
    }

    _weeklyData[selectedDayIndex]!.add(_tempVisit);
    
    // تصفير النموذج للزيارة القادمة
    _tempVisit = VisitEntity(shift: "AM", type: "Single", brick: null, doctor: null); 
    _emitUpdatedState();
  }

  void removeVisitFromDay(int visitIndex) {
    if (_weeklyData[selectedDayIndex]!.isNotEmpty) {
      _weeklyData[selectedDayIndex]!.removeAt(visitIndex);
      _emitUpdatedState();
    }
  }
 Future<void> submitPlan() async {
  emit(WeeklyPlanLoading(
    weeklyData: _weeklyData,
    selectedDayIndex: selectedDayIndex, // شيلي الـ _ لو مش موجودة في التعريف فوق
    tempVisit: _tempVisit,
    completionRate: _calculateCompletion,
  ));

  try {
    await saveVisitUseCase.repository.saveWeeklyPlan(_weeklyData); 
    
    try {
      await submitPlanUseCase.call(); 
    } catch (e) {
      print("Hive Error: $e");
    }
    
    emit(WeeklyPlanSuccess(
      weeklyData: _weeklyData,
      selectedDayIndex: selectedDayIndex,
      tempVisit: _tempVisit,
      completionRate: _calculateCompletion,
    ));

  } catch (e) {
    emit(WeeklyPlanError(
      e.toString(),
      weeklyData: _weeklyData,
      selectedDayIndex: selectedDayIndex,
      tempVisit: _tempVisit,
      completionRate: _calculateCompletion,
    ));
  }
}

void refreshPlanStatus() async {
    // إرسال حالة التحميل مع الحفاظ على البيانات الحالية في الواجهة
    emit(WeeklyPlanLoading(
      weeklyData: Map.from(_weeklyData),
      selectedDayIndex: selectedDayIndex,
      tempVisit: _tempVisit,
      completionRate: _calculateCompletion,
    ));

    try {
      // 1. طلب المزامنة من السيرفر (تحديث Hive من Supabase)
      await saveVisitUseCase.repository.syncPlanStatusWithServer();

      // 2. إعادة قراءة البيانات من Hive بعد ما اتحدثت
      final updatedPlan = saveVisitUseCase.repository.getLocalPlan();

      // 3. تحديث القائمة المحلية في الكيوبيت
      _weeklyData.clear();
      _weeklyData.addAll(updatedPlan);

      // 4. تحديث الواجهة بالحالة الجديدة
      _emitUpdatedState();
    } catch (e) {
      _emitUpdatedState(error: "فشلت عملية تحديث البيانات");
    }
  }
  bool get isPlanComplete => _weeklyData.values.every((list) => list.isNotEmpty);

  double get _calculateCompletion {
    int daysWithVisits = _weeklyData.values.where((list) => list.isNotEmpty).length;
    return daysWithVisits / weekDays.length;
  }

 void _emitUpdatedState({String? error}) {
  emit(WeeklyPlanUpdated(
    weeklyData: Map.from(_weeklyData), 
    selectedDayIndex: selectedDayIndex,
    completionRate: _calculateCompletion,
    tempVisit: _tempVisit, 
    error: error,
    ));
  }
}

extension VisitEntityCopy on VisitEntity {
  VisitEntity copyWith({
    String? brick,
    String? doctor,
    String? shift,
    String? type,
    String? notes,
    String? date,
    String? dayName,
  }) {
    return VisitEntity(
      brick: brick ?? this.brick,
      doctor: doctor ?? this.doctor,
      shift: shift ?? this.shift,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      dayName: dayName ?? this.dayName,
    );
  }
}