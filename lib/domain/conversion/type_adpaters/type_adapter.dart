import 'package:data_migrator/domain/conversion/type_adpaters/copy_adapter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/float_adapter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/int_adapter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/string_adapter.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';

abstract class TypeAdapter {
  TypeAdapter({
    required this.sourceSchemaDataType,
    required this.destinationSchemaDataType,
  });

  SchemaDataType sourceSchemaDataType;
  SchemaDataType destinationSchemaDataType;

  dynamic convert(dynamic sourceData);

  static TypeAdapter? buildTypeAdapter(List<SchemaDataType> sourceTypes, List<SchemaDataType> destinationTypes) {
    TypeAdapter adapter;
    for (var sourceType in sourceTypes) {
      for (var destinationType in destinationTypes) {
        try {
          adapter = CopyAdapter(sourceSchemaDataType: sourceType, destinationSchemaDataType: destinationType);
        } catch (e) {
          try {
            adapter = IntAdapter(sourceSchemaDataType: sourceType, destinationSchemaDataType: destinationType);
          } catch (e) {
            try {
              adapter = FloatAdapter(sourceSchemaDataType: sourceType, destinationSchemaDataType: destinationType);
            } catch (e) {
              print(e);
              try {
                adapter = StringAdapter(sourceSchemaDataType: sourceType, destinationSchemaDataType: destinationType);
              } catch (e) {
                continue;
              }
            }
          }
        }
        return adapter;
      }
    }
    return null;
  }
}
