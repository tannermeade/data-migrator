import 'package:data_migrator/domain/data_types/schema_data_type.dart';

abstract class TypeAdapter {
  TypeAdapter({
    required this.sourceSchemaDataType,
    required this.destinationSchemaDataType,
  });

  SchemaDataType sourceSchemaDataType;
  SchemaDataType destinationSchemaDataType;

  dynamic convert(dynamic sourceData);
}
