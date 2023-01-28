import 'package:data_migrator/domain/data_types/schema_map.dart';

import 'convert_schema_field.dart';
import 'convert_schema_obj.dart';

class ConvertSchemaMap implements ConvertSchemaObj {
  ConvertSchemaMap({
    required this.fieldConversions,
    this.sourceSchemaMap,
    this.destinationSchemaMap,
  });

  List<ConvertSchemaField> fieldConversions;
  List<int>? sourceSchemaMap;
  List<int>? destinationSchemaMap;

  static ConvertSchemaMap fromSource({required SchemaMap schemaMap, required List<int> address}) {
    List<ConvertSchemaField> fields = [];
    for (int i = 0; i < schemaMap.fields.length; i++) {
      fields.add(ConvertSchemaField.fromSource(
        schemaField: schemaMap.fields[i],
        address: address + [i],
      ));
    }
    return ConvertSchemaMap(
      sourceSchemaMap: address,
      fieldConversions: fields,
    );
  }

  @override
  String toString() {
    return """ConvertSchemaMap(
      sourceSchemaMap:$sourceSchemaMap,
      destinationSchemaMap:$destinationSchemaMap,
      fieldConversions:$fieldConversions,
      )""";
  }
}
