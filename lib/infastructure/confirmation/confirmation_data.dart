import 'package:data_migrator/domain/data_types/schema_data_type.dart';

import 'schema_map_change.dart';

class ConfirmationData {
  ConfirmationData({
    required this.sentence,
    required this.forDestination,
    required this.schemaBefore,
    required this.schemaAfter,
    required this.onConfirmed,
    required this.schemaMapChange,
  });

  String sentence;
  bool forDestination;
  SchemaDataType? schemaBefore;
  SchemaDataType? schemaAfter;
  Future Function() onConfirmed;
  SchemaMapChange schemaMapChange;
}
