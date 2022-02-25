import 'package:data_migrator/domain/data_types/enums.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_default_value.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_boolean.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_int.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_string.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/appwrite_origin.dart';
import 'package:data_migrator/infastructure/data_origins/data_origin.dart';
import 'package:data_migrator/ui/common/alpine/alpine_data_table.dart';
import 'package:data_migrator/ui/common/alpine/alpine_table.dart';
import 'package:data_migrator/ui/common/alpine/alpine_text_field.dart';
import 'package:data_migrator/ui/common/alpine/alpine_button.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:data_migrator/ui/common/alpine/alpine_close_button.dart';
import 'package:data_migrator/ui/common/values/enums.dart';
import 'package:data_migrator/ui/common/alpine/alpine_id_widget.dart';
import 'package:data_migrator/ui/dialog_handler.dart';
import 'package:data_migrator/ui/common/values/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

import 'add_field_dialog.dart';

class EditSchemaMapDialogData extends DialogData {
  EditSchemaMapDialogData(this.schemaMap, this.forOrigin);
  final SchemaMap schemaMap;
  final Origin forOrigin;
  // final String content;
  // final Function() onDelete;
}

class EditSchemaMapDialog extends StatefulWidget {
  const EditSchemaMapDialog({
    Key? key,
    required this.data,
  }) : super(key: key);

  final EditSchemaMapDialogData data;

  @override
  State<EditSchemaMapDialog> createState() => _EditSchemaMapDialogState();
}

class _EditSchemaMapDialogState extends State<EditSchemaMapDialog> {
  late SchemaMap schemaMap;
  late TextEditingController _nameController;
  late TextEditingController _idController;

  @override
  void initState() {
    schemaMap = SchemaMap.copyWith(widget.data.schemaMap);
    _idController = TextEditingController(text: schemaMap.id ?? "");
    _nameController = TextEditingController(text: schemaMap.name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      backgroundColor: AlpineColors.background1b,
      child: Container(
        width: 600,
        //padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Divider(
                color: AlpineColors.chartLineColor2,
                thickness: 2,
              ),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 40, top: 35, bottom: 25, right: 40),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            schemaMap.name,
            style: TextStyle(
              // color: AlpineColors.textColor1,
              fontSize: 20,
              fontWeight: FontWeight.w200,
            ),
          ),
          AlpineCloseButton(onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
        margin: const EdgeInsets.only(top: 30, bottom: 30),
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                var prov = widget.data.forOrigin == Origin.source ? sourceOriginProvider : destinationOriginProvider;
                var dataOrigin = ref.read(prov);
                var doShow = dataOrigin is AppwriteOrigin;
                if (doShow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Schema id",
                        style: TextStyle(
                          color: AlpineColors.textColor1,
                          fontSize: 16,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      const SizedBox(height: 15),
                      AlpineIdWidget(
                        textController: _idController,
                        editable: schemaMap.mutable,
                        startEditing: _idController.text.isNotEmpty,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
            Text(
              "Schema name",
              style: TextStyle(
                color: AlpineColors.textColor1,
                fontSize: 16,
                fontWeight: FontWeight.w200,
              ),
            ),
            const SizedBox(height: 15),
            !schemaMap.mutable
                ? AlpineIdWidget(
                    textController: _nameController,
                    editable: false,
                    startEditing: _nameController.text.isNotEmpty,
                    width: double.infinity,
                  )
                : AlpineTextField(nameController: _nameController),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "Fields",
                  style: TextStyle(
                    color: AlpineColors.textColor1,
                    fontSize: 16,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                Expanded(child: Container()),
                if (schemaMap.mutable)
                  AlpineButton(
                    color: AlpineColors.buttonColor2,
                    isFilled: true,
                    label: 'Add',
                    height: 35,
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) => Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
                                return AddFieldDialog(
                                    onAddField: (field) {
                                      for (var iField in schemaMap.fields) {
                                        if (iField.title == field.title) return false;
                                      }
                                      setState(() => schemaMap =
                                          SchemaMap.copyWith(schemaMap, fields: schemaMap.fields + [field]));
                                      return true;
                                    },
                                    field: SchemaField(
                                      title: '',
                                      isList: false,
                                      required: true,
                                      types: [
                                        SchemaString(
                                          type: StringType.text,
                                          defaultValue: null,
                                        )
                                      ],
                                    ));
                              }));
                    },
                  ),
              ],
            ),
            const SizedBox(height: 15),
            ..._buildFields(),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer(builder: (context, ref, child) {
                  return AlpineButton(
                    label: "Save",
                    color: AlpineColors.buttonColor2,
                    isFilled: true,
                    onTap: () {
                      var dataOrigin = ref.read(
                          widget.data.forOrigin == Origin.source ? sourceOriginProvider : destinationOriginProvider);
                      dataOrigin.updateSchema(
                        newObj: SchemaMap.copyWith(
                          schemaMap,
                          id: _idController.text,
                          name: _nameController.text,
                        ),
                        oldObj: widget.data.schemaMap,
                      );
                      // schemaMap.id = _idController.text;
                      // schemaMap.name = _nameController.text;
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(width: 10),
                AlpineButton(
                  label: "Cancel",
                  color: AlpineColors.buttonColor2,
                  isFilled: false,
                  onTap: () => Navigator.pop(context),
                ),
                Expanded(
                    child: Align(
                  alignment: Alignment.centerRight,
                  child: Consumer(
                    builder: (BuildContext context, WidgetRef ref, Widget? child) {
                      var dataOrigin = ref.read(
                          widget.data.forOrigin == Origin.source ? sourceOriginProvider : destinationOriginProvider);
                      return AlpineButton(
                        label: "Remove From Migration",
                        width: 225,
                        textColor: Colors.white,
                        color: AlpineColors.warningColor,
                        isFilled: true,
                        onTap: () {
                          var converter = ref.read(converterProvider);
                          var addr = converter.getAddress(dataOrigin.getSchema(), widget.data.schemaMap);
                          // need to update state here still...
                          // converter.schemaConversions.removeWhere((el) {
                          //   return widget.data.forOrigin == Origin.source
                          //       ? listEquals(addr, el.sourceSchemaMap)
                          //       : listEquals(addr, el.destinationSchemaMap);
                          // });
                          dataOrigin.deleteFromSchema(schemaObj: widget.data.schemaMap);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                )),
              ],
            ),
          ],
        ));
  }

  List<Widget> _buildFields() {
    return [
      AlpineDataTable(
        showCellBorder: false,
        headers: const [],
        data: schemaMap.fields
            .map((field) => [
                  field.title,
                  field.types.map((t) => t.readableString()).join(', '),
                  field.isList ? "array" : "single value",
                  // field.required ? "required" : "not required",
                  field.types.toString(),
                  // if (field.types.isNotEmpty && field.types.first is SchemaInt)
                  //   (field.types.first as SchemaDefaultValue).defaultValue.toString(),
                  if (schemaMap.mutable)
                    Consumer(
                      builder: (context, ref, child) {
                        var prov =
                            widget.data.forOrigin == Origin.source ? sourceOriginProvider : destinationOriginProvider;
                        var dataOrigin = ref.read(prov);
                        return AlpineButton(
                          label: "Delete",
                          textColor: Colors.white,
                          color: AlpineColors.warningColor,
                          isFilled: true,
                          onTap: () => setState(() {
                            schemaMap = SchemaMap.copyWith(
                              schemaMap,
                              fields: schemaMap.fields.where((f) => f != field).toList(),
                            );
                          }),
                        );
                      },
                    ),
                ])
            .toList(),
      ),
    ];
  }
}
