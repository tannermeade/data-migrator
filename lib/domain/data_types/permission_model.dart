import 'enums.dart';

class PermissionModel {
  PermissionModel({
    required this.level,
    required this.readAccess,
    required this.writeAccess,
  });

  PermissionLevel level;
  List<String> readAccess;
  List<String> writeAccess;
}
