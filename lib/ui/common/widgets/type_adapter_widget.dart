import 'package:data_migrator/domain/conversion/type_adpaters/copy_adapter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/float_adapter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/int_adapter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/string_adapter.dart';
import 'package:data_migrator/domain/conversion/type_adpaters/type_adapter.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:data_migrator/ui/common/values/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TypeAdapterWidget extends StatefulWidget {
  const TypeAdapterWidget({
    Key? key,
    required this.adapter,
    required this.sourceField,
    required this.destinationField,
    required this.onAdapterChange,
    this.onDelete,
  }) : super(key: key);

  final SchemaField? sourceField;
  final SchemaField? destinationField;
  final TypeAdapter adapter;
  final VoidCallback? onDelete;
  final Function(TypeAdapter) onAdapterChange;

  @override
  State<TypeAdapterWidget> createState() => _TypeAdapterWidgetState();
}

class _TypeAdapterWidgetState extends State<TypeAdapterWidget> {
  bool _tileHovering = false;
  bool _deleteHovering = false;

  SchemaDataType? sourceType;
  SchemaDataType? destinationType;
  Type? adapterType;
  late TypeAdapter adapter;

  @override
  void initState() {
    super.initState();
    sourceType = widget.adapter.sourceSchemaDataType;
    destinationType = widget.adapter.destinationSchemaDataType;
    adapterType = widget.adapter.runtimeType;
    adapter = widget.adapter;
    print("initState: $adapterType");
  }

  @override
  Widget build(BuildContext context) {
    print("build: $adapterType");
    return MouseRegion(
      onEnter: (event) => setState(() => _tileHovering = true),
      onExit: (event) => setState(() => _tileHovering = false),
      child: GestureDetector(
        // onTap: () {},
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
          child: Row(
            children: [
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
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text("Types: "),
                      _AlpineDropDown<SchemaDataType>(
                        type: adapter.sourceSchemaDataType,
                        typeList: widget.sourceField != null ? widget.sourceField!.types : [],
                        itemBuilder: _dataTypeItemBuilder,
                        onChanged: (SchemaDataType? value) {
                          if (value == null) return;
                          adapter.sourceSchemaDataType = value;
                          sourceType = value;
                          _setAdapter();
                        },
                      ),
                      Text(
                        " to ",
                        style: TextStyle(color: AlpineColors.textColor2),
                      ),
                      _AlpineDropDown<SchemaDataType>(
                        type: adapter.destinationSchemaDataType,
                        typeList: widget.destinationField != null ? widget.destinationField!.types : [],
                        itemBuilder: _dataTypeItemBuilder,
                        onChanged: (SchemaDataType? value) {
                          if (value == null) return;
                          adapter.destinationSchemaDataType = value;
                          destinationType = value;
                          var adapters = _possibleAdapters();
                          _setAdapter(adapters.first);
                        },
                      ),
                    ],
                  ),
                  // Text(
                  //   adapter.runtimeType.toString(),
                  //   style: TextStyle(color: AlpineColors.textColor2),
                  // ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text("Adapter: "),
                      _AlpineDropDown<Type>(
                        type: adapter.runtimeType,
                        typeList: _possibleAdapters(),
                        itemBuilder: (t) => DropdownMenuItem<Type>(
                            child: Text(
                              t.toString(),
                              style: const TextStyle(color: Colors.black, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            value: t),
                        onChanged: (Type? value) {
                          if (value == null) return;
                          adapterType = value;
                          _setAdapter();
                        },
                      ),
                    ],
                  ),
                  // Text(
                  //   adapter.runtimeType.toString(),
                  //   style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 12),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setAdapter([Type? newAdapterType]) {
    try {
      switch (newAdapterType ?? adapterType) {
        case CopyAdapter:
          adapter = CopyAdapter(
            sourceSchemaDataType: sourceType!,
            destinationSchemaDataType: destinationType!,
          );
          break;
        case FloatAdapter:
          adapter = FloatAdapter(
            sourceSchemaDataType: sourceType!,
            destinationSchemaDataType: destinationType!,
          );
          break;
        case IntAdapter:
          adapter = IntAdapter(
            sourceSchemaDataType: sourceType!,
            destinationSchemaDataType: destinationType!,
          );
          break;
        case StringAdapter:
          adapter = StringAdapter(
            sourceSchemaDataType: sourceType!,
            destinationSchemaDataType: destinationType!,
          );
          break;
        default:
      }
      widget.onAdapterChange(adapter);
    } catch(e) {
      print("Failed setting type adapter...");
      print(e);
    }
  }

  List<Type> _possibleAdapters() {
    List<Type> list = [];
    try {
      CopyAdapter(
        sourceSchemaDataType: sourceType!,
        destinationSchemaDataType: destinationType!,
      );
      list.add(CopyAdapter);
    } catch (e) {}

    try {
      FloatAdapter(
        sourceSchemaDataType: sourceType!,
        destinationSchemaDataType: destinationType!,
      );
      list.add(FloatAdapter);
    } catch (e) {}

    try {
      IntAdapter(
        sourceSchemaDataType: sourceType!,
        destinationSchemaDataType: destinationType!,
      );
      list.add(IntAdapter);
    } catch (e) {}

    try {
      StringAdapter(
        sourceSchemaDataType: sourceType!,
        destinationSchemaDataType: destinationType!,
      );
      list.add(StringAdapter);
    } catch (e) {}

    return list;
  }

  DropdownMenuItem<SchemaDataType?> _dataTypeItemBuilder(SchemaDataType t) {
    String str = t.readableString();
    const size = 13;
    return DropdownMenuItem<SchemaDataType>(
        child: Text(
          str.length > size ? str.substring(0, size) : str,
          style: const TextStyle(color: Colors.black, fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        value: t);
  }
}

class _AlpineDropDown<T> extends StatelessWidget {
  const _AlpineDropDown({
    Key? key,
    required this.type,
    required this.typeList,
    required this.onChanged,
    required this.itemBuilder,
  }) : super(key: key);

  final T? type;
  final List<T> typeList;
  final Function(T?) onChanged;
  final DropdownMenuItem<T?> Function(T) itemBuilder;

  @override
  Widget build(BuildContext context) {
    var list = typeList.map(itemBuilder).toList();
    return Container(
      width: 90,
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: AlpineColors.textFieldColor1,
      ),
      child: DropdownButton<T?>(
        focusColor: Colors.transparent,
        dropdownColor: AlpineColors.textFieldColor1,
        value: type,
        isDense: true,
        underline: const SizedBox(),
        icon: const SizedBox(),
        items: list,
        onChanged: onChanged,
      ),
    );
  }
}
