import 'package:data_migrator/infastructure/confirmation/confirmation_data.dart';
import 'package:data_migrator/domain/conversion/conversion/enums.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/copy_adapter.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_default_value.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_nullable.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/domain/data_types/schema_none.dart';
import 'package:data_migrator/infastructure/data_origins/data_origin.dart';
import 'package:data_migrator/ui/common/values/providers.dart';
import 'package:flutter/foundation.dart';

import 'convert_schema_field.dart';
import 'convert_schema_map.dart';
import 'convert_schema_obj.dart';

class SchemaConverter {
  SchemaConverter();

  List<ConvertSchemaMap> schemaConversions = [];

  void importSourceSchema(List<SchemaMap> schema) {
    for (int i = 0; i < schema.length; i++) {
      schemaConversions.add(ConvertSchemaMap.fromSource(schemaMap: schema[i], address: [i]));
    }
  }

  List<int>? getAddress(dynamic schema, dynamic obj) => _getAddressRecursive(schema, obj.hashCode, []);

  List<int>? _getAddressRecursive(dynamic obj, dynamic hashCode, List<int> addr) {
    var list;
    if (obj is List) {
      list = obj;
    } else if (obj is SchemaMap) {
      list = obj.fields;
    } else if (obj is SchemaField) {
      list = obj.types;
    } else {
      return null;
    }
    for (int i = 0; i < list.length; i++) {
      if (list[i].hashCode == hashCode) return addr + [i];
    }
    for (int i = 0; i < list.length; i++) {
      var result = _getAddressRecursive(list[i], hashCode, addr + [i]);
      if (result != null) return result;
    }
    return null;
  }

  void generateDefaultConversions({
    required List<SchemaMap> source,
    required List<SchemaMap> destination,
  }) {
    schemaConversions = [];

    for (int i = 0; i < source.length; i++) {
      schemaConversions.add(ConvertSchemaMap.fromSource(schemaMap: source[i], address: [i]));
    }

    for (int i = 0; i < schemaConversions.length && i < destination.length; i++) {
      schemaConversions[i].destinationSchemaMap = [i];
      for (int j = 0; j < schemaConversions[i].fieldConversions.length && j < destination[i].fields.length; j++) {
        schemaConversions[i].fieldConversions[j].destinationSchemaField = [i, j];
        schemaConversions[i].fieldConversions[j].level = ConnectionLevel.direct;
        source[i].fields[j].types;
        var sourceField =
            getFromSchemaAddress(source, schemaConversions[i].fieldConversions[j].defaultSourceSchemaField!);
        if (sourceField is SchemaField) {
          // check if all source dataTypes are in destination dataTypes
          bool destinationContainsAllSourceTypes = sourceField.types.fold<bool>(
            true,
            (hasNotFoundAMissingType, type) =>
                hasNotFoundAMissingType &&
                destination[i].fields[j].types.firstWhere((dType) => dType.runtimeType == type.runtimeType,
                    orElse: () => SchemaDataTypeNone()) is! SchemaDataTypeNone,
          );
          if (destinationContainsAllSourceTypes) {
            // add adapters for all source to destination types
            var typeAdapters = sourceField.types
                .map((sourceDataType) => CopyAdapter(
                      sourceSchemaDataType: sourceDataType,
                      destinationSchemaDataType: sourceDataType,
                    ))
                .toList();
            schemaConversions[i].fieldConversions[j].defaultAdapters.addAll(typeAdapters);
          }
        }
      }
    }
  }

  // TypeAdapter _schemaDataTypeToTypeAdapter(SchemaDataType type) {
  //   if (type is SchemaString) {
  //     return StringAdapter();
  //   } else if (type is SchemaInt) {}
  // }

  static dynamic getFromSchemaAddress(List data, List<int> addr) {
    if (addr.length == 1) return data[addr.first];
    List childData = [];
    if (data[addr.first] is SchemaMap) {
      childData = (data[addr.first] as SchemaMap).fields;
    } else if (data[addr.first] is SchemaField) {
      childData = (data[addr.first] as SchemaField).types;
    } else {
      throw Exception(
          "Invalid schema address. One of the address indexes (not the last one) referenced an object that wasn't a "
          "SchemaMap or SchemaField. This usually means that you referenced a SchemaDataType in a "
          "SchemaField.types that wasn't a SchemaMap.");
    }
    return getFromSchemaAddress(childData, addr.sublist(1, addr.length));
  }

  Sink<List<List>>? destinationSink;

  bool validateConversions(DataOrigin sourceOrigin, DataOrigin destinationOrigin) {
    // - no missing type adapters
    // - no missing source/destination
    // - all required destination fields have a valid conversion connection
    // - no missing type adapters

    for (var obj in schemaConversions) {
      if (!_isValidSchema(obj, destinationOrigin)) throw Exception("Can't start conversion. Conversions aren't valid.");
      if (_hasMissingTypeAdapters(obj)) throw Exception("Can't start conversion. Missing type adapters.");
      if (!sourceOrigin.isConversionReady) throw Exception("Can't start conversion. Source isn't ready.");
      if (!destinationOrigin.isConversionReady) throw Exception("Can't start conversion. Destination isn't ready.");
    }
    return true;
  }

  bool _hasMissingTypeAdapters(ConvertSchemaMap schemaMap) {
    for (var field in schemaMap.fieldConversions) {
      if (field.defaultAdapters.isEmpty) return true;
    }
    return false;
  }

