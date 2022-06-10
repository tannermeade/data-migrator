import 'package:data_migrator/domain/data_types/enums.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_default_value.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_nullable.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_typed.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_size.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';

class SchemaString implements SchemaDataType, SchemaNullable, SchemaSizeInt, SchemaDefaultValue, SchemaTyped {
  SchemaString({
    this.nullable = true,
    required this.type,
    this.size,
    this.defaultValue,
  });

  @override
  bool nullable;

  @override
  StringType type;
  @override
  set typeByEnum(Enum value) {
    if (value is StringType) type = value;
  }

  @override
  int? size;
  @override
  String? defaultValue;
  @override
  set defaultValueByDynamic(value) {
    if (value is String || value is String?) defaultValue = value;
  }

  SchemaString.object()
      : type = StringType.text,
        nullable = true;

  static SchemaString copyWith(SchemaString obj, {StringType? type, int? size, bool? nullable}) {
    return SchemaString(
      type: type ?? obj.type as StringType,
      size: size ?? obj.size,
      nullable: nullable ?? obj.nullable,
    );
  }

  @override
  bool isOfType(data) {
    return data is String;
  }

  @override
  bool operator ==(Object other) =>
      other is SchemaString && other.type == type && other.size == size && other.nullable == nullable;

  @override
  int get hashCode => Object.hash(type, size, nullable);

  @override
  String toString() => "SchemaString(${type.name})";

  @override
  String readableString() => "string(${type.name})";
}
