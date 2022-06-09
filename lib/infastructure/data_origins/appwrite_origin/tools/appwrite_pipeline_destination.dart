// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:console_flutter_sdk/appwrite.dart';
import 'package:console_flutter_sdk/models.dart' as models;
import 'package:data_migrator/domain/conversion/conversion/schema_converter.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/data_types/appwrite_file_group.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/data_types/appwrite_upload_event.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/tools/appwrite_adapter.dart';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class AppwritePipelineDestination {
  AppwritePipelineDestination({
    required this.adapter,
  });

  AppwriteAdapter adapter;

  bool _cancelStream = false;
  List<AppwriteFileGroup> _awFileGroups = [];
  static const _dataSeparator = ",\n";

  StreamController<AppwriteUploadEvent>? _uploadStreamController;
  StreamSubscription<AppwriteUploadEvent>? _uploadStreamSubscription;

  //////////////////////////////
  /// Data Bundling Pipeline ///
  //////////////////////////////

  Sink<List<List>>? getDataSink(List<int> schemaIndex) => _awFileGroups[schemaIndex.first].streamController != null
      ? _awFileGroups[schemaIndex.first].streamController!.sink
      : null;

  void closeDataSink(List<int> schemaIndex) => _cancelStream = true;

  Future<Sink<List<List>>> openDataSink(
    List<int> schemaIndex,
    List<SchemaMap> schema,
  ) async {
    SchemaMap schemaObj = SchemaConverter.getFromSchemaAddress(schema, schemaIndex);

    await adapter.validateCloudFunction();
    await adapter.validateStorageBucket();

    schemaObj = SchemaMap.copyWith(
      schemaObj,
      id: await _validateOrCreateCollection(schemaObj),
      mutable: false,
    );

    // schemaObj.id = await _validateCollection(schemaObj);
    // schemaObj.mutable = false;
    List<String> fieldTitles = schemaObj.fields.map((f) => f.title).toList();
    File file = await _writeFileHeader(fieldTitles, schemaObj.id!, 1);

    _awFileGroups.add(AppwriteFileGroup(
      files: [file],
      streamController: StreamController<List<List>>(),
      collectionId: schemaObj.id!,
      fields: fieldTitles,
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
        _awFileGroups[fileGroupIndex].dataWriteByteCount! > adapter.config.bundleByteSize) {
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
        _awFileGroups[fileGroupIndex].fields,
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

  Future<File> _writeFileHeader(List<String> fields, String collectionId, int bundleNum) async {
    var file = await _createFile(collectionId, bundleNum);
    String fieldStr = '["' + fields.join('","') + '"]';
    String header = '{"fields":' + fieldStr + ',\n"collectionId":"' + collectionId + '",\n"data":[\n';
    await file.writeAsString(header);
    return file;
  }

  Future _finishFile(AppwriteFileGroup awFileGroup) async {
    await _writeFileFooter(awFileGroup.lastFile);
    if (_uploadStreamController == null) _initUploadStream();
    _uploadStreamController!.sink
        .add(AppwriteUploadEvent(awFileGroup: awFileGroup, uploadIndex: awFileGroup.files.length - 1));
  }

  //////////////////////////
  /// Uploading Pipeline ///
  //////////////////////////

  void _initUploadStream() {
    _uploadStreamController = StreamController<AppwriteUploadEvent>();
    _uploadStreamSubscription = _uploadStreamController!.stream.listen(_handleUploadStream);
  }

  Future<String> _validateOrCreateCollection(
    SchemaMap schemaObj,
  ) async {
    var collection = await adapter.getCollection(schemaObj);
    if (collection == null) {
      var collection = await adapter.createCollection(schemaObj);
      return collection.$id;
    }
    return collection.$id;
  }

  Future _handleUploadStream(AppwriteUploadEvent uploadEvent) async {
    // if (adapter.config.migratorFunct == null) {
    //   _uploadStreamSubscription!.pause();
    //   await adapter.initMigratorCloudFunction();
    //   _uploadStreamSubscription!.resume();
    // }
    await _uploadFile(uploadEvent);
  }

  Future _uploadFile(AppwriteUploadEvent uploadEvent) async {
    var multipartFile = await MultipartFile.fromPath("file", uploadEvent.file.path);
    var inputFile = InputFile(
      file: multipartFile,
      path: uploadEvent.file.path,
      filename: basename(uploadEvent.file.path),
    );
    var storage = Storage(adapter.config.client);
    Future<models.File> f = storage.createFile(
      fileId: "unique()",
      file: inputFile,
      bucketId: adapter.config.bucketId,
      // read: ['role:all'],
      // write: ['role:all'],
    );
    uploadEvent.awFileGroup.uploadedFiles.add(f);
    f.then((fileModel) => _handleCloudExecution(fileModel, uploadEvent.awFileGroup));
  }

  Future _handleCloudExecution(models.File fileModel, AppwriteFileGroup awFileGroup) async {
    Functions functions = Functions(adapter.config.client);

    // start execution
    var execution = functions.createExecution(functionId: adapter.config.migratorFunct!.$id, data: fileModel.$id);
    awFileGroup.insertExecutions.add(execution);
  }

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
