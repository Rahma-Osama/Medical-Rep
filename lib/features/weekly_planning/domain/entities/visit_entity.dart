class VisitEntity {
  final String? brick;
  final String? doctor;
  final String shift;
  final String type;
  final String? notes;

  VisitEntity({
    this.brick,
    this.doctor,
    this.shift = "AM",
    this.type = "Single",
    this.notes = "",
  });

  bool get isValid => brick != null && doctor != null;
}