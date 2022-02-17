import 'package:data_migrator/domain/conversion/type_adpaters/type_adapter.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_float.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_int.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_string.dart';

class StringAdapter extends TypeAdapter {
  Function(dynamic)? _convertToString;

  StringAdapter({
    required SchemaDataType sourceSchemaDataType,
    required SchemaDataType destinationSchemaDataType,
  }) : super(sourceSchemaDataType: sourceSchemaDataType, destinationSchemaDataType: destinationSchemaDataType) {
    if (destinationSchemaDataType is! SchemaString) {
      // this isn't a job for string adapter...
      throw Exception("Can't create a StringAdapter for a non-string destination: "
          "${sourceSchemaDataType.runtimeType} to ${destinationSchemaDataType.runtimeType}");
    }
    switch (sourceSchemaDataType.runtimeType) {
      case SchemaInt:
        _convertToString = _handleIntToString;
        break;
      case SchemaFloat:
        _convertToString = _handleDoubleToString;
        break;
      default:
        // this isn't a job for string adapter...
        throw Exception("Can't create a StringAdapter for unsupported types: "
            "${sourceSchemaDataType.runtimeType} to ${destinationSchemaDataType.runtimeType}");
    }
  }

  @override
  dynamic convert(dynamic sourceData) {
    if (_convertToString != null) sourceData = _convertToString!(sourceData);
    return sourceData;
  }

  @override
  String toString() {
    return "StringAdapter($sourceSchemaDataType)";
  }

  String _handleIntToString(dynamic data) {
    if (![int, BigInt].contains(data.runtimeType)) {
      throw Exception("StringAdapter is trying to adapt a non-integer like an integer.");
    }
    return _handleToString(data);
  }

  String _handleDoubleToString(dynamic data) {
    if (![double].contains(data.runtimeType)) {
      throw Exception("StringAdapter is trying to adapt a non-float like an float.");
    }
    return _handleToString(data);
  }

  String _handleToString(dynamic data) {
    try {
      if (data == null) {
        if ((destinationSchemaDataType as SchemaString).nullable) {
          return data;
        } else {
          return (destinationSchemaDataType as SchemaString).defaultValue!;
        }
      }
      return data.toString();
    } catch (e) {
      print(e);
      throw Exception(
          "StringAdapter failed converting data. Schema probably is not nullable, defaultValue is null, and data was null.");
    }
  }

  @override
  bool operator ==(Object other) =>
      other is StringAdapter &&
      other.sourceSchemaDataType == sourceSchemaDataType &&
      other.destinationSchemaDataType == destinationSchemaDataType;

  @override
  int get hashCode => Object.hash(StringAdapter, sourceSchemaDataType, destinationSchemaDataType);
}
