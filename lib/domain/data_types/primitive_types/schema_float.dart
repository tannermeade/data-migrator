import 'package:data_migrator/domain/data_types/enums.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_default_value.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_nullable.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_typed.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_signed.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_size.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';

class SchemaFloat
    implements SchemaDataType, SchemaNullable, SchemaSigned, SchemaSizeRange, SchemaDefaultValue, SchemaTyped {
  SchemaFloat({
    this.nullable = true,
    required this.type,
    this.signed = true,
    this.min,
    this.max,
    this.defaultValue,
  });

  @override
  bool nullable;

  @override
  FloatType type;
  @override
  set typeByEnum(Enum value) {
    if (value is FloatType) type = value;
  }

  @override
  bool signed;
  @override
  double? min;
  @override
  set minByDynamic(value) {
    if (value is double || value is double?) min = value;
  }

  @override
  double? max;
  @override
  set maxByDynamic(value) {
    if (value is double || value is double?) max = value;
  }

  @override
  double? defaultValue;
  @override
  set defaultValueByDynamic(value) {
    if (value is double || value is double?) defaultValue = value;
  }

  SchemaFloat.object()
      : type = FloatType.double,
        signed = true,
        nullable = true;

  static SchemaFloat copyWith(
    SchemaFloat obj, {
    FloatType? type,
    bool? signed,
    double? min,
    double? max,
    double? defaultValue,
    bool? nullable,
  }) {
    return SchemaFloat(
      type: type ?? obj.type as FloatType,
      signed: signed ?? obj.signed,
      min: min ?? obj.min,
      max: max ?? obj.max,
      defaultValue: defaultValue,
      nullable: nullable ?? obj.nullable,
    );
  }

  @override
  bool isOfType(data) {
    return data is double;
  }

  @override
  bool operator ==(Object other) =>
      other is SchemaFloat &&
      other.type == type &&
      other.max == max &&
      other.min == min &&
      other.signed == signed &&
      other.defaultValue == defaultValue &&
      other.nullable == nullable;

  @override
  int get hashCode => Object.hash(
        type,
        max,
        min,
        signed,
        defaultValue,
        nullable,
      );

  @override
  String toString() => "SchemaFloat()";

  @override
  String readableString() => "float";
}
