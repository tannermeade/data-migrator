import 'package:data_migrator/domain/data_types/enums.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:data_migrator/ui/common/values/enums.dart';
import 'package:data_migrator/ui/dialog_handler.dart';
import 'package:data_migrator/ui/dialogs/edit_schema_map_dialog.dart';
import 'package:data_migrator/ui/common/values/routes.dart';
import 'package:flutter/material.dart';

class SchemaMapWidget extends StatelessWidget {
  const SchemaMapWidget({
    Key? key,
    required this.schemaMap,
    required this.forOrigin,
    this.onEdit,
    this.icon,
  }) : super(key: key);

  final SchemaMap schemaMap;

  final VoidCallback? onEdit;
  final Widget? icon;
  final Origin? forOrigin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: AlpineColors.background3b,
        borderRadius: BorderRadius.circular(8),
        // border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(context),
          Divider(color: AlpineColors.background1b, thickness: 1),
          ...schemaMap.fields
              .map((f) => Text("${f.title}(${f.types.map((t) => t.readableString()).join(', ')})"))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(schemaMap.name),
                if (schemaMap.id != null)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: SelectableText(
                      schemaMap.id!,
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (schemaMap.classification != SchemaClassification.regular)
          Container(
            alignment: Alignment.topLeft,
            child: Tooltip(
                message: "This is a custom SchemaMap that will be handled in a special way when migrating data.",
                child: Text(
                  "custom",
                  style: TextStyle(color: Colors.grey.withOpacity(0.5)),
                )),
          ),
        if (forOrigin != null)
          Container(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: onEdit ??
                  () => toPopUp(
                        context,
                        Routes.editSchemaMapDialog,
                        EditSchemaMapDialogData(schemaMap, forOrigin!),
                      ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: icon ??
                    const Tooltip(
                      message: "Configure",
                      child: Icon(
                        Icons.more_vert_rounded,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),
          ),
      ],
    );
  }
}
