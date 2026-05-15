class VisitEntity {
  final String visitId;
  final String doctorName;
  final String specialty;
  final String clinicName;
  final String location;
  final String shift;
  final String targetProduct;
  final DateTime startTime;
  final DateTime? lastSeenTime;

  const VisitEntity({
    required this.visitId,
    required this.doctorName,
    required this.specialty,
    required this.clinicName,
    required this.location,
    required this.shift,
    required this.targetProduct,
    required this.startTime,
    this.lastSeenTime,
  });
}