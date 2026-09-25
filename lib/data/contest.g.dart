// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contest.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContestAdapter extends TypeAdapter<Contest> {
  @override
  final int typeId = 0;

  @override
  Contest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contest(
      id: fields[0] as int,
      duration: fields[1] as int,
      description: fields[6] as String,
      title: fields[4] as String,
      link: fields[5] as String,
      logoId: fields[7] as int,
      startDate: fields[2] as DateTime,
      endDate: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Contest obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.duration)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.link)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.logoId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContestAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
