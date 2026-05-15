import '../../domain/entities/medical_entity.dart';

class MedicalModel extends MedicalEntity {
  MedicalModel({
    required super.name,
    required super.specialty,
    required super.category,
    required super.hospital,
    required super.phone,
    required super.email,
    required super.address,
  });

  // من JSON (السحب من سوبابيس للتطبيق)
  factory MedicalModel.fromJson(Map<String, dynamic> json) {
    return MedicalModel(
      // بنقرأ 'name' ولو مش موجود بنحط 'Unknown'
      name: json['name'] ?? 'Unknown',

      // بنقرأ 'specialization' من سوبابيس ونخزنها في 'specialty' اللي في الـ Entity
      specialty: json['specialization'] ?? 'General',

      category: json['category'] ?? 'N/A',
      hospital: json['hospital'] ?? 'N/A',
      phone: json['phone'] ?? 'No Phone',
      email: json['email'] ?? 'No Email',

      // بنقرأ 'address_name' من سوبابيس ونخزنها في 'address' اللي في الـ Entity
      address: json['address_name'] ?? 'No Address',
    );
  }

  // إلى JSON (الرفع من التطبيق لسوبابيس)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      // هنا بنرجع الأسماء لأصلها اللي سوبابيس بيفهمه
      'specialization': specialty,
      'category': category,
      'hospital': hospital,
      'phone': phone,
      'email': email,
      'address_name': address,
    };
  }
}