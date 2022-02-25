import 'package:data_migrator/domain/data_types/interfaces/schema_object.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_boolean.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_float.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_int.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_string.dart';

import 'enums.dart';
import 'schema_data_type.dart';

class SchemaField implements SchemaObject {
  SchemaField({
    List<SchemaDataType>? types,
    Set<Type>? objTypes,
    required this.title,
    required this.isList,
    required this.required,
    this.status,
  })  : assert(types != null || objTypes != null),
        types = List.unmodifiable(types ?? SchemaField.setTypes(objTypes ?? {}));

  final List<SchemaDataType> types;
  final String title;
  final bool isList;
  final bool required;
  final FieldStatus? status;

  SchemaField.copyWith(
    SchemaField other, {
    List<SchemaDataType>? types,
    String? title,
    bool? isList,
    bool? required,
    FieldStatus? status,
  })  : types = types ?? other.types,
        title = title ?? other.title,
        isList = isList ?? other.isList,
        required = required ?? other.required,
        status = status ?? other.status;

  static List<SchemaDataType> setTypes(Set<Type> objTypes) {
    List<SchemaDataType> types = [];
    for (var type in objTypes) {
      if (type == String) {
        types.add(SchemaString.object());
      } else if (type == int) {
        types.add(SchemaInt.object());
      } else if (type == double) {
        types.add(SchemaFloat.object());
      } else if (type == bool) {
        types.add(SchemaBoolean.object());
      }
    }
    return types;
  }

  @override
  String toString() {
    // return "SchemaField(\n\t\ttypes:$types, \n\t\ttitle:$title, \n\t\tisList:$isList, \n\t\trequired:$required\n)";
    return "SchemaField($title[$types])";
  }
}
