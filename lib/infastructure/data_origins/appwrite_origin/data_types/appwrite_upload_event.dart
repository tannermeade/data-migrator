import 'package:data_migrator/infastructure/data_origins/appwrite_origin/data_types/appwrite_file_group.dart';
import 'dart:io';

class AppwriteUploadEvent {
  AppwriteUploadEvent({
    required this.awFileGroup,
    required this.uploadIndex,
  });

  AppwriteFileGroup awFileGroup;
  int uploadIndex;

  File get file => awFileGroup.files[uploadIndex];
}
