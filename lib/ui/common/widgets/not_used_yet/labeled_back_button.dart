import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:flutter/material.dart';

class LabeledBackButton extends StatefulWidget {
  const LabeledBackButton({
    Key? key,
    this.onTap,
    required this.label,
  }) : super(key: key);

  final Function()? onTap;
  final String label;

  @override
  State<LabeledBackButton> createState() => _LabeledBackButtonState();
}

class _LabeledBackButtonState extends State<LabeledBackButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (event) => setState(() => isHovering = true),
        onExit: (event) => setState(() => isHovering = false),
        cursor: SystemMouseCursors.click,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Icon(Icons.arrow_back_ios, color: AlpineColors.textColor1, size: 15),
              transform: Transform.translate(
                offset: Offset(isHovering ? -3 : 0, 0),
              ).transform,
            ),
            Text(
              widget.label,
              style: TextStyle(color: AlpineColors.textColor1, fontSize: 15, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}
