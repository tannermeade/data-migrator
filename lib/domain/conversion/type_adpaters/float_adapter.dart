import 'package:data_migrator/domain/conversion/type_adpaters/type_adapter.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_float.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_int.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_string.dart';

class FloatAdapter extends TypeAdapter {
  Function(dynamic)? _convertToString;

  FloatAdapter({
    required SchemaDataType sourceSchemaDataType,
    required SchemaDataType destinationSchemaDataType,
  }) : super(sourceSchemaDataType: sourceSchemaDataType, destinationSchemaDataType: destinationSchemaDataType) {
    if (destinationSchemaDataType is! SchemaFloat) {
      // this isn't a job for int adapter...
      throw Exception("Can't create a FloatAdapter for a non-integer destination: "
          "${sourceSchemaDataType.runtimeType} to ${destinationSchemaDataType.runtimeType}");
    }
    switch (sourceSchemaDataType.runtimeType) {
      case SchemaString:
        _convertToString = _handleStringToDouble;
        break;
      case SchemaInt:
        _convertToString = _handleIntToDouble;
        break;
      default:
        // this isn't a job for string adapter...
        throw Exception("Can't create a FloatAdapter for unsupported types: "
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
    return "FloatAdapter($sourceSchemaDataType)";
  }

  dynamic _handleIntToDouble(dynamic data) {
    if (![int, BigInt].contains(data.runtimeType)) {
      throw Exception("FloatAdapter is trying to adapt a non-integer like an integer.");
    }
    try {
      if (data == null) {
        if ((destinationSchemaDataType as SchemaFloat).nullable) {
          return data;
        } else {
          return (destinationSchemaDataType as SchemaFloat).defaultValue!;
        }
      }
    } catch (e) {
      print(e);
      throw Exception(
          "FloatAdapter failed converting data. Schema probably is not nullable, defaultValue is null, and data was null.");
    }

    try {
      return (data as int).toDouble();
    } catch (e) {
      print(e);
      throw Exception("FloatAdapter failed converting data. The int data failed on toDouble().");
    }
  }

  dynamic _handleStringToDouble(dynamic data) {
    if (![String].contains(data.runtimeType)) {
      throw Exception("FloatAdapter is trying to adapt a non-string like an string.");
    }
    String cleanData = "";
    try {
      if (data != null) cleanData = (data as String).replaceAll(RegExp(r'[^0-9.]'), '');
    } catch (e) {
      print(e);
      throw Exception(
          "FloatAdapter failed converting data. Failed replacing non integer characters in string. Data probably "
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
          "FloatAdapter failed converting data. Schema probably is not nullable, defaultValue is null, and data was null.");
    }

    try {
      return double.parse(cleanData);
    } catch (e) {
      print(e);
      throw Exception("FloatAdapter failed converting data. The string data was not parsable.");
    }
  }

  // dynamic _handleStringToDouble(dynamic data) {
  //   if (![double].contains(data.runtimeType)) {
  //     throw Exception("FloatAdapter is trying to adapt a non-string like an string.");
  //   }
  //   try {
  //     if (data == null) {
  //       if ((destinationSchemaDataType as SchemaFloat).nullable) {
  //         return data;
  //       } else {
  //         return (destinationSchemaDataType as SchemaFloat).defaultValue!;
  //       }
  //     }
  //   } catch (e) {
  //     print(e);
  //     throw Exception(
  //         "FloatAdapter failed converting data. Schema probably is not nullable, defaultValue is null, and data was null.");
  //   }

  //   try {
  //     return double.parse(data);
  //   } catch (e) {
  //     print(e);
  //     throw Exception("FloatAdapter failed converting data. The string data wasn't parseable.");
  //   }
  // }

  @override
  bool operator ==(Object other) =>
      other is FloatAdapter &&
      other.sourceSchemaDataType == sourceSchemaDataType &&
      other.destinationSchemaDataType == destinationSchemaDataType;

  @override
  int get hashCode => Object.hash(FloatAdapter, sourceSchemaDataType, destinationSchemaDataType);
}
