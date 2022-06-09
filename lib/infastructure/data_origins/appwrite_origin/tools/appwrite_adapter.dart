import 'dart:io';

import 'package:console_flutter_sdk/appwrite.dart';
import 'package:console_flutter_sdk/models.dart' as models;
import 'package:data_migrator/domain/data_types/enums.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_default_value.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_size.dart';
import 'package:data_migrator/domain/data_types/permission_model.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_boolean.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_enum.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_float.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_int.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_string.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/infastructure/confirmation/change_type.dart';
import 'package:data_migrator/infastructure/confirmation/schema_change.dart';
import 'package:data_migrator/infastructure/confirmation/schema_map_change.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/data_types/appwrite_configuration.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/data_types/appwrite_permission_type.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/tools/appwrite_schema_modification.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart' as mime;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AppwriteAdapter {
  AppwriteAdapter({AppwriteConfiguration? config}) : config = AppwriteConfiguration();

  AppwriteConfiguration config;

  Future logout() async {
    if (config.endpoint == null) throw Exception("Can't logout. No Endpoint for Appwrite!");
    if (config.session == null) {
      config.client
              .setEndpoint(config.endpoint!) // Your API Endpoint
              .setProject('console') // Your project ID
          ;
      Account account = Account(config.client);
      print("logging out...");
      var result = await account.deleteSessions();
      print(result);
      return result;
    }
    Account account = Account(config.client);
    config.client
            .setEndpoint(config.endpoint!) // Your API Endpoint
            .setProject('console') // Your project ID
        ;
    print("logging out...");
    config.client.setMode("");
    var result = await account.deleteSession(sessionId: config.session!.$id);
    print("done");
    config.session = null;
    config.selectedProject = null;
    return result;
  }

  Future authenticate({
    required String email,
    required String password,
    required String endpoint,
  }) async {
    Account account = Account(config.client);
    config.client
            .setEndpoint(endpoint) // Your API Endpoint
            .setProject('console') // Your project ID
        ;
    config.session = await account.createSession(email: email, password: password);
    config.endpoint = endpoint;
    print("logged in...");
    print(config.session != null ? config.session!.toMap() : config.session);
  }

  Future selectProject(models.Project project) async {
    config.client.setProject(project.$id);
    config.client.setMode("admin");
    config.selectedProject = project;
  }

  Future<models.ProjectList> getProjects() async {
    var proj = Projects(config.client);
    var projects = await proj.list();
    return projects;
  }

  Future<models.Collection?> getCollection(SchemaMap schemaObj) async {
    if (schemaObj.id != null) {
      try {
        var collection = await Database(config.client).getCollection(collectionId: schemaObj.id!);
        return collection;
      } catch (e) {
        print("Collection doesn't exist. Creating it now.");
      }
    }
    return null;
  }

  Future<models.CollectionList> getCollections() async {
    var db = Database(config.client);
    var collections = await db.listCollections();
    return collections;
  }

  Future<models.Collection> createCollection(SchemaMap schemaObj) async {
    var db = Database(config.client);
    var collection = await db.createCollection(
      collectionId: schemaObj.id != null && schemaObj.id!.isNotEmpty ? schemaObj.id! : "unique()",
      name: schemaObj.name,
      permission:
          schemaObj.permissionModel != null ? _permissionModelToStr(schemaObj.permissionModel!.level) : "document",
      read: schemaObj.permissionModel != null ? schemaObj.permissionModel!.readAccess : [],
      write: schemaObj.permissionModel != null ? schemaObj.permissionModel!.writeAccess : [],
    );

    for (var field in schemaObj.fields) {
      await _createAttribute(db, collection.$id, field);
    }
    return collection;
  }

  Future deleteCollection(SchemaMap schemaMap) async {
    if (schemaMap.id == null) throw Exception("Can't delete collection without an id.");
    var db = Database(config.client);
    db.deleteCollection(collectionId: schemaMap.id!);
  }

  Future<models.Collection> updateCollection(SchemaMap schemaObj) async {
    if (schemaObj.id == null) throw Exception("Can't update a collection with a SchemaMap that can a null id.");
    var db = Database(config.client);
    var collection = await db.updateCollection(
      collectionId: schemaObj.id!,
      name: schemaObj.name,
      permission:
          schemaObj.permissionModel != null ? _permissionModelToStr(schemaObj.permissionModel!.level) : "document",
      // read: schemaObj.permissionModel != null ? schemaObj.permissionModel!.readAccess : [],
      // write: schemaObj.permissionModel != null ? schemaObj.permissionModel!.writeAccess : [],
    );

    // recreate/edit attributes that are different
    await _editAttributes(
      attributes: collection.attributes,
      collectionId: collection.$id,
      db: db,
      schemaMap: schemaObj,
      commitEdits: true,
    );

    return collection;
  }

  Future<List<SchemaField>> _editAttributes({
    required Database db,
    required List attributes,
    required SchemaMap schemaMap,
    required String collectionId,
    bool commitEdits = false,
  }) async {
    List<SchemaField> fieldsChanged = [];
    for (var attr in attributes) {
      try {
        var field = schemaMap.fields.firstWhere((f) => f.title == attr["key"]);

        bool recreateAttribute = false;
        if (_isAttributeDifferentThanSchemaFieldType(field, attr)) {
          recreateAttribute = true;
        } else
        // validate isList
        if (attr["array"] != null && attr["array"] is bool && attr["array"] != field.isList) {
          recreateAttribute = true;
        } else
        // validate required
        if (attr["required"] != null && attr["required"] is bool && attr["array"] != field.required) {
          recreateAttribute = true;
        } else
        // validate default
        if ((attr["default"] != null || (field.types.length == 1 && field.types.first is SchemaDefaultValue)) &&
            attr["default"] != (field.types.first as SchemaDefaultValue).defaultValue) {
          recreateAttribute = true;
        } else
        // validate size by int
        if ((attr["size"] != null || (field.types.length == 1 && field.types.first is SchemaSizeInt)) &&
            attr["size"] != (field.types.first as SchemaSizeInt).size) {
          recreateAttribute = true;
        } else
        // validate size by range
        if (((attr["min"] != null || attr["max"] != null) ||
                (field.types.length == 1 && field.types.first is SchemaSizeRange)) &&
            (attr["min"] != (field.types.first as SchemaSizeRange).min ||
                attr["max"] != (field.types.first as SchemaSizeRange).max)) {
          recreateAttribute = true;
        }

        if (recreateAttribute) {
          fieldsChanged.add(field);
          if (commitEdits) {
            await db.deleteAttribute(collectionId: collectionId, key: attr["key"]);
            var resultModel = await _createAttribute(db, collectionId, field);
            if (resultModel == null) {
              throw Exception("An error happened when recreating attribute for collection($collectionId). "
                  "SchemaField:${field.title}");
            }
          } else {}
        }
      } catch (e) {
        print(e);
        print("no SchemaField found for attribute... it needs to be deleted");
        try {
          if (commitEdits) {
            await db.deleteAttribute(collectionId: collectionId, key: attr["key"]);
          }
          fieldsChanged.add(SchemaField(
            title: attr["key"] ?? "NO_FIELD_KEY",
            isList: attr["array"] ?? false,
            required: attr["required"] ?? false,
          ));
        } catch (e) {
          print(e);
          print("Failed deleting attribute from Appwrite that doesn't have a matching SchemField.");
        }
      }
    }

    // create fields that don't exist yet
    for (var field in schemaMap.fields) {
      bool found = false;
      for (var attr in attributes) if (attr["key"] == field.title) found = true;
      if (!found) {
        fieldsChanged.add(field);
        if (commitEdits) {
          var resultModel = await _createAttribute(db, collectionId, field);
          if (resultModel == null) {
            throw Exception("An error happened when recreating attribute for collection($collectionId). "
                "SchemaField:${field.title}");
          }
        }
      }
    }

    return fieldsChanged;
  }

  Future<models.Model?> _createAttribute(Database db, String collectionId, SchemaField field) async {
    if (field.types.isEmpty) {
      print("WARNING!!!!!!!! Creating Appwrite Collection with attribute ${field.title} of "
          "SchemaString because it has no types.");
      field.types.add(SchemaString.object());
    }
    models.Model? attribute;
    switch (field.types.first.runtimeType) {
      case SchemaString:
        var type = field.types.first as SchemaString;
        switch (type.type) {
          case StringType.tinyText:
          case StringType.text:
          case StringType.mediumText:
          case StringType.longText:
            attribute = await db.createStringAttribute(
              collectionId: collectionId,
              key: field.title,
              size: type.size ?? 255,
              xrequired: field.required,
              xdefault: field.required ? null : type.defaultValue,
            );
            break;
          case StringType.url:
            attribute = await db.createUrlAttribute(
              collectionId: collectionId,
              key: field.title,
              xrequired: field.required,
              xdefault: field.required ? null : type.defaultValue,
            );
            break;
          case StringType.email:
            attribute = await db.createEmailAttribute(
              collectionId: collectionId,
              key: field.title,
              xrequired: field.required,
              xdefault: field.required ? null : type.defaultValue,
            );
            break;
          case StringType.ip:
            attribute = await db.createIpAttribute(
              collectionId: collectionId,
              key: field.title,
              xrequired: field.required,
              xdefault: field.required ? null : type.defaultValue,
            );
            break;
          default:
        }
        break;
      case SchemaInt:
        var type = field.types.first as SchemaInt;
        attribute = await db.createIntegerAttribute(
          collectionId: collectionId,
          key: field.title,
          max: type.max,
          min: type.min,
          xrequired: field.required,
          xdefault: field.required ? null : type.defaultValue,
        );
        break;
      case SchemaFloat:
        var type = field.types.first as SchemaFloat;
        attribute = await db.createFloatAttribute(
          collectionId: collectionId,
          key: field.title,
          max: type.max,
          min: type.min,
          xrequired: field.required,
          xdefault: field.required ? null : type.defaultValue,
        );
        break;
      case SchemaBoolean:
        var type = field.types.first as SchemaBoolean;
        attribute = await db.createBooleanAttribute(
          collectionId: collectionId,
          key: field.title,
          xrequired: false,
          xdefault: field.required ? null : type.defaultValue,
        );
        break;
      case SchemaEnum:
        var type = field.types.first as SchemaEnum;
        attribute = await db.createEnumAttribute(
          collectionId: collectionId,
          key: field.title,
          xrequired: false,
          xdefault: field.required ? null : type.defaultValue,
          elements: [],
        );
        break;
      default:
        print("Failed creating Appwrite collection attribute. SchemaDataType not implemented.");
    }
    return attribute;
  }

  String _permissionModelToStr(
    PermissionLevel permLevel, {
    AppwritePermissionType appwritePermissionType = AppwritePermissionType.database,
  }) {
    if (appwritePermissionType == AppwritePermissionType.database) {
      return permLevel == PermissionLevel.schema ? "collection" : "document";
    } else {
      return permLevel == PermissionLevel.schema ? "bucket" : "file";
    }
  }

  bool _isAttributeDifferentThanSchemaFieldType(SchemaField field, dynamic attr) {
    if (field.types.length != 1) return true;
    switch (attr["type"]) {
      case "string":
        switch (attr["format"]) {
          case "email":
            if (field.types.first is SchemaString && (field.types.first as SchemaString).type != StringType.email) {
              return true;
            }
            break;
          case "enum":
            if (field.types.first is! SchemaEnum) return true;
            break;
          case "url":
            if (field.types.first is SchemaString && (field.types.first as SchemaString).type != StringType.url) {
              return true;
            }
            break;
          case "ip":
            if (field.types.first is SchemaString && (field.types.first as SchemaString).type != StringType.ip) {
              return true;
            }
            break;
          default:
            break;
        }
        break;
      case "integer":
        if (field.types.first is! SchemaInt) return true;
        break;
      case "float":
        if (field.types.first is! SchemaFloat) return true;
        break;
      case "boolean":
        if (field.types.first is! SchemaBoolean) return true;
        break;
      default:
        break;
    }

    return false;
  }

  final migratorCodeFilename = 'code.tar.gz';

  Future<InputFile> get _migratorCode async {
    // check if file is there
    final path = (await getApplicationDocumentsDirectory()).path;
    var file = File('$path/$migratorCodeFilename');

    // delete file if there
    if (await file.exists()) {
      await file.delete();
    }

    // save file
    await file.writeAsBytes((await rootBundle.load('assets/$migratorCodeFilename')).buffer.asUint8List());

    // send path-ed file
    return InputFile(
      file: await MultipartFile.fromPath('code', file.path),
      path: file.path,
      filename: migratorCodeFilename,
    );
  }

  Future<models.Funct> _upsertCloudFunction(Functions functions) async {
    models.Funct migratorFunct;
    models.Deployment migratorDeployment;

    // Validate Cloud Function Exists
    try {
      migratorFunct = await functions.get(functionId: config.migratorFunctionId);
    } catch (e) {
      migratorFunct = await _createMigratorFunction(functions);
      config.migratorFunctDeployment = null;
      config.migratorFunct = null;
    }

    // Validate Deployment
    if (config.migratorFunctDeployment != null) {
      if (migratorFunct.deployment != config.migratorFunctDeployment!.$id) {
        migratorDeployment = await _upsertDeployment(functions, migratorFunct.$id, config.migratorFunctDeployment!.$id);
      } else {
        migratorDeployment = config.migratorFunctDeployment!;
      }
    } else {
      migratorDeployment = await _createDeployment(functions, migratorFunct.$id);
    }

    // Validate Cloud Function Attributes
    if (migratorFunct.vars["APPWRITE_ENDPOINT"] != config.endpoint ||
        migratorFunct.vars["APPWRITE_FUNCTION_PROJECT_ID"] != config.selectedProject!.$id ||
        migratorFunct.vars["APPWRITE_API_KEY"] != config.currentAPIKey) {
      await _updateMigratorFunction(functions, config.migratorFunctionId);
    }

    config.migratorFunct = migratorFunct;
    config.migratorFunctDeployment = migratorDeployment;

    return migratorFunct;
  }

  // Returns the deployment if a new Deployment was created
  // Returns null if deployment was updated (activated)
  Future<models.Deployment> _upsertDeployment(Functions functions, String functionId, String deploymentId) async {
    try {
      return await _updateDeployment(functions, functionId, deploymentId);
    } catch (e) {
      return await _createDeployment(functions, functionId);
    }
  }

  Future<models.Deployment> _updateDeployment(Functions functions, String functionId, String deploymentId) async {
    await functions.updateDeployment(
      functionId: functionId,
      deploymentId: deploymentId,
    );
    return await _waitUntilDeploymentActivated(functions, functionId, deploymentId);
  }

  Future<models.Deployment> _createDeployment(
    Functions functions,
    String functionId, {
    bool waitUntilActivited = true,
  }) async {
    var deployment = await functions.createDeployment(
      functionId: functionId,
      entrypoint: 'src/index.py',
      activate: true,
      code: await _migratorCode,
    );
    if (waitUntilActivited) return await _waitUntilDeploymentActivated(functions, functionId, deployment.$id);
    return deployment;
  }

  Future<Functions> initMigratorCloudFunction() async {
    var functions = Functions(config.client);

    await _upsertCloudFunction(functions);

    try {
      if (config.migratorFunctDeployment == null) {
        throw Exception();
      }
      models.DeploymentList deploymentList = await functions.getDeployment(
        functionId: config.migratorFunct!.$id,
        deploymentId: config.migratorFunctDeployment!.$id,
      );
      if (deploymentList.total > 1) {
        if (!deploymentList.deployments.firstWhere((d) => d.$id == config.migratorFunctDeployment!.$id).activate) {
          _updateDeployment(functions, config.migratorFunct!.$id, config.migratorFunctDeployment!.$id);
        }
      } else {
        throw Exception();
      }
    } catch (e) {
      // create new deployment
      config.migratorFunctDeployment = await _createDeployment(functions, config.migratorFunct!.$id);
    }

    print("√ done setting up cloud function");

    return functions;
  }

  Future<models.Deployment> _waitUntilDeploymentActivated(
    Functions functions,
    String functionId,
    String deploymentId,
  ) async {
    for (int i = 0; i < 60; i++) {
      models.DeploymentList? deploymentList;
      try {
        deploymentList = await functions.listDeployments(
          functionId: functionId,
          search: deploymentId,
        );
        // deploymentList = await functions.getDeployment(
        //   functionId: functionId,
        //   deploymentId: deploymentId,
        // );
      } catch (e) {}

      try {
        if (deploymentList != null &&
            deploymentList.total > 0 &&
            deploymentList.deployments.firstWhere((d) => d.$id == deploymentId).status == "ready") {
          return deploymentList.deployments.firstWhere((d) => d.$id == deploymentId);
        }
      } catch (e) {}

      await Future.delayed(const Duration(seconds: 1));
    }

    throw Exception("Failed to verify cloud function deployment is active. It might have taken an abnormal amount of "
        "time for the migrator cloud function deployment to activate.");
  }

  Future<models.Funct> _createMigratorFunction(Functions functions) async => await functions.create(
        functionId: config.migratorFunctionId,
        name: "Migrator Insert Function",
        execute: [],
        runtime: "python-3.10",
        timeout: 900,
        vars: {
          "APPWRITE_ENDPOINT": config.endpoint,
          "APPWRITE_FUNCTION_PROJECT_ID": config.selectedProject!.$id,
          "APPWRITE_API_KEY": config.currentAPIKey,
        },
      );

  Future<models.Funct> _updateMigratorFunction(Functions functions, String functionId) async => await functions.update(
        functionId: functionId,
        name: "Migrator Insert Function",
        execute: [],
        timeout: 900,
        vars: {
          "APPWRITE_ENDPOINT": config.endpoint,
          "APPWRITE_FUNCTION_PROJECT_ID": config.selectedProject!.$id,
          "APPWRITE_API_KEY": config.currentAPIKey,
        },
      );

  Future validateCloudFunction() async {
    Functions functions = Functions(config.client);

    if (config.migratorFunctionId.isEmpty) {
      throw Exception("The appwrite cloud function id is not set.");
    }

    await _upsertCloudFunction(functions);
  }

  Future validateStorageBucket() async {
    models.Bucket? bucket;
    Storage storage = Storage(config.client);

    // check if bucket exists
    try {
      bucket = await storage.getBucket(bucketId: config.bucketId);
      // ignore: empty_catches
    } catch (e) {}

    if (bucket == null || bucket.$id.isEmpty) {
      // if it doesn't exist, create it
      await storage.createBucket(
        bucketId: config.bucketId,
        name: "DataMigrator Upload Bucket",
        permission: _permissionModelToStr(
          PermissionLevel.schema,
          appwritePermissionType: AppwritePermissionType.storage,
        ),
        enabled: true,
      );
      return true;
    } else {
      if (bucket.enabled &&
          (bucket.allowedFileExtensions.isEmpty || bucket.allowedFileExtensions.contains("json")) &&
          bucket.maximumFileSize > config.bundleByteSize) {
        return true;
      }
    }
    throw Exception("Failed validating the upload storage bucket. The bucket might exist already but is disabled, "
        "doesn't allow json files, or the bundle size is bigger than the bucket's maximum allowed file size.");
  }

  Future handleSchemaChange({required SchemaMapChange? schemaMapChange, required SchemaMap schemaMap}) async {
    if (schemaMapChange == null) return;
    String? collectionId;
    switch (schemaMapChange.changeType) {
      case ChangeType.delete:
        await deleteCollection(schemaMap);
        return;
      case ChangeType.create:
        var collection = await _createCollectionFromChange(schemaMapChange);
        collectionId = collection.$id;
        break;
      case ChangeType.update:
        var collection = await _updateCollectionFromChange(schemaMapChange);
        collectionId = collection.$id;
        break;
      case ChangeType.none:
        break;
    }

    for (var fieldChange in schemaMapChange.fieldChanges) {
      if (schemaMapChange.id == null && collectionId == null) {
        throw Exception("Can't modify a field from a null collection id");
      }
      switch (fieldChange.changeType) {
        case ChangeType.delete:
          await _deleteAttributeFromChange(schemaMapChange.id ?? collectionId!, fieldChange);
          break;
        case ChangeType.create:
          await _createAttributeFromChange(schemaMapChange.id ?? collectionId!, fieldChange);
          break;
        case ChangeType.update:
          // await _updateAttributeFromChange(schemaMapChange.id ?? collectionId!, fieldChange);
          throw Exception("Can't update an Appwrite attribute. Must delete and create a new one.");
        case ChangeType.none:
          break;
      }
    }
  }

  Future _deleteAttributeFromChange(String collectionId, SchemaChange fieldChange) async {
    if (fieldChange.changeType != ChangeType.delete && fieldChange.changeType != ChangeType.update) {
      throw Exception("Can't delete an attribute that isn't a delete change.");
    }
    var db = Database(config.client);
    await db.deleteAttribute(collectionId: collectionId, key: fieldChange.id);
  }

  Future updateAttributeFromChange(String collectionId, SchemaChange fieldChange) async {
    await _deleteAttributeFromChange(collectionId, fieldChange);
    await _createAttributeFromChange(collectionId, fieldChange);
  }

  Future _createAttributeFromChange(String collectionId, SchemaChange fieldChange) async {
    var types = fieldChange["types"];
    if (types is! List || types.length != 1) throw Exception("Not 1 type in fieldChange.");

    await _createAttributeTypeFromChange(
      db: Database(config.client),
      collectionId: collectionId,
      type: types.first,
      change: fieldChange,
    );
  }

  Future<models.Model?> _createAttributeTypeFromChange({
    required Database db,
    required String collectionId,
    required SchemaDataType type,
    required SchemaChange change,
  }) async {
    models.Model? attribute;

    String? fieldTitle = change["title"];
    bool? fieldRequired = change["required"];
    if (fieldTitle == null || fieldRequired == null) throw Exception("Field's title or required is missing");

    switch (type.runtimeType) {
      case SchemaString:
        switch ((type as SchemaString).type) {
          case StringType.tinyText:
          case StringType.text:
          case StringType.mediumText:
          case StringType.longText:
            attribute = await _tryWaitTry<models.AttributeString>(
              tryThis: () async => await db.createStringAttribute(
                collectionId: collectionId,
                key: fieldTitle,
                size: type.size ?? 255,
                xrequired: fieldRequired,
                xdefault: type.defaultValue,
              ),
            );
            break;
          case StringType.url:
            attribute = await _tryWaitTry<models.AttributeUrl>(
              tryThis: () async => await db.createUrlAttribute(
                collectionId: collectionId,
                key: fieldTitle,
                xrequired: fieldRequired,
                xdefault: type.defaultValue,
              ),
            );

            break;
          case StringType.email:
            attribute = await _tryWaitTry<models.AttributeEmail>(
              tryThis: () async => await db.createEmailAttribute(
                collectionId: collectionId,
                key: fieldTitle,
                xrequired: fieldRequired,
                xdefault: type.defaultValue,
              ),
            );
            break;
          case StringType.ip:
            attribute = await _tryWaitTry<models.AttributeIp>(
              tryThis: () async => await db.createIpAttribute(
                collectionId: collectionId,
                key: fieldTitle,
                xrequired: fieldRequired,
                xdefault: type.defaultValue,
              ),
            );
            break;
          default:
        }
        break;
      case SchemaInt:
        attribute = await _tryWaitTry<models.AttributeInteger>(
          tryThis: () async => await db.createIntegerAttribute(
            collectionId: collectionId,
            key: fieldTitle,
            max: (type as SchemaInt).max,
            min: type.min,
            xrequired: fieldRequired,
            xdefault: type.defaultValue,
          ),
        );
        break;
      case SchemaFloat:
        attribute = await _tryWaitTry<models.AttributeFloat>(
          tryThis: () async => await db.createFloatAttribute(
            collectionId: collectionId,
            key: fieldTitle,
            max: (type as SchemaFloat).max != null ? type.max : null,
            min: type.min,
            xrequired: fieldRequired,
            xdefault: type.defaultValue,
          ),
        );
        break;
      case SchemaBoolean:
        attribute = await _tryWaitTry<models.AttributeBoolean>(
          tryThis: () async => await db.createBooleanAttribute(
            collectionId: collectionId,
            key: fieldTitle,
            xrequired: fieldRequired,
            xdefault: (type as SchemaBoolean).defaultValue,
          ),
        );
        break;
      case SchemaEnum:
        attribute = await _tryWaitTry<models.AttributeEnum>(
          tryThis: () async => await db.createEnumAttribute(
            collectionId: collectionId,
            key: fieldTitle,
            xrequired: fieldRequired,
            xdefault: (type as SchemaEnum).defaultValue,
            elements: [],
          ),
        );
        break;
      default:
        print("Failed creating Appwrite collection attribute. SchemaDataType not implemented.");
    }
    return attribute;
  }

  Future<models.Collection> _updateCollectionFromChange(SchemaMapChange schemaMapChange) async {
    if (schemaMapChange.id == null || schemaMapChange.id!.isEmpty) {
      throw Exception("Can't update colelction from change with no id");
    }

    var db = Database(config.client);
    String name;
    try {
      name = schemaMapChange.changes.firstWhere((c) => c.key == "name").value;
    } catch (e) {
      rethrow;
    }
    var permModel = PermissionModel(
      level: PermissionLevel.schema,
      readAccess: [],
      writeAccess: [],
    );

    var collection = await db.updateCollection(
      collectionId: schemaMapChange.id!,
      name: name,
      permission: _permissionModelToStr(permModel.level),
      read: permModel != null ? permModel.readAccess : [],
      write: permModel != null ? permModel.writeAccess : [],
    );

    return collection;
  }

  Future<models.Collection> _createCollectionFromChange(SchemaMapChange schemaMapChange) async {
    var db = Database(config.client);
    String name;
    try {
      name = schemaMapChange.changes.firstWhere((c) => c.key == "name").value;
    } catch (e) {
      print(e);
      print("Can't create collection from change that has no name.");
      throw e;
    }

    var permModel = PermissionModel(
      level: PermissionLevel.schema,
      readAccess: [],
      writeAccess: [],
    );

    var collection = await db.createCollection(
      collectionId: schemaMapChange.id != null && schemaMapChange.id!.isNotEmpty ? schemaMapChange.id! : "unique()",
      name: name,
      permission: _permissionModelToStr(permModel.level),
      read: permModel != null ? permModel.readAccess : [],
      write: permModel != null ? permModel.writeAccess : [],
    );

    return collection;
  }

  Future<T> _tryWaitTry<T>({
    required Future Function() tryThis,
    Duration waitTime = const Duration(seconds: 5),
    int tries = 0,
    int maxTries = 5,
  }) async {
    try {
      return await tryThis();
    } catch (e) {
      // attribute already exists (wait for a delete)
      if (e is AppwriteException && e.code == 409) {
        print("Appwrite Action Failed. Try #$tries happening in ${waitTime.inSeconds} seconds.");
        if (maxTries < tries) rethrow;
        await Future.delayed(waitTime);
        return await _tryWaitTry(tryThis: tryThis, tries: ++tries);
      }
      rethrow;
    }
  }

  Future<Map<SchemaMap, SchemaMap?>> getCollectionsSchemaMapForSchemaMaps(List<SchemaMap> schemaMaps) async {
    Map<SchemaMap, SchemaMap?> map = {};
    for (var schemaMap in schemaMaps) {
      var collection = await getCollection(schemaMap);
      map[schemaMap] = collection != null ? AppwriteSchemaModification.collectionToSchemaMap(collection) : null;
    }
    return map;
  }
}
