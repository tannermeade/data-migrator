import 'alpine_colors.dart';
import 'package:flutter/material.dart';

class AlpineButton extends StatefulWidget {
  const AlpineButton({
    Key? key,
    required this.label,
    required this.color,
    required this.isFilled,
    this.onTap,
    this.textColor,
    this.width,
    this.fontSize = 16,
    this.height = 45,
    this.padding,
    // this.textHoverColor,
  }) : super(key: key);

  final String label;
  final Color color;
  final Color? textColor;
  // final Color? textHoverColor;
  final bool isFilled;
  final VoidCallback? onTap;
  final double? width;
  final double height;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  @override
  State<AlpineButton> createState() => _AlpineButtonState();
}

class _AlpineButtonState extends State<AlpineButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20),
          height: widget.height,
          width: widget.width,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.isFilled ? widget.color : const Color(0x00000000),
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            border: Border.all(color: widget.color, width: 2),
          ),
          child: Text(widget.label,
              style: TextStyle(
                  color: widget.textColor ?? (widget.isFilled ? AlpineColors.background1a : widget.color),
                  fontWeight: FontWeight.w200,
                  fontSize: widget.fontSize)),
        ),
      ),
    );
  }
}
