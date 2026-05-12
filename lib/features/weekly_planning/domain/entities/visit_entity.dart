class VisitEntity {
  final String? brick;
  final String? doctor;
  final String shift;
  final String type;
  final String? notes;
  final String? date;
  final String? dayName;

  VisitEntity({
    this.brick,
    this.doctor,
    this.shift = "AM",
    this.type = "Single",
    this.notes = "",
    this.date,
    this.dayName,
  });

  bool get isValid => brick != null && doctor != null;

  // دالة ضرورية لتحديث القيم في الـ Cubit
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