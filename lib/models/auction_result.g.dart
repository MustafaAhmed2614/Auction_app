// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuctionResultAdapter extends TypeAdapter<AuctionResult> {
  @override
  final int typeId = 2;

  @override
  AuctionResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuctionResult(
      id: fields[0] as String,
      player: fields[1] as Player,
      winningTeam: fields[2] as Team,
      finalPrice: fields[3] as int,
      timestamp: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AuctionResult obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.player)
      ..writeByte(2)
      ..write(obj.winningTeam)
      ..writeByte(3)
      ..write(obj.finalPrice)
      ..writeByte(4)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuctionResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
