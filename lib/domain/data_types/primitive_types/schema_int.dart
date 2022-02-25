import 'package:data_migrator/domain/data_types/enums.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_default_value.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_nullable.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_typed.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_signed.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_size.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';

class SchemaInt
    implements SchemaDataType, SchemaNullable, SchemaSigned, SchemaSizeRange, SchemaDefaultValue, SchemaTyped {
  SchemaInt({
    this.nullable = true,
    required this.type,
    this.signed = true,
    this.defaultValue,
    this.min,
    this.max,
  });

  @override
  bool nullable;

  @override
  IntType type;
  @override
  set typeByEnum(Enum value) {
    if (value is IntType) type = value;
  }

  @override
  bool signed;
  @override
  int? defaultValue;
  @override
  set defaultValueByDynamic(value) {
    try {
      if (value is String) value = int.parse(value);
    } catch (e) {}
    if (value is int || value is int?) defaultValue = value;
  }

  @override
  int? min;
  @override
  set minByDynamic(value) {
    if (value is int || value is int?) min = value;
  }

  @override
  int? max;
  @override
  set maxByDynamic(value) {
    if (value is int || value is int?) max = value;
  }

  SchemaInt.object()
      : type = IntType.int,
        signed = true,
        defaultValue = 0,
        nullable = true;

  @override
  bool isOfType(data) {
    return data is int;
  }

  static SchemaInt copyWith(
    SchemaInt obj, {
    IntType? type,
    bool? signed,
    int? defaultValue,
    int? min,
    int? max,
    bool? nullable,
  }) {
    return SchemaInt(
      type: type ?? obj.type as IntType,
      signed: signed ?? obj.signed,
      defaultValue: defaultValue ?? obj.defaultValue,
      min: min ?? obj.min,
      max: max ?? obj.max,
      nullable: nullable ?? obj.nullable,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SchemaInt &&
      other.type == type &&
      other.defaultValue == defaultValue &&
      other.max == max &&
      other.min == min &&
      other.signed == signed &&
      other.nullable == nullable;

  @override
  int get hashCode => Object.hash(
        type,
        defaultValue,
        max,
        min,
        signed,
        nullable,
      );

  @override
  String toString() => "SchemaInt(${type.name})";

  @override
  String readableString() => "int";
}
