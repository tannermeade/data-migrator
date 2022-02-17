import 'package:data_migrator/domain/conversion/type_adpaters/type_adapter.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:flutter/material.dart';

class TypeAdapterWidget extends StatefulWidget {
  const TypeAdapterWidget({
    Key? key,
    required this.adapter,
    this.onDelete,
  }) : super(key: key);

  final TypeAdapter adapter;
  final VoidCallback? onDelete;

  @override
  State<TypeAdapterWidget> createState() => _TypeAdapterWidgetState();
}

class _TypeAdapterWidgetState extends State<TypeAdapterWidget> {
  bool _tileHovering = false;
  bool _deleteHovering = false;

  @override
  Widget build(BuildContext context) {
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
                  // const Text("", style: TextStyle(fontSize: 12)),
                  Text(
                    widget.adapter.runtimeType.toString(),
                    style: TextStyle(color: AlpineColors.textColor2),
                  ),
                  Text(
                    widget.adapter.sourceSchemaDataType.readableString() +
                        " to " +
                        widget.adapter.destinationSchemaDataType.readableString(),
                    style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
