import 'package:hive/hive.dart';
part 'visit_model.g.dart';

@HiveType(typeId: 0)
class VisitModel extends HiveObject {
  @HiveField(0)
  String? brick;

  @HiveField(1)
  String? doctor;

  @HiveField(2)
  String shift;

  @HiveField(3)
  String type;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  String? date; // التاريخ بصيغة String مؤقتاً

  @HiveField(6)
  String? dayName;
  @HiveField(7)
  String status;

  VisitModel({
    this.brick,
    this.doctor,
    this.shift = "AM",
    this.type = "Single",
    this.notes = "",
    this.date,
    this.dayName,
    this.status = "pending",
  });

  // التحويل لـ JSON متوافق 100% مع أسماء أعمدة الداتا بيز
  Map<String, dynamic> toJson() => {
        "visit_date": date,       // مطابق لـ visit_date
        "day_name": dayName,      // مطابق لـ day_name
        "brick": brick,           // مطابق لـ brick
        "doctor_name": doctor,    // مطابق لـ doctor_name
        "shift": shift,           // مطابق لـ shift
        "visit_type": type,       // مطابق لـ visit_type
        "notes": notes,           // مطابق لـ notes
        "status": "pending",      // مطابق لـ status
      };
}