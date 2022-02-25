import 'package:data_migrator/domain/data_types/enums.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_default_value.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_nullable.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_typed.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';

class SchemaDate implements SchemaDataType, SchemaNullable, SchemaDefaultValue, SchemaTyped {
  SchemaDate({
    this.nullable = true,
    this.defaultValue,
    required this.type,
  });

  @override
  bool nullable;
  @override
  DateTime? defaultValue;
  @override
  set defaultValueByDynamic(value) {
    if (value is DateTime || value is DateTime?) defaultValue = value;
  }

  @override
  DateType type;
  @override
  set typeByEnum(Enum value) {
    if (value is DateType) type = value;
  }

  @override
  String toString() => "SchemaDate(${type.name})";

  @override
  bool isOfType(data) {
    if (data is! String) return false;

    try {
      DateTime.parse(data);
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  @override
  bool operator ==(Object other) => other is SchemaDate && other.nullable == nullable;

  @override
  int get hashCode => Object.hash(defaultValue, nullable);

  @override
  String readableString() => "date";
}
