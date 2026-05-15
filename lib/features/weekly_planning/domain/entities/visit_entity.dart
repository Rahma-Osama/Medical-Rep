class VisitEntity {
  final String? visitId; 
  final String? brick;
  final String? doctor;
  final String shift;
  final String type;
  final String? notes;
  final String? date;
  final String? dayName;

  VisitEntity({
    this.visitId, 
    this.brick,
    this.doctor,
    this.shift = "AM",
    this.type = "Single",
    this.notes = "",
    this.date,
    this.dayName,
  });

  bool get isValid => doctor != null && doctor!.isNotEmpty && brick != null;

 
  VisitEntity copyWith({
    String? visitId,
    String? brick,
    String? doctor,
    String? shift,
    String? type,
    String? notes,
    String? date,
    String? dayName,
  }) {
    return VisitEntity(
      visitId: visitId ?? this.visitId, // 🔹 مهم جداً عشان الـ ID ميفقدش أثناء التعديل
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