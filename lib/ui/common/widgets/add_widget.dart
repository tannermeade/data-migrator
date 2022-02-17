import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:flutter/material.dart';

class AddWidget extends StatefulWidget {
  const AddWidget({
    Key? key,
    this.onTap,
  }) : super(key: key);

  final VoidCallback? onTap;

  @override
  State<AddWidget> createState() => _AddWidgetState();
}

class _AddWidgetState extends State<AddWidget> {
  bool _onHover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _onHover = true),
      onExit: (event) => setState(() => _onHover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: _onHover
            ? Icon(Icons.add_circle, color: AlpineColors.buttonColor2)
            : Icon(Icons.add, color: Colors.white.withOpacity(0.25)),
      ),
    );
  }
}
