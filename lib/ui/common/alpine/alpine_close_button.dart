import 'alpine_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class AlpineCloseButton extends StatelessWidget {
  const AlpineCloseButton({
    Key? key,
    this.onTap,
  }) : super(key: key);

  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: AlpineColors.buttonColor2,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(7),
          child: Icon(FontAwesome.close, color: AlpineColors.background1a, size: 16),
        ),
      ),
    );
  }
}
