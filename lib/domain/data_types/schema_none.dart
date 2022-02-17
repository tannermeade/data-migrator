import 'schema_data_type.dart';

class SchemaDataTypeNone implements SchemaDataType {
  @override
  bool isOfType(data) => false;

  @override
  String readableString() => "none";
}
