import 'package:data_migrator/domain/data_types/enums.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_object.dart';

import 'permission_model.dart';
import 'schema_data_type.dart';
import 'schema_field.dart';
import 'schema_index.dart';

class SchemaMap implements SchemaDataType, SchemaObject {
  SchemaMap({
    required this.name,
    this.id,
    List<SchemaField> fields = const [],
    List<SchemaIndex> indices = const [],
    this.permissionModel,
    this.lastUpdated,
    this.createdOn,
    this.enabled,
    this.mutable = true,
    this.classification = SchemaClassification.regular,
  })  : fields = List.unmodifiable(fields),
        indices = List.unmodifiable(indices);

  final String name;
  final String? id;
  final List<SchemaField> fields;
  final List<SchemaIndex> indices;
  final PermissionModel? permissionModel;
  final DateTime? lastUpdated;
  final DateTime? createdOn;
  final bool? enabled;
  final bool mutable;
  final SchemaClassification classification;

  SchemaMap.copyWith(
    SchemaMap other, {
    String? name,
    String? id,
    List<SchemaField>? fields,
    List<SchemaIndex>? indices,
    PermissionModel? permissionModel,
    DateTime? lastUpdated,
    DateTime? createdOn,
    bool? enabled,
    bool? mutable,
    SchemaClassification? classification,
  })  : name = name ?? other.name,
        id = id ?? other.id,
        fields = fields ?? other.fields,
        indices = indices ?? other.indices,
        permissionModel = permissionModel ?? other.permissionModel,
        lastUpdated = lastUpdated ?? other.lastUpdated,
        createdOn = createdOn ?? other.createdOn,
        enabled = enabled ?? other.enabled,
        mutable = mutable ?? other.mutable,
        classification = classification ?? other.classification;

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
