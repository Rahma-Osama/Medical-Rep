// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VisitModelAdapter extends TypeAdapter<VisitModel> {
  @override
  final int typeId = 0;

  @override
  VisitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VisitModel(
      visitId: fields[13] as String?,
      brick: fields[0] as String?,
      doctor: fields[1] as String?,
      shift: fields[2] as String,
      type: fields[3] as String,
      notes: fields[4] as String?,
      date: fields[5] as String?,
      dayName: fields[6] as String?,
      status: fields[7] as String,
      specialty: fields[8] as String?,
      clinicName: fields[9] as String?,
      lat: fields[10] as double?,
      long: fields[11] as double?,
      targetProduct: fields[12] as String?,
      adminFeedback: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VisitModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.brick)
      ..writeByte(1)
      ..write(obj.doctor)
      ..writeByte(2)
      ..write(obj.shift)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.dayName)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.specialty)
      ..writeByte(9)
      ..write(obj.clinicName)
      ..writeByte(10)
      ..write(obj.lat)
      ..writeByte(11)
      ..write(obj.long)
      ..writeByte(12)
      ..write(obj.targetProduct)
      ..writeByte(13)
      ..write(obj.visitId)
      ..writeByte(14)
      ..write(obj.adminFeedback);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
