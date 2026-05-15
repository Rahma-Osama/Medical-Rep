import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:medical_rep/features/visit_flow/data/models/visit_data_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  List<String> allBricks = [];
  List<String> filteredDoctors = [];

  final Map<int, List<VisitEntity>> _weeklyData = {
    0: [], // Saturday
    1: [], // Sunday
    2: [], // Monday
    3: [], // Tuesday
    4: [], // Wednesday
  };

  VisitEntity _tempVisit = VisitEntity(shift: "AM", type: "Single");
  bool _isSuccessfullyUploaded = false;

  bool get isPlanAlreadySubmitted => _isSuccessfullyUploaded;

  void _initData() async {
    try {
      final fetchedBricks =
          await saveVisitUseCase.repository.getAreasFromSupabase();
      allBricks = List<String>.from(fetchedBricks);

      final String? userId = Supabase.instance.client.auth.currentUser?.id;
      final response = await Supabase.instance.client
          .from('visits')
          .select()
          .eq('user_id', userId ?? '');

      final List dataFromServer = response as List;

      if (dataFromServer.isEmpty) {
        _isSuccessfullyUploaded = false;
        await resetPlan();
      } else {
        _isSuccessfullyUploaded = true;
        final cachedPlan = saveVisitUseCase.repository.getLocalPlan();
        if (cachedPlan.values.any((list) => list.isNotEmpty)) {
          _weeklyData.clear();
          _weeklyData.addAll(cachedPlan);
        }
      }
      _emitUpdatedState();
    } catch (e) {
      print(" Init Error: $e");
      _emitUpdatedState(error: "حدث خطأ أثناء جلب البيانات");
    }
  }

  Future<void> submitPlan() async {
    if (state is WeeklyPlanLoading) return;

    emit(WeeklyPlanLoading(
      weeklyData: _weeklyData,
      selectedDayIndex: selectedDayIndex,
      tempVisit: _tempVisit,
      completionRate: _calculateCompletion,
    ));

    try {
      await saveVisitUseCase.repository.saveWeeklyPlan(_weeklyData);

      _isSuccessfullyUploaded = true;

      if (Hive.isBoxOpen('settings')) {
        await Hive.box('settings')
            .put('last_sync_date', DateTime.now().millisecondsSinceEpoch);
      }

      _emitUpdatedState();

      emit(WeeklyPlanSuccess(
        weeklyData: _weeklyData,
        selectedDayIndex: selectedDayIndex,
        tempVisit: _tempVisit,
        completionRate: _calculateCompletion,
      ));

      print(" Submit Success - Button should lock now");
    } catch (e) {
      _isSuccessfullyUploaded = false;
      emit(WeeklyPlanError(
        "خطأ في الرفع: ${e.toString()}",
        weeklyData: _weeklyData,
        selectedDayIndex: selectedDayIndex,
        tempVisit: _tempVisit,
        completionRate: _calculateCompletion,
      ));
    }
  }

  Future<void> resetPlan() async {
    if (!Hive.isBoxOpen('weekly_visits_box')) {
      await Hive.openBox<VisitModel>('weekly_visits_box');
    }

    var box = Hive.box<VisitModel>('weekly_visits_box');
    await box.clear();

    _weeklyData.forEach((key, value) => value.clear());

    _isSuccessfullyUploaded = false;

    _emitUpdatedState();
    print("Plan Reset.");
  }

  void clearCacheIfExpired() {
    if (_isCacheExpired()) {
      var box = Hive.box<VisitModel>('weekly_visits_box');
      box.clear();

      emit(WeeklyPlanInitial());
      print(" Cache expired and cleared.");
    }
  }

  bool _isCacheExpired() {
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
      doctor: field == "doctor"
          ? value
          : (field == "brick" ? null : _tempVisit.doctor),
      shift: field == "shift" ? value : _tempVisit.shift,
      type: field == "type" ? value : _tempVisit.type,
      notes: field == "notes" ? value : _tempVisit.notes,
      date: _getDateForDay(selectedDayIndex),
      dayName: weekDays[selectedDayIndex],
    );

    if (field == "brick" && value != null) {
      filteredDoctors = [];
      _emitUpdatedState();
      filteredDoctors =
          await saveVisitUseCase.repository.getDoctorsByArea(value);
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
    if (_tempVisit.doctor == null || _tempVisit.brick == null) return;

    final currentDayVisits = _weeklyData[selectedDayIndex]!;
    
    // بنشوف هل الدكتور ده موجود في القائمة الحالية؟
    int existingIndex = currentDayVisits.indexWhere((v) => v.doctor == _tempVisit.doctor);

    if (existingIndex != -1) {
      // ✅ لو موجود: بنحدثه في مكانه وبنخلي الـ ID القديم زي ما هو
      // وده اللي هيخلي السيرفر يعمل Update مش Insert
      currentDayVisits[existingIndex] = _tempVisit;
    } else {
      // لو مش موجود: بنضيفه كزيارة جديدة
      _weeklyData[selectedDayIndex]!.add(_tempVisit);
    }

    _tempVisit = VisitEntity(shift: "AM", type: "Single", brick: null, doctor: null);
    _emitUpdatedState();
  }
  void removeVisitFromDay(int visitIndex) {
    if (_weeklyData[selectedDayIndex]!.isNotEmpty) {
      _weeklyData[selectedDayIndex]!.removeAt(visitIndex);
      _emitUpdatedState();
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

  bool get isPlanComplete =>
      _weeklyData.values.every((list) => list.isNotEmpty);

  double get _calculateCompletion {
    int daysWithVisits =
        _weeklyData.values.where((list) => list.isNotEmpty).length;
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
  // جوه كلاس WeeklyPlanCubit
void forceEnableSubmission() {
  // بنعدل المتغير الأصلي اللي شايل القيمة
  _isSuccessfullyUploaded = false; 

  // بنبعت الحالة الجديدة عشان الـ UI يحس بالتغيير ويفتح الزرار
  if (state is WeeklyPlanUpdated) {
    final currentState = state as WeeklyPlanUpdated;
    emit(WeeklyPlanUpdated(
      weeklyData: currentState.weeklyData,
      selectedDayIndex: currentState.selectedDayIndex,
      tempVisit: currentState.tempVisit,
    ));
  }
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
