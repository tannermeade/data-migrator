import 'package:data_migrator/domain/conversion/type_adpaters/type_adapter.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';

import 'convert_conditions.dart';
import 'convert_adapters.dart';
import 'convert_schema_obj.dart';
import 'enums.dart';

class ConvertSchemaField implements ConvertSchemaObj {
  ConvertSchemaField({
    this.destinationSchemaField,
    this.defaultSourceSchemaField,
    List<TypeAdapter>? defaultAdapters,
    Map<ConvertConditional, ConvertAdapters>? conditionals,
    this.level,
  })  : defaultAdapters = defaultAdapters ?? [],
        conditionals = conditionals ?? {};

  List<int>? destinationSchemaField;
  List<int>? defaultSourceSchemaField;
  List<TypeAdapter> defaultAdapters;
  Map<ConvertConditional, ConvertAdapters> conditionals;
  ConnectionLevel? level;

  static ConvertSchemaField fromSource({required SchemaField schemaField, required List<int> address}) {
    return ConvertSchemaField(
      defaultSourceSchemaField: address,
      // connectionType: ConnectionType.direct,
      defaultAdapters: [],
    );
  }

  @override
  String toString() {
    return """ConvertSchemaField(
        destination: $destinationSchemaField,
        conditionals:${conditionals.length},
        defaultAdapters: $defaultAdapters,
      )""";
  }

  dynamic convert(List sourceMapValues) {
    // execute all conditions falling back on the defaults
    TypeAdapter? typeAdapter;

    for (var conditionalEntry in conditionals.entries) {
      if (conditionalEntry.key.execute(sourceMapValues)) {
        // get the source field
        int index = conditionalEntry.value.sourceSchemaFields.first.last;
        // get the adapter: it's the adapter that matches this particular data field type
        typeAdapter = conditionalEntry.value.adapters
            .firstWhere((el) => el.sourceSchemaDataType.isOfType(sourceMapValues[index]));
        return typeAdapter.convert(sourceMapValues[index]);
      }
    }

    typeAdapter ??= _getDefaultAdapter(sourceMapValues);
    
    return typeAdapter.convert(sourceMapValues[defaultSourceSchemaField!.last]);
  }

  TypeAdapter _getDefaultAdapter(List sourceMapValues) {
    if (defaultSourceSchemaField == null) throw Exception("No default source schema field defined.");
    int index = defaultSourceSchemaField!.last;
    return defaultAdapters.firstWhere((el) => el.sourceSchemaDataType.isOfType(sourceMapValues[index]));
  }

  bool isMatch(int fieldIndex) {
    for (ConvertConditional conditional in conditionals.keys) {
      for (SingleConvertCondition condition in conditional.conditions) {
        condition.preOperandField;
      }
    }

    return defaultSourceSchemaField != null &&
        defaultSourceSchemaField!.isNotEmpty &&
        defaultSourceSchemaField!.last == fieldIndex;
  }
}
