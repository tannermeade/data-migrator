import 'package:data_migrator/domain/conversion/type_adpaters/type_adapter.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_default_value.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_nullable.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_signed.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_size.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';

class CopyAdapter extends TypeAdapter {
  Function(dynamic)? _convertNullable;
  Function(dynamic)? _convertSigned;
  Function(dynamic)? _convertSizeInt;
  Function(dynamic)? _convertSizeRangeMin;
  Function(dynamic)? _convertSizeRangeMax;
  Function(dynamic)? _convertDefaultValue;

  CopyAdapter({
    required SchemaDataType sourceSchemaDataType,
    required SchemaDataType destinationSchemaDataType,
  }) : super(sourceSchemaDataType: sourceSchemaDataType, destinationSchemaDataType: destinationSchemaDataType) {
    if (sourceSchemaDataType.runtimeType == destinationSchemaDataType.runtimeType) {
      // handle differences
      if (sourceSchemaDataType is SchemaNullable &&
          (sourceSchemaDataType as SchemaNullable).nullable != (destinationSchemaDataType as SchemaNullable).nullable) {
        // init nullable function
        _convertNullable = _handleNullable;
      }
      if (sourceSchemaDataType is SchemaSigned &&
          (sourceSchemaDataType as SchemaSigned).signed != (destinationSchemaDataType as SchemaSigned).signed) {
        // init signed function
        _convertSigned = _handleSigned;
      }
      if (sourceSchemaDataType is SchemaSizeInt &&
          (sourceSchemaDataType as SchemaSizeInt).size != (destinationSchemaDataType as SchemaSizeInt).size) {
        // init size int function
        _convertSizeInt = _handleSizeInt;
      }
      if (sourceSchemaDataType is SchemaSizeRange) {
        if ((sourceSchemaDataType as SchemaSizeRange).min != (destinationSchemaDataType as SchemaSizeRange).min) {
          // init size min function
          _convertSizeRangeMin = _handleSizeRangeMin;
        }
        if ((sourceSchemaDataType as SchemaSizeRange).max != (destinationSchemaDataType as SchemaSizeRange).max) {
          // init size max function
          _convertSizeRangeMax = _handleSizeRangeMax;
        }
      }
      if (sourceSchemaDataType is SchemaDefaultValue &&
          (sourceSchemaDataType as SchemaDefaultValue).defaultValue !=
              (destinationSchemaDataType as SchemaDefaultValue).defaultValue) {
        // init default value function
        _convertDefaultValue = _handleDefaultValue;
      }
    } else {
      // this isn't a job for copy adapter...
      throw Exception("Can't create a CopyAdapter for unrelated types: "
          "${sourceSchemaDataType.runtimeType} and ${destinationSchemaDataType.runtimeType}");
    }
  }

  @override
  dynamic convert(dynamic sourceData) {
    if (_convertNullable != null) sourceData = _convertNullable!(sourceData);
    if (_convertSigned != null) sourceData = _convertSigned!(sourceData);
    if (_convertSizeInt != null) sourceData = _convertSizeInt!(sourceData);
    if (_convertSizeRangeMin != null) sourceData = _convertSizeRangeMin!(sourceData);
    if (_convertSizeRangeMax != null) sourceData = _convertSizeRangeMax!(sourceData);
    if (_convertDefaultValue != null) sourceData = _convertDefaultValue!(sourceData);
    return sourceData;
  }

  @override
  String toString() {
    return "CopyAdapter($sourceSchemaDataType)";
  }

  dynamic _handleNullable(dynamic data) {
    if (data != null) {
      return data;
    } else if (destinationSchemaDataType is SchemaDefaultValue &&
        (destinationSchemaDataType as SchemaDefaultValue).defaultValue != null) {
      return (destinationSchemaDataType as SchemaDefaultValue).defaultValue;
    }
    throw Exception("Incompatible Schema Types for CopyAdapter: Source data is NULL, destination can't be NULL, and "
        "destination has no default Value.");
  }

  dynamic _handleSigned(dynamic data) {
    return data;
  }

  dynamic _handleSizeInt(dynamic data) {
    return data;
  }

  dynamic _handleSizeRangeMin(dynamic data) {
    return data;
  }

  dynamic _handleSizeRangeMax(dynamic data) {
    return data;
  }

  dynamic _handleDefaultValue(dynamic data) {
    return data;
  }

  @override
  bool operator ==(Object other) =>
      other is CopyAdapter &&
      other.sourceSchemaDataType == sourceSchemaDataType &&
      other.destinationSchemaDataType == destinationSchemaDataType;

  @override
  int get hashCode => Object.hash(CopyAdapter, sourceSchemaDataType, destinationSchemaDataType);
}
