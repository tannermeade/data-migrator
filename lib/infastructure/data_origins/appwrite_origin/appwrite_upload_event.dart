import 'package:data_migrator/infastructure/data_origins/appwrite_origin/appwrite_file.dart';
import 'dart:io';

class AppwriteUploadEvent {
  AppwriteUploadEvent({
    required this.awFile,
    required this.uploadIndex,
  });

  AppwriteFile awFile;
  int uploadIndex;

  File get file => awFile.files[uploadIndex];
}
