import 'package:data_migrator/infastructure/confirmation/confirmation_data.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_object.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';

abstract class DataOrigin {
  DataOrigin();

  List<SchemaMap> getSchema();
  void deleteFromSchema({required SchemaObject schemaObj});
  void addToSchema({required SchemaObject newObj, required SchemaObject parentObj});
  void updateSchema({required SchemaObject newObj, required SchemaObject oldObj});

  Stream<List<List>>? getDataStream(List<int> schemaIndex);
  Stream<List<List>> startDataStream(List<int> schemaIndex);
  Stream<List<List>>? playDataStream(List<int> schemaIndex);
  void pauseDataStream(List<int> schemaIndex);
  void endDataStream(List<int> schemaIndex);

  Sink<List<List>>? getDataSink(List<int> schemaIndex);
  Future<Sink<List<List>>> openDataSink(List<int> schemaIndex);
  void closeDataSink(List<int> schemaIndex);

  Future<List<ConfirmationData>> validate();

  bool get isConversionReady;

  dynamic updateSchemaRecursive(dynamic obj, dynamic hashCode, SchemaObject newObj) {
    List list;
    if (obj is List) {
      list = obj;
    } else if (obj is SchemaMap) {
      list = obj.fields;
    } else if (obj is SchemaField) {
      list = obj.types;
    } else {
      return null;
    }

    // is old object in children list?
    for (int i = 0; i < list.length; i++) {
      if (list[i].hashCode == hashCode) {
        // reconstruct parent without child
        // return, so next level up can reconstruct grandparent with new parent
        if (obj is List<SchemaMap> && newObj is SchemaMap) {
          int x = 0;
          return list.map((el) => x++ == i ? newObj : el as SchemaMap).toList();
        } else if (obj is SchemaMap) {
          if (newObj is! SchemaField) throw Exception("Can't put a non-SchemaField in SchemaMap.fields.");
          int x = 0;
          return SchemaMap.copyWith(obj, fields: obj.fields.map((e) => x++ == i ? newObj : e).toList());
        } else if (obj is SchemaField) {
          if (newObj is! SchemaDataType) throw Exception("Can't put a non-SchemaDataType in SchemaField.types.");
          int x = 0;
          return SchemaField.copyWith(obj,
              types: obj.types.map((e) => x++ == i ? newObj as SchemaDataType : e).toList());
        }
        // is List / first function call
        int x = 0;
        return list.map((el) => x++ == i ? newObj : el).toList();
      }
    }

    // is object in childrens' descendants?
    for (int i = 0; i < list.length; i++) {
      var result = updateSchemaRecursive(list[i], hashCode, newObj);
      if (result != null) {
        if (obj is List) {
          list[i] = result;
          return list;
        } else if (result is SchemaMap && obj is SchemaField) {
          int x = 0;
          return SchemaField.copyWith(obj,
              types: list.map((e) => x++ == i ? result : e).toList() as List<SchemaDataType>);
        } else if (result is SchemaField && obj is SchemaMap) {
          int x = 0;
          return SchemaMap.copyWith(obj, fields: list.map((e) => x++ == i ? result : e).toList() as List<SchemaField>);
        }
        throw Exception("Failed deleting schema obj. Result is not a SchemaMap or SchemaField.");
      }
    }
    return null;
  }

  dynamic deleteFromSchemaRecursive(dynamic obj, dynamic hashCode) {
    List list;
    if (obj is List) {
      list = obj;
    } else if (obj is SchemaMap) {
      list = obj.fields;
    } else if (obj is SchemaField) {
      list = obj.types;
    } else {
      return null;
    }

    // is object in children list?
    for (int i = 0; i < list.length; i++) {
      if (list[i].hashCode == hashCode) {
        // reconstruct parent without child
        // return, so next level up can reconstruct grandparent with new parent
        if (obj is SchemaMap) {
          return SchemaMap.copyWith(obj, fields: obj.fields.where((field) => field.hashCode != hashCode).toList());
        } else if (obj is SchemaField) {
          // new field
          return SchemaField.copyWith(obj, types: obj.types.where((type) => type.hashCode != hashCode).toList());
        }
        // is List / first function call
        return list.where((el) => el.hashCode != hashCode).toList();
      }
    }

    // is object in childrens' descendants?
    for (int i = 0; i < list.length; i++) {
      var result = deleteFromSchemaRecursive(list[i], hashCode);
      if (result != null) {
        if (obj is List) {
          list[i] = result;
          return list;
        } else if (result is SchemaMap && obj is SchemaField) {
          int x = 0;
          return SchemaField.copyWith(obj,
              types: list.map((e) => x++ == i ? result : e).toList() as List<SchemaDataType>);
        } else if (result is SchemaField && obj is SchemaMap) {
          int x = 0;
          return SchemaMap.copyWith(obj, fields: list.map((e) => x++ == i ? result : e).toList() as List<SchemaField>);
        }
        throw Exception("Failed deleting schema obj. Result is not a SchemaMap or SchemaField.");
      }
    }
    return null;
  }
}
