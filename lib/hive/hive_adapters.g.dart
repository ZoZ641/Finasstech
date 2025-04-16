// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(fields[0] as String, fields[1] as String);
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 1;

  @override
  Budget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Budget(
      id: fields[0] as String,
      forecastedSales: (fields[1] as num).toDouble(),
      categories: (fields[2] as Map).cast<String, BudgetCategory>(),
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.forecastedSales)
      ..writeByte(2)
      ..write(obj.categories)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BudgetCategoryAdapter extends TypeAdapter<BudgetCategory> {
  @override
  final int typeId = 2;

  @override
  BudgetCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetCategory(
      name: fields[0] as String,
      percentage: (fields[1] as num).toDouble(),
      amount: (fields[2] as num).toDouble(),
      minRecommendedPercentage: (fields[3] as num).toDouble(),
      maxRecommendedPercentage: (fields[4] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, BudgetCategory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.percentage)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.minRecommendedPercentage)
      ..writeByte(4)
      ..write(obj.maxRecommendedPercentage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
