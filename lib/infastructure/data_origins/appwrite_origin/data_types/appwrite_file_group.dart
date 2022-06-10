import 'dart:async';
import 'dart:io';
import 'package:console_flutter_sdk/models.dart' as model;
import 'package:data_migrator/domain/data_types/schema_map.dart';

class AppwriteFileGroup {
  AppwriteFileGroup({
    List<File>? files,
    this.dataWriteByteCount,
    this.streamController,
    this.streamSubscription,
    // this.schemaAddress,
    required this.collectionId,
    required this.schemaMap,
  }) : this.files = files ?? [];

  File get lastFile => files.last;

  List<File> files;
  List<Future<model.File>> uploadedFiles = [];
  List<Future<model.Execution>> insertExecutions = [];
  int? dataWriteByteCount;
  // List<int>? schemaAddress;
  String collectionId;
  SchemaMap schemaMap;
  StreamController<List<List>>? streamController;
  StreamSubscription<List<List>>? streamSubscription;
}
