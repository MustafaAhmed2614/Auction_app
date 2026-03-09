// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'innings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InningsAdapter extends TypeAdapter<Innings> {
  @override
  final int typeId = 3;

  @override
  Innings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Innings(
      battingTeam: fields[0] as Team,
      runs: fields[1] as int,
      wickets: fields[2] as int,
      ballsBowled: fields[3] as int,
      isCompleted: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Innings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.battingTeam)
      ..writeByte(1)
      ..write(obj.runs)
      ..writeByte(2)
      ..write(obj.wickets)
      ..writeByte(3)
      ..write(obj.ballsBowled)
      ..writeByte(4)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InningsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
