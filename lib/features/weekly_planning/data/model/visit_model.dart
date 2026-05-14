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
  @HiveField(8)
  String? specialty;

  @HiveField(9)
  String? clinicName;

  @HiveField(10)
  String? location;

  @HiveField(11)
  String? targetProduct;
  VisitModel({
    this.brick,
    this.doctor,
    this.shift = "AM",
    this.type = "Single",
    this.notes = "",
    this.date,
    this.dayName,
    this.status = "pending",
    this.specialty,
    this.clinicName,
    this.location,
    this.targetProduct,
  });

  // التحويل لـ JSON متوافق 100% مع أسماء أعمدة الداتا بيز
// التعديل الأفضل في toJson
Map<String, dynamic> toJson() => {
      "visit_date": date,
      "day_name": dayName,
      "brick": brick,
      "doctor_name": doctor,
      "shift": shift,
      "visit_type": type,
      "notes": notes,
      "status": status,
  "specialty": specialty,
  "clinic_name": clinicName,
  "location": location,
  "target_product": targetProduct,
    };
      factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
  
      doctor: json['doctor_name'], // اتأكدي إن الاسم هنا زي اللي في سوبابيز
      date: json['visit_date'],
      dayName: json['day_name'],
      brick: json['brick'],
      status: json['status'] ?? 'pending',
      shift: json['shift'],
      specialty: json['specialty'],
      clinicName: json['clinic_name'],
      location: json['location'],
      targetProduct: json['target_product'],
    );
  }
}