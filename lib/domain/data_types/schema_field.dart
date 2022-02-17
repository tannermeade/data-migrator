import 'package:data_migrator/domain/data_types/primitive_types/schema_boolean.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_float.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_int.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_string.dart';

import 'schema_data_type.dart';

class SchemaField {
  SchemaField({
    required List<SchemaDataType> types,
    required String title,
    required bool isList,
    required bool required,
  })  : _types = types,
        _title = title,
        _isList = isList,
        _required = required;

  List<SchemaDataType> _types;
  String _title;
  bool _isList;
  bool _required;

  List<SchemaDataType> get types => _types;
  String get title => _title;
  bool get isList => _isList;
  bool get required => _required;

  set types(List<SchemaDataType> data) => _types = _validateTypes(data);
  set title(String data) => _title = _validateTitle(data);
  set isList(bool data) => _isList = _validateIsList(data);
  set required(bool data) => _required = _validateRequired(data);

  List<SchemaDataType> _validateTypes(List<SchemaDataType> data) => data;
  String _validateTitle(String data) => data;
  bool _validateIsList(bool data) => data;
  bool _validateRequired(bool data) => data;

  void setTypes(Set<Type> objTypes) {
    for (var type in objTypes) {
      if (type == String) {
        _types.add(SchemaString.object());
      } else if (type == int) {
        _types.add(SchemaInt.object());
      } else if (type == double) {
        _types.add(SchemaFloat.object());
      } else if (type == bool) {
        _types.add(SchemaBoolean.object());
      }
    }
  }

  @override
  String toString() {
    // return "SchemaField(\n\t\ttypes:$types, \n\t\ttitle:$title, \n\t\tisList:$isList, \n\t\trequired:$required\n)";
    return "SchemaField($_title[$_types])";
  }
}
