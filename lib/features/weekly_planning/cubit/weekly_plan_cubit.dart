import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
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
        _weeklyData.addAll(cachedPlan);
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

    _weeklyData[selectedDayIndex]!.add(_tempVisit);
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
      selectedDayIndex: selectedDayIndex,
      tempVisit: _tempVisit,
      completionRate: _calculateCompletion,
    ));

    try {
      await saveVisitUseCase.repository.saveWeeklyPlan(_weeklyData); 
      
      try {
        await submitPlanUseCase.call(); 
        // 🔹 طالما الخطة اترجمت واترفعت بنجاح، بنحدث وقت الـ Sync لبداية الـ 5 أيام
        if (Hive.isBoxOpen('settings')) {
          await Hive.box('settings').put('last_sync_date', DateTime.now().millisecondsSinceEpoch);
        }
      } catch (e) {
        print("Hive/Submit Error: $e");
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