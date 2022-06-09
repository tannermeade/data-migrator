import 'package:console_flutter_sdk/models.dart';
import 'package:data_migrator/domain/data_types/enums.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_boolean.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_float.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_int.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_string.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';

class AppwriteSchemaModification {
  static void addSchemaFromSchema(List<SchemaMap> sourceSchema, Function(SchemaMap) addToSchema) {
    for (int i = 0; i < sourceSchema.length; i++) {
      addToSchema(SchemaMap(
        name: sourceSchema[i].name,
        mutable: true,
        fields: sourceSchema[i].fields.map((f) {
          var types = convertTypes(f.types);
          return SchemaField(
            title: f.title,
            types: types.isEmpty ? [SchemaString.object()] : types,
            isList: f.isList,
            required: f.required,
          );
        }).toList(),
      ));
    }
  }

  static List<SchemaDataType> convertTypes(List<SchemaDataType> types) {
    Set<SchemaDataType> convertedTypes = {};
    for (var type in types) {
      if (type is SchemaString) {
        convertedTypes.add(SchemaString.copyWith(type));
      } else if (type is SchemaInt) {
        convertedTypes.add(SchemaInt.copyWith(type));
      } else if (type is SchemaFloat) {
        convertedTypes.add(SchemaFloat.copyWith(type));
      } else if (type is SchemaBoolean) {
        convertedTypes.add(type);
      }
    }
    return convertedTypes.toList();
  }

  static List<SchemaMap> collectionsToSchema(CollectionList collectionsList) {
    List<SchemaMap> schemaMaps = [];
    for (var collection in collectionsList.collections) {
      schemaMaps.add(collectionToSchemaMap(collection));
    }

    return schemaMaps;
  }

  static SchemaMap collectionToSchemaMap(Collection collection) {
    List<SchemaField> fields = [];
    for (var attr in collection.attributes) {
      if (attr is Map) {
        var key = attr["key"] ?? "";
        var type = attr["type"] ?? "";
        var status = attr["status"] ?? "";
        var required = attr["required"] ?? "";
        var isArray = attr["array"] ?? "";
        List<SchemaDataType> types = [];
        switch (type) {
          case 'integer':
            types.add(SchemaInt(
              type: IntType.int,
              signed: true,
              min: attr["min"] is String ? int.parse(attr["min"]) : attr["min"],
              max: attr["max"] is String ? int.parse(attr["max"]) : attr["max"],
              defaultValue: attr["default"] is String ? int.parse(attr["default"]) : attr["default"],
            ));
            break;
          case 'double':
            types.add(SchemaFloat(
              type: FloatType.double,
              signed: true,
              min: attr["min"] is String ? double.parse(attr["min"]) : attr["min"],
              max: attr["max"] is String ? double.parse(attr["max"]) : attr["max"],
            ));
            break;
          case 'string':
            types.add(SchemaString(
              type: StringType.text,
              size: attr["size"] is String ? int.parse(attr["size"]) : attr["size"],
              defaultValue: attr["default"],
            ));
            break;
          // case '':
          //   break;
          // case '':
          //   break;
          default:
            break;
        }
        FieldStatus fieldStatus;
        switch (status) {
          case "available":
            fieldStatus = FieldStatus.available;
            break;
          case "failed":
            fieldStatus = FieldStatus.failed;
            break;
          case "processing":
            fieldStatus = FieldStatus.processing;
            break;
          default:
            fieldStatus = FieldStatus.none;
        }

        fields.add(SchemaField(
          isList: isArray,
          required: required,
          title: key,
          types: types,
          status: fieldStatus,
        ));
      }
    }

    return SchemaMap(
      name: collection.name,
      id: collection.$id,
      fields: fields,
      mutable: true,
    );
  }
}
