import 'package:data_migrator/domain/data_types/enums.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/infastructure/confirmation/change_type.dart';
import 'package:data_migrator/infastructure/confirmation/confirmation_data.dart';
import 'package:data_migrator/infastructure/confirmation/schema_change.dart';
import 'package:data_migrator/infastructure/confirmation/schema_map_change.dart';
import 'package:data_migrator/infastructure/confirmation/variable_change.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/tools/appwrite_adapter.dart';
import 'package:flutter/foundation.dart';

class AppwriteSchemaValidation {
  AppwriteSchemaValidation({
    required this.adapter,
  });

  AppwriteAdapter adapter;

  Future<List<ConfirmationData>> validate(List<SchemaMap> schema) async {
    List<ConfirmationData> confirmations = [];
    if (schema.isEmpty) throw Exception("No schemas setup for AppwriteOrigin.");

    // get schemaMaps with an ID, throw error if failed
    List<SchemaMap> schemaMapsWithId = [];
    try {
      schemaMapsWithId = schema.where((el) => el.id != null && el.id!.isNotEmpty).toList();
    } catch (e) {
      print(e);
      return confirmations;
    }

    // get collections for those schemaMaps
    Map<SchemaMap, SchemaMap?> schemaMapsToCollections =
        await adapter.getCollectionsSchemaMapForSchemaMaps(schemaMapsWithId);

    for (var entry in schemaMapsToCollections.entries) {
      var schemaMap = entry.key;
      var collection = entry.value;

      // Collection CREATE: Check Collection doesn't exist yet
      if (collection == null) {
        confirmations.add(ConfirmationData(
          sentence: "Do you want to create this collection?",
          forDestination: true,
          schemaBefore: null,
          schemaAfter: schemaMap,
          onConfirmed: () async {
            SchemaMap.copyWith(
              schemaMap,
              id: (await adapter.createCollection(schemaMap)).$id,
              mutable: false,
            );
          },
          schemaMapChange: SchemaMapChange(
            id: schemaMap.id,
            changeType: ChangeType.create,
            changes: [],
            indexChanges: [],
            fieldChanges: schemaMap.fields
                .map((f) => SchemaChange(
                      id: f.title,
                      changeType: ChangeType.create,
                      changes: [
                        VariableChange<bool>(key: "isList", value: f.isList),
                        VariableChange<bool>(key: "required", value: f.required),
                        VariableChange<List<SchemaDataType>>(key: "types", value: f.types),
                      ],
                    ))
                .toList(),
          ),
        ));
        continue;
      }

      // Collection UPDATE: check collection metadata difference
      SchemaMapChange schemaMapChange;
      if (_collectionIsDifferentThanSchemaMap(schemaMap, collection)) {
        //name, permission, read, write, enabled
        schemaMapChange = SchemaMapChange(
          id: schemaMap.id,
          changeType: ChangeType.update,
          changes: [
            if (schemaMap.name != collection.name) VariableChange<String>(key: "name", value: schemaMap.name),
            if (schemaMap.permissionModel != null && schemaMap.name != collection.name)
              VariableChange<PermissionLevel>(key: "permission", value: schemaMap.permissionModel!.level),
            if (schemaMap.permissionModel != null && schemaMap.name != collection.name)
              VariableChange<List<String>>(key: "read", value: schemaMap.permissionModel!.readAccess),
            if (schemaMap.permissionModel != null && schemaMap.name != collection.name)
              VariableChange<List<String>>(key: "write", value: schemaMap.permissionModel!.writeAccess),
            if (schemaMap.enabled != null && schemaMap.name != collection.name)
              VariableChange<bool>(key: "enabled", value: schemaMap.enabled!),
          ],
          fieldChanges: [],
          indexChanges: [],
        );
      } else {
        schemaMapChange = SchemaMapChange(
          id: schemaMap.id,
          changeType: ChangeType.none,
          changes: [],
          fieldChanges: [],
          indexChanges: [],
        );
      }

      // Attributes CREATE: check exists locally, not on server
      for (var field in schemaMap.fields) {
        SchemaField? attrField;
        try {
          attrField = collection.fields.firstWhere((attr) => field.title == attr.title);
        } catch (e) {
          print(e.toString());
          schemaMapChange.fieldChanges.add(SchemaChange(
            id: field.title,
            changeType: ChangeType.create,
            changes: [
              VariableChange<String>(key: "title", value: field.title),
              VariableChange<bool>(key: "isList", value: field.isList),
              VariableChange<bool>(key: "required", value: field.required),
              VariableChange<List<SchemaDataType>>(key: "types", value: field.types),
            ],
          ));
          continue;
        }

        // Attributes UPDATE: check exists in both, but attribute is different
        if (attrField != null) {
          if (attrField.status != FieldStatus.available ||
              field.isList != attrField.isList ||
              field.required != attrField.required ||
              !listEquals(field.types, attrField.types)) {
            schemaMapChange.fieldChanges.add(SchemaChange(
              id: field.title,
              changeType: ChangeType.delete,
              changes: [],
            ));
            schemaMapChange.fieldChanges.add(SchemaChange(
              id: field.title,
              changeType: ChangeType.create,
              changes: [
                VariableChange<String>(key: "title", value: field.title),
                VariableChange<bool>(key: "isList", value: field.isList),
                VariableChange<bool>(key: "required", value: field.required),
                VariableChange<List<SchemaDataType>>(key: "types", value: field.types),
              ],
            ));
          }
        }
      }

      // Attributes DELETE: attr exists on server, not locally
      for (var attr in collection.fields) {
        try {
          schemaMap.fields.firstWhere((f) => f.title == attr.title);
        } catch (e) {
          print(e);

          schemaMapChange.fieldChanges.add(SchemaChange(
            id: attr.title,
            changeType: ChangeType.delete,
            changes: [],
          ));
        }
      }

      if (schemaMapChange.changeType != ChangeType.none || schemaMapChange.fieldChanges.isNotEmpty) {
        // add confirmation data
        confirmations.add(ConfirmationData(
          sentence: "Do you want to change this collection?",
          forDestination: true,
          schemaBefore: collection,
          schemaAfter: schemaMap,
          schemaMapChange: schemaMapChange,
          onConfirmed: () async =>
              await adapter.handleSchemaChange(schemaMapChange: schemaMapChange, schemaMap: schemaMap),
        ));
      }
    }

    return confirmations;
  }

  bool _collectionIsDifferentThanSchemaMap(SchemaMap schemaMap, SchemaMap collection) {
    if (schemaMap.id == null) return true;

    if (schemaMap.id != collection.id ||
        schemaMap.name != collection.name ||
        (schemaMap.permissionModel != null &&
            ((schemaMap.permissionModel!.level == PermissionLevel.schema &&
                    collection.permissionModel!.level == PermissionLevel.data) ||
                (schemaMap.permissionModel!.level == PermissionLevel.data &&
                    collection.permissionModel!.level == PermissionLevel.schema)))) {
      return true;
    }
    return false;
  }
}
