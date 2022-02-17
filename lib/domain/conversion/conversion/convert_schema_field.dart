import 'package:data_migrator/domain/conversion/type_adpaters/type_adapter.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';

import 'convert_schema_obj.dart';
import 'enums.dart';

class ConvertSchemaField implements ConvertSchemaObj {
  ConvertSchemaField({
    this.sourceSchemaField,
    this.destinationSchemaField,
    this.connectionType,
    List<TypeAdapter>? typeAdapters,
  }) : typeAdapters = typeAdapters ?? [];

  List<int>? sourceSchemaField;
  List<int>? destinationSchemaField;
  ConnectionType? connectionType;
  List<TypeAdapter> typeAdapters;

  static ConvertSchemaField fromSource({required SchemaField schemaField, required List<int> address}) {
    return ConvertSchemaField(
      sourceSchemaField: address,
      // connectionType: ConnectionType.direct,
      typeAdapters: [],
    );
  }

  @override
  String toString() {
    return """ConvertSchemaField(
        source: $sourceSchemaField,
        destination: $destinationSchemaField,
        connectionType: $connectionType,
        typeAdapters: $typeAdapters,
      )""";
  }
}
