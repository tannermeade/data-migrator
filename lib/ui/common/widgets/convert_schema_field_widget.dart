import 'package:data_migrator/domain/conversion/conversion/convert_adapters.dart';
import 'package:data_migrator/domain/conversion/conversion/convert_conditions.dart';
import 'package:data_migrator/domain/conversion/conversion/convert_schema_field.dart';
import 'package:data_migrator/domain/conversion/conversion/convert_schema_map.dart';
import 'package:data_migrator/domain/conversion/conversion/schema_converter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/copy_adapter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/float_adapter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/int_adapter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/string_adapter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/type_adapter.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_object.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_float.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_int.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_string.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/infastructure/data_origins/data_origin.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:data_migrator/ui/common/values/providers.dart';
import 'package:data_migrator/ui/common/widgets/add_widget.dart';
import 'package:data_migrator/ui/common/widgets/primitive_input/string_field.dart';
import 'package:data_migrator/ui/common/widgets/type_adapter_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'primitive_input/float_field.dart';
import 'primitive_input/int_field.dart';

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
        SchemaObject? sourceField;
        if (widget.convertSchemaField.defaultSourceSchemaField != null) {
          sourceField = SchemaConverter.getFromSchemaAddress(
              sourceOrigin.getSchema(), widget.convertSchemaField.defaultSourceSchemaField!);
          List<int> sourceMapAddr = widget.convertSchemaField.defaultSourceSchemaField!.toList();
          sourceMapAddr.removeLast();
        }

        SchemaObject? destinationField;
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

  Widget _buildBody(SchemaObject? sourceField, SchemaObject? destinationField) {
    return Column(
      children: [
        // Container(
        //   clipBehavior: Clip.antiAlias,
        //   decoration: const BoxDecoration(color:Colors.red),
        //   padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        //   width: 100,
        //   child: _buildDropdown(false),
        //   // Row(
        //   //   mainAxisAlignment: MainAxisAlignment.spaceAround,
        //   //   crossAxisAlignment: CrossAxisAlignment.center,
        //   //   children: [
        //   //     // Expanded(
        //   //     //   child: Row(
        //   //     //     mainAxisAlignment: MainAxisAlignment.end,
        //   //     //     children: [_buildDropdown(true)],
        //   //     //   ),
        //   //     // ),
        //   //     // Container(
        //   //     //   margin: const EdgeInsets.symmetric(horizontal: 10),
        //   //     //   child: Icon(Icons.arrow_right_alt_rounded, color: AlpineColors.textColor2),
        //   //     // ),
        //   //     Expanded(child: _buildDropdown(false)),
        //   //   ],
        //   // ),
        // ),
        SizedBox(
          width: 200,
          child: _buildDestinationDropdown(),
        ),
        Divider(color: AlpineColors.background1a, thickness: 1),
        ..._buildDefault(sourceField, destinationField),
        const SizedBox(height: 10),
        ..._buildConditions(sourceField, destinationField),
        const SizedBox(height: 10),
      ],
    );
  }

  List<Widget> _buildDefault(SchemaObject? sourceField, SchemaObject? destinationField) {
    return [
      Container(
        margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Default", style: TextStyle(color: AlpineColors.textColor2)),
            AddWidget(onTap: () {
              var adapter = TypeAdapter.buildTypeAdapter(
                (sourceField as SchemaField).types,
                (destinationField as SchemaField).types,
              );
              if (adapter != null && !widget.convertSchemaField.defaultAdapters.contains(adapter)) {
                widget.convertSchemaField.defaultAdapters.add(adapter);
                setState(() {});
              } else {
                print("no adapter added:$adapter");
              }
            }),
          ],
        ),
      ),
      Row(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSourceDropdown(null),
          ),
          Expanded(
            child: _buildAdapterSection(),
          ),
        ],
      ),
    ];
  }

  Widget _buildAdapterSection() {
    return Consumer(builder: (context, ref, child) {
      var sourceDataOrigin = ref.read(sourceOriginProvider);
      List<int>? sourceFieldAddr = widget.convertSchemaField.defaultSourceSchemaField;
      var sourceSchemaField = sourceFieldAddr != null
          ? SchemaConverter.getFromSchemaAddress(sourceDataOrigin.getSchema(), sourceFieldAddr)
          : null;
      if (sourceSchemaField is! SchemaField?) {
        sourceSchemaField = null;
      }

      var destinationDataOrigin = ref.read(destinationOriginProvider);
      List<int>? destinationFieldAddr = widget.convertSchemaField.destinationSchemaField;
      var destinationSchemaField = destinationFieldAddr != null
          ? SchemaConverter.getFromSchemaAddress(destinationDataOrigin.getSchema(), destinationFieldAddr)
          : null;
      if (destinationSchemaField is! SchemaField?) {
        destinationSchemaField = null;
      }

      List<Widget> adapters = [];

      for (int i = 0; i < widget.convertSchemaField.defaultAdapters.length; i++) {
        adapters.add(TypeAdapterWidget(
          adapter: widget.convertSchemaField.defaultAdapters[i],
          sourceField: sourceSchemaField,
          destinationField: destinationSchemaField,
          onDelete: () => setState(() => widget.convertSchemaField.defaultAdapters.removeAt(i)),
          onAdapterChange: (typeAdapter) => setState(() => widget.convertSchemaField.defaultAdapters[i] = typeAdapter),
        ));
      }

      return Column(children: [
        if (widget.convertSchemaField.defaultAdapters.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 35),
            child: Text("No Adapters", style: TextStyle(color: AlpineColors.warningColor.withOpacity(0.5))),
          ),
        ...adapters,
        // widget.convertSchemaField.defaultAdapters
        //     .map((a) => TypeAdapterWidget(
        //           adapter: a,
        //           sourceField: sourceSchemaField,
        //           destinationField: destinationSchemaField,
        //           onDelete: () => setState(() => widget.convertSchemaField.defaultAdapters.remove(a)),
        //           onAdapterChange: (typeAdapter) => widget.convertSchemaField.defaultAdapters.
        //           a = typeAdapter,
        //         ))
        //     .toList(),
      ]);
    });
  }

  List<Widget> _buildConditions(SchemaObject? sourceField, SchemaObject? destinationField) {
    return [
      Container(
        margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Conditions", style: TextStyle(color: AlpineColors.textColor2)),
            AddWidget(onTap: () {
              widget.convertSchemaField.conditionals[ConvertConditional(conditions: [])] = ConvertAdapters(
                sourceSchemaFields: [
                  // (sourceField as SchemaField)
                ],
                adapters: [],
              );
              setState(() {});
              // var adapter = _buildTypeAdapter(
              //   (sourceField as SchemaField).types,
              //   (destinationField as SchemaField).types,
              // );
              // if (adapter != null && !widget.convertSchemaField.defaultAdapters.contains(adapter)) {
              //   widget.convertSchemaField.defaultAdapters.add(adapter);
              //   setState(() {});
              // } else {
              //   print("no adapter added:$adapter");
              // }
            }),
          ],
        ),
      ),
      if (widget.convertSchemaField.conditionals.isEmpty)
        Text("No Conditions Added", style: TextStyle(color: Colors.grey.withOpacity(0.5))),
      Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildEditConditionalWidgets(),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildSourceDropdown(List<int>? inputFieldAddr) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        var dataOrigin = ref.read(sourceOriginProvider);
        var fieldAddr = inputFieldAddr ?? widget.convertSchemaField.defaultSourceSchemaField;
        var field = fieldAddr != null ? SchemaConverter.getFromSchemaAddress(dataOrigin.getSchema(), fieldAddr) : null;
        var converter = ref.read(converterProvider);
        var mapAddr = widget.convertSchemaMap.sourceSchemaMap;
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
              for (var connection in widget.convertSchemaMap.fieldConversions) {
                var convertField = connection.defaultSourceSchemaField;

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
            "No Source Field",
            style: TextStyle(color: AlpineColors.warningColor),
          ),
          items: (uniqueFields ?? schemaMapFields)
              .map((f) => DropdownMenuItem<SchemaField>(
                  child: Wrap(
                    clipBehavior: Clip.antiAlias,
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    runAlignment: WrapAlignment.center,
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
            widget.convertSchemaField.defaultSourceSchemaField = result;
            widget.convertSchemaField.defaultAdapters = [];
            setState(() {});
          },
        );
      },
    );
  }

  Widget _buildDestinationDropdown() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        var dataOrigin = ref.read(destinationOriginProvider);
        var fieldAddr = widget.convertSchemaField.destinationSchemaField;
        var field = fieldAddr != null ? SchemaConverter.getFromSchemaAddress(dataOrigin.getSchema(), fieldAddr) : null;
        var converter = ref.read(converterProvider);
        var mapAddr = widget.convertSchemaMap.destinationSchemaMap;
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
              for (var connection in widget.convertSchemaMap.fieldConversions) {
                var convertField = connection.destinationSchemaField;

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
          isExpanded: true,
          icon: const SizedBox(),
          hint: Text(
            "No Destination Field",
            style: TextStyle(color: AlpineColors.warningColor),
          ),
          items: (uniqueFields ?? schemaMapFields)
              .map((f) => DropdownMenuItem<SchemaField>(
                  child: Wrap(
                    clipBehavior: Clip.antiAlias,
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    runAlignment: WrapAlignment.center,
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
            widget.convertSchemaField.destinationSchemaField = result;
            widget.convertSchemaField.defaultAdapters = [];
            setState(() {});
          },
        );
      },
    );
  }

  List<Widget> _buildEditConditionalWidgets() {
    var entries = widget.convertSchemaField.conditionals.entries.toList();
    List<Widget> widgets = [];
    for (int i = 0; i < entries.length; i++) {
      widgets.add(EditConditionalWidget(
        convertSchemaMap: widget.convertSchemaMap,
        convertSchemaField: widget.convertSchemaField,
        entry: entries[i],
        conditionNumber: i,
        onDelete: () => setState(() => widget.convertSchemaField.conditionals.remove(entries[i].key)),
      ));
    }
    return widgets;
  }
}

