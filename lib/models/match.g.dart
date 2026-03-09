// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MatchAdapter extends TypeAdapter<Match> {
  @override
  final int typeId = 4;

  @override
  Match read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Match(
      id: fields[0] as String,
      team1: fields[1] as Team,
      team2: fields[2] as Team,
      matchNumber: fields[3] as int,
      isFinal: fields[4] as bool,
      isCompleted: fields[5] as bool,
      firstInnings: fields[6] as Innings?,
      secondInnings: fields[7] as Innings?,
      winner: fields[8] as Team?,
    );
  }

  @override
  void write(BinaryWriter writer, Match obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.team1)
      ..writeByte(2)
      ..write(obj.team2)
      ..writeByte(3)
      ..write(obj.matchNumber)
      ..writeByte(4)
      ..write(obj.isFinal)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.firstInnings)
      ..writeByte(7)
      ..write(obj.secondInnings)
      ..writeByte(8)
      ..write(obj.winner);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
