import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/visit_entity.dart';
import '../domain/usecases/save_visit_usecase.dart';
import '../domain/usecases/submit_plan_usecase.dart';
import 'weekly_plan_state.dart';

// ملاحظة: تأكدي أن الـ WeeklyDataModel في الـ state أصبح يحتوي على List<VisitEntity> لكل يوم
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

  // تخزين البيانات: كل يوم يحتوي على قائمة من الزيارات
  final Map<int, List<VisitEntity>> _weeklyData = {
    0: [], // Saturday
    1: [], // Sunday
    2: [], // Monday
    3: [], // Tuesday
    4: [], // Wednesday
  };

  // كائن مؤقت لتخزين الاختيارات الحالية قبل الإضافة للقائمة
  VisitEntity _tempVisit = VisitEntity(shift: "AM", type: "Single");

  void _initData() {
    // هنا نفترض أن الـ LocalPlan يرجع الخريطة بالشكل الجديد
    // إذا كان الكود القديم يرجع زيارة واحدة، ستحتاجين لتعديل الـ Repository أيضاً
    _emitUpdatedState();
  }

  String _getDateForDay(int index) {
    DateTime now = DateTime.now();
    DateTime targetDate = now.add(Duration(days: index)); 
    return "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
  }

  void selectDay(int index) {
    selectedDayIndex = index;
    // عند تغيير اليوم، نصفر النموذج المؤقت
    _tempVisit = VisitEntity(shift: "AM", type: "Single");
    _emitUpdatedState();
  }

  // تحديث البيانات في النموذج المؤقت (قبل الإضافة للقائمة)
  void tempUpdateField(String field, dynamic value) {
    _tempVisit = _tempVisit.copyWith(
      brick: field == "brick" ? value : _tempVisit.brick,
      doctor: field == "doctor" ? value : (field == "brick" ? null : _tempVisit.doctor),
      shift: field == "shift" ? value : _tempVisit.shift,
      type: field == "type" ? value : _tempVisit.type,
      notes: field == "notes" ? value : _tempVisit.notes,
      date: _getDateForDay(selectedDayIndex),
      dayName: weekDays[selectedDayIndex],
    );
    _emitUpdatedState();
  }

  // إضافة الزيارة المؤقتة إلى قائمة اليوم المختار
  void addVisitToDay() {
    if (_tempVisit.doctor == null || _tempVisit.brick == null) {
      emit(WeeklyPlanError("Please select Brick and Doctor first"));
      _emitUpdatedState();
      return;
    }

    // التحقق من عدم تكرار الدكتور في نفس اليوم
    final currentDayVisits = _weeklyData[selectedDayIndex]!;
    bool isDuplicate = currentDayVisits.any((v) => v.doctor == _tempVisit.doctor);

    if (isDuplicate) {
      emit(WeeklyPlanError("This doctor is already added for today!"));
      _emitUpdatedState();
      return;
    }

    // إضافة الزيارة وتصفير المؤقت
    _weeklyData[selectedDayIndex]!.add(_tempVisit);
    _tempVisit = VisitEntity(shift: "AM", type: "Single"); // إعادة تعيين للزيارة القادمة
    
    _emitUpdatedState();
  }

  // حذف زيارة من القائمة
  void removeVisitFromDay(int visitIndex) {
    _weeklyData[selectedDayIndex]!.removeAt(visitIndex);
    _emitUpdatedState();
  }

  Future<void> submitPlan() async {
    if (!isPlanComplete) {
      emit(WeeklyPlanError("Please add at least one visit for each day!"));
      _emitUpdatedState();
      return;
    }

    emit(WeeklyPlanLoading());
    try {
      // تحويل الـ Map لقائمة مسطحة لإرسالها لـ UseCase
      List<VisitEntity> allVisits = [];
      _weeklyData.values.forEach((list) => allVisits.addAll(list));

      // ملاحظة: ستحتاجين لتعديل الـ UseCase ليقبل List<VisitEntity> أو Map المحدثة
      await saveVisitUseCase.repository.saveWeeklyPlan(_weeklyData); 
      await submitPlanUseCase.call();
      
      emit(WeeklyPlanSuccess());
    } catch (e) {
      emit(WeeklyPlanError("Sync Failed: ${e.toString()}"));
      _emitUpdatedState();
    }
  }

  List<String> getFilteredDoctors() {
    final brick = _tempVisit.brick;
    if (brick == "Maadi") return ["Dr. Ahmed Ali", "Dr. Sara Hassan"];
    if (brick == "Nasr City") return ["Dr. John Doe", "Dr. Mona Samy"];
    if (brick == "Dokki") return ["Dr. Khaled Zaki", "Dr. Reham"];
    return [];
  }

  // الخطة تكتمل إذا كان كل يوم فيه على الأقل زيارة واحدة (أو حسب شروطك)
  bool get isPlanComplete => _weeklyData.values.every((list) => list.isNotEmpty);

  double get _calculateCompletion {
    int daysWithVisits = _weeklyData.values.where((list) => list.isNotEmpty).length;
    return daysWithVisits / weekDays.length;
  }

  void _emitUpdatedState() {
    emit(WeeklyPlanUpdated(
      weeklyData: _weeklyData, // تأكدي أن الـ State يقبل Map<int, List<VisitEntity>>
      selectedDayIndex: selectedDayIndex,
      completionRate: _calculateCompletion,
      tempVisit: _tempVisit, // مرري الزيارة المؤقتة للـ UI ليعرض الاختيارات الحالية
    ));
  }
}

// ملحق: إضافة دالة copyWith للـ VisitEntity إذا لم تكن موجودة لتسهيل التحديث
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