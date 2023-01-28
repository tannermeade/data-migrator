import 'package:data_migrator/domain/data_types/enums.dart';
import 'package:data_migrator/domain/data_types/permission_model.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_string.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';

class AppwriteUserSchema extends SchemaMap {
  AppwriteUserSchema()
      : super(
          name: "Users",
          mutable: false,
          permissionModel: PermissionModel(level: PermissionLevel.data, readAccess: [], writeAccess: []),
          indices: [],
          classification: SchemaClassification.appwriteUsers,
          fields: [
            SchemaField(
              title: "\$id",
              isList: false,
              required: false,
              types: [
                SchemaString(
                  type: StringType.id,
                  size: 36,
                  nullable: false,
                )
              ],
            ),
            SchemaField(
              title: "name",
              isList: false,
              required: true,
              types: [SchemaString.object()],
            ),
            SchemaField(
              title: "email",
              isList: false,
              required: true,
              types: [
                SchemaString(
                  type: StringType.email,
                  // size: 36,
                  nullable: false,
                )
              ],
            ),
            SchemaField(
              title: "password",
              isList: false,
              required: true,
              types: [
                SchemaString(type: StringType.argon2),
                SchemaString(type: StringType.bcrypt),
                SchemaString(type: StringType.md5),
                SchemaString(type: StringType.phpass),
                SchemaString(type: StringType.scrypt),
                SchemaString(type: StringType.scryptFirebase),
                SchemaString(type: StringType.sha),
              ],
            ),
          ],
          enabled: true,
        );
}
