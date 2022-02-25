import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:data_migrator/infastructure/confirmation/change_type.dart';
import 'package:data_migrator/infastructure/confirmation/confirmation_data.dart';
import 'package:data_migrator/domain/conversion/conversion/schema_converter.dart';
import 'package:data_migrator/domain/data_types/enums.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_default_value.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_object.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_size.dart';
import 'package:data_migrator/domain/data_types/permission_model.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_boolean.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_enum.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_float.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_int.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_string.dart';
import 'package:data_migrator/infastructure/confirmation/schema_change.dart';
import 'package:data_migrator/infastructure/confirmation/schema_map_change.dart';
import 'package:data_migrator/infastructure/confirmation/variable_change.dart';
import 'package:data_migrator/infastructure/data_origins/data_origin.dart';
import 'package:console_flutter_sdk/appwrite.dart';
import 'package:console_flutter_sdk/models.dart' as model;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'appwrite_file_group.dart';
import 'package:http_parser/http_parser.dart' as mime;

import 'appwrite_upload_event.dart';

class AppwriteOrigin extends DataOrigin {
  AppwriteOrigin() : super();

  List<SchemaMap> _schema = [];
  @override
  List<SchemaMap> get schema => _schema;

  @override
  bool get isConversionReady =>
      _schema.isNotEmpty &&
      isAuthenticated &&
      _selectedProject != null &&
      _currentEndpoint != null &&
      _currentAPIKey != null &&
      bundleByteSize > 0;

  @override
  List<SchemaMap> getSchema() => _schema;

  @override
  void addToSchema({required SchemaObject newObj, required SchemaObject parentObj}) {
    // TODO: implement addToSchema
  }

  @override
  void deleteFromSchema({required SchemaObject schemaObj}) {
    var result = deleteFromSchemaRecursive(_schema, schemaObj.hashCode);
    _schema = result;
  }

  @override
  void updateSchema({required SchemaObject newObj, required SchemaObject oldObj}) {
    var result = updateSchemaRecursive(_schema, oldObj.hashCode, newObj);
    _schema = result;
  }

  final Client _client = Client();
  Client get client => _client;
  bool get isAuthenticated =>
      _session != null && DateTime.fromMillisecondsSinceEpoch(_session!.expire * 1000).compareTo(DateTime.now()) > 0;
  model.Session? _session;
  // model.Session? get session => _session;
  model.Project? _selectedProject;
  model.Project? get selectedProject => _selectedProject;
  String? _currentEndpoint;
  String? get currentEndpoint => _currentEndpoint;
  String? _currentAPIKey;
  set apiKey(String str) => _currentAPIKey = str;
  String? get currentAPIKey => _currentAPIKey;

  int bundleByteSize = 500000; /* 500KB */

  // Future deleteAllFiles() async {
  //   var storage = Storage(_client);
  //   var files = await storage.listFiles();
  //   for (var file in files.files) {
  //     await storage.deleteFile(fileId: file.$id);
  //   }
  // }

  @override
  Stream<List<List>> startDataStream(List<int> schemaIndex) {
    // TODO: implement startDataStream
    throw UnimplementedError();
  }

  @override
  Stream<List<List>> getDataStream(List<int> schemaIndex) {
    // TODO: implement getStream
    throw UnimplementedError();
  }

  @override
  void endDataStream(List<int> schemaIndex) {
    // TODO: implement endDataStream
  }

  @override
  void pauseDataStream(List<int> schemaIndex) {
    // TODO: implement pauseDataStream
  }

  @override
  Stream<List<List>>? playDataStream(List<int> schemaIndex) {
    // TODO: implement playDataStream
    throw UnimplementedError();
  }

  // void importSchemaFromAppwrite(String collectionId) {
  //   // request the collection
  //   // convert collection to SchemaMap
  //   // add SchemaMap to schema
  // }

