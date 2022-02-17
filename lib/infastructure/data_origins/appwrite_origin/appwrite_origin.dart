import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:data_migrator/domain/conversion/conversion/schema_converter.dart';
import 'package:data_migrator/domain/data_types/enums.dart';
import 'package:data_migrator/domain/data_types/permission_model.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_boolean.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_enum.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_float.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_int.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_string.dart';
import 'package:data_migrator/infastructure/data_origins/data_origin.dart';
import 'package:console_flutter_sdk/appwrite.dart';
import 'package:console_flutter_sdk/models.dart' as model;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'appwrite_file.dart';
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
  void removeSchema(dynamic schemaObj) => _schema.remove(schemaObj);

  final Client _client = Client();
  Client get client => _client;
  bool get isAuthenticated =>
      _session != null && DateTime.fromMillisecondsSinceEpoch(_session!.expire * 1000).compareTo(DateTime.now()) > 0;
  model.Session? _session;
  model.Session? get session => _session;
  model.Project? _selectedProject;
  model.Project? get selectedProject => _selectedProject;
  String? _currentEndpoint;
  String? get currentEndpoint => _currentEndpoint;
  String? _currentAPIKey;
  set apiKey(String str) => _currentAPIKey = str;
  String? get currentAPIKey => _currentAPIKey;

  int bundleByteSize = 500000; /* 500KB */

  Future deleteAllFiles() async {
    var storage = Storage(_client);
    var files = await storage.listFiles();
    for (var file in files.files) {
      await storage.deleteFile(fileId: file.$id);
    }
  }

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
      List<SchemaField> fields = [];
      for (var field in collection.attributes) {
        if (field is Map) {
          var key = field["key"] ?? "";
          var type = field["type"] ?? "";
          var status = field["status"] ?? "";
          var required = field["required"] ?? "";
          var isArray = field["array"] ?? "";
          List<SchemaDataType> types = [];
          switch (type) {
            case 'integer':
              types.add(SchemaInt(
                type: IntType.int,
                signed: true,
                min: field["min"] is String ? int.parse(field["min"]) : field["min"],
                max: field["max"] is String ? int.parse(field["max"]) : field["max"],
                defaultValue: field["default"] is String ? int.parse(field["default"]) : field["default"],
              ));
              break;
            case 'double':
              types.add(SchemaFloat(
                type: FloatType.double,
                signed: true,
                min: field["min"] is String ? double.parse(field["min"]) : field["min"],
                max: field["max"] is String ? double.parse(field["max"]) : field["max"],
              ));
              break;
            case 'string':
              types.add(SchemaString(
                type: StringType.text,
                size: field["size"] is String ? int.parse(field["size"]) : field["size"],
                defaultValue: field["default"],
              ));
              break;
            // case '':
            //   break;
            // case '':
            //   break;
            default:
              break;
          }
          fields.add(SchemaField(
            isList: isArray,
            required: required,
            title: key,
            types: types,
          ));
        }
      }

      schemaMaps.add(SchemaMap(
        name: collection.name,
        id: collection.$id,
        fields: fields,
        mutable: false,
      ));
    }

    return schemaMaps;
  }

  bool _cancelStream = false;
  List<AppwriteFile> _awFileGroups = [];

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
    schemaObj.id = await _validateCollection(schemaObj);

    File file = await _writeFileHeader(schemaObj.id!, 1);
    _awFileGroups.add(AppwriteFile(
      files: [file],
      streamController: StreamController<List<List>>(),
      schemaAddress: schemaIndex,
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
      SchemaMap schemaMap = SchemaConverter.getFromSchemaAddress(schema, _awFileGroups[fileGroupIndex].schemaAddress!);
      var file = await _writeFileHeader(
        _awFileGroups[fileGroupIndex].collectionId,
        _awFileGroups[fileGroupIndex].files.length + 1,
      );
      _awFileGroups[fileGroupIndex].files.add(file);
      _awFileGroups[fileGroupIndex].dataWriteByteCount = 0;
    } catch (e) {
      print("ERROR in AppwriteDataOrigin._handleStream() -- when opening new bundle file, the schemaAddress failed or "
          "writing the new file's header failed. Here is the schemaAddress:${_awFileGroups[fileGroupIndex].schemaAddress}");
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

  Future _finishFile(AppwriteFile awFile) async {
    await _writeFileFooter(awFile.lastFile);
    if (_uploadStreamController == null) _initUploadStream();
    _uploadStreamController!.sink.add(AppwriteUploadEvent(awFile: awFile, uploadIndex: awFile.files.length - 1));
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

  Future<String> _validateCollection(SchemaMap schemaObj) async {
    if (schemaObj.id != null) {
      try {
        await Database(_client).getCollection(collectionId: schemaObj.id!);
        return schemaObj.id!;
      } catch (e) {
        print("Collection doesn't exist. Creating it now.");
      }
    }
    var collection = await _createCollection(schemaObj);
    return collection.$id;
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

  String _permissionModelToStr(PermissionModel model) =>
      model.permissionType == PermissionLevel.schema ? "collection" : "document";

  Future _createAttribute(Database db, String collectionId, SchemaField field) async {
    if (field.types.isEmpty) {
      print("WARNING!!!!!!!! Creating Appwrite Collection with attribute ${field.title} of "
          "SchemaString because it has no types.");
      field.types.add(SchemaString.object());
    }
    switch (field.types.first.runtimeType) {
      case SchemaString:
        var type = field.types.first as SchemaString;
        switch (type.type) {
          case StringType.tinyText:
          case StringType.text:
          case StringType.mediumText:
          case StringType.longText:
            await db.createStringAttribute(
              collectionId: collectionId,
              key: field.title,
              size: type.size ?? 255,
              xrequired: false,
              xdefault: type.defaultValue,
            );
            break;
          case StringType.url:
            await db.createUrlAttribute(
              collectionId: collectionId,
              key: field.title,
              xrequired: false,
              xdefault: type.defaultValue,
            );
            break;
          case StringType.email:
            await db.createEmailAttribute(
              collectionId: collectionId,
              key: field.title,
              xrequired: false,
              xdefault: type.defaultValue,
            );
            break;
          case StringType.ip:
            await db.createIpAttribute(
              collectionId: collectionId,
              key: field.title,
              xrequired: false,
              xdefault: type.defaultValue,
            );
            break;
          default:
        }
        break;
      case SchemaInt:
        var type = field.types.first as SchemaInt;
        await db.createIntegerAttribute(
          collectionId: collectionId,
          key: field.title,
          max: type.max,
          min: type.min,
          xrequired: false,
          xdefault: type.defaultValue,
        );
        break;
      case SchemaFloat:
        var type = field.types.first as SchemaFloat;
        await db.createFloatAttribute(
          collectionId: collectionId,
          key: field.title,
          max: type.max != null ? type.max.toString() : null,
          min: type.min != null ? type.min.toString() : null,
          xrequired: false,
          xdefault: type.defaultValue != null ? type.defaultValue.toString() : null,
        );
        break;
      case SchemaBoolean:
        var type = field.types.first as SchemaBoolean;
        await db.createBooleanAttribute(
          collectionId: collectionId,
          key: field.title,
          xrequired: false,
          xdefault: type.defaultValue,
        );
        break;
      case SchemaEnum:
        var type = field.types.first as SchemaEnum;
        await db.createEnumAttribute(
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
    uploadEvent.awFile.uploadedFiles.add(f);
    f.then((fileModel) => _handleCloudExecution(fileModel, uploadEvent.awFile));
  }

  Future _handleCloudExecution(model.File fileModel, AppwriteFile awFile) async {
    Functions functions = Functions(_client);

    // start execution
    var execution = functions.createExecution(functionId: _migratorFunct!.$id, data: fileModel.$id);
    awFile.insertExecutions.add(execution);
  }

  Future<MultipartFile> get _migratorCode async => MultipartFile.fromBytes(
        "code",
        (await rootBundle.load('assets/insert_bundle_code.tar.gz')).buffer.asUint8List(),
        filename: "insert_bundle_code.tar.gz",
        contentType: mime.MediaType.parse("application/x-gzip"),
      );

  Future debugCreateMigratorFunction() async {
    var functions = Functions(_client);
    await _createMigratorFunction(functions);
  }

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
}
