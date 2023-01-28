import 'package:data_migrator/domain/conversion/type_adpaters/type_adapter.dart';

class ConvertAdapters {
  ConvertAdapters({
    required this.sourceSchemaFields,
    required this.adapters,
  });

  List<List<int>> sourceSchemaFields;
  List<TypeAdapter> adapters;
  
}
