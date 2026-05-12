
class VisitTaskEntity {
  final String id;
  final String title;
  final bool isDone;

  const VisitTaskEntity({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  VisitTaskEntity copyWith({bool? isDone}) {
    return VisitTaskEntity(
      id: id,
      title: title,
      isDone: isDone ?? this.isDone,
    );
  }
}