  void addSchemaFromSchema(List<SchemaMap> sourceSchema) {
    // _schema = [];
    for (int i = 0; i < sourceSchema.length; i++) {
      _schema.add(SchemaMap(
        name: sourceSchema[i].name,
        mutable: true,
        fields: sourceSchema[i].fields.map((f) {
          var types = _convertTypes(f.types);
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

  List<SchemaDataType> _convertTypes(List<SchemaDataType> types) {
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

  Future logout() async {
    if (_currentEndpoint == null) throw Exception("Can't logout. No Endpoint for Appwrite!");
    if (_session == null) {
      _client
              .setEndpoint(_currentEndpoint!) // Your API Endpoint
              .setProject('console') // Your project ID
          ;
      Account account = Account(_client);
      print("logging out...");
      var result = await account.deleteSessions();
      print(result);
      return result;
    }
    Account account = Account(_client);
    _client
            .setEndpoint(_currentEndpoint!) // Your API Endpoint
            .setProject('console') // Your project ID
        ;
    print("logging out...");
    _client.setMode("");
    var result = await account.deleteSession(sessionId: _session!.$id);
    print("done");
    _session = null;
    _selectedProject = null;
    return result;
  }

  Future authenticate({
    required String email,
    required String password,
    required String endpoint,
  }) async {
    Account account = Account(_client);
    _client
            .setEndpoint(endpoint) // Your API Endpoint
            .setProject('console') // Your project ID
        ;
    _session = await account.createSession(email: email, password: password);
    _currentEndpoint = endpoint;
    print("logged in...");
    print(_session != null ? _session!.toMap() : _session);
  }

  Future selectProject(model.Project project) async {
    _client.setProject(project.$id);
    _client.setMode("admin");
    _selectedProject = project;
  }

  Future<model.ProjectList> getProjects() async {
    var proj = Projects(_client);
    var projects = await proj.list();
    return projects;
  }

  Future<model.CollectionList> getCollections() async {
    var db = Database(_client);
    var collections = await db.listCollections();
    return collections;
  }

  Future<List<SchemaMap>> getRemoteSchema() async {
    var collectionsList = await getCollections();
    var schemaMaps = _collectionsToSchema(collectionsList);
    return schemaMaps;
  }

  List<SchemaMap> _collectionsToSchema(model.CollectionList collectionsList) {
    List<SchemaMap> schemaMaps = [];
    for (var collection in collectionsList.collections) {
      schemaMaps.add(_collectionToSchemaMap(collection));
    }

    return schemaMaps;
  }

  SchemaMap _collectionToSchemaMap(model.Collection collection) {
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

  bool _cancelStream = false;
  List<AppwriteFileGroup> _awFileGroups = [];

  @override
  Sink<List<List>>? getDataSink(List<int> schemaIndex) => _awFileGroups[schemaIndex.first].streamController != null
      ? _awFileGroups[schemaIndex.first].streamController!.sink
      : null;

  @override
  void closeDataSink(List<int> schemaIndex) => _cancelStream = true;

  @override
  Future<Sink<List<List>>> openDataSink(List<int> schemaIndex) async {
    SchemaMap schemaObj = SchemaConverter.getFromSchemaAddress(schema, schemaIndex);

    await _validateCloudFunction();

    SchemaMap.copyWith(
      schemaObj,
      id: await _validateOrCreateCollection(schemaObj),
      mutable: false,
    );

    // schemaObj.id = await _validateCollection(schemaObj);
    // schemaObj.mutable = false;

    File file = await _writeFileHeader(schemaObj.id!, 1);
    _awFileGroups.add(AppwriteFileGroup(
      files: [file],
      streamController: StreamController<List<List>>(),
      collectionId: schemaObj.id!,
    ));
    int fileGroupIndex = _awFileGroups.length - 1;
    var streamSubscription = _awFileGroups[fileGroupIndex].streamController!.stream.listen(
      (data) => _handleStream(data, fileGroupIndex),
      onDone: () {
        _finishFile(_awFileGroups[fileGroupIndex]);
      },
    );
    _awFileGroups[fileGroupIndex].streamSubscription = streamSubscription;
    return _awFileGroups[fileGroupIndex].streamController!.sink;
  }

  void _handleStream(List<List> data, int fileGroupIndex) async {
    _awFileGroups[fileGroupIndex].streamSubscription!.pause();

    if (_awFileGroups[fileGroupIndex].dataWriteByteCount != null &&
        _awFileGroups[fileGroupIndex].dataWriteByteCount! > bundleByteSize) {
      await _iterateToNewBundle(fileGroupIndex);
    }

    // convert data to json bytes
    List<int> bytes = _processData(data, fileGroupIndex);

    // store data in local storage
    await _awFileGroups[fileGroupIndex].lastFile.writeAsBytes(bytes, mode: FileMode.append);

    // increment byteCount
    _awFileGroups[fileGroupIndex].dataWriteByteCount =
        (_awFileGroups[fileGroupIndex].dataWriteByteCount ?? 0) + bytes.length;

    if (_cancelStream) {
      _awFileGroups[fileGroupIndex].streamController!.close();
    } else {
      _awFileGroups[fileGroupIndex].streamSubscription!.resume();
    }
  }

  static const _dataSeparator = ",\n";

  List<int> _processData(List<List> data, int fileGroupIndex) {
    var strLines = data.map((l) => jsonEncode(l)).toList();
    if (_awFileGroups[fileGroupIndex].dataWriteByteCount != null &&
        _awFileGroups[fileGroupIndex].dataWriteByteCount! > 1 &&
        strLines.isNotEmpty) {
      strLines.first = _dataSeparator + strLines.first;
    }
    var fullString = strLines.join(_dataSeparator);
    return fullString.codeUnits;
  }

  Future _iterateToNewBundle(int fileGroupIndex) async {
    // write footer
    await _finishFile(_awFileGroups[fileGroupIndex]);
    // create new file
    try {
      // SchemaMap schemaMap = SchemaConverter.getFromSchemaAddress(schema, _awFileGroups[fileGroupIndex].schemaAddress!);
      var file = await _writeFileHeader(
        _awFileGroups[fileGroupIndex].collectionId,
        _awFileGroups[fileGroupIndex].files.length + 1,
      );
      _awFileGroups[fileGroupIndex].files.add(file);
      _awFileGroups[fileGroupIndex].dataWriteByteCount = 0;
    } catch (e) {
      print("ERROR in AppwriteDataOrigin._handleStream() -- when opening new bundle file, the schemaAddress failed or "
          "writing the new file's header failed. Here is the collectionId:${_awFileGroups[fileGroupIndex].collectionId},"
          " and file count:${_awFileGroups[fileGroupIndex].files.length}");
      print(e);
      throw e;
    }
  }

  Future<File> _writeFileHeader(String collectionId, int bundleNum) async {
    var file = await _createFile(collectionId, bundleNum);
    String header = '{"collectionId":"' + collectionId + '","data":[\n';
    await file.writeAsString(header);
    return file;
  }

  static const String migratorFunctionId = "MigratorInsertFunctionId";

  Future _finishFile(AppwriteFileGroup awFileGroup) async {
    await _writeFileFooter(awFileGroup.lastFile);
    if (_uploadStreamController == null) _initUploadStream();
    _uploadStreamController!.sink
        .add(AppwriteUploadEvent(awFileGroup: awFileGroup, uploadIndex: awFileGroup.files.length - 1));
  }

  StreamController<AppwriteUploadEvent>? _uploadStreamController;
  StreamSubscription<AppwriteUploadEvent>? _uploadStreamSubscription;
  model.Funct? _migratorFunct;
  model.Tag? _migratorFunctTag;

  void _initUploadStream() {
    _uploadStreamController = StreamController<AppwriteUploadEvent>();
    _uploadStreamSubscription = _uploadStreamController!.stream.listen(_handleUploadStream);
  }

  Future _validateCloudFunction() async {
    if (_migratorFunct != null) {
      try {
        await Functions(_client).get(functionId: migratorFunctionId);
      } catch (e) {
        _migratorFunct = null;
        _migratorFunctTag = null;
      }
    }
  }

  Future<String> _validateOrCreateCollection(SchemaMap schemaObj) async {
    var collection = await _getCollection(schemaObj);
    if (collection == null) {
      var collection = await _createCollection(schemaObj);
      return collection.$id;
    }
    return collection.$id;
  }

  Future<model.Collection?> _getCollection(SchemaMap schemaObj) async {
    if (schemaObj.id != null) {
      try {
        var collection = await Database(_client).getCollection(collectionId: schemaObj.id!);
        return collection;
      } catch (e) {
        print("Collection doesn't exist. Creating it now.");
      }
    }
    return null;
  }

  Future<model.Collection> _createCollection(SchemaMap schemaObj) async {
    var db = Database(_client);
    var collection = await db.createCollection(
      collectionId: schemaObj.id != null && schemaObj.id!.isNotEmpty ? schemaObj.id! : "unique()",
      name: schemaObj.name,
      permission: schemaObj.permissionModel != null ? _permissionModelToStr(schemaObj.permissionModel!) : "document",
      read: schemaObj.permissionModel != null ? schemaObj.permissionModel!.readAccess : [],
      write: schemaObj.permissionModel != null ? schemaObj.permissionModel!.writeAccess : [],
    );

    for (var field in schemaObj.fields) {
      await _createAttribute(db, collection.$id, field);
    }
    return collection;
  }

  Future<model.Collection> _updateCollection(SchemaMap schemaObj) async {
    if (schemaObj.id == null) throw Exception("Can't update a collection with a SchemaMap that can a null id.");
    var db = Database(_client);
    var collection = await db.updateCollection(
      collectionId: schemaObj.id!,
      name: schemaObj.name,
      permission: schemaObj.permissionModel != null ? _permissionModelToStr(schemaObj.permissionModel!) : "document",
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

  String _permissionModelToStr(PermissionModel model) =>
      model.permissionType == PermissionLevel.schema ? "collection" : "document";

  Future<model.Model?> _createAttribute(Database db, String collectionId, SchemaField field) async {
    if (field.types.isEmpty) {
      print("WARNING!!!!!!!! Creating Appwrite Collection with attribute ${field.title} of "
          "SchemaString because it has no types.");
      field.types.add(SchemaString.object());
    }
    model.Model? attribute;
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
              xdefault: type.defaultValue,
            );
            break;
          case StringType.url:
            attribute = await db.createUrlAttribute(
              collectionId: collectionId,
              key: field.title,
              xrequired: field.required,
              xdefault: type.defaultValue,
            );
            break;
          case StringType.email:
            attribute = await db.createEmailAttribute(
              collectionId: collectionId,
              key: field.title,
              xrequired: field.required,
              xdefault: type.defaultValue,
            );
            break;
          case StringType.ip:
            attribute = await db.createIpAttribute(
              collectionId: collectionId,
              key: field.title,
              xrequired: field.required,
              xdefault: type.defaultValue,
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
          xdefault: type.defaultValue,
        );
        break;
      case SchemaFloat:
        var type = field.types.first as SchemaFloat;
        attribute = await db.createFloatAttribute(
          collectionId: collectionId,
          key: field.title,
          max: type.max != null ? type.max.toString() : null,
          min: type.min != null ? type.min.toString() : null,
          xrequired: field.required,
          xdefault: type.defaultValue != null ? type.defaultValue.toString() : null,
        );
        break;
      case SchemaBoolean:
        var type = field.types.first as SchemaBoolean;
        attribute = await db.createBooleanAttribute(
          collectionId: collectionId,
          key: field.title,
          xrequired: false,
          xdefault: type.defaultValue,
        );
        break;
      case SchemaEnum:
        var type = field.types.first as SchemaEnum;
        attribute = await db.createEnumAttribute(
          collectionId: collectionId,
          key: field.title,
          xrequired: false,
          xdefault: type.defaultValue,
          elements: [],
        );
        break;
      default:
        print("Failed creating Appwrite collection attribute. SchemaDataType not implemented.");
    }
    return attribute;
  }

  Future _handleUploadStream(AppwriteUploadEvent uploadEvent) async {
    if (_migratorFunct == null) {
      _uploadStreamSubscription!.pause();
      await _initMigratorCloudFunction();
      _uploadStreamSubscription!.resume();
    }
    await _uploadFile(uploadEvent);
  }

  Future<Functions> _initMigratorCloudFunction() async {
    var functions = Functions(_client);
    try {
      print("about to maybe create cloud function: $_migratorFunct");
      _migratorFunct = await functions.get(functionId: migratorFunctionId);
      print("done creating funct:$_migratorFunct");
    } catch (e) {
      print("creating cloud function");
      _migratorFunct = await _createMigratorFunction(functions);
    }
    print("funct exists now: $_migratorFunct");
    print("_migratorFunctTag:$_migratorFunctTag");
    print("_migratorFunct!.tag:${_migratorFunct!.tag}");
    if (_migratorFunctTag != null) print("_migratorFunctTag!.id:${_migratorFunctTag!.$id}");
    // check if migratorFunct has correct tag
    if (_migratorFunctTag == null) {
      print("create new tag");
      _migratorFunctTag = await functions.createTag(
        functionId: _migratorFunct!.$id,
        command: 'python insert_bundle.py',
        code: await _migratorCode,
      );
      print("activating tag");
      _migratorFunct = await functions.updateTag(functionId: _migratorFunct!.$id, tag: _migratorFunctTag!.$id);
    }
    print("√ done setting up cloud function");

    return functions;
  }

  Future _uploadFile(AppwriteUploadEvent uploadEvent) async {
    var multipartFile = await MultipartFile.fromPath("file", uploadEvent.file.path);
    var storage = Storage(_client);
    Future<model.File> f = storage.createFile(fileId: "unique()", file: multipartFile);
    uploadEvent.awFileGroup.uploadedFiles.add(f);
    f.then((fileModel) => _handleCloudExecution(fileModel, uploadEvent.awFileGroup));
  }

  Future _handleCloudExecution(model.File fileModel, AppwriteFileGroup awFileGroup) async {
    Functions functions = Functions(_client);

    // start execution
    var execution = functions.createExecution(functionId: _migratorFunct!.$id, data: fileModel.$id);
    awFileGroup.insertExecutions.add(execution);
  }

  Future<MultipartFile> get _migratorCode async => MultipartFile.fromBytes(
        "code",
        (await rootBundle.load('assets/insert_bundle_code.tar.gz')).buffer.asUint8List(),
        filename: "insert_bundle_code.tar.gz",
        contentType: mime.MediaType.parse("application/x-gzip"),
      );

  Future<model.Funct> _createMigratorFunction(Functions functions) async => await functions.create(
        functionId: migratorFunctionId,
        name: "Migrator Insert Function",
        execute: [],
        runtime: "python-3.9",
        timeout: 900,
        vars: {
          "APPWRITE_ENDPOINT": _currentEndpoint,
          "APPWRITE_FUNCTION_PROJECT_ID": _selectedProject!.$id,
          "APPWRITE_API_KEY": _currentAPIKey,
        },
      );

  Future _writeFileFooter(File file) async {
    await file.writeAsBytes(
      "\n]}".codeUnits,
      mode: FileMode.append,
    );
  }

  Future<String> get _localPath async => (await getApplicationDocumentsDirectory()).path;

  Future<File> _createFile(String collectionId, int bundleNum) async {
    final path = await _localPath;
    final now = DateTime.now();
    String datetimeStr = DateFormat('y-M-d, h-m-s').format(now);
    return File('$path/data_bundle_$bundleNum-$collectionId-$datetimeStr.json');
  }

  @override
  Future<List<ConfirmationData>> validate() async {
    List<ConfirmationData> confirmations = [];
    if (_schema.isEmpty) throw Exception("No schemas setup for AppwriteOrigin.");

    // get schemaMaps with an ID, throw error if failed
    List<SchemaMap> schemaMapsWithId = [];
    try {
      schemaMapsWithId = _schema.where((el) => el.id != null && el.id!.isNotEmpty).toList();
    } catch (e) {
      print(e);
      return confirmations;
    }

    // get collections for those schemaMaps
    Map<SchemaMap, SchemaMap?> schemaMapsToCollections = await _getCollectionsSchemaMapForSchemaMaps(schemaMapsWithId);

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
              id: (await _createCollection(schemaMap)).$id,
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
              VariableChange<PermissionLevel>(key: "permission", value: schemaMap.permissionModel!.permissionType),
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
          onConfirmed: () async => await _handleSchemaChange(schemaMapChange: schemaMapChange, schemaMap: schemaMap),
        ));
      }
    }

    return confirmations;
  }

  Future _deleteCollection(SchemaMap schemaMap) async {
    if (schemaMap.id == null) throw Exception("Can't delete collection without an id.");
    var db = Database(_client);
    db.deleteCollection(collectionId: schemaMap.id!);
  }

  Future _handleSchemaChange({required SchemaMapChange? schemaMapChange, required SchemaMap schemaMap}) async {
    if (schemaMapChange == null) return;
    String? collectionId;
    switch (schemaMapChange.changeType) {
      case ChangeType.delete:
        await _deleteCollection(schemaMap);
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
    var db = Database(_client);
    await db.deleteAttribute(collectionId: collectionId, key: fieldChange.id);
  }

  Future _updateAttributeFromChange(String collectionId, SchemaChange fieldChange) async {
    await _deleteAttributeFromChange(collectionId, fieldChange);
    await _createAttributeFromChange(collectionId, fieldChange);
  }

  Future _createAttributeFromChange(String collectionId, SchemaChange fieldChange) async {
    var types = fieldChange["types"];
    if (types is! List || types.length != 1) throw Exception("Not 1 type in fieldChange.");

    await _createAttributeTypeFromChange(
      db: Database(_client),
      collectionId: collectionId,
      type: types.first,
      change: fieldChange,
    );
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

  Future<model.Model?> _createAttributeTypeFromChange({
    required Database db,
    required String collectionId,
    required SchemaDataType type,
    required SchemaChange change,
  }) async {
    model.Model? attribute;

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
            attribute = await _tryWaitTry<model.AttributeString>(
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
            attribute = await _tryWaitTry<model.AttributeUrl>(
              tryThis: () async => await db.createUrlAttribute(
                collectionId: collectionId,
                key: fieldTitle,
                xrequired: fieldRequired,
                xdefault: type.defaultValue,
              ),
            );

            break;
          case StringType.email:
            attribute = await _tryWaitTry<model.AttributeEmail>(
              tryThis: () async => await db.createEmailAttribute(
                collectionId: collectionId,
                key: fieldTitle,
                xrequired: fieldRequired,
                xdefault: type.defaultValue,
              ),
            );
            break;
          case StringType.ip:
            attribute = await _tryWaitTry<model.AttributeIp>(
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
        attribute = await _tryWaitTry<model.AttributeInteger>(
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
        attribute = await _tryWaitTry<model.AttributeFloat>(
          tryThis: () async => await db.createFloatAttribute(
            collectionId: collectionId,
            key: fieldTitle,
            max: (type as SchemaFloat).max != null ? type.max.toString() : null,
            min: type.min != null ? type.min.toString() : null,
            xrequired: fieldRequired,
            xdefault: type.defaultValue != null ? type.defaultValue.toString() : null,
          ),
        );
        break;
      case SchemaBoolean:
        attribute = await _tryWaitTry<model.AttributeBoolean>(
          tryThis: () async => await db.createBooleanAttribute(
            collectionId: collectionId,
            key: fieldTitle,
            xrequired: fieldRequired,
            xdefault: (type as SchemaBoolean).defaultValue,
          ),
        );
        break;
      case SchemaEnum:
        attribute = await _tryWaitTry<model.AttributeEnum>(
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

  Future<model.Collection> _updateCollectionFromChange(SchemaMapChange schemaMapChange) async {
    if (schemaMapChange.id == null || schemaMapChange.id!.isEmpty) {
      throw Exception("Can't update colelction from change with no id");
    }

    var db = Database(_client);
    String name;
    try {
      name = schemaMapChange.changes.firstWhere((c) => c.key == "name").value;
    } catch (e) {
      rethrow;
    }
    var permModel = PermissionModel(
      permissionType: PermissionLevel.schema,
      readAccess: [],
      writeAccess: [],
    );

    var collection = await db.updateCollection(
      collectionId: schemaMapChange.id!,
      name: name,
      permission: _permissionModelToStr(permModel),
      // schemaMapChange.permissionModel != null ? _permissionModelToStr(schemaMapChange.permissionModel!) : "document",
      read: permModel != null ? permModel.readAccess : [],
      write: permModel != null ? permModel.writeAccess : [],
    );

    return collection;
  }

  Future<model.Collection> _createCollectionFromChange(SchemaMapChange schemaMapChange) async {
    var db = Database(_client);
    String name;
    try {
      name = schemaMapChange.changes.firstWhere((c) => c.key == "name").value;
    } catch (e) {
      print(e);
      print("Can't create collection from change that has no name.");
      throw e;
    }

    var permModel = PermissionModel(
      permissionType: PermissionLevel.schema,
      readAccess: [],
      writeAccess: [],
    );

    var collection = await db.createCollection(
      collectionId: schemaMapChange.id != null && schemaMapChange.id!.isNotEmpty ? schemaMapChange.id! : "unique()",
      name: name,
      permission: _permissionModelToStr(permModel),
      // schemaMapChange.permissionModel != null ? _permissionModelToStr(schemaMapChange.permissionModel!) : "document",
      read: permModel != null ? permModel.readAccess : [],
      write: permModel != null ? permModel.writeAccess : [],
    );

    return collection;
  }

  Future<Map<SchemaMap, SchemaMap?>> _getCollectionsSchemaMapForSchemaMaps(List<SchemaMap> schemaMaps) async {
    Map<SchemaMap, SchemaMap?> map = {};
    for (var schemaMap in schemaMaps) {
      var collection = await _getCollection(schemaMap);
      map[schemaMap] = collection != null ? _collectionToSchemaMap(collection) : null;
    }
    return map;
  }

  // Future<Map<SchemaMap, model.Collection?>> _getCollectionsForSchemaMaps(List<SchemaMap> schemaMaps) async {
  //   Map<SchemaMap, model.Collection?> map = {};
  //   for (var schemaMap in schemaMaps) {
  //     var collection = await _getCollection(schemaMap);
  //     map[schemaMap] = collection;
  //   }
  //   return map;
  // }

  bool _collectionIsDifferentThanSchemaMap(SchemaMap schemaMap, SchemaMap collection) {
    if (schemaMap.id == null) return true;

    if (schemaMap.id != collection.id ||
        schemaMap.name != collection.name ||
        (schemaMap.permissionModel != null &&
            ((schemaMap.permissionModel!.permissionType == PermissionLevel.schema &&
                    collection.permissionModel!.permissionType == PermissionLevel.data) ||
                (schemaMap.permissionModel!.permissionType == PermissionLevel.data &&
                    collection.permissionModel!.permissionType == PermissionLevel.schema)))) {
      return true;
    }
    return false;
  }
}
