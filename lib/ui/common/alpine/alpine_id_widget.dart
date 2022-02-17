import 'alpine_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class AlpineIdWidget extends StatefulWidget {
  const AlpineIdWidget({
    Key? key,
    this.textController,
    this.width = 300,
    this.subLabel,
    this.editable = false,
    this.startEditing = false,
    this.subLabelEditing = "Allowed Characters A-Z, a-z, 0-9, and non-leading underscore",
  }) : super(key: key);

  final TextEditingController? textController;
  final double? width;
  final String? subLabel;
  final String subLabelEditing;
  final bool editable;
  final bool startEditing;

  @override
  State<AlpineIdWidget> createState() => _AlpineIdWidgetState();
}

class _AlpineIdWidgetState extends State<AlpineIdWidget> {
  late bool editing;
  late TextEditingController _textController;
  String? cachedText;

  @override
  void initState() {
    editing = widget.startEditing;
    _textController = widget.textController ?? TextEditingController(text: "unique()");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var idWidget = widget.editable ? _buildEditableIdWidget() : _buildCopyIdWidget();

    return widget.subLabel == null
        ? idWidget
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              idWidget,
              const SizedBox(height: 10),
              SelectableText(
                editing ? widget.subLabelEditing : widget.subLabel!,
                style: TextStyle(
                  color: AlpineColors.textColor2,
                  fontSize: 10,
                  fontWeight: FontWeight.w100,
                  height: 1.5,
                ),
              ),
            ],
          );
  }

  Container _buildCopyIdWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black38, width: 1),
        color: AlpineColors.background4a,
      ),
      width: widget.width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                color: AlpineColors.buttonColor3,
                child: Text(
                  _textController.text,
                  style: TextStyle(
                    color: AlpineColors.textColor1,
                    fontWeight: FontWeight.w200,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: _textController.text));
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Copied code to your clipboard.")));
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Icon(
                    FontAwesome.copy,
                    size: 18,
                    color: AlpineColors.textColor1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableIdWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black38, width: 1),
        color: AlpineColors.background4a,
      ),
      width: widget.width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Container(
                padding: editing ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                color: AlpineColors.buttonColor3,
                child: editing
                    ? TextField(
                        controller: _textController,
                        cursorColor: Colors.black,
                        cursorWidth: 1,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          fillColor: AlpineColors.textColor1,
                          filled: true,
                          focusColor: AlpineColors.textColor1,
                          hoverColor: AlpineColors.textColor1,
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                          ),
                        ),
                      )
                    : Text(
                        "unique()",
                        // _textController.text.isEmpty ? "unique()" : _textController.text,
                        style: TextStyle(
                          color: AlpineColors.textColor1,
                          fontWeight: FontWeight.w200,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (editing) {
                    cachedText = _textController.text;
                    _textController.text = "";
                  } else if (cachedText != null) {
                    _textController.text = cachedText!;
                    cachedText = null;
                  }
                  editing = !editing;
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Icon(
                    editing ? FontAwesome.random : FontAwesome.edit,
                    size: 18,
                    color: AlpineColors.textColor1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
