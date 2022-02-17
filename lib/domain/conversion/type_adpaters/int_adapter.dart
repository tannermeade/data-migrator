import 'package:data_migrator/domain/conversion/type_adpaters/type_adapter.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_float.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_int.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_string.dart';

class IntAdapter extends TypeAdapter {
  Function(dynamic)? _convertToString;

  IntAdapter({
    required SchemaDataType sourceSchemaDataType,
    required SchemaDataType destinationSchemaDataType,
  }) : super(sourceSchemaDataType: sourceSchemaDataType, destinationSchemaDataType: destinationSchemaDataType) {
    if (destinationSchemaDataType is! SchemaInt) {
      // this isn't a job for int adapter...
      throw Exception("Can't create a IntAdapter for a non-integer destination: "
          "${sourceSchemaDataType.runtimeType} to ${destinationSchemaDataType.runtimeType}");
    }
    switch (sourceSchemaDataType.runtimeType) {
      case SchemaString:
        _convertToString = _handleStringToInt;
        break;
      case SchemaFloat:
        _convertToString = _handleDoubleToInt;
        break;
      default:
        // this isn't a job for string adapter...
        throw Exception("Can't create a IntAdapter for unsupported types: "
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
    return "IntAdapter($sourceSchemaDataType)";
  }

  dynamic _handleStringToInt(dynamic data) {
    if (![String].contains(data.runtimeType)) {
      throw Exception("IntAdapter is trying to adapt a non-string like an string.");
    }
    String cleanData = "";
    try {
      if (data != null) cleanData = (data as String).replaceAll(RegExp(r'[^0-9]'), '');
    } catch (e) {
      print(e);
      throw Exception(
          "IntAdapter failed converting data. Failed replacing non integer characters in string. Data probably "
          "isn't a string.");
    }
    try {
      if (cleanData.isEmpty) {
        if ((destinationSchemaDataType as SchemaInt).nullable) {
          return null;
        } else {
          return (destinationSchemaDataType as SchemaInt).defaultValue;
        }
      }
      if (data == null) {
        if ((destinationSchemaDataType as SchemaInt).nullable) {
          return data;
        } else {
          return (destinationSchemaDataType as SchemaInt).defaultValue!;
        }
      }
    } catch (e) {
      print(e);
      throw Exception(
          "IntAdapter failed converting data. Schema probably is not nullable, defaultValue is null, and data was null.");
    }

    try {
      return int.parse(cleanData);
    } catch (e) {
      print(e);
      throw Exception("IntAdapter failed converting data. The string data was not parsable.");
    }
  }

  dynamic _handleDoubleToInt(dynamic data) {
    if (![double].contains(data.runtimeType)) {
      throw Exception("IntAdapter is trying to adapt a non-double like an double.");
    }
    try {
      if (data == null) {
        if ((destinationSchemaDataType as SchemaInt).nullable) {
          return data;
        } else {
          return (destinationSchemaDataType as SchemaInt).defaultValue!;
        }
      }
    } catch (e) {
      print(e);
      throw Exception(
          "IntAdapter failed converting data. Schema probably is not nullable, defaultValue is null, and data was null.");
    }

    try {
      return (data as double).toInt();
    } catch (e) {
      print(e);
      throw Exception("IntAdapter failed converting data. The double data failed on toInt().");
    }
  }

  @override
  bool operator ==(Object other) =>
      other is IntAdapter &&
      other.sourceSchemaDataType == sourceSchemaDataType &&
      other.destinationSchemaDataType == destinationSchemaDataType;

  @override
  int get hashCode => Object.hash(IntAdapter, sourceSchemaDataType, destinationSchemaDataType);
}
