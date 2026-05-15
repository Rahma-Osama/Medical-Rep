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
  String? date;

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

  // 1. إضافة الـ ID اللي سوبابيز بيستخدمه (UUID)
  @HiveField(13)
  String? visitId;

  VisitModel({
    this.visitId, // أضفناه هنا
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

  // 2. تحديث toJson عشان تشمل الـ ID لو موجود
  Map<String, dynamic> toJson() => {
    "id": visitId, // مهم جداً للـ Update
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
    "location": null,
    "target_product": targetProduct,
  };

  // 3. تحديث fromJson عشان تقرأ الـ ID (الـ UUID) من سوبابيز
  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      visitId: json['id']?.toString(), // قراءة الـ UUID من عمود id
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
      lat: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      long: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      targetProduct: json['target_product'],
    );
  }
}