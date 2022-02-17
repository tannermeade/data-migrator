import 'permission_model.dart';
import 'schema_data_type.dart';
import 'schema_field.dart';
import 'schema_index.dart';

class SchemaMap implements SchemaDataType {
  SchemaMap({
    required this.name,
    this.id,
    this.fields = const [],
    this.indexList = const [],
    this.permissionModel,
    this.lastUpdated,
    this.createdOn,
    this.enabled,
    this.mutable = true,
  });

  String name;
  String? id;
  List<SchemaField> fields;
  List<SchemaIndex> indexList;
  PermissionModel? permissionModel;
  DateTime? lastUpdated;
  DateTime? createdOn;
  bool? enabled;
  bool mutable;

  @override
  bool isOfType(data) {
    return data is SchemaMap;
  }

  @override
  String toString() {
    return "SchemaMap(\n\tname:$name, \n\tfields:$fields\n)";
  }

  @override
  String readableString() => "map";
}
