// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductHiveAdapter extends TypeAdapter<ProductHive> {
  @override
  final int typeId = 0;

  @override
  ProductHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductHive()
      ..remoteId = fields[0] as String
      ..name = fields[1] as String
      ..description = fields[2] as String
      ..price = fields[3] as double
      ..imageUrl = fields[4] as String
      ..isSynced = fields[5] == null ? true : fields[5] as bool
      ..isDeleted = fields[6] == null ? false : fields[6] as bool;
  }

  @override
  void write(BinaryWriter writer, ProductHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.remoteId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.isSynced)
      ..writeByte(6)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
