import 'enums.dart';

class PermissionModel {
  PermissionModel({
    required this.permissionType,
    required this.readAccess,
    required this.writeAccess,
  });

  PermissionLevel permissionType;
  List<String> readAccess;
  List<String> writeAccess;
}
