import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:medical_rep/core/utils/work_week_dates.dart';
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
      // 1. جلب المناطق
      final fetchedBricks = await saveVisitUseCase.repository.getAreasFromSupabase();
      allBricks = List<String>.from(fetchedBricks); 

      // 2. التحقق من السيرفر وجلب الخطة
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
        
      // جلب البيانات المحلية
        final cachedPlan = await saveVisitUseCase.repository.getLocalPlan();
        
        if (cachedPlan.isNotEmpty) {
          _weeklyData.clear();
          
          final Map<int, List<VisitEntity>> sanitizedPlan = {};
          
          // ✅ الحل القاطع: بنتعامل مع الـ value على إنها List دايماً تماشياً مع الـ Repository
          cachedPlan.forEach((key, value) {
            if (value is List) {
              sanitizedPlan[key] = List<VisitEntity>.from(value);
            } else {
              sanitizedPlan[key] = [];
            }
          });

          // نضمن إن كل الـ 5 أيام موجودين في الـ Map عشان الـ UI ميتلخبطش
          for (int i = 0; i < weekDays.length; i++) {
            if (!sanitizedPlan.containsKey(i)) {
              sanitizedPlan[i] = [];
            }
          }

          _weeklyData.addAll(_normalizeCachedPlanDates(sanitizedPlan));
          print("✅ Cached Plan Loaded Safely: ${_weeklyData.length} days processed.");
        }
      }
      _emitUpdatedState();
    } catch (e) {
      print("❌ Init Error: $e");
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
// 1️⃣ تأمين دالة الـ resetPlan بالـ await
  Future<void> resetPlan() async {
    // ✅ الفحص الذكي: لو الصندوق مش مفتوح بالكامل استناه يفتح فوراً ومنع الكراش
    final box = Hive.isBoxOpen('weekly_visits_box')
        ? Hive.box('weekly_visits_box')
        : await Hive.openBox('weekly_visits_box');
        
    await box.clear();

    _weeklyData.forEach((key, value) => value.clear());

    _isSuccessfullyUploaded = false;

    _emitUpdatedState();
    print("✅ Plan Reset Successfully.");
  }

  // 2️⃣ تأمين دالة الـ clearCacheIfExpired بالـ await
  void clearCacheIfExpired() async { // ضيفنا async هنا
    if (await _isCacheExpired()) { // ضيفنا await هنا
      // ✅ تأمين الصندوق بـ await فوراً
      final box = Hive.isBoxOpen('weekly_visits_box')
          ? Hive.box('weekly_visits_box')
          : await Hive.openBox('weekly_visits_box');
          
      await box.clear();

      emit(WeeklyPlanInitial());
      print(" Cache expired and cleared.");
    }
  }

  // 3️⃣ تأمين دالة فحص الكاش _isCacheExpired
  Future<bool> _isCacheExpired() async {
    // ✅ تأمين صندوق الـ settings برضه عشان نضمن السلامة 100%
    final settingsBox = Hive.isBoxOpen('settings')
        ? Hive.box('settings')
        : await Hive.openBox('settings');

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
    if (isClosed) return;

    emit(WeeklyPlanLoading(
      weeklyData: Map.from(_weeklyData),
      selectedDayIndex: selectedDayIndex,
      tempVisit: _tempVisit,
      completionRate: _calculateCompletion,
    ));

    try {
      await saveVisitUseCase.repository.syncPlanStatusWithServer();
      
      // ✅ التعديل هنا: ضيفنا await لأن الدالة بقت Future ومضمونة
      final updatedPlan = await saveVisitUseCase.repository.getLocalPlan();

      _weeklyData.clear();
      _weeklyData.addAll(updatedPlan);

      _emitUpdatedState();
    } catch (e) {
      print(" Error in refreshPlanStatus: $e"); // عشان لو فيه حاجة تانية تبان في الـ Log
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
    // ✅ حماية إضافية ضد الـ Bad State قبل أي emit
    if (isClosed) return;

    emit(WeeklyPlanUpdated(
      weeklyData: Map.from(_weeklyData),
      selectedDayIndex: selectedDayIndex,
      completionRate: _calculateCompletion,
      tempVisit: _tempVisit,
      error: error,
    ));
  }

  void forceEnableSubmission() {
    if (isClosed) return;

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