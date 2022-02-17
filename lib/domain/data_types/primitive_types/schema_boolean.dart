import 'package:data_migrator/domain/data_types/interfaces/schema_default_value.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_nullable.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';

class SchemaBoolean implements SchemaDataType, SchemaNullable, SchemaDefaultValue {
  SchemaBoolean({
    this.nullable = true,
    this.defaultValue,
  });

  SchemaBoolean.object() : nullable = true;

  @override
  bool nullable;
  @override
  bool? defaultValue;
  @override
  set defaultValueByDynamic(value) {
    if (value is bool || value is bool?) defaultValue = value;
  }

  @override
  String toString() => "SchemaBoolean()";

  @override
  bool isOfType(data) {
    return data is bool;
  }

  @override
  bool operator ==(Object other) =>
      other is SchemaBoolean && other.defaultValue == defaultValue && other.nullable == nullable;

  @override
  int get hashCode => Object.hash(defaultValue, nullable);

  @override
  String readableString() => "boolean";
}
