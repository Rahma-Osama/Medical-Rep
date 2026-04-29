import 'package:hive/hive.dart';

part 'visit_model.g.dart'; // هذا الملف سيتم توليده تلقائياً

@HiveType(typeId: 0) // رقم فريد لهذا الموديل
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

  VisitModel({
    this.brick,
    this.doctor,
    this.shift = "AM",
    this.type = "Single",
    this.notes = "",
  });

 bool get isDayComplete => brick != null && doctor != null;
// أضيفي هذه الميثود هنا:
  Map<String, dynamic> toJson() => {
        "brick": brick,
        "doctor": doctor,
        "shift": shift,
        "type": type,
        "notes": notes,
      };
}