// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_feedback_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingFeedbackHiveModelAdapter
    extends TypeAdapter<PendingFeedbackHiveModel> {
  @override
  final int typeId = 2;

  @override
  PendingFeedbackHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingFeedbackHiveModel(
      visitId: fields[0] as String,
      interestLevel: fields[1] as String,
      sampleGiven: fields[2] as bool,
      followUpRequired: fields[3] as bool,
      notes: fields[4] as String,
      submittedAt: fields[5] as DateTime,
      doctorName: fields[6] as String,
      clinicName: fields[7] as String,
      targetProduct: fields[10] as String?,
      isSynced: fields[8] as bool,
      endTime: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PendingFeedbackHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.visitId)
      ..writeByte(1)
      ..write(obj.interestLevel)
      ..writeByte(2)
      ..write(obj.sampleGiven)
      ..writeByte(3)
      ..write(obj.followUpRequired)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.submittedAt)
      ..writeByte(6)
      ..write(obj.doctorName)
      ..writeByte(7)
      ..write(obj.clinicName)
      ..writeByte(8)
      ..write(obj.isSynced)
      ..writeByte(9)
      ..write(obj.endTime)
      ..writeByte(10)
      ..write(obj.targetProduct);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingFeedbackHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
