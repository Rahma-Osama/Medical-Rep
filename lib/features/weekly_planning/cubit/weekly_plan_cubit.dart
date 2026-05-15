import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:medical_rep/core/utils/work_week_dates.dart';
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
      // 1. جلب المناطق (From both branches)
      final fetchedBricks = await saveVisitUseCase.repository.getAreasFromSupabase();
      allBricks = List<String>.from(fetchedBricks); 

      // 2. التحقق من السيرفر وجلب الخطة المحفوظة (Merged from dev2 & home_profile_updates)
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
        
        if (cachedPlan.isNotEmpty || cachedPlan.values.any((list) => list.isNotEmpty)) {
          _weeklyData.clear();
          // Using the advanced normalization utility from home_profile_updates
          _weeklyData.addAll(_normalizeCachedPlanDates(cachedPlan));
          print("✅ Cached Plan Loaded & Normalized: ${_weeklyData.length} days found.");
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

  // Resolved Conflict 2: Keeps the clean static logic from home_profile_updates
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
    if (_tempVisit.doctor == null || _tempVisit.brick == null) return;

    final currentDayVisits = _weeklyData[selectedDayIndex]!;
    
    int existingIndex = currentDayVisits.indexWhere((v) => v.doctor == _tempVisit.doctor);

    // Resolved Conflict 3: Preserved the duplicate prevention and local state update logic safely
    final visitToAdd = _tempVisit.copyWith(
      date: _getDateForDay(selectedDayIndex),
      dayName: weekDays[selectedDayIndex],
    );

    if (existingIndex != -1) {
      currentDayVisits[existingIndex] = visitToAdd;
    } else {
      currentDayVisits.add(visitToAdd);
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

  void forceEnableSubmission() {
    _isSuccessfullyUploaded = false; 

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