import 'change_type.dart';
import 'variable_change.dart';

class SchemaChange {
  SchemaChange({
    required this.id,
    required this.changeType,
    required this.changes,
  });

  String id;
  ChangeType changeType;
  List<VariableChange> changes;

  operator [](String key) {
    try {
      return changes.firstWhere((el) => el.key == key).value;
    } catch (e) {
      print("Error Accessing SchemaChange with key [$key]. Key does not exist.");
      return null;
    }
  }
}
