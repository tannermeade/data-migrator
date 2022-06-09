import 'package:data_migrator/domain/conversion/conversion/convert_schema_field.dart';
import 'package:data_migrator/domain/conversion/conversion/convert_schema_map.dart';
import 'package:data_migrator/domain/conversion/conversion/schema_converter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/copy_adapter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/float_adapter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/int_adapter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/string_adapter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/type_adapter.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:data_migrator/ui/common/values/providers.dart';
import 'package:data_migrator/ui/common/widgets/add_widget.dart';
import 'package:data_migrator/ui/common/widgets/type_adapter_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConvertSchemaFieldWidget extends StatefulWidget {
  const ConvertSchemaFieldWidget({
    Key? key,
    required this.convertSchemaField,
    required this.convertSchemaMap,
    this.onDelete,
  }) : super(key: key);

  final ConvertSchemaMap convertSchemaMap;
  final ConvertSchemaField convertSchemaField;
  final VoidCallback? onDelete;

  @override
  State<ConvertSchemaFieldWidget> createState() => _ConvertSchemaFieldWidgetState();
}

class _ConvertSchemaFieldWidgetState extends State<ConvertSchemaFieldWidget> {
  bool _isHovering = false;
  bool _isDeleteHovering = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        var sourceOrigin = ref.read(sourceOriginProvider);
        var destinationOrigin = ref.read(destinationOriginProvider);
        var sourceField;
        if (widget.convertSchemaField.sourceSchemaField != null) {
          sourceField = SchemaConverter.getFromSchemaAddress(
              sourceOrigin.getSchema(), widget.convertSchemaField.sourceSchemaField!);
          List<int> sourceMapAddr = widget.convertSchemaField.sourceSchemaField!.toList();
          sourceMapAddr.removeLast();
        }

        var destinationField;
        if (widget.convertSchemaField.destinationSchemaField != null) {
          destinationField = SchemaConverter.getFromSchemaAddress(
              destinationOrigin.schema, widget.convertSchemaField.destinationSchemaField!);
          List<int> destinationMapAddr = widget.convertSchemaField.destinationSchemaField != null
              ? widget.convertSchemaField.destinationSchemaField!.toList()
              : [0, 0];
          destinationMapAddr.removeLast();
        }

        return MouseRegion(
          onEnter: (e) => setState(() => _isHovering = true),
          onExit: (e) => setState(() => _isHovering = false),
          child: Container(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AlpineColors.background3b,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: AlpineColors.background3b),
            ),
            child: Stack(
              children: [
                _buildBody(sourceField, destinationField),
                if (_isHovering) _buildDelete(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDelete() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => setState(() => _isDeleteHovering = true),
      onExit: (event) => setState(() => _isDeleteHovering = false),
      child: Container(
        margin: const EdgeInsets.only(top: 10, left: 10),
        child: GestureDetector(
          onTap: widget.onDelete,
          child: _isHovering
              ? _isDeleteHovering
                  ? Icon(Icons.delete, color: AlpineColors.warningColor)
                  : Icon(Icons.delete_outline, color: Colors.white.withOpacity(0.15))
              : const SizedBox(width: 24),
        ),
      ),
    );
  }

  Widget _buildBody(sourceField, destinationField) {
    return Column(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_buildDropdown(true)],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_right_alt_rounded, color: AlpineColors.textColor2),
              ),
              Expanded(child: _buildDropdown(false)),
            ],
          ),
        ),
        Divider(color: AlpineColors.background1a, thickness: 1),
        Container(
          margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Type Adapters", style: TextStyle(color: AlpineColors.textColor2)),
              AddWidget(onTap: () {
                var adapter = _buildTypeAdapter(
                  (sourceField as SchemaField).types,
                  (destinationField as SchemaField).types,
                );
                if (adapter != null && !widget.convertSchemaField.typeAdapters.contains(adapter)) {
                  widget.convertSchemaField.typeAdapters.add(adapter);
                  setState(() {});
                } else {
                  print("no adapter added:$adapter");
                }
              }),
            ],
          ),
        ),
        if (widget.convertSchemaField.typeAdapters.isEmpty)
          Text("No Adapters", style: TextStyle(color: AlpineColors.warningColor.withOpacity(0.5))),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.convertSchemaField.typeAdapters
              .map((a) => TypeAdapterWidget(
                    adapter: a,
                    onDelete: () => setState(() => widget.convertSchemaField.typeAdapters.remove(a)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDropdown(bool forSource) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        var dataOrigin = ref.read(forSource ? sourceOriginProvider : destinationOriginProvider);
        var fieldAddr =
            forSource ? widget.convertSchemaField.sourceSchemaField : widget.convertSchemaField.destinationSchemaField;
        var field = fieldAddr != null ? SchemaConverter.getFromSchemaAddress(dataOrigin.getSchema(), fieldAddr) : null;
        var converter = ref.read(converterProvider);
        var mapAddr =
            forSource ? widget.convertSchemaMap.sourceSchemaMap : widget.convertSchemaMap.destinationSchemaMap;
        List<SchemaField>? schemaMapFields = [];
        List<SchemaField>? uniqueFields;
        if (mapAddr != null) {
          var schemaMap = SchemaConverter.getFromSchemaAddress(dataOrigin.getSchema(), mapAddr);
          if (schemaMap is SchemaMap) {
            schemaMapFields = schemaMap.fields;
            List<SchemaField> usedFields = [];
            for (var mapField in schemaMap.fields) {
              var addr = converter.getAddress(dataOrigin.getSchema(), mapField);
              var found = false;
              for (var connection in widget.convertSchemaMap.connections) {
                var convertField = forSource ? connection.sourceSchemaField : connection.destinationSchemaField;

                if (addr != null && listEquals(convertField, addr)) found = true;
              }
              if (found && field != mapField) usedFields.add(mapField);
            }
            var set1fields = Set.from(schemaMap.fields);
            var setUsedFields = Set.from(usedFields);
            uniqueFields = List.from(set1fields.difference(setUsedFields));
          }
        }

        return DropdownButton<SchemaField>(
          focusColor: Colors.transparent,
          dropdownColor: AlpineColors.background1a,
          value: field,
          underline: const SizedBox(),
          icon: const SizedBox(),
          hint: Text(
            forSource ? "No Source Field" : "No Destination Field",
            style: TextStyle(color: AlpineColors.warningColor),
          ),
          items: (uniqueFields ?? schemaMapFields)
              .map((f) => DropdownMenuItem<SchemaField>(
                  child: Wrap(
                    clipBehavior: Clip.antiAlias,
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    runAlignment : WrapAlignment.center,
                    children: [
                      Text(
                        converter.getAddress(dataOrigin.getSchema(), f).toString(),
                        style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 12),
                      ),
                      Text(
                        f.title,
                        style: TextStyle(color: AlpineColors.textColor2, fontSize: 12),
                      ),
                      Text(
                        f.types.map((e) => e.readableString()).join(', '),
                        style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 12),
                      ),
                    ],
                  ),
                  value: f))
              .toList(),
          onChanged: (SchemaField? value) {
            if (value == null) return;
            var result = converter.getAddress(dataOrigin.getSchema(), value);
            if (forSource) {
              widget.convertSchemaField.sourceSchemaField = result;
            } else {
              widget.convertSchemaField.destinationSchemaField = result;
            }
            widget.convertSchemaField.typeAdapters = [];
            setState(() {});
          },
        );
      },
    );
  }

  TypeAdapter? _buildTypeAdapter(List<SchemaDataType> sourceTypes, List<SchemaDataType> destinationTypes) {
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
  }
}
