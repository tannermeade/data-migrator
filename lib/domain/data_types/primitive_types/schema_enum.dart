import 'package:data_migrator/domain/data_types/interfaces/schema_default_value.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_nullable.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';

class SchemaEnum implements SchemaDataType, SchemaNullable, SchemaDefaultValue {
  SchemaEnum({
    this.nullable = true,
    required this.elements,
    this.defaultValue,
  });

  @override
  bool nullable;
  List<String> elements;
  @override
  String? defaultValue;
  @override
  set defaultValueByDynamic(value) {
    if (value is String || value is String?) defaultValue = value;
  }

  @override
  String toString() => "SchemaEnum()";

  @override
  bool isOfType(data) {
    return data is List<String>;
  }

  @override
  bool operator ==(Object other) =>
      other is SchemaEnum &&
      other.elements.fold(true, (prevVal, el) => prevVal && other.elements.contains(el)) &&
      other.defaultValue == defaultValue &&
      other.nullable == nullable;

  @override
  int get hashCode => Object.hash(Object.hashAll(elements), defaultValue, nullable);

  @override
  String readableString() => "enum";
}
