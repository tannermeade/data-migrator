import 'dart:async';
import 'dart:io';
import 'package:console_flutter_sdk/models.dart' as model;

class AppwriteFileGroup {
  AppwriteFileGroup({
    List<File>? files,
    this.dataWriteByteCount,
    this.streamController,
    this.streamSubscription,
    // this.schemaAddress,
    required this.collectionId,
    required this.fields,
  }) : this.files = files ?? [];

  File get lastFile => files.last;

  List<File> files;
  List<Future<model.File>> uploadedFiles = [];
  List<Future<model.Execution>> insertExecutions = [];
  int? dataWriteByteCount;
  // List<int>? schemaAddress;
  String collectionId;
  List<String> fields;
  StreamController<List<List>>? streamController;
  StreamSubscription<List<List>>? streamSubscription;
}
