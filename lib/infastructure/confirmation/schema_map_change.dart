import 'package:data_migrator/infastructure/confirmation/variable_change.dart';

import 'change_type.dart';
import 'schema_change.dart';

class SchemaMapChange {
  SchemaMapChange({
    required this.id,
    required this.changeType,
    required this.changes,
    required this.fieldChanges,
    required this.indexChanges,
  });

  String? id;
  ChangeType changeType;
  List<VariableChange> changes;
  List<SchemaChange> fieldChanges;
  List<SchemaChange> indexChanges;
  // dynamic permissionChange;
}