  bool _isValidSchema(ConvertSchemaObj schemaObj, DataOrigin destinationOrigin) {
    if (schemaObj is ConvertSchemaMap) {
      if (schemaObj.destinationSchemaMap != null && schemaObj.sourceSchemaMap != null) {
        SchemaMap? destinationMap =
            getFromSchemaAddress(destinationOrigin.getSchema(), schemaObj.destinationSchemaMap!);
        if (destinationMap == null) return false; // invalid conversion destination
        var requiredFields = destinationMap.fields.where((field) => field.required).toList();
        var requiredFieldAddresses = requiredFields.map((field) => getAddress(destinationOrigin.getSchema(), field));
        List<List?> missingFields = [];
        requiredFieldAddresses.forEach((fieldAddr) {
          try {
            schemaObj.fieldConversions.firstWhere((con) => listEquals(con.destinationSchemaField, fieldAddr));
          } catch (e) {
            missingFields.add(fieldAddr);
          }
        });
        // does it have the the required destination fields?
        if (missingFields.isNotEmpty) {
          throw Exception(
              "Can't start conversion. Conversions aren't valid due to missing required destination fields.");
        }
        return true;
      } else {
        throw Exception(
            "Can't start conversion. Conversions aren't valid due to missing source/destination undefined field.");
        return false; // schemaMap source/destination aren't filled out
      }
    }
    throw Exception("Can't start conversion. Conversions aren't valid due to invalid ConversionSchemaMap.");
    return false; // not a ConversionSchemaMap
  }

  Future startConversion({
    required List<int> sourceAddress,
    required DataOrigin source,
    required DataOrigin destination,
    Future<bool> Function(List<ConfirmationData>)? onConfirm,
  }) async {
    // validate sourceAddress exists
    ConvertSchemaMap mapConversion = _getMapConversion(sourceAddress);

    // validate conversion & dataOrigins
    validateConversions(source, destination);
    var sourceConfirms = await source.validate();
    var destinationConfirms = await destination.validate();
    var allConfirms = sourceConfirms + destinationConfirms;
    if (onConfirm != null && allConfirms.isNotEmpty) {
      var confirmed = await onConfirm(allConfirms);
      if (!confirmed) return;
    }

    // start conversion
    destinationSink = await destination.openDataSink(mapConversion.destinationSchemaMap!);
    source.startDataStream(sourceAddress).listen(
          (sourceMapPayload) => _handleConversionEvents(sourceMapPayload, mapConversion, source, destination),
          onDone: () => destinationSink!.close(),
        );
  }

  ConvertSchemaMap _getMapConversion(List<int> sourceAddress) {
    try {
      var mapConversion = schemaConversions.firstWhere((el) => listEquals(el.sourceSchemaMap, sourceAddress));
      if (mapConversion.destinationSchemaMap == null) throw Exception("Error: Conversion missing destination.");
      return mapConversion;
    } catch (e) {
      print(e);
      throw Exception("Can't convert from that source address because no conversions where found for it.");
    }
  }

  void _handleConversionEvents(
    List<List> sourceMapPayload,
    ConvertSchemaMap mapConversion,
    DataOrigin source,
    DataOrigin destination,
  ) {
    // convert data with converter
    var data = _convert(sourceMapPayload, mapConversion, source, destination);

    // send to appwrite destination
    if (destinationSink != null) destinationSink!.add(data);
  }

  List<List> _convert(
    List<List> sourceMapPayload,
    ConvertSchemaMap mapConversion,
    DataOrigin source,
    DataOrigin destination,
  ) {
    List<List> destinationData = [];
    SchemaMap destinationSchemaMap = _getDestinationSchemaMap(mapConversion, destination);
    List defaultDestinationMapValues = _initializeDefaultValues(destinationSchemaMap);
    
    // loop thru rows of data event
    for (int rowIndex = 0; rowIndex < sourceMapPayload.length; rowIndex++) {
      List destinationMapValues = List.from(defaultDestinationMapValues);
      for (ConvertSchemaField fieldConversion in mapConversion.fieldConversions) {
        var convertedFieldData = fieldConversion.convert(sourceMapPayload[rowIndex]);
        destinationMapValues[fieldConversion.destinationSchemaField!.last] = convertedFieldData;
      }

      destinationData.add(destinationMapValues);
    }
    return destinationData;
  }

  List _initializeDefaultValues(SchemaMap destinationSchemaMap) {
    List destinationRow = [];
    for (SchemaField field in destinationSchemaMap.fields) {
      if (field.types.isNotEmpty) {
        var defaultValue =
            field.types.first is SchemaDefaultValue ? (field.types.first as SchemaDefaultValue).defaultValue : null;
        var nullable = field.types.first is SchemaNullable ? (field.types.first as SchemaNullable).nullable : false;
        if (defaultValue != null || nullable) {
          destinationRow.add(defaultValue);
        } else {
          // throw Exception("Conversion failed. No defaultValue for field and field isn't nullable.");
          destinationRow.add(null);
        }
      } else {
        // throw Exception("Conversion failed. A destination SchemaField has empty types.");
        destinationRow.add(null);
      }
    }
    return destinationRow;
  }

  SchemaMap _getDestinationSchemaMap(ConvertSchemaMap convertConnection, DataOrigin destination) {
    // get destinationSchemaMap first
    if (convertConnection.destinationSchemaMap != null) {
      var result = getFromSchemaAddress(destination.getSchema(), convertConnection.destinationSchemaMap!);
      if (result is SchemaMap) return result;
    }
    throw Exception("No Destination SchemaMap");
  }
}
