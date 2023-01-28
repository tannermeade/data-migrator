import 'package:data_migrator/domain/conversion/conversion/convert_schema_field.dart';
import 'package:data_migrator/domain/conversion/conversion/convert_schema_map.dart';
import 'package:data_migrator/domain/conversion/conversion/schema_converter.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/infastructure/data_origins/csv_origin/csv_origin.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:data_migrator/ui/common/values/providers.dart';
import 'package:data_migrator/ui/common/widgets/add_widget.dart';
import 'package:data_migrator/ui/common/widgets/convert_schema_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class ConvertSchemaMapWidget extends StatefulWidget {
  const ConvertSchemaMapWidget({
    Key? key,
    required this.convertSchemaMap,
    this.onDelete,
  }) : super(key: key);

  final ConvertSchemaMap convertSchemaMap;
  final VoidCallback? onDelete;

  @override
  State<ConvertSchemaMapWidget> createState() => _ConvertSchemaMapWidgetState();
}

class _ConvertSchemaMapWidgetState extends State<ConvertSchemaMapWidget> {
  bool _isHovering = false;
  bool _isDeleteHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => setState(() => _isHovering = true),
      onExit: (e) => setState(() => _isHovering = false),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: AlpineColors.background1a,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Stack(
          children: [
            if (_isHovering) _buildDelete(),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildDelete() {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 10),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) => setState(() => _isDeleteHovering = true),
        onExit: (event) => setState(() => _isDeleteHovering = false),
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

  Widget _buildBody() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10, bottom: 5, left: 10, right: 10),
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
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [_buildDropdown(false)],
                ),
              ),
            ],
          ),
        ),
        Divider(color: AlpineColors.background3b, thickness: 1),
        Container(
          width: double.infinity,
          // color: Colors.red,
          margin: const EdgeInsets.only(right: 10, left: 10),
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Fields", style: TextStyle(color: AlpineColors.textColor2)),
              AddWidget(onTap: () => setState(() => widget.convertSchemaMap.fieldConversions.add(ConvertSchemaField()))),
            ],
          ),
        ),
        if (widget.convertSchemaMap.fieldConversions.isEmpty)
          Text("No Field Connections", style: TextStyle(color: AlpineColors.warningColor.withOpacity(0.5))),
        ...widget.convertSchemaMap.fieldConversions
            .map((c) => ConvertSchemaFieldWidget(
                  convertSchemaField: c,
                  convertSchemaMap: widget.convertSchemaMap,
                  onDelete: () => setState(
                    () => widget.convertSchemaMap.fieldConversions.removeWhere((el) => el.hashCode == c.hashCode),
                  ),
                ))
            .toList(),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDropdown(bool forSource) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        var dataOrigin = ref.read(forSource ? sourceOriginProvider : destinationOriginProvider);
        var mapAddr =
            forSource ? widget.convertSchemaMap.sourceSchemaMap : widget.convertSchemaMap.destinationSchemaMap;
        var map = mapAddr != null ? SchemaConverter.getFromSchemaAddress(dataOrigin.getSchema(), mapAddr) : null;
        var converter = ref.read(converterProvider);

        return DropdownButton<SchemaMap>(
          focusColor: Colors.transparent,
          dropdownColor: AlpineColors.background4a,
          value: map,
          underline: const SizedBox(),
          icon: const SizedBox(),
          hint: Text(
            forSource ? "No Source Map" : "No Destination Map",
            style: TextStyle(color: AlpineColors.warningColor),
          ),
          items: [
            ...dataOrigin.getSchema().map((m) => DropdownMenuItem<SchemaMap>(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      m.name,
                      style: TextStyle(color: AlpineColors.textColor2),
                    ),
                    Text(
                      map != null ? converter.getAddress(dataOrigin.getSchema(), m).toString() : "",
                      style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
                value: m))
          ],
          onChanged: (SchemaMap? value) {
            if (value == null) return;
            var result = converter.getAddress(dataOrigin.getSchema(), value);
            if (forSource) {
              widget.convertSchemaMap.sourceSchemaMap = result;
            } else {
              widget.convertSchemaMap.destinationSchemaMap = result;
            }
            setState(() {});
          },
        );
      },
    );
  }
}
