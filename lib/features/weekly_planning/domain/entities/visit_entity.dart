class VisitEntity {
  final String? visitId; 
  final String? brick;
  final String? doctor;
  final String shift;
  final String type;
  final String? notes;
  final String? date;
  final String? dayName;
  // ✅ الأعمدة الجديدة اللي كانت ناقصة جوه الـ Entity:
    String status; 
  final String? managerNotes;

  VisitEntity({
    this.visitId, 
    this.brick,
    this.doctor,
    this.shift = "AM",
    this.type = "Single",
    this.notes = "",
    this.date,
    this.dayName,
    this.status = "pending", // ✅ القيمة الافتراضية لأي زيارة جديدة هي pending
    this.managerNotes,
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
    String? status,       // ✅ إضافة الـ status في الـ copyWith
    String? managerNotes, // ✅ إضافة الـ managerNotes في الـ copyWith
  }) {
    return VisitEntity(
      visitId: visitId ?? this.visitId, 
      brick: brick ?? this.brick,
      doctor: doctor ?? this.doctor,
      shift: shift ?? this.shift,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      dayName: dayName ?? this.dayName,
      status: status ?? this.status,             // ✅ تمرير القيمة الجديدة أو الحفاظ على القديمة
      managerNotes: managerNotes ?? this.managerNotes, // ✅ تمرير القيمة الجديدة أو الحفاظ على القديمة
    );
  }
}