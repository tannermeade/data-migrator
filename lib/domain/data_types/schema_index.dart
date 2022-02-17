import 'schema_attribute.dart';
import 'enums.dart';

class SchemaIndex {
  SchemaIndex({
    required this.indexId,
    required this.type,
    required this.attributes,
  });

  String indexId;
  SchemaIndexType type;
  List<SchemaAttribute> attributes;
}