class EditConditionalWidget extends StatefulWidget {
  EditConditionalWidget({
    super.key,
    required MapEntry<ConvertConditional, ConvertAdapters> entry,
    required this.convertSchemaMap,
    required this.convertSchemaField,
    required this.conditionNumber,
    required this.onDelete,
  })  : conditional = entry.key,
        convertAdapters = entry.value;

  final ConvertConditional conditional;
  final ConvertAdapters convertAdapters;
  final ConvertSchemaMap convertSchemaMap;
  final ConvertSchemaField convertSchemaField;
  final int conditionNumber;
  final VoidCallback onDelete;

  @override
  State<EditConditionalWidget> createState() => _EditConditionalWidgetState();
}

class _EditConditionalWidgetState extends State<EditConditionalWidget> {
  bool _isHovering = false;
  bool _isDeleteHovering = false;

  @override
  Widget build(BuildContext context) {
    // return Text(conditional.toString());
    return MouseRegion(
      onEnter: (e) => setState(() => _isHovering = true),
      onExit: (e) => setState(() => _isHovering = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: AlpineColors.background1c,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: AlpineColors.background3b),
        ),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  height: 40,
                  child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Condition #" + (widget.conditionNumber + 1).toString(),
                            style: TextStyle(color: AlpineColors.textColor1),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onEnter: (event) => setState(() => _isDeleteHovering = true),
                            onExit: (event) => setState(() => _isDeleteHovering = false),
                            child: GestureDetector(
                              onTap: widget.onDelete,
                              child: _isHovering
                                  ? _isDeleteHovering
                                      ? Icon(Icons.delete, color: AlpineColors.warningColor)
                                      : Icon(Icons.delete_outline, color: Colors.white.withOpacity(0.15))
                                  : const SizedBox(width: 0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Row(children: [
                  ..._buildIfTitle(),
                  const Expanded(child: SizedBox()),
                  AddWidget(onTap: () {
                    if (widget.convertAdapters.sourceSchemaFields.isNotEmpty) {
                      widget.conditional.conditions.add(SingleConvertCondition(
                        preOperandField: widget.convertAdapters.sourceSchemaFields.first,
                        operator: ConnectionConditonOperator.equals,
                        postOperand: "",
                      ));
                      setState(() {});
                    }
                  }),
                ]),
                if (widget.conditional.conditions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("No Conditions", style: TextStyle(color: AlpineColors.warningColor.withOpacity(0.5))),
                  ),
                ...widget.conditional.conditions.map((el) => ConditionWidget(
                      condition: el,
                      sourceSchemaMap: widget.convertSchemaMap.sourceSchemaMap,
                      onDelete: () {
                        widget.conditional.conditions.remove(el);
                        setState(() {});
                      },
                    )),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Then use this field and adapters:",
                      style: TextStyle(color: AlpineColors.textColor1),
                    ),
                    const Expanded(child: SizedBox()),
                    Consumer(builder: (context, ref, child) {
                      return AddWidget(onTap: () {
                        if (widget.convertSchemaField.destinationSchemaField == null) return;

                        var sourceFieldAddr = widget.convertAdapters.sourceSchemaFields.first;
                        var sourceDataOrigin = ref.read(sourceOriginProvider);
                        var sourceSchemaField =
                            SchemaConverter.getFromSchemaAddress(sourceDataOrigin.getSchema(), sourceFieldAddr);
                        List<SchemaDataType> sourceDataTypes =
                            sourceSchemaField is SchemaField ? sourceSchemaField.types : [];

                        var destinationFieldAddr = widget.convertSchemaField.destinationSchemaField;
                        var destinationDataOrigin = ref.read(destinationOriginProvider);
                        var destinationSchemaField = SchemaConverter.getFromSchemaAddress(
                            destinationDataOrigin.getSchema(), destinationFieldAddr!);
                        List<SchemaDataType> destinationDataTypes =
                            destinationSchemaField is SchemaField ? destinationSchemaField.types : [];

                        // TypeAdapter? adapter = TypeAdapter.buildTypeAdapter(sourceDataTypes, destinationDataTypes);
                        // if (adapter != null) {
                        //   widget.convertAdapters.adapters.add(adapter);
                        // }
                        widget.convertAdapters.adapters.add(CopyAdapter(
                          sourceSchemaDataType: sourceDataTypes.first,
                          destinationSchemaDataType: destinationDataTypes.first,
                        ));
                        setState(() {});
                      });
                    }),
                  ],
                ),
                _buildAdapters(),
              ],
            )
          ],
        ),
      ),
    );
  }

  SchemaField? _getFieldFromMap(
      {required DataOrigin dataOrigin, required List<int>? mapAddr, required int fieldIndex}) {
    var schemaMap = mapAddr != null ? SchemaConverter.getFromSchemaAddress(dataOrigin.getSchema(), mapAddr) : null;
    List<SchemaField>? schemaMapFields = schemaMap is SchemaMap ? schemaMap.fields : [];

    return mapAddr != null && mapAddr.isNotEmpty ? schemaMapFields[fieldIndex] : null;
  }

  Widget _buildAdapters() {
    return Consumer(builder: (context, ref, child) {
      print("test");
      SchemaField? sourceSchemaField;
      SchemaField? destinationSchemaField;
      if (widget.convertAdapters.sourceSchemaFields.isNotEmpty) {
        sourceSchemaField = _getFieldFromMap(
          dataOrigin: ref.read(sourceOriginProvider),
          mapAddr: widget.convertSchemaMap.sourceSchemaMap,
          fieldIndex: widget.convertAdapters.sourceSchemaFields.first.last,
        );

        destinationSchemaField = _getFieldFromMap(
          dataOrigin: ref.read(destinationOriginProvider),
          mapAddr: widget.convertSchemaMap.destinationSchemaMap,
          fieldIndex: widget.convertSchemaField.destinationSchemaField != null
              ? widget.convertSchemaField.destinationSchemaField!.last
              : 0,
        );
      }

      return Row(
        children: [
          // AddWidget(onTap: () {}),
          const SizedBox(width: 10),
          _buildSourceField(),

          Expanded(
            child: Column(
              children: [
                if (widget.convertAdapters.adapters.isEmpty)
                  Container(
                    padding: const EdgeInsets.only(left: 42),
                    child: Text("No Adapters", style: TextStyle(color: AlpineColors.warningColor.withOpacity(0.5))),
                  ),
                if (widget.convertAdapters.sourceSchemaFields.isNotEmpty)
                  ...widget.convertAdapters.adapters.map((a) {
                    return TypeAdapterWidget(
                      adapter: a,
                      sourceField: sourceSchemaField,
                      destinationField: destinationSchemaField,
                      onAdapterChange: (typeAdapter) => a = typeAdapter,
                      onDelete: () => setState(() => widget.convertAdapters.adapters.remove(a)),
                    );
                  }).toList(),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSourceField() {
    return Consumer(builder: (context, ref, child) {
      var dataOrigin = ref.read(sourceOriginProvider);
      List<int>? mapAddr = widget.convertSchemaMap.sourceSchemaMap;

      var schemaMap = mapAddr != null ? SchemaConverter.getFromSchemaAddress(dataOrigin.getSchema(), mapAddr) : null;
      List<SchemaField>? schemaMapFields = schemaMap is SchemaMap ? schemaMap.fields : [];
      SchemaField? schemaField;
      if (widget.convertAdapters.sourceSchemaFields.isNotEmpty &&
          widget.convertAdapters.sourceSchemaFields.first.isNotEmpty) {
        schemaField = schemaMapFields[widget.convertAdapters.sourceSchemaFields.first.last];
      }

      var converter = ref.read(converterProvider);

      return DropdownButton<SchemaField?>(
        focusColor: Colors.transparent,
        dropdownColor: AlpineColors.background1a,
        value: schemaField,
        underline: const SizedBox(),
        icon: const SizedBox(),
        hint: Text(
          "No Source Field",
          style: TextStyle(color: AlpineColors.warningColor),
        ),
        items: (schemaMapFields)
            .map((f) => DropdownMenuItem<SchemaField>(
                child: Wrap(
                  clipBehavior: Clip.antiAlias,
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  runAlignment: WrapAlignment.center,
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
          if (result != null) {
            widget.convertAdapters.sourceSchemaFields = [result];
          }
        },
      );
    });
  }

  Widget _buildDropDown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: AlpineColors.textFieldColor1,
      ),
      child: DropdownButton<ConditionOperand>(
        focusColor: Colors.transparent,
        dropdownColor: AlpineColors.textFieldColor1,
        value: widget.conditional.conditionOperand,
        isDense: true,
        underline: const SizedBox(),
        icon: const SizedBox(),
        items: (ConditionOperand.values)
            .map((option) => DropdownMenuItem<ConditionOperand>(
                child: Wrap(
                  clipBehavior: Clip.antiAlias,
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  runAlignment: WrapAlignment.center,
                  children: [
                    Text(
                      option == ConditionOperand.and ? "all" : "any",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ],
                ),
                value: option))
            .toList(),
        onChanged: (ConditionOperand? value) {
          if (value == null) return;
          widget.conditional.conditionOperand = value;
        },
      ),
    );
  }

  List<Widget> _buildIfTitle() => [
        Text("If", style: TextStyle(color: AlpineColors.textColor1)),
        const SizedBox(width: 5),
        _buildDropDown(),
        const SizedBox(width: 5),
        Text("of the below are true:", style: TextStyle(color: AlpineColors.textColor1)),
      ];
}

class ConditionWidget extends StatefulWidget {
  const ConditionWidget({
    super.key,
    required this.condition,
    required this.sourceSchemaMap,
    required this.onDelete,
  });

  final SingleConvertCondition condition;
  final List<int>? sourceSchemaMap;
  final VoidCallback? onDelete;

  @override
  State<ConditionWidget> createState() => _ConditionWidgetState();
}

class _ConditionWidgetState extends State<ConditionWidget> {
  bool _tileHovering = false;
  bool _deleteHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _tileHovering = true),
      onExit: (event) => setState(() => _tileHovering = false),
      child: GestureDetector(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Row(children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (event) => setState(() => _deleteHovering = true),
              onExit: (event) => setState(() => _deleteHovering = false),
              child: GestureDetector(
                onTap: widget.onDelete,
                child: _tileHovering
                    ? _deleteHovering
                        ? Icon(Icons.delete, color: AlpineColors.warningColor)
                        : Icon(Icons.delete_outline, color: Colors.white.withOpacity(0.15))
                    : const SizedBox(width: 24),
              ),
            ),
            const SizedBox(width: 5),
            FieldSelectorWidget(
              index: widget.condition.preOperandField.last,
              onChange: (i) => widget.condition.preOperandField = i,
              sourceSchemaMap: widget.sourceSchemaMap,
            ),
            _buildOperatorDropDown(),
            Expanded(
              child: _buildOperandInput(),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildOperatorDropDown() {
    return DropdownButton<ConnectionConditonOperator>(
      focusColor: Colors.transparent,
      dropdownColor: AlpineColors.background1a,
      value: widget.condition.operator,
      underline: const SizedBox(),
      icon: const SizedBox(),
      hint: Text(
        "No Source Field",
        style: TextStyle(color: AlpineColors.warningColor),
      ),
      items: ConnectionConditonOperator.values
          .map((o) => DropdownMenuItem<ConnectionConditonOperator>(
              child: Wrap(
                clipBehavior: Clip.antiAlias,
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.start,
                runAlignment: WrapAlignment.center,
                children: [
                  Text(
                    o.name,
                    style: TextStyle(color: AlpineColors.textColor2, fontSize: 12),
                  ),
                ],
              ),
              value: o))
          .toList(),
      onChanged: (ConnectionConditonOperator? value) {
        if (value == null) return;
        widget.condition.operator = value;
        // var result = converter.getAddress(dataOrigin.getSchema(), value);
        // widget.convertSchemaField.defaultSourceSchemaField = result;
        // widget.convertSchemaField.defaultAdapters = [];
        // setState(() {});
      },
    );
  }

  _handleOnChanged(String value) {
    widget.condition.postOperand = value;
  }

  Widget _buildOperandInput() {
    return Consumer(builder: (context, ref, child) {
      if ([ConnectionConditonOperator.isNotNull, ConnectionConditonOperator.isNull]
          .contains(widget.condition.operator)) {
        return const SizedBox();
      }
      var sourceOrigin = ref.read(sourceOriginProvider);
      var obj = SchemaConverter.getFromSchemaAddress(sourceOrigin.getSchema(), widget.condition.preOperandField);
      if (obj is! SchemaField) return const Text("Not supported type");

      List<SchemaDataType> types = obj.types;

      if (types.contains(SchemaInt.object())) {
        return IntField(
          controller: TextEditingController(text: widget.condition.postOperand),
          onChanged: _handleOnChanged,
        );
      } else if (types.contains(SchemaFloat.object())) {
        return FloatField(
          controller: TextEditingController(text: widget.condition.postOperand),
          onChanged: _handleOnChanged,
        );
      } else if (types.contains(SchemaString.object())) {
        return StringField(
          controller: TextEditingController(text: widget.condition.postOperand),
          onChanged: _handleOnChanged,
        );
      }

      return const Text("Not supported type.");
    });
  }
}

class FieldSelectorWidget extends StatelessWidget {
  const FieldSelectorWidget({
    Key? key,
    required this.index,
    required this.onChange,
    required this.sourceSchemaMap,
  }) : super(key: key);

  final int index;
  final Function(List<int>) onChange;
  final List<int>? sourceSchemaMap;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      var dataOrigin = ref.read(sourceOriginProvider);
      List<int>? mapAddr = sourceSchemaMap;

      var schemaMap = mapAddr != null ? SchemaConverter.getFromSchemaAddress(dataOrigin.getSchema(), mapAddr) : null;
      List<SchemaField>? schemaMapFields = schemaMap is SchemaMap ? schemaMap.fields : [];
      SchemaField? schemaField;
      if (schemaMapFields.isNotEmpty && schemaMapFields.length > index) {
        schemaField = schemaMapFields[index];
      }

      var converter = ref.read(converterProvider);

      return DropdownButton<SchemaField?>(
        focusColor: Colors.transparent,
        dropdownColor: AlpineColors.background1a,
        value: schemaField,
        underline: const SizedBox(),
        icon: const SizedBox(),
        hint: Text(
          "No Source Field",
          style: TextStyle(color: AlpineColors.warningColor),
        ),
        items: (schemaMapFields)
            .map((f) => DropdownMenuItem<SchemaField>(
                child: Wrap(
                  clipBehavior: Clip.antiAlias,
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  runAlignment: WrapAlignment.center,
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
          if (result != null) {
            onChange(result);
          }
        },
      );
    });
  }
}
