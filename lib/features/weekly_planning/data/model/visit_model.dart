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
  double? lat;

  @HiveField(11)
  double? long;

  @HiveField(12)
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
    this.lat,
    this.long,
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
  "lat": lat,
  "long": long,
  "target_product": targetProduct,
    };
  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      doctor: json['doctor_name'],
      date: json['visit_date'],
      dayName: json['day_name'],
      brick: json['brick'],
      status: json['status'] ?? 'pending',
      shift: json['shift'] ?? 'AM',
      type: json['visit_type'] ?? 'Single',
      notes: json['notes'] ?? '',
      specialty: json['specialty'],
      clinicName: json['clinic_name'],
      lat: json['lat']?.toDouble(),
      long: json['long']?.toDouble(),
      targetProduct: json['target_product'],
    );
  }}