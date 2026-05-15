import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:medical_rep/core/utils/work_week_dates.dart';
import 'package:medical_rep/features/visit_flow/data/models/visit_data_models.dart';
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
  void _initData() async {
    try {
      // 1. جلب المناطق
      final fetchedBricks = await saveVisitUseCase.repository.getAreasFromSupabase();
      allBricks = List<String>.from(fetchedBricks); 

      // 2. جلب الخطة المحفوظة في الكاش (Hive)
      final cachedPlan = saveVisitUseCase.repository.getLocalPlan();
      if (cachedPlan.isNotEmpty) {
        _weeklyData.clear();
        _weeklyData.addAll(_normalizeCachedPlanDates(cachedPlan));
        print("✅ Cached Plan Loaded: ${_weeklyData.length} days found.");
      }

      _emitUpdatedState();
    } catch (e) {
      print("Cubit Init Error: $e");
      _emitUpdatedState(error: "حدث خطأ في جلب البيانات");
    }
  }

  // 🔹 مكان الدوال الصحيح لمراقبة الـ 5 أيام والـ Cache (جوه الكلاس)
  void clearCacheIfExpired() {
    if (_isCacheExpired()) {
      var box = Hive.box<VisitModel>('weekly_visits_box');
      box.clear();
      
      // ✅ الـ emit شغالة هنا تمام لأنها جوه الكلاس
      emit(WeeklyPlanInitial()); 
      print("🚨 Cache expired and cleared.");
    }
  }

  bool _isCacheExpired() {
    // التأكد أولاً إن البوكس مفتوح للأمان
    if (!Hive.isBoxOpen('settings')) return false;
    
    var settingsBox = Hive.box('settings');
    int? lastSync = settingsBox.get('last_sync_date');
    
    if (lastSync == null) return false;

    DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(lastSync);
    int differenceInDays = DateTime.now().difference(lastDate).inDays;

    return differenceInDays >= 5; 
  }

  void tempUpdateField(String field, dynamic value) async {
    _tempVisit = _tempVisit.copyWith(
      brick: field == "brick" ? value : _tempVisit.brick, 
      doctor: field == "doctor" ? value : (field == "brick" ? null : _tempVisit.doctor),
      shift: field == "shift" ? value : _tempVisit.shift,
      type: field == "type" ? value : _tempVisit.type,
      notes: field == "notes" ? value : _tempVisit.notes,
      date: _getDateForDay(selectedDayIndex),
      dayName: weekDays[selectedDayIndex],
    );

    if (field == "brick" && value != null) {
      filteredDoctors = []; 
      _emitUpdatedState();
      filteredDoctors = await saveVisitUseCase.repository.getDoctorsByArea(value);
    }
    
    _emitUpdatedState();
  }

  String _getDateForDay(int index) =>
      WorkWeekDates.isoDateForPlanDay(index);

  Map<int, List<VisitEntity>> _normalizeCachedPlanDates(
    Map<int, List<VisitEntity>> plan,
  ) {
    return plan.map((dayIndex, visits) {
      return MapEntry(
        dayIndex,
        visits
            .map(
              (v) => v.copyWith(
                date: WorkWeekDates.normalizedVisitDate(
                  dayName: v.dayName ?? weekDays[dayIndex],
                  visitDate: v.date,
                ),
                dayName: v.dayName ?? weekDays[dayIndex],
              ),
            )
            .toList(),
      );
    });
  }

  void selectDay(int index) {
    selectedDayIndex = index;
    _tempVisit = VisitEntity(
      shift: "AM",
      type: "Single",
      date: _getDateForDay(index),
      dayName: weekDays[index],
    );
    _emitUpdatedState();
  }

  Future<void> addVisitToDay() async {
    if (_tempVisit.doctor == null || _tempVisit.brick == null || _tempVisit.doctor!.isEmpty) {
      _emitUpdatedState(error: "Please select Brick and Doctor first");
      return;
    }

    final currentDayVisits = _weeklyData[selectedDayIndex]!;
    bool isDuplicate = currentDayVisits.any((v) => v.doctor == _tempVisit.doctor);

    if (isDuplicate) {
      _emitUpdatedState(error: "هذا الدكتور مضاف بالفعل في جدول اليوم!");
      return;
    }

    final visitToAdd = _tempVisit.copyWith(
      date: _getDateForDay(selectedDayIndex),
      dayName: weekDays[selectedDayIndex],
    );
    _weeklyData[selectedDayIndex]!.add(visitToAdd);
    _tempVisit = VisitEntity(
      shift: "AM",
      type: "Single",
      date: _getDateForDay(selectedDayIndex),
      dayName: weekDays[selectedDayIndex],
    ); 
    _emitUpdatedState();
  }

  void removeVisitFromDay(int visitIndex) {
    if (_weeklyData[selectedDayIndex]!.isNotEmpty) {
      _weeklyData[selectedDayIndex]!.removeAt(visitIndex);
      _emitUpdatedState();
    }
  }

  // استبدلي دالة submitPlan في الـ Cubit بهذا الكود:
Future<void> submitPlan() async {
  // 1. حماية ضد الضغط المتكرر: لو الستيت Loading ميعملش حاجة
  if (state is WeeklyPlanLoading) return;

  emit(WeeklyPlanLoading(
    weeklyData: _weeklyData,
    selectedDayIndex: selectedDayIndex,
    tempVisit: _tempVisit,
    completionRate: _calculateCompletion,
  ));

  try {
    // 2. 🔹 نكتفي بـ saveWeeklyPlan لأنها دلوقت بقت بتسيف محلي وترفع للسيرفر "صح"
    await saveVisitUseCase.repository.saveWeeklyPlan(_weeklyData); 
    
    // 3. تحديث وقت المزامنة للـ 5 أيام
    if (Hive.isBoxOpen('settings')) {
      await Hive.box('settings').put('last_sync_date', DateTime.now().millisecondsSinceEpoch);
    }
    
    emit(WeeklyPlanSuccess(
      weeklyData: _weeklyData,
      selectedDayIndex: selectedDayIndex,
      tempVisit: _tempVisit,
      completionRate: _calculateCompletion,
    ));

    print(" Submit Success - Local & Remote Synced");

  } catch (e) {
    emit(WeeklyPlanError(
      "خطأ في الرفع: ${e.toString()}",
      weeklyData: _weeklyData,
      selectedDayIndex: selectedDayIndex,
      tempVisit: _tempVisit,
      completionRate: _calculateCompletion,
    ));
  }
}
  void refreshPlanStatus() async {
    emit(WeeklyPlanLoading(
      weeklyData: Map.from(_weeklyData),
      selectedDayIndex: selectedDayIndex,
      tempVisit: _tempVisit,
      completionRate: _calculateCompletion,
    ));

    try {
      await saveVisitUseCase.repository.syncPlanStatusWithServer();
      final updatedPlan = saveVisitUseCase.repository.getLocalPlan();

      _weeklyData.clear();
      _weeklyData.addAll(updatedPlan);

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
} // 👈 قفل كلاس الـ Cubit الأساسي هنا

// الـ extension بيفضل بره الكلاس عادي جداً
